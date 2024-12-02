class Entity
  ACCEL = 500 / 60 / 60
	FRICTION = 500 / 60 / 60
  GRAVITY = 500 / 60 / 60
  MAX_FALL_SPEED = 400 / 60
  JUMP = 200 / 60

  # input
  attr_accessor :left, :right, :down

  # movement
  attr_accessor :x, :y, :dx, :dy, :on_ground, :wg

  # size
  attr_reader :w, :h

  # collision
  attr_reader :cxo, :cyo, :cw, :ch

  # game
  attr_reader :health, :max_health

  # render
  attr_reader :a, :render_deg, :image, :hide, :hflip, :flash
  attr_accessor :remove
	
	def initialize
    @x = @y = @dx = @dy = 0
    @friction = FRICTION
    @gravity = GRAVITY
    @a = 255
    @cxo = @cyo = @cw = @ch = 0
    @render_deg = 0
    @remove = false
    @left = @right = @down = false
    @drop = false
    @max_speed = 70 / 60
    @jump_speed = JUMP
    @flash = false
    @flash_time = 0
    @health = 0
    @hflip = false
	end

  def set_image args, region
    @image = args.state.assets.find region
    @w = @image.tile_w
    @h = @image.tile_h
  end

  def set_image_index args, region, index, width
    @image = args.state.assets.find_index region, index, width
    @w = width
    @h = @image.tile_h
  end

  def crect x = @x, y = @y
    return { x: x + @cxo - @cw / 2, y: y + @cyo - @ch / 2, w: @cw, h: @ch }
  end

  def jump
    if @on_ground
      @dy = @jump_speed
    end
  end

  def drop
    if @on_ground && @wg&.platform
      @y -= 1
    end
  end

  def apply_friction
    # input
    if !@left && @dx < 0 then @dx = (@dx + FRICTION).clamp(@dx, 0) end
    if !@right && @dx > 0 then @dx = (@dx - FRICTION).clamp(0, @dx) end
  end

  def apply_physics walls, has_friction = true, check_collision = true
    # gravity
    @dy = (@dy - @gravity).clamp(-MAX_FALL_SPEED, 1000)

    # friction
    apply_friction if has_friction

    return unless check_collision

    # check collision x
    @wx = walls.find { |w|
      if w.platform then next end
      Utils.overlaps? ({ x: w.x - w.w / 2, y: w.y - w.h / 2, w: w.w, h: w.h}), (crect @x + @dx, @y)
    }
    if @wx
      if @dx >  0
        @x = @wx.x - @wx.w / 2 - @cxo - @cw / 2
      else
        @x = @wx.x + @wx.w / 2 - @cxo + @cw / 2
      end
      @dx = 0
    end

    # check collision y
    @wy = walls.find { |w|
      # check platform, should only collide if we are above the platform and dy < 0
      next if w.platform && (@dy >= 0 || @y + @cyo - @ch / 2 < w.y + w.h / 2)
      Utils.overlaps? ({ x: w.x - w.w / 2, y: w.y - w.h / 2, w: w.w, h: w.h}), (crect @x, @y + @dy)
    }
    @on_ground = false
    if @wy
      if @dy > 0
        @y = @wy.y - @wy.h / 2 - @cyo - @ch / 2
      else
        @y = @wy.y + @wy.h / 2 - @cyo + @ch / 2
        @wg = @wy
        @on_ground = true
      end
      @dy = 0
    else
      @wg = nil
    end
  end

  def render_debug args, cam
    cam.render_box args, @x + @cxo, @y + @cyo, @cw, @ch, 255, 0, 0, 128
  end

end