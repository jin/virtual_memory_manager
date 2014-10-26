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

  def init_page_table(for_segment, at_frame)
    @segment_table.set_segment(for_segment, at_frame)

    pt = PageTable.new(1024)
    $frames.set_word(at_frame, pt)
  end

  def init_page(for_segment, page_number, at_frame)
    page_table = $frames.get_word(@segment_table.get_segment(for_segment))
    page_table.set_page(0, at_frame)

    page = Page.new(512)
    $frames.set_word(at_frame, page) unless at_frame < 0
  end

  # #-------------------
  

  # def create_page_table(vaddr)
  # end

  # def create_page(vaddr)
  #   pt = $frames[get_page_table(vaddr.segment)]
  # end

  # def get_word(frame, offset)
  #   $frames[frame][offset]
  # end

  # def get_page_table(segment)
  #   segment_table.get_segment(segment)
  # end

  # def get_page(page_table, page)
  #   pt = $frames[page_table]
  #   pt.get_page(page)
  # end

  private

  def init_segment_table
    @segment_table = SegmentTable.new
    $frames.set_word(0, @segment_table)
  end

end
