Object = require("src.utils.classic")

PlayerSystem = Object:extend()

function PlayerSystem:new(sysGrid)
    local cells = lume.concat(table.arange(1, 4), table.arange(4 + db.components.size[sysGrid.id] - 1, 4 + db.components.size[sysGrid.id] + 4))
    local points = sysGrid:lineToVertices(cells)
    local bounds = sysGrid:cellsToBounds(points)
    local solutionSpace = {
        12 - (bounds.x2 - bounds.x1),
        12 - (bounds.y2 - bounds.y1)
    }
    self.line = db:createEntity({
        cells = cells,
        points = points,
        bounds = bounds,
        solutionSpace = solutionSpace
    })
end

function PlayerSystem:moveActivePoint(key, sysGrid)
    local size = db.components.size[sysGrid.id]
    local dirs = {}
    dirs["right"] = { 1, "add"}
    dirs["left"] = { -1, "add"}
    dirs["down"] = { size, "add"}
    dirs["up"] = { -size, "add"}
    dirs["backspace"] = { true, "add"}
    dirs["delete"] = { true, "add"}
    dirs["d"] = { 1, "shift"}
    dirs["a"] = { -1, "shift"}
    dirs["s"] = { size, "shift"}
    dirs["w"] = { -size, "shift"}

    local dir = dirs[key]

    if not dir then return end

    local direction, moveType = unpack(dir)


    if moveType == "add" then
        local cells = db.components.cells[self.line]
        if key == "backspace" or key == "delete" then
            if #cells > 1 then
                table.remove(cells, #cells)
            end
        else
            local lastCell = cells[#cells]
            local newDir = lastCell + direction
            local noCardinal = checkCardinal(lastCell, direction, size)
            local noCells = lume.any(cells, function (cell)
                return cell == newDir
            end)

            -- Moving point shouldn't go beyond game bounds. Assumes square bounds
            if noCardinal or noCells then return end

            table.insert(cells, newDir)
        end
    elseif moveType == "shift" then
        self:shiftCells(self.line, direction, size)
    end

    self:updateLine(self.line, sysGrid)
end

function PlayerSystem:shiftCells(id, dir, size)
    local bounds = db.components.bounds[id]
    local topLeft = orchestrator.sysGrid:getCell({ bounds.x1, bounds.y1 }, size)
    local bottomRight = orchestrator.sysGrid:getCell({ bounds.x2, bounds.y2 }, size)
    
    local noCardinal1 = checkCardinal(topLeft, dir, size)
    local noCardinal2 = checkCardinal(bottomRight, dir, size)

    if noCardinal1 or noCardinal2 then return end

    db.components.cells[id] = table.add(db.components.cells[id], dir)
    self:updateLine(id, orchestrator.sysGrid)
end

function PlayerSystem:updateLine(id, sysGrid)
    local cells = db.components.cells[id]
    local points = sysGrid:lineToVertices(cells)
    local bounds = sysGrid:cellsToBounds(points)
    local solutionSpace = {
        12 - (bounds.x2 - bounds.x1),
        12 - (bounds.y2 - bounds.y1)
    }

    db:addComponent(id, 'points', points)
    db:addComponent(id, 'bounds', bounds)
    db:addComponent(id, 'solutionSpace', solutionSpace)
end

function checkCardinal(cell, dir, size)
    local newDir = cell + dir
    local noRight = dir == 1 and cell % size == 11
    local noLeft = dir == -1 and cell % size == 0
    local noUp = newDir < 0
    local noDown = newDir > math.pow(size, 2) - 1

    return noRight or noLeft or noUp or noDown
end