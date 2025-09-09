shaderClass = require("src.utils.shaders")
Object = require("src.utils.classic")

Renderer = Object:extend()


function Renderer:new()
    self.layerOrder = {"background", "default", "ui"}
    self.layers = {}

    self:updateFont()
    self:clear()

    self.shaders = Shaders()
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
    self:drawBackground()
    self:drawGameWindow()
    self:drawDebugTool()
    self:drawPanels()

    self:drawCells(orchestrator.sysPlayer.line)
end

function Renderer:drawCells(id)
    self:add("default", 20, function()
        local gameBounds = db.components.bounds[db:get('display', 'gameBounds', 0)]
        local coords, size = orchestrator.sysGrid:getCoords(id, 'points'), db.components.size[orchestrator.sysGrid.id]
        local cellWidth = (gameBounds.x2 - gameBounds.x1) / size
        local cellHeight = (gameBounds.y2 - gameBounds.y1) / size
        for i = 1, #coords do
            local x1, y1 = unpack(coords[i])
            
            love.graphics.setColor(utils.toRGB("#797D62"))
            love.graphics.circle(
                "fill",
                x1 * cellWidth + gameBounds.x1 + cellWidth * 0.5,
                y1 * cellHeight + gameBounds.y1 + cellHeight * 0.5,
                cellWidth * 0.3 + 3,
                cellHeight * 0.3 + 3
            )

            if i < #coords then
                local x2, y2 = unpack(coords[i + 1])
                
                love.graphics.setLineWidth(cellWidth * 0.3 * 0.8 + 6)
                love.graphics.line(
                    x1 * cellWidth + gameBounds.x1 + cellWidth * 0.5,
                    y1 * cellHeight + gameBounds.y1 + cellHeight * 0.5,
                    x2 * cellWidth + gameBounds.x1 + cellWidth * 0.5,
                    y2 * cellHeight + gameBounds.y1 + cellHeight * 0.5
                )
            end
            
            love.graphics.setColor(utils.toRGB("#9B9B7A"))
            love.graphics.circle(
                "fill",
                x1 * cellWidth + gameBounds.x1 + cellWidth * 0.5,
                y1 * cellHeight + gameBounds.y1 + cellHeight * 0.5,
                cellWidth * 0.3,
                cellHeight * 0.3
            )

            if i < #coords then
                local x2, y2 = unpack(coords[i + 1])
                
                love.graphics.setLineWidth(cellWidth * 0.3 * 0.8)
                love.graphics.line(
                    x1 * cellWidth + gameBounds.x1 + cellWidth * 0.5,
                    y1 * cellHeight + gameBounds.y1 + cellHeight * 0.5,
                    x2 * cellWidth + gameBounds.x1 + cellWidth * 0.5,
                    y2 * cellHeight + gameBounds.y1 + cellHeight * 0.5
                )
            end
        end
    end
    )

    self:add("ui", 30, function ()
        local value = db.components.t[sysInput.vars.Show_Line_Bounds]
        if value == 0 then return end

        love.graphics.setLineWidth(4)
        local bounds = table.copy(db.components.bounds[id])
        bounds.x2, bounds.y2 = bounds.x2 + 1, bounds.y2 + 1
        drawBox(
            self:boundsToScreenSpace(bounds),
            "line",
            {1, 1, 1, 1}
        )
    end)

    -- self:add("default", 21, function()
    --         local gameBounds = db.components.bounds[db:get('display', 'gameBounds', 0)]
    --         local coords, size = orchestrator.sysGrid:getCoords(id), db.components.size[orchestrator.sysGrid.id]
    --         local line = {}
    --         local cellWidth = (gameBounds.x2 - gameBounds.x1) / size
    --         local cellHeight = (gameBounds.y2 - gameBounds.y1) / size
    --         for i, coord in ipairs(orchestrator.sysGrid:getCoords(orchestrator.points)) do
    --             local x, y = unpack(coord)

    --             love.graphics.setColor({1, 1, 1, 1})
    --             love.graphics.circle(
    --                 "fill",
    --                 x * cellWidth + gameBounds.x1 + cellWidth * 0.5,
    --                 y * cellHeight + gameBounds.y1 + cellHeight * 0.5,
    --                 cellWidth * 0.3,
    --                 cellHeight * 0.3
    --             )
    --         end
    --     end
    -- )
end

function Renderer:drawBackground()
    self:add("background", 0, function()
        love.graphics.setColor(utils.toRGB("#AD9585"))
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

    local gameBounds = db.components.bounds[db:get('display', 'gameBounds', 0)]
    local size = db.components.size[orchestrator.sysGrid.id]

    -- Game window outline
    self:add("default", 2, function()
        love.graphics.setColor(utils.toRGB("#BDAA9D"))
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
        love.graphics.setColor(utils.toRGB("#CABBB1"))
        
        love.graphics.rectangle(
            "fill",
            gameBounds.x1,
            gameBounds.y1,
            gameBounds.x2 - gameBounds.x1,
            gameBounds.y2 - gameBounds.y1
        )
    end)
    
    self:add("default", 1, function()
        local cells = db.queries.cells
        for cell in pairs(cells) do
            local x, y = unpack(db.components.coord[cell])
            local cellWidth = (gameBounds.x2 - gameBounds.x1) / size
            local cellHeight = (gameBounds.y2 - gameBounds.y1) / size

            local clickBounds = db.components.clickBounds[cell]

            if not db.components.statusHandler[cell].callback() then
                drawBox(clickBounds, "fill", utils.toRGB("#D9AE94"))
            end

            love.graphics.setLineWidth(lineWidth)
            local value = db.components.t[sysInput.vars.Notch_Size]
        
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
            drawBox(clickBounds, "line", utils.toRGB("#BDAA9D"))

            love.graphics.setStencilTest()

            self:add("ui", 1, function ()
                local value = db.components.t[sysInput.vars.Show_Coords]

                if value == 1 then 
                    love.graphics.setFont(love.graphics.newFont(12))
                    love.graphics.setColor({1, 1, 1, 1})
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
    end)
end

function Renderer:drawDebugTool()
    if not orchestrator.ui.enabled then return end

    -- Draw Debug Tool window
    self:add("ui", 11, function ()
        local secondPrimaryPanelBounds = table.copy(db.components.bounds[db:get('display', 'panels').secondPrimary])
        secondPrimaryPanelBounds.y2 = secondPrimaryPanelBounds.y1 + (secondPrimaryPanelBounds.y2 - secondPrimaryPanelBounds.y1) * 0.5

        love.graphics.setLineWidth(4)
        drawBox(utils.expandBounds(secondPrimaryPanelBounds, -10), "fill", utils.toRGB("#CABBB1"))
        drawBox(utils.expandBounds(secondPrimaryPanelBounds, -10), "line", {1, 1, 1, 1})
    end)

    -- Draw Debug Tools
    self:add("ui", 12, function ()
        local controls = db:getQuery("uiControls")

        for control in pairs(controls) do
            local uiComponent = db.components.uiComponent[control]

            if uiComponent == "slider" then
                drawSlider(control)
            elseif uiComponent == "toggle" then
                drawToggle(control)
            end
        end
    end)

    -- Draw solution space  
    self:add("ui", 12, function ()
        local firstPrimaryPanelBounds = utils.expandBounds(table.copy(db.components.bounds[db:get('display', 'panels').firstPrimary]), -10)
        local width = firstPrimaryPanelBounds.x2 - firstPrimaryPanelBounds.x1
        local sx, sy = unpack(db.components.solutionSpace[orchestrator.sysPlayer.line])
        local cellWidth = width / sx

        love.graphics.setColor(utils.toRGB("#CABBB1"))
        love.graphics.rectangle(
            "fill",
            firstPrimaryPanelBounds.x1,
            firstPrimaryPanelBounds.y1,
            width,
            cellWidth * sy
        )

        for x = 0, sx - 1 do
            for y = 0, sy - 1 do
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle(
                    "line",
                    firstPrimaryPanelBounds.x1 + x * cellWidth,
                    firstPrimaryPanelBounds.y1 + y * cellWidth,
                    cellWidth,
                    cellWidth
                )
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

function drawBox(bounds, mode, color)
    love.graphics.setColor(color)
    love.graphics.rectangle(
        mode,
        bounds.x1,
        bounds.y1,
        bounds.x2 - bounds.x1,
        bounds.y2 - bounds.y1
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

function drawSlider(control)
    local bounds = db.components.bounds[control]
    local clickBounds = db.components.clickBounds[control]
    local line = db.components.line[control]
    local t = db.components.t[control]
    local label = db.components.name[control]

    if line then 
        love.graphics.setLineWidth(2)
        drawLine(
            line,
            utils.toRGB("#997B66")
        )
    end
    if clickBounds and t then
        drawCircle(
            clickBounds,
            "fill", 
            utils.lerpColour(utils.toRGB("#CABBB1"), utils.toRGB("#997B66"), t)
        )
        love.graphics.setLineWidth(2)
        drawCircle(
            clickBounds,
            "line", 
            utils.toRGB("#997B66")
        )
        if label then 
            love.graphics.setColor(utils.toRGB("#997B66"))
            love.graphics.printf(label, bounds.x1, line.y1 + 4, (bounds.x2 - bounds.x1), "center")
        end
    end
end

function drawToggle(control)
    local bounds = db.components.bounds[control]
    local clickBounds = db.components.clickBounds[control]
    local t = db.components.t[control]
    local label = db.components.name[control]

    local offBounds = utils.expandBounds(UISystem.getToggleClickBounds(bounds, 0), 5)
    local onBounds = utils.expandBounds(UISystem.getToggleClickBounds(bounds, 1), 5)

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
        love.graphics.setColor(utils.toRGB("#997B66"))
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
            utils.toRGB("#997B66")
        )
        drawCircle(
            onBounds,
            "line",
            utils.toRGB("#997B66")
        )

        love.graphics.setStencilTest()

        drawCircle(
            clickBounds,
            "fill", 
            utils.lerpColour(utils.toRGB("#CABBB1"), utils.toRGB("#997B66"), t)
        )
        love.graphics.setLineWidth(2)
        drawCircle(
            clickBounds,
            "line", 
            utils.toRGB("#997B66")
        )
        if label then 
            love.graphics.setColor(utils.toRGB("#997B66"))
            love.graphics.printf(label, bounds.x1, (bounds.y1 + bounds.y2 - love.graphics.getFont():getHeight()) * 0.5, (bounds.x2 - bounds.x1) * 0.9, "right")
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