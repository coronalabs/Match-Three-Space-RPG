local composer = require( "composer" )
local isSimulator = "simulator" == system.getInfo("environment")

--   _____      __            
--  / ___/___  / /___  ______ 
--  \__ \/ _ \/ __/ / / / __ \
-- ___/ /  __/ /_/ /_/ / /_/ /
--/____/\___/\__/\__,_/ .___/ 
--                   /_/      

display.setStatusBar( display.HiddenStatusBar ) -- removes status bar on iOS

 -- removes bottom bar on Android 
if system.getInfo("androidApiLevel") and (system.getInfo("androidApiLevel") < 19) then
  native.setProperty( "androidSystemUiVisibility", "lowProfile" )
 else
  native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end

-- Keep session audio
if audio.supportsSessionProperty == true then
  audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
end

--  ___      _              
-- |   \ ___| |__ _  _ __ _ 
-- | |) / -_) '_ \ || / _` |
-- |___/\___|_.__/\_,_\__, |
--                    |___/ 

-- Do not use buffer for console messages
--io.output():setvbuf("no")

if isSimulator then 

-- Show FPS
  local visualMonitor = require('com.ponywolf.visualMonitor')
  local visMon = visualMonitor:new()
  visMon.isVisible = false

-- Show/hide Physics
  local function debugKeys(event)
    local phase = event.phase
    local key = event.keyName
    if phase == "up" then
      if key == "p" then
        physics.show = not physics.show
        if physics.show then 
          physics.setDrawMode( "hybrid" ) 
        else
          physics.setDrawMode( "normal" )  
        end
      end
      if key == "f" then
        visMon.isVisible = not visMon.isVisible 
      end
    end
  end
  Runtime:addEventListener("key", debugKeys)
end

--   ___
--  / __|___ _ __  _ __  ___ ___ ___ _ _
-- | (__/ _ \ '  \| '_ \/ _ (_-</ -_) '_|
--  \___\___/_|_|_| .__/\___/__/\___|_|
--                |_|

-- Go to game screen
composer.gotoScene( "scene.menu.menu", { params = { } })
