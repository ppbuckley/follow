Object = require("src.utils.classic")
windowSystemClass = require("src.sys.windowSystem")
eventSystemClass = require("src.sys.eventSystem")
gridSystemClass = require("src.sys.gridSystem")
UISystemClass = require("src.sys.uiSystem")

Orchestrator = Object:extend()

function Orchestrator:new()
    self:setup()
end

function Orchestrator:setup()
    self.ui = UISystem()
    self.sysEvents = EventSystem()
    
    db:set('display', 'gameBounds', db:createEntity({bounds = {}}))
    self:registerQueries()
    self:updateSettings()
    
    self.sysGrid = GridSystem()
    self.sysPlayer = PlayerSystem(self.sysGrid)

    self:connectHandlers()
end

function Orchestrator:registerQueries()
    db:registerQuery('clickable', {'clickHandler', 'clickBounds'})
    db:registerQuery('cells', {'cellNum', 'coord', 'clickBounds', 'clickHandler', 'statusHandler'})
    db:registerQuery('uiControls', {'clickHandler', 'clickBounds', 'uiComponent'})
end

function Orchestrator:resize()
    self.sysEvents.onWindowResize:emit()
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
    if self.sysGrid then self.sysGrid:updateCells() end
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
    self.ui:clear(sysInput)
    self.ui:add(UISystem.Slider, "Notch Size", 0.6)
    self.ui:add(UISystem.Toggle, "Show Panels", 0)
    self.ui:add(UISystem.Toggle, "Show Coords", 0)
    self.ui:add(UISystem.Toggle, "Show Cell IDs", 0)
end

function Orchestrator:updateGameWindow(width, height, gameSize) 
    local gameBounds = {
        x1 = (width - gameSize) * 0.5,
        y1 = (height - gameSize) * 0.5,
        x2 = (width + gameSize) * 0.5,
        y2 = (height + gameSize) * 0.5
    }
    db.components.bounds[db:get('display', 'gameBounds')] = gameBounds
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
    self.sysEvents.onWindowResize:connect(self.sysEvents.bind(db, db.updateDisplay))
    self.sysEvents.onWindowResize:connect(self.sysEvents.bind(self.ui, self.ui.resize))
    self.sysEvents.onWindowResize:connect(self.sysEvents.bind(self, self.updateSettings))
    self.sysEvents.onKeyPressed:connect(self.sysEvents.bind(self, self.onKeyPressed))
end

function Orchestrator:onKeyPressed(key)
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