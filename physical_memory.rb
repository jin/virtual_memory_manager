require_relative 'frame'
require_relative 'bitmap'
require_relative 'segment_table'
require_relative 'page_table'

class PhysicalMemory

  attr_reader :bitmap, :frames
  attr_accessor :segment_table

  # 1024 frames of 512 words each
  def initialize(frames = 1024)
    @bitmap = Bitmap.new(frames)
    @frames = {}

    init_segment_table
  end

  # only called at initialization
  def create_page_table(segment, paddr)
    segment_table.set_segment(segment, paddr.frame)
    @frames[paddr.frame] = PageTable.new(1024)
    @bitmap.set(paddr.frame)
    @bitmap.set(paddr.frame + 1)
  end

  def get_page_table(index)
  end

  def create_page(page, segment, paddr)
    page_table = @frames[segment_table.get_segment(segment)]
    page_table.set_page(page, paddr.frame)
    p @segment_table
    p @frames
    p page_table
  end

  private

  def init_segment_table
    @segment_table = SegmentTable.new
    @frames[0] = @segment_table
    @bitmap.set 0
  end

end
