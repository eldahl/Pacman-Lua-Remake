pacman = {}
pacman.x = 1		-- Map x
pacman.y = 1		-- Map y
pacman.sx = 14+32	-- Screen x
pacman.sy = 14+32	-- Screen y
pacman.canEatGhosts = false

--pacman.moving = true
pacman.move = 0

animationTime = 0			-- Keeps track of time in current frame
animationFrame = 5			-- Length of frame

function pacman.movement()
	-- Up
	if pacman.move == 1 then
		if map[pacman.x][pacman.y-1] == gfx.tile then pacman.move = 0
		else
			-- Move
			pacman.sy = pacman.sy-config.pacmanSpeed
			
			-- Animation
			if pacman.gfx == gfx.pacman and animationTime > animationFrame then
				pacman.gfx = gfx.pacmanUp
				animationTime = 0
			elseif animationTime > animationFrame then
				pacman.gfx = gfx.pacman
				animationTime = 0
			end	
		end	
	-- Down
	elseif pacman.move == 2 then
		if map[pacman.x][pacman.y+1] == gfx.tile then pacman.move = 0 
		else
			-- Move
			pacman.sy = pacman.sy+config.pacmanSpeed
			
			-- Animation
			if pacman.gfx == gfx.pacman and animationTime > animationFrame then
				pacman.gfx = gfx.pacmanDown
				animationTime = 0
			elseif animationTime > animationFrame then
				pacman.gfx = gfx.pacman
				animationTime = 0
			end
		end	
	-- Left
	elseif pacman.move == 3 then
		if map[pacman.x-1][pacman.y] == gfx.tile then pacman.move = 0 
		else
			-- Move
			pacman.sx = pacman.sx-config.pacmanSpeed
			
			-- Animation
			if pacman.gfx == gfx.pacman and animationTime > animationFrame then
				pacman.gfx = gfx.pacmanLeft
				animationTime = 0
			elseif animationTime > animationFrame then
				pacman.gfx = gfx.pacman
				animationTime = 0
			end	
		end
	-- Right
	elseif pacman.move == 4 then
		if map[pacman.x+1][pacman.y] == gfx.tile then pacman.move = 0 
		else
			-- Move
			pacman.sx = pacman.sx+config.pacmanSpeed
			
			-- Animation
			if pacman.gfx == gfx.pacman and animationTime > animationFrame then
				pacman.gfx = gfx.pacmanRight
				animationTime = 0
			elseif animationTime > animationFrame then
				pacman.gfx = gfx.pacman
				animationTime = 0
			end	
		end
	end

	-- Check and change x and y pos
	newTile = pacman.tileChangeCheck()
	-- Check possible movement
	pacman.movementCheck()

	-- Movement change only possible in first frame of entering new tile
	if newTile or pacman.move == 0 then
		if 		newDirection == 1 and canMoveUp 	then pacman.move = 1
		elseif 	newDirection == 2 and canMoveDown 	then pacman.move = 2
		elseif 	newDirection == 3 and canMoveLeft 	then pacman.move = 3
		elseif 	newDirection == 4 and canMoveRight 	then pacman.move = 4 
		end
	end

	--if pacman.move == 1 then pacman.sy = pacman.sy-config.pacmanSpeed end
	--if pacman.move == 2 then pacman.sy = pacman.sy+config.pacmanSpeed end
	--if pacman.move == 3 then pacman.sx = pacman.sx-config.pacmanSpeed end
	--if pacman.move == 4 then pacman.sx = pacman.sx+config.pacmanSpeed end
end

function pacman.tileChangeCheck()
	-- Change x and y when arriving on next tile
	if pacman.sy < pacman.y*32-16 then pacman.y = pacman.y-1 return true end
	if pacman.sy > pacman.y*32+44 then pacman.y = pacman.y+1 return true end
	if pacman.sx < pacman.x*32-16 then pacman.x = pacman.x-1 return true end
	if pacman.sx > pacman.x*32+44 then pacman.x = pacman.x+1 return true end
end

function pacman.movementCheck()
	-- Check possible movement in next tile
	if map[pacman.x][pacman.y-1] ~= gfx.tile then canMoveUp = true 		else canMoveUp = false end		-- Up
	if map[pacman.x][pacman.y+1] ~= gfx.tile then canMoveDown = true 	else canMoveDown = false end	-- Down
	if map[pacman.x-1][pacman.y] ~= gfx.tile then canMoveLeft = true 	else canMoveLeft = false end	-- Left
	if map[pacman.x+1][pacman.y] ~= gfx.tile then canMoveRight = true 	else canMoveRight = false end	-- Right
end