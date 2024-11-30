class Screen

  attr_accessor :cam, :ui_cam

  def initialize
    @cam = Camera.new
    @ui_cam = Camera.new
  end
  
  def update args
    raise NotImplementedError
  end

  def render args
    raise NotImplementedError
  end

end