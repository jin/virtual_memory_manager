class Frame

  def initialize(size = 512)
    @words = Hash.new
  end

  def get_word(index)
    @words.fetch(index, 0)
  end

  def set_word(index, value)
    @words[index] = value
  end

end
