local driver = require("luasql.mysql")
local env = driver.mysql()
local Server = NetTest:addState('Server')
function Server:enterState()
  clearLoveCallbacks()
  
  print("initializing server")
  client_id = {}
  client_name = {}
  chat = {}
  online = 0
  math.randomseed( os.time() )
  function onConnect(ip, port)
    print("Connection from " .. ip)
    online = online + 1;
    client_id[ip] = math.random(10001,99999)
    print(ip .. " recieved id " .. client_id[ip])
    server:send('100002You recieved id ' .. client_id[ip], ip)
    server:send('3' .. client_id[ip], ip)
    server:send('100002' .. client_id[ip] .. ' connected')
    server:send('4' .. client_id[ip].. ip)
  end
  function onReceive(data, ip, port)
    --print(string.sub(data, 1, 1) .. " recieved")
    if(string.sub(data,1 , 1) == '2') then
      message = string.sub(data,2)
      if string.sub(message,2 ,2) ~= '-' then
        chat[#chat+1] = message
        server:send(client_id[ip] .. data)
      elseif string.sub(message,3,6) == 'name' then
        newname = string.sub(message,7)
        print(newname)
        server:send('100002' .. client_id[ip] .. ' changed name to ' .. newname)
        client_name[ip] = newname
        conn = env:connect('LUADB', 'root', 'Kolokolq11')
        query = conn:execute('INSERT INTO Users ( login ) VALUES ( "'  .. newname ..  '" );')
        print(query)
        conn:close()
        server:send('5' .. client_id[ip] .. client_name[ip])
      else server:send('100002No such command', ip)
      end
        
      message = nil
    end
    
  end
  function onDisconnect(ip, port)
    online = online - 1
  end
  server = lube.server(18025)
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
