#!/usr/bin/env ruby
require 'PP'

require_relative 'virtual_address'
require_relative 'physical_memory'
require_relative 'physical_address'

class App

  attr_accessor :physical_memory

  def start 
    initialization_file = ARGV[0]
    input_file = ARGV[1]

    @physical_memory = PhysicalMemory.new

    initialize_with IO.readlines(initialization_file)
    process_virtual_addresses_from IO.readlines(input_file).first
  end

  def initialize_with(instructions)
    puts "Applying configuration.."

    apply_segment_table_config(instructions.first) # first line of initialization.txt
    apply_page_table_config(instructions.last)     # second line of initialization.txt
  end

  def apply_segment_table_config(config)
    config.split.map(&:to_i).each_slice(2) do |slice|
      segment, paddr = slice.first, PhysicalAddress.new(slice.last)
      puts "====="
      puts "Creating page table for segment #{segment} starting at frame #{paddr.inspect}"
      @physical_memory.create_page_table(segment, paddr)
      pp $frames
    end
  end

  def apply_page_table_config(config)
    config.split.map(&:to_i).each_slice(3) do |slice|
      page, segment, paddr = slice[0], slice[1], PhysicalAddress.new(slice[2])
      puts "====="
      puts "Creating page #{page} for segment #{segment} starting at frame #{paddr.inspect} "
      @physical_memory.create_page(page, segment, paddr)
      pp $frames
    end
  end

  def process_virtual_addresses_from(lines)
    lines.split.map(&:to_i).each_slice(2) do |slice|
      rw_bit, vaddr = slice.first, VirtualAddress.new(slice.last)
      operation = rw_bit > 0 ? :write : :read
      evaluate_physical_address(operation, vaddr)
      pp $frames
    end
  end

  def evaluate_physical_address(operation, vaddr)
    case operation
    when :read then puts read(vaddr)
    when :write then puts write(vaddr)
    end
  end

  def read(vaddr)
    puts "====="
    puts "Reading #{vaddr.inspect}"

    page_table = @physical_memory.get_page_table(vaddr.segment)
    return "error" if page_table.nil?

    page = @physical_memory.get_page(page_table, vaddr.page)
    return "error" if page.nil?

    512 * page + vaddr.offset
  end

  def write(vaddr)
    puts "====="
    puts "Writing to #{vaddr.inspect}"

    page_table = @physical_memory.get_page_table(vaddr.segment)
    # create page table if page_table.nil?
  end

end

app = App.new
app.start
