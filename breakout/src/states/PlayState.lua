--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level

    self.recoverPoints = 5000
    --timer for powerup spawns
    self.powerupTimer = 0
    self.powerup = Powerup()
    --probably don't need this 
    self.powerups = {} 
    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)

    --track all balls in play
    self.extraBalls = {self.ball}
    self.ballcount = 1

    --track score for upgrading paddle size
    self.pointsToUpgrade = 0
    self.hasKey = false 

end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    --track timer for spawning powerup 
    self.powerupTimer = self.powerupTimer + dt 
    if self.powerupTimer > MIN_POWERUP_TIMER + math.random(0,5) then 
        --self.powerup.inPlay = true 
        self.powerup.inPlay = true 
        --self.powerupTimer = 0
    end 
    -- update positions based on velocity
    self.paddle:update(dt)
    --self.ball:update(dt)
    if self.powerup.inPlay then 
        self.powerup:update(dt)
    end 
    -- If paddle hits a powerup, check what kind of powerup it is,
    -- and implement it 

    if self.powerup:collides(self.paddle) then
        self.powerup.inPlay = false
        -- if it is type 'addballs', spawn 2 extra balls
        if self.powerup.type == 'addballs' then
            extra1 = Ball(1)
            extra1.dx = math.random(-200, 200)
            extra1.dy = math.random(-50, -60)
            extra1.x = self.paddle.x + (self.paddle.width / 2) - 4
            extra1.y = self.paddle.y - 8
            extra2 = Ball(7)
            extra2.dx = math.random(-200, 200)
            extra2.dy = math.random(-50, -60)
            extra2.x = self.paddle.x + (self.paddle.width / 2) - 4
            extra2.y = self.paddle.y - 8
            table.insert(self.extraBalls, extra1)
            table.insert(self.extraBalls, extra2)
            table.insert(self.extraBalls, extra1)
            table.insert(self.extraBalls, extra1)
            self.ballcount = self.ballcount + 2
        -- if it is type 'key' allow the ball to brick locked bricks
        elseif self.powerup.type == 'key' then
            self.hasKey = true
        end 
    end 
    for k, ball in pairs(self.extraBalls) do 
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()

        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)
                -- if pointsToUpgrade is hit, increase the size of the paddle
                if self.paddle.size < 4 then --stop tracking pointsToUpgrade if paddle is max size
                    self.pointsToUpgrade = self.pointsToUpgrade + (brick.tier * 200 + brick.color * 25)
                    if self.pointsToUpgrade > 100 then 
                        self.paddle:resize(1)
                        self.pointsToUpgrade = 0
                    end 
                end 

                -- trigger the brick's hit function, which removes it from play
                if brick.type == 'normal' then 
                    brick:hit()
                elseif brick.type == 'locked' and self.hasKey then 
                    brick:hit()
                end 

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
    end
end 

    for k, ball in pairs(self.extraBalls) do 
    -- if ball goes below bounds, make it nil and decrease the current ballcount
        if ball.y >= VIRTUAL_HEIGHT then
            self.extraBalls[k] = nil
            ball.inPlay = false
            self.ballcount = self.ballcount - 1
            ball.y = 1
            ball.dy = 0
            ball.dx = 0
        end 
        --if all the balls have fallen, decrease health
        if self.ballcount == 0 then 
            self.health = self.health - 1
            gSounds['hurt']:play()
            --reset ballcount for next time
            self.ballcount = 1
            --decrease size of paddle
            if self.paddle.size > 1 then 
                self.paddle:resize(-1)
            end 
            -- if health is 0, game over 
            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            --otherwise go back to serve state
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints
                })
            end
        end
    end 

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    --update all the balls in play
    for k, extraBall in pairs(self.extraBalls) do
        if extraBall.x ~= nil and extraBall.y ~= nil then 
            extraBall:update(dt)
        end
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    --self.ball:render()
    renderScore(self.score)
    renderHealth(self.health)
    --only render powerup if powerup.inPlay is true, 
    --and the powerup hasn't reached the end of the screen
    if self.powerup.inPlay and self.powerup.y <= VIRTUAL_HEIGHT then 
        self.powerup:render()
    --Reset the timer and powerup once the current powerup falls past the paddle
    elseif self.powerup.y >= VIRTUAL_HEIGHT or self.powerup:collides(self.paddle) then 
        self.powerupTimer = 0
        self.powerup:reset()
    end 
    --render all the balls in play
    for k, extraBall in pairs(self.extraBalls) do 
        if extraBall.inPlay then
            extraBall:render()
        end 
    end 
    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

end 

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end