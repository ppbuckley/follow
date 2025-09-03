Object = require("src.utils.classic")

-- Abstract base class
WindowSystem = Object:extend()

function WindowSystem:new()
    -- Empty constructor, but we'll check in methods
end

function WindowSystem:checkImplementation()
    if self.class == WindowSystem then
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
    return width - db:get('settings', 'border', 250) * math.pow(ratio, 2)
end

function Portrait:getPanelsBounds(width, height)
    local ratio = height/width
    local gameSize = height - db:get('settings', 'border', 250) * math.pow(ratio, 3)

    -- x1 = (width - gameSize) * 0.5,
    -- y1 = (height - gameSize) * 0.5,
    -- x2 = (width + gameSize) * 0.5,
    -- y2 = (height + gameSize) * 0.5

    local panels = {
        firstPrimary = {
            x1 = 0,
            y1 = 0,
            x2 = (width - gameSize) * 0.5,
            y2 = height
        },
        secondPrimary = {
            x1 = (width + gameSize) * 0.5,
            y1 = 0,
            x2 = width,
            y2 = height
        },
        firstSecondary = {
            x1 = (width - gameSize) * 0.5,
            y1 = 0,
            x2 = (width + gameSize) * 0.5,
            y2 = (height - gameSize) * 0.5
        },
        secondSecondary = {
            x1 = (width - gameSize) * 0.5,
            y1 = (height + gameSize) * 0.5,
            x2 = (width + gameSize) * 0.5,
            y2 = height
        }
    }

    return panels
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
    return height - db:get('settings', 'border', 250) * math.pow(ratio, 3)
end

function Landscape:getPanelsBounds(width, height)
    local ratio = height/width
    local gameSize = height - db:get('settings', 'border', 250) * math.pow(ratio, 3)

    local panels = {
        firstPrimary = {
            x1 = 0,
            y1 = 0,
            x2 = (width - gameSize) * 0.5,
            y2 = height
        },
        secondPrimary = {
            x1 = (width + gameSize) * 0.5,
            y1 = 0,
            x2 = width,
            y2 = height
        },
        firstSecondary = {
            x1 = (width - gameSize) * 0.5,
            y1 = 0,
            x2 = (width + gameSize) * 0.5,
            y2 = (height - gameSize) * 0.5
        },
        secondSecondary = {
            x1 = (width - gameSize) * 0.5,
            y1 = (height + gameSize) * 0.5,
            x2 = (width + gameSize) * 0.5,
            y2 = height
        }
    }

    return panels
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