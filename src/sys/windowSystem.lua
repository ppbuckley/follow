Object = require("src.utils.classic")

-- Abstract base class
WindowSystem = Object:extend()

function WindowSystem:new()
    -- Empty constructor, but we'll check in methods
end

function WindowSystem:checkImplementation()
    if self.class == Orientation then
        error("Cannot use Orientation directly, use Vertical or Horizontal")
    end
end

function WindowSystem:getName()
    self:checkImplementation()
    return self.name
end

function WindowSystem:getVector()
    self:checkImplementation()
    return self.vector
end

function WindowSystem:isPortrait()
    return self.class == Portrait
end

function WindowSystem:isLandscape()
    return self.class == Landscape
end

function WindowSystem:rotate()
    if self:isPortrait() then
        return Landscape()
    else
        return Portrait()
    end
end

-- Portrait subclass
Portrait = WindowSystem:extend()

function Portrait:new()
    self.class = Portrait
    self.name = "portrait"
    self.vector = {x = 0, y = 1}
end

function Portrait:getBoxLength(width, height)
    local ratio = width/height
    return (width - config.window.border * math.pow(ratio, 2)) * 0.5
end

function Portrait:getLevelData()
    local width = orchestrator.window:getBoxLength(config.window.width, config.window.height) * 2
    local height = 55

    local data = {
        x = (config.window.width - width) * 0.5, 
        y = math.min((config.window.width - width) * 0.5, (config.window.height - width) * 0.25 - height * 0.5),
        width = width, 
        height = height,
        widthMultiplier = 1,
        heightMultiplier = 0,
        widthDivisor = #orchestrator.tracking.level.boxColors * config.game.level,
        heightDivisor = 1,
        notchWidth = 3,
        notchHeight = height,
        corners = height * 0.2,
        segments = {}
    }

    for index, color in ipairs(orchestrator.tracking.level.boxColors) do
        for level = 1, config.game.level, 1 do
            table.insert(data.segments, {
                color = color,
                segNum = (index - 1) * config.game.level + level
            })
        end
    end

    return data
end

-- Landscape subclass
Landscape = WindowSystem:extend()

function Landscape:new()
    self.class = Landscape
    self.name = "landscape"
    self.vector = {x = 1, y = 0}
end

function Landscape:getBoxLength(width, height)
    local ratio = height/width
    return (height - config.window.border * math.pow(ratio, 3)) * 0.5 - config.game.font.size
end

function Landscape:getLevelData()
    local width = 55
    local height = orchestrator.window:getBoxLength(config.window.width, config.window.height) * 2

    local data = {
        x = math.min((config.window.height - height) * 0.5, (config.window.width - height) * 0.25 - width * 0.5),
        y = (config.window.height - height) * 0.5, 
        width = width, 
        height = height,
        widthMultiplier = 0,
        heightMultiplier = 1,
        widthDivisor = 1,
        heightDivisor = #orchestrator.tracking.level.boxColors * config.game.level,
        notchWidth = width,
        notchHeight = 3,
        corners = width * 0.2,
        segments = {}
    }

    for index, color in ipairs(orchestrator.tracking.level.boxColors) do
        for level = 1, config.game.level, 1 do
            table.insert(data.segments, {
                color = color,
                segNum = (index - 1) * config.game.level + level
            })
        end
    end

    return data
end

-- Static factory methods
function WindowSystem.portrait()
    return Portrait()
end

function WindowSystem.landscape()
    return Landscape()
end

function WindowSystem.fromString(str)
    if str == "portrait" or str == "p" then
        return Portrait()
    elseif str == "landscape" or str == "l" then
        return Landscape()
    else
        error("Unknown orientation: " .. str)
    end
end

function WindowSystem.fromWindow(width, height)
    if width > height then
        return Landscape()
    else
        return Portrait()
    end
end