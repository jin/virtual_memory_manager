require 'lrucache'

class TLB

  def initialize
    @cache = LRUCache.new(:max_size => 4, :default => nil)
  end

  def add(vaddr, physical_address)
    @cache.store(get_identifier(vaddr), physical_address)
  end

  def retrieve(vaddr)
    @cache.fetch(get_identifier(vaddr))
  end

  private

  def get_identifier(vaddr)
    (vaddr.segment << 19) + (vaddr.page << 9)
  end

end
