Object = require("src.utils.classic")

UISystem = Object:extend()

function UISystem:new()
    self.nextUI = 1
    self.enabled = false
end

function UISystem:toggleDebugTool()
    self.enabled = not self.enabled
end

function UISystem.Slider(name, bounds, defaultValue)
    return UISystem:createSlider(name, bounds, defaultValue)
end

function UISystem:createSlider(name, bounds, defaultValue)

    local ydist = bounds.y2 - bounds.y1
    local ybar = (bounds.y1 + bounds.y2) * 0.5

    local line = {
        x1 = bounds.x1 + ydist * 0.75,
        y1 = ybar,
        x2 = bounds.x2 - ydist * 0.75,
        y2 = ybar
    }

    local slider = db:createEntity({
        bounds = bounds,
        line = line,
        t = defaultValue,
        name = name,
        uiComponent = "slider"
    })

    db:addComponent(slider, 'clickHandler',
        function(x, y)
            local bounds = db.components.bounds[slider]
            local line = db.components.line[slider]
            local t = utils.remap(utils.clamp(x, line.x1, line.x2),  line.x1, line.x2, 0, 1)
            db.components.t[slider] = t
            local clickBounds = self.getSliderClickBounds(bounds, line, t)
            db.components.clickBounds[slider] = clickBounds
        end
    )

    db:addComponent(slider, 'clickBounds', self.getSliderClickBounds(bounds, line, defaultValue))
    
    return slider
end

function UISystem.Toggle(name, bounds, defaultValue)
    return UISystem:createToggle(name, bounds, defaultValue)
end

function UISystem:createToggle(name, bounds, defaultValue)
    local ydist = bounds.y2 - bounds.y1
    local ybar = (bounds.y1 + bounds.y2) * 0.5

    local toggle = db:createEntity({
        bounds = bounds,
        t = defaultValue,
        name = name,
        uiComponent = "toggle"
    })

    db:addComponent(toggle, 'clickHandler',
        function(x, y)
            local bounds = db.components.bounds[toggle]
            local oldT = db.components.t[toggle]
            local t = 0
            if oldT == 0 then t = 1 end
            db.components.t[toggle] = t
            local clickBounds = self.getToggleClickBounds(bounds, t)
            flux.to(
                db.components.clickBounds[toggle],
                0.25,
                clickBounds
            ):ease("circinout")
        end
    )

    db:addComponent(toggle, 'clickBounds', self.getToggleClickBounds(bounds, defaultValue))
    
    return toggle
end

function UISystem:clear()
    for name, id in pairs(sysInput.vars) do
        db:destroyEntity(id)
    end
end

function UISystem:add(uiComponent, name, defaultValue)
    local bounds = self:getNextBounds()
    local component = uiComponent(string.gsub(name, ' ', '_'), bounds, defaultValue)

    sysInput.vars[string.gsub(name, ' ', '_')] = component

end

function UISystem.getSliderClickBounds(bounds, line, t)
    local ydist = bounds.y2 - bounds.y1
    local tSpan = (line.x2 - line.x1) * t

    return {
        x1 = line.x1 - ydist * 0.2 + tSpan,
        y1 = line.y1 - ydist * 0.2,
        x2 = line.x1 + ydist * 0.2 + tSpan,
        y2 = line.y2 + ydist * 0.2
    }
end

function UISystem.getToggleClickBounds(bounds, t)
    local ydist = bounds.y2 - bounds.y1

    local clickBounds = {
        x1 = bounds.x1 + ydist * 0.4,
        y1 = bounds.y1 + ydist * 0.3,
        x2 = bounds.x1 + ydist * 0.8,
        y2 = bounds.y1 + ydist * 0.7
    }

    return utils.shiftBounds(clickBounds, { x = t * 30, y = 0 })
end

function UISystem:getNextBounds()
    local secondPrimaryPanelBounds = utils.expandBounds(table.copy(db.components.bounds[db:get('display', 'panels').secondPrimary]), -10)
    local panelHeight = secondPrimaryPanelBounds.y2 - secondPrimaryPanelBounds.y1
    secondPrimaryPanelBounds.y2 = secondPrimaryPanelBounds.y1 + panelHeight / 15

    local nextBounds = utils.expandBounds(utils.shiftBounds(secondPrimaryPanelBounds, { x = 0, y = panelHeight * (self.nextUI - 1) / 15}), -4)
    self.nextUI = self.nextUI + 1

    return nextBounds
end