class TestScreen < Screen

  def initialize
    super

    @player = Player.new
    @player.x = WIDTH / 2
    @player.y = HEIGHT / 2

    @cam.x = @player.x
    @cam.y = HEIGHT / 2

    @walls = []
    @walls << (Utils.center_rect 20, 0, 500, 16)
    @walls << { x: 160, y: 40, w: 100, h: 4, platform: true }
    @walls << { x: 80, y: 70, w: 40, h: 4, platform: true }
    @walls << { x: 160, y: 100, w: 40, h: 4, platform: true }
  end

  def update args
    # handle inputs
    @player.left = args.inputs.left
    @player.right = args.inputs.right
    if args.inputs.up
      @player.jump
    end
    (mx, my) = @cam.from_screen_space(args.inputs.mouse.x, args.inputs.mouse.y)

    # cam follow player
    ease = 0.1
    @cam.look_at @player.x, @player.y, ease

    @player.look_at mx, my
    @player.update @walls
  end

  def render args
    @walls.each { |w| @cam.renderBox args, w.x, w.y, w.w, w.h, 0, 0, 0, 255 }
    @player.render args, @cam

    # debug text
    args.outputs.labels << { text: "player x, y #{@player.x.round(2)} #{@player.y.round(2)}", x: 20, y: args.grid.h - 10 }
    args.outputs.labels << { text: "player dx, dy #{@player.dx.round(2)} #{@player.dy.round(2)}", x: 20, y: args.grid.h - 30 }
    args.outputs.labels << { text: "cam x, y #{@cam.x.round(2)}, #{@cam.y.round(2)}", x: 20, y: args.grid.h - 50 }
  end

end