local Blinks = RegisterMod( "Blinks",1 )
local Blinks_item = Isaac.GetItemIdByName( "Blinks" )

local charge = 3
local oldstage = nil
local iconsprite
local test = false
--local sprite = nil


function Blinks:post_update( )

	local player = Isaac.GetPlayer(0)
	--Stop if he doesnt have the item

	local entities = Isaac.GetRoomEntities()
	for i=1,#entities do
		if entities[i].Type == 5 and entities[i].Variant == 100 and entities[i].SubType == Blinks_item then
			local sp = entities[i]:GetSprite()
			sp:ReplaceSpritesheet(1,"gfx/Items/Collectibles/3blinks.png")
			sp:LoadGraphics()
			test = true
		end
	end

	if player:HasCollectible(Blinks_item) == false then return end


	--Set charge
	if charge == 0 then
		player:SetActiveCharge(0)
	else player:SetActiveCharge(1)
	end

	--Replenish on new stage
	local stage = Game():GetLevel():GetStage()
	if oldstage ~= stage then
		charge = 3
		oldstage = stage
	end





end

function Blinks:use_Blinks( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local number = math.random(0,10)
	local position = Isaac.GetFreeNearPosition(player.Position, 100)
	
	
	if charge > 0 then
		--Plays Thumb up
		player:AnimateHappy()
		charge = charge - 1

		--
		local entities = Isaac.GetRoomEntities()
		for i=1,#entities do
			if entities[i].Type == EntityType.ENTITY_PROJECTILE then
				entities[i]:Die()
			end
		end

		--Opens all doors
		local room = Game():GetRoom()
		for i=0,7 do
			local door = room:GetDoor(i)
			if door ~= nil then
				if room:GetDoor(i).TargetRoomType == RoomType.ROOM_SECRET or room:GetDoor(i).TargetRoomType == RoomType.ROOM_SUPERSECRET then
					room:GetDoor(i):TryBlowOpen()
				end
				if room:GetDoor(i).CurrentRoomType == RoomType.ROOM_SECRET or room:GetDoor(i).CurrentRoomType == RoomType.ROOM_SUPERSECRET then
					room:GetDoor(i):TryBlowOpen()
				end
			end
		end
	end


end


function Blinks:post_render()
	local player = Isaac.GetPlayer(0)

	if player:HasCollectible(Blinks_item) == false then return end
	local spr = Sprite()
	spr:Load("gfx/blinks.anm2",true)

	if charge == 3 then
		spr:ReplaceSpritesheet(0,"gfx/Items/Collectibles/3blinks.png")
	elseif charge == 2 then
		spr:ReplaceSpritesheet(0,"gfx/Items/Collectibles/2blinks.png")
	elseif charge == 1 then
		spr:ReplaceSpritesheet(0,"gfx/Items/Collectibles/1blinks.png")
	elseif charge == 0 then
		spr:ReplaceSpritesheet(0,"gfx/Items/Collectibles/0blinks.png")
	end


	spr:LoadGraphics()
	spr:Play("Idle",true)
	spr:RenderLayer(0, Vector(0, 0))

end

function Blinks:new_run()


	if Game():GetFrameCount() < 100 then
		charge = 3
	end
	oldstage = nil
end

Blinks:AddCallback( ModCallbacks.MC_POST_RENDER, Blinks.post_render);
Blinks:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, Blinks.new_run);
Blinks:AddCallback( ModCallbacks.MC_POST_UPDATE, Blinks.post_update);
Blinks:AddCallback( ModCallbacks.MC_USE_ITEM, Blinks.use_Blinks, Blinks_item );