local CustomFam = RegisterMod( "Attractive Buddy",1 );
local familiarItem = Isaac.GetItemIdByName("Attractive Buddy")
local familiarEntity = Isaac.GetEntityTypeByName("Attractive Buddy")
local familiarEntityVariant = Isaac.GetEntityVariantByName("Attractive Buddy")

had = false
distance = 1 
function CustomFam:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(familiarItem) then
		if had == false then
			local f = Isaac.Spawn(familiarEntity,familiarEntityVariant,0,player.Position,Vector(0,0),player)
			had = true
		end
	end
end

function CustomFam:FamiliarInit(fam)
	--fam:MoveDiagonally(3.5)
	--fam.GridCollisionClass = GridCollisionClass.COLLISION_WALL
	fam:GetSprite():PlayOverlay("Effect",true)
end

function CustomFam:FamiliarUpdate(fam)
	fam:MoveDiagonally(0.7)
	if fam:CollidesWithGrid() then
		--fam.Velocity = Vector(fam.Velocity.Y,-fam.Velocity.X)
	end
	
	local	entities = Isaac.GetRoomEntities( )
	for i = 1, #entities do
		if entities[i]:IsEnemy() or entities[i].Type == EntityType.ENTITY_PICKUP or entities[i].Type == EntityType.ENTITY_TEAR or entities[i].Type == ENTITY_BOMBDROP  then
		
			local vec = entities[i].Position - fam.Position
			distance = (220000 - vec:LengthSquared())/100000
			
			if distance < 0 then
				distance = 0
			end
			
			
			--local weigthMultiplier = 3
			--if entities[i].Mass ~= 0 then 
			--	local weigthMultiplier = fam.Mass/entities[i].Mass
			--end
			
			
			local multiplier = 0.25
			if entities[i]:IsEnemy() then
				multiplier = 0.33
			end
			
			entities[i].Velocity = entities[i].Velocity:__sub(vec:Normalized():__mul(multiplier * distance))
		end
	end
	
end

function CustomFam:OnRunStart()
	had = false
end

function CustomFam:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	--Isaac.RenderText("FAGG",100,60,1,1,1,255)
end

CustomFam:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, CustomFam.FamiliarInit, familiarEntityVariant)
CustomFam:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, CustomFam.FamiliarUpdate, familiarEntityVariant)

CustomFam:AddCallback(ModCallbacks.MC_POST_RENDER,CustomFam.drawText)
CustomFam:AddCallback(ModCallbacks.MC_POST_UPDATE,CustomFam.UPDATE)

CustomFam:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,CustomFam.OnRunStart)