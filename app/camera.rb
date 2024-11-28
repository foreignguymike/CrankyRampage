require 'app/constants'

class Camera
  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720
  SCALE_X = SCREEN_WIDTH.to_f / WIDTH
  SCALE_Y = SCREEN_HEIGHT.to_f / HEIGHT
  
  attr_reader :x, :y
  def x=v
    @x = v - (SCREEN_WIDTH / 2) / SCALE_X
  end
  def y=v
    @y = v
  end

  def initialize
    @x = 0
    @y = 0
  end

  def to_screen_space x, y
    [(x - @x) * SCALE_X, (y - @y) * SCALE_Y]
  end

  def from_screen_space x, y
    [(x / SCALE_X) + @x, (y / SCALE_Y) + @y]
  end

  def scale_w width
    width * SCALE_X
  end

  def scale_h height
    height * SCALE_Y
  end

  def render objects
    Array(objects).each do |obj|
      screen_x, screen_y = to_screen_space obj.x, obj.y
      screen_w = scale_w obj.w
      screen_h = scale_h obj.h
      hide = obj.hide
      alpha = obj.a || 255
      if !hide
        $args.outputs.sprites << {
          x: screen_x,
          y: screen_y,
          w: screen_w,
          h: screen_h,
          **obj.image,
          anchor_x: 0.5,
          anchor_y: 0.5,
          a: alpha
        }
      end
    end
  end
end
