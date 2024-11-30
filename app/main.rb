require 'app/camera'
require 'app/constants'
require 'app/screen/screen_manager'
require 'app/screen/screen'
require 'app/screen/test_screen'
require 'app/util/utils'
require 'app/util/texture_atlas_manager'
require 'app/util/animation'
require 'app/entity/entity'
require 'app/entity/cursor'
require 'app/entity/player'
require 'app/entity/bullet'
require 'app/entity/particle'
require 'app/tiled/tiled_map'

def setup_game args
  return if Kernel.tick_count != 0
  args.state.debug = false
  args.state.assets ||= TextureAtlasManager.new "assets/pack.atlas", "assets/pack.png"
  args.state.sm = ScreenManager.new
  args.state.sm.push TestScreen.new
end

def tick args
  setup_game args

  if args.inputs.keyboard.key_down.f1
    args.state.debug = !args.state.debug
  end

  # tick screen
  args.outputs[:fbo].w = WIDTH
  args.outputs[:fbo].h = HEIGHT
  args.state.sm.tick args

  # render fbo
  args.outputs.sprites << { x: 0, y: 0, w: args.grid.w / 2, h: args.grid.h, path: :fbo }

end