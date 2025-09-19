Object = require("src.utils.classic")

GridSystem = Object:extend()

cellCallbacks = {
    t = function() return true end,
    f = function() return false end
}

function GridSystem:new()
    local size = db:get('game', 'gridSize', 6)
    local cells = {}

    local defaultCellCheck = "t"

    for i, cell in ipairs(table.arange(math.pow(size, 2))) do
        cells[cell] = db:createEntity({
            cellNum = cell,
            coord = {},
            clickBounds = {},
            clickHandler = function ()
                return nil
            end,
            statusHandler = function ()
                return nil
            end
        })
    end

    self.id = db:createEntity({
        cells = cells,
        size = size
    })
    
    self:updateCells()
end

function GridSystem:updateCells()
    local size = db:get('game', 'gridSize', 6)
    local cells = self:getUpdatedCells(size)
    -- db.components.cells[self.id] = cells
    db.components.size[self.id] = size

    db:updateQueries(self.id)
end

function GridSystem:getUpdatedCells(size)
    local gameBounds = db.components.bounds[db:get('display', 'gameBounds')]

    local cellWidth = (gameBounds.x2 - gameBounds.x1) / size
    local cellHeight = (gameBounds.y2 - gameBounds.y1) / size

    local cells = {}

    local defaultCellCheck = "t"

    for cell, cellNum in pairs(db.components.cells[self.id]) do
        local coord = self:getCoord(cell, size)
        local x, y = unpack(coord)

        local cellCheck = defaultCellCheck

        db.components.cellNum[cellNum] = cell
        db.components.coord[cellNum] = coord
        db.components.clickBounds[cellNum] = {
            x1 = x * cellWidth + gameBounds.x1,
            y1 = y * cellHeight + gameBounds.y1,
            x2 = x * cellWidth + gameBounds.x1 + cellWidth,
            y2 = y * cellHeight + gameBounds.y1 + cellHeight,
        }
        db.components.clickHandler[cellNum] = function () return cell end
        db.components.statusHandler[cellNum] = self:getStatusHandler(cellCheck)
    end

    return cells
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