require_relative 'virtual_address'
require 'test/unit'

class TestVirtualAddress < Test::Unit::TestCase

  # 6553522 => 0000 000001100 0111111111 110110010
  # 0, 12, 511, 434
  def test_valid_virtual_address
    vaddr = VirtualAddress.new(6553522)
    assert_not_nil(vaddr)
  end

  def test_valid_virtual_address_min
    vaddr = VirtualAddress.new(0)
    assert_not_nil(vaddr)
  end

  def test_invalid_virtual_address_max
    vaddr = VirtualAddress.new(4294967295)
    assert_not_nil(vaddr)
  end

  def test_invalid_virtual_address_large
    assert_raise(RuntimeError) { VirtualAddress.new(4294967295 + 1) }
  end

  def test_invalid_virtual_address_small
    assert_raise(RuntimeError) { VirtualAddress.new(-1) }
  end

  def test_retrieve_segment_from_address
    vaddr = VirtualAddress.new(6553522)
    assert_equal(12, vaddr.segment)
  end

  def test_retrieve_page_from_address
    vaddr = VirtualAddress.new(6553522)
    assert_equal(511, vaddr.page)
  end

  def test_retrieve_offset_from_address
    vaddr = VirtualAddress.new(6553522)
    assert_equal(434, vaddr.offset)
  end

end
