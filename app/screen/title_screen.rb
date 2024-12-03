class TitleScreen < Screen

  def initialize args
    super()

    @buttons = []
    @buttons << Button.new("Play", WIDTH / 2, HEIGHT / 2 - 30, 100, 15) {
      finish args
    }

  end

  private def finish args
    args.state.sm.replace TestScreen.new args, "level1-1"
  end

  def update args
    # handle mouse input
    mx, my = @cam.from_screen_space args.inputs.mouse.x, args.inputs.mouse.y
    @buttons.each { |b| b.check_mouse mx, my }
    if args.inputs.mouse.click
      @buttons.each { |b| b.click }
    end
  end

  def render args
    Utils.clear_screen args, 5, 33, 55, 255
    @cam.render_text args, "CRANKY RAMPAGE", "fonts/m5x7.ttf", 12.66666 * 2, WIDTH / 2, HEIGHT / 2 + 30, 255, 255, 255, 255, 1, 1
    @buttons.each { |b| b.render args, @cam }
    @cam.flush args
  end

end