class ScreenManager

  attr_accessor :depth

  def initialize
    @screens = []
    @depth = 1
  end

  def push s
    @screens.push s
  end

  def pop
    return nil if @screens.empty?
    @screens.pop
  end

  def peek
    return nil if @screens.empty?
    @screens.last
  end

  def tick
    if peek
      peek.update
      peek.render
    end
  end

end