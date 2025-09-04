Object = require("src.utils.classic")

GridSystem = Object:extend()

function GridSystem:new(size)
    self.id = db:createEntity({
        cells = table.arange(math.pow(size, 2)),
        size = size
    })
end

function GridSystem:getCoords(id, component)
    local cells = db.components[component or "cells"][id]
    local size = db.components.size[self.id]

    local coords = {}

    for _, cell in pairs(cells) do
        table.insert(coords, {cell % size, math.floor(cell / size)})
    end

    return coords
end

function GridSystem:lineToVertices(cells)
    local size = db.components.size[self.id]
    local deltas = {}
    deltas[1] = true
    deltas[-1] = true
    deltas[size] = true
    deltas[-size] = true
    
    local delta
    local points = {}
    for i = 1, #cells - 1 do
        if (cells[i + 1] - cells[i]) ~= delta then
            local segStart = cells[i]
            table.insert(points, segStart)
        end
        delta = cells[i + 1] - cells[i]
        if not deltas[delta] then error("bad line") end
    end

    table.insert(points, cells[#cells])

    return points
end