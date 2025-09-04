Object = require("src.utils.classic")

-- Signal class
Signal = Object:extend()

function Signal:new()
    self.handlers = {}
end

function Signal:connect(handler)
    self.handlers[handler] = true
    return handler
end

function Signal:disconnect(handler)
    self.handlers[handler] = nil
end

function Signal:emit(...)
    for handler in pairs(self.handlers) do
        handler(...)
    end
end

-- Clear all handlers
function Signal:clear()
    self.handlers = {}
end

-- Get handler count
function Signal:count()
    local count = 0
    for _ in pairs(self.handlers) do
        count = count + 1
    end
    return count
end

-- Event System
EventSystem = Object:extend()

function EventSystem:new()
    self.onKeyPressed = Signal()
    self.onMousePressed = Signal()
    self.onMouseReleased = Signal()
    self.onWindowResize = Signal()
end

-- Helper method to connect multiple events at once
function EventSystem:connectAll(eventHandlers)
    local connections = {}
    for eventName, handler in pairs(eventHandlers) do
        if self[eventName] then
            connections[eventName] = self[eventName]:connect(handler)
        end
    end
    return connections
end

function EventSystem.bind(object, method)
    return function(...)
        return method(object, ...)
    end
end