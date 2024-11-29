class Entity
  # movement
  attr_accessor :x, :y, :dx, :dy, :a

  # size
  attr_accessor :w, :h

  # collision
  attr_accessor :cw, :ch
	
	def initialize
    @x = @y = @dx = @dy = 0
    @a = 255
    @cw = @ch = 0
	end
end