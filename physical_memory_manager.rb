require_relative 'frame'
require_relative 'page'
require_relative 'segment_table'
require_relative 'page_table'

class PhysicalMemoryManager

  attr_accessor :frames, :segment_table

  SEGMENT_TABLE_FRAME_INDEX = 0

  # ======================================================================
  # INITIALIZATION BEGIN

  # 1024 frames of 512 words each
  def initialize(frames = 1024)
    $frames = Frame.new(1024)
    $bm = Bitmap.new(1024)

    init_segment_table
  end

  def init_page_table(segment, paddr)
    @segment_table.set_segment(segment, paddr.address)
    # Since paddr.address is not resident (-1), don't create a page table.
    return if paddr.address < 0
    create_page_table(paddr.frame)
  end

  def init_page(segment, page, paddr)
    # Initialization will not raise errors -> Page table is always valid and created
    page_table = $frames.get_word(@segment_table.get_segment(segment) / 512)
    page_table.set_page(page, paddr.address)

    # Since paddr.address is not resident (-1), don't create a page
    return if paddr.address < 0
    create_page(paddr.frame)
  end

  # INITIALIZATION END
  # ======================================================================

  # ======================================================================
  # NORMAL R/W OPERATIONS

  #	For a read operation to the VA:
  #	If a ST entry (PM[s]) or a PT entry (PM[PM[s] + p]) equals -1 then output "pf" (page fault) and continue with the next VA.
  #	If a ST entry or a PT entry equals 0, then output "error" and continue with the next VA.
  #	Otherwise output the corresponding PA = PM[PM[s] + p] + w
  def read_from(vaddr)
    st_entry = @segment_table.get_segment(vaddr.segment)
    return "pf" if st_entry == -1
    return "error" if st_entry == 0

    pt = $frames.get_word(st_entry / 512)

    pt_entry = pt.get_page(vaddr.page)
    return "pf" if pt_entry == -1
    return "error" if pt_entry == 0

    page = $frames.get_word(pt_entry / 512)

    page.get_word(vaddr.offset) ? pt_entry + vaddr.offset : "error"
  end


  #	For a write operation to the VA:
  #	If a ST entry or a PT entry equals ‒1 then output “pf” (page fault) and continue with the next VA.
  #	If a ST entry equals 0 then allocate a new blank PT (all zeroes), update the ST entry accordingly, and continue with the translation process; if a PT entry equals 0 then create a new blank page, and continue with the translation process.
  #	Otherwise output the corresponding PA = PM[PM[s] + p] + w
  def write_to(vaddr)
    st_entry = @segment_table.get_segment(vaddr.segment)
    return "pf" if st_entry == -1

    if st_entry == 0
      idx = $bm.find_free_slot(2)
      create_page_table(idx)
      st_entry = idx * 512
      segment_table.set_segment(vaddr.segment, st_entry)
    end

    page_table = $frames.get_word(st_entry / 512)

    pt_entry = page_table.get_page(vaddr.page)
    return "pf" if pt_entry == -1
    if pt_entry == 0
      idx = $bm.find_free_slot(1)
      create_page(idx)
      pt_entry = idx * 512
      page_table.set_page(vaddr.page, pt_entry)
    end

    return pt_entry + vaddr.offset
  end

  def create_page_table(idx)
    pt = PageTable.new(1024)
    $frames.set_word(idx, pt)
    $frames.set_word(idx + 1, pt)
    $bm.set(idx)
    $bm.set(idx + 1)
  end

  def create_page(idx)
    page = Page.new(512)
    $frames.set_word(idx, page)
    $bm.set(idx)
  end

  private

  def init_segment_table
    @segment_table = SegmentTable.new
    $frames.set_word(SEGMENT_TABLE_FRAME_INDEX, @segment_table)
    $bm.set(SEGMENT_TABLE_FRAME_INDEX)
  end

end
