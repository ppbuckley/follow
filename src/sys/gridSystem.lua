Object = require("src.utils.classic")

GridSystem = Object:extend()

function GridSystem:new(size)
    self.id = db:createEntity({
        cells = table.arange(math.pow(size, 2)),
        size = size
    })
end

function GridSystem:getCoords()
    local cells = db.components.cells[self.id]
    local size = db.components.size[self.id]

    local coords = {}

    for _, cell in pairs(cells) do
        table.insert(coords, {cell % size, math.floor(cell / size)})
    end

    return coords
end