class TextureAtlasManager
  @map
  def initialize atlas_file, atlas_tex
    atlas_pack = $gtk.read_file atlas_file
    @map = {}
    region_name = ""
    region_bounds = { tile_x: 0, tile_y: 0, tile_w: 0, tile_h: 0 }
    atlas_pack.split("\n").each_with_index { |line, i|
      next if i < 3
      if (i % 2 == 1)
        region_name = line.trim
      else
        parse = line.split(":")[1]
        c = parse.split(",")
        @map[region_name] = { path: atlas_tex, tile_x: c[0].to_i, tile_y: c[1].to_i, tile_w: c[2].to_i, tile_h: c[3].to_i }
      end
    }
  end

  def find region_name
    return @map[region_name]
  end

  def find_index region_name, i, w
    region = @map[region_name]
    tx = region.tile_x
    return { **@map[region_name], tile_x: tx + i * w, tile_w: w }
  end
end