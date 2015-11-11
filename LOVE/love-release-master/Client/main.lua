--[[
Game main. just like server one.
]]

require("LUBE")
require("MiddleClass")
require("Stateful")
Space = class('Space'):include(Stateful)
require('game')

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

--going straight to 'game' state
function Space:initialize()
  super.initialize(self)
  self:gotoState('game')
end

function love.load ()
  Space = Space:new()
end
