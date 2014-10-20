class VirtualAddress

  attr_reader :segment, :page, :offset, :address

  def initialize(address)
    raise "Address is not valid." unless is_valid?(address)

    @address = address 
    @segment, @page, @offset = partition(@address)
  end

  def is_valid?(address)
    address.is_a?(Integer) && address >= 0 && address < 2 ** 32
  end

  def partition(address)
    offset = address & (511 - 1)
    page = (address & (1023 << 9)) >> 9
    segment = (address & (511 << 19)) >> 19
    [segment, page, offset]
  end

end
