require_relative 'bitmap'

class Frame
  attr_reader :words, :size

  def initialize(size = 512)
    @words = Hash.new
    @bitmap = Bitmap.new(size)
    @size = size
  end

  def get_word(index)
    @words.fetch(index, 0)
  end

  def set_word(index, value)
    @words[index] = value
    value.nil? ? @bitmap.unset(index) : @bitmap.set(index) if index
  end

  def find_free_slot(size = 1)
    index = 0
    @bitmap.each_cons(size) do |i|
      return index if i.all? { |x| x }
      index += 1
    end
    nil
  end

  private
  attr_accessor :bitmap

end

