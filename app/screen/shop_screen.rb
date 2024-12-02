class ShopScreen < Screen

  def initialize args, next_screen
    super()

    @next_screen = next_screen

    @money = args.state.money
    @health = args.state.health
    @max_health = args.state.max_health
    @gun = args.state.gun
    puts "entered shop with gun #{@gun}"

    # sanity check
    raise ArgumentError if @money == nil || @health == nil || @max_health == nil || @gun == nil

    @buttons = []
    @add_heart_cost = (@max_health - 2) * 50
    add_heart = Button.new("+1 Heart - #{@add_heart_cost}", 220, 130, 100, 15) {
      if @money >= @add_heart_cost
        @max_health += 1
        @health += 1
        @money -= @add_heart_cost
        @add_heart_cost = (@max_health - 2) * 50
        add_heart.text = "+1 Heart - #{@add_heart_cost}"
      end
    }
    @buttons << add_heart

    @buttons << Button.new("Refill Hearts - 10", 100, 130, 100, 15) {
      if @money >= 10 && @health < @max_health
        @health = @max_health
        @money -= 10
      end
    }
    @buttons << Button.new("Machine Gun - 200", WIDTH / 2, 100, 110, 15) {
      if @money >= 200 && @gun != "machinegun"
        @gun = "machinegun"
        @money -= 200
      end
    }
    @buttons << Button.new("Triplet - 200", WIDTH / 2, 85, 110, 15) {
      if @money >= 200 && @gun != "triplet"
        @gun = "triplet"
        @money -= 200
      end
    }
    @buttons << Button.new("Spreader - 200", WIDTH / 2, 70, 110, 15) {
      if @money >= 200 && @gun != "spreader"
        @gun = "spreader"
        @money -= 200
      end
    }
    @buttons << Button.new("Beam - 400", WIDTH / 2, 55, 110, 15) {
      if @money >= 400 && @gun != "beam"
        @gun = "beam"
        @money -= 400
      end
    }
    @buttons << Button.new("Exit", WIDTH / 2, 20, 50, 15) {
      finish args
    }

  end

  private def finish args
    args.state.health = @health
    args.state.max_health = @max_health
    args.state.money = @money
    args.state.gun = @gun
    args.state.sm.replace TestScreen.new args
    case @next_screen
    when "test2" then args.state.sm.replace Test2Screen.new args
    when "boss" then args.state.sm.replace BossScreen.new args
    else args.state.sm.replace TestScreen.new args
    end
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
    full_hearts = @health
    empty_hearts = @max_health - full_hearts
    count = 0
    full_hearts.times { |i|
      @cam.render_image args, (args.state.assets.find "heartfull"), 10 + 13 * count, HEIGHT - 11, 11, 9
      count += 1
    }
    empty_hearts.times { |i|
      @cam.render_image args, (args.state.assets.find "heartempty"), 10 + 13 * count, HEIGHT - 11, 11, 9
      count += 1
    }
    @cam.render_image args, (args.state.assets.find "money"), 11, HEIGHT - 25, 12, 12
    @cam.render_text args, "#{@money}", "fonts/m5x7.ttf", 12.66666, 22, HEIGHT - 25, 255, 255, 255

    @cam.render_text args, "SHOP", "fonts/m5x7.ttf", 12.66666 * 1.5, WIDTH / 2, HEIGHT - 20, 255, 255, 255, 255, 1, 1

    @buttons.each { |b| b.render args, @cam }
    # @cam.render_text args, "Refill Hearts - 10", "fonts/m5x7.ttf", 12.66666, 40, 130, 255, 255, 255
    # @cam.render_text args, "+1 Heart - 10", "fonts/m5x7.ttf", 12.66666, 170, 130, 255, 255, 255
    # @cam.render_text args, "+1 Heart - 10", "fonts/m5x7.ttf", 12.66666, 50, 100, 255, 255, 255
  end

end