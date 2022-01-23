PlayerCarryState = Class{__includes = EntityWalkState}

function PlayerCarryState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite; negated in render function of state
    self.entity.offsetY = 5
    self.entity.offsetX = 0

end

function PlayerCarryState:enter(params)

end 

function PlayerCarryState:update(dt)

    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('carry-left')
        self.entity.obj.x = self.entity.x 
        self.entity.obj.y = self.entity.y - self.entity.height / 2 - 1
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('carry-right')
        self.entity.obj.x = self.entity.x 
        self.entity.obj.y = self.entity.y - self.entity.height / 2 - 1
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('carry-up')
        self.entity.obj.x = self.entity.x 
        self.entity.obj.y = self.entity.y - self.entity.height / 2 - 1
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('carry-down')
        self.entity.obj.x = self.entity.x 
        self.entity.obj.y = self.entity.y - self.entity.height / 2 - 1
        
    else
        self.entity:changeState('idle')
    end 

    if love.keyboard.wasPressed('x') then 
        --TODO: throw the pot 
    end 

    EntityWalkState.update(self, dt)

end

function PlayerCarryState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], 
    gFrames[anim.texture][anim:getCurrentFrame()],
    math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
    --love.graphics.setColor(1, 0, 1, 1)
    --love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
    --love.graphics.setColor(1, 1, 1, 1)
end 