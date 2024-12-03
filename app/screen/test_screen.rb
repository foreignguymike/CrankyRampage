class TestScreen < Screen

  def initialize args, map_id
    super()

    @map_id = map_id
    @tiled_map = TiledMap.new map_file_from_map_id

    @player = Player.new
    @player.x = @tiled_map.p.x
    @player.y = @tiled_map.p.y
    @player.set_gun Gun.from args.state.gun, add_bullet
    @player.money = (args.state.money ||= 0)
    @player.health = (args.state.health ||= @player.max_health)
    @player.max_health = (args.state.max_health ||= @player.max_health)
    args.state.lives ||= 3

    parse_map

    @cloudx = 0

    @cam.look_at (@player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2), (@player.y.clamp HEIGHT / 2, @tiled_map.map_height - HEIGHT / 2)

    @cursor = Cursor.new
    $gtk.hide_cursor

    @ui = UI.new @player

    # play music
    # args.audio[:music] = { input: "music/meadow.mp3", gain: 1, looping: true }
  end

  private def map_file_from_map_id
    return case @map_id
    when "level1-1" then "assets/testmap.tmx"
    when "level1-2" then "assets/test2map.tmx"
    when "boss1" then "assets/bossmap.tmx"
    else raise ArgumentError "unknown map id #{@map_id}"
    end
  end

  private def next_map_id
    return case @map_id
    when "level1-1" then "level1-2"
    when "level1-2" then "boss1"
    end
  end

  private def parse_map
    @tiled_map.entities.each { |e|
      case e.name
      when "amber", "emerald", "sapphire", "ruby"
        @collectables << (Gem.new e.name, e.x, e.y, 0, 0)
      when "yoyo"
        @enemies << (Yoyo.new e.x, e.y, @tiled_map.walls)
      when "slimer"
        @enemies << (Slimer.new e.x, e.y, @tiled_map.walls.select { |w| e.wall_ids.include? w.id })
      when "sneaky"
        @enemies << (Sneaky.new e.x, e.y, @tiled_map.walls)
      end
    }
  end

  private def finish args
    $gtk.show_cursor
    args.state.health = @player.health
    args.state.max_health = @player.max_health
    args.state.money = @player.money
    args.state.gun = @player.gun.class.name.downcase
    args.state.sm.replace ShopScreen.new args, next_map_id
  end

  def update args
    @start_time = Time.now
    # handle key input
    @player.left = args.inputs.left
    @player.right = args.inputs.right
    @player.drop if args.inputs.down
    @player.jump if args.inputs.up
    if args.state.debug
      if args.inputs.keyboard.key_down.one
        @player.set_gun Gun::Pistol.new add_bullet
      elsif args.inputs.keyboard.key_down.two
        @player.set_gun Gun::MachineGun.new add_bullet
      elsif args.inputs.keyboard.key_down.three
        @player.set_gun Gun::Triplet.new add_bullet
      elsif args.inputs.keyboard.key_down.four
        @player.set_gun Gun::Spreader.new add_bullet
      elsif args.inputs.keyboard.key_down.five
        @player.set_gun Gun::Beam.new add_bullet
      end
      if args.inputs.keyboard.key_down.r
        args.state.sm.replace TestScreen.new args, @map_id
      end
    end

    # handle mouse input
    mx, my = @cam.from_screen_space args.inputs.mouse.x, args.inputs.mouse.y
    @player.fire if args.inputs.mouse.button_left

    # update enemies
    start_time = Time.now
    @enemies.reject! { |e| 
      e.update args, @player, @bullets, @enemy_bullets
      if e.dead?
        @particles << (Particle.new "explosion", e.x, e.y + 7, 32, 32, 0, 0, 8, 3, true)
        @particles << (Particle.new "explosion", e.x - 5, e.y - 5, 32, 32, 0, 0, 8, 3, true)
        @particles << (Particle.new "explosion", e.x + 5, e.y - 5, 32, 32, 0, 0, 8, 3, true)
        args.audio[:esfx] = { input: "sounds/explode.wav", gain: 0.4, looping: false }
        e.gems.each { |c|
          rad = rand * 2 * PI / 4 + PI / 4
          dx = Math.cos rad
          dy = Math.sin rad
          @collectables << (Gem.new c.type, c.x || e.x, c.y || e.y, dx * 100 / 60, dy * 150 / 60, false)
        }
      end
      e.remove 
    }
    @enemy_update_time = Time.now - start_time

    # update collectables
    start_time = Time.now
    @collectables.reject! { |c|
      c.update @tiled_map.walls
      c.remove 
    }
    @collectable_update_time = Time.now - start_time

    # update particles
    start_time = Time.now
    @particles.reject! { |p|
      p.update
      p.remove
    }
    @particle_update_time = Time.now - start_time

    # update bullets
    start_time = Time.now
    @bullets.reject! { |b|
      b.update @tiled_map.walls
      b.remove
    }
    @bullet_update_time = Time.now - start_time

    # update enemy bullets
    start_time = Time.now
    @enemy_bullets.reject! { |b|
      b.update @tiled_map.walls
      b.remove
    }
    @enemy_bullet_update_time = Time.now - start_time

    # cam follow player
    if @tiled_map.map_rows <= 12
      @cam.look_at (@player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2), HEIGHT / 2, 0.08
    else
      @cam.look_at (@player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2), (@player.y.clamp HEIGHT / 2, @tiled_map.map_height - HEIGHT / 2), 0.08
    end

    # update player
    @player.look_at mx, my
    start_time = Time.now
    @player.update args, @tiled_map.walls, @enemies, @enemy_bullets, @collectables
    if @player.dead?
      args.state.lives -= 1
      if args.state.lives <= 0
        $gtk.show_cursor
        args.state.sm.replace GameOverScreen.new args
      else
        args.state.sm.replace TestScreen.new args, @map_id
      end
    end
    @player_update_time = Time.now - start_time

    # update cursor
    @cursor.x = mx
    @cursor.y = my
    @cursor.update

    # end level
    if @player.x > @tiled_map.map_width
      finish args
    end
  end

  def render args
    start_time = Time.now
    Utils.clear_screen args, 21, 60, 74, 255
    if @map_id == "level1-1"
      @ui_cam.render_image args, (args.state.assets.find "sky"), WIDTH / 2, HEIGHT / 2, WIDTH, HEIGHT
      @cloudx = (@cloudx + 0.04) % WIDTH
      @ui_cam.render_image args, (args.state.assets.find "clouds"), @cloudx + WIDTH, HEIGHT / 2 - 25, WIDTH, HEIGHT
      @ui_cam.render_image args, (args.state.assets.find "clouds"), @cloudx, HEIGHT / 2 - 25, WIDTH, HEIGHT
      @ui_cam.render_image args, (args.state.assets.find "clouds"), @cloudx - WIDTH, HEIGHT / 2 - 25, WIDTH, HEIGHT
      @ui_cam.render_image args, (args.state.assets.find "mountains"), WIDTH / 2, HEIGHT / 2 - 30 - @cam.y / 20, WIDTH, HEIGHT
    end
    @ui_cam.flush args

    @player.render args, @cam
    @enemies.each { |e| e.render args, @cam }
    @tiled_map.render args, @cam
    @collectables.each { |c| c.render args, @cam }
    @bullets.each { |b| b.render args, @cam }
    @enemy_bullets.each { |b| b.render args, @cam }
    @particles.each { |p| p.render args, @cam }

    @ui.render args, @ui_cam
    @ui_cam.flush args

    @cursor.render args, @cam

    @cam.flush args
    @render_time = Time.now - start_time
    @frame_time = Time.now - @start_time

    # debug text
    if args.state.debug
      color = BLACK
      args.outputs.labels << { text: "player x, y #{@player.x.round(2)} #{@player.y.round(2)}", x: 10, y: args.grid.h - 200, **color }
      args.outputs.labels << { text: "player dx, dy #{@player.dx.round(2)} #{@player.dy.round(2)}", x: 10, y: args.grid.h - 220, **color }
      args.outputs.labels << { text: "cam x, y #{@cam.x.round(2)}, #{@cam.y.round(2)}", x: 10, y: args.grid.h - 240, **color }
      args.outputs.labels << { text: "entity count #{@collectables.size + @enemies.size + @bullets.size + @particles.size + 2}", x: 10, y: args.grid.h - 260, **color }
      args.outputs.labels << { text: "Frame time: #{(1000 * @frame_time).round(0)}ms", x: 10, y: args.grid.h - 300, **color }
      args.outputs.labels << { text: "Render time: #{(1000 * @frame_time).round(0)}ms", x: 10, y: args.grid.h - 320, **color }
      args.outputs.labels << { text: "Enemy time: #{(1000 * @enemy_update_time).round(0)}ms", x: 10, y: args.grid.h - 340, **color }
      args.outputs.labels << { text: "Collectable time: #{(1000 * @collectable_update_time).round(0)}ms", x: 10, y: args.grid.h - 360, **color }
      args.outputs.labels << { text: "Particle time: #{(1000 * @particle_update_time).round(0)}ms", x: 10, y: args.grid.h - 380, **color }
      args.outputs.labels << { text: "Bullet time: #{(1000 * @bullet_update_time).round(0)}ms", x: 10, y: args.grid.h - 400, **color }
      args.outputs.labels << { text: "Enemy Bullet time: #{(1000 * @enemy_bullet_update_time).round(0)}ms", x: 10, y: args.grid.h - 420, **color }
      args.outputs.labels << { text: "Player time: #{(1000 * @player_update_time).round(0)}ms", x: 10, y: args.grid.h - 440, **color }
      args.outputs.labels << { text: "DR version #{$gtk.version}", x: 10, y: 25, **color }
    end
  end

end