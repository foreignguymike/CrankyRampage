class SpikeWheel < Entity

  attr_reader :health

  def initialize x, y
    super()
    @x = x
    @y = y
    @max_speed = 30 / 60
    @cw = @ch = 15
    @left = true
    @health = 5
  end

  def update walls, bullets
    if @wx != nil
      @left = !@left
      @right = !@right
    end
    @render_deg += @left ? 3 : -3
    check_collision walls
    @x += @dx
    @y += @dy
    
    bullets.each { |b|
      if Utils.overlaps? crect, (b.crect b.x, b.y)
        b.remove = true
        @health -= 1
        @flash = true
        @flash_time = 5
        if @health <= 0
          @remove = true
        end
      end
    }
    @flash_time -= 1
    if @flash_time <= 0
      @flash = false
    end
  end

  def render args, cam
    set_image args, "spikewheel"
    cam.render args, self


    if args.state.debug
      render_debug args, cam
    end
  end

end