require 'app/camera'
require 'app/constants'
require 'app/screen/screen_manager'
require 'app/screen/screen'
require 'app/screen/test_screen'
require 'app/screen/test2_screen'
require 'app/screen/shop_screen'
require 'app/util/utils'
require 'app/util/texture_atlas_manager'
require 'app/util/animation'
require 'app/entity/entity'
require 'app/entity/enemies/enemy'
require 'app/entity/enemies/yoyo'
require 'app/entity/enemies/slimer'
require 'app/entity/enemies/sneaky'
require 'app/entity/gem'
require 'app/entity/cursor'
require 'app/entity/player'
require 'app/entity/bullet'
require 'app/entity/particle'
require 'app/entity/button'
require 'app/tiled/tiled_map'
require 'app/weapons/gun'
require 'app/ui/ui'

def setup_game args, force = false
  return if !force && Kernel.tick_count != 0
  args.state.debug = false
  args.state.assets = TextureAtlasManager.new "assets/pack.atlas", "assets/pack.png"
  args.state.sm = ScreenManager.new


  # debug
  args.state.health = 3
  args.state.max_health = 3
  args.state.money = 412
  args.state.gun = "pistol"
  args.state.sm.push ShopScreen.new args, "test2"
  # args.state.sm.push TestScreen.new args
end

def tick args
  setup_game args

  if args.inputs.keyboard.key_down.f1
    args.state.debug = !args.state.debug
  end

  # tick screen
  args.state.sm.tick args

end