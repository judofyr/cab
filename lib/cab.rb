require 'set'

class Cab
  def initialize(dir:, &blk)
    @block = blk
    @dir = dir
    @files = {}

    @trace = TracePoint.new(:line, :end) do |tp|
      if handle_path?(tp.path)
        file = lookup_or_insert_file(tp.path)
        file.mark_loaded

        tp.binding.eval('caller_locations').each do |frame|
          if frame.path != tp.path && requirerer = lookup_file(frame.path)
            file.included_by(requirerer)
          end
        end

        if tp.event == :end
          file.add_constant(tp.self)
        end
      end
    end
  end

  def self.rack(*args, &blk)
    cab = new(*args, &blk)
    proc { |env| cab.run.call(env) }
  end

  def run
    to_unload = []
    to_delete = []

    @files.each_value do |file|
      case file.tick
      when :deleted
        to_unload << file
        to_delete << file.path
      when :changed
        to_unload << file
      end
    end

    to_unload.each(&:unload)
    to_delete.each do |path|
      remove_file(path)
    end

    @trace.enable do
      @block.call
    end
  end

  private

  def lookup_or_insert_file(path)
    @files[path] ||= TrackedFile.new(path)
  end

  def lookup_file(path)
    @files[path]
  end

  def remove_file(path)
    @files.delete(path)
  end

  def handle_path?(path)
    path.start_with?(@dir)
  end

  class TrackedFile
    attr_reader :path

    def initialize(path)
      @path = path
      @constants = Set.new
      @parents = Set.new
      @mtime = File.mtime(path)
      @is_unloaded = false
    end

    def mark_loaded
      @is_unloaded = false
    end

    def add_constant(const)
      @constants << const
    end

    def included_by(file)
      @parents << file
    end

    # Returns `true` if the file has changed
    def tick
      old_mtime = @mtime
      begin
        @mtime = File.mtime(@path)
      rescue Errno::ENOENT
        :deleted
      else
        if @mtime != old_mtime
          :changed
        else
          :unchanged
        end
      end
    end

    def load
      require(@path)
    end

    def unload
      return if @is_unloaded
      @is_unloaded = true

      @constants.each do |const|
        unload_constant(const)
      end
      @constants.clear

      unload_require

      @parents.each do |parent|
        parent.unload
      end
      @parents.clear
    end

    def unload_constant(const)
      parts = const.name.split('::')
      last_name = parts.pop

      parent_scope = parts.reduce(Object) do |scope, name|
        if !scope.const_defined?(name, false)
          # Weirdly named class/module. Ignore it.
          return
        end

        scope.const_get(name, false)
      end

      parent_scope.send(:remove_const, last_name)
    end

    def unload_require
      $LOADED_FEATURES.delete(@path)
    end
  end
end
