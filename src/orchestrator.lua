Object = require("src.utils.classic")
windowSystemClass = require("src.sys.windowSystem")
eventSystemClass = require("src.sys.eventSystem")
gridSystemClass = require("src.sys.gridSystem")
UISystemClass = require("src.sys.uiSystem")

Orchestrator = Object:extend()

function Orchestrator:new()
    self.ui = UISystem()
    self:setup()
end

function Orchestrator:setup()
    self.events = EventSystem()
    self.grid = GridSystem(db:get('game', 'gridSize', 6))
    self.input = {}

    local cells = lume.concat(table.arange(1, 4), table.arange(4 + db.components.size[self.grid.id] - 1, 4 + db.components.size[self.grid.id] + 4))

    self.line = db:createEntity({
        cells = cells,
        points = self.grid:lineToVertices(cells)
    })
    
    self:registerQueries()
    self:updateSettings()
    self:connectHandlers()


end

function Orchestrator:registerQueries()
    db:registerQuery('clickable', {'clickHandler', 'clickBounds'})
    db:registerQuery('uiControls', {'clickHandler', 'clickBounds', 'uiComponent'})
end

function Orchestrator:resize()
    self.events.onWindowResize:emit()
end

function Orchestrator:updateSettings()
    self.ui.nextUI = 1
    -- Update WindowOrientation
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    self.window = WindowSystem.fromWindow(width, height)
    db:set('display', 'width', width)
    db:set('display', 'height', height)

    -- Other updates
    self:updateLayout(width, height)
    self:updateDebugTool()
    
    -- Update fontSize
    db:set('settings', 'fontSize', utils.remap(db:get('display', width, love.graphics.getWidth()), 400, 1920, 12, 20))
    renderer:updateFont()
    
end

function Orchestrator:updateLayout(width, height)
    local gameSize = self.window:getBoxLength(width, height)
    local panelsBounds = self.window:getPanelsBounds(width, height)
    
    self:updateGameWindow(width, height, gameSize)
    self:updatePanels(panelsBounds)
end

function Orchestrator:updateDebugTool()
    self.ui:clear(self)
    self.ui:add(UISystem.Slider, "Notch Size", self, 0.6)
    self.ui:add(UISystem.Toggle, "Show Panels", self, 0)
    self.ui:add(UISystem.Toggle, "Show Coords", self, 0)
    self.ui:add(UISystem.Toggle, "Show Cell IDs", self, 0)
end

function Orchestrator:updateGameWindow(width, height, gameSize) 
    db:set('display', 'gameBounds', db:createEntity({
        bounds = {
            x1 = (width - gameSize) * 0.5,
            y1 = (height - gameSize) * 0.5,
            x2 = (width + gameSize) * 0.5,
            y2 = (height + gameSize) * 0.5
        }
    }))
end


function Orchestrator:updatePanels(panelsBounds) 
    db:set('display', 'panels', {
            firstPrimary = db:createEntity({
                bounds = panelsBounds.firstPrimary
            }),
            secondPrimary = db:createEntity({
                bounds = panelsBounds.secondPrimary
            }),
            firstSecondary = db:createEntity({
                bounds = panelsBounds.firstSecondary
            }),
            secondSecondary = db:createEntity({
                bounds = panelsBounds.secondSecondary
            }),
        }
    )
end

function Orchestrator:connectHandlers() 
    self.events.onWindowResize:connect(self.events.bind(db, db.updateDisplay))
    self.events.onWindowResize:connect(self.events.bind(self, self.updateSettings))
    self.events.onMousePressed:connect(self.events.bind(self, self.doThing))
    self.events.onKeyPressed:connect(self.events.bind(self, self.moveActivePoint))
    -- self.events.onMouseReleased:connect(self.events.bind(self, self.doThing))
end

function Orchestrator:moveActivePoint(key)
    local size = db.components.size[orchestrator.grid.id]
    local dirs = {}
    dirs["right"] = 1
    dirs["left"] = -1
    dirs["down"] = size
    dirs["up"] = -size
    dirs["backspace"] = true
    dirs["delete"] = true

    local dir = dirs[key]

    if not dir then
        return
    else
        local cells = db.components.cells[self.line]
        if key == "backspace" or key == "delete" then
            table.remove(cells, #cells)
        else
            local lastCell = cells[#cells]
            local noRight = dir == 1 and lastCell % size == 11
            local noLeft = dir == -1 and lastCell % size == 0
            local noUp = lastCell + dir < 0
            local noDown = lastCell + dir > math.pow(size, 2) - 1

            -- Moving point shouldn't go beyond game bounds. Assumes square bounds
            if noRight or noLeft or noUp or noDown then return end

            table.insert(cells, lastCell + dir)
        end
        db.components.points[self.line] = self.grid:lineToVertices(cells)
    end
end

function Orchestrator:getBoxBounds(width, height)
    db.game.box.length = self.window:getBoxLength(width, height)

    local bounds = {
        topLeft = {
            x = db:get('display', halfWidth, love.graphics.gethalfWidth),
            y = db:get('display', halfHeight, love.graphics.gethalfHeight)
        },
        bottomRight = {
            x = db:get('display', halfWidth, love.graphics.gethalfWidth),
            y = db:get('display', halfHeight, love.graphics.gethalfHeight)
        }
    }

    self.boxBounds = bounds
end