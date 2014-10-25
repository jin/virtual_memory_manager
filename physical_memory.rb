require_relative 'frame'
require_relative 'bitmap'
require_relative 'segment_table'
require_relative 'page_table'
require 'PP'

class PhysicalMemory

  attr_reader :bitmap, :frames
  attr_accessor :segment_table

  # 1024 frames of 512 words each
  def initialize(frames = 1024)
    @bitmap = Bitmap.new(frames)
    $frames = {}

    init_segment_table
  end

  def get_word(frame, offset)
    $frames[frame][offset]
  end

  # only called at initialization
  def create_page_table(segment, paddr)
    segment_table.set_segment(segment, paddr.frame)
    $frames[paddr.frame + 1] = $frames[paddr.frame] = PageTable.new(1024)
    @bitmap.set(paddr.frame)
    @bitmap.set(paddr.frame + 1)
  end

  def get_page_table(segment)
    segment_table.get_segment(segment)
  end

  def create_page(page, segment, paddr)
    page_table = $frames[segment_table.get_segment(segment)]
    page_table.set_page(page, paddr.frame)
    if paddr.frame >= 0
      $frames[paddr.frame] ||= Frame.new(512)
      $frames[paddr.frame].set_word(paddr.offset, true)
    end
  end

  def get_page(page_table, page)
    pt = $frames[page_table]
    pt.get_page(page)
  end

  private

  def init_segment_table
    @segment_table = SegmentTable.new
    $frames[0] = @segment_table
  end

end
