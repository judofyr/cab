$LOAD_PATH << File.expand_path('../lib', __dir__)
require 'pathname'
require 'open3'
require 'tmpdir'
require 'minitest'

class << self
  include Minitest::Assertions
  attr_accessor :assertions
end
self.assertions = 0

class GitDirectory
  attr_reader :path

  def self.with_mbox(path)
    Dir.mktmpdir do |dir|
      git = new(dir)
      git.init
      git.import_mbox(path)
      yield git.walker
    end
  end

  def initialize(path)
    @path = Pathname.new(path).expand_path
  end

  def git(*args)
    env = {
      "GIT_DIR" => (@path + ".git").to_s,
      "GIT_WORK_TREE" => @path.to_s,
    }
    stdout, status = Open3.capture2(env, "git", *args)
    if !status.success?
      raise "Command failed: git #{args.join(" ")}"
    end
    stdout
  end

  def export_mbox
    git("format-patch", "--root", "--stdout")
  end

  def init
    git("init")
  end

  def import_mbox(path)
    git("am", "--quiet", "--whitespace=nowarn", path.to_s)
  end

  def commits
    git("log", "--format=%H").split.reverse
  end

  def checkout(sha1)
    git("checkout", "--quiet", sha1)
    changed_files = git("diff-tree", "--no-commit-id", "--name-only", sha1).split
    timestamp = git("show", "-s", "--format=%at", sha1).to_i
    mtime = Time.at(timestamp)
    changed_files.each do |file|
      path = (@path + file).to_s
      File.utime(File.atime(path), mtime, path)
    end
  end

  def walker
    Walker.new(self, commits)
  end

  class Walker
    def initialize(git, commits)
      @git = git
      @commits = commits
    end

    def path
      @git.path
    end

    def next
      commit = @commits.shift or raise "No next commit"
      @git.checkout(commit)
    end
  end
end

if $0 == __FILE__
  case ARGV.shift
  when "export"
    dir = GitDirectory.new(ARGV[0])
    print dir.export_mbox
  end
end

