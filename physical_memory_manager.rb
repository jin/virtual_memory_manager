require_relative 'frame'
require_relative 'page'
require_relative 'segment_table'
require_relative 'page_table'
require 'PP'

class PhysicalMemoryManager

  # attr_reader :bitmap, :frames
  # attr_accessor :segment_table
  
  attr_accessor :frames, :segment_table

  # 1024 frames of 512 words each
  def initialize(frames = 1024)
    $frames = Frame.new(1024)

    init_segment_table
  end

  # Called only at initialization stage
  def init_page_table(for_segment, at_frame)
    @segment_table.set_segment(for_segment, at_frame)

    pt = PageTable.new(1024)
    $frames.set_word(at_frame, pt)
  end

  # Called only at initialization stage
  def init_page(for_segment, page_number, at_frame, with_offset)
    page_table = $frames.get_word(@segment_table.get_segment(for_segment))
    page_table.set_page(page_number, at_frame)

    page = Page.new(512)
    $frames.set_word(at_frame, page) unless at_frame < 0

    page.set_word(with_offset, true)
  end

  def read_from(vaddr)
    pt = $frames.get_word(@segment_table.get_segment(vaddr.segment))
    return "error" if pt.nil?

    page = $frames.get_word(pt.get_page(vaddr.page))
    return "error" if page.nil?

    page.get_word(vaddr.offset) ? pt.get_page(vaddr.page) * 512 + vaddr.offset : "error"
  end

  def write_to(vaddr)
  end

  private

  def init_segment_table
    @segment_table = SegmentTable.new
    $frames.set_word(0, @segment_table)
  end

end
