class Entity
  # movement
  attr_accessor :x, :y, :dx, :dy

  # size
  attr_reader :w, :h

  # collision
  attr_reader :cw, :ch

  # render
  attr_reader :remove, :a, :render_deg, :image, :hide, :hflip
	
	def initialize
    @x = @y = @dx = @dy = 0
    @a = 255
    @cw = @ch = 0
    @render_deg = 0
    @remove = false
	end

  def set_image args, region
    @image = args.state.assets.find region
    @w = @image.tile_w
    @h = @image.tile_h
  end

  def crect x, y
    return { x: x - @cw / 2, y: y - @ch / 2, w: @cw, h: @ch }
  end

  def render_debug args, cam
    cam.render_box args, @x, @y, @cw, @ch, 255, 0, 0, 80
  end

end