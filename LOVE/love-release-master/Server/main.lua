--[[
Server main. Including necessary libraries here. Initializing Space(State-handler)
]]

require "LUBE"
require "MiddleClass"
require "Stateful"
Space = class('Space'):include(Stateful)
require "server"

--Clearing all CallBacks (not rly sure why)
function clearLoveCallbacks()
  love.draw = nil
  love.joystickpressed = nil
  love.joystickreleased = nil
  love.keypressed = nil
  love.keyreleased = nil
  love.load = nil
  love.mousepressed = nil
  love.mousereleased = nil
  love.update = nil
end

--Going to state 'server_control'
function Space:initialize()
  super.initialize(self)
  self:gotoState('server_control')
end

function love.load ()
  Space = Space:new()
end
