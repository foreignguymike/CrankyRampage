class Boss < Enemy
  DROP = -2
  PRE_IDLE = -1
  IDLE = 0
  ARC_ATTACK = 1
  JUMP = 2
  HOP = 3
  PHASE2 = 4
  EXPLODING = 5
  DEAD = 6

  ATTACKS = [ARC_ATTACK, JUMP, HOP]

  attr_reader :state

  def initialize x, y, player, walls
    super x, y
    @max_speed = 40 / 60
    @max_health = @health = 3000
    @cw = 30
    @ch = 50
    @player = player
    @walls = walls
    @actual_hit_box = { x: @x - 10, y: @y + 5, w: 20, h: 20 }
    @guard_hit_box = { x: @x - 25, y: @y - 25, w: 50, h: 30 }

    @state = DROP
    @state_time = 0
    @last_attack = nil
    @hop_count = 0
    @hop_dir = 1
    @phase2 = false
    @shield = false
  end

  private def mad?
    @health <= @max_health / 2 && !@phase2
  end

  private def set_new_state state
    @state_time = 0
    @state = state
    if @phase2
      @phase2 = false
      @state = PHASE2
      return
    end
    case @state
    when HOP
      @gravity = mad? ? 1000 / 60 / 60 : GRAVITY
      @hop_count = mad? ? 3 : 3
      @hop_dir = @x < @player.x ? 1 : -1
    when EXPLODING
      @dx = @dy = 0
      @can_hit_player = false
    end
    @last_attack = state if ATTACKS.include? state
  end

  private def update_state args, enemy_bullets, particles
    @state_time += 1
    case @state
    when DROP
      set_new_state PRE_IDLE if @on_ground
    when PRE_IDLE
      set_new_state IDLE if @state_time >= 120
    when IDLE
      set_new_state next_state if @state_time >= (mad? ? 30 : 60)
    when PHASE2
      if !@on_ground
        @state_time = 0
      else
        @dx = 0
      end
      @shield = true if @state_time == 60
      set_new_state IDLE if @state_time >= 120
    when ARC_ATTACK
      if @state_time % (mad? ? 13 : 20) == 0
        dx = if mad?
          @x < @player.x ? rand(150) + 30 : -rand(190) - 30
        else
          @x < @player.x ? rand(100) + 30 : -rand(190) - 30
        end
        dy = rand(100) + 250
        enemy_bullets << (Bullet.new args, "greenslime", @x, @y + @ch / 2, dx / 60, dy / 60, 0, true)
      end
      set_new_state next_state if @state_time >= 120
    when JUMP
      if @state_time == 5
        @dy = 400 / 60
        @dx = @x < @player.x ? 144 / 60 : -144 / 60
      end
      if mad?
        enemy_bullets << (Bullet.new args, "greenslime", @x, @y - @ch / 2, 0, -300 / 60, 0) if @state_time == 20 || @state_time == 40 || @state_time == 60 || @state_time == 80
      else
        enemy_bullets << (Bullet.new args, "greenslime", @x, @y - @ch / 2, 0, -300 / 60, 0) if @state_time == 30 || @state_time == 70
      end
      if @on_ground && @state_time > 5
        @dx = 0
        set_new_state IDLE
      end
    when HOP
      if @on_ground && @hop_count == 0
        @dx = 0
        @gravity = GRAVITY
        set_new_state IDLE
      end
      if @on_ground && @hop_count > 0
        @dy = mad? ? 250 / 60 : 250 / 60
        @dx = @hop_dir * (mad? ? 150 / 60 : 76 / 60)
        @hop_count -= 1
      end
    when EXPLODING
      if @state_time > 60 && @state_time < 300
        if @state_time % 3 == 0
          particles << (Particle.new "explosion", @x + rand(@cw) - @cw / 2, @y + rand(@ch) - @ch / 2, 32, 32, 0, 0, 8, 3, true)
        end
        args.audio[:esfx] = { input: "sounds/explode.wav", gain: 0.4, looping: false } if @state_time % 10 == 0
      end
      set_new_state DEAD if @state_time == 301
    else
      @state = IDLE
    end
  end

  private def next_state
    return case @state
    when IDLE, PHASE2
      [ARC_ATTACK, JUMP, HOP].select { |s| s != @last_attack }.sample
      # [ARC_ATTACK, JUMP].sample
      # HOP
      # ARC_ATTACK
    when ARC_ATTACK, JUMP, HOP
      IDLE
    end
  end

  private def state_string
    case @state
    when DROP then "DROP"
    when PRE_IDLE then "PRE_IDLE"
    when IDLE then "IDLE"
    when ARC_ATTACK then "ARC ATTACK"
    when JUMP then "JUMP"
    when HOP then "HOP"
    when PHASE2 then "PHASE2"
    when EXPLODING  then "EXPLODING"
    when DEAD then "DEAD"
    end
  end

  def check_bullets args, bullets
    if @state == PHASE2 || @phase2
      rect = crect
      bullets.each { |b|
        next if b.remove
        if Utils.overlaps? b.crect, rect
          b.remove = true
        args.audio[:esfx] = { input: "sounds/gem.wav", gain: 0.4, looping: false }
        end
      }
      return
    end

    hit_box = mad? ? @actual_hit_box : crect
    bullets.each { |b|
      next if b.remove
      bcrect = b.crect
      if @shield
        if Utils.overlaps? bcrect, @guard_hit_box
          b.remove = true
          args.audio[:esfx] = { input: "sounds/gem.wav", gain: 0.4, looping: false }
        end
      end
      if Utils.overlaps? b.crect, hit_box
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

  def dead?
    @state == DEAD
  end

  def update args, bullets, enemy_bullets, particles
    return if @state == DEAD
    apply_physics @walls, false if @state != EXPLODING
    @x += @dx
    @y += @dy
    @actual_hit_box = { x: @x - 10, y: @y + 5, w: 20, h: 20 }
    @guard_hit_box = { x: @x - 25, y: @y - 25, w: 50, h: 40 }
    
    old_health = @health
    if @state != EXPLODING
      check_bullets args, bullets
    end
    if old_health > @max_health / 2 && @health <= @max_health / 2
      @phase2 = true
    end

    if old_health > 0 && @health <= 0
      @health = 0
      set_new_state EXPLODING
    end

    old_state = @state
    update_state args, enemy_bullets, particles
    new_state = @state
  end

  def render args, cam, ui_cam
    @hflip = @dx < 0
    if @state == JUMP && @on_ground
      set_image args, "bosssquat"
    elsif @state == HOP && @on_ground
      set_image args, "bosssquat"
    elsif @state == PRE_IDLE
      set_image args, "bosssquat"
    else
      set_image args, "bossidle"
    end
    cam.render args, self
    cam.render_image args, (args.state.assets.find "bossshield"), @x, @y, 50, 50 if @shield
    w = 160
    w2 = (w - 2) * @health / @max_health
    ui_cam.render_box args, WIDTH / 2, HEIGHT - 8, w, 4, 0, 0, 0
    ui_cam.render_box args, WIDTH / 2 - (w - w2) / 2 + 1, HEIGHT - 8, w2, 2, 198, 216, 49

    render_debug args, cam if args.state.debug
  end
  
end