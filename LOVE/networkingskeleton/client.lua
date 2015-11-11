
local Client = NetTest:addState('Client')
function Client:enterState()
  clearLoveCallbacks()
  
  print("initializing client")
  function onReceive(data)
    
  end
  client = lube.client()
  client:setHandshake("Hi!")
  client:setCallback(onReceive)
  client:connect("127.0.0.1", 3557)
  print("initialized client")
  
  function love.update(dt)
    client:update(dt)
  end
  function love.draw()
  end
  function love.keypressed(k)
    if k=='escape' then
      netTest:gotoState('Menu')
    end
  end
end
function Client:exitState()
  print("Exiting client")
end
