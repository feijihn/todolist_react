
--creating state 'server_control'
local server_control = Space:addState('server_control')

--enetering server_control state
function server_control:enterState()

--when some1 connect this function calls
  function onConnect (ip, port)
    print("connection from " .. ip)
  end

--when data recieved this function calls
  function onReceive (data, ip, port)
    print("recieved " .. data)
  end

--when some1 disconnect this function calls
  function onDisconnect(ip, port)
    print(ip .. "disconnected")
  end

--turning on server 'listening'
  clearLoveCallbacks()
  print("initializing server")
--listening on port '3557'
  serv = lube.server(3557)
--listing callback names
  serv:setCallback(onReceive, onConnect, onDisconnect)
--setting handshake
  serv:setHandshake("Hi!")
  print("initialized server")

  function love.update(dt)
--updating server every frame
      serv:update(dt)
  end

end
