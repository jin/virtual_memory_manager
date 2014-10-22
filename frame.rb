class Frame
  attr_reader :words

  def initialize(size = 512)
    @words = Array.new(size)
  end

  def get_word_at(index)
    @words[index]
  end

  def set_word_at(index, value)
    @words[index] = value
  end
end
