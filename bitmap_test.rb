require_relative 'bitmap'
require 'test/unit'

class TestBitmap < Test::Unit::TestCase

  def test_set_bit
    map = Bitmap.new(:size => 8)
    map.set(4)
    assert_equal(true, map.is_set?(4))
  end

  def test_unset_bit
    map = Bitmap.new(:size => 8)
    map.set(4)
    map.unset(4)
    assert_equal(false, map.is_set?(4))
  end

  def test_out_of_range_small
    map = Bitmap.new(:size => 8)
    assert_raise(RuntimeError) { map.set(-1) }
  end

  def test_out_of_range_large
    map = Bitmap.new(:size => 8)
    assert_raise(RuntimeError) { map.set(8) }
  end

end
