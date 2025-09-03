utils = {}

function utils.toRGB(r, g, b, a)
    -- Handle hex code input
    if type(r) == "string" then
        local hex = r:gsub("#", "")
        
        -- Handle 3-digit hex (#RGB)
        if #hex == 3 then
            hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
        end
        
        -- Handle 6-digit hex (#RRGGBB) or 8-digit hex (#RRGGBBAA)
        if #hex == 6 or #hex == 8 then
            r = tonumber(hex:sub(1, 2), 16)
            g = tonumber(hex:sub(3, 4), 16)
            b = tonumber(hex:sub(5, 6), 16)
            a = 255 -- g is second param if provided
            -- a = #hex == 8 and tonumber(hex:sub(7, 8), 16) or (g or 255) -- g is second param if provided
        else
            error("Invalid hex color: " .. r)
        end
    end
    
    -- Default alpha to 255 if not provided
    a = a or 255
    
    return {
        r / 255,
        g / 255,
        b / 255,
        a / 255
    }
end

function utils.filter(list, test)
    if not list then return end
    local newList = {}
    for i = 1, #list do
        if test(list[i]) then
            table.insert(newList, list[i])
        end
    end
    return newList
end

function utils.coalesce(list, value)
    if not list then return end
    local newList = {}
    for i = 1, #list do
        if list[i] then
            table.insert(newList, list[i])
        else
            table.insert(newList, value)
        end
    end
    return newList
end

function utils.getRandomColor(seed)
    local randomColor = {
        love.math.random(100, 200),
        love.math.random(100, 200),
        love.math.random(100, 200),
        255
    }
    return randomColor
end

function utils.colorDifference(color1, color2)
    r1, g1, b1, a1 = unpack(color1)
    r2, g2, b2, a2 = unpack(color2)

    return {
        r1 - r2,
        g1 - g2,
        b1 - b2,
        1
    }
end

function utils.colorMultiply(color, factor)
    r, g, b, a = unpack(color)
    return {
        r * factor,
        g * factor,
        b * factor,
        (a or 1) * factor
    }
end

function utils.opposite(direction)
    x, y = unpack(direction)

    return {
        -x,
        -y
    }
end

function utils.choose(list)
    if #list == 0 then return nil end
    local idx = love.math.random(1, #list)
    return list[idx]
end

function utils.chooseMany(list, count)
    if #list == 0 then return nil end
    
    -- Single item (backward compatible)
    if not count or count == 1 then
        local idx = love.math.random(1, #list)
        return list[idx]
    end
    
    if count <= 0 then return {} end
    
    -- Create a copy to avoid modifying original
    local pool = {}
    for i = 1, #list do
        pool[i] = list[i]
    end
    
    -- Pick items by swapping chosen ones to the end
    local result = {}
    local poolSize = #pool
    
    for i = 1, math.min(count, poolSize) do
        local idx = love.math.random(1, poolSize - i + 1)
        result[i] = pool[idx]
        -- Swap chosen item with last unpicked item
        pool[idx] = pool[poolSize - i + 1]
    end
    
    return result
end

function utils.chooseValue(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    
    if #keys == 0 then return nil, nil end
    
    local key = keys[love.math.random(1, #keys)]
    return key, tbl[key]
end

-- Convert RGB (0-1) to HSL
function utils.rgbToHsl(color)
    r, g, b = unpack(color)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, l = 0, 0, (max + min) / 2
    
    if max ~= min then
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)
        
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    return {
        h, s, l
    }
end

-- Convert HSL to RGB (0-1)
function utils.hslToRgb(color)
    h, s, l = unpack(color)
    if s == 0 then
        return l, l, l
    end
    
    local function hue2rgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end
    
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    
    return {
        hue2rgb(p, q, h + 1/3),
        hue2rgb(p, q, h),
        hue2rgb(p, q, h - 1/3)
    }
end

-- Interpolate between two colours
function utils.lerpColour(color1, color2, t)
    t = math.max(0, math.min(1, t))
    r1, g1, b1, a1 = unpack(color1)
    r2, g2, b2, a2 = unpack(color2)
    local h1, s1, l1 = unpack(utils.rgbToHsl({r1, g1, b1}))
    local h2, s2, l2 = unpack(utils.rgbToHsl({r2, g2, b2}))
    
    -- Handle hue wrapping (shortest path)
    local dh = h2 - h1
    if dh > 0.5 then
        dh = dh - 1
    elseif dh < -0.5 then
        dh = dh + 1
    end
    
    local h = (h1 + dh * t) % 1
    local s = s1 + (s2 - s1) * t
    local l = l1 + (l2 - l1) * t
    
    return utils.hslToRgb({h, s, l})
end

function utils.lerp(a, b, t)
    t = math.max(0, math.min(1, t))
    return a + (b - a) * t
end

function utils.all(tbl, fn)
    for i, v in ipairs(tbl) do
        if not fn(v, i) then
            return false
        end
    end
    return true
end

function utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function utils.remap(value, oldMin, oldMax, newMin, newMax)
    local normalized = (value - oldMin) / (oldMax - oldMin)
    
    -- normalized = utils.clamp(normalized, 0, 1)
    
    return newMin + normalized * (newMax - newMin)
end

function utils.appendInPlace(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + i] = t2[i]
    end
    return t1
end

function utils.every(delay, func)
    local timer = 0
    return function(dt)
        timer = timer + dt
        if timer >= delay then
            timer = timer - delay
            func()
        end
    end
end

function utils.lastItemsFrom(list)
    local lastItems = {}
    for _, tbl in pairs(list) do
        table.insert(lastItems, tbl[#tbl])
    end

    return lastItems
end

-- Basic version for arrays
function utils.contains(array, value)
    for i = 1, #array do
        if array[i] == value then
            return true
        end
    end
    return false
end

function utils.product(...)
    local arrays = {...}
    local n = #arrays
    
    -- Handle empty input
    if n == 0 then
        return function() return nil end
    end
    
    -- Initialize indices
    local indices = {}
    for i = 1, n do
        indices[i] = 1
        if #arrays[i] == 0 then
            -- If any array is empty, product is empty
            return function() return nil end
        end
    end
    
    local done = false
    
    return function()
        if done then return nil end
        
        -- Build current combination
        local result = {}
        for i = 1, n do
            result[i] = arrays[i][indices[i]]
        end
        
        -- Increment indices
        local carry = 1
        for i = n, 1, -1 do
            indices[i] = indices[i] + carry
            carry = 0
            
            if indices[i] > #arrays[i] then
                indices[i] = 1
                carry = 1
            end
        end
        
        -- If we carried past the first array, we're done
        if carry == 1 then
            done = true
        end
        
        return unpack(result)
    end
end

function utils.productTables(...)
    local arrays = {...}
    local n = #arrays
    
    if n == 0 then
        return function() return nil end
    end
    
    local indices = {}
    for i = 1, n do
        indices[i] = 1
        if #arrays[i] == 0 then
            return function() return nil end
        end
    end
    
    local done = false
    
    return function()
        if done then return nil end
        
        local result = {}
        for i = 1, n do
            result[i] = arrays[i][indices[i]]
        end
        
        -- Increment indices
        local carry = 1
        for i = n, 1, -1 do
            indices[i] = indices[i] + carry
            carry = 0
            
            if indices[i] > #arrays[i] then
                indices[i] = 1
                carry = 1
            end
        end
        
        if carry == 1 then
            done = true
        end
        
        return result
    end
end

function utils.getKeys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

function utils.getValues(tbl)
    local values = {}
    for _, v in pairs(tbl) do
        table.insert(values, v)
    end
    return values
end

function prettyPrint(tbl, indent, visited)
    indent = indent or 0
    visited = visited or {}
    
    -- Handle non-table types
    if type(tbl) ~= "table" then
        if type(tbl) == "string" then
            return string.format('"%s"', tbl:gsub('"', '\\"'))
        else
            return tostring(tbl)
        end
    end
    
    -- Handle circular references
    if visited[tbl] then
        return "<circular reference>"
    end
    visited[tbl] = true
    
    local parts = {}
    local hasArray = false
    local hasHash = false
    local maxIndex = 0
    
    -- First pass: determine table structure
    for k, v in pairs(tbl) do
        if type(k) == "number" and k >= 1 and k == math.floor(k) then
            hasArray = true
            maxIndex = math.max(maxIndex, k)
        else
            hasHash = true
        end
    end
    
    -- Check if it's a pure sequential array
    local isPureArray = hasArray and not hasHash
    if isPureArray then
        for i = 1, maxIndex do
            if tbl[i] == nil then
                isPureArray = false
                break
            end
        end
    end
    
    local indentStr = string.rep("  ", indent)
    local innerIndentStr = string.rep("  ", indent + 1)
    
    -- Handle empty table
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    if count == 0 then
        return "{}"
    end
    
    table.insert(parts, "{")
    
    -- Process array part first (if it's a pure array)
    if isPureArray then
        for i = 1, maxIndex do
            local v = tbl[i]
            local valueStr = prettyPrint(v, indent + 1, visited)
            table.insert(parts, innerIndentStr .. valueStr .. (i < maxIndex and "," or ""))
        end
    else
        -- Mixed table: process all keys
        local keys = {}
        for k in pairs(tbl) do
            table.insert(keys, k)
        end
        
        -- Sort keys for consistent output
        table.sort(keys, function(a, b)
            -- Numbers first, then strings
            if type(a) ~= type(b) then
                return type(a) == "number"
            end
            if type(a) == "number" then
                return a < b
            else
                return tostring(a) < tostring(b)
            end
        end)
        
        for i, k in ipairs(keys) do
            local v = tbl[k]
            local keyStr
            
            if type(k) == "number" then
                keyStr = "[" .. k .. "]"
            elseif type(k) == "string" and k:match("^[%a_][%w_]*$") then
                -- Valid identifier, can use without quotes
                keyStr = k
            else
                -- Need quotes or brackets
                keyStr = "[" .. prettyPrint(k, 0, visited) .. "]"
            end
            
            local valueStr = prettyPrint(v, indent + 1, visited)
            
            -- Format based on value type
            if type(v) == "table" and next(v) ~= nil then
                -- Non-empty table: put on next line
                local lines = {}
                for line in valueStr:gmatch("[^\n]+") do
                    table.insert(lines, line)
                end
                
                if #lines == 1 then
                    -- Single line table
                    table.insert(parts, innerIndentStr .. keyStr .. " = " .. valueStr .. (i < #keys and "," or ""))
                else
                    -- Multi-line table
                    table.insert(parts, innerIndentStr .. keyStr .. " = " .. lines[1])
                    for j = 2, #lines do
                        table.insert(parts, innerIndentStr .. lines[j])
                    end
                    if i < #keys then
                        parts[#parts] = parts[#parts] .. ","
                    end
                end
            else
                -- Simple value
                table.insert(parts, innerIndentStr .. keyStr .. " = " .. valueStr .. (i < #keys and "," or ""))
            end
        end
    end
    
    table.insert(parts, indentStr .. "}")
    
    -- Clean up visited for this table
    visited[tbl] = nil
    
    return table.concat(parts, "\n")
end

-- Wrapper function for easier use
function pp(tbl)
    print(prettyPrint(tbl))
end

function utils.between(v, a, b)
    return (a < v) and (b > v)
end

function utils.pointInsideBox(point, bounds)
    local isBetweenX = point.x > bounds.x1 and point.x < bounds.x2
    local isBetweenY = point.y > bounds.y1 and point.y < bounds.y2

    return isBetweenX and isBetweenY
end

function utils.expandBounds(bounds, distance)
    return {
        x1 = bounds.x1 - distance,
        y1 = bounds.y1 - distance,
        x2 = bounds.x2 + distance,
        y2 = bounds.y2 + distance,
    }
end

function utils.shiftBounds(bounds, vector)
    return {
        x1 = bounds.x1 + vector.x,
        y1 = bounds.y1 + vector.y,
        x2 = bounds.x2 + vector.x,
        y2 = bounds.y2 + vector.y,
    }
end

function utils.getRandomPointOutsideBox(boxX1, boxY1, boxX2, boxY2, windowWidth, windowHeight)
    -- Ensure box coordinates are properly ordered
    local minX = math.min(boxX1, boxX2)
    local maxX = math.max(boxX1, boxX2)
    local minY = math.min(boxY1, boxY2)
    local maxY = math.max(boxY1, boxY2)
    
    -- Calculate areas outside the box
    local areas = {}
    
    -- Top area (above box)
    if minY > 0 then
        table.insert(areas, {
            x1 = 0, y1 = 0,
            x2 = windowWidth, y2 = minY,
            area = windowWidth * minY
        })
    end
    
    -- Bottom area (below box)
    if maxY < windowHeight then
        table.insert(areas, {
            x1 = 0, y1 = maxY,
            x2 = windowWidth, y2 = windowHeight,
            area = windowWidth * (windowHeight - maxY)
        })
    end
    
    -- Left area (left of box, excluding top/bottom overlap)
    if minX > 0 then
        table.insert(areas, {
            x1 = 0, y1 = minY,
            x2 = minX, y2 = maxY,
            area = minX * (maxY - minY)
        })
    end
    
    -- Right area (right of box, excluding top/bottom overlap)
    if maxX < windowWidth then
        table.insert(areas, {
            x1 = maxX, y1 = minY,
            x2 = windowWidth, y2 = maxY,
            area = (windowWidth - maxX) * (maxY - minY)
        })
    end
    
    -- If no valid areas (box fills window), return nil
    if #areas == 0 then
        return nil, nil
    end
    
    -- Calculate total area
    local totalArea = 0
    for _, area in ipairs(areas) do
        totalArea = totalArea + area.area
    end
    
    -- Pick a random point weighted by area
    local randomValue = love.math.random() * totalArea
    local accumulatedArea = 0
    
    for _, area in ipairs(areas) do
        accumulatedArea = accumulatedArea + area.area
        if randomValue <= accumulatedArea then
            -- Generate random point within this area
            local x = love.math.random() * (area.x2 - area.x1) + area.x1
            local y = love.math.random() * (area.y2 - area.y1) + area.y1
            return x, y
        end
    end
    
    -- Fallback (shouldn't happen)
    local area = areas[1]
    return love.math.random() * (area.x2 - area.x1) + area.x1,
           love.math.random() * (area.y2 - area.y1) + area.y1
end

function utils.chooseManyWeighted(list, count, weightFunc)
    if #list == 0 then return nil end
    
    -- Extract weights using the function if provided
    local weights
    if weightFunc then
        weights = {}
        for i, item in ipairs(list) do
            weights[i] = weightFunc(item) or 1
        end
    end
    
    -- Single item (backward compatible)
    if not count or count == 1 then
        if weights then
            return utils.chooseWeightedWithFunc(list, weightFunc)
        else
            return list[love.math.random(1, #list)]
        end
    end
    
    if count <= 0 then return {} end
    
    -- If no weight function, use original unweighted logic
    if not weightFunc then
        local pool = {}
        for i = 1, #list do
            pool[i] = list[i]
        end
        
        local result = {}
        local poolSize = #pool
        
        for i = 1, math.min(count, poolSize) do
            local idx = love.math.random(1, poolSize - i + 1)
            result[i] = pool[idx]
            pool[idx] = pool[poolSize - i + 1]
        end
        
        return result
    end
    
    -- Weighted selection without replacement
    local result = {}
    local remainingIndices = {}
    local remainingWeights = {}
    
    -- Initialize with weights from function
    for i = 1, #list do
        remainingIndices[i] = i
        remainingWeights[i] = weights[i]
    end
    
    -- Pick items
    for i = 1, math.min(count, #list) do
        -- Calculate total weight
        local totalWeight = 0
        for j = 1, #remainingWeights do
            totalWeight = totalWeight + remainingWeights[j]
        end
        
        if totalWeight <= 0 then break end
        
        -- Pick weighted random
        local random = love.math.random() * totalWeight
        local accumulated = 0
        local chosenIndex = nil
        
        for j = 1, #remainingWeights do
            accumulated = accumulated + remainingWeights[j]
            if random <= accumulated then
                chosenIndex = j
                break
            end
        end
        
        -- Add to result
        if chosenIndex then
            result[i] = list[remainingIndices[chosenIndex]]
            
            -- Remove from remaining
            remainingIndices[chosenIndex] = remainingIndices[#remainingIndices]
            remainingWeights[chosenIndex] = remainingWeights[#remainingWeights]
            table.remove(remainingIndices)
            table.remove(remainingWeights)
        end
    end
    
    return result
end

-- Helper for single weighted choice with function
function utils.chooseWeightedWithFunc(list, weightFunc)
    local totalWeight = 0
    for i, item in ipairs(list) do
        totalWeight = totalWeight + (weightFunc(item) or 1)
    end
    
    if totalWeight <= 0 then
        return list[love.math.random(1, #list)]
    end
    
    local random = love.math.random() * totalWeight
    local accumulated = 0
    
    for i, item in ipairs(list) do
        accumulated = accumulated + (weightFunc(item) or 1)
        if random <= accumulated then
            return item
        end
    end
    
    return list[#list]
end

function utils.average(numbers_table)
    local sum = 0
    local count = 0

    -- Iterate through the table to sum the numbers
    for _, value in ipairs(numbers_table) do
        -- Ensure the value is a number before adding to the sum
        if type(value) == "number" then
            sum = sum + value
            count = count + 1
        end
    end

    -- Calculate the average if there are numbers in the table
    if count > 0 then
        return sum / count
    else
        return 0 -- Return 0 or handle as an error if the table is empty or contains no numbers
    end
end

function utils.difference(list1, list2)
    -- Create a set from list2 for O(1) lookup
    local set2 = {}
    for _, item in ipairs(list2) do
        set2[item] = true
    end
    
    -- Build result with items from list1 not in set2
    local result = {}
    for _, item in ipairs(list1) do
        if not set2[item] then
            table.insert(result, item)
        end
    end
    
    return result
end


function copy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    
    if orig_type == 'table' then
        -- Check if we've already copied this table (handles circular references)
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            
            -- Copy metatable
            local orig_meta = getmetatable(orig)
            if orig_meta then
                setmetatable(copy, table.copy(orig_meta, copies))
            end
            
            -- Copy all key-value pairs
            for orig_key, orig_value in next, orig, nil do
                copy[table.copy(orig_key, copies)] = table.copy(orig_value, copies)
            end
        end
    else
        -- Non-table values are copied directly
        copy = orig
    end
    
    return copy
end

table.copy = copy

-- Get the median of a table.
function utils.weightedMedian(weightTable)
    -- Convert hashtable to array of {value, weight} pairs
    local items = {}
    local totalWeight = 0
    
    for value, weight in pairs(weightTable) do
        if weight > 0 and type(value) == "number" then  -- Only include positive weights
            table.insert(items, {value = value, weight = weight})
            totalWeight = totalWeight + weight
        end
    end
    
    -- Handle edge cases
    if #items == 0 then
        return nil
    elseif #items == 1 then
        return items[1].value
    end
    
    -- Sort by value
    table.sort(items, function(a, b)
        return a.value < b.value
    end)
    
    -- Find weighted median
    local halfWeight = totalWeight / 2
    local cumulativeWeight = 0
    
    for i, item in ipairs(items) do
        cumulativeWeight = cumulativeWeight + item.weight
        
        if cumulativeWeight >= halfWeight then
            -- Check if we're exactly at the midpoint
            if cumulativeWeight == halfWeight and i < #items then
                -- Return average of current and next value
                return (item.value + items[i + 1].value) / 2
            else
                return item.value
            end
        end
    end
    
    -- Shouldn't reach here, but return last value as fallback
    return items[#items].value
end

function arange(start, stop, step)
    -- Handle different argument patterns like numpy
    if stop == nil then
        -- arange(stop) -> arange(0, stop, 1)
        stop = start
        start = 0
        step = 1
    elseif step == nil then
        -- arange(start, stop) -> arange(start, stop, 1)
        step = 1
    end
    
    -- Validate step
    if step == 0 then
        error("Step cannot be zero")
    end
    
    local result = {}
    local i = 1
    local current = start
    
    -- Handle both positive and negative steps
    if step > 0 then
        while current < stop do
            result[i] = current
            current = current + step
            i = i + 1
        end
    else
        while current > stop do
            result[i] = current
            current = current + step
            i = i + 1
        end
    end
    
    return result
end

table.arange = arange;

return utils

