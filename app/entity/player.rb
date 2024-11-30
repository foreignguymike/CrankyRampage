require 'app/util/utils'

class Player < Entity

  INVULNERABILITY_TIME = 2 * 60

  def initialize
    super
    @cw = 10
    @ch = 24
    @cyo = -4
    @mx = @my = 0
    @on_ground = false
    @fire_time = 0
    @max_speed = 90 / 60
    @hit_time = 0
    @stagger = false
  end

  def look_at mx, my
    @rad = Math.atan2(my - @y, mx - x)
  end

  def fire
    if @fire_time < 0
      @fire_time = 10
      return true
    else
      return false
    end
  end

  private def check_input
    # input
    if @left then @dx = (@dx - ACCEL).clamp(-@max_speed, 0) end
    if @right then @dx = (@dx + ACCEL).clamp(0, @max_speed) end
  end

  def update args, walls, enemies, collectables
    # check input
    check_input if !@stagger

    # check collision
    check_collision walls, !@stagger

    # move
    @x += @dx
    @y += @dy

    # check enemies
    if @stagger && @wy != nil
      @stagger = false
    end
    if @hit_time < 0
      enemies.each { |e|
        if Utils.overlaps? e.crect, crect
          @hit_time = INVULNERABILITY_TIME
          @dx = @hflip ? 60 / 60 : -60 / 60
          @dy = 80 / 60
          @stagger = true
          args.audio[:sfx] = { input: "sounds/hit.wav", gain: 0.7, looping: false }
        end
      }
    end

    # check collectables
    collectables.each { |c|
      if Utils.overlaps? c.crect, crect
        args.audio[:csfx] = { input: "sounds/gem.wav", gain: 0.7, looping: false }
        c.remove = true
      end
    }

    # hit
    @hit_time -= 1

    # shooting
    @fire_time -= 1

  end

  def render args, cam

    # direction
    @hflip = @rad < -PI / 2 || @rad > PI / 2

    # hit
    @hide = @hit_time > 0 && @hit_time % 10 < 5

    # render legs
    if !@on_ground
      set_image args, "playerjump"
    elsif @left || @right
      index = 1.frame_index(8, 4, true)
      if (@right && @hflip) || (@left && !@hflip)
        set_image_index args, "playerwalk", 7 - index, @w
      else
        set_image_index args, "playerwalk", index, @w
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
    render_debug args, cam if args.state.debug
  end

end