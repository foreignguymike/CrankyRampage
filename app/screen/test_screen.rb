class TestScreen < Screen

  def initialize args
    super()

    @random = Random.new

    @bullets = []
    @particles = []
    @enemies = []
    @collectables = []

    @enemies << (SpikeWheel.new 350, HEIGHT / 2)
    @enemies << (SpikeWheel.new 550, HEIGHT / 2)
    @enemies << (SpikeWheel.new 880, 32)
    @enemies << (SpikeWheel.new 1200, 32)
    @enemies << (SpikeWheel.new 1350, 32)
    @enemies << (SpikeWheel.new 1500, 32)

    @player = Player.new
    @player.x = WIDTH / 2
    @player.y = HEIGHT / 2

    @cloudx = 0

    @cam.look_at @player.x, HEIGHT / 2

    @tiled_map = TiledMap.new "assets/testmap.tmx"

    @cursor = Cursor.new
    $gtk.hide_cursor

    # args.audio[:music] = { input: "music/meadow.mp3", gain: 1, looping: true }
  end

  private def add_bullet args, mx, my
    dir = @player.hflip ? -1 : 1
    speed = 500 / 60
    dx = mx - @player.x
    dy = my - @player.y
    deg = (Math.atan2 dy, dx) * 180 / PI
    deg = (deg / 45).round * 45
    dx = Math.cos deg * PI / 180
    dy = Math.sin deg * PI / 180
    len = Math.sqrt dx**2 + dy**2
    dx /= len
    dy /= len
    x = @player.x + 13 * dx
    y = @player.y + 13 * dy - 1
    @bullets << (Bullet.new args, x, y, speed * dx, speed * dy, deg)
    @particles << (Particle.new "gunflash", x + dx, y + dy, 7, 7, 0, 0, 3, 2, true)
  end

  private def update_cam mx, my
    @cam.look_at (@player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2), HEIGHT / 2, 0.07
    # follow mouse
    # midx = (@player.x + mx) / 2
    # midy = (@player.y + my) / 2
    # dx = midx - @player.x
    # dy = midy - @player.y
    # dist = Math.sqrt dx**2 + dy**2
    # if dist > 50
    #   scale = 50 / dist
    #   midx = @player.x + dx * scale
    #   midy = @player.y + dy * scale
    # end
    # @cam.look_at [midx, WIDTH / 2].max, HEIGHT / 2, 0.07
  end

  def update args
    # handle key input
    @player.left = args.inputs.left
    @player.right = args.inputs.right
    if args.inputs.down
      @player.drop
    end
    if args.inputs.up
      @player.jump
    end

    # handle mouse input
    mx, my = @cam.from_screen_space args.inputs.mouse.x, args.inputs.mouse.y
    if args.inputs.mouse.button_left
      if @player.fire
        args.audio[:sfx] = { input: "sounds/shoot.wav", gain: 0.2, looping: false }
        add_bullet args, mx, my
      end
    end

    # update enemies
    @enemies.reject! { |e| 
      e.update args, @tiled_map.walls, @bullets
      if e.health <= 0
        @particles << (Particle.new "explosion", e.x, e.y + 7, 32, 32, 0, 0, 8, 3, true)
        @particles << (Particle.new "explosion", e.x - 5, e.y - 5, 32, 32, 0, 0, 8, 3, true)
        @particles << (Particle.new "explosion", e.x + 5, e.y - 5, 32, 32, 0, 0, 8, 3, true)
        args.audio[:esfx] = { input: "sounds/explode.wav", gain: 0.4, looping: false }
        4.times {
          rad = rand * 2 * PI / 4 + PI / 4
          dx = Math.cos rad
          dy = Math.sin rad
          @collectables << (Gem.new "gem", e.x, e.y, 12, 12, dx * 100 / 60, dy * 150 / 60, 24, 2)
        }
      end
      e.remove 
    }

    # update collectables
    @collectables.reject! { |c|
      c.update @tiled_map.walls
      c.remove 
    }

    # update particles
    @particles.reject! { |p|
      p.update
      p.remove
    }

    # update bullets
    @bullets.reject! { |b|
      b.update @tiled_map.walls
      b.remove
    }

    # cam follow player
    update_cam mx, my

    # update player
    @player.look_at mx, my
    @player.update args, @tiled_map.walls, @enemies, @collectables

    # update cursor
    @cursor.x = mx
    @cursor.y = my
    @cursor.update
  end

  def render args
    Utils.clear_screen args, 20, 20, 40, 255
    @ui_cam.render_image args, (args.state.assets.find "sky"), WIDTH / 2, HEIGHT / 2, WIDTH, HEIGHT
    @cloudx = (@cloudx + 0.02) % WIDTH
    @ui_cam.render_image args, (args.state.assets.find "clouds"), @cloudx + WIDTH, HEIGHT / 2 - 10, WIDTH, HEIGHT
    @ui_cam.render_image args, (args.state.assets.find "clouds"), @cloudx, HEIGHT / 2 - 10, WIDTH, HEIGHT
    @ui_cam.render_image args, (args.state.assets.find "clouds"), @cloudx - WIDTH, HEIGHT / 2 - 10, WIDTH, HEIGHT
    @ui_cam.render_image args, (args.state.assets.find "mountains"), WIDTH / 2, HEIGHT / 2 - 30, WIDTH, HEIGHT

    @tiled_map.render args, @cam
    @player.render args, @cam
    @enemies.each { |e| e.render args, @cam }
    @collectables.each { |c| c.render args, @cam }
    @bullets.each { |b| b.render args, @cam }
    @particles.each { |p| p.render args, @cam }

    @cursor.render args, @cam

    # debug text
    args.outputs.labels << { text: "player x, y #{@player.x.round(2)} #{@player.y.round(2)}", x: 10, y: args.grid.h - 10, **BLACK }
    args.outputs.labels << { text: "player dx, dy #{@player.dx.round(2)} #{@player.dy.round(2)}", x: 10, y: args.grid.h - 30, **BLACK }
    args.outputs.labels << { text: "cam x, y #{@cam.x.round(2)}, #{@cam.y.round(2)}", x: 10, y: args.grid.h - 50, **BLACK }
    args.outputs.labels << { text: "entity count #{@collectables.size + @enemies.size + @bullets.size + @particles.size + 2}", x: 10, y: args.grid.h - 70, **BLACK }
    args.outputs.labels << { text: "DR version #{$gtk.version}", x: 10, y: 25, **BLACK }
  end

end