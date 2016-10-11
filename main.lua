local composer = require( "composer" )
local isSimulator = "simulator" == system.getInfo( "environment" )

display.setStatusBar( display.HiddenStatusBar )  -- Removes status bar

-- Removes bottom bar on Android 
if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
    native.setProperty( "androidSystemUiVisibility", "lowProfile" )
else
    native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end

-- Do not use buffer for console messages
--io.output():setvbuf("no")

if isSimulator then 

    -- Show FPS
    local visualMonitor = require( "com.ponywolf.visualMonitor" )
    local visMon = visualMonitor:new()
    visMon.isVisible = false

    -- Show/hide Physics
    local function debugKeys( event )
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
            elseif key == "f" then
                visMon.isVisible = not visMon.isVisible 
            end
        end
    end
    Runtime:addEventListener( "key", debugKeys )
end

-- Go to game screen
composer.gotoScene( "scene.menu.menu", { params={} } )
