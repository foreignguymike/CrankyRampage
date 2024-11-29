require 'app/util/utils'

class Player < Entity
  ACCEL = 300 / 60 / 60
	FRICTION = 300 / 60 / 60
  GRAVITY = 300 / 60 / 60
	MAX_SPEED = 70 / 60
  MAX_FALL_SPEED = 200 / 60
  JUMP = 150 / 60

  # input
  attr_accessor :left, :right

  def initialize
    super
    @left = @right = false
    @cw = 10
    @ch = 32
    @mx = @my = 0
    @on_ground = false
    @fire_time = 10
  end

  def look_at mx, my
    @rad = Math.atan2(my - @y, mx - x)
  end

  def jump
    if @on_ground
      @dy = JUMP
    end
  end

  def fire
    if @fire_time > 10
      @fire_time = 0
      return true
    else
      return false
    end
  end

  def update walls
    # input
    if @left then @dx = (@dx - ACCEL).clamp(-MAX_SPEED, 0) end
    if @right then @dx = (@dx + ACCEL).clamp(0, MAX_SPEED) end
    
    # gravity
    @dy = (@dy - GRAVITY).clamp(-MAX_FALL_SPEED, 1000)
    
    # friction
    if !@left && @dx < 0 then @dx = (@dx + FRICTION).clamp(@dx, 0) end
    if !@right && @dx > 0 then @dx = (@dx - FRICTION).clamp(0, @dx) end

    # check collision x
    @wc = walls.find { |w|
      if w.platform then next end
      Utils.overlaps? ({ x: w.x - w.w / 2, y: w.y - w.h / 2, w: w.w, h: w.h}), (crect @x + @dx, @y)
    }
    if @wc
      if @dx >  0
        @x = @wc.x - @wc.w / 2 - @cw / 2
      else
        @x = @wc.x + @wc.w / 2 + @cw / 2
      end
      @dx = 0
    end

    # check collision y
    @wc = walls.find { |w|
      # check platform, should only collide if we are above the platform and dy < 0
      if w.platform && (@dy >= 0 || @y + @dy - @ch / 2 < w.y - w.h / 2) then next end
      Utils.overlaps? ({ x: w.x - w.w / 2, y: w.y - w.h / 2, w: w.w, h: w.h}), (crect @x, @y + @dy)
    }
    @on_ground = false
    if @wc
      if @dy > 0
        @y = @wc.y - @wc.h / 2 - @ch / 2
      else
        @y = @wc.y + @wc.h / 2 + @ch / 2
        @on_ground = true
      end
      @dy = 0
    end

    # move
    @x += dx
    @y += dy

    # shooting
    @fire_time += 1

  end

  def render args, cam
    @hflip = @rad < -PI / 2 || @rad > PI / 2

    # render legs
    if !@on_ground
      set_image args, "playerjump"
    elsif @left || @right || @up || @down
      index = 1.frame_index(8, 4, true) + 1
      if (@right && @hflip) || (@left && !@hflip)
        set_image args, "playerwalk#{9 - index}"
      else
        set_image args, "playerwalk#{index}"
      end
    else
      set_image args, "playeridle"
    end
    cam.render args, self

    # render direction
    if @rad > 3 * PI / 8 && @rad < 5 * PI / 8
      set_image args, "playerup"
    elsif @rad < -3 * PI / 8 && @rad > -5 * PI / 8
      set_image args, "playerdown"
    elsif (@rad > 1 * PI / 8 && @rad < 3 * PI / 8) || (@rad > 5 * PI / 8 && @rad < 7 * PI / 8)
      set_image args, "playerupright"
    elsif (@rad < -1 * PI / 8 && @rad > -3 * PI / 8) || (@rad < -5 * PI / 8 && @rad > -7 * PI / 8)
      set_image args, "playerdownright"
    else
      set_image args, "playerright"
    end
    cam.render args, self

    # render collision box
    if args.state.debug
      render_debug args, cam
    end
  end

end