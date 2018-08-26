require_relative 'helper'

GitDirectory.with_mbox(File.expand_path('example3.mbox', __dir__)) do |walker|
  cab = Cab.new(dir: walker.path.to_s) do
    require(walker.path + 'main.rb')
    ::A::Value
  end

  walker.next
  assert_equal 1, cab.run

  walker.next
  assert_equal 2, cab.run

  walker.next
  assert_equal 3, cab.run

  walker.next
  assert_equal 4, cab.run
end


