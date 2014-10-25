class Frame
  attr_reader :words
  attr_reader :size

  def initialize(size = 512)
    # @words = Array.new(size)
    @words = Hash.new
    @size = size
  end

  def get_word(index)
    @words[index]
  end

  def set_word(index, value)
    @words[index] = value
  end
end
