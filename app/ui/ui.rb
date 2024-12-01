class UI
  def initialize player
    @player = player
  end

  def render args, cam
    # render money
    cam.render_image args, (args.state.assets.find "money"), 11, HEIGHT - 11, 12, 12
    cam.render_text args, "#{@player.money}", "fonts/m5x7.ttf", 12.66666, 22, HEIGHT - 11, 255, 255, 255
  end
end