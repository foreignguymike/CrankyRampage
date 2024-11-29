require 'app/util/texture_atlas_manager'

module Utils
  def self.clearScreen(args, r, g, b, a)
    args.outputs.sprites << {
      x: 0,
      y: 0,
      w: args.grid.w,
      h: args.grid.h,
      **($args.state.assets.find "pixel"),
      r: r,
      g: g,
      b: b,
      a: a
    }
  end

  def require_all(dir)
    Dir[File.dirname(__dir__, dir, "*.rb")].each { |file| require file }
  end

end