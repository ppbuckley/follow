Object = require("src.utils.classic")

DesignSystem = Object:extend()

function DesignSystem:new()
    self.colors = {
        white = db:createEntity({color = utils.toRGB("#FFFFFF")}),
        offwhite = db:createEntity({color = utils.toRGB("#F3F3F3")}),
        grey = db:createEntity({color = utils.toRGB("#DCDCDC")}),
        black = db:createEntity({color = utils.toRGB("#000000")}),
        accent = db:createEntity({color = utils.toRGB("#FE6F5E")}),
    }

    self.assets = {
        layout = db:createEntity({
            image = love.graphics.newImage("src/assets/layout.png", {mipmaps=true}),
            res = 512
        })
    }
end

function DesignSystem:getImage(image)
    return db.components.image[self.assets[image]], db.components.res[self.assets[image]]
end

function DesignSystem:getColor(color)
    return db.components.color[self.colors[color]]
end

function DesignSystem:setColor(color)
    love.graphics.setColor(self:getColor(color))
end