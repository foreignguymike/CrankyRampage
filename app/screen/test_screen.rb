class TestScreen < Screen

  def initialize
    super

    @player = Player.new
    @player.x = WIDTH / 2
    @player.y = HEIGHT / 2

    @walls = []
    @walls << { x: WIDTH / 2, y: 8, w: 280, h: 16 }
  end

  def update args
    # handle inputs
    @player.left = args.inputs.left
    @player.right = args.inputs.right
    if args.inputs.up
      @player.jump
    end
    (mx, my) = @cam.from_screen_space(args.inputs.mouse.x, args.inputs.mouse.y)
    
    @player.look_at mx, my
    @player.update @walls
  end

  def render args
    @walls.each { |w| @cam.renderBox args, w.x, w.y, w.w, w.h, 0, 0, 0, 255 }
    @player.render args, @cam
  end

end