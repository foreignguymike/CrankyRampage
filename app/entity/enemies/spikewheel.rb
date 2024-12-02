class SpikeWheel < Enemy

  attr_reader :health, :gems

  def initialize x, y
    super x, y
    @max_speed = 60 / 60
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
    @render_deg -= @max_speed * 5
    check_collision walls, false
    @x += @dx
    @y += @dy
    
    check_bullets args, bullets
  end

  def render args, cam
    set_image args, "spikewheel"
    cam.render args, self
    render_health args, cam

    render_debug args, cam if args.state.debug
  end

end