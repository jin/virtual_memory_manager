class Bitmap

  # Bitmap for keeping track of free frames
  # Size = 1024 bits
  # false => free
  # true  => occupied

  def initialize(options = {})
    @map = Array.new(options[:size], false)
  end

  def is_set?(bit)
    check_valid_bit_index(bit)
    @map[bit]
  end

  def set(bit)
    check_valid_bit_index(bit)
    @map[bit] = true
  end

  def unset(bit)
    check_valid_bit_index(bit)
    @map[bit] = false
  end

  def check_valid_bit_index(bit)
    raise 'Requested bit is outside of range' if bit < 0 || bit >= @map.length
  end

  private

  attr_accessor :map

end
