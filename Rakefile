require 'bundler/setup'

if File.exists?('.git') && !ENV['CAB_VERSION']
  tags = `git log -n1 --decorate-refs=refs/tags/v* --format=%d`
  if tags =~ /tag: v(\d+\.\d+)/
    ENV['CAB_VERSION'] = $1
  end
end

task :default => [:test]

desc "Run tests"
task :test => ["test:suite", "test:format"]

desc "Runs the test suite"
task "test:suite" do
  sh 'ruby', 'test/run1.rb'
  sh 'ruby', 'test/run2.rb'
  sh 'ruby', 'test/run3.rb'
  puts "*** All tests passed"
end

desc "Checks if formatting is correct"
task "test:format" do
  sh "rufo", "-c", "lib", "bin"
end

desc "Formats the source files"
task "format" do
  sh "rufo", "lib", "bin" do
    # don't care about the status code
  end
end

