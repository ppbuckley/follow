Object = require("src.utils.classic")
windowSystemClass = require("src.sys.windowSystem")
eventSystemClass = require("src.sys.eventSystem")
databaseClass = require("src.database")

Orchestrator = Object:extend()

function Orchestrator:new()
    self.db = DB()
    self.events = Signal()
    self.window = WindowSystem.fromWindow(self.db.settings.window.width, self.db.settings.window.height)
end

function Orchestrator:setup()
    self:updateSettings()    
    self:connectHandlers()
end

function Orchestrator:refresh()
    self:updateSettings()
    self.events.onWindowResize:emit()
end

function Orchestrator:updateSettings()
    -- Update WindowOrientation
    local width, height = self.db.settings.window.width, self.db.settings.window.height
    self.window = WindowSystem.fromWindow(width, height)
    
    -- Update box lengths and bounds
    self:updateBoxBounds(width, height)

    -- Update font size
    self.db.settings.game.font.size = utils.remap(self.db.settings.window.width, 400, 1920, 12, 20)
    renderer:updateFont()
    
end

function Orchestrator:connectHandlers() 
    -- self.events.onMousePressed:connect(self.events.bind(self, self.doThing))
    -- self.events.onMouseReleased:connect(self.events.bind(self, self.doThing))
end

function Orchestrator:getBoxBounds(width, height)
    self.db.settings.game.box.length = self.window:getBoxLength(width, height)

    local bounds = {
        topLeft = {
            x = self.db.settings.window.halfWidth,
            y = self.db.settings.window.halfHeight
        },
        bottomRight = {
            x = self.db.settings.window.halfWidth,
            y = self.db.settings.window.halfHeight
        }
    }

    self.boxBounds = bounds
end