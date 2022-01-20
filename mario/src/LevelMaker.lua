--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- spawn our key and lock
    local key_id = math.random(4)
    local keySpawned = false 
    local keyPickup = false 
    local lockSpawned = false 

    -- TODO: randomize flag and key/lock colors
    -- TODO: animate flag 
    -- TODO: don't allow flags to spawn over empty space

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness, only if it's not the first column (where the player spawns)
        if math.random(7) == 1 and x ~= 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true, 
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
            local keyFrame = math.random(#KEYS)
            -- chance to spawn key, if one hasn't already spawned
            if math.random(25) == 1 and not keySpawned and x > 10 then 
                keyObj = GameObject {
                    texture = 'keys-locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight +1 ) * TILE_SIZE,
                    width = 16, 
                    height = 16, 
                    frame = math.random(4),
                    collidable = true, 
                    consumable = true, 
                    solid = false, 
                    --when the key is picked up, set keyPickup to true 
                    onConsume = function (player, object)
                        gSounds['pickup']:play()
                        keyPickup = true 
                        print(keyPickup)
                    end
                }
            table.insert(objects, keyObj)
            keySpawned = true 
            end 
            --chance to spawn locked block 
            if math.random(10) == 1 and keySpawned and x > 20 and not lockSpawned then 
                local lockObj = GameObject {
                    texture = 'keys-locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight -1 ) * TILE_SIZE,
                    width = 16, 
                    height = 16, 
                    frame = keyObj.frame + 4, --get the same color lock as the key that already spawned
                    collidable = true, 
                    solid = true, 
                    hit = false,
                    --the lock is hit, unlock it only if the key has been picked up
                    onCollide = function (obj)
                        -- After the lock is unlocked, spawn the flag (pole and flag)
                        if keyPickup and not obj.hit then
                            obj.hit = true 
                            gSounds['powerup-reveal']:play()
                            local pole = GameObject {
                                texture = 'poles',
                                x = (width - 4) * TILE_SIZE, 
                                y = (blockHeight - 1) * TILE_SIZE,
                                width = 16, 
                                height = 48, 
                                frame = 5, 
                                collidable = true, 
                                consumable = true,
                                hit = false, 
                                solid = false, 
                                -- When hit, go to next level
                                onConsume = function (player, object)
                                    gSounds['pickup']:play()
                                    gStateMachine:change('play', {
                                        score = player.score, 
                                        width = width
                                    })
                                end 
                            }
                            
                            local flag = GameObject {
                                texture = 'flags',
                                x = (width - 4) * TILE_SIZE + 8,
                                y = (blockHeight - 1) * TILE_SIZE - 1, 
                                width = 16, 
                                height = 16, 
                                frame = 4,
                                collidable = true, 
                                consumable = true, 
                                solid = false, 
                                
                                onConsume = function (player, object)
                                    gSounds['pickup']:play()
                                    gStateMachine:change('play', {
                                        score = player.score, 
                                        width = width
                                    })
                                end 
                            }
                            table.insert(objects, pole)
                            table.insert(objects, flag)
                        end 
                    end
                }
            table.insert(objects, lockObj)
            lockSpawned = true 
            end 
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end