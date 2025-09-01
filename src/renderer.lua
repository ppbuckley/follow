shaderClass = require("src.utils.shaders")
Object = require("src.utils.classic")

Renderer = Object:extend()


function Renderer:new()
    self:updateFont()
    self.shaders = Shaders()
    self.layers = {
        default = {
            draw = {}
        },
        ui = {
            draw = {}
        }
    }

    self.layerOrder = {"default", "ui"}

end

function Renderer:updateFont()
    self.font = love.graphics.newFont(db.game.font.size)
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
    self:add("ui", 1, function()
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.circle("fill", db.window.halfWidth, db.window.halfHeight, 100)
    end)
    
    self:add(nil, 1, function()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.circle("fill", db.window.halfWidth, db.window.halfHeight, 200)
    end)
    
    self:add("ui", 0, function()
        love.graphics.setColor(0, 1, 1, 1)
        love.graphics.circle("fill", db.window.halfWidth, db.window.halfHeight, 150)
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
    self.layers = {
        default = {
            draw = {}
        },
        ui = {
            draw = {}
        }
    }
end