class Slimer < Enemy
  attr_reader :health, :gems

  def initialize x, y
    super x, y
    @max_speed = 40 / 60
    @cw = @ch = 15
    @dx = -@max_speed
    @left = true
    @max_health = @health = 5
    @gems = [ { type:"amber"}, { type:"amber"}, { type:"emerald"} ]
    @cw = 32
    @ch = 10
    @cyo = -11
    @animation = Animation.new 4, 5
  end

  def update args, player, walls, bullets
    if @wx != nil
      @max_speed = -@max_speed
      @dx = @max_speed
    end
    check_collision walls, false
    @x += @dx
    @y += @dy
    
    check_bullets args, bullets

    @animation.tick
  end

  def render args, cam
    @hflip = @dx < 0
    set_image_index args, "slimer", @animation.index, 32
    cam.render args, self
    render_health args, cam

    render_debug args, cam if args.state.debug
  end

end