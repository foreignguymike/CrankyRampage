require 'app/constants'

class Camera
  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720
  SCALE_X = SCREEN_WIDTH.to_f / WIDTH
  SCALE_Y = SCREEN_HEIGHT.to_f / HEIGHT
  
  attr_reader :x, :y

  def initialize
    @x = 0
    @y = 0
  end

  def look_at x, y, ease=1
    @x += (x - (SCREEN_WIDTH / 2) / SCALE_X - @x) * ease
    @y += (y - (SCREEN_HEIGHT / 2) / SCALE_Y - @y) * ease
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

  def render args, objects
    Array(objects).each { |obj|
      sx, sy = to_screen_space obj.x, obj.y
      sw = scale_w obj.w
      sh = scale_h obj.h
      hide = obj.hide || false
      alpha = obj.a || 255
      if !hide
        args.outputs.sprites << {
          x: sx - sw / 2,
          y: sy - sh / 2,
          w: sw,
          h: sh,
          **obj.image,
          flip_horizontally: obj.hflip,
          a: alpha,
          angle: obj.render_deg,
          blendmode_enum: obj.flash ? 2 : 1
        }
      end
    }
  end

  def render_image args, image, x, y, w, h
    sx, sy = to_screen_space x, y
    sw = scale_w w
    sh = scale_h h
    args.outputs.sprites << {
      x: sx - sw / 2,
      y: sy - sh / 2,
      w: sw,
      h: sh,
      **image
    }
  end

  def render_tile args, tileset, row, col, size, tile_row, tile_col, e
    sx, sy = to_screen_space col * size, row * size
    ss = scale_w size
    args.outputs.sprites << {
      x: sx.round,
      y: sy.round,
      w: ss + 1, # the + 1 is an attempt to fix weird line rendering gaps
      h: ss + 1,
      path: tileset,
      tile_x: tile_col * size,
      tile_y: tile_row * size,
      tile_w: size,
      tile_h: size
    }
  end

  def render_box args, x, y, w, h, r, g, b, a = 255
    sx, sy = to_screen_space x, y
    sw = scale_w w
    sh = scale_h h
    args.outputs.sprites << {
      x: sx - sw / 2,
      y: sy - sh / 2,
      w: sw,
      h: sh,
      **(args.state.assets.find "pixel"),
      r: r,
      g: g,
      b: b,
      a: a
    }
  end

  def render_text args, text, font, size_px, x, y, r, g, b, a = 255, v_align = 1, h_align = 0
    sx, sy = to_screen_space x, y
    px = scale_w size_px
    args.outputs.labels << { 
      x: sx,
      y: sy,
      text: text,
      font: font,
      size_px: px,
      r: r,
      g: g,
      b: b,
      vertical_alignment_enum: v_align,
      alignment_enum: h_align
    }
  end

end
