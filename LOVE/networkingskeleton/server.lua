
local Server = NetTest:addState('Server')
function Server:enterState()
  clearLoveCallbacks()
  
  print("initializing server")
  function onConnect(ip, port)
    print("Connection from " .. ip)
  end
  function onReceive(data, ip, port)
    
  end
  function onDisconnect(ip, port)
    
  end
  server = lube.server(3557)
  server:setCallback(onReceive, onConnect, onDisconnect)
  server:setHandshake("Hi!")
  print("initialized server")
  
  function love.update(dt)
    server:update(dt)
  end
  function love.draw()
  end
  function love.keypressed(k)
    if k=='escape' then
      netTest:gotoState('Menu')
    end
  end
end
function Server:exitState()
  --TODO: Server EXIT CODE
  print("Exiting server")
end
