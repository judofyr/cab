require_relative 'helper'

GitDirectory.with_mbox(File.expand_path('example4.mbox', __dir__)) do |walker|
  cab = Cab.new(dir: walker.path.to_s) do
    require(walker.path + 'main.rb')
    ::Main::Value
  end

  walker.next
  assert_equal 1, cab.run

  walker.next
  assert_equal 3, cab.run

  walker.next
  assert_equal 2, cab.run

  walker.next
  assert_equal 4, cab.run
end


