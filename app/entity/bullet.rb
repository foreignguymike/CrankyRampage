class Bullet < Entity

  attr_reader :damage

  def initialize args, path, x = 0, y = 0, dx = 0, dy = 0, deg = 0
    super()
    @x = x
    @y = y
    @dx = dx
    @dy = dy
    @render_deg = deg
    set_image args, path
    @cw = @ch = [@w, @h].min

    @time = case path
    when "pistol" then 10
    when "machinegun" then 25
    when "triplet" then 40
    when "wave" then 25
    when "beam" then 10

    when "greenslime" then 100
    end

    @damage = case path
    when "pistol" then 12
    when "machinegun" then 16
    when "triplet" then 18
    when "wave" then 20
    when "beam" then 2

    when "greenslime" then 1
    end

    if path == "greenslime"
      @cw = @ch = 1
    end
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