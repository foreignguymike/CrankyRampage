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

  def replace s
    pop
    push s
  end

  def peek
    @screens.last
  end

  def tick args
    if peek != nil
      peek.update args
      peek.render args
    end
  end

end