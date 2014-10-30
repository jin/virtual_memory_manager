require 'lru_redux'

class TLB

  def initialize
    @lru = LruRedux::Cache.new(4)
  end

  def add(vaddr, physical_address)
    @lru[get_identifier(vaddr)] = physical_address
  end

  def retrieve(vaddr)
    @lru[get_identifier(vaddr)]
  end

  private

  def get_identifier(vaddr)
    ((vaddr.segment << 19) + (vaddr.page << 9)).to_s.to_sym
  end

end
