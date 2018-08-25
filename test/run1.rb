require_relative 'support'
require 'cab'

GitDirectory.with_mbox(__dir__ + '/example1.mbox') do |walker|
  cab = Cab.new(dir: walker.path.to_s) do
    require(walker.path + 'main.rb')
    defined?(::A) ? "A#{::A::Value}" : "B#{::B::Value}"
  end

  walker.next
  assert_equal "A1", cab.run

  walker.next
  assert_equal "A2", cab.run

  walker.next
  assert_equal "B2", cab.run
end

