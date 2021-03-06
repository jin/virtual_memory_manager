require 'bitset'

class Bitmap

  attr_reader :bitset

  def initialize(size = 1024)
    @bitset = Bitset.new(1024)
  end

  def is_set?(bit)
    @bitset[bit]
  end

  def set(bit)
    @bitset.set(bit)
  end

  def unset(bit)
    @bitset.clear(bit)
  end

  def find_free_slot(size = 1)
    index = 1
    @bitset.to_a[1..-1].each_cons(size) do |i|
      return index if i.all? { |x| !x }
      index += 1
    end
    nil
  end

end
