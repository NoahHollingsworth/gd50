--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Entity = Class{}

function Entity:init(def)

    -- in top-down games, there are four directions instead of two
    self.direction = 'down'

    self.animations = self:createAnimations(def.animations)

    -- dimensions
    self.x = def.x
    self.y = def.y
    self.width = def.width
    self.height = def.height

    -- drawing offsets for padded sprites
    self.offsetX = def.offsetX or 0
    self.offsetY = def.offsetY or 0

    self.walkSpeed = def.walkSpeed

    self.health = def.health

    -- flags for flashing the entity when hit
    self.invulnerable = false
    self.invulnerableDuration = 0
    self.invulnerableTimer = 0

    -- timer for turning transparency on and off, flashing
    self.flashTimer = 0

    self.dead = false

    -- will this entity spawn a heart when killed
    self.spawnHeart = math.random(1) == 1

    self.type = def.type or 'enemy'

    --is the player carrying a pot
    self.isCarrying = false 
end

function Entity:createAnimations(animations)
    local animationsReturned = {}

    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            texture = animationDef.texture or 'entities',
            frames = animationDef.frames,
            interval = animationDef.interval
        }
    end

    return animationsReturned
end

--[[
    AABB with some slight shrinkage of the box on the top side for perspective.
]]
function Entity:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                self.y + self.height < target.y or self.y > target.y + target.height)
end

function Entity:damage(dmg)
    self.health = self.health - dmg
end

function Entity:heal(heal)
    self.health = self.health + heal
end

function Entity:goInvulnerable(duration)
    self.invulnerable = true
    self.invulnerableDuration = duration
end

function Entity:changeState(name, params)
    self.stateMachine:change(name)
end

function Entity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

-- stop movement when colliding with solid objects 
-- redirect non-player entities
function Entity:solidCollision(target, dt)
    local directions = {'left', 'right', 'up', 'down'}
    if self.direction == 'left' then 
        self.x = self.x - self.walkSpeed * dt 
        if self.x <= target.x + target.width then 
            self.x = target.x + target.width
        end
        if self.type ~= 'player' then 
            self.direction = directions[math.random(#directions)]
            self:changeAnimation('walk-' .. tostring(self.direction))
        end 
    elseif self.direction == 'right' then 
        self.x = self.x + self.walkSpeed * dt 
        if self.x >= target.x - target.width then 
            self.x = target.x - self.width
        end
        if self.type ~= 'player' then 
            self.direction = directions[math.random(#directions)]
            self:changeAnimation('walk-' .. tostring(self.direction))
        end 
    elseif self.direction == 'up' then 
        self.y = self.y + self.walkSpeed * dt 
        if self.y <= target.y - target.height then 
            self.y = target.y + target.height
        end 
        if self.type ~= 'player' then 
            self.direction = directions[math.random(#directions)]
            self:changeAnimation('walk-' .. tostring(self.direction))
        end 
    elseif self.direction == 'down' then 
        self.y = self.y - self.walkSpeed * dt 
        if self.y >= target.y + target.height then 
            self.y = target.y - target.height
        end 
        if self.type ~= 'player' then 
            self.direction = directions[math.random(#directions)]
            self:changeAnimation('walk-' .. tostring(self.direction))
        end 
    end 
end

function Entity:update(dt)
    if self.invulnerable then
        self.flashTimer = self.flashTimer + dt
        self.invulnerableTimer = self.invulnerableTimer + dt

        if self.invulnerableTimer > self.invulnerableDuration then
            self.invulnerable = false
            self.invulnerableTimer = 0
            self.invulnerableDuration = 0
            self.flashTimer = 0
        end
    end

    self.stateMachine:update(dt)

    if self.currentAnimation then
        self.currentAnimation:update(dt)
    end
end

function Entity:processAI(params, dt)
    self.stateMachine:processAI(params, dt)
end

function Entity:render(adjacentOffsetX, adjacentOffsetY)
    
    -- draw sprite slightly transparent if invulnerable every 0.04 seconds
    if self.invulnerable and self.flashTimer > 0.06 then
        self.flashTimer = 0
        love.graphics.setColor(1, 1, 1, 64/255)
    end

    self.x, self.y = self.x + (adjacentOffsetX or 0), self.y + (adjacentOffsetY or 0)
    self.stateMachine:render()
    love.graphics.setColor(1, 1, 1, 1)
    self.x, self.y = self.x - (adjacentOffsetX or 0), self.y - (adjacentOffsetY or 0)
end