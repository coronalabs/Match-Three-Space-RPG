
-- Project: Joystick 0.3
--
-- Date: Mar 3, 2015
-- Updated: Apr 14, 2015

local M = {}
M.buttons = {}

local stage = display.getCurrentStage()

function M.newButton(radius, onPress, key, code)

  local buttonGroup = display.newGroup()

  local button 
  if type(radius) == "number" then
    button = display.newCircle( buttonGroup, 0,0, radius )
    button:setFillColor( 0.2, 0.2, 0.2, 0.9 )  
  else
    button = display.newImage( buttonGroup, radius, 0,0 )
  end
  buttonGroup.button = button

  function button:touch(event)
    local phase = event.phase
    if phase=="began" then
      if event.id then stage:setFocus(event.target, event.id) end
      button.xScale, button.yScale = 0.95, 0.95
      if onPress then
        onPress({phase = "down", key = key or "none"})
      end
    elseif phase=="ended" then
      if event.id then stage:setFocus(nil, event.id) end
      button.xScale, button.yScale = 1, 1
      if onPress then
        onPress({phase = "up", key = key or "none"})
      end
    end
    return true
  end

  function buttonGroup:activate()
    self:addEventListener("touch", self.button )
  end

  function buttonGroup:deactivate()
    self:removeEventListener("touch", self.button )
  end

  if key then M.buttons[key] = button end
  if code then M.buttons[code] = button end
  return buttonGroup
end

function M.newStick( innerRadius, outerRadius )
  local joystickGroup = display.newGroup()

  local outerArea 
  if type(outerRadius) == "number" then
    outerArea = display.newCircle( joystickGroup, 0,0, outerRadius )
    outerArea:setFillColor( 0.2, 0.2, 0.2, 0.9 )
  else
    outerArea = display.newImage( joystickGroup, outerRadius, 0,0 )
    outerRadius = (outerArea.contentWidth + outerArea.contentHeight) * 0.25
  end

  local radToDeg = 57.29578
  local degToRad = 0.0174533
  local joystick 
  
  if type(innerRadius) == "number" then
    joystick = display.newCircle( joystickGroup, 0,0, innerRadius )
    joystick:setFillColor( 0.4, 0.4, 0.4, 0.9 )
  else
    joystick = display.newImage( joystickGroup, innerRadius, 0,0 )
    innerRadius = (joystick.contentWidth + joystick.contentHeight) * 0.25
  end  


  -- for easy reference later
  joystickGroup.joystick = joystick

  -- where should joystick motion be stopped?
  local stopRadius = outerRadius - innerRadius

  -- store angle, distance
  local angle = 0
  local distance = 0
  joystickGroup.angle = angle
  joystickGroup.distance = distance

  function joystickGroup.getAngle()
    return angle
  end
  function joystickGroup.getDistance()
    return distance/stopRadius
  end

  function joystick:touch(event)
    local phase = event.phase
    if phase=="began" or (phase=="moved" and self.isFocus) then
      if( phase == "began" ) then
        stage:setFocus(event.target, event.id)
        self.eventID = event.id
        self.isFocus = true
      end
      local parent = self.parent
      local posX, posY = parent:contentToLocal(event.x, event.y)
      angle = -math.atan2( posY, posX )*radToDeg
      angle = angle % 360
      distance = math.sqrt((posX*posX)+(posY*posY))

      if( distance >= stopRadius ) then
        distance = stopRadius
        local radAngle = angle*degToRad
        self.x = distance*math.cos(radAngle)
        self.y = -distance*math.sin(radAngle)
      else
        self.x = posX
        self.y = posY
      end
    else
      self.x = 0
      self.y = 0
      stage:setFocus(nil, event.id)
      angle = 0
      distance = 0
      self.isFocus = false
    end
    joystickGroup.dx = self.x
    joystickGroup.dy = self.y
    return true
  end

  function joystickGroup:activate()
    self:addEventListener("touch", self.joystick )
    Runtime:addEventListener( "key", M.onKeyEvent )
    self.directionId = 0
    self.angle = 0
    self.distance = 0
    self.dx = 0
    self.dy = 0
  end

  function joystickGroup:deactivate()
    stage:setFocus(nil, joystick.eventID)
    joystick.x, joystick.y = outerArea.x, outerArea.y
    self:removeEventListener("touch", self.joystick )
    Runtime:removeEventListener( "key", M.onKeyEvent )
    self.directionId = 0
    self.angle = 0
    self.distance = 0
    angle, distance = 0, 0
    self.dx = 0
    self.dy = 0
  end

  function M.onKeyEvent( event )
    local name = event.keyName
    local phase = event.phase
    local code = event.nativeKeyCode

    local dx = joystickGroup.dx or 0
    local dy = joystickGroup.dy or 0
    if phase == "down" then
      if name == "up" or code == 126 then dy = dy - outerRadius end
      if name == "down" or code == 125 then dy = dy + outerRadius  end
      if name == "left" or code == 123 then dx = dx - outerRadius end
      if name == "right" or code == 124 then dx = dx + outerRadius  end
    end
    if phase == "up" then
      if name == "up" or code == 126 then dy = dy + outerRadius end
      if name == "down" or code == 125 then dy = dy - outerRadius  end
      if name == "left" or code == 123 then dx = dx + outerRadius end
      if name == "right" or code == 124 then dx = dx - outerRadius  end
    end

    dx = math.max(-outerRadius,math.min(outerRadius,dx))
    dy = math.max(-outerRadius,math.min(outerRadius,dy))

    distance = stopRadius
    if dx == 0 and dy == 0 then distance = 0 end
    angle = -(math.atan2( dy, dx )*radToDeg)
    angle = angle % 360
    local radAngle = angle*degToRad
    joystick.x = distance*math.cos(radAngle)
    joystick.y = -distance*math.sin(radAngle)
    joystickGroup.dx = dx
    joystickGroup.dy = dy

    if name then
      if M.buttons[name] then
        if phase == "down" then
          M.buttons[name]:touch({phase="began"})
        elseif phase == "up" then
          M.buttons[name]:touch({phase="ended"})
        end
      end
    end

    if code then
      if M.buttons[code] then
        if phase == "down" then
          M.buttons[code]:touch({phase="began"})
        elseif phase == "up" then
          M.buttons[code]:touch({phase="ended"})
        end
      end
    end

    return false
  end

  return joystickGroup
end

return M
