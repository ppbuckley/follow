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
    self.vars = {}
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

    if key == "space" then
        local id = orchestrator.sysPlayer.line
        orchestrator.sysPlayer:shiftCells(id, 1)
    end
    
    orchestrator.sysEvents.onKeyPressed:emit(key)
end

function InputSystem:keyReleased(key)
    self.repeats.clicked[key] = false
    self.repeats.down[key] = 0
end

function InputSystem:keyRepeated()
    for key, clicked in pairs(self.repeats.clicked) do
        if clicked then
            self.repeats.down[key] = self.repeats.down[key] + love.timer.getDelta()
            if self.repeats.down[key] > 0.25 then
                if self.repeats.wait[key] < 0.02 then
                    self.repeats.wait[key] = self.repeats.wait[key] + love.timer.getDelta()
                else
                    self:keyPressed(key, true)
                    self.repeats.wait[key] = 0
                end
            end
        end
    end
end

function InputSystem:mousePressed(x, y, button, istouch)
    local clickables = db.queries.clickable

    for clickable in pairs(clickables) do
        if utils.pointInsideBox({x = x, y = y}, db.components.clickBounds[clickable]) then
            if orchestrator.ui.enabled then
                if db.components.uiComponent[clickable] == "slider" then
                    self.state.mouseDown[clickable] = true
                elseif db.components.uiComponent[clickable] == "toggle" then
                    db.components.clickHandler[clickable](love.mouse.getPosition())
                end
            end
            
        end
    end
    
    local cells = db.queries.cells
    
    for cell in pairs(cells) do
        if utils.pointInsideBox({x = x, y = y}, db.components.clickBounds[cell]) then
            local cellCheck = "t"
            if button == 1 then cellCheck = "f" end
            db.components.statusHandler[cell] = orchestrator.sysGrid:getStatusHandler(cellCheck)
        end
    end
end

function InputSystem:mouseReleased()
    self.state.mouseDown = {}
    orchestrator.sysEvents.onMouseReleased:emit()
end

function InputSystem:update()
    self:keyRepeated()

    if #utils.getKeys(self.state.mouseDown) > 0 and not love.mouse.isDown(1) then self:mouseReleased() end
    if love.mouse.isDown(1) then
        for held in pairs(self.state.mouseDown) do
            db.components.clickHandler[held](love.mouse.getPosition())
        end
    end
end