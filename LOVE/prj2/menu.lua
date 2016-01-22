
local Menu = NetTest:addState('Menu')
function Menu:enterState()
  clearLoveCallbacks()
  menuText = "1. Server\n2. Client\n3. Exit"
  function love.draw()
    love.graphics.print(menuText, 0,0)
  end
  function love.keypressed(k,u)
    if k=='1' then
      netTest:gotoState('Server')
    elseif k=='2' then
      netTest:gotoState('Client')
    elseif k=='3' then
      love.event.push('q')
    end
  end 
end
function Menu:exitState()
  
end
