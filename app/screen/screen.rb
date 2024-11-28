class Screen

  attr_accessor :cam

  def initialize
    @cam = Camera.new
  end
  
  def update
    raise NotImplementedError
  end

  def render
    raise NotImplementedError
  end

end