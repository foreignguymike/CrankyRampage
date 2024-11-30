class Particle < Entity

  def initialize path, x, y, w, h, dx, dy, count = -1, interval = -1, once = false
    super()
    @path = path
    @x = x
    @y = y
    @w = w
    @h = h
    @dx = dx
    @dy = dy
    @count = count
    @interval = interval
    @once = once

    @animation = Animation.new @count, @interval
  end

  def update
    @animation.tick
    if @once
      @remove = @animation.play_count > 0
    end
  end

  def render args, cam
    if @count > 0
      set_image_index args, @path, @animation.index, @w
    else
      set_image args, @path
    end
    cam.render args, self
  end

end