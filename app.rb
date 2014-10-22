#!/usr/bin/env ruby
#
require_relative 'virtual_address'
require_relative 'physical_memory'

class App

  attr_accessor :physical_memory

  def start 
    initialization_file = ARGV[0]
    input_file = ARGV[1]

    @physical_memory = PhysicalMemory.new

    initialize_with File.read(initialization_file)
    process_virtual_addresses_from File.read(input_file)
  end

  def initialize_with(lines)
    instructions = lines.split("\n")
    apply_segment_table_config(instructions.first) # first line of initialization.txt
    apply_page_table_config(instructions.last)     # second line of initialization.txt
  end

  def apply_segment_table_config(config)
    config.split.each_slice(2) do |slice|
      segment, frame = slice
      @physical_memory.create_page_table(:segment => segment, :frame => frame)
    end
  end

  def apply_page_table_config(config)
    config.split.each_slice(3) do |slice|
      page, segment, frame = slice
      @physical_memory.create_page(:segment => segment, :page => page, :frame => frame)
    end
  end

  def process_virtual_addresses_from(lines)
    lines.split.map { |token| token.to_i }.each_slice(2) do |slice|
      rw_bit, vaddr = slice.first, VirtualAddress.new(slice.last)
      operation = rw_bit > 0 ? :write : :read
      paddr = evaluate_physical_address(operation, vaddr)
      paddr
    end
  end

  def evaluate_physical_address(operation, vaddr)
    p operation, vaddr
  end

end

app = App.new
app.start
