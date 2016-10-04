local composer = require( "composer" )
local isSimulator = "simulator" == system.getInfo("environment")
local platform = system.getInfo( "platformName" )

display.setStatusBar( display.HiddenStatusBar ) -- removes status bar on iOS

 -- removes bottom bar on Android 
if system.getInfo("androidApiLevel") and (system.getInfo("androidApiLevel") < 19) then
  native.setProperty( "androidSystemUiVisibility", "lowProfile" )
 else
  native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end

-- The default magnification sampling filter applied whenever an image is loaded by Corona.
-- Use "nearest" with a small content size to get a retro-pixel look
display.setDefault( "magTextureFilter", "linear" )
display.setDefault( "minTextureFilter", "linear" )

--  The default behavior for texture loading is to load the texture when the display
--  object is created or when the display object uses it. Setting this value to false
--  will delay loading of the texture to when the object appears on screen or to
--  when it becomes visible.
display.setDefault( "preloadTextures", true )

-- Texture Wrap Keys
-- Other values are useful for patterns: "repeat", "mirroredRepeat"
display.setDefault( "textureWrapX", "clampToEdge" )
display.setDefault( "textureWrapY", "clampToEdge" )

-- Uncomment to turn on wireframe
--display.setDrawMode( "wireframe", true )

-- Set default anchor point
display.setDefault( "anchorX", 0.5 )
display.setDefault( "anchorY", 0.5 )

-- Set background color 
display.setDefault( "background", 0/255, 0/255, 0/255)

-- Remove mouse pointer
--native.setProperty( "mouseCursorVisible", false )

-- Keep session audio
if audio.supportsSessionProperty == true then
  audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
end

-- Add multitouch
--system.activate( "multitouch" )

-- Randomize
math.randomseed( os.time() ) 

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
composer.gotoScene( "scene.game.game", { params = { } })
