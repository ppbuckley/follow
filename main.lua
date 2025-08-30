function loadModules()
    -- Load utility modules
    flux = require("src.utils.flux")
    utils = require("src.utils.utils")
    
    -- Load managers
    orchestratorClass = require("src.orchestrator")
    rendererClass = require("src.renderer")
    inputSystemClass = require("src.sys.inputSystem")
end

function love.load()
    -- Import modules
    loadModules()
    
    -- Instantiate systems
    orchestrator = Orchestrator()
    renderer = Renderer()
    sysInput = InputSystem()
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

function love.mousepressed(x, y, button, istouch)
    sysInput:mousePressed(x, y, button, istouch)
end

function love.resize()
    orchestrator:refresh()
end