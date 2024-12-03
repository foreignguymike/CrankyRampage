class Boss < Enemy
  DROP = -2
  PRE_IDLE = -1
  IDLE = 0
  ARC_ATTACK = 1
  JUMP = 2
  HOP = 3

  attr_reader :state

  def initialize x, y, player, walls
    super x, y
    @max_speed = 40 / 60
    @cw = @ch = 15
    @max_health = @health = 3000
    @cw = @ch = 50
    @player = player
    @walls = walls
    @actual_hit_box = { x: @x - 10, y: @y + 5, w: 20, h: 20 }
    @guard_hit_box = { x: @x - 25, y: @y - 25, w: 50, h: 30 }

    @state = DROP
    @state_time = 0
    @last_attack = nil
  end

  private def set_new_state state
    @state_time = 0
    @state = state
    case @state
    when JUMP
      # @on_ground = false
      @dy = 400 / 60
      @dx = @x < @player.x ? 144 / 60 : -144 / 60
    end
  end

  private def update_state args, enemy_bullets
    @state_time += 1
    case @state
    when DROP
      set_new_state PRE_IDLE if @on_ground
    when PRE_IDLE
      set_new_state IDLE if @state_time >= 120
    when IDLE
      set_new_state next_state if @state_time >= 60
    when ARC_ATTACK
      if @state_time % 10 == 0
        dx = @x < @player.x ? rand(100) + 30 : -rand(190) - 30
        dy = rand(100) + 250
        enemy_bullets << (Bullet.new args, "greenslime", @x, @y + @ch / 2, dx / 60, dy / 60, 0, true)
      end
      set_new_state next_state if @state_time >= 120
    when JUMP
      enemy_bullets << (Bullet.new args, "greenslime", @x, @y - @ch / 2, 0, -300 / 60, 0) if @state_time == 30
      enemy_bullets << (Bullet.new args, "greenslime", @x, @y - @ch / 2, 0, -300 / 60, 0) if @state_time == 70
      if @on_ground
        @dx = 0
        set_new_state IDLE
      end
    else
      @state = IDLE
    end
  end

  private def next_state
    return case @state
    when IDLE
      # [ARC_ATTACK, JUMP].select { |s| s != @last_attack }.sample
      [ARC_ATTACK, JUMP].sample
      # ARC_ATTACK
    when ARC_ATTACK, JUMP, HOP
      IDLE
    end
  end

  private def state_string
    case @state
    when -1 then "PRE_IDLE"
    when 0 then "IDLE"
    when 1 then "ARC ATTACK"
    when 2 then "JUMP"
    when 3 then "HOP"
    end
  end

  def check_bullets args, bullets
    bullets.each { |b|
      next if b.remove
      bcrect = b.crect
      if Utils.overlaps? bcrect, @guard_hit_box
        b.remove = true
        args.audio[:esfx] = { input: "sounds/gem.wav", gain: 0.4, looping: false }
      end
      if Utils.overlaps? b.crect, @actual_hit_box
        b.remove = true
        @health -= b.damage
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

  def update args, bullets, enemy_bullets
    apply_physics @walls, false
    @x += @dx
    @y += @dy
    @actual_hit_box = { x: @x - 10, y: @y + 5, w: 20, h: 20 }
    @guard_hit_box = { x: @x - 25, y: @y - 25, w: 50, h: 40 }
    
    check_bullets args, bullets
    old_state = @state
    update_state args, enemy_bullets
    new_state = @state
    puts "new state #{state_string}" if old_state != new_state
  end

  def render args, cam, ui_cam
    @hflip = @dx < 0
    set_image args, "boss"
    cam.render args, self
    render_health args, cam

    if args.state.debug
      cam.render_box args, @actual_hit_box.x + @actual_hit_box.w / 2, @actual_hit_box.y + @actual_hit_box.h / 2, @actual_hit_box.w, @actual_hit_box.h, 255, 0, 0, 128
      cam.render_box args, @guard_hit_box.x + @guard_hit_box.w / 2, @guard_hit_box.y + @guard_hit_box.h / 2, @guard_hit_box.w, @guard_hit_box.h, 0, 0, 255, 128
    end
  end
  
end