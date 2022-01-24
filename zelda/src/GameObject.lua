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
    
    -- if the object can be thrown 
    self.projectile = def.projectile or false 
    self.dx = 0
    self.dy = 0
    self.direction = 'left'
    self.throwSpeed = 120
    self.thrown = false 

    -- default empty collision callback
    self.onCollide = function() end

    self.onConsume = function() end 
end

function GameObject:collides(target)
    return not (target.x > self.x + self.width or self.x > target.x + target.width or
            target.y > self.y + self.height or self.y > target.y + target.height + 0.5)
end
 
function GameObject:update(dt)
    if self.thrown then 
        self:throw(dt)
    end 
end

function GameObject:throw(dt)
    self.solid = true 
    
    if self.direction == 'left' then 
        self.x = self.x - self.throwSpeed * dt
        
        if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
            self.x = MAP_RENDER_OFFSET_X + TILE_SIZE
        end
    elseif self.direction == 'right' then 
        self.x = self.x + self.throwSpeed * dt

        if self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.width
        end
    elseif self.direction == 'up' then 
        self.y = self.y - self.throwSpeed * dt

        if self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 then 
            self.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2
        end
    elseif self.direction == 'down' then 
        self.y = self.y + self.throwSpeed * dt

        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if self.y + self.height >= bottomEdge then
            self.y = bottomEdge - self.height
        end
    end 

end 

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX + (self.width*(1 - self.scaleX)), self.y + adjacentOffsetY + (self.height*(1 - self.scaleX)), 
        0, self.scaleX, self.scaleY)
    --love.graphics.setColor(1, 0, 1, 1)
    --love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    --love.graphics.setColor(1, 1, 1, 1)
end