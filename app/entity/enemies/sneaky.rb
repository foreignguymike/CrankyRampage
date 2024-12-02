class Sneaky < Enemy
  def initialize x, y
    super x, y
    @max_speed = 60 / 60
    @cw = @ch = 15
    @left = true
    @max_health = @health = 80
    @gems = [ { type:"sapphire"}, { type:"sapphire"}, { type:"emerald"}, { type:"emerald"}, { type:"amber"}, { type:"amber"}, { type:"amber"}, { type:"amber"} ]

    @attacking = false
    @original_y = y
    @interval = 0
  end

  def update args, player, walls, bullets, enemy_bullets
    @hflip = player.x < @x
    @interval -= 1

    if !@attacking && @interval < 0 && (player.x - @x).abs < 160 && (player.y - @y).abs < 30
      @dy = 200 / 60
      @attacking = true
      @interval = 60 * 2
    end

    old_dy = @dy
    apply_physics walls, false, false
    new_dy = @dy
    @y += @dy

    if old_dy >= 0 && new_dy < 0
      dx = (player.x + player.dx * 10) - @x
      dy = (player.y + player.dy * 10) - @y
      len = Math.sqrt dx**2 + dy**2
      dx /= len
      dy /= len
      enemy_bullets << (Bullet.new args, "greenslime", @x, @y, dx * 300 / 60, dy * 300 / 60, 0)
    end

    if @y < @original_y
      @attacking = false
      @y = @original_y
    end

    check_bullets args, bullets
    if @flash_time == 4 && !@attacking && @interval < 0
      @attacking = true
    end
  end

  def render args, cam
    @attacking ? (set_image args, "sneakyattack") : (set_image args, "sneakyidle")
    cam.render args, self
    render_health args, cam

    render_debug args, cam if args.state.debug
  end
end