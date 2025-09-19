Object = require("src.utils.classic")

PlayerSystem = Object:extend()

function PlayerSystem:new(sysGrid)
end

function checkCardinal(cell, dir, size)
    local newDir = cell + dir
    local noRight = dir == 1 and cell % size == (size - 1)
    local noLeft = dir == -1 and cell % size == 0
    local noUp = newDir < 0
    local noDown = newDir > math.pow(size, 2) - 1

    return noRight or noLeft or noUp or noDown
end