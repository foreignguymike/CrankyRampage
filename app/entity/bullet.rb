class Bullet < Entity

  attr_accessor :remove

  def initialize args, x, y, dx, dy, deg
    super()
    @x = x
    @y = y
    @dx = dx
    @dy = dy
    @remove = false
    @render_deg = deg
    @time = 0
    set_image args, "machinegun"
  end

  def update walls
    @x += @dx
    @y += @dy
    @time += 1

    if @time > 15
      @remove = true
      return
    end

    walls.each { |w|
      if w.platform then next end
      if Utils.overlaps? ({ x: w.x - w.w / 2, y: w.y - w.h / 2, w: w.w, h: w.h}), (crect @x, @y)
        puts "remove"
        @remove = true
      end
    }
  end

  def render args, cam
    cam.render args, self
  end

end