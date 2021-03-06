#!/usr/bin/env ruby
require 'optparse'
require 'PP'
require_relative 'virtual_address'
require_relative 'physical_address'
require_relative 'physical_memory_manager'
require_relative 'tlb'

#=========================================
# Option parsing from command line
#=========================================

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby app.rb [options]"

  opts.on("-c", "--config filename", "Configuration/Initialization file") do |c|
    options[:config] = c
  end

  opts.on("-i", "--input filename", "Input file of virtual addresses") do |i|
    options[:input] = i
  end

  opts.on("-t", "--enable-tlb", "Enable the translation look-aside buffer") do |t|
    options[:tlb] = t
  end

  opts.on("-v", "--verbose", "Verbose mode") do |v|
    options[:verbose] = v
  end
end.parse!

#=========================================
# IO driver
#=========================================

class App

  def initialize(options)
    @options = options
  end

  def start
    initialization_file = @options.fetch(:config)
    input_file = @options.fetch(:input)
    enable_tlb = @options.fetch(:tlb, false)
    @verbose = @options.fetch(:verbose, false)

    $tlb = TLB.new # Create a TLB regardless of whether TLB is enabled or not.
    @physical_memory_manager = PhysicalMemoryManager.new

    configure(IO.readlines(initialization_file))
    translate_virtual_addresses(IO.readlines(input_file).first, enable_tlb)
    puts
  end

  def configure(config)
    configure_page_tables(config.first)
    configure_pages(config.last)
  end

  def configure_page_tables(config)
    split_input_string(config, 2).each do |tokens|
      segment, paddr = tokens.first, PhysicalAddress.new(tokens.last)
      @physical_memory_manager.init_page_table(segment, paddr)
    end
  end

  def configure_pages(config)
    split_input_string(config, 3).each do |tokens|
      page, segment, paddr = tokens[0], tokens[1], PhysicalAddress.new(tokens[2])
      @physical_memory_manager.init_page(segment, page, paddr)
    end
  end

  def translate_virtual_addresses(input, enable_tlb)
    split_input_string(input, 2).each do |tokens|
      rw_bit, vaddr = tokens.first, VirtualAddress.new(tokens.last)
      print "\n#{rw_bit == 0 ? "read" : "write"} Address #{tokens.last} Segment #{vaddr.segment}, Page #{vaddr.page}, Offset #{vaddr.offset}. Result: " if @verbose
      output = if enable_tlb
                 entry = $tlb.retrieve(vaddr)
                 if entry.nil? # TLB miss
                   result = evaluate_virtual_address(rw_bit, vaddr)

                   # Check if result is err/pf or physical address
                   (result.to_i == 0) ? result : "m #{result}"
                 else # TLB hit
                   "h #{entry + vaddr.offset}"
                 end
               else
                 evaluate_virtual_address(rw_bit, vaddr)
               end

      print "#{output} "
      # pp $frames
    end
  end

  def evaluate_virtual_address(rw_bit, vaddr)
    case rw_bit
    when 0 then @physical_memory_manager.read(vaddr)
    when 1 then @physical_memory_manager.write(vaddr)
    end
  end

  def split_input_string(str, length)
    str.split.map(&:to_i).each_slice(length)
  end

end

app = App.new(options)
app.start
