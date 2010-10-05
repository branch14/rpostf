require 'helper'

class TestRpostf < Test::Unit::TestCase
  context 'some array' do
    setup do
      @array = %w(1 2 3 4 5 6)
    end

    should "chunk into pieces of 2 by default" do
      assert_equal [['1', '2'], ['3', '4'], ['5', '6']], @array.chunk
    end

    should "chunk into pices of 3" do
      assert_equal [['1', '2', '3'], ['4', '5', '6']], @array.chunk(3)
    end

    should "not chunk into 4" do
      assert_raise StandardError do
        @array.chunk(4)
      end
    end
  end
end
