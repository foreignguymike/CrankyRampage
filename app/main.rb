require 'app/camera'
require 'app/constants'
require 'app/screen/screen_manager'
require 'app/screen/screen'
require 'app/screen/test_screen'
require 'app/util/utils'
require 'app/util/texture_atlas_manager'
require 'app/util/animation'
require 'app/entity/entity'
require 'app/entity/spikewheel'
require 'app/entity/gem'
require 'app/entity/cursor'
require 'app/entity/player'
require 'app/entity/bullet'
require 'app/entity/particle'
require 'app/tiled/tiled_map'
require 'app/weapons/gun'
require 'app/ui/ui'

def setup_game args, force = false
  return if !force && Kernel.tick_count != 0
  args.state.debug = false
  args.state.assets = TextureAtlasManager.new "assets/pack.atlas", "assets/pack.png"
  args.state.sm = ScreenManager.new
  args.state.sm.push TestScreen.new args
end

def tick args
  setup_game args

  if args.inputs.keyboard.key_down.f1
    args.state.debug = !args.state.debug
  end
  if args.inputs.keyboard.key_down.r
    setup_game args, true
  end

  # tick screen
  args.state.sm.tick args

end