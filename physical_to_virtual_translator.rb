#!/usr/bin/env ruby

segment = ARGV[0].to_i
page = ARGV[1].to_i
offset = ARGV[2].to_i

puts (segment << 19) + (page << 9) + (offset)
