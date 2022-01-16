Powerup = Class{}

function Powerup:init()
    -- simple positional and dimensional variables
    self.width = 16
    self.height = 16

    -- track velocity on Y axis (the only dimension the powerups will move)
    self.dy = POWERUP_SPEED

    self.x = math.random(0, VIRTUAL_WIDTH - 16)
    self.y = 0
    

    -- represents the texture that will be applied to the powerup
    --9 = addBalls, 10 = key
    self.skinOptions = {9,9,9,9,10} --TODO: better way to get weighted choice
    self.skin = self.skinOptions[math.random(5)]
    self.inPlay = false 
    if self.skin == 10 then 
        self.type = 'key'
    else 
        self.type = 'addballs'
    end 
    
end 

function Powerup:update(dt)
    --make the powerup fall towards the paddle
    if self.inPlay then 
        self.y = self.y + (self.dy * dt)
        if self.y >= VIRTUAL_HEIGHT/2 then 
            inPlay = false 
        end 
    end 
end 

function Powerup:render()
    if self.inPlay then 
        love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin], 
        self.x, self.y)
    end 
end 

function Powerup:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end
-- call once current powerup falls past paddle
-- this will set up a new powerup to be spawned 
function Powerup:reset()
    self.x = math.random(0, VIRTUAL_WIDTH - 16)
    self.y = 0
    self.skin = self.skinOptions[math.random(5)]
    if self.skin == 10 then 
        self.type = 'key'
    else 
        self.type = 'addballs'
    end 
    self.inPlay = false 
end 