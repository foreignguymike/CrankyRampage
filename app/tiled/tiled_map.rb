class TiledMap

  attr_accessor :map_width, :map_height
  attr_accessor :walls

  def initialize tmx_file
    @walls = []

    tmx_dir = File.dirname tmx_file

    tmx = $gtk.parse_xml_file tmx_file
    data = tmx[:children].first

    data[:children].each { |c|
      case c[:name]
      when 'layer'
        map = c[:children].first[:children].first[:data]
        @map = Utils.parse_2d_array map
        @map_cols = c[:attributes]["width"].to_i
        @map_rows = c[:attributes]["height"].to_i
        @map_width = @map_cols * @tile_size
        @map_height = @map_rows * @tile_size
      when 'objectgroup'
        name = c[:attributes]["name"]
        c[:children].each { |wall|
          w = wall[:attributes]
          x = w["x"].to_i
          y = w["y"].to_i
          width = w["width"].to_i
          height = w["height"].to_i
          @walls << { **(Utils.center_rect x, @map_height - y - height, width, height), platform: name == "platforms" }
        }
      when 'tileset'
        tileset_source_file = c[:attributes]["source"]
        tsx = $gtk.parse_xml_file File.join tmx_dir, tileset_source_file

        tile_attributes = tsx[:children].first[:attributes]
        @tile_size = tile_attributes["tilewidth"].to_i
        @tile_count = tile_attributes["tilecount"].to_i
        @tile_cols = tile_attributes["columns"].to_i

        @tileset_image_file = File.join tmx_dir, tsx[:children].first[:children].first[:attributes]["source"]
      end
    }

  end

  def render args, cam
    @map.each_with_index { |row, r|
      row.each_with_index { |e, c|
        # next if e == 0
        cam.render_tile args, @tileset_image_file, @map_rows - 1 - r, c, @tile_size, ((e - 1) / @tile_cols).to_i, (e - 1) % @tile_cols, e
      }
    }
    # debug
    if (args.state.debug)
      @walls.each { |w|
        if w.platform
          cam.render_box args, w.x, w.y, w.w, 16, 0, 0, 255, 80
        else
          cam.render_box args, w.x, w.y, w.w, w.h, 255, 0, 0, 80
        end
      }
    end
  end

end