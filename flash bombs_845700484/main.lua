local Blanks = RegisterMod( "Blank Bombs",1 );
local blanksItem = Isaac.GetItemIdByName("Blank Bombs")

local oldBBF = false
local oldBB = false

function Blanks:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(blanksItem) == true then
		local entities = Isaac.GetRoomEntities()

		local bb = false
		local bbf = false


		for i=1,#entities do
			--Normal bombs
			if entities[i].Type == EntityType.ENTITY_BOMBDROP and entities[i].SpawnerType == EntityType.ENTITY_PLAYER then
				local sprite = entities[i]:GetSprite()
				--If First frame
				if entities[i].FrameCount  == 1 then
					sprite:Load("gfx/flashbomb.anm2",false)
					sprite:LoadGraphics()
				end

				--If exploding
				if sprite:IsPlaying("Explode") then
					Blanks:TriggerEffect(4)
				end
			end

			--Bobs brain
			if entities[i].Type == EntityType.ENTITY_FAMILIAR and entities[i].Variant == FamiliarVariant.BOBS_BRAIN then
				bb = entities[i]:IsVisible()
			end
			
			-- BFF
			if entities[i].Type == EntityType.ENTITY_FAMILIAR and entities[i].Variant == FamiliarVariant.BBF then
				bbf = entities[i]:IsVisible()
			end
		end

		if bb == false and oldBB == true then
			Blanks:TriggerEffect(30)
		end
		
		if bbf == false and oldBBF == true then
			Blanks:TriggerEffect(30)
		end

		oldBB = bb
		oldBBF = bff
			
	end
end

function Blanks:TriggerEffect(dur)
	local entities = Isaac.GetRoomEntities()
	for i=1,#entities do
		if entities[i]:IsEnemy() then
			entities[i]:AddSlowing(EntityRef(player),dur,1,Color(1,1,1,1,0,0,0))
		end
		if entities[i].Type == EntityType.ENTITY_PROJECTILE then
			entities[i]:Die()
		end
	end
end

function Blanks:OnRunStart()
end

function Blanks:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()


end

function Blanks:randomTable(t)
	local keys, i = {}, 1
	for k,_ in pairs(t) do
		keys[i] = k
		i= i+1
	end
	return keys[math.random(1,#keys)]
	--return t[keys[rand]]
end

Blanks:AddCallback(ModCallbacks.MC_POST_RENDER,Blanks.drawText)
Blanks:AddCallback(ModCallbacks.MC_POST_UPDATE,Blanks.UPDATE)
Blanks:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,Blanks.OnRunStart)