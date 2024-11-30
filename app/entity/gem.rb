class Gem < Entity

  def initialize path, x, y, w, h, dx, dy, count = -1, interval = -1
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
    @friction = 0
    @cw = @ch = 12

    @max_speed = dx
    @jump_vel = dy

    @animation = Animation.new @count, @interval
  end

  def update walls
    if @wy == nil
      @jump_vel = @dy.abs
    end
    if @wx != nil
      @max_speed = -@max_speed
      @dx = @max_speed
    end
    if @wy != nil && @wy.y < @y
      @max_speed *= 0.6
      @jump_vel *= 0.6
      @dx = @max_speed
      @dy = @jump_vel
    end

    check_collision walls, false
    @x += @dx
    @y += @dy

    @animation.tick
  end

  def render args, cam
    if @count > 0
      set_image_index args, @path, @animation.index, @w
    else
      set_image args, @path
    end
    cam.render args, self
    render_debug args, cam if args.state.debug
  end

end