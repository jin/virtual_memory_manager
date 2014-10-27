require_relative 'bitmap'

class Frame
  attr_reader :words, :size

  def initialize(size = 512)
    @words = Hash.new
    @size = size
  end

  def get_word(index)
    @words.fetch(index, 0)
  end

  def set_word(index, value)
    @words[index] = value
  end

end

