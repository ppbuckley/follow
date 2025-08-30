utils = require("src.utils.utils")
queue = require("src.utils.queue")

Object = require("src.utils.classic")

DB = Object:extend()

function DB:new()
    self.window = {
        border = 250,
        width = love.graphics.getWidth(), 
        height = love.graphics.getHeight(),
        halfWidth = love.graphics.getWidth() * 0.5, 
        halfHeight = love.graphics.getHeight() * 0.5,
        progressBar = {
            border = 50
        }
    }
    self.game = {
        font = {
            size = 24
        },
        colors = Queue(),
        box = {
            length = 200,
            offsetDistance = 0,
            gap = 6,
            lineWidth = 6
        },
        item = {
            defaultColor = {0.3, 0.3, 0.3, 1},
            outline = 4
        },
        level = 3
    }
    
    self.game.colors:push(utils.toRGB(255, 190, 11, 255)) -- "Amber"
    self.game.colors:push(utils.toRGB(255, 0, 110, 255)) -- "Rose"
    self.game.colors:push(utils.toRGB(131, 56, 236, 255)) -- "Blue Violet"
    self.game.colors:push(utils.toRGB(58, 134, 255, 255)) -- "Azure"

    self.game.colors:shuffle()
end