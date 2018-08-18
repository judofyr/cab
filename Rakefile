if File.exists?('.git') && !ENV['CAB_VERSION']
  tags = `git log -n1 --decorate-refs=refs/tags/v* --format=%d`
  if tags =~ /tag: v(\d+\.\d+)/
    ENV['CAB_VERSION'] = $1
  end
end

require 'rake/testtask'

task :default => [:test]

ENV["COVERAGE"] = "1"

Rake::TestTask.new do
end

