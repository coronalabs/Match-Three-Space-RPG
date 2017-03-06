-- Requirements
local composer = require "composer"
local fx = require "com.ponywolf.ponyfx"
local fpp = require "scene.game.lib.fpp"
local threeMatch = require "scene.game.lib.threeMatch"
local monster = require "scene.game.lib.monster"
local item = require "scene.game.lib.item"
local scoring = require "scene.game.lib.score"
local hearts = require "scene.game.lib.heartBar"

-- Variables local to scene
local scene = composer.newScene()
local hallway, board, score, alien, crate, heart, sounds


function scene:create( event )
  local sceneGroup = self.view -- add display objects to this group

  -- sounds
  local sndDir = "scene/game/sfx/"
  sounds = {
    alien = audio.loadSound( sndDir .. "alien.mp3" ),
    beep = audio.loadSound( sndDir .. "beep.mp3" ),
    hit = audio.loadSound(  sndDir .. "hit.mp3" ),
    key = audio.loadSound(  sndDir .. "key.mp3" ),
    metal = audio.loadSound( sndDir .. "metal.mp3" ),    
    laser = audio.loadSound( sndDir .. "laser.mp3" ),
    beep = audio.loadSound( sndDir .. "select.mp3" ),
    horror = audio.loadSound( sndDir .. "loops/horrorloop.mp3"  ),
    wind = audio.loadSound( sndDir .. "loops/spacewind.mp3" ),
  }

  -- new level creation
  local function nextLevel()
    local x,y = hallway.x,hallway.y
    hallway:exit()
    hallway = fpp.new()
    scene.view:insert(hallway)
    hallway.x, hallway.y = x,y

    -- add an item or enemy
    local rnd = math.random(3)
    if rnd == 1 then 
      alien = monster.new() 
      alien.x, alien.y = x, y
      sceneGroup:insert(alien)  
      alien:toBack()
    elseif rnd == 2 then
      crate = item.new() 
      crate.x, crate.y = x, y
      sceneGroup:insert(crate)  
      crate:toBack()
    else
      -- no item
    end

    hallway:toBack()
    hallway:show()
  end

  -- match actions
  local function matched(event)
    local phase, count, image = event.phase, event.count, event.image

    -- let's get matching
    if phase == "matched" then
      if image == "" then 
      elseif image == "spaceKey.png" and not hallway.moving and not (alien and alien.isAlive) then
        score:add(1500)
        audio.play(sounds.key)
        -- I collected the key before the crate, so abandon crate
        if crate and crate.collect then
          crate:explode()
        end      
        nextLevel()      
      elseif image == "spaceGlove.png" or image == "spaceGun.png" then
        audio.play(sounds.laser)
        if alien and alien.hurt then 
          audio.play(sounds.hit)                 
          alien:hurt()
          score:add(500)
        end
      elseif image == "spaceMonster.png" then
        if alien and alien.isAlive then
          audio.play(sounds.hit)        
          hallway:shake()
          fx.screenFlash({1,0,0})
          if heart:damage(1) == 0 then
            composer.gotoScene("scene.gameover", { effect = "slideDown" })
          end
        else
          audio.play(sounds.alien)        
        end
      elseif image == "spaceCrate.png" and crate and crate.collect then
        audio.play(sounds.beep)
        crate:collect()
        score:add(1000)
      else
        score:add(50)
      end
    end
  end

  -- create a new First Person Perspective
  hallway = fpp.new() 
  hallway.x = display.contentCenterX

  -- create a new threeMatch  
  board = threeMatch.new(matched, { rows = 5 } )
  board.x = display.contentCenterX
  board.y = display.contentHeight - (board.contentHeight / 2) - display.screenOriginY - 16

  -- place the hallway half way up from the 
  hallway.y = (display.screenOriginY + board.contentBounds.yMin) / 2  

  -- black out bottom of screen
  local mask = display.newRect(sceneGroup, board.x, board.y + 32, display.actualContentWidth, board.contentHeight + 96)
  mask:setFillColor(0,0,0)

  -- add our scoring module
  local credits = display.newImageRect(sceneGroup, "scene/game/img/credit.png", 96,96 )  
  credits.x = display.contentWidth - credits.contentWidth / 2 - 8
  credits.y = display.screenOriginY + credits.contentHeight / 2 + 8

  score = scoring.new()
  score.x = display.contentWidth - score.contentWidth / 2 - 16 - credits.width
  score.y = display.screenOriginY + score.contentHeight / 2 + 16

  -- add our hearts module
  heart = hearts.new()
  heart.x = 32
  heart.y = display.screenOriginY + heart.contentHeight / 2 + 8  

  -- insert our game items in the right order
  sceneGroup:insert(hallway)
  sceneGroup:insert(mask)
  sceneGroup:insert(board)
  sceneGroup:insert(score)
  sceneGroup:insert(credits)
  sceneGroup:insert(heart)

end

local function enterFrame(event)
  local elapsed = event.time

end

function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then
    Runtime:addEventListener("enterFrame", enterFrame)
  elseif ( phase == "did" ) then
    audio.play(sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then
    audio.fadeOut( { time = 1000 })
  elseif ( phase == "did" ) then
    Runtime:removeEventListener("enterFrame", enterFrame)  
  end
end

function scene:destroy( event )
  audio.stop()
  for s,v in pairs( sounds ) do
    audio.dispose( v )
    sounds[s] = nil
  end
end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene