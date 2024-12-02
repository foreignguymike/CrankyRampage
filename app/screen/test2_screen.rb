class Test2Screen < Screen

  def initialize args
    super()

    @tiled_map = TiledMap.new "assets/test2map.tmx"

    @player = Player.new
    @player.x = @tiled_map.p.x
    @player.y = @tiled_map.p.y
    @player.set_gun Gun.from args.state.gun, add_bullet
    @player.money = (args.state.money ||= 0)
    @player.health = (args.state.health ||= @player.max_health)
    @player.max_health = (args.state.max_health ||= @player.max_health)

    parse_map

    @cloudx = 0

    @cam.look_at (@player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2), (@player.y.clamp HEIGHT / 2, @tiled_map.map_height - HEIGHT / 2)

    @cursor = Cursor.new
    $gtk.hide_cursor

    @ui = UI.new @player

    # debug
    @enemy_update_time = @collectable_update_time = @particle_update_time = @bullet_update_time = @player_update_time = 0

    # play music
    # args.audio[:music] = { input: "music/meadow.mp3", gain: 1, looping: true }
  end

  private def parse_map
    @tiled_map.entities.each { |e|
      case e.name
      when "amber", "emerald", "sapphire", "ruby"
        @collectables << (Gem.new e.name, e.x, e.y, 0, 0)
      when "yoyo"
        @enemies << (Yoyo.new e.x, e.y)
      when "slimer"
        @enemies << (Slimer.new e.x, e.y)
      end
    }
  end

  private def finish args
    $gtk.show_cursor
    args.state.health = @player.health
    args.state.max_health = @player.max_health
    args.state.money = @player.money
    args.state.gun = @player.gun.class.name.downcase
    args.state.sm.replace ShopScreen.new args, "test"
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
      if args.inputs.keyboard.key_down.r || @player.health <= 0
        args.state.sm.replace TestScreen.new args
      end
    end

    # handle mouse input
    mx, my = @cam.from_screen_space args.inputs.mouse.x, args.inputs.mouse.y
    @player.fire if args.inputs.mouse.button_left

    # update enemies
    start_time = Time.now
    @enemies.reject! { |e| 
      e.update args, @player, @tiled_map.walls, @bullets
      if e.health <= 0
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

    # cam follow player
    @cam.look_at (@player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2), HEIGHT / 2, 0.08

    # update player
    @player.look_at mx, my
    start_time = Time.now
    @player.update args, @tiled_map.walls, @enemies, @collectables
    args.state.sm.replace Test2Screen.new args if @player.health <= 0
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
    Utils.clear_screen args, 20, 20, 40, 255

    @player.render args, @cam
    @enemies.each { |e| e.render args, @cam }
    @tiled_map.render args, @cam
    @collectables.each { |c| c.render args, @cam }
    @bullets.each { |b| b.render args, @cam }
    @particles.each { |p| p.render args, @cam }

    @ui.render args, @ui_cam

    @cursor.render args, @cam

    @frame_time = Time.now - @start_time

    # debug text
    if args.state.debug
      color = BLACK
      args.outputs.labels << { text: "player x, y #{@player.x.round(2)} #{@player.y.round(2)}", x: 10, y: args.grid.h - 200, **color }
      args.outputs.labels << { text: "player dx, dy #{@player.dx.round(2)} #{@player.dy.round(2)}", x: 10, y: args.grid.h - 220, **color }
      args.outputs.labels << { text: "cam x, y #{@cam.x.round(2)}, #{@cam.y.round(2)}", x: 10, y: args.grid.h - 240, **color }
      args.outputs.labels << { text: "entity count #{@collectables.size + @enemies.size + @bullets.size + @particles.size + 2}", x: 10, y: args.grid.h - 260, **color }
      args.outputs.labels << { text: "Frame time: #{(1000 * @frame_time).round(0)}ms", x: 10, y: args.grid.h - 300, **color }
      args.outputs.labels << { text: "Enemy time: #{(1000 * @enemy_update_time).round(0)}ms", x: 10, y: args.grid.h - 320, **color }
      args.outputs.labels << { text: "Collectable time: #{(1000 * @collectable_update_time).round(0)}ms", x: 10, y: args.grid.h - 340, **color }
      args.outputs.labels << { text: "Particle time: #{(1000 * @particle_update_time).round(0)}ms", x: 10, y: args.grid.h - 360, **color }
      args.outputs.labels << { text: "Bullet time: #{(1000 * @bullet_update_time).round(0)}ms", x: 10, y: args.grid.h - 380, **color }
      args.outputs.labels << { text: "Player time: #{(1000 * @player_update_time).round(0)}ms", x: 10, y: args.grid.h - 400, **color }
      args.outputs.labels << { text: "DR version #{$gtk.version}", x: 10, y: 25, **color }
    end
  end

end