#!/usr/bin/env ruby

class App

  def initialize
    super
  end

  def loop
    ARGF.each do |line|
      line == "\n" ? print("\n\n") : display(process_input(line))
    end

    print "\n"

  end

  def process_input(line)
  end

  def display(response)
  end

  def show_debug_info
  end
end

app = App.new
app.loop
