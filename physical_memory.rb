require_relative 'frame'
require_relative 'bitmap'

class PhysicalMemory

  attr_reader :memory_map, :bitmap

  # 1024 frames of 512 words each
  def initialize(frames = 1024)
    @bitmap = Array.new(frames)
    @memory_map = {}

    init_segment_table
  end

  def is_free_frame?(index)
    @bitmap.is_set? index
  end

  def get_segment_table
    @memory_map[0]
  end

  def get_page_table_at(index)

  end

  def set_page_table_at(index)
    @memory_map[index] = PageTable.new
    @bitmap.set index
    @bitmap.set index + 1
  end

  def get_page_at(index) 
    @memory_map[index]
  end

  def set_page_at(index)
    @memory_map[index] = Frame.new
    @bitmap.set index
  end

  def get_word_at(frame, offset)
    return frame.get_word_at(offset)
  end

  private

  def init_segment_table
    @memory_map[0] = SegmentTable.new
    @bitmap.set 0
  end

end
