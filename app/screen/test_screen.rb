class TestScreen < Screen

  def initialize
    @player = Player.new
    @cam = Camera.new

    @player.x = WIDTH / 2
    @player.y = HEIGHT / 2
  end

  def update
    # handle inputs
    @player.up = $args.inputs.up
    @player.left = $args.inputs.left
    @player.down = $args.inputs.down
    @player.right = $args.inputs.right
    (mx, my) = @cam.from_screen_space($inputs.mouse.x, $inputs.mouse.y)
    
    @player.look_at mx, my
    @player.update
  end

  def render
    @player.render @cam
  end

end