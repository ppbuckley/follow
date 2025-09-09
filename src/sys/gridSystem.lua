Object = require("src.utils.classic")

GridSystem = Object:extend()

cellCallbacks = {
    t = function() return true end,
    f = function() return false end
}

function GridSystem:new(size)
    local gameBounds = db.components.bounds[db:get('display', 'gameBounds', 0)]

    local cellWidth = (gameBounds.x2 - gameBounds.x1) / size
    local cellHeight = (gameBounds.y2 - gameBounds.y1) / size

    local cells = {}

    local defaultCellCheck = "t"

    for i, cell in ipairs(table.arange(math.pow(size, 2))) do
        local coord = self:getCoord(cell, size)
        local x, y = unpack(coord)

        local cellCheck = defaultCellCheck

        cells[cell] = db:createEntity({
            cellNum = cell,
            coord = coord,
            clickBounds = {
                x1 = x * cellWidth + gameBounds.x1,
                y1 = y * cellHeight + gameBounds.y1,
                x2 = x * cellWidth + gameBounds.x1 + cellWidth,
                y2 = y * cellHeight + gameBounds.y1 + cellHeight,
            },
            clickHandler = function ()
                return cell
            end,
            statusHandler = self:getStatusHandler(cellCheck)
        })
    end

    self.id = db:createEntity({
        cells = cells,
        size = size
    })
end

function GridSystem:getStatusHandler(cellCheck)
    return {
        name = cellCheck,
        callback = cellCallbacks[cellCheck]
    }
end

function GridSystem:getCoords(id, component)
    local cells = db.components[component or "cells"][id]
    local size = db.components.size[self.id]

    local coords = {}

    for _, cell in pairs(cells) do
        table.insert(coords, self:getCoord(cell, size))
    end

    return coords
end

function GridSystem:getCoord(cell, size)
    return {cell % size, math.floor(cell / size)}
end

function GridSystem:getCell(coord, size)
    local x, y = unpack(coord)
    return y * size + x
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

function GridSystem:cellsToBounds(cells)
    local size = db.components.size[self.id]

    local minX, minY, maxX, maxY = size, size, 0, 0
    for i, cell in pairs(cells) do
        local x, y = unpack(self:getCoord(cell, size))
        if x < minX then minX = x end
        if y < minY then minY = y end
        if x > maxX then maxX = x end
        if y > maxY then maxY = y end
    end

    return {
        x1 = minX,
        y1 = minY,
        x2 = maxX,
        y2 = maxY
    }
end