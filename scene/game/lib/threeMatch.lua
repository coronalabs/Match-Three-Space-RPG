-- three match module

local M = {}

local function pointInBounds(x, y, object)
  local bounds = object.contentBounds
  if not bounds then return false end
  if x > bounds.xMin and x < bounds.xMax and y > bounds.yMin and y < bounds.yMax then
    return true 
  else 
    return false
  end
end

local abs = math.abs
local random = math.random

function M.new(listener, options)
  -- make a new three match board
  options = options or {}

  local rows = options.rows or 5
  local cols = options.cols or 6
  local width = options.width or (display.actualContentWidth / cols) - 6
  local height = options.height or width
  local colors = options.colors or { {1,0,0}, {1,1,0}, {0,0,1}, {1,0,1}, {0,1,1}, {0,1,0} }
  local subDir = options.subDir or "scene/game/img/tokens/"
  local boardImage = options.boardImage or "darkCrate.png"
  local images = options.images or { "spaceCrate.png", "spaceMonster.png", "spaceKey.png", "spaceGlove.png", "spaceGun.png" }
  local imageWidth = options.imageWidth or width * 0.95
  local imageHeight = options.imageHeight or height * 0.95 
  local paused = options.paused or false
  local onStatus = listener

  -- our board dsiplay object
  local board = display.newGroup()
  board.anchorChildren = true
  board.status = "init"

  -- store our timers
  board.timer = {}

  if paused then board.status = "paused" end
  function board:play()
    paused = false
    board.status = "idle"    
    board:replunish()    
    board:recycle()
  end 

  function board:pause()
    paused = true
    board.status = "paused"    
  end  

  function board:updateStatus(count, index, points)
    if onStatus then
      onStatus({ phase = board.status, count = count, index = index, image = images and images[index], points = points } )
    else
      -- print it if you want
    end
  end
  board:updateStatus()

  function board:newSquare(r,c)
    if board.space == nil then
      board.space = {}
    end
    local spaces = board.space
    -- function that draws an empty square
    local nextSpace = #spaces+1
    if boardImage then
      spaces[nextSpace] = display.newImageRect(self, subDir .. boardImage, width, height)
      spaces[nextSpace].x, spaces[nextSpace].y = c*width + c, r*height + r
    else
      spaces[nextSpace] = display.newRoundedRect(self, c*width + c, r*height + r, width-2, height-2, width * 0.10)
      spaces[nextSpace].alpha = 0.25    
    end
    --spaces[nextSpace]:translate(-width * 0.5, -height * 0.5)  
  end

  -- make the empty board
  for i = 1, rows do
    for j = 1, cols do
      board:newSquare(i,j)
    end
  end

  function board:newPiece(r,c)
    if not board.removeSelf then return false end
    if board.piece == nil then
      board.piece = {}
    end
    local pieces = board.piece
    -- function that builds a new game piece    
    local nextPiece = #pieces+1

    if images then
      local index = random(#images)
      pieces[nextPiece] = display.newImageRect(self, subDir .. images[index], imageWidth, imageHeight)
      pieces[nextPiece].x, pieces[nextPiece] .y = c*width + c, r*height + r
      pieces[nextPiece].index = index
    else
      pieces[nextPiece] = display.newCircle(self, c*width + c, r*height + r, width * 0.45)
      pieces[nextPiece].index = random(#colors)
      local index = pieces[nextPiece].index
      pieces[nextPiece]:setFillColor(colors[index][1],colors[index][2],colors[index][3])    
    end
    -- make a local copy
    local currentPiece = pieces[nextPiece]    
    currentPiece.id = nextPiece
    currentPiece.r,currentPiece.c = r,c

    --currentPiece:translate(-width * 0.5, -height * 0.5)
    transition.from( currentPiece, { time = 233, xScale = 0.001, yScale = 0.01, transition=easing.outBounce } )

    -- touch listener function
    function currentPiece:touch( event )
      if not self.moving and board.status == "idle" and event.phase == "began" then
        -- first we set the focus on the object
        display.getCurrentStage():setFocus( self, event.id )
        self:toFront()
        self.isFocus = true
        self.isMoving = true

        -- then we store the original x and y position
        self.markX = self.x
        self.markY = self.y

        board.status = "swapping"
        board:updateStatus()

        transition.to (self, { tag="board", time=100, xScale = 1.2, yScale = 1.2, transition=easing.outQuad } )

      elseif self.isFocus then

        if event.phase == "moved" then

          local dx, dy = abs(event.x - event.xStart), abs(event.y - event.yStart)
          local lr, ud = false, false

          if dx > 16 or dy > 16 then 
            if dx > dy then lr = true end 
            if dy > dx then ud = true end 
          end

          -- then drag our object
          self.x = event.x - event.xStart + self.markX
          self.y = event.y - event.yStart + self.markY

          -- keep it lr/ud
          if ud then self.x = self.markX end
          if lr then self.y = self.markY end

          -- only allow moving a single space
          if self.x < self.markX - width then self.x = self.markX - width end
          if self.x > self.markX + width then self.x = self.markX + width end
          if self.y < self.markY - height then self.y = self.markY - height end
          if self.y > self.markY + height then self.y = self.markY + height end

        elseif event.phase == "ended" or event.phase == "cancelled" then

          -- is there a new piece under where we let go?
          local lx = (self.contentBounds.xMin + self.contentBounds.xMax) * 0.5
          local ly = (self.contentBounds.yMin + self.contentBounds.yMax) * 0.5          
          local pieceToSwap = board:findPiece(lx,ly,self.id)

          -- keep from double touches
          local function checkMatches()
            if pieceToSwap then pieceToSwap.moving = false end
            self.moving = false 
            board:cull()              
          end

          local function noMove()
            self.moving = false
            board.status = "idle"
            board:updateStatus()
          end

          if pieceToSwap then
            -- keep from double touches
            pieceToSwap.moving = true

            -- swap row and column
            pieceToSwap.r, self.r = self.r, pieceToSwap.r
            pieceToSwap.c, self.c = self.c, pieceToSwap.c

            transition.to(self, { tag="board", time = 500, xScale = 1, yScale = 1, x = pieceToSwap.x, y = pieceToSwap.y, transition = easing.outBounce, onComplete = checkMatches } )
            transition.to(pieceToSwap, { tag="board", time = 500, x = self.markX, y = self.markY, transition = easing.outBounce } )              
          else           
            transition.to(self, { tag="board", time = 333, xScale = 1, yScale = 1, x = self.markX, y = self.markY, transition = easing.outBounce, onComplete = noMove }  )     
          end
          -- we end the movement by removing the focus from the object
          display.getCurrentStage():setFocus( self, nil )
          self.isFocus = false      
        end
      end
      -- return true so Corona knows that the touch event was handled propertly
      return true
    end

    -- finally, add an event listener to our circle to allow it to be dragged
    currentPiece:addEventListener( "touch" )

  end

  function board:findPiece(x,y,id)
    if not board.removeSelf then return false end    
    -- find a piece at a screen x,y
    local pieces = board.piece
    id = id or -1
    if pieces == nil then return false end
    for i = #pieces, 1, -1 do
      if pointInBounds(x,y,pieces[i]) and i ~= id then
        return pieces[i]
      end
    end
    return false
  end

  function board:getPiece(r,c)
    if not board.removeSelf then return false end    
    -- get a piece at a board r,c
    local pieces = board.piece
    if pieces == nil then return false end
    for i = #pieces,1,-1 do
      if pieces[i] and pieces[i].r == r and pieces[i].c == c then
        return pieces[i]
      end
    end
    return false    
  end

  function board:dump()
    --dump board
    for i = 1, rows do
      local output = ""
      for j = 1, cols do
        output = output .. (board:getPiece(i,j) and board:getPiece(i,j).index or ".")
      end
      print (output)
    end
  end

  function board:cull()
    if not board.removeSelf then return false end 
    if paused then return false end        
    local pieces = board.piece
    if pieces == nil then return false end
    local cull = false
    board.status = "matching"
    board:updateStatus()

    --match rows
    for i = 1, rows do
      local matches = 0
      for j = 1, cols-1 do
        if board:getPiece(i,j).index == board:getPiece(i,j+1).index then
          matches = matches + 1          
          if matches > 1 then
            board.status = "matched"             
            local points = {}
            for k = 1, matches+1 do
              local piece = board:getPiece(i,j+2-k)
              piece.cull = true
              cull = true
              points[k] = {}
              points[k].x, points[k].y = piece:localToContent(0,0)
            end
            board:updateStatus(matches+1, board:getPiece(i,j).index, points)    
          end
        else 
          matches = 0
        end
      end
    end

    --match cols
    for j = 1, cols do
      local matches = 0
      for i = 1, rows-1 do
        if board:getPiece(i,j).index == board:getPiece(i+1,j).index then
          matches = matches + 1          
          if matches > 1 then
            board.status = "matched"
            local points = {}
            for k = 1, matches+1 do
              local piece = board:getPiece(i+2-k,j)
              piece.cull = true
              cull = true
              points[k] = {}
              points[k].x, points[k].y = piece:localToContent(0,0)
            end
            board:updateStatus(matches+1, board:getPiece(i,j).index, points)                
          end
        else 
          matches = 0
        end
      end
    end

    if cull then
      board.status = "culling"
      board:updateStatus()      
      local pieces = board.piece
      if pieces == nil then return false end
      for i = #pieces, 1, -1 do
        if pieces[i].cull then
          transition.to (pieces[i], { tag="board", time = 233, xScale = 0.001, yScale = 0.001, transition=easing.outExpo })
        end
      end
      board.timer[#board.timer+1] = timer.performWithDelay(250, function () board:drop("down") end)
    else
      board.status = "idle"
      board:updateStatus()
    end
  end

  function board:recycle()
    if not board.removeSelf then return false end    
    -- object cleanup
    local pieces = board.piece
    if pieces == nil then return false end

    -- compact table
    for i = #pieces,1,-1 do
      if pieces[i].cull then
        display.remove(pieces[i])
        table.remove(pieces,i)  
      end
    end

    -- re-id
    for i = 1, #pieces,1 do
      pieces[i].id = i
    end    
  end

  function board:drop(direction)
    if not board.removeSelf then return false end    
    board:recycle()
    board.status = "dropping"
    board:updateStatus()
    local drop = false

    -- set gravity
    direction = direction or "down"
    if direction == "down" then
      -- find gaps
      for i = rows,1,-1 do
        for j = cols,1,-1 do
          if not board:getPiece(i,j) then -- we have a gap
            if board:getPiece(i-1,j) then
              drop = true
              transition.to(board:getPiece(i-1,j), { tag="board", delta = true, time=233, y = height+1, transition=easing.outBounce } )
              board:getPiece(i-1,j).r = i
            end
          end
        end
      end
    else
      -- find gaps
      for i = 1,rows do
        for j = 1,cols do
          if not board:getPiece(i,j) then -- we have a gap
            if board:getPiece(i+1,j) then
              drop = true
              transition.to(board:getPiece(i+1,j), { tag="board", delta = true, time=233, y = -(height+1), transition=easing.outBounce } )
              board:getPiece(i+1,j).r = i
            end
          end
        end
      end
    end

    if drop then
      board.timer[#board.timer+1] = timer.performWithDelay(250, function () board:drop(direction) end )
    else
      board:replunish()
    end
  end

  function board:replunish()
    if not board.removeSelf then return false end    
    board:recycle()    
    for i = 1, rows do
      for j = 1, cols do
        if not board:getPiece(i,j) then board:newPiece(i,j) end
      end
    end
    board.timer[#board.timer+1] = timer.performWithDelay(250, function () board:cull() end )
  end

  function board:finalize()
    if not board.removeSelf then return false end    
    transition.cancel("board")
    board.status = "finalizing"
    board:updateStatus()
    -- clean up timers
    for i = #board.timer, 1, -1 do
      timer.cancel(board.timer[i])
      board.timer[i]=nil 
    end
  end
  
  board:addEventListener('finalize')

  -- add the pieces
  board:replunish()
  board:recycle()  

  return board
end

return M