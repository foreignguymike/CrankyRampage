class UI
  def initialize player
    @player = player
  end

  def render args, cam
    # render hearts
    full_hearts = @player.health
    empty_hearts = @player.max_health - full_hearts
    count = 0
    full_hearts.times { |i|
      cam.render_image args, (args.state.assets.find "heartfull"), 10 + 13 * count, HEIGHT - 11, 11, 9
      count += 1
    }
    empty_hearts.times { |i|
      cam.render_image args, (args.state.assets.find "heartempty"), 10 + 13 * count, HEIGHT - 11, 11, 9
      count += 1
    }

    # render lives
    cam.render_image args, (args.state.assets.find "headhud"), WIDTH - 32, HEIGHT - 13, 20, 17
    cam.render_text args, "x#{args.state.lives}", "fonts/m5x7.ttf", 12.66666, WIDTH - 18, HEIGHT - 13, 255, 255, 255

    # render money
    cam.render_image args, (args.state.assets.find "money"), 11, HEIGHT - 25, 12, 12
    cam.render_text args, "#{@player.money}", "fonts/m5x7.ttf", 12.66666, 22, HEIGHT - 25, 255, 255, 255

  end
end