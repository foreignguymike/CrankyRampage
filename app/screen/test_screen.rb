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
    @death_time = 0

    parse_map

    @cloudx = 0

    @cam.look_at (@player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2), (@player.y.clamp HEIGHT / 2, @tiled_map.map_height - HEIGHT / 2)

    @cursor = Cursor.new
    $gtk.hide_cursor

    @ui = UI.new @player

    # play music
    args.audio[:music] = { input: "music/level1.mp3", gain: 0.5, looping: true } if !args.audio[:music]

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
    if !@player.dead?
      @player.left = args.inputs.left
      @player.right = args.inputs.right
      @player.drop if args.inputs.down
      @player.jump args if args.inputs.up
      mx, my = @cam.from_screen_space args.inputs.mouse.x, args.inputs.mouse.y
      @player.look_at mx, my
      @player.fire if args.inputs.mouse.button_left
    end

    # update enemies
    @enemies.reject! { |e| 
      e.update args, @player, @bullets, @enemy_bullets
      if e.dead?
        @particles << (Particle.new "explosion", e.x, e.y + 7, 32, 32, 0, 0, 8, 3, true)
        @particles << (Particle.new "explosion", e.x - 5, e.y - 5, 32, 32, 0, 0, 8, 3, true)
        @particles << (Particle.new "explosion", e.x + 5, e.y - 5, 32, 32, 0, 0, 8, 3, true)
        args.audio[:esfx] = { input: "sounds/explode.ogg", gain: 0.4, looping: false }
        e.gems.each { |c|
          rad = rand * 2 * PI / 4 + PI / 4
          dx = Math.cos rad
          dy = Math.sin rad
          @collectables << (Gem.new c.type, c.x || e.x, c.y || e.y, dx * 100 / 60, dy * 150 / 60, false)
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

    # update enemy bullets
    @enemy_bullets.reject! { |b|
      b.update @tiled_map.walls
      b.remove
    }

    # cam follow player
    if @tiled_map.map_rows <= 12
      @cam.look_at (@player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2), HEIGHT / 2, 0.08
    else
      @cam.look_at (@player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2), (@player.y.clamp HEIGHT / 2, @tiled_map.map_height - HEIGHT / 2), 0.08
    end

    # update player
    if @player.dead?
      args.audio[:music] = nil
      @death_time += 1
      if @death_time == 120
        args.state.lives -= 1
        if args.state.lives <= 0
          $gtk.show_cursor
          args.state.sm.replace GameOverScreen.new args
        else
          args.state.sm.replace TestScreen.new args, @map_id
        end
      end
    else
      @player.update args, @tiled_map.walls, @enemies, @enemy_bullets, @collectables
    end

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
    if @death_time > 0
      Utils.clear_screen args, 0, 0, 0, 255
      @player.render args, @cam
    else
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
      @cam.flush args

      @ui.render args, @ui_cam
      @ui_cam.flush args

      @cursor.render args, @cam
      @cam.flush args
    end
  end

end