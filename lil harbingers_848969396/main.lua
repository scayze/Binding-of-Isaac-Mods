local LilHarbinger = RegisterMod("7 Seals - Lil Harbingers",1 );
local familiarItem = Isaac.GetItemIdByName("7 Seals")
local familiarEntity = Isaac.GetEntityTypeByName("LilHarbinger")
local familiarEntityVariant = Isaac.GetEntityVariantByName("LilHarbinger")

local had = false
local timer = 0

function LilHarbinger:UPDATE()

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

function LilHarbinger:FamiliarInit(fam)
	fam:GetData().FlyDelay = 0
	fam:GetData().Timer = 0
	fam:GetData().Type = 0
	fam:GetData().Speed = 0
	fam:GetData().Fly = nil
	fami = fam
	fam:GetData().TargetPos = LilHarbinger:randomPos()

	LilHarbinger:rerollHarbinger(fam)
end


function LilHarbinger:randomPos()
	local room = Game():GetRoom()
	--math.randomseed(room:GetDecorationSeed())
	return Isaac.GetRandomPosition()
end

function LilHarbinger:toDirection(vec)
	if 		vec.X > 0 then return Direction.RIGHT
	elseif 	vec.X < 0 then return Direction.LEFT
	end

	return Direction.NO_DIRECTION
end

function LilHarbinger:randomTable(t)
	local keys, i = {}, 1
	for k,_ in pairs(t) do
	 keys[i] = k
	 i= i+1
	end

	local rand
	rand = math.random(1,#keys)
	return t[keys[rand]]
end

function LilHarbinger:rerollHarbinger(fam)
	local room = Game():GetRoom()

	math.randomseed(Game():GetFrameCount())
	fam:GetData().Type = math.random(1,5)

	local sprite = fam:GetSprite()

	if fam:GetData().Type == 1 then
		sprite:ReplaceSpritesheet(0,"gfx/miniwar.png")
		fam:GetData().FlyDelay = 150
		fam:GetData().Speed = 2.5
		fam.CollisionDamage = 1.5
	elseif fam:GetData().Type == 2 then
		sprite:ReplaceSpritesheet(0,"gfx/minipest.png")
		fam:GetData().FlyDelay = 90
		fam:GetData().Speed = 2
		fam.CollisionDamage = 0.5
	elseif fam:GetData().Type == 3 then
		sprite:ReplaceSpritesheet(0,"gfx/minifam.png")
		fam:GetData().FlyDelay = 90
		fam:GetData().Speed = 2
		fam.CollisionDamage = 0.5
	elseif fam:GetData().Type == 4 then
		sprite:ReplaceSpritesheet(0,"gfx/minideath.png")
		fam:GetData().FlyDelay = 90
		fam:GetData().Speed = 1.5
		fam.CollisionDamage = 1.5
	elseif fam:GetData().Type == 5 then
		sprite:ReplaceSpritesheet(0,"gfx/minicon.png")
		fam:GetData().FlyDelay = 0
		fam:GetData().Speed = 2
		fam.CollisionDamage = 0.5
	end
	sprite:LoadGraphics()

	sprite:Play("FloatDown",false)
	fam:GetData().TargetPos = LilHarbinger:randomPos()
	Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,fam.Position,Vector(0,0),player)
end

function LilHarbinger:FamiliarUpdate(fam)
	--Follow Position
	local player = Isaac.GetPlayer(0)
	local sprite = fam:GetSprite()
	--fam:ToNPC().Pathfinder:MoveRandomly(false)
	local room = Game():GetRoom()

	-- increment timer
	timer = timer + 1

	if timer >= 300 then
		timer = 0
		LilHarbinger:rerollHarbinger(fam)
	end



	--Set Velocity
	fam.Velocity = fam.Velocity + (fam:GetData().TargetPos - fam.Position):Resized(2)

	if fam:GetData().Type == 1 or fam:GetData().Type == 4 then

		if (fam.Position - fam:GetData().TargetPos):LengthSquared() <= 25 then 
			fam.Velocity = Vector(0,0)
		end

		if Game():GetFrameCount() % 3 then
			local ents = Isaac.GetRoomEntities()
			local closestEnt = nil
			local closestDist = 99999999999
			for i=1,#ents do
				if ents[i]:IsEnemy() then
					local dist = (ents[i].Position - fam.Position):LengthSquared()
					if dist < closestDist then
						closestDist = dist
						closestEnt = ents[i]
					end
				end
			end
			if closestEnt ~= nil then
				fam:GetData().TargetPos = closestEnt.Position
			else
				if (fam.Position - fam:GetData().TargetPos):LengthSquared() <= 25 then 
					fam:GetData().TargetPos = LilHarbinger:randomPos()
				end
			end
		end
	elseif fam:GetData().Type == 2 then

		if (fam.Position - fam:GetData().TargetPos):LengthSquared() <= 25 then 
			fam:GetData().TargetPos = LilHarbinger:randomPos()
		end

		if Game():GetFrameCount() % 12 == 0 and room:IsClear() == false then
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.PLAYER_CREEP_GREEN,0,fam.Position,Vector(0,0),player):ToEffect()
			creep:SetTimeout(120)
			creep.LifeSpan = 120
			creep:SetDamageSource(EntityType.ENTITY_PLAYER)
		end
	elseif fam:GetData().Type == 3 then

		if (fam.Position - fam:GetData().TargetPos):LengthSquared() <= 25 then 
			fam:GetData().TargetPos = LilHarbinger:randomPos()
		end

		if Game():GetFrameCount() % 12 == 0 and room:IsClear() == false then
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.PLAYER_CREEP_BLACK,0,fam.Position,Vector(0,0),player):ToEffect()
			creep:SetTimeout(120)
			creep.LifeSpan = 120
			creep:SetDamageSource(EntityType.ENTITY_PLAYER)
		end
	elseif fam:GetData().Type == 5 then
		if (fam.Position - fam:GetData().TargetPos):LengthSquared() <= 25 then 
			fam:GetData().TargetPos = LilHarbinger:randomPos()
		end
	end


	--Shorten  velocity
	if fam.Velocity:Length() > fam:GetData().Speed then fam.Velocity = fam.Velocity:Resized(fam:GetData().Speed) end



	fam:GetData().Timer = fam:GetData().Timer + 1
	if fam:GetData().Timer >= fam:GetData().FlyDelay and (fam:GetData().Fly == nil or fam:GetData().Fly:Exists() == false) then
		fam:GetData().Timer = 0

		--Spawn Fly
		local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, fam:GetData().Type, fam.Position, Vector(0, 0), fam)
		--Another one for conquest
		if fam:GetData().Type == 5 then
			fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, fam:GetData().Type, fam.Position, Vector(0, 0), fam)
		end

		--Anim and data
		sprite:Play("PreSpawn",true)
		fam:GetData().Fly = fly
	end

	--Animation triggers
	if sprite:IsFinished("PreSpawn") then
		sprite:Play("FloatDown")
	end

	--Animations
	local dir = LilHarbinger:toDirection(fam.Velocity)


	if dir== Direction.LEFT then
		sprite.FlipX = true
	elseif dir == Direction.RIGHT then
		sprite.FlipX = false
	end

end



function LilHarbinger:OnRunStart()
	had = false
end

function LilHarbinger:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	--Isaac.RenderText(tostring(player.Position.X) .. " " .. tostring(player.Position.Y),100,60,1,1,1,255)
	--Isaac.RenderText(tostring(fami:GetData().TargetPos.X) .. " " .. tostring(fami:GetData().TargetPos.Y),100,75,1,1,1,255)
end


LilHarbinger:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, LilHarbinger.FamiliarInit, familiarEntityVariant)
LilHarbinger:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LilHarbinger.FamiliarUpdate, familiarEntityVariant)

LilHarbinger:AddCallback(ModCallbacks.MC_POST_RENDER,LilHarbinger.drawText)
LilHarbinger:AddCallback(ModCallbacks.MC_POST_UPDATE,LilHarbinger.UPDATE)

LilHarbinger:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,LilHarbinger.OnRunStart)