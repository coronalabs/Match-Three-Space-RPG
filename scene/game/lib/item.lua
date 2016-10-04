-- First Person Item Lib

local fx = require "com.ponywolf.ponyfx"
local healthBar = require "scene.game.lib.healthBar"
local M = {}

function M.new()

  local instance = display.newGroup()

  instance.streaks = fx.newStreak()
  instance.streaks.xScale, instance.streaks.yScale = 0.25, 0.25
  instance:insert(instance.streaks)

  -- load item
  instance.img = display.newImageRect(instance, "scene/game/img/obj/crate.png", 768, 768)

  -- flip it randomly
  instance.img.xScale = math.random() < 0.5 and 1 or -1
  instance.img._xScale = instance.xScale

  -- adjust it's hue
  instance.img.fill.effect = "filter.hue"
  instance.img.fill.effect.angle = math.random(360)

  -- make it bounce
  fx.bounce(instance.img)

  function instance:collect()
    transition.cancel(self.img)
    local function remove()
      display.remove(instance)
    end
    transition.to(self, { time = 500, yScale = 0.01, xScale = 0.01, y=display.contentHeight/2, transition = easing.outQuad, 
        onComplete = remove }
    )
  end

  function instance:explode()
    transition.cancel(self.img)
    local function remove()
      display.remove(instance)
    end
    transition.to(self, { time = 500, yScale = 3, xScale = 3, alpha = 0, transition = easing.outQuad, 
        onComplete = remove }
    )
  end

  function instance:finalize()
    transition.cancel(self)
  end

  instance:addEventListener("finalize")
  return instance
end

return M