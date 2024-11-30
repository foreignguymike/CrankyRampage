class Bullet < Entity

  def initialize args, x = 0, y = 0, dx = 0, dy = 0, deg = 0
    super()
    @x = x
    @y = y
    @dx = dx
    @dy = dy
    @render_deg = deg
    @time = 0
    @cw = @ch = 10
    set_image args, "machinegun"
  end

  def update walls
    walls.each { |w|
      if w.platform then next end
      if Utils.overlaps? ({ x: w.x - w.w / 2, y: w.y - w.h / 2, w: w.w, h: w.h}), (crect @x, @y)
        @remove = true
      end
    }

    @x += @dx
    @y += @dy
    @time += 1

    if @time > 10
      @remove = true
      return
    end
  end

  def render args, cam
    cam.render args, self
    render_debug args, cam if args.state.debug
  end

end