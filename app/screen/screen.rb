class Screen

  def initialize
    @cam = Camera.new
    @cam.set_size WIDTH, HEIGHT
    @ui_cam = Camera.new
    @ui_cam.set_size WIDTH, HEIGHT

    @bullets = []
    @enemy_bullets = []
    @particles = []
    @enemies = []
    @collectables = []

    # debug
    @enemy_update_time = @collectable_update_time = @particle_update_time = @bullet_update_time = @enemy_bullet_update_time = @player_update_time = 0
  end

  def add_bullet
    ->(args, b, flash = true) {
      args.audio[:sfx] = { input: "sounds/shoot.ogg", gain: 0.1, looping: false }
      @bullets << b
      @particles << (Particle.new "gunflash", b.x - b.dx, b.y - b.dy, 7, 7, 0, 0, 3, 2, true) if flash
    }
  end
  
  def update args
    raise NotImplementedError
  end

  def render args
    raise NotImplementedError
  end

end