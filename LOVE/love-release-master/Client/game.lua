--defining 'game' state
local game = Space:addState('game')

--entering 'game' state
function game:enterState()

  clearLoveCallbacks()

--this calls then data from server is recieved
  function onReceive (data)
    print("recieved " .. data .. 'from server')
  end

  print("initializing client")

--connecting to server
  client = lube.client()
--sending Handshake to server
  client:setHandshake("Hi!")
--listing callback names
  client:setCallback(onReceive)
--connting to localhost port 3557
  client:connect("127.0.0.1", 3557)
  print("initialized client")

  function love.update(dt)
--updating server every frame
    client:update(dt)
  end

  function love.draw()
  end

  function love.keypressed(k)
  end

end
