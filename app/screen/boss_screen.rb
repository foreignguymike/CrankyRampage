class BossScreen < Screen

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

    @cloudx = 0

    @cam.look_at (@player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2), (@player.y.clamp HEIGHT / 2, @tiled_map.map_height - HEIGHT / 2)

    @cursor = Cursor.new
    $gtk.hide_cursor

    @ui = UI.new @player

    @event_index = 0
    @event_time = 0

    @boss = Boss.new @tiled_map.map_width - 46, @tiled_map.map_height * 3, @player, @tiled_map.walls.select { |w| !w.platform }
    @enemies << @boss

    args.audio[:music] = nil

  end

  private def map_file_from_map_id
    return case @map_id
    when "boss1" then "assets/bossmap.tmx"
    else raise ArgumentError "unknown map id #{@map_id}"
    end
  end

  # scripted events
  private def update_event args
    case @event_index
    when 0
      # boss drop
      if @boss.on_ground
        @event_index = 1
        @event_time = 0
      end
    when 1
      # camera shake
      if @event_time < 60
        @event_time += 1
        x = @player.x.clamp WIDTH / 2, @tiled_map.map_width - WIDTH / 2
        y = @player.y.clamp HEIGHT / 2, @tiled_map.map_height - HEIGHT / 2
        step = 60 - @event_time
        shake = step.even? ? (step / 4).round : (-step / 4).round
        @cam.look_at x, y + shake
      else
        @event_index = 2
        args.audio[:music] = { input: "music/level1boss.mp3", gain: 0.5, looping: true }
        @event_time = 0
      end
    when 2
      @event_time += 1
      if @event_time >= 60
        @event_index = 10
        @event_time = 0
      end
    end
  end

  def finish args
    $gtk.show_cursor
    args.state.sm.replace CongratsScreen.new args
  end

  def update args
    # handle input
    mx, my = @cam.from_screen_space args.inputs.mouse.x, args.inputs.mouse.y
    if @event_index == 10
      if !@player.dead?
        @player.left = args.inputs.left
        @player.right = args.inputs.right
        @player.drop if args.inputs.down
        @player.jump args if args.inputs.up
        mx, my = @cam.from_screen_space args.inputs.mouse.x, args.inputs.mouse.y
        @player.look_at mx, my
        @player.fire if args.inputs.mouse.button_left
      end
    end

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

    # update boss
    @boss.update args, @bullets, @enemy_bullets, @particles
    if @boss.exploding?
      args.audio[:music] = nil
    end
    if @boss.dead?
      finish args
      return
    end

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
          args.state.sm.replace BossScreen.new args, @map_id
        end
      end
    else
      @player.look_at mx, my
      @player.update args, @tiled_map.walls, @enemies, @enemy_bullets, @collectables
    end

    # update cursor
    @cursor.x = mx
    @cursor.y = my
    @cursor.update

    # update event
    update_event args

  end

  def render args
    if @death_time > 0
      Utils.clear_screen args, 0, 0, 0, 255
      @player.render args, @cam
    else
      Utils.clear_screen args, 21, 60, 74, 255
      @tiled_map.render args, @cam
      @boss.render args, @cam, @ui_cam if !@boss.dead?
      @player.render args, @cam
      @collectables.each { |c| c.render args, @cam }
      @bullets.each { |b| b.render args, @cam }
      @enemy_bullets.each { |b| b.render args, @cam }
      @particles.each { |p| p.render args, @cam }
      @cam.flush args

      @ui.render args, @ui_cam
      @ui_cam.flush args

      @cursor.render args, @cam if @event_index == 10
      @cam.flush args

      if args.state.debug
        color = BLACK
        args.outputs.labels << { text: "enemy bullet count #{@enemy_bullets.size}", x: 10, y: args.grid.h - 260, **color }
      end
    end
  end

end