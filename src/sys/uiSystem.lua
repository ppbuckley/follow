Object = require("src.utils.classic")

UISystem = Object:extend()

function UISystem:new()
    self.nextUI = 1
    self.layers = {
        debug = {
            enabled = false
        }
    }

    self.debugTool = db:createEntity({
        enabled = false,
        bounds = self:getDebugToolBounds()
    })
end

function UISystem:resize()
    db.components.bounds[self.debugTool] = self:getDebugToolBounds()
end

function UISystem:getDebugToolBounds()
    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local width = math.min(math.max(windowWidth * 0.3, 150), 250)
    local height = self.nextUI * 60

    local x1 = windowWidth - width
    local y1 = 0
    local x2 = windowWidth
    local y2 = height

    return {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2
    }
end

function UISystem:toggleDebugTool()
    self.layers.debug.enabled = not self.layers.debug.enabled
end

function UISystem.Slider(name, bounds, defaultValue)
    return UISystem:createSlider(name, bounds, defaultValue)
end

function UISystem:createSlider(name, bounds, defaultValue)
    local first, second = unpack(bounds)

    local ydist = first.y2 - first.y1
    local ybar = (first.y1 + first.y2) * 0.5

    local line = {
        x1 = first.x1 + ydist * 0.75,
        y1 = ybar,
        x2 = first.x2 - ydist * 0.75,
        y2 = ybar
    }

    local slider = db:createEntity({
        bounds = first,
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
            local clickBounds = self.getSliderClickBounds(first, line, t)
            db.components.clickBounds[slider] = clickBounds
        end
    )

    db:addComponent(slider, 'clickBounds', self.getSliderClickBounds(first, line, defaultValue))
    
    return slider
end

function UISystem.Toggle(name, bounds, defaultValue)
    return UISystem:createToggle(name, bounds, defaultValue)
end

function UISystem:createToggle(name, bounds, defaultValue)
    local first, second = unpack(bounds)

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
            local clickBounds = self.getToggleClickBounds(first, t)
            flux.to(
                db.components.clickBounds[toggle],
                0.25,
                clickBounds
            ):ease("circinout")
        end
    )

    db:addComponent(toggle, 'clickBounds', self.getToggleClickBounds(first, defaultValue))
    
    return toggle
end

function UISystem:clear()
    for name, id in pairs(sysInput.vars) do
        db:destroyEntity(id)
    end
end

function UISystem:add(uiComponent, name, defaultValue)
    self:resize()
    local first, second = self:getNextBounds()
    local component = uiComponent(string.gsub(name, ' ', '_'), {first, second}, defaultValue)

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
    local bounds = utils.expandBounds(self:getDebugToolBounds(), -15)
    local first, second = utils.splitBounds(bounds, {x = 0.5})

    first.y2 = first.y1 + 60
    second.y2 = second.y1 + 60

    local nextBoundsFirst = utils.shiftBounds(first, { x = 0, y = 60 * (self.nextUI - 1)})
    local nextBoundsSecond = utils.shiftBounds(second, { x = 0, y = 60 * (self.nextUI - 1)})
    self.nextUI = self.nextUI + 1

    return nextBoundsFirst, nextBoundsSecond
end