-- First Person Perspective Lib

local fx = require "com.ponywolf.ponyfx"
local M = {}

function M.new()
  local instance = display.newGroup()

  -- load door
  instance.door = display.newImageRect(instance, "scene/game/img/hallway/door.png", 256, 256)

  -- load background
  instance.back = display.newImageRect(instance, "scene/game/img/hallway/hallway.png", 1024, 1024)

  -- flip it randomly
  instance.back.xScale = math.random() < 0.5 and 1 or -1
  instance.back._xScale = instance.back.xScale

  -- adjust it's hue
  instance.back.fill.effect = "filter.hue"
  instance.back.fill.effect.angle = math.random(360)

  -- load the wall decor
  instance.wall = display.newImageRect(instance, "scene/game/img/hallway/wall.png", 1024, 1024)    

  function instance:show()
    local function stop()
      instance.moving = false
    end
    instance.moving = true
    transition.from(self, { time = 1500, alpha = 0, yScale = 0.5, xScale = 0.5, transition = easing.outQuad, onComplete = stop } )
  end

  function instance:exit()
    local function remove()
      display.remove(instance)
    end
    instance.moving = true
    -- transtion each separatelty
    transition.to(self.door, { time = 1500, y = -2048, yScale = 12, xScale = 12, transition = easing.inQuad } )
    transition.to(self.back, { time = 1500, yScale = 12, xScale = 12 * self.back._xScale, transition = easing.inQuad } )
    transition.to(self.wall, { time = 1500, yScale = 12, xScale = 12, transition = easing.inQuad, 
        onComplete = remove }
    )
  end

  function instance:shake()
    -- use the fx module to shake the pieces
    fx.shake(self.wall)
    fx.shake(self.door)
    fx.shake(self.back)
  end

  function instance:finalize()
    transition.cancel(self)
  end

  instance:addEventListener("finalize")
  return instance
end

return M