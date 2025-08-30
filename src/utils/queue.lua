object = require("src.utils.classic")

Queue = object:extend()

function Queue:new()
    self.first = 0
    self.last = -1
end

function Queue:__tostring()
    return string.format("Queue(%s)", table.concat(self:toList(), ", "))
end

function Queue:push(value)
    self.last = self.last + 1
    self[self.last] = value
end

function Queue:pushList(list)
    for _, item in pairs(list) do
        self:push(item)
    end
end

function Queue:pop()
    if self:isEmpty() then
        return nil
    end
    local value = self[self.first]
    self[self.first] = nil  -- Allow garbage collection
    self.first = self.first + 1
    return value
end

function Queue:isEmpty()
    return self.first > self.last
end

function Queue:size()
    return self.last - self.first + 1
end

function Queue:peek()
    if self:isEmpty() then
        return nil
    end
    return self[self.first]
end

function Queue:clear()
    for i = self.first, self.last do
        self[i] = nil
    end
    self.first = 0
    self.last = -1
end

function Queue:toList()
    local items = {}
    local index = 1
    for i = self.first, self.last do
        items[index] = self[i]
        index = index + 1
    end
    return items
end

function Queue:shuffle()
    -- Convert to array for easier shuffling
    local items = self:toList()
    
    -- Fisher-Yates shuffle
    for i = #items, 2, -1 do
        local j = love.math.random(1, i)
        items[i], items[j] = items[j], items[i]
    end
    
    -- Clear and repopulate
    self:clear()
    self:pushList(items)
end