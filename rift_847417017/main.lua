local Rift = RegisterMod( "Twisty Tuning Fork",1 )
local RiftItem = Isaac.GetItemIdByName( "Twisty Tuning Fork" )
local riftEntityType = Isaac.GetEntityTypeByName("Rift")

local multibaby = nil
local riftEntity = nil
local oldroom = nil
local isUsed = false

function Rift:post_update( )

	local player = Isaac.GetPlayer(0)
	--Stop if he doesnt have the item
	if multibaby ~= nil and riftEntity ~= nil then
		multibaby.Position = riftEntity.Position
		multibaby.Visible = false
	end



	if oldroom ~= Game():GetRoom():GetSpawnSeed() then
		oldroom = Game():GetRoom():GetSpawnSeed()
		isUsed = false
		if riftentity ~= nil then
			riftentity:Remove()
			riftentity = nil
		end
		if multibaby ~= nil then
			multibaby:Remove()
			multibaby = nil
		end
	end

	if isUsed == true then
		if riftEntity:GetSprite():IsFinished("Disappear") then
			riftEntity:Remove()
			multibaby:Remove()
		end
	end

	if isUsed ~= true then return end

	local ents = Isaac.GetRoomEntities()
	for i=1,#ents do
		--Delete all doubled rifts
		if ents[i].Type == riftEntityType and ents[i].Index ~= riftEntity.Index then
			ents[i]:Remove()
		end
		if ents[i].Type == 3 and ents[i].Variant == FamiliarVariant.MULTIDIMENSIONAL_BABY and ents[i].Index ~= multibaby.Index then
			ents[i]:Remove()
		end

		--Velocity for pickups towards rift
		if ents[i].Type == EntityType.ENTITY_PICKUP then
			didWork2 = true
			if (ents[i].Variant > 0 and ents[i].Variant <= 90 and ents[i].Variant ~= 70) or ents[i].Variant == 360 then
				didWork = true
				ents[i].Velocity = ents[i].Velocity + (riftEntity.Position - ents[i].Position):Resized(0.4)

				if (ents[i].Position - riftEntity.Position):LengthSquared() <= 21 then
					Isaac.Spawn(ents[i].Type,ents[i].Variant,ents[i].SubType,ents[i].Position,ents[i].Velocity,player)
					riftEntity:GetSprite():Play("Disappear",true)
					isUsed = false
				end
			end
		end
	end

	if riftEntity:GetSprite():IsFinished("Appear") then
		riftEntity:GetSprite():Play("Idle",true)
	end

end

function Rift:on_Use(CollectibleType)
	local player = Isaac.GetPlayer(0)

	riftEntity = Isaac.Spawn(riftEntityType,0,0,player.Position, Vector(0, 0), player)
	multibaby = Isaac.Spawn(3,FamiliarVariant.MULTIDIMENSIONAL_BABY,0,player.Position, Vector(0, 0), player)
	multibaby.Visible = false
	isUsed = true
	return true
end

function Rift:multi_update(npc)
	if npc.Index ~= multibaby.Index then return end
	npc.Position = riftEntity.Position

end

function Rift:new_run()
	--Isaac.RenderText(tostring(test),50, 50, 255,255, 255, 255)
	--Isaac.RenderText(tostring(riftItem),50, 50, 255,255, 255, 255)
end

Rift:AddCallback( ModCallbacks.MC_FAMILIAR_UPDATE, Rift.multi_update,FamiliarVariant.MULTIDIMENSIONAL_BABY);
Rift:AddCallback( ModCallbacks.MC_POST_RENDER, Rift.new_run);
Rift:AddCallback( ModCallbacks.MC_POST_UPDATE, Rift.post_update);
Rift:AddCallback( ModCallbacks.MC_USE_ITEM, Rift.on_Use, RiftItem);