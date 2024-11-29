class Particle < Entity

  def initialize path, x, y, dx, dy, count = -1, interval = -1, once = false
    super()
    @path = path
    @x = x
    @y = y
    @dx = dx
    @dy = dy
    @count = count
    @interval = interval
    @once = once

    @total = @count * @interval
    @time = 0

    @animation = Animation.new @count, @interval
  end

  def update
    @animation.tick
    if @animation.play_count > 0 && @once
      @remove = true
    end
  end

  def render args, cam
    if @count > 0
      set_image args, "#{@path}#{@animation.index + 1}"
    else
      set_image args, @path
    end
    cam.render_image args, @image, @x, @y, @w, @h
  end

end