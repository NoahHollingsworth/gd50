--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, shiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    -- is this a shiny block, default to false
    self.shiny = shiny or false 

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 300)
    self.psystem:setParticleLifetime(0.75)
    self.psystem:setEmissionArea('uniform', 16, 16)
    self.psystem:setEmissionRate(10)
    self.psystem:setColors(1,0,0,0.5, 0,0,1,0.5, 0,1,0,0.5)


end

function Tile:update(dt)
    self.psystem:update(dt)
end 

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
    
    if self.shiny then 
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.psystem, self.x + x + 16, self.y + y + 16, 0, 0.5, 0.5)
    end 
end
