local RobotHat = RegisterMod( "RobotHat",1 )
local RobotHatTriangle = Isaac.GetEntityTypeByName( "Triangle" )
local RobotHatLevelUp = Isaac.GetEntityTypeByName( "LevelUpText" )
local RobotHatItem = Isaac.GetItemIdByName("Robot Hat")
local RobotHatCostume = Isaac.GetCostumeIdByPath("gfx/characters/robothatani.anm2")
local RobotHatGlowCostume = Isaac.GetCostumeIdByPath("gfx/characters/TriGlow.anm2")
local Tri_Sound = Isaac.GetSoundIdByName("tri_pickup")
local Max_Sound = Isaac.GetSoundIdByName("max_reached")

local player_hit = false
local tris_collected = 0
local player_glowing = false
local had = false
local level = 0

function RobotHat:update()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local ents = Isaac.GetRoomEntities()

end

function RobotHat:triangle_update(npc)
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local ents = Isaac.GetRoomEntities()


	npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	npc.GridCollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER


	if npc:GetSprite():IsFinished("Appear") then
		npc:GetSprite():Play("Idle",true)
		npc:GetData().init = true
	end
	if npc:GetData().init == nil and npc:GetSprite():IsPlaying("Appear") == false then
		npc:GetSprite():Play("Appear",true)
	end
	--Isaac.DebugString(npc:GetSprite():)
	if npc:GetSprite():IsPlaying("Idle") then
		local dist = (npc.Position - player.Position):LengthSquared()
		if dist < 350 then
			npc:GetSprite():Play("Collect",true)
			local sfx = SFXManager()
			sfx:Play(Tri_Sound,1,0,false,1)
			if tris_collected < 25 then
				tris_collected = tris_collected + 1
			end
			player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
	end

	if npc:GetSprite():IsFinished("Collect") then
		npc:Remove()
		--local e = Isaac.Spawn(RobotHatLevelUp, 0, 0, player.Position - Vector(0,70), Vector(0,0),player)

	end

end


function RobotHat:levelup_update(npc)
	local player = Isaac.GetPlayer(0)
	if npc.FrameCount >= 56 then
		npc:Remove()
	end
	--npc.Position = player.Position - Vector(0,75)
	npc.Velocity = (player.Position - Vector(0,75)) - npc.Position
	if npc:GetSprite():IsFinished("Idle") then npc:GetSprite():Play("Idle") end
end

function RobotHat:post_render()
	local player = Isaac.GetPlayer(0)
	--Isaac.RenderText(tostring(tris_collected),30, 30, 1, 1, 1, 255)
	--Isaac.RenderText(tostring(player_hit),30, 45, 1, 1, 1, 255)

	if player:HasCollectible(RobotHatItem) == true and had == false then
		player:AddNullCostume(RobotHatCostume)
		had = true
	end
	if player:HasCollectible(RobotHatItem) == false and had == true then
		had = false
	end

	if player_glowing == false and tris_collected == 25 then
		player:AddNullCostume(RobotHatGlowCostume)
		player_glowing = true
	end
	if player_glowing == true and tris_collected ~= 25 then
		player:TryRemoveNullCostume(RobotHatGlowCostume)
		player_glowing = false
	end
end

function RobotHat:on_Damage(entity, amount, damageflag, source, countdownframes)
	local player = Isaac.GetPlayer(0)
	
	--Trigger Player Hit flag
	if entity.Type == EntityType.ENTITY_PLAYER then
		player_hit = true
	end


	if player:HasCollectible(RobotHatItem) then
		if entity.HitPoints < amount and entity:IsEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
			local random_v
			--Isaac.Spawn(RobotHatTriangle, 0, 0, entity.Position, Vector(0,0), player)
			for i=1,2 do
				local tri = Isaac.Spawn(RobotHatTriangle, 0, 0, entity.Position, RandomVector() * 4, player)
				tri:ToNPC().State = 3
			end
		end
		--Drop sum Tris
		if entity.Type == EntityType.ENTITY_PLAYER then
			tris_collected = tris_collected - 15
			tris_lost = 15
			if tris_collected < 0 then
				tris_lost = 15 - math.abs(tris_collected)
				tris_collected = 0
				for i=1,tris_lost do
					local tri = Isaac.Spawn(RobotHatTriangle, 0, 0, entity.Position, RandomVector() * 4, player)
					tri:ToNPC().State = 3
					if i == 3 then break end
				end
			end

			player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
	end
end

function RobotHat:eval_cache(play, cache)

	--Does the player have the item?
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(RobotHatItem) == false then return end
	--Shotspeed
	if cache == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed + (tris_collected/25.0 * player.ShotSpeed * 0.25)
	end
	--Teardelay
	if cache == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = player.MaxFireDelay - math.ceil(tris_collected/25.0 * player.MaxFireDelay/2)
		for i=1,level do
			Isaac.DebugString(tostring(player.MaxFireDelay))
			if player.MaxFireDelay > 2 then
				player.MaxFireDelay = player.MaxFireDelay - 1
			end
		end
		Isaac.DebugString(tostring(tris_collected/25.0 * player.MaxFireDelay/2))
	end

end

function RobotHat:new_room()
	local player = Isaac.GetPlayer(0)

	--player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED) 
	--player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
	--player:EvaluateItems()

end

function RobotHat:new_game()
	local player = Isaac.GetPlayer(0)
	if Game():GetFrameCount() < 20 then
		level = 0
		player_hit = false
	end
	--player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED) 
	--player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
	--player:EvaluateItems()

end

function RobotHat:new_stage()
	local player = Isaac.GetPlayer(0)

	if player:HasCollectible(RobotHatItem) then
		tris_collected = 0


		if player_hit == false then
			local e = Isaac.Spawn(RobotHatLevelUp, 0, 0, player.Position - Vector(0,75), Vector(0,-2),player)
			e:ToNPC().State = 4
			e.Velocity = Vector(0,-2)
			e.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			e.GridCollisionClass = GridCollisionClass.COLLISION_NONE
			player:AnimateHappy()
			local sfx = SFXManager()
			sfx:Play(Max_Sound,1,0,false,1)
			level = level + 1
		end


		player_hit = false

		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end

end

RobotHat:AddCallback( ModCallbacks.MC_POST_GAME_STARTED,RobotHat.new_game)
RobotHat:AddCallback( ModCallbacks.MC_POST_NEW_ROOM ,RobotHat.new_room)
RobotHat:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL,RobotHat.new_stage)

RobotHat:AddCallback( ModCallbacks.MC_POST_RENDER ,RobotHat.post_render)

RobotHat:AddCallback( ModCallbacks.MC_EVALUATE_CACHE ,RobotHat.eval_cache)
RobotHat:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG,RobotHat.on_Damage)

RobotHat:AddCallback( ModCallbacks.MC_POST_UPDATE, RobotHat.update)

RobotHat:AddCallback( ModCallbacks.MC_NPC_UPDATE , RobotHat.triangle_update, RobotHatTriangle)
RobotHat:AddCallback( ModCallbacks.MC_NPC_UPDATE , RobotHat.levelup_update, RobotHatLevelUp)