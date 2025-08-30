shaderClass = require("src.utils.shaders")
Object = require("src.utils.classic")

Renderer = Object:extend()


function Renderer:new()
    self.shaders = Shaders()
    self:updateFont()
end

function Renderer:updateFont()
    self.font = love.graphics.newFont(orchestrator.db.settings.game.font.size)
    love.graphics.setFont(self.font)
end

function Renderer:render()
end