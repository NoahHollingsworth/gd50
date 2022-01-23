--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states
    self.consumable = def.consumable
    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height
    self.scaleX = def.scaleX or 1 
    self.scaleY = def.scaleY or 1

    -- default empty collision callback
    self.onCollide = function() end

    self.onConsume = function() end 
end

function GameObject:collides(target)
    return not (target.x > self.x + self.width or self.x > target.x + target.width or
            target.y > self.y + self.height or self.y > target.y + target.height + 0.5)
end
 
function GameObject:update(dt)

end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX + (self.width*(1 - self.scaleX)), self.y + adjacentOffsetY + (self.height*(1 - self.scaleX)), 
        0, self.scaleX, self.scaleY)
    --love.graphics.setColor(1, 0, 1, 1)
    --love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    --love.graphics.setColor(1, 1, 1, 1)
end