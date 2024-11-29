class TestScreen < Screen

  def initialize
    super

    @bullets = []

    @player = Player.new
    @player.x = WIDTH / 2
    @player.y = HEIGHT / 2

    @cam.look_at @player.x, HEIGHT / 2

    @tiled_map = TiledMap.new "assets/testmap.tmx"
  end

  private def add_bullet args, mx, my
    dir = @player.hflip ? -1 : 1
    speed = 300 / 60
    dx = mx - @player.x
    dy = my - @player.y
    deg = (Math.atan2 dy, dx) * 180 / PI
    deg = (deg / 45).round * 45
    dx = Math.cos(deg * PI / 180)
    dy = Math.sin(deg * PI / 180)
    len = Math.sqrt(dx**2 + dy**2)
    dx /= len
    dy /= len
    @bullets << Bullet.new(args, @player.x + 13 * dx, @player.y + 13 * dy - 1, speed * dx, speed * dy, deg)
  end

  def update args
    # handle key input
    @player.left = args.inputs.left
    @player.right = args.inputs.right
    if args.inputs.up
      @player.jump
    end
    if args.inputs.keyboard.key_down.one
      args.state.debug = !args.state.debug
    end

    # handle mouse input
    (mx, my) = @cam.from_screen_space(args.inputs.mouse.x, args.inputs.mouse.y)
    if args.inputs.mouse.button_left
      if @player.fire
        add_bullet args, mx, my
      end
    end

    # update bullets
    @bullets.each { |b| b.update @tiled_map.walls }
    @bullets.reject! { |b|
      b.remove 
    }

    # cam follow player
    @cam.look_at @player.x, HEIGHT / 2, 0.1

    # update player
    @player.look_at mx, my
    @player.update @tiled_map.walls
  end

  def render args
    Utils.clear_screen args, 20, 20, 40, 255

    @tiled_map.render args, @cam
    @player.render args, @cam
    @bullets.each { |b| b.render args, @cam }

    # debug text
    args.outputs.labels << { text: "player x, y #{@player.x.round(2)} #{@player.y.round(2)}", x: 20, y: args.grid.h - 10, **WHITE }
    args.outputs.labels << { text: "player dx, dy #{@player.dx.round(2)} #{@player.dy.round(2)}", x: 20, y: args.grid.h - 30, **WHITE }
    args.outputs.labels << { text: "cam x, y #{@cam.x.round(2)}, #{@cam.y.round(2)}", x: 20, y: args.grid.h - 50, **WHITE }
  end

end