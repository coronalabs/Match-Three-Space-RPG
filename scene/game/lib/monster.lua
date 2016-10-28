-- First Person Monster Lib

local fx = require "com.ponywolf.ponyfx"
local healthBar = require "scene.game.lib.healthBar"
local M = {}

function M.new()

  local instance = display.newGroup()

  -- load monster
  instance.img = display.newImageRect(instance, "scene/game/img/obj/enemy.png", 768, 768)

  -- flip it randomly
  instance.img.xScale = math.random() < 0.5 and 1 or -1
  instance.img._xScale = instance.xScale

  -- adjust it's hue
  instance.hue = math.random(360)  
  local function tint()
    if instance and instance.img and instance.img.fill then
      instance.img.fill.effect = "filter.hue"
      instance.img.fill.effect.angle = instance.hue
    end
  end
  tint()

  instance.bar = healthBar.new()
  instance:insert(instance.bar)
  instance.bar.x, instance.bar.y = instance.img.x, instance.img.y - 284
  instance.isAlive = true

  -- make it breathe
  fx.breath(instance.img, 0.025, 750)

  function instance:hurt(ammount)
    fx.shake(self)
    fx.flash(self.img, 30, tint)
    if self.bar:damage(ammount or 0.25) == 0 then 
      self:die()
    end
  end

  function instance:die()
    if instance then 
      instance.isAlive = false
      local function remove()
        display.remove(instance)
        instance = nil
      end
      transition.to(self.img, { time = 500, yScale = 0.01, xScale = 0.01, transition = easing.outQuad, 
          onComplete = remove }
      )
    end
  end

  function instance:finalize()
    transition.cancel(self)
  end

  instance:addEventListener("finalize")
  return instance
end

return M