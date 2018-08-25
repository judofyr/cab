require 'set'

class Cab
  def initialize(dir:, &blk)
    @block = blk
    @dir = dir
    @files = {}

    @trace = TracePoint.new(:line, :end) do |tp|
      if handle_path?(tp.path)
        file = lookup_or_insert_file(tp.path)

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
    to_reload = []

    @files.each_value do |file|
      did_change = file.tick
      to_reload << file if did_change
    end

    to_reload.each(&:unload)

    @trace.enable do
      to_reload.each(&:load)
      @block.call
    end
  end

  private

  def lookup_or_insert_file(path)
    @files[path] ||= TrackedFile.new(path)
  end

  def handle_path?(path)
    path.start_with?(@dir)
  end

  class TrackedFile
    attr_reader :path

    def initialize(path)
      @path = path
      @constants = Set.new
      @mtime = File.mtime(path)
    end

    def add_constant(const)
      @constants << const
    end

    # Returns `true` if the file has changed
    def tick
      old_mtime = @mtime
      @mtime = File.mtime(@path)
      return @mtime != old_mtime
    end

    def load
      require(@path)
    end

    def unload
      @constants.each do |const|
        unload_constant(const)
      end
      @constants.clear

      unload_require
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
