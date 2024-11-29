class Player < Entity
  ACCEL = 500 / 60 / 60
	FRICTION = 500 / 60 / 60
	MAX_SPEED = 50 / 60
  PI = Math::PI

  # movement
  attr_accessor :x, :y, :dx, :dy

  # input
  attr_accessor :up, :down, :left, :right

  # render
  attr_accessor :image
  attr_accessor :hide
  attr_accessor :hflip

  def initialize
    @x = @y = @dx = @dy = 0
    @cw = @ch = 15
    @mx = @my = 0
    set_image "playerright"
  end

  def look_at mx, my
    @rad = Math.atan2(my - @y, mx - x)
  end

  private def set_image region
    puts "setting image: #{region}"
    @image = $args.state.assets.find region
    @w = @image.tile_w
    @h = @image.tile_h
  end

  def update
    # animate
    # @sprite = "sprites/witch#{1.frame_index(3, 7, true) + 1}.png"

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

  def render cam
    @hflip = @rad < -PI / 2 || @rad > PI / 2

    # check rad
    $args.outputs.labels << { text:"nrad: #{@rad}", x: 20, y: 20 }
    if @rad > 3 * PI / 8 && @rad < 5 * PI / 8
      set_image "playerup"
    elsif @rad < -3 * PI / 8 && @rad > -5 * PI / 8
      set_image "playerdown"
    elsif (@rad > 1 * PI / 8 && @rad < 3 * PI / 8) || (@rad > 5 * PI / 8 && @rad < 7 * PI / 8)
      set_image "playerupright"
    elsif (@rad < -1 * PI / 8 && @rad > -3 * PI / 8) || (@rad < -5 * PI / 8 && @rad > -7 * PI / 8)
      set_image "playerdownright"
    else
      set_image "playerright"
    end
    cam.render self
    index = 1.frame_index(8, 4, true) + 1
    if @left || @right || @up || @down
      if (@right && @hflip) || (@left && !@hflip)
        set_image "playerwalk#{9 - index}"
      else
        set_image "playerwalk#{index}"
      end
    else
      set_image "playeridle"
    end
    cam.render self
  end

end