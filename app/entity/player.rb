class Player < Entity
  ACCEL = 300 / 60 / 60
	FRICTION = 200 / 60 / 60
	MAX_SPEED = 50 / 60

  # movement
  attr_accessor :x, :y, :dx, :dy

  # input
  attr_accessor :up, :down, :left, :right

  # render
  attr_accessor :image
  attr_accessor :hide

  def initialize
    @x = @y = @dx = @dy = 0
    @cw = @ch = 15
    @mx = @my = 0
  end

  def lookat mx, my
    @mx = mx
    @my = my
  end

  def update
    # animate
    # @sprite = "sprites/witch#{1.frame_index(3, 7, true) + 1}.png"
    puts Math.atan2(@my - @y, @mx - @x)
    @image = $args.state.assets.find "headhud"
    @w = @image.tile_w
    @h = @image.tile_h

    # input
    if @left then @dx = (@dx - ACCEL).clamp(-MAX_SPEED, 0) end
    if @right then @dx = (@dx + ACCEL).clamp(0, MAX_SPEED) end
    if @up then @dy = (@dy + ACCEL).clamp(0, MAX_SPEED) end
    if @down then @dy = (@dy - ACCEL).clamp(-MAX_SPEED, 0) end
    
    # friction
    if !@left && @dx < 0 then @dx = (@dx + FRICTION).clamp(@dx, 0) end
    if !@right && @dx > 0 then @dx = (@dx - FRICTION).clamp(0, @dx) end
    if !@up && @dy > 0 then @dy = (@dy - FRICTION).clamp(0, @dy) end
    if !@down && @dy < 0 then @dy = (@dy + FRICTION).clamp(@dy, 0) end

    # move
    @x += @dx
    @y += @dy

  end

end