shaderClass = require("src.utils.shaders")
Object = require("src.utils.classic")

Renderer = Object:extend()


function Renderer:new()
    self.sysDesign = DesignSystem()
    self.layerOrder = {"background", "default", "ui"}
    self.layers = {}

    self:updateFont()
    self:clear()

    self.shaders = Shaders().shaders
end

function Renderer:updateFont()
    self.font = love.graphics.newFont(db:get('settings', 'fontSize', 24))
    love.graphics.setFont(self.font)
end

function Renderer:add(layerName, orderNumber, drawFunc)
    table.insert(self.layers[layerName or "default"].draw, {order = orderNumber, func = drawFunc})
end

function sortLayer(a, b)
    return a.order < b.order
end

function Renderer:render()
    self:build()
    self:draw()
    self:clear()
    
    -- print(love.timer.getFPS())
end

function Renderer:build()
    -- UX
    self:drawBackground()
    self:drawGameWindow()
    self:drawPanels()
    
    -- UI
    self:drawDebugTool()
end

function Renderer:drawBackground()
    self:add("background", 0, function()
        self.sysDesign:setColor('offwhite')
        love.graphics.rectangle(
            "fill",
            0,
            0,
            db:get('display', 'width'),
            db:get('display', 'height')
        )
    end)
end

function Renderer:drawGameWindow()
    local lineWidth = db:get('display', 'lineWidthDefault')

    local gameBounds = db.components.bounds[db:get('display', 'gameBounds')]
    local size = db.components.size[orchestrator.sysGrid.id]

    -- Game window outline
    self:add("default", 2, function()
        self.sysDesign:setColor('grey')
        love.graphics.setLineWidth(db:get('display', 'lineWidthDefault'))
        
        love.graphics.rectangle(
            "line",
            gameBounds.x1,
            gameBounds.y1,
            gameBounds.x2 - gameBounds.x1,
            gameBounds.y2 - gameBounds.y1
        )
    end)
    
    -- Game window background
    self:add("default", 0, function()
        self.sysDesign:setColor('white')
        
        love.graphics.rectangle(
            "fill",
            gameBounds.x1,
            gameBounds.y1,
            gameBounds.x2 - gameBounds.x1,
            gameBounds.y2 - gameBounds.y1
        )
    end)
    
    local cells = db.queries.cells
    for cell in pairs(cells) do
        local x, y = unpack(db.components.coord[cell])
        local cellWidth = (gameBounds.x2 - gameBounds.x1) / size
        local cellHeight = (gameBounds.y2 - gameBounds.y1) / size
        
        local clickBounds = db.components.clickBounds[cell]

        local value = db.components.t[sysInput.vars.Notch_Size]
        
        self:add("default", 1, function()
            love.graphics.setLineWidth(lineWidth)
        
            love.graphics.stencil(function()
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle(
                    "fill",
                    x * cellWidth + cellWidth * (1 - value) * 0.5 + gameBounds.x1,
                    y * cellHeight + gameBounds.y1 - lineWidth,
                    cellWidth * value,
                    cellHeight + lineWidth * 2
                )
                love.graphics.rectangle(
                    "fill",
                    x * cellWidth + gameBounds.x1 - lineWidth,
                    y * cellHeight + cellHeight * (1 - value) * 0.5 + gameBounds.y1,
                    cellWidth + lineWidth * 2,
                    cellHeight * value
                )
                end,
                "replace",
                1
            )
            love.graphics.setStencilTest("notequal", 1)

            -- love.graphics.rectangle(
            --     "line",
            --     x * cellWidth + gameBounds.x1,
            --     y * cellHeight + gameBounds.y1,
            --     cellWidth,
            --     cellHeight
            -- )
            drawBox(clickBounds, "line", db.components.color[self.sysDesign.colors.grey])

            love.graphics.setStencilTest()
        end)

        if not db.components.statusHandler[cell].callback() then
            if utils.contains(db.components.cells[orchestrator.sysPlayer.line], db.components.cellNum[cell]) then
                self:add("default", 21, function ()    
                    drawCross(clickBounds, utils.toRGB("#D08C60"))
                end)
            end

            self:add("default", 5, function ()
                drawBox(utils.expandBounds(clickBounds, -6), "fill", utils.toRGB("#D9AE94"))
            end)
        end


        self:add("ui", 1, function ()
            local value = db.components.t[sysInput.vars.Show_Coords]

            if value == 1 then 
                love.graphics.setFont(love.graphics.newFont(12))
                love.graphics.setColor({1, 1, 1, 1})
                love.graphics.setFont(love.graphics.newFont(8))
                love.graphics.printf(
                    string.format("(%s, %s)", x, y), 
                    x * cellWidth + gameBounds.x1,
                    y * cellHeight + gameBounds.y1,
                    cellWidth,
                    "center"
                )
            end

            local value = db.components.t[sysInput.vars.Show_Cell_IDs]

            if value == 1 then 
                love.graphics.setFont(love.graphics.newFont(12))
                love.graphics.setColor({1, 1, 1, 1})
                love.graphics.printf(
                    db.components.cellNum[cell], 
                    x * cellWidth + gameBounds.x1,
                    y * cellHeight + gameBounds.y1 + (cellHeight - love.graphics.getFont():getHeight()) * 0.5,
                    cellWidth,
                    "center"
                )
            end
        end)
    end
end

function Renderer:drawDebugTool()
    if not orchestrator.ui.layers.debug.enabled then return end

    -- Draw Debug Tool window
    self:add("ui", 11, function ()
        local bounds = db.components.bounds[orchestrator.ui.debugTool]

        love.graphics.setLineWidth(4)
        drawBox(utils.expandBounds(bounds, -10), "fill", self.sysDesign:getColor('white'), 20)
        drawBox(utils.expandBounds(bounds, -10), "line", self.sysDesign:getColor('grey'), 20)
    end)

    -- Draw Debug Tools
    self:add("ui", 12, function ()
        local controls = db:getQuery("uiControls")

        for control in pairs(controls) do
            local uiComponent = db.components.uiComponent[control]

            if uiComponent == "slider" then
                self:drawSlider(control)
            elseif uiComponent == "toggle" then
                self:drawToggle(control)
            end
        end
    end)
end

function Renderer:drawPanels()
    local value = db.components.t[sysInput.vars.Show_Panels]

    if value == 0 then return end

    self:add("ui", 10, function ()
        panels = db:get('display', 'panels')

        love.graphics.setLineWidth(4)
        drawBox(utils.expandBounds(db.components.bounds[panels.firstPrimary], -db:get('display', 'lineWidthDefault') * 0.5), "line", {1, 0, 0, 1})
        drawBox(utils.expandBounds(db.components.bounds[panels.secondPrimary], -db:get('display', 'lineWidthDefault') * 0.5), "line", {1, 0, 0, 1})
        drawBox(utils.expandBounds(db.components.bounds[panels.firstSecondary], -db:get('display', 'lineWidthDefault') * 0.5), "line", {0, 0, 1, 1})
        drawBox(utils.expandBounds(db.components.bounds[panels.secondSecondary], -db:get('display', 'lineWidthDefault') * 0.5), "line", {0, 0, 1, 1})
    end)
end

function Renderer:draw()
    for _, layerName in pairs(self.layerOrder) do
        local draws = self.layers[layerName].draw
        table.sort(draws, sortLayer)
        for _, draw in pairs(draws) do
            draw.func()
        end
    end
end

function Renderer:clear()
    for _, layerName in pairs(self.layerOrder) do 
        self.layers[layerName] = {draw = {}}
    end
end

function drawBox(bounds, mode, color, radius)
    love.graphics.setColor(color)
    love.graphics.rectangle(
        mode,
        bounds.x1,
        bounds.y1,
        bounds.x2 - bounds.x1,
        bounds.y2 - bounds.y1,
        radius or 0
    )
end

function drawCross(bounds, color)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(8)
    local crossBounds = utils.expandBounds(bounds, -8)

    love.graphics.line(
        crossBounds.x1,
        crossBounds.y1,
        crossBounds.x2,
        crossBounds.y2
    )
    love.graphics.line(
        crossBounds.x1,
        crossBounds.y2,
        crossBounds.x2,
        crossBounds.y1
    )
end

function drawCircle(bounds, mode, color)
    love.graphics.setColor(color)
    love.graphics.circle(
        mode,
        bounds.x1 + (bounds.x2 - bounds.x1) * 0.5,
        bounds.y1 + (bounds.x2 - bounds.x1) * 0.5,
        (bounds.x2 - bounds.x1) * 0.5
    )
end

function drawLine(line, color)
    love.graphics.setColor(color)
    love.graphics.line(
        line.x1,
        line.y1,
        line.x2,
        line.y2
    )
end

function Renderer:drawSlider(control)
    local bounds = db.components.bounds[control]
    local clickBounds = db.components.clickBounds[control]
    local line = db.components.line[control]
    local t = db.components.t[control]
    local label = db.components.name[control]

    if line then 
        love.graphics.setLineWidth(2)
        drawLine(
            line,
            self.sysDesign:getColor('grey')
        )
    end
    if clickBounds and t then
        drawCircle(
            clickBounds,
            "fill", 
            utils.lerpColour(self.sysDesign:getColor('offwhite'), self.sysDesign:getColor('accent'), t)
        )
        love.graphics.setLineWidth(2)
        drawCircle(
            clickBounds,
            "line", 
            self.sysDesign:getColor('grey')
        )
        if label then 
            self.sysDesign:setColor('grey')
            love.graphics.setFont(love.graphics.newFont(12))
            love.graphics.printf(label, bounds.x1, line.y1 + 4, (bounds.x2 - bounds.x1), "center")
        end
    end
end

function Renderer:drawToggle(control)
    local first, second = unpack(db.components.bounds[control])
    drawBox(first, "line", {0, 1, 0, 1})
    drawBox(second, "line", {0, 1, 1, 1})
    local clickBounds = db.components.clickBounds[control]
    local t = db.components.t[control]
    local label = db.components.name[control]

    local offBounds = utils.expandBounds(UISystem.getToggleClickBounds(first, 0), 5)
    local onBounds = utils.expandBounds(UISystem.getToggleClickBounds(first, 1), 5)

    if clickBounds and t then
        love.graphics.stencil(function ()
            love.graphics.rectangle(
                "fill",
                (offBounds.x2 + offBounds.x1) * 0.5,
                offBounds.y1 + 1,
                onBounds.x1 - offBounds.x1,
                offBounds.y2 - offBounds.y1 - 2
            )
        end)

        love.graphics.setStencilTest("notequal", 1)

        love.graphics.setLineWidth(2)
        self.sysDesign:setColor('grey')
        love.graphics.rectangle(
                "fill",
                (offBounds.x2 + offBounds.x1) * 0.5,
                offBounds.y1 - 1,
                onBounds.x1 - offBounds.x1,
                offBounds.y2 - offBounds.y1 + 2
            )
        drawCircle(
            offBounds,
            "line",
            self.sysDesign:getColor('grey')
        )
        drawCircle(
            onBounds,
            "line",
            self.sysDesign:getColor('grey')
        )

        love.graphics.setStencilTest()

        drawCircle(
            clickBounds,
            "fill", 
            utils.lerpColour(self.sysDesign:getColor('grey'), self.sysDesign:getColor('accent'), t)
        )
        love.graphics.setLineWidth(2)
        drawCircle(
            clickBounds,
            "line", 
            self.sysDesign:getColor('offwhite')
        )
        if label then 
            self.sysDesign:setColor('grey')
            -- love.graphics.setFont(love.graphics.newFont(12))
            -- love.graphics.printf(label, bounds.x1, (bounds.y1 + bounds.y2 - love.graphics.getFont():getHeight()) * 0.5, (bounds.x2 - bounds.x1) * 0.9, "right")
            
            local image, res = self.sysDesign:getImage('layout')
            local boundsHeight = second.y2 - second.y1
            local imageHeight =  boundsHeight * 0.65
            
            self.shaders.colorShader:send("targetColor", self.sysDesign:getColor('grey'))
            love.graphics.setShader(self.shaders.colorShader)
            love.graphics.draw(image, second.x2 - imageHeight, second.y1 + (boundsHeight - imageHeight) * 0.5, 0, imageHeight/res, imageHeight/res)
            love.graphics.setShader()
        end
    end
end

function Renderer:coordToScreenSpace(x, y)
    local gameBounds = db.components.bounds[db:get('display', 'gameBounds', 0)]
    local size = db.components.size[orchestrator.sysGrid.id]
    local cellWidth = (gameBounds.x2 - gameBounds.x1) / size
    local cellHeight = (gameBounds.y2 - gameBounds.y1) / size

    return {
        x * cellWidth + gameBounds.x1,
        y * cellHeight + gameBounds.y1
    }
end

function Renderer:boundsToScreenSpace(bounds)
    local x1, y1 = unpack(self:coordToScreenSpace(bounds.x1, bounds.y1))
    local x2, y2 = unpack(self:coordToScreenSpace(bounds.x2, bounds.y2))

    return {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2
    }
end