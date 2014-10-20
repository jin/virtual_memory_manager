require_relative 'frame'

class PhysicalMemory

  attr_reader :frame_array

  # 1024 frames of 512 words each
  def initialize(frames)
    @frame_array = Array.new(frames)
  end

  def is_free_frame?(index)
    @frame_array[index].nil?
  end

  def create_frame_at(index)
    @frame_array[index] = Frame.new(512)
  end

  def get_frame_at(index)
    @frame_array[index]
  end

end
