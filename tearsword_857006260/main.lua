
local TearSword = RegisterMod( "TearSword",1 );
local SwordItem = Isaac.GetItemIdByName("Ragged Rags")
local RagCostume = Isaac.GetCostumeIdByPath("gfx/characters/ragcostume.anm2")

local had = false

local maxtears = 4
local tears = {}
local swordDir = Vector(0,0)
local tearcount = 0

--FLAGS
FLAG_NO_EFFECT = 0
FLAG_SPECTRAL = 1
FLAG_PIERCING = 1<<1
FLAG_HOMING = 1<<2
FLAG_SLOWING = 1<<3
FLAG_POISONING = 1<<4
FLAG_FREEZING = 1<<5
FLAG_PARASITE = 1<<6
FLAG_COAL = 1<<7
FLAG_MAGIC_MIRROR = 1<<8
FLAG_POLYPHEMUS = 1<<9
FLAG_WIGGLE_WORM = 1<<10
FLAG_UNK1 = 1<<11 --No noticeable effect but fruit cake can spawn those
FLAG_IPECAC = 1<<12
FLAG_CHARMING = 1<<13
FLAG_CONFUSING = 1<<14
FLAG_ENEMIES_DROP_HEARTS = 1<<15
FLAG_TINY_PLANET = 1<<16
FLAG_ANTI_GRAVITY = 1<<17
FLAG_CRICKETS_BODY = 1<<18
FLAG_RUBBER_CEMENT = 1<<19
FLAG_FEAR = 1<<20
FLAG_PROPTOSIS = 1<<21
FLAG_FIRE = 1<<22
FLAG_STRANGE_ATTRACTOR = 1<<23
FLAG_PISCES = 1<<24
FLAG_PULSE_WORM = 1<<25
FLAG_RING_WORM = 1<<26
FLAG_FLAT_WORM = 1<<27
FLAG_SAD_BOMBS = 1<<28
FLAG_BUTT_BOMBS = 1<<29
FLAG_GLITTER_BOMBS = 1<<30
FLAG_HOOK_WORM = 1<<31
FLAG_GODHEAD = 1<<32
FLAG_GISH = 1<<33
FLAG_SCATTER_BOMBS = 1<<34
FLAG_EXPLOSIVO = 1<<35
FLAG_CONTINUUM = 1<<36
FLAG_HOLY_LIGHT = 1<<37
FLAG_BUMBO_TEARS = 1<<38
FLAG_SERPENTS_KISS = 1<<39
FLAG_TRACTOR_BEAM = 1<<40
FLAG_GODS_FLESH = 1<<41
FLAG_HEAD_OF_THE_KEEPER = 1<<42
FLAG_MYSTERIOUS_LIQUID = 1<<43
FLAG_OUROBOROS_WORM = 1<<44
FLAG_GLAUCOMA = 1<<45
FLAG_SINUS_INFECTION = 1<<46
FLAG_PARASITOID = 1<<47
FLAG_SULFURIC_ACID = 1<<48 
FLAG_COMPOUND_FRACTURE = 1<<49
FLAG_EYE_OF_BELIAL = 1<<50
FLAG_MIDAS = 1<<51
FLAG_EUTHANASIA = 1<<52
FLAG_JACOBS_LADDER = 1<<53
FLAG_LITTLE_HORN = 1<<54
FLAG_LUDOVICO_TECHNIQUE = 1<<55
--FLAGSEND

TearAdditions = { }
TearAdditions[CollectibleType.COLLECTIBLE_20_20] 		= 1
TearAdditions[CollectibleType.COLLECTIBLE_MUTANT_SPIDER]= 3
TearAdditions[CollectibleType.COLLECTIBLE_INNER_EYE] 	= 2
TearAdditions[CollectibleType.COLLECTIBLE_THE_WIZ] 		= 1


function TearSword:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)


	--Quit when you dont even have the fucking item
	if player:HasCollectible(SwordItem) == false then return end
	--Evaluate Tearcount
	tearcount = 1
	for k,v in pairs(TearAdditions) do
		tearcount = tearcount + player:GetCollectibleNum(k) * v
	end

	--player.GetMovementJoystick(player) = Vector(1,1)
	--Check the direction the player is looking in
	if player:GetFireDirection() ~= -1 and player:AreOpposingShootDirectionsPressed() == false then
		local fireDir = player:GetAimDirection()
		swordDir = fireDir 
	elseif player:GetMovementDirection() ~= -1 then
		swordDir = player:GetMovementJoystick()
	else
		swordDir = Vector(0,1)
	end
	--Calculate tearsword length
	maxtears = math.floor(math.abs(player.TearHeight/4)) * tearcount

	local entities = Isaac.GetRoomEntities()

	--Add new tears to the sword
	for i=1,#entities do
		local isSwordEntity = false
		if entities[i].Parent ~= nil then
			if entities[i].Type == EntityType.ENTITY_TEAR and entities[i].SpawnerType == EntityType.ENTITY_PLAYER and entities[i].Parent.Index == player.Index and entities[i].FrameCount < 10 then
				if entities[i]:ToTear().StickTarget == nil or entities[i]:ToTear().StickTarget:Exists() == false then
					for j=1,#tears do
						if entities[i].Index == tears[j].Index then
							isSwordEntity = true 
						end

					end

					--Doesnt work
					if tears[1] ~= nil then
						if tears[1].TearFlags & FLAG_PARASITE > 0 or tears[1].TearFlags & FLAG_CRICKETS_BODY > 0 then
							if tears[1].TearFlags & FLAG_PARASITE == 0 and tears[1].TearFlags & FLAG_CRICKETS_BODY == 0 then
								isSwordEntity = true
							end
						end
					end

					if entities[i]:ToTear().Variant == TearVariant.BOBS_HEAD or entities[i]:ToTear().Variant == TearVariant.CHAOS_CARD then
						isSwordEntity = true
					end
					if isSwordEntity == false then
						if #tears < maxtears then
							table.insert(tears,1,entities[i]:ToTear())
						else
							entities[i]:Remove()

						end
					end
				end
			end
		end
	end

	--Sword table
	local swordnum = {}
	--Sword iteratior
	local swordcount = 1
	--FIll  Sword Table
	for i=1,tearcount do
		table.insert(swordnum,0)
	end


	local xdist = 0
	--ydist between tears
	local ydist = 0
	if tears[1] ~= nil then
		--xdist between tears
		xdist = 15 * tears[1].Scale
		--ydist between tears
		ydist = 10 * tears[1].Scale
	end

	--For All tears do
	for i=1,#tears do
		--Remove non existing tears
		if tears[i]:Exists() == false then
			table.remove(tears,i)
		end
		if tears[i].StickTarget ~= nil then
			if tears[i].StickTarget:Exists() == true then
				table.remove(tears,i)
			end
		end

		--Iterate over swords
		swordcount = swordcount + 1
		if swordcount > tearcount then swordcount = 1 end
		swordnum[swordcount] = swordnum[swordcount] + 1

		--Normalize the direction
		local swordDirNormalized = swordDir:Normalized()
		--Calculate the X position
		local goalPosition = player.Position + swordDirNormalized * xdist * (swordnum[swordcount])  + swordDirNormalized * 15
		--Calculate the Y position
		goalPosition = goalPosition + Vector(- swordDirNormalized.Y, swordDirNormalized.X) * ( (swordcount-1) * ydist - (tearcount-1) * ydist / 2)
		--Set Tear Params
		tears[i].Velocity = (goalPosition - tears[i].Position) / 1.2 --Vector(0,0)
		tears[i].FallingSpeed = 0
		tears[i].FallingAcceleration = 0 
		tears[i].Height = player.TearHeight
		--tears[i].ContinueVelocity = Vector(0,0)
		tears[i].GridCollisionClass = GridCollisionClass.COLLISION_NONE
		tears[i].TearFlags = tears[i].TearFlags | 1 --| FLAG_LUDO
		--Rmoveing tearflags
		--FLAG_RUBBER_CEMENT
		tears[i].TearFlags = tears[i].TearFlags | FLAG_PIERCING
		tears[i].TearFlags = tears[i].TearFlags ~ FLAG_PIERCING
		tears[i].TearFlags = tears[i].TearFlags | FLAG_COAL
		tears[i].TearFlags = tears[i].TearFlags ~ FLAG_COAL
		tears[i].TearFlags = tears[i].TearFlags | FLAG_TINY_PLANET
		tears[i].TearFlags = tears[i].TearFlags ~ FLAG_TINY_PLANET
		tears[i].TearFlags = tears[i].TearFlags | FLAG_TRACTOR_BEAM
		tears[i].TearFlags = tears[i].TearFlags ~ FLAG_TRACTOR_BEAM
		tears[i].TearFlags = tears[i].TearFlags | FLAG_CONTINUUM
		tears[i].TearFlags = tears[i].TearFlags ~ FLAG_CONTINUUM
		tears[i].TearFlags = tears[i].TearFlags | FLAG_RUBBER_CEMENT
		tears[i].TearFlags = tears[i].TearFlags ~ FLAG_RUBBER_CEMENT
		-- Chaning colour
		local c = Color(0.3 + (math.sin(tears[i].FrameCount/10)+1)*0.35,0,0.5+(math.sin(tears[i].FrameCount/10)+1)*0.5,1,0,0,0)
		--tears[i]:SetColor(Color(0.1+(tears[i].FrameCount%30)/30 ,0.1,0.1+ (tears[i].FrameCount%30)/17 ,1,0,0,0),9999,99,false,false  )
		tears[i]:SetColor(c,9999,99,false,false  ) 
	end

end

function TearSword:toDirection(vec)
	if math.abs(vec.X) > math.abs(vec.Y) then
		if vec.X > 0 then 		return Direction.RIGHT
		elseif vec.X < 0 then	return Direction.LEFT
		end
	elseif math.abs(vec.X) < math.abs(vec.Y) then
		if vec.Y > 0 then 		return Direction.DOWN
		elseif vec.Y < 0 then	return Direction.UP
		end
	end

	return Direction.NO_DIRECTION
end


function TearSword:OnRunStart()
	if Game():GetFrameCount() <= 100 then
		had = false
	end
end

function TearSword:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()


	if player:HasCollectible(SwordItem) == true and had == false then
		player:AddNullCostume(RagCostume)
		had = true
	end
	if player:HasCollectible(SwordItem) == false and had == true then
		had = false
	end


	if player:HasCollectible(SwordItem) == false then return end
	--player:AddNullCostume(RagCostume)


	--Isaac.RenderText(tostring(d.X) .. " " .. tostring(d.Y),100,60,1,1,1,255)
--	Isaac.RenderText(tostring(#tears),100,75,1,1,1,255)
--	Isaac.RenderText(tostring(tearcount),100,90,1,1,1,255)
end

function TearSword:eval( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()


end 


TearSword:AddCallback(ModCallbacks.MC_POST_RENDER,TearSword.drawText)
TearSword:AddCallback(ModCallbacks.MC_POST_UPDATE,TearSword.UPDATE)
TearSword:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,TearSword.OnRunStart)