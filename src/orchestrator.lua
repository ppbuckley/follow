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
    self.ui:add(UISystem.Slider, "Notch Size", self)
    self.ui:add(UISystem.Toggle, "Show Panels", self)
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
    -- self.events.onMouseReleased:connect(self.events.bind(self, self.doThing))
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