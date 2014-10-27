#!/usr/bin/env ruby
require 'PP'
require 'optparse'
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

    $tlb = TLB.new # Create a TLB regardless of whether TLB is enabled or not.
    @physical_memory_manager = PhysicalMemoryManager.new

    configure(IO.readlines(initialization_file))
    translate_virtual_addresses(IO.readlines(input_file).first, enable_tlb)
    puts
  end

  def configure(instructions)
    configure_page_tables(instructions.first) # first line 
    configure_pages(instructions.last)     # second line
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
      operation = rw_bit > 0 ? :write : :read

      if enable_tlb
        entry = $tlb.retrieve(vaddr)
        if entry.nil? # TLB miss
          result = evaluate_physical_address(operation, vaddr)
          (result.to_i == 0) ? print(result) : print("m #{result}")
        else # TLB hit
          print "h #{entry + vaddr.offset}"
        end
      else
        print evaluate_physical_address(operation, vaddr)
      end
      print " "
    end
  end

  def evaluate_physical_address(operation, vaddr)
    case operation
    when :read then return @physical_memory_manager.read_from(vaddr) 
    when :write then return @physical_memory_manager.write_to(vaddr)
    end
  end

  def split_input_string(str, length)
    str.split.map(&:to_i).each_slice(length)
  end

end

app = App.new(options)
app.start
