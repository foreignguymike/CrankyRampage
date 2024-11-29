require 'app/tiled/tiled_map'

class TestScreen < Screen

  def initialize
    super

    @player = Player.new
    @player.x = WIDTH / 2
    @player.y = HEIGHT / 2

    @cam.look_at @player.x, HEIGHT / 2

    @tiled_map = TiledMap.new "assets/testmap.tmx"
    puts "walls: #{@tiled_map.walls}"
  end

  def update args
    # handle inputs
    @player.left = args.inputs.left
    @player.right = args.inputs.right
    if args.inputs.up
      @player.jump
    end
    if args.inputs.keyboard.key_down.one
      args.state.debug = !args.state.debug
    end
    (mx, my) = @cam.from_screen_space(args.inputs.mouse.x, args.inputs.mouse.y)

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

    # debug text
    args.outputs.labels << { text: "player x, y #{@player.x.round(2)} #{@player.y.round(2)}", x: 20, y: args.grid.h - 10, **WHITE }
    args.outputs.labels << { text: "player dx, dy #{@player.dx.round(2)} #{@player.dy.round(2)}", x: 20, y: args.grid.h - 30, **WHITE }
    args.outputs.labels << { text: "cam x, y #{@cam.x.round(2)}, #{@cam.y.round(2)}", x: 20, y: args.grid.h - 50, **WHITE }
  end

end