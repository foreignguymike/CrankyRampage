require 'app/constants'

class Camera
  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720
  
  attr_reader :x, :y

  attr_accessor :render_count

  def initialize
    @x = 0
    @y = 0
    @render_count = 0
    set_size SCREEN_WIDTH, SCREEN_HEIGHT
  end

  def set_size w, h
    @w = w
    @h = h
    @scale_x = SCREEN_WIDTH / w
    @scale_y = SCREEN_HEIGHT / h
  end

  def look_at x, y, ease=1
    @x += (x - (SCREEN_WIDTH / 2) / @scale_x - @x) * ease
    @y += (y - (SCREEN_HEIGHT / 2) / @scale_y - @y) * ease
  end

  def to_screen_space x, y
    [(x - @x) * @scale_x, (y - @y) * @scale_y]
  end

  def from_screen_space x, y
    [(x / @scale_x) + @x, (y / @scale_y) + @y]
  end

  def scale_w width
    width * @scale_x
  end

  def scale_h height
    height * @scale_y
  end

  def render args, objects
    Array(objects).each { |obj|
      sx, sy = to_screen_space obj.x, obj.y
      sw = scale_w obj.w
      sh = scale_h obj.h
      next unless Utils.overlaps? obj.crect, { x: @x, y: @y, w: @w, h: @h }
      hide = obj.hide || false
      alpha = obj.a || 255
      if !hide
        @render_count += 1
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
