class Screen

  attr_accessor :cam

  def initialize
    @cam = Camera.new
  end
  
  def update args
    raise NotImplementedError
  end

  def render args
    raise NotImplementedError
  end

end