#!/usr/bin/env ruby
require 'PP'
require 'optparse'

require_relative 'virtual_address'
require_relative 'physical_address'
require_relative 'physical_memory_manager'

class App

  attr_accessor :physical_memory

  def initialize(options)
    @options = options
  end

  def start
    initialization_file = @options[:config]
    input_file = @options[:input]

    # puts "-----------------------------------------------"
    # puts "initializing.."
    # puts "-----------------------------------------------"

    @physical_memory_manager = PhysicalMemoryManager.new

    initialize_with IO.readlines(initialization_file)
    process_virtual_addresses_from IO.readlines(input_file).first
    puts
  end

  def initialize_with(instructions)
    # puts "Applying configuration.."
    apply_segment_table_config(instructions.first) # first line of initialization.txt
    apply_page_table_config(instructions.last)     # second line of initialization.txt
  end

  def apply_segment_table_config(config)
    config.split.map(&:to_i).each_slice(2) do |slice|
      segment, paddr = slice.first, PhysicalAddress.new(slice.last)
      # puts "====="
      # puts "Creating page table for segment #{segment} at #{paddr.inspect}"
      @physical_memory_manager.init_page_table(segment, paddr)
    end
  end

  def apply_page_table_config(config)
    config.split.map(&:to_i).each_slice(3) do |slice|
      page, segment, paddr = slice[0], slice[1], PhysicalAddress.new(slice[2])
      # puts "====="
      # puts "Creating page #{page} for segment #{segment} at #{paddr.inspect} "
      @physical_memory_manager.init_page(segment, page, paddr)
    end
  end

  def process_virtual_addresses_from(lines)
    lines.split.map(&:to_i).each_slice(2) do |slice|
      rw_bit, vaddr = slice.first, VirtualAddress.new(slice.last)
      operation = rw_bit > 0 ? :write : :read
      evaluate_physical_address(operation, vaddr)
    end
  end

  def evaluate_physical_address(operation, vaddr)
    case operation
    when :read then print read(vaddr)
    when :write then print write(vaddr)
    end
    print " "
  end

  def read(vaddr)
    # puts "====="
    # puts "Reading #{vaddr.inspect}"
    @physical_memory_manager.read_from(vaddr)
  end

  def write(vaddr)
    # puts "====="
    # puts "Writing to #{vaddr.inspect}"
    @physical_memory_manager.write_to(vaddr)
  end

end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby app.rb [options]"

  opts.on("-c", "--config filename", "Configuration/Initialization file") do |c|
    options[:config] = c
  end

  opts.on("-i", "--input filename", "Input file of virtual addresses") do |i|
    options[:input] = i
  end
end.parse!

app = App.new(options)
app.start
