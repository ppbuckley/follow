print(love.filesystem.getSaveDirectory())
-- In main.lua or before you need the module

function loadModules()
    -- Add your custom paths to Love2D's require path
    local requirePath = love.filesystem.getRequirePath()
    requirePath = requirePath .. ";src/modules/share/lua/5.4/?.lua"
    requirePath = requirePath .. ";src/modules/share/lua/5.4/?/init.lua"
    love.filesystem.setRequirePath(requirePath)

    -- Load utility modules
    flux = require("src.utils.flux")
    utils = require("src.utils.utils")
    lume = require("src.utils.lume")
    bitser = require("bitser")
    
    -- Load managers
    databaseClass = require("src.database")
    db = DB()
    orchestratorClass = require("src.orchestrator")
    rendererClass = require("src.renderer")
    inputSystemClass = require("src.sys.inputSystem")
    playerSystemClass = require("src.sys.playerSystem")
    designSystemClass = require("src.sys.designSystem")
end

function love.load()
    -- Import modules
    loadModules()
    
    -- Instantiate systems
    renderer = Renderer()
    sysInput = InputSystem()
    orchestrator = Orchestrator()
end

function love.draw()
    renderer:render()
end

function love.update(dt)
    flux.update(dt)
    sysInput:update()
end

-- Handle inputs
function love.keypressed(key)
    sysInput:keyPressed(key)
end

function love.keyreleased(key)
    sysInput:keyReleased(key)
end

function love.mousepressed(x, y, button, istouch)
    sysInput:mousePressed(x, y, button, istouch)
end

function love.resize()
    orchestrator:resize()
end