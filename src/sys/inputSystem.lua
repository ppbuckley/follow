Object = require("src.utils.classic")

InputSystem = Object:extend()

function InputSystem:new()
    self.state = {
        mouseDown = {}
    }
    self.repeats = {
        clicked = {},
        down = {},
        wait = {}
    }
end

function InputSystem:keyPressed(key, skip)
    if not skip then
        self.repeats.down[key] = 0
        self.repeats.wait[key] = 0
    end

    self.repeats.clicked[key] = true
    
    if love.keyboard.isDown("lgui") and key == "`" then
        orchestrator.ui:toggleDebugTool()
    end
    
    orchestrator.events.onKeyPressed:emit(key)
end

function InputSystem:keyReleased(key)
    self.repeats.clicked[key] = false
    self.repeats.down[key] = 0
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
    for key, clicked in pairs(self.repeats.clicked) do
        if clicked then
            self.repeats.down[key] = self.repeats.down[key] + love.timer.getDelta()
            if self.repeats.down[key] > 0.5 then
                if self.repeats.wait[key] < 0.04 then
                    self.repeats.wait[key] = self.repeats.wait[key] + love.timer.getDelta()
                else
                    self:keyPressed(key, true)
                    self.repeats.wait[key] = 0
                end
            end
        end
    end

    if #utils.getKeys(self.state.mouseDown) > 0 and not love.mouse.isDown(1) then self:mouseReleased() end
    if love.mouse.isDown(1) then
        for held in pairs(self.state.mouseDown) do
            db.components.clickHandler[held](love.mouse.getPosition())
        end
    end
end