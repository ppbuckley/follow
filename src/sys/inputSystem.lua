Object = require("src.utils.classic")

InputSystem = Object:extend()

function InputSystem:new()
    self.state = {
        mouseDown = false
    }
end

function InputSystem:keyPressed(key)
    print(key)
end

function InputSystem:mousePressed(x, y, button, istouch)
    print(x, y, button, istouch)
end

function InputSystem:mouseReleased()
    if self.state.heldItem then orchestrator:checkAssertions(self.state.heldItem) end
    orchestrator.events.onMouseReleased:emit()
end

function InputSystem:update()
    if self.state.mouseDown and not love.mouse.isDown(1) then self:mouseReleased() end
    self.state.mouseDown = love.mouse.isDown(1)
end