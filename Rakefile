if File.exists?('.git') && !ENV['CAB_VERSION']
  tags = `git log -n1 --decorate-refs=refs/tags/v* --format=%d`
  if tags =~ /tag: v(\d+\.\d+)/
    ENV['CAB_VERSION'] = $1
  end
end

task :default => [:test]

task :test do
  sh 'ruby', 'test/run1.rb'
  sh 'ruby', 'test/run2.rb'
  sh 'ruby', 'test/run3.rb'
  puts "*** All tests passed"
end

