PlayerPickupState = Class{__includes = BaseState}

function PlayerPickupState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite; negated in render function of state
    self.player.offsetY = 5
    self.player.offsetX = 0
    self.player:changeAnimation('pickup-' .. self.player.direction)
    self.player.obj = nil 
end

function PlayerPickupState:enter(params)
    
end 

function PlayerPickupState:update(dt)

    -- if we've fully elapsed through one cycle of animation, change back to idle state
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        for k, object in pairs(self.dungeon.currentRoom.objects) do 
            
            if object:collides(self.player) and object.type == 'pot' then
                object.thrown = false 
                object.solid = false 
                self.player.isCarrying = true 
                object.x = self.player.x 
                object.y = self.player.y - self.player.height / 2 - 1
                self.player.obj = object 

                self.player:changeState('carry')
            else 
                self.player:changeState('idle')
            end 

        end 
        
    end

end

function PlayerPickupState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], 
    gFrames[anim.texture][anim:getCurrentFrame()],
    math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))

end 