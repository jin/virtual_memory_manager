class PhysicalAddress < Address

  attr_reader :frame, :offset, :address

  def initialize(address)
    @address = address
    @frame, @offset = (is_resident? @address) ? partition(@address) : [-1, nil]
  end

  def is_resident?(address)
    address.to_i >= 0 
  end

  def partition(address)
    offset = address & 511
    frame = (address >> 9) & 1023 
    [frame, offset]
  end

end
