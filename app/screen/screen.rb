class Screen

  def initialize
    @cam = Camera.new
    @cam.set_size WIDTH, HEIGHT
    @ui_cam = Camera.new
    @ui_cam.set_size WIDTH, HEIGHT
  end
  
  def update args
    raise NotImplementedError
  end

  def render args
    raise NotImplementedError
  end

end