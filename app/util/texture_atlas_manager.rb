class TextureAtlasManager
  @map
  def initialize atlasFile, atlasTex
    atlasPack = $gtk.read_file atlasFile
    @map = {}
    regionName = ""
    regionBounds = { tile_x: 0, tile_y: 0, tile_w: 0, tile_h: 0 }
    atlasPack.split("\n").each_with_index { |line, i|
      next if i < 3
      if (i % 2 == 1)
        regionName = line.trim
      else
        parse = line.split(":")[1]
        c = parse.split(",")
        @map[regionName] = { path: atlasTex, tile_x: c[0].to_i, tile_y: c[1].to_i, tile_w: c[2].to_i, tile_h: c[3].to_i }
      end
    }
  end

  def find regionName
    return @map[regionName]
  end
end