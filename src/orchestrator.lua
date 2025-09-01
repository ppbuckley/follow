Object = require("src.utils.classic")
windowSystemClass = require("src.sys.windowSystem")
eventSystemClass = require("src.sys.eventSystem")

Orchestrator = Object:extend()

function Orchestrator:new()
    self.events = EventSystem()
    self.window = WindowSystem.fromWindow(db.window.width, db.window.height)
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
    local width, height = db.window.width, db.window.height
    self.window = WindowSystem.fromWindow(width, height)
    
    -- Update box lengths and bounds
    self:updateBoxBounds(width, height)

    -- Update font size
    db.game.font.size = utils.remap(db.window.width, 400, 1920, 12, 20)
    renderer:updateFont()
    
end

function Orchestrator:connectHandlers() 
    -- self.events.onMousePressed:connect(self.events.bind(self, self.doThing))
    -- self.events.onMouseReleased:connect(self.events.bind(self, self.doThing))
end

function Orchestrator:getBoxBounds(width, height)
    db.game.box.length = self.window:getBoxLength(width, height)

    local bounds = {
        topLeft = {
            x = db.window.halfWidth,
            y = db.window.halfHeight
        },
        bottomRight = {
            x = db.window.halfWidth,
            y = db.window.halfHeight
        }
    }

    self.boxBounds = bounds
end