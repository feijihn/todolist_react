local utf8 = require("utf8")
local Client = NetTest:addState('Client')
function Client:enterState()
  clearLoveCallbacks()
  message = ""
  chat = {}
  client_id = {}
  client_name = {}
  input_line = 0
  id = 0
  client_name[id] = 'noname'
  Font = love.graphics.getFont()
  print("initializing client")

  
  function onReceive(data)
   if(string.sub(data, 6, 6) == '2') then
     message = string.sub(data, 7)
     sender = string.sub(data,1,5)
     if sender == '10000' then
      chat[#chat+1] = "System message : " .. message
     elseif client_name[sender] == nil then
      chat[#chat+1] = sender .. " : " .. message
     else
      chat[#chat+1] = client_name[sender] .. " : " .. message
     end
     message = ""
   end
   if(string.sub(data, 1, 1) == '3') then
     id = string.sub(data, 2)
     client_name[id] = 'noname'
   end
   if(string.sub(data, 1, 1) == '4') then
     client_id[string.sub(data,7)] = string.sub(data, 2 , 6)
   end
   if(string.sub(data, 1, 1) == '5') then
     client_name[string.sub(data,2,6)] = string.sub(data, 7)
   end
   
  end
  client = lube.client()
  client:setHandshake("Hi!")
  client:setCallback(onReceive)
  client:connect("127.0.0.1", 18025)
  print("initialized client")
  
  function love.textinput(t)
    if input_line == 1 then
      message = message .. t
    end
  end
  
  function love.update(dt)
    client:update(dt)
  end
  function love.draw()
      love.graphics.printf("Hello, " .. client_name[id] ..  " , your id " .. id,0 ,0 , love.graphics.getWidth())
    if input_line == 1 then
      love.graphics.printf(string.sub(message,2),0,8+(#chat+1)*Font:getHeight( ),love.graphics.getWidth())
      love.graphics.printf('|',Font:getWidth(message)+2,8+(#chat+1)*Font:getHeight( ),love.graphics.getWidth())
    end
    for i = 1, #chat do
      love.graphics.printf(chat[i], 0, 8+i*Font:getHeight( ), love.graphics.getWidth())
    end
  end
  function love.keypressed(k)
    if k=='escape' then
      netTest:gotoState('Menu')
    end
    if k == 'y' and input_line == 0 then
      input_line = 1
    end
    if k == 'return' and input_line == 1 then
      client:send('2 ' .. string.sub(message,2))
      input_line = 0
      message = ""
    end
    if k == "backspace" then
        local byteoffset = utf8.offset(message, -1)
        if byteoffset then
            message = string.sub(message, 1, byteoffset - 1)
        end
    end
  end
function Client:exitState()
  print("Exiting client")
end
end


