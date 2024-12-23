class Enemy < Entity
  
  attr_reader :gems, :can_hit_player

  def initialize x, y
    super()
    @x = x
    @y = y
    @walls = []
    @can_hit_player = true
  end

  def check_bullets args, bullets, rect = crect
    bullets.each { |b|
      next if b.remove
      if Utils.overlaps? b.crect, rect
        b.remove = true
        @health -= b.damage
        @flash = true
        @flash_time = 5
        if @health <= 0
          @remove = true
        end
        args.audio[:esfx] = { input: "sounds/enemyhit.ogg", gain: 1, looping: false }
      end
    }
    @flash_time -= 1
    if @flash_time <= 0
      @flash = false
    end
  end

  def render_health args, cam
    if @health < @max_health
      # draw outline
      cam.render_image args, (args.state.assets.find "enemyhealthbaroutline"), @x, @y + @h / 2, 15, 3
      # draw health 198, 216, 49
      w = 13 * @health / @max_health
      cam.render_box args, @x - (13 - w) / 2, @y + @h / 2, w, 1, 198, 216, 49
    end
  end
end