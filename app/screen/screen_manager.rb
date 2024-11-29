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

  def tick args
    if peek
      peek.update args
      peek.render args
    end
  end

end