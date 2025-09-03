Object = require("src.utils.classic")

InputSystem = Object:extend()

function InputSystem:new()
    self.state = {
        mouseDown = {}
    }
end

function InputSystem:keyPressed(key)
    if love.keyboard.isDown("lgui") and key == "`" then
        orchestrator.ui:toggleDebugTool()
    end
end

function InputSystem:mousePressed(x, y, button, istouch)
    local clickables = db.queries.clickable

    for clickable in pairs(clickables) do
        if utils.pointInsideBox({x = x, y = y}, db.components.clickBounds[clickable]) and orchestrator.ui.enabled then
            if db.components.uiComponent[clickable] == "slider" then
                self.state.mouseDown[clickable] = true
            else
                db.components.clickHandler[clickable](love.mouse.getPosition())    
            end
        end
    end
end

function InputSystem:mouseReleased()
    self.state.mouseDown = {}
    orchestrator.events.onMouseReleased:emit()
end

function InputSystem:update()
    if #utils.getKeys(self.state.mouseDown) > 0 and not love.mouse.isDown(1) then self:mouseReleased() end
    if love.mouse.isDown(1) then
        for held in pairs(self.state.mouseDown) do
            db.components.clickHandler[held](love.mouse.getPosition())
        end
    end
end