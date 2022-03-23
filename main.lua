require("config")
require("map")
require("ghost")
require("pacman")

gfx = {}
sfx = {}

points = 0
fruitStartTimer = 0
gameOver = false

function love.load()

	love.filesystem.setIdentity(config.gameName)					-- Identity for system
	love.keyboard.setKeyRepeat(true)

    love.graphics.setBackgroundColor(104, 136, 248)                 -- Set the background color to a nice blue

    love.window.setTitle(config.windowTitle)                        -- Window title
    love.window.setMode(config.screenWidth, config.screenHeight)    -- Game window resolution

    																
    sfx.cheese = love.audio.newSource("data/cheese.ogg", "static")	-- Load sounds


    gfx.tile = love.graphics.newImage("data/tile.png")				-- Load textures
    gfx.black = love.graphics.newImage("data/black.png")
    
    gfx.pacman = love.graphics.newImage("data/pacman.png")
    gfx.pacmanUp = love.graphics.newImage("data/pacmanUp.png")
    gfx.pacmanDown = love.graphics.newImage("data/pacmanDown.png")
    gfx.pacmanLeft = love.graphics.newImage("data/pacmanLeft.png")
    gfx.pacmanRight = love.graphics.newImage("data/pacmanRight.png")

    gfx.ghost0 = love.graphics.newImage("data/ghost0.png")
    gfx.ghost1 = love.graphics.newImage("data/ghost1.png")
    gfx.ghost2 = love.graphics.newImage("data/ghost2.png")
    gfx.ghostEat = love.graphics.newImage("data/ghostEat.png")
    
    gfx.cheese = love.graphics.newImage("data/cheese1.png")
    gfx.fruit = love.graphics.newImage("data/fruit1.png")


    pacman.gfx = gfx.pacman

    for i = 0, 4 do 												-- Setup ghosts
    	ghosts[i] = {}
    	setmetatable(ghosts[i], ghost)
    	ghosts[i]:init()
    end

    -- See map.lua
    map.loadData()
end

function love.keypressed(key)
	if key == "up" 		then newDirection = 1 end
	if key == "down" 	then newDirection = 2 end
	if key == "left" 	then newDirection = 3 end
	if key == "right" 	then newDirection = 4 end

	if key == "escape" then love.event.quit() end
end

function love.update()
	
	if not gameOver then
		pacman.movement()
	end
	
	for i = 0, #ghosts do
		ghosts[i]:movement()
	end
	--ghost.movement()

	-- Middle tunnel
	if 		pacman.sx < -10 		then pacman.sx = 36+(32*20)	pacman.x = 20
	elseif 	pacman.sx > 46+(32*20) 	then pacman.sx = 1 pacman.x = 0
	end

	for i = 0, #ghosts do 
		if 		ghosts[i].sx < -10 then ghosts[i].sx = 36+(32*20) ghosts[i].x = 20
		elseif 	ghosts[i].sx > 36+(32*20) then ghosts[i].sx = 1 ghosts[i].x = 0
		end
	end

	animationTime = animationTime + 1

	-- Check for cheese and fruit
	if map[pacman.x][pacman.y] == gfx.cheese then
		points = points +1
		map[pacman.x][pacman.y] = gfx.black
		sfx.cheese:play()
	elseif map[pacman.x][pacman.y] == gfx.fruit then
		pacman.canEatGhosts = true
		for i = 0, #ghosts do
			ghosts[i].gfx = gfx.ghostEat
		end
		map[pacman.x][pacman.y] = gfx.black
		fruitStartTimer = love.timer.getTime()
	end

	-- Keep check on fruit timer
	if love.timer.getTime() - fruitStartTimer > 10 then
		pacman.canEatGhosts = false
		for i = 0, #ghosts do
			if ghosts[i].eaten == nil or ghosts[i].eaten ~= 1 then
				ghosts[i].gfx = ghosts[i].initGfx
			end
		end
		fruitStartTimer = 0
	end

	-- and ghosts
	for i = 0, #ghosts do
		if pacman.x == ghosts[i].x and pacman.y == ghosts[i].y then				-- Check by sx, sy 
			
			if pacman.canEatGhosts then
				ghosts[i]:eat()
			else
				--ghosts[i].gfx = gfx.ghostEat
				gameOver = true
			end
		end

		-- If ghosts has been eaten and 30 seconds has gone by, respawn
		if ghosts[i].eaten == 1 then
			if love.timer.getTime() - ghosts[i].respawnTimer > 30 then
				ghosts[i]:respawn()
			end
		end
	end
end

function drawMap()
	love.graphics.setColor(255,255,255,255)
	for i = 0, 20 do 														-- Background
		for j = 0, 20 do
			love.graphics.draw(gfx.black, 14+i*32, 14+j*32, 0, 1, 1)
		end
	end
	for i = 0, 20 do 														-- Tiles
		for j = 0, 20 do
			if map[i][j] ~= nil then
				love.graphics.draw(map[i][j], 14+i*32, 14+j*32, 0, 1, 1)
			end
		end
	end

end

function love.draw(dt)
	drawMap()

	love.graphics.draw(pacman.gfx, pacman.sx, pacman.sy, 0, 1, 1)

	-- Ghosts
	for i = 0, #ghosts do
		if ghosts[i].gfx ~= nil then
			love.graphics.draw(ghosts[i].gfx, ghosts[i].sx, ghosts[i].sy, 0, 1, 1)
		end
	end
	--love.graphics.draw(ghost.gfx, ghost.sx, ghost.sy, 0, 1, 1)

	-- HUD
	love.graphics.draw(gfx.cheese, 300, -2, 0, 2, 2)
	love.graphics.print(points, 345, 20, 0, 1.5, 1.5)

	love.graphics.print("x: " .. pacman.x .. " sx: " .. pacman.sx, 10, 5)
	love.graphics.print("y: " .. pacman.y .. " sy: " .. pacman.sy, 10, 15)

	if gameOver then
		love.graphics.setColor(0,0,100,255)
		love.graphics.rectangle("fill", config.screenWidth * 0.5 - config.screenWidth * 0.3 , config.screenHeight * 0.5 - config.screenHeight * 0.25, config.screenWidth*0.6, config.screenHeight*0.15)
		love.graphics.setColor(255,255,0,255)
		love.graphics.print("Game over!", config.screenWidth * 0.5 - config.screenWidth * 0.25, 200, 0, 5)
	end
	
	--love.graphics.print("x: " .. ghost.x .. " sx: " .. ghost.sx, 10, 25)
	--love.graphics.print("y: " .. ghost.y .. " sy: " .. ghost.sy, 10, 35)
	--love.graphics.print("ghost.move: " .. ghost.move, 10, 45)
	
	if canMoveUp 	then love.graphics.setColor(0, 255, 0, 255) else love.graphics.setColor(255, 0, 0, 255) end
	love.graphics.rectangle("fill", 200, 10, 5, 5)

	if canMoveDown 	then love.graphics.setColor(0, 255, 0, 255) else love.graphics.setColor(255, 0, 0, 255) end
	love.graphics.rectangle("fill", 200, 20, 5, 5)

	if canMoveLeft 	then love.graphics.setColor(0, 255, 0, 255) else love.graphics.setColor(255, 0, 0, 255) end
	love.graphics.rectangle("fill", 195, 15, 5, 5)

	if canMoveRight then love.graphics.setColor(0, 255, 0, 255) else love.graphics.setColor(255, 0, 0, 255) end
	love.graphics.rectangle("fill", 205, 15, 5, 5)


	if ghost.canMoveForward then love.graphics.setColor(0, 255, 0, 255) else love.graphics.setColor(255, 0, 0, 255) end
	love.graphics.rectangle("fill", 220, 10, 5, 5)

	if ghost.canMoveLeft then love.graphics.setColor(0, 255, 0, 255) else love.graphics.setColor(255, 0, 0, 255) end
	love.graphics.rectangle("fill", 215, 15, 5, 5)

	if ghost.canMoveRight then love.graphics.setColor(0, 255, 0, 255) else love.graphics.setColor(255, 0, 0, 255) end
	love.graphics.rectangle("fill", 225, 15, 5, 5)
end