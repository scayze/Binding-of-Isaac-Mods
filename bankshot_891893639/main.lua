local PoleBillard = RegisterMod( "Bank Shot",1 );
local PoleBillardItem = Isaac.GetItemIdByName("Bank Shot")
local PoleBillardCostume = Isaac.GetCostumeIdByPath("gfx/characters/ballcostume.anm2")
local PoleBillardSound = Isaac.GetSoundIdByName("pingpongpong")

local had = false
local tears = {}
local dist = 0
local FLAG_COAL = 1<<7
function PoleBillard:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)

	if player:HasCollectible(PoleBillardItem) == false then return end

	tears = {}
	local ents = Isaac.GetRoomEntities()
	for i=1,#ents do
		if ents[i].Type == EntityType.ENTITY_TEAR then
			ents[i]:ToTear().Height = player.TearHeight
			ents[i]:ToTear().FallingAcceleration = 0
			ents[i]:ToTear().FallingSpeed = 0
			ents[i].Velocity = ents[i].Velocity / 1.04

			--Rmoveing tearflag
			ents[i]:ToTear().TearFlags = ents[i]:ToTear().TearFlags | FLAG_COAL
			ents[i]:ToTear().TearFlags = ents[i]:ToTear().TearFlags ~ FLAG_COAL

			if ents[i].FrameCount > 1 then
				table.insert(tears,ents[i])
			end
		end
	end
	table.insert(tears,player)

	if tears[1].Type == EntityType.ENTITY_TEAR then
		dist = 11 * tears[1]:ToTear().Scale
	end

	local pvel = player.Velocity

	for i=1,#tears do
		for j=i,#tears do
			if i ~= j then
				local collision = tears[i].Position - tears[j].Position
				local distance = collision:LengthSquared()
				if distance == 0.0 then
					collision = Vector(1.0,0.0)
					distance = dist * dist
				end

				if distance < dist * dist then

					distance = collision:Length()
					collision = collision / distance

					local aci = tears[i].Velocity:Dot(collision)
					local bci = tears[j].Velocity:Dot(collision)

					local colMul = 1.1
					local v1 = (bci - aci) * colMul 
					local v2 = (aci - bci) * colMul

					tears[i].Velocity = tears[i].Velocity + Vector(collision.X * v1, collision.Y * v1)
					tears[j].Velocity = tears[j].Velocity + Vector(collision.X * v2, collision.Y * v2)

					local overlapDist = dist - distance

					if tears[i].Type == EntityType.ENTITY_PLAYER then
						tears[j].Position = tears[j].Position - collision:Normalized() * overlapDist
					elseif tears[j].Type == EntityType.ENTITY_PLAYER then
						tears[i].Position = tears[i].Position + collision:Normalized() * overlapDist
					else
						tears[i].Position = tears[i].Position + collision:Normalized() * overlapDist / 2
						tears[j].Position = tears[j].Position - collision:Normalized() * overlapDist / 2

						local sfx = SFXManager()
						sfx:Play(PoleBillardSound,1,0,false,1)
					end
				end
			end
		end
	end

	player.Velocity = pvel

end

function PoleBillard:OnRunStart()
	had = false
end

function PoleBillard:Sound(index)
	local sfx = SFXManager()
	sfx:Play(index,10000,0,false,1)
end

--Stats and concussion effect
function PoleBillard:Eval_Cache(play, cache)

	--Does the player have the item?
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(PoleBillardItem) == false then return end
	--Range
	if cache == CacheFlag.CACHE_RANGE then
		player.TearHeight = 5
		player.TearFallingAcceleration = 0
	end
	--Shotspeed
	if cache == CacheFlag.CACHE_SHOTSPEED then
		--player.ShotSpeed = player.ShotSpeed / 5 * 3

	end
end

function PoleBillard:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()

	if player:HasCollectible(PoleBillardItem) == true and had == false then
		player:AddNullCostume(PoleBillardCostume)
		had = true
	end
	if player:HasCollectible(PoleBillardItem) == false and had == true then
		had = false
	end
end



function PoleBillard:onNewRoom()
	local player = Isaac.GetPlayer(0)
	tears = {}
end

PoleBillard:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,PoleBillard.onNewRoom)
PoleBillard:AddCallback(ModCallbacks.MC_POST_RENDER,PoleBillard.drawText)
PoleBillard:AddCallback(ModCallbacks.MC_POST_UPDATE,PoleBillard.UPDATE)
PoleBillard:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,PoleBillard.OnRunStart)
PoleBillard:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,PoleBillard.Eval_Cache)