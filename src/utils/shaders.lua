Object = require("src.utils.classic")

Shaders = Object:extend()

function Shaders:new()
    local colorShader = [[
        uniform vec4 targetColor;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            vec4 texcolor = Texel(texture, texture_coords);
            
            // If the texture's alpha is 0, return transparent
            if (texcolor.a == 0.0) {
                return vec4(0.0, 0.0, 0.0, 0.0);
            }
            
            // Otherwise, return the target color with the texture's alpha
            return vec4(targetColor.rgb, texcolor.a * targetColor.a);
        }
    ]]
    self.shaders = {
        colorShader = love.graphics.newShader(colorShader)
    }
end