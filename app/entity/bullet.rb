class Bullet < Entity

  attr_reader :damage

  def initialize args, path, x = 0, y = 0, dx = 0, dy = 0, deg = 0, physics = false
    super()
    @x = x
    @y = y
    @dx = dx
    @dy = dy
    @render_deg = deg
    set_image args, path
    @cw = @ch = [@w, @h].min
    @physics = physics

    @time = case path
    when "pistol" then 10
    when "machinegun" then 30
    when "triplet" then 40
    when "wave" then 40
    when "beam" then 10

    when "greenslime" then 100
    end

    @damage = case path
    when "pistol" then 12
    when "machinegun" then 16
    when "triplet" then 18
    when "wave" then 20
    when "beam" then 5

    when "greenslime" then 1
    end

    if path == "greenslime"
      @cw = @ch = 4
    end

    @bounce = path == "wave"
    @gravity = 0 if @bounce
  end

  def update walls
    if !@physics && !@bounce
      walls.each { |w|
        next if w.platform
        if Utils.overlaps? ({ x: w.x - w.w / 2, y: w.y - w.h / 2, w: w.w, h: w.h}), (crect @x, @y)
          @remove = true
        end
      }
    else
      apply_physics walls, false, true, @bounce, true
      @remove = true if (@wx != nil || @wy != nil) && !@bounce
      if @wx != nil
        if @render_deg > 90 || @render_deg < -90
          @render_deg += 2* (90 - @render_deg)
        elsif @render_deg >= 0
          @render_deg = 180 - @render_deg
        else
          @render_deg = -180 - @render_deg
        end
      end
      if @wy != nil
        @render_deg = -@render_deg
      end
    end

    @x += @dx
    @y += @dy
    @time -= 1

    if @time < 0
      @remove = true
      return
    end
  end

  def render args, cam
    cam.render args, self
    render_debug args, cam if args.state.debug
  end

end