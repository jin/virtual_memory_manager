require_relative 'frame'
require_relative 'page'
require_relative 'segment_table'
require_relative 'page_table'

class PhysicalMemoryManager

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

  #	For a read operation to the VA:
  #	If a ST entry (PM[s]) or a PT entry (PM[PM[s] + p]) equals ‒1 then output “pf” (page fault) and continue with the next VA.
  #	If a ST entry or a PT entry equals 0, then output “error” and continue with the next VA.
  #	Otherwise output the corresponding PA = PM[PM[s] + p] + w
  def read_from(vaddr)
    st_entry = @segment_table.get_segment(vaddr.segment)
    return "pf" if st_entry == -1
    return "error" if st_entry == 0

    pt = $frames.get_word(st_entry)

    pt_entry = pt.get_page(vaddr.page)
    return "pf" if pt_entry == -1
    return "error" if pt_entry == 0

    page = $frames.get_word(pt_entry)

    page.get_word(vaddr.offset) ? pt_entry * 512 + vaddr.offset : "error"
  end


  #	For a write operation to the VA:
  #	If a ST entry or a PT entry equals ‒1 then output “pf” (page fault) and continue with the next VA.
  #	If a ST entry equals 0 then allocate a new blank PT (all zeroes), update the ST entry accordingly, and continue with the translation process; if a PT entry equals 0 then create a new blank page, and continue with the translation process.
  #	Otherwise output the corresponding PA = PM[PM[s] + p] + w
  def write_to(vaddr)
    st_entry = @segment_table.get_segment(vaddr.segment)
    return "pf" if st_entry == -1
    # create page table if st_entry == 0
    
    pt = $frames.get_word(st_entry)

    pt_entry = pt.get_page(vaddr.page)
    return "pf" if pt_entry == -1
    # create page if pt_entry == 0
    
    page = $frames.get_word(pt_entry)
    page.set_word(vaddr.offset, true)

    return pt_entry * 512 + vaddr.offset
  end

  private

  def init_segment_table
    @segment_table = SegmentTable.new
    $frames.set_word(0, @segment_table)
  end

end
