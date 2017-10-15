--[[ 12/01/2017
This is a Mod made by Scayze (Manuel Strey).
Feel free to play around with the code. But beware, some parts are a fucking eyesore,
im not responsible for any damage it causes you.

Anyways.
Have fun playing around and feel free to ask me anything over Twitter (@ThatScayze) or Discord (Scayze#0426)

Cya!
]]


StartDebug()

--http://lua-users.org/wiki/StrictStructs
local struct_mt = {
	-- instances can be created by calling the struct object
	__call = function(s,t)
		local obj = t or {}  -- pass it a table (or nothing)
		local fields = s._fields
		-- attempt to set a non-existent field in ctor?
		for k,v in pairs(obj) do
			if not fields[k] then
				s._error_nf(nil,k)
			end
		end
		-- fill in any default values if not supplied
		for k,v in pairs(fields) do
			if not obj[k] then
				obj[k] = v
			end
		end
		setmetatable(obj,s._mt)
		return obj
	end;
}

-- creating a new struct triggered by struct.STRUCTNAME
struct = setmetatable({},{
	__index = function(tbl,sname)
		-- so we create a new struct object with a name
		local s = {_name = sname}
		-- and put the struct in the enclosing context
		_G[sname] = s
		-- the not-found error
		s._error_nf = function (tbl,key)
			error("field '"..key.."' is not in "..s._name)
		end
		-- reading or writing an undefined field of this struct is an error
		s._mt = {
			_name = s._name;
			__index = s._error_nf;
			__newindex = s._error_nf;
		}
		-- the struct has a ctor
		setmetatable(s,struct_mt)
		-- return a function that sets the struct's fields
		return function(t)
			s._fields = t
		end
	end
})
--http://lua-users.org/wiki/StrictStructs


--Register The Mof
local pacmanMod = RegisterMod("Pacman", 1)
local ghostEntity = Isaac.GetEntityTypeByName("PacmanGhost")
local gamekidAnim = Isaac.GetCostumeIdByPath("gfx/characters/093_the gamekid.anm2")


struct.Data {
	StartTile = 206;
	ScatterTile = 420;
	TargetTile = 420;
	NextTile = 206;
	OldTile = 0;
	Active = 0;
	Speed = 5.5;
	CurrentAnim = "Down";
}

--Isaac.Spawn(EntityType.ENTITY_SLOT)
--Current Level
--Speeds
normSpeed = 6
frightSpeed = 4.5
deathSpeed = 14

finished = false
currentLevel = 1
--closed room
closed = false

--is on teleporter block
onTeleport = false

highscore = 0
score = 0

--Coins Picked up
coins = 1
--Max Coins
maxCoins = 164

--Ghost Data
pinkData = nil
redData = nil
blueData = nil
orangeData = nil

pinkData = Data{ScatterTile = 420,TargetTile = 420, NextTile = 205, Active = 1, StartTile = 207}
redData = Data{ScatterTile = 0,TargetTile = 0, NextTile = 205, Active = 1, StartTile = 206}
blueData = Data{ScatterTile = 24,TargetTile = 24, NextTile = 205, Active = 0, StartTile = 208}
orangeData = Data{ScatterTile = 444,TargetTile = 444, NextTile = 205, Active = 0, StartTile = 209}

--Ghost entities
entityPink = nil
entityRed = nil
entityBlue = nil
entityOrange = nil

--chases (Scatter/Chase alternating)
timer = nil
modes = {7,20,7,20,5,20,5,99999999}
currentMode = nil
--chase mode
chaseMode = -1

isInitialized = false
initCalled = false
--Last Movement Direction
lastMovement = Direction.LEFT

globalGridSpawned = false

--Fruit stuff
fruitStart = 0
fruit1spawned = false
fruit2spawned = false
fruit = nil

ghostEatPoints = 200

--Mod Update
function pacmanMod:Update()

	--Spawn to grid:
    local player = Isaac.GetPlayer(0)
    local level = Game():GetLevel()
    local room = Game():GetRoom()
   	local roomShape = room:GetRoomShape() 
	local ents = Isaac.GetRoomEntities()

	--Start of run
	--if Game():GetFrameCount() == 1 then playerInit() end

	--When its the PacMan room
	if roomShape == RoomShape.ROOMSHAPE_2x2  and room:GetType() == RoomType.ROOM_ARCADE then
		--INIT
		if initCalled == false then
			Init()
		end
		if isInitialized == false then
			playerInit()
		end

		if globalGridSpawned == false then
			spawnGrid()
		end


		if score > highscore then
			Isaac.SaveModData(pacmanMod,score)
			highscore = score
		end
		--INIT END
		--if coins == 0 and initCalled == true then initCalled = false end
		--if player.Position.X <=200 then initCalled = false end
		--Closing the Room
		if player.Position.X < 980 and closed == false then
			room:SpawnGridEntity(220,GridEntityType.GRID_ROCK,0,room:GetSpawnSeed(),0)
			closed = true
		elseif player.Position.X > 980 and closed == true then
			room:DestroyGrid(220,true)
			closed = false
		end

		-- Activate other ghosts as the game progresses
		if coins <= maxCoins - 20 then blueData.Active = 1 end
		if coins <= 2 * maxCoins / 3 then orangeData.Active = 1 end

		--Fruit check
		if Game():GetFrameCount() - fruitStart >300 and fruit ~= nil then
			fruit:Remove()
			fruit = nil
		end
		--Fruit spawns
		if coins == maxCoins-113 and fruit1spawned == false then
			fruit1spawned = true
			spawnFruit()
		end
		if coins == maxCoins-47 and fruit2spawned == false then
			fruit2spawned = true
			spawnFruit()
		end

		--Set Movespeed to constant 0.7 (half a devil)
		player.MoveSpeed = 0.7

		--COLLECTIBLE_ONE_UP
		if player:IsDead() then
			if player:WillPlayerRevive() == true then
				playerDead()
				player:Revive()
				player:RemoveCollectible(CollectibleType.COLLECTIBLE_LAZARUS_RAGS,true)
			else
				if score > highscore then
					Isaac.SaveModData(pacmanMod,tostring(score))
				end
			end
		end
		--if closed == false then return end
		--UPDATE
    
		local oldMode = chaseMode

		if currentMode % 2 == 0 then
			chaseMode = 1
		else
			chaseMode = 0
		end

		if player:HasInvincibility() then
			chaseMode = 3
		else 
			timer = timer + 1
		end

		--WHY DOESNT THIS WORK WHAT THE ACTUAL FUCKif oldMode ~= 3 and chaseMode ~= oldmode and oldmode ~= -1 then reverseDirecion() end
		--WHY DO THESE 3 WORK?!?!?!? THIS IS THE SAME FUCKING THING
		if oldMode ~= 3 and chaseMode == 3 then reverseDirecion() end
		if oldMode == 0 and chaseMode == 1 then reverseDirecion() end
		if oldMode == 1 and chaseMode == 0 then reverseDirecion() end
		--Thisbugwassodamnobviousihatemyself
		--if oldMode ~= 3 and oldmode ~= 1 and chaseMode == 1 then reverseDirecion() end

		--Switch to next mode
		if timer/30 >= modes[currentMode] then
			currentMode = currentMode + 1
			timer = 0
		end


		--Key scores
		local c = player:GetNumCoins()
		score = score + c * 10
		player:AddCoins(-c)


		--Fruit scores
		local k = player:GetNumKeys()
		if k ~= 0 then
			if currentLevel == 1 then
				score = score + 100
			elseif currentLevel == 2 then
				score = score + 300
			elseif currentLevel == 3 or currentLevel == 4 then
				score = score + 500
			elseif currentLevel == 5 or currentLevel == 6 then
				score = score + 700
			elseif currentLevel == 7 or currentLevel == 8 then
				score = score + 1000
			elseif currentLevel == 9 or currentLevel == 10 then
				score = score + 2000
			elseif currentLevel == 11 or currentLevel == 12 then
				score = score + 3000
			elseif currentLevel >= 13 then
				score = score + 5000
			end
		end
		player:AddKeys(-k)


		--Update last movement direcion 
		if player:GetMovementDirection() ~= Direction.NO_DIRECTION then
			lastMovement = player:GetMovementDirection()
		end
		
		--Power Pellets
		if  player:GetActiveCharge() >= 1 then
			player:DischargeActiveItem()
			player:ClearTemporaryEffects()
			player:UsePill(PillEffect.PILLEFFECT_POWER,PillColor.PILL_BLUE_BLUE)
			--player:PlaySound()
			score = score + 50
			ghostEatPoints = 200
			local sound_entity = Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, player.Position, Vector(0,0), nil):ToNPC()
			sound_entity:PlaySound(SoundEffect.SOUND_POWER_PILL, 50, 0, false, 1)
			sound_entity:Remove()
		end

		--Teleporter
		local playerIndex = room:GetGridIndex(player.Position)
		if playerIndex == 40 and onTeleport == false then
			player.Position = room:GetGridPosition(376)
			onTeleport = true
			--player:AnimateTeleport(true)
			--player:AnimateTeleport(false)
		elseif playerIndex == 376 and onTeleport == false then
			player.Position = room:GetGridPosition(40)
			onTeleport = true
			--player:AnimateTeleport(true)
			--player:AnimateTeleport(false)
		end

		if not (playerIndex == 40 or playerIndex == 376) then
			onTeleport = false
		end

		--Finish Requirement

		if initCalled == true then
			local coin = false
			coins = 0
			for i=1,#ents do
				if (ents[i].Type == EntityType.ENTITY_PICKUP and ents[i].Variant == PickupVariant.PICKUP_COIN) or (ents[i].Type == EntityType.ENTITY_PICKUP and ents[i].Variant == PickupVariant.PICKUP_LIL_BATTERY)then
					if ents[i]:Exists() then
						coin = true
						coins = coins+1
					end
				end
			end

			if coin == false and room:GetFrameCount() >= 100 and timer >= 100 then
				if currentLevel == 3 then
					finish()
				end
				initCalled = false
				currentLevel = currentLevel + 1
			end
		end

		--UPDATE END
	else
		--player:UseCard(Card.CARD_STARS)
	end
end

--Mod Custom Render
function pacmanMod:Render()
 	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
   	local roomShape = room:GetRoomShape() 
	local level = Game():GetLevel()
	--Isaac.DebugString(getmetatable(level:GetRoomByIdx(0)))

	if roomShape == RoomShape.ROOMSHAPE_2x2  and room:GetType() == RoomType.ROOM_TREASURE then
		--INIT
		Isaac.RenderText("Highscore: " .. tostring(highscore),42,21,255,255,255,255)
		Isaac.RenderText("Score: " .. tostring(score),42,34,255,255,255,255)
		Isaac.RenderText("Level: " .. tostring(currentLevel),42,47,255,255,255,255)

	end
	--Isaac.RenderText(tostring(coins) .. "    " .. tostring(isValid(room:GetGridIndex(player.Position))),50,60,255,255,255,255)
	--Debug Renders. A lot.
	--[[
		local g = lastMovement
	if g == Direction.NO_DIRECTION then Isaac.RenderText("0",50,50,255,255,255,255)
	elseif g == Direction.LEFT then Isaac.RenderText("l",50,50,255,255,255,255) 
	elseif g == Direction.UP then Isaac.RenderText("u",50,50,255,255,255,255)
	elseif g == Direction.RIGHT then Isaac.RenderText("r",50,50,255,255,255,255)
	elseif g == Direction.DOWN then Isaac.RenderText("d",50,50,255,255,255,255)
	end
	
	Isaac.RenderText("state: " .. tostring(chaseMode) .. "   currentMode: " .. tostring(currentMode),30,33,255,255,255,255)
	--Isaac.RenderText( tostring(player.Velocity.X) .. " ".. tostring(player.Velocity.Y),50,35,255,255,255,255)
	--Isaac.RenderText( tostring(isValidTest(room:GetGridIndex(player.Position)) ),50,35,255,255,255,255)
	--Isaac.RenderText( tostring(tonumber(room:GetGridEntity(room:GetGridIndex(player.Position)):GetType())),300,35,255,255,255,255)
	--Isaac.RenderText( tostring(player.Position.X) .. " ".. tostring(player.Position.Y) ),50,50,255,255,255,255)

	Isaac.RenderText("Pink: " .. tostring(pinkData.OldTile) .. " going to ".. tostring(pinkData.TargetTile) ,50,70,255,255,255,255)
	Isaac.RenderText("Red:  " .. tostring(redData.OldTile) .. " going to ".. tostring(redData.TargetTile),50,85,255,255,255,255)
	Isaac.RenderText("Blue: " .. tostring(blueData.OldTile) .. " going to ".. tostring(blueData.TargetTile),50,100,255,255,255,255)
	Isaac.RenderText("Orange: " .. tostring(orangeData.OldTile) .. " going to ".. tostring(orangeData.TargetTile),50,115,255,255,255,255)

	local rp = nil

	rp = Isaac.WorldToScreenDistance(room:GetGridPosition(pinkData.TargetTile),true)
	Isaac.RenderText("P",rp.X,rp.Y,0,0,255,255)
	rp = Isaac.WorldToScreenDistance(room:GetGridPosition(redData.TargetTile),true)
	Isaac.RenderText("R",rp.X,rp.Y,0,0,255,255)
	rp = Isaac.WorldToScreenDistance(room:GetGridPosition(blueData.TargetTile),true)
	Isaac.RenderText("B",rp.X,rp.Y,0,0,255,255)
	rp = Isaac.WorldToScreenDistance(room:GetGridPosition(orangeData.TargetTile),true)
	Isaac.RenderText("O",rp.X,rp.Y,0,0,255,255)
	--Isaac.RenderText(tostring(room:GetGridEntity(room:GetGridIndex(player.Position)) ,50,20,255,255,255,255)
	]]

end

--Mod GHOST / NPC Update
function pacmanMod:GhostUpdate(npc)
  	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local level = Game():GetLevel()

	if closed == false then return end
	--Determine ghost

	local data = nil

	--Pink
	if npc.Index == entityPink.Index then
		data = pinkData
		if chaseMode == 1 then
			for i=0,4 do
				if lastMovement == Direction.LEFT then
					data.TargetTile = room:GetGridIndex(player.Position + Vector(-(160-i*40),0))
				elseif lastMovement == Direction.UP then
					data.TargetTile = room:GetGridIndex(player.Position + Vector(0,-(160-i*40)))
				elseif lastMovement == Direction.RIGHT then
					data.TargetTile = room:GetGridIndex(player.Position + Vector((160-i*40),0))
				elseif lastMovement == Direction.DOWN then
					data.TargetTile = room:GetGridIndex(player.Position + Vector(0,(160-i*40)))
				end
				if data.TargetTile ~= -1 then break end
			end
		else
			data.TargetTile = data.ScatterTile
		end

	--Red
	elseif npc.Index == entityRed.Index then
		data =  redData
		data.TargetTile = room:GetGridIndex(player.Position)

	--Blue
	elseif npc.Index == entityBlue.Index then
		data = blueData
		local twoGridAway = nil
		if chaseMode == 1 then
			--Two infront of the player
			if lastMovement == Direction.LEFT then
				twoGridAway = player.Position + Vector(-80,0)
			elseif lastMovement == Direction.UP then
				twoGridAway = player.Position + Vector(0,-80)
			elseif lastMovement == Direction.RIGHT then
				twoGridAway = player.Position + Vector(80,0)
			elseif lastMovement == Direction.DOWN then
				twoGridAway = player.Position + Vector(0,80)
			end
			--Dist between twoGridAway and Reds Position
			local distTGA_RP = twoGridAway - entityRed.Position
			data.TargetTile = room:GetGridIndex(entityRed.Position+distTGA_RP*2)
			--Increment
			local dm = 0
			--If the tile is out of map, smallen the vector until it fits
			while data.TargetTile == -1 do
				dm = dm+0.1
				data.TargetTile = room:GetGridIndex(entityRed.Position+distTGA_RP*(2-dm))
			end

		else
			data.TargetTile = data.ScatterTile
		end

	--Orange
	elseif npc.Index == entityOrange.Index then
		data = orangeData
		data.TargetTile = data.ScatterTile
		if chaseMode == 1 and (npc.Position - player.Position):Length() > 320 then
			data.TargetTile = room:GetGridIndex(player.Position)
		end
	end

	if data == nil then return end
	if data.Active == 0 then return end
	--If hit, back to start.
	if npc.HitPoints < npc.MaxHitPoints then
		npc.HitPoints = npc.MaxHitPoints
		data.NextTile = data.StartTile
		score = score + ghostEatPoints
		ghostEatPoints = ghostEatPoints * 2
		if ghostEatPoints >= 3200 then
			ghostEatPoints = 200
			score = score + 12000
		end
	end

	--Reset Mac ghosts eaten when 4


	--Choose Target tile if still in house
	local pos = npc.Position
	local currentIndex = room:GetGridIndex(Vector(pos.X,pos.Y))

	--Choose Animation
	local vel = npc.Velocity
	local animate = "Down"
	if math.abs(vel.X) > math.abs(vel.Y) then
		if vel.X>0 then animate = "Right"
		else 		animate = "Left"
		end
	else
		if vel.Y>0 then animate = "Down"
		else 		animate = "Up"
		end
	end

	if animate ~= data.CurrentAnim then 
		npc:GetSprite():Play(animate,true)
		CurrentAnim = animate
	end


	-- set speed
	if chaseMode == 0 or chaseMode == 1 then
		data.Speed = normSpeed
	elseif chaseMode == 3 then
		data.Speed = frightSpeed
	end

	if data.NextTile == data.StartTile then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE 
		data.Speed = deathSpeed
	else 
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY  
	end
	if room:GetGridIndex(npc.Position) == data.StartTile then data.Speed = normSpeed end

	-- Stop function if the ghost is not even active

	-- Check if arrived the aimed tile
	local nextPos = room:GetGridPosition(data.NextTile)
	if (nextPos-pos):LengthSquared() > 30 then
		npc.Velocity = (nextPos-pos):Resized(data.Speed)
	else
		-- If Stepped on StartTile nexttile = 205
		--If in start, nextTile = 205
		if data.NextTile == data.StartTile then
			data.NextTile = 205
			return
		end
		--If Stepped on Teleporter
		if data.NextTile == 40 then
			npc.Position = room:GetGridPosition(376)
			data.NextTile = 376
		elseif data.NextTile == 376 then
			npc.Position = room:GetGridPosition(40)
			data.NextTile = 40
		end
		pos = npc.Position

		--Check closest to tile
		local closest = 999999999999999999
		local index = 0
		local closestID = 0
		local dist = 0

		local possibilities = {}
		--Right
		index = data.NextTile + 1--room:GetGridIndex(Vector(pos.X+40,pos.Y))
		if isValid(index,data.OldTile) then
			table.insert(possibilities,index)
			dist = (room:GetGridPosition(index) - room:GetGridPosition(data.TargetTile)):LengthSquared()
			if  dist < closest then
				closest = dist
				closestID = index
			end
		end
		--Down
		index = room:GetGridIndex(Vector(pos.X,pos.Y+40))
		if isValid(index,data.OldTile) then
			table.insert(possibilities,index)
			dist = (room:GetGridPosition(index) - room:GetGridPosition(data.TargetTile)):LengthSquared()
			if  dist < closest then
				closest = dist
				closestID = index
			end
		end
		--Left
		index = data.NextTile-1 --room:GetGridIndex(Vector(pos.X-40,pos.Y))
		if isValid(index,data.OldTile) then
			table.insert(possibilities,index)
			dist = (room:GetGridPosition(index) - room:GetGridPosition(data.TargetTile)):LengthSquared()
			--Not speciel fields
			if  dist < closest and index ~=176 and index ~= 232 and index ~= 186 and index ~= 242 then
				closest = dist
				closestID = index
			end
		end
		--Top
		index = room:GetGridIndex(Vector(pos.X,pos.Y-40))
		if isValid(index,data.OldTile) then
			table.insert(possibilities,index)
			dist = (room:GetGridPosition(index) - room:GetGridPosition(data.TargetTile)):LengthSquared()
			if  dist < closest then
				closest = dist
				closestID = index
			end
		end

		data.OldTile = data.NextTile
		data.NextTile = closestID

		if chaseMode == 3 then
			data.NextTile = possibilities[math.random(1,#possibilities)]
		end



	end
 	--SpawnGridEntity ( integer Variant, integer Seed, integer VarData)
	--room:SpawnGridEntity(blueData.TargetTile,GridEntityType.GRID_ROCK,0,room:GetSpawnSeed(),0)
	--room:DestroyGrid(blueData.TargetTile,false)
end

--On a new run (please please please god work dont fail me i have faith in thee)
function pacmanMod:NewRun()
	local player = Isaac.GetPlayer(0)

	local diff = 3 - player:GetMaxHearts()
	player:AddMaxHearts(diff,true)

	finished = false
	currentLevel = 1

	--closed room
	closed = false

	highscore = tonumber(Isaac.LoadModData(pacmanMod))
	if highscore == nil then
		highscore = 0
	end
	score = 0


	--Coins Picked up
	coins = 1
	--Max Coins
	maxCoins = 164

	--Ghost Data
	pinkData = nil
	redData = nil
	blueData = nil
	orangeData = nil

	--Ghost entities
	entityPink = nil
	entityRed = nil
	entityBlue = nil
	entityOrange = nil

	--chases (Scatter/Chase alternating)
	timer = 0
	modes = {7,20,7,20,5,20,5,99999999}
	currentMode = nil
	--chase mode
	chaseMode = 0


	isInitialized = false
	initCalled = false

	fruitStart = 0
	fruit1spawned = false
	fruit2spawned = false
	fruit = nil
end

--render
pacmanMod:AddCallback(ModCallbacks.MC_POST_RENDER, pacmanMod.Render)
--update
pacmanMod:AddCallback(ModCallbacks.MC_POST_UPDATE, pacmanMod.Update)
--npc update
pacmanMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, pacmanMod.GhostUpdate, ghostEntity)
--post player init
pacmanMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, pacmanMod.NewRun)

-- Spawns a fruit
function spawnFruit()
	room = Game():GetRoom()
	player = Isaac.GetPlayer(0)
	fruitStart = Game():GetFrameCount()
	if fruit ~= nil then fruit:Remove() end
	fruit = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, room:GetGridPosition(211),Vector(0, 0), player)
	--[[
	local sprite = fruit:GetSprite()
	sprite:Load("gfx/fruits.anm2",true)
	sprite:Play("cherry",true)]]
end

-- Init when the room is reset / first spawns
function Init()
		local player = Isaac.GetPlayer(0)
		local room = Game():GetRoom()

		player:ClearTemporaryEffects()

		--Set initialized
		initCalled = true


		fruitStart = 0
		fruit1spawned = false
		fruit2spawned = false
		fruit = nil

		--Speeds
		normSpeed = 6.0
		frightSpeed = 4.5
		deathSpeed = 14

		--is Player on teleporter block
		onTeleport = false

		--Reset Timer to 0
		timer = 0
		--Mode
		currentMode = 1
		--chase mode
		chaseMode = -1
		--Reset Coins
		coins = 1

		player.Position = room:GetGridPosition(215)
		--Last Movement Direction
		lastMovement = Direction.LEFT

		--Spawn all coins and batteries
		spawnCoins()

		player:AddCollectible(CollectibleType.COLLECTIBLE_GAMEKID,0,true)
		player.MoveSpeed = 0.33
		player.Damage = 0
		player.ShotSpeed = 0
		player.TearHeight = -1
		player.MaxFireDelay = 9999


		---Entities
		--Kill em all
		if entityPink ~= nil then entityPink:Die() end
		if entityRed ~= nil then entityRed:Die() end
		if entityBlue ~= nil then entityBlue:Die() end
		if entityOrange ~= nil then entityOrange:Die() end

		-- Reset Ghost entities
		entityPink = nil
		entityRed = nil
		entityBlue = nil
		entityOrange = nil

		--Ghost Entities Spawned
		entityPink = 	Isaac.Spawn(ghostEntity,0,0,room:GetGridPosition(207),Vector(0,0),player)
		entityPink:GetSprite():Play("Left")
		entityPink:SetColor(Color(234/255,130/255,229/255,1,0,0,0),9999999,99,false,true)
		entityPink.GridCollisionClass = GridCollisionClass.COLLISION_NONE
		entityPink.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY 

		entityRed = 	Isaac.Spawn(ghostEntity,0,0,room:GetGridPosition(206),Vector(0,0),player)
		entityRed:GetSprite():Play("Left")
		entityRed:SetColor(Color(208/255,62/255,25/255,1,0,0,0),9999999,99,false,false)
		entityRed.GridCollisionClass = GridCollisionClass.COLLISION_NONE
		entityRed.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY 

		entityBlue = 	Isaac.Spawn(ghostEntity,0,0,room:GetGridPosition(208),Vector(0,0),player)
		entityBlue:GetSprite():Play("Left")
		entityBlue:SetColor(Color(70/255,191/255,238/255,1,0,0,0),9999999,99,false,false)
		entityBlue.GridCollisionClass = GridCollisionClass.COLLISION_NONE
		entityBlue.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY 

		entityOrange = 	Isaac.Spawn(ghostEntity,0,0,room:GetGridPosition(209),Vector(0,0),player)
		entityOrange:GetSprite():Play("Left")
		entityOrange:SetColor(Color(219/255,133/255,28/255,1,0,0,0),9999999,99,false,false)
		entityOrange.GridCollisionClass = GridCollisionClass.COLLISION_NONE
		entityOrange.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY 

		--Rest Data
		pinkData = nil
		redData = nil
		blueData = nil
		orangeData = nil

		pinkData = Data{ScatterTile = 420,TargetTile = 420, NextTile = 205, Active = 1, StartTile = 207}
		redData = Data{ScatterTile = 0,TargetTile = 0, NextTile = 205, Active = 1, StartTile = 206}
		blueData = Data{ScatterTile = 24,TargetTile = 24, NextTile = 205, Active = 0, StartTile = 208}
		orangeData = Data{ScatterTile = 444,TargetTile = 444, NextTile = 205, Active = 0, StartTile = 209}

		--remove bombs
		local c = player:GetNumBombs()
		player:AddBombs(-c)
end

-- First init when entering PacMan room
function playerInit()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()

	coins = 1

	spawnGrid()
	--Clear the room
	isInitialized = true

	--player:AddNullCostume(gamekidAnim)

	player:AddCollectible(CollectibleType.COLLECTIBLE_GAMEKID,0,true)
	player:AddCollectible(CollectibleType.COLLECTIBLE_LAZARUS_RAGS ,0,true)
	player:AddCollectible(CollectibleType.COLLECTIBLE_LAZARUS_RAGS ,0,true)
	player:AddCollectible(CollectibleType.COLLECTIBLE_LAZARUS_RAGS ,0,true)
	---Entities
end

--Check validity of Tile
function isValid(index, oldTile)
		--[[
	if norocks == nil then return false end
	local room = Game():GetRoom()
	if index == oldTile then return false end

	for i=1,#norocks do
		if index == norocks[i]  then
			return true
		end
	end

	return false
		]]--

	if index == oldTile then return false end
	local room = Game():GetRoom()
		if room:GetGridEntity(index) == nil then
			return true
		elseif room:GetGridEntity(index).Desc.Type == GridEntityType.GRID_NULL or room:GetGridEntity(index).Desc.Type == GridEntityType.GRID_DECORATION  then
			return true
		else
			return false
		end

end

--Let all ghists recerse Direction
function reverseDirecion()
	if pinkData.Active == 1 and pinkData.NextTile ~= pinkData.StartTile and pinkData.NextTile ~= 205 then
		local p = pinkData.NextTile
		pinkData.NextTile = pinkData.OldTile
		pinkData.OldTile = p
	end
	if redData.Active == 1 and redData.NextTile ~= redData.StartTile and redData.NextTile ~= 205 then
		local p = redData.NextTile
		redData.NextTile = redData.OldTile
		redData.OldTile = p
	end
	if blueData.Active == 1 and blueData.NextTile ~= blueData.StartTile and blueData.NextTile ~= 205 then
		local p = blueData.NextTile
		blueData.NextTile = blueData.OldTile
		blueData.OldTile = p
	end
	if orangeData.Active == 1 and orangeData.NextTile ~= orangeData.StartTile and orangeData.NextTile ~= 205 then
		local p = orangeData.NextTile
		orangeData.NextTile = orangeData.OldTile
		orangeData.OldTile = p
	end
end


--Clear everything
function clearRoom()
	--[[local entities = Isaac.GetRoomEntities()
	for i=1,#entities do
		if entities[i].Type == ghostEntity then
			entities[i].Kill()
		end
	end]]--

	local room = Game():GetRoom()
	for i=29,418 do
		room:DestroyGrid(i,true)
	end
end

--When the player finished the challenge
function finish()
	if finished ~= false then return end
	finished = true
	--clearRoom()
	room = Game():GetRoom()
	if entityPink ~= nil then entityPink:Die() end
	if entityRed ~= nil then entityRed:Die() end
	if entityBlue ~= nil then entityBlue:Die() end
	if entityOrange ~= nil then entityOrange:Die() end
	room:DestroyGrid(210,true)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TROPHY , 0, room:GetGridPosition(210),Vector(0, 0), player)
end

--If the player dies
function playerDead()
	local room = Game():GetRoom()
	local player = Isaac.GetPlayer(0)
	--Reset Timer to 0
	timer = 0
	--Mode
	currentMode = 1
	--chase mode
	chaseMode = 0
	--Reset Coins
	coins = 1

	player.Position = room:GetGridPosition(215)
	--Last Movement Direction
	lastMovement = Direction.LEFT

	---Entities
	--Kill em all
	if entityPink ~= nil then entityPink:Die() end
	if entityRed ~= nil then entityRed:Die() end
	if entityBlue ~= nil then entityBlue:Die() end
	if entityOrange ~= nil then entityOrange:Die() end

	-- Reset Ghost entities
	entityPink = nil
	entityRed = nil
	entityBlue = nil
	entityOrange = nil

	--Ghost Entities Spawned
	entityPink = 	Isaac.Spawn(ghostEntity,0,0,room:GetGridPosition(207),Vector(0,0),player)
	entityPink:GetSprite():Play("Left")
	entityPink:SetColor(Color(234/255,130/255,229/255,1,0,0,0),9999999,99,false,true)
	entityPink.GridCollisionClass = GridCollisionClass.COLLISION_NONE
	entityPink.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY 

	entityRed = 	Isaac.Spawn(ghostEntity,0,0,room:GetGridPosition(206),Vector(0,0),player)
	entityRed:GetSprite():Play("Left")
	entityRed:SetColor(Color(208/255,62/255,25/255,1,0,0,0),9999999,99,false,false)
	entityRed.GridCollisionClass = GridCollisionClass.COLLISION_NONE
	entityRed.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY 

	entityBlue = 	Isaac.Spawn(ghostEntity,0,0,room:GetGridPosition(208),Vector(0,0),player)
	entityBlue:GetSprite():Play("Left")
	entityBlue:SetColor(Color(70/255,191/255,238/255,1,0,0,0),9999999,99,false,false)
	entityBlue.GridCollisionClass = GridCollisionClass.COLLISION_NONE
	entityBlue.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY 

	entityOrange = 	Isaac.Spawn(ghostEntity,0,0,room:GetGridPosition(209),Vector(0,0),player)
	entityOrange:GetSprite():Play("Left")
	entityOrange:SetColor(Color(219/255,133/255,28/255,1,0,0,0),9999999,99,false,false)
	entityOrange.GridCollisionClass = GridCollisionClass.COLLISION_NONE
	entityOrange.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY 

	--Rest Data
	pinkData = nil
	redData = nil
	blueData = nil
	orangeData = nil

	pinkData = Data{ScatterTile = 420,TargetTile = 420, NextTile = 205, Active = 1, StartTile = 207}
	redData = Data{ScatterTile = 0,TargetTile = 0, NextTile = 205, Active = 1, StartTile = 206}
	blueData = Data{ScatterTile = 24,TargetTile = 24, NextTile = 205, Active = 0, StartTile = 208}
	orangeData = Data{ScatterTile = 444,TargetTile = 444, NextTile = 205, Active = 0, StartTile = 209}
end

-- Mod Spawn Pacman Room
function spawnGrid()
	globalGridSpawned = true
	local room = Game():GetRoom()
	local player = Isaac.GetPlayer(0)
	room:SpawnGridEntity(220,GridEntityType.GRID_ROCK,0,room:GetSpawnSeed(),0)
end

function spawnCoins()
	local room = Game():GetRoom()
	local player = Isaac.GetPlayer(0)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 7*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 7*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 11*40,165+9*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 11*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 10*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 9*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 8*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 6*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+6*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 6*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 8*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 12*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 11*40,165+11*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 10*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 8*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 1, Vector(80 + 0*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 1*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+1*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 4*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 10*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 11*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 12*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 13*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 14*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 15*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 19*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 8*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 0*40,165+1*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 2*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+3*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 5*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 6*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 8*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 9*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 11*40,165+3*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+3*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 17*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 19*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 20*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 20*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+9*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 8*40,165+6*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 7*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 21*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+6*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 14*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 13*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 9*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 8*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+11*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 2*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 1*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 0*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 1*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 0*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 14*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 15*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+9*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 19*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 20*40,165+11*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 15*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 17*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 6*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 5*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 17*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+11*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 15*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+3*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 20*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 11*40,165+1*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 12*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 9*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 5*40,165+1*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 17*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 19*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 20*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 13*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 1*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 1*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+9*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 5*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 4*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 5*40,165+11*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 4*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 17*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 12*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 2*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 20*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 21*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 0*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 1, Vector(80 + 0*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+3*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 19*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 20*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 1, Vector(80 + 22*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 1, Vector(80 + 22*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+11*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 14*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 20*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 19*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+9*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 11*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 2*40,165+12*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 7*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 6*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 5*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 20*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 6*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 5*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 14*40,165+6*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 14*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 10*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 11*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 0*40,165+11*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 4*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 2*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 0*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 0*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 2*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 1*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 0*40,165+9*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 0*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 0*40,165+3*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 21*40,165+7*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+8*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+10*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 20*40,165+1*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 4*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 3*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 5*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+1*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 13*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 14*40,165+2*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 17*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+5*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+4*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 18*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 16*40,165+1*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 21*40,165+0*40),Vector(0, 0), player)
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Vector(80 + 22*40,165+6*40),Vector(0, 0), player)	
end

