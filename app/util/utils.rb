require 'app/util/texture_atlas_manager'

module Utils
  def self.clear_screen(args, r, g, b, a)
    args.outputs.sprites << {
      x: 0,
      y: 0,
      w: args.grid.w,
      h: args.grid.h,
      **(args.state.assets.find "pixel"),
      r: r,
      g: g,
      b: b,
      a: a
    }
  end

  def self.overlaps? r1, r2
    # Check if one rectangle is to the left of the other
    return false if r1[:x] + r1[:w] <= r2[:x] || r2[:x] + r2[:w] <= r1[:x]

    # Check if one rectangle is above the other
    return false if r1[:y] + r1[:h] <= r2[:y] || r2[:y] + r2[:h] <= r1[:y]

    # If neither is true, the rectangles overlap
    true
  end

  def self.center_rect x, y, w, h
    return { x: x + w / 2, y: y + h / 2, w: w, h: h }
  end

end