require 'app/util/utils'

class Player < Entity

  def initialize
    super
    @cw = 10
    @ch = 24
    @cyo = -4
    @mx = @my = 0
    @on_ground = false
    @fire_time = 10
    @max_speed = 90 / 60
  end

  def look_at mx, my
    @rad = Math.atan2(my - @y, mx - x)
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
    # check collision
    check_collision walls

    # move
    @x += @dx
    @y += @dy

    # shooting
    @fire_time += 1

  end

  def render args, cam
    @hflip = @rad < -PI / 2 || @rad > PI / 2

    # render legs
    if !@on_ground
      set_image args, "playerjump"
    elsif @left || @right
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