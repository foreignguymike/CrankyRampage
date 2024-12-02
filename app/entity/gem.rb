class Gem < Entity

  attr_reader :value

  def initialize path, x, y, dx, dy
    super()
    @path = path
    @x = x
    @y = y
    @w = w
    @h = h
    @dx = dx
    @dy = dy
    @gravity = 0 if dy == 0
    @friction = 0
    @cw = @ch = 12

    @max_speed = dx
    @jump_vel = dy

    @w = @h = case path
    when "amber", "emerald", "sapphire" then 12
    end

    @count = case path
    when "amber", "emerald", "sapphire" then 24
    end

    @interval = case path
    when "amber", "emerald", "sapphire" then 3
    end

    @value = case path
    when "amber" then 1
    when "emerald" then 3
    when "sapphire" then 5
    else 0
    end

    @animation = Animation.new @count, @interval
  end

  def follow player
    @player = player
  end

  def update walls
    if @player == nil
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
    else
      dx = @player.x - @x
      dy = @player.y - @y
      len = Math.sqrt dx**2 + dy**2
      nx = dx / len
      ny = dy / len
      @dx = nx * 200 / 60
      @dy = ny * 200 / 60
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