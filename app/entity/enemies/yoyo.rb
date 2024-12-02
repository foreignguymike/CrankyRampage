class Yoyo < Enemy

  attr_reader :health, :gems

  def initialize x, y
    super x, y
    @max_speed = 60 / 60
    @cw = @ch = 15
    @dx = -@max_speed
    @left = true
    @max_health = @health = 70
    @gems = [ { type:"sapphire"}, { type:"amber"}, { type:"amber"} ]

    @attacking = false
    @retreating = false
    @original_y = y
  end

  def update args, player, walls, bullets
    wall = walls.find { |w|
      if w.platform then next end
      Utils.overlaps? ({ x: w.x - w.w / 2, y: w.y - w.h / 2, w: w.w, h: w.h}), (crect @x, @y)
    }

    if !@attacking && !@retreating && (player.x - @x).abs < 30 && @original_y - player.y < 150
      @attacking = true
    end
    if @attacking
      @dy = -200 / 50
      @render_deg -= 30
      if wall != nil && wall.y < @y
        @attacking = false
        @retreating = true
      end
    end
    if @retreating
      @dy = 30 / 50
      @render_deg -= 5
    end

    @y += @dy
    if @y > @original_y
      @retreating = false
      @y = @original_y
    end

    check_bullets args, bullets
    if @flash_time == 4 && !@attacking && !@retreating # just got hit
      @attacking = true
    end

    if @health <= 0
      y = (wall == nil || wall.platform ? @y : (wall.y > @y ? wall.y - wall.h / 2 - 12 : wall.y + wall.h / 2 + 12))
      @gems.each { |g| g[:y] = y }
    end
  end

  def render args, cam
    # string 250, 255, 255
    length = @original_y - @y
    cam.render_box args, @x, @original_y - length / 2, 1, length, 250, 255, 255
    set_image args, "yoyo"
    cam.render args, self
    cam.render_image args, (args.state.assets.find "yoyoeye"), @x, @y, 11, 7 if @attacking || @retreating
    render_health args, cam

    render_debug args, cam if args.state.debug
  end

end