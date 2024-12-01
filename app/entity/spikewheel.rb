class SpikeWheel < Entity

  attr_reader :health, :gems

  def initialize x, y
    super()
    @x = x
    @y = y
    @max_speed = 30 / 60
    @cw = @ch = 15
    @dx = -@max_speed
    @left = true
    @max_health = @health = 5
    @gems = ["amber", "amber", "emerald"]
  end

  def update args, walls, bullets
    if @wx != nil
      @max_speed = -@max_speed
      @dx = @max_speed
    end
    @render_deg += @dx < 0 ? 3 : -3
    check_collision walls, false
    @x += @dx
    @y += @dy
    
    bullets.each { |b|
      next if b.remove
      if Utils.overlaps? b.crect, crect
        b.remove = true
        @health -= 1
        @flash = true
        @flash_time = 5
        if @health <= 0
          @remove = true
        end
        args.audio[:esfx] = { input: "sounds/enemyhit.wav", gain: 1, looping: false }
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

    render_debug args, cam if args.state.debug
  end

end