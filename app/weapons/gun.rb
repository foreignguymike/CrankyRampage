class Gun
  def initialize add_bullet, fire_interval, burst_interval = 0, burst_count = 1, bullet: "pistol", spread: 0, num_bullets: 1, bullet_angle: 0, speed: 500 / 60
    @add_bullet = add_bullet
    @fire_interval = fire_interval
    @burst_interval = burst_interval
    @burst_count = burst_count
    @burst_remaining = 0
    @fire_timer = fire_interval
    @burst_timer = 0
    @spread = spread
    @num_bullets = num_bullets
    @bullet_angle = bullet_angle
    @bullet = bullet
    @speed = speed

    # sanity check
    raise ArgumentError, "fire_interval must be greater than burst_interval * burst_count" if fire_interval <= burst_interval * burst_count
  end

  def update args, x, y, mx, my, offset = 0
    @fire_timer -= 1
    @burst_timer -= 1
    perform_fire args, x, y, mx, my, offset if can_burst?
  end

  def can_fire?
    @fire_timer <= 0
  end

  def can_burst?
    @burst_remaining > 0 && @burst_timer <= 0
  end

  def fire
    return unless can_fire? && @burst_remaining == 0
    @fire_timer = @fire_interval
    @burst_remaining = @burst_count
  end

  private def perform_fire args, x, y, mx, my, offset
    create_bullets args, x, y, mx, my, offset
    @burst_remaining -= 1
    @burst_timer = @burst_interval
  end

  private def create_bullets args, x, y, mx, my, offset
    dx = mx - x
    dy = my - y
    deg = (Math.atan2 dy, dx) * 180 / PI
    angle_per_bullet = @bullet_angle / @num_bullets
    deg -= @bullet_angle / 2

    @num_bullets.times { |i|
      tdeg = deg + (@spread > 0 ? rand(@spread) - @spread / 2 : 0)
      dx = Math.cos tdeg * PI / 180
      dy = Math.sin tdeg * PI / 180
      len = Math.sqrt dx**2 + dy**2
      dx /= len
      dy /= len
      bx = x + offset * dx
      by = @bullet == "wave" ? y : y + offset * dy - 1
      @add_bullet.call args, (Bullet.new args, @bullet, bx, by, @speed * dx, @speed * dy, tdeg), @bullet != "beam"
      deg += angle_per_bullet
    }
  end

  def self.from name, *args
    case name
    when "triplet" then Triplet.new *args
    when "machinegun" then MachineGun.new *args
    when "spreader" then Spreader.new *args
    when "beam" then Beam.new *args
    else Pistol.new *args
    end
  end
end

class Pistol < Gun
  def initialize add_bullet
    super add_bullet, 15
  end
end

class Triplet < Gun  
  def initialize add_bullet
    super add_bullet, 30, 4, 3, bullet: "triplet"
  end
end

class MachineGun < Gun
  def initialize add_bullet
    super add_bullet, 6, spread: 20, bullet: "machinegun"
  end
end

class Spreader < Gun
  def initialize add_bullet
    super add_bullet, 30, num_bullets: 5, bullet_angle: 30, bullet: "wave"
  end
end

class Beam < Gun
  def initialize add_bullet
    super add_bullet, 1, bullet: "beam", speed: 1000 / 60
  end
end
