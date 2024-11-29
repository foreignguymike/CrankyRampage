class Entity
  ACCEL = 300 / 60 / 60
	FRICTION = 300 / 60 / 60
  GRAVITY = 300 / 60 / 60
	MAX_SPEED = 70 / 60
  MAX_FALL_SPEED = 200 / 60
  JUMP = 150 / 60

  # input
  attr_accessor :left, :right, :down

  # movement
  attr_accessor :x, :y, :dx, :dy, :on_ground, :wg

  # size
  attr_reader :w, :h

  # collision
  attr_reader :cxo, :cyo, :cw, :ch

  # render
  attr_reader :remove, :a, :render_deg, :image, :hide, :hflip
	
	def initialize
    @x = @y = @dx = @dy = 0
    @a = 255
    @cxo = @cyo = @cw = @ch = 0
    @render_deg = 0
    @remove = false
    @left = @right = @down = false
    @drop = false
	end

  def set_image args, region
    @image = args.state.assets.find region
    @w = @image.tile_w
    @h = @image.tile_h
  end

  def crect x, y
    return { x: x + @cxo - @cw / 2, y: y + @cyo - @ch / 2, w: @cw, h: @ch }
  end

  def jump
    if @on_ground
      @dy = JUMP
    end
  end

  def drop
    if @on_ground && @wg&.platform
      @y -= 1
    end
  end

  def check_collision walls
    # input
    if @left then @dx = (@dx - ACCEL).clamp(-MAX_SPEED, 0) end
      if @right then @dx = (@dx + ACCEL).clamp(0, MAX_SPEED) end
      
      # gravity
      @dy = (@dy - GRAVITY).clamp(-MAX_FALL_SPEED, 1000)
      
      # friction
      if !@left && @dx < 0 then @dx = (@dx + FRICTION).clamp(@dx, 0) end
      if !@right && @dx > 0 then @dx = (@dx - FRICTION).clamp(0, @dx) end
  
      # check collision x
      @wc = walls.find { |w|
        if w.platform then next end
        Utils.overlaps? ({ x: w.x - w.w / 2, y: w.y - w.h / 2, w: w.w, h: w.h}), (crect @x + @dx, @y)
      }
      if @wc
        if @dx >  0
          @x = @wc.x - @wc.w / 2 - @cxo - @cw / 2
        else
          @x = @wc.x + @wc.w / 2 - @cxo + @cw / 2
        end
        @dx = 0
      end
  
      # check collision y
      @wc = walls.find { |w|
        # check platform, should only collide if we are above the platform and dy < 0
        next if w.platform && (@dy >= 0 || @y + @cyo - @ch / 2 < w.y + w.h / 2)
        Utils.overlaps? ({ x: w.x - w.w / 2, y: w.y - w.h / 2, w: w.w, h: w.h}), (crect @x, @y + @dy)
      }
      @on_ground = false
      if @wc
        if @dy > 0
          @y = @wc.y - @wc.h / 2 - @cyo - @ch / 2
        else
          @y = @wc.y + @wc.h / 2 - @cyo + @ch / 2
          @wg = @wc
          @on_ground = true
        end
        @dy = 0
      end
  end

  def render_debug args, cam
    cam.render_box args, @x + @cxo, @y + @cyo, @cw, @ch, 255, 0, 0, 80
  end

end