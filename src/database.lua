Object = require("src.utils.classic")

DB = Object:extend()

function DB:new()
    self.nextEntityId = 1
    self.entities = {}
    self.components = {}
    self.queries = {}
    
    -- General game data
    self.data = {
        settings = {},
        progress = {},
        levels = {},
        display = {},
        device = {},
        game = {}
    }

    self:set('settings', 'border', 250)
    self:set('settings', 'fontSize', 24)

    self:set('game', 'gridSize', 12)

    self:updateDisplay()
    
    -- TODO: implement game color methods
    -- self.game.colors:push(utils.toRGB(255, 190, 11, 255)) -- "Amber"
    -- self.game.colors:push(utils.toRGB(255, 0, 110, 255)) -- "Rose"
    -- self.game.colors:push(utils.toRGB(131, 56, 236, 255)) -- "Blue Violet"
    -- self.game.colors:push(utils.toRGB(58, 134, 255, 255)) -- "Azure"
    
    -- self.game.colors:shuffle()
end

function DB:updateDisplay()
    self:set('display', 'width', love.graphics.getWidth())
    self:set('display', 'height', love.graphics.getHeight())
    self:set('display', 'halfWidth', love.graphics.getWidth() * 0.5)
    self:set('display', 'halfHeight', love.graphics.getHeight() * 0.5)
    self:set('display', 'lineWidthDefault', 4)
end

-- Entity management
function DB:createEntity(components)
    local entityId = self.nextEntityId
    self.nextEntityId = self.nextEntityId + 1
    
    self.entities[entityId] = true
    
    -- Add components if provided
    if components then
        for componentType, data in pairs(components) do
            if not self.components[componentType] then
                self.components[componentType] = {}
            end
            self.components[componentType][entityId] = data
        end
    end
    
    self:updateQueries(entityId)
    return entityId
end

function DB:destroyEntity(entityId)
    if not self.entities[entityId] then return false end
    
    -- Remove from all component tables
    for componentType, componentTable in pairs(self.components) do
        componentTable[entityId] = nil
    end
    
    -- Remove from all queries
    for queryName, queryTable in pairs(self.queries) do
        queryTable[entityId] = nil
    end
    
    self.entities[entityId] = nil
    return true
end

-- Component management
function DB:addComponent(entityId, componentType, data)
    if not self.entities[entityId] then return false end
    
    if not self.components[componentType] then
        self.components[componentType] = {}
    end
    
    local hadComponent = self.components[componentType][entityId] ~= nil
    self.components[componentType][entityId] = data
    
    -- Only update queries if composition changed
    self:updateQueries(entityId)
    
    return true
end

function DB:removeComponent(entityId, componentType)
    if not self.entities[entityId] or not self.components[componentType] then 
        return false 
    end
    
    local hadComponent = self.components[componentType][entityId] ~= nil
    self.components[componentType][entityId] = nil
    
    -- Only update queries if composition changed
    if hadComponent then
        self:updateQueries(entityId)
    end
    
    return true
end

function DB:getComponent(entityId, componentType)
    if not self.components[componentType] then return nil end
    return self.components[componentType][entityId]
end

function DB:hasComponent(entityId, componentType)
    return self:getComponent(entityId, componentType) ~= nil
end

-- Query management
function DB:registerQuery(queryName, componentTypes)
    self.queries[queryName] = {}
    
    -- Store query definition for updates
    if not self._queryDefinitions then
        self._queryDefinitions = {}
    end
    self._queryDefinitions[queryName] = componentTypes
    
    -- Populate existing entities
    for entityId in pairs(self.entities) do
        self:updateEntityQuery(entityId, queryName)
    end
end

function DB:updateQueries(entityId)
    if not self._queryDefinitions then return end
    
    for queryName in pairs(self._queryDefinitions) do
        self:updateEntityQuery(entityId, queryName)
    end
end

function DB:updateEntityQuery(entityId, queryName)
    local componentTypes = self._queryDefinitions[queryName]
    local matches = true
    
    for _, componentType in ipairs(componentTypes) do
        if not self:hasComponent(entityId, componentType) then
            matches = false
            break
        end
    end
    
    if matches then
        self.queries[queryName][entityId] = true
    else
        self.queries[queryName][entityId] = nil
    end
end

function DB:getQuery(queryName)
    return self.queries[queryName] or {}
end

-- Utility functions
function DB:entityExists(entityId)
    return self.entities[entityId] ~= nil
end

function DB:getEntityCount()
    local count = 0
    for _ in pairs(self.entities) do
        count = count + 1
    end
    return count
end

-- General data management
function DB:set(category, key, value)
    if not self.data[category] then
        self.data[category] = {}
    end
    self.data[category][key] = value
end

function DB:get(category, key, default)
    if not self.data[category] then
        return default
    end
    local value = self.data[category][key]
    return value ~= nil and value or default
end

function DB:getCategory(category)
    return self.data[category] or {}
end

function DB:setCategory(category, data)
    self.data[category] = data or {}
end

function DB:hasKey(category, key)
    return self.data[category] and self.data[category][key] ~= nil
end