local PotHead = RegisterMod( "PotHead",1 );
local PotHeadItem = Isaac.GetItemIdByName("Pothead")
local PotHeadCostume = Isaac.GetCostumeIdByPath("gfx/characters/potcostume.anm2")

local PotEntity = Isaac.GetEntityTypeByName("BluePot")

local BluePot = Isaac.GetEntityVariantByName("BluePot")
local GreenPot = Isaac.GetEntityVariantByName("GreenPot")
local PurplePot = Isaac.GetEntityVariantByName("PurplePot")
local RedPot = Isaac.GetEntityVariantByName("RedPot")


local tears = {}
local had = false
local oldSeed = 0

function PotHead:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)
	
	if oldSeed ~= room:GetDecorationSeed() then
		oldSeed = room:GetDecorationSeed()
		tears = {}
	end
	math.randomseed(room:GetFrameCount() + Random() + math.random() )

	if player:HasCollectible(PotHeadItem) == false then return end

	local startColor = {r=0.8,g=0.8,b=0}
	local endColor = {r=0,g=0,b=1}
	for i=1,#tears do
		local c = Color(0,0,0.5+(math.sin(tears[i].FrameCount/3)+1)*0.25,1,0,0,0)
		--local c = Color(0.89- (math.sin(tears[i].FrameCount/10)+1)*0.4,0.8 - (math.sin(tears[i].FrameCount/10)+1)*0.4,0+(math.sin(tears[i].FrameCount/10)+1)*0.5,1,0,0,0)
		tears[i]:SetColor(c,9999,99,false,false  ) 
	end
	
	local ents = Isaac.GetRoomEntities()
	for i=1,#ents do 
		if ents[i].Type == EntityType.ENTITY_TEAR and ents[i].Parent.Type == EntityType.ENTITY_PLAYER then
			if ents[i]:GetData().evaled == nil then
				if player.Luck + 4 > math.random() * 29 then
					--ents[i]:SetColor(Color(0, 3, 9, 1, 2, 3, 9), 99999, 99, false, false)
					table.insert(tears,ents[i])
				end
				ents[i]:GetData().evaled = true
			end
		end
	end

end

function PotHead:pot_update(npc)
	if npc:GetSprite():IsFinished("Appear") then
		npc:GetSprite():Play("Idle",true)
	end
end

function PotHead:onRunStart()
	tearDown = false
	had = false
end



function PotHead:Sound(index)
	local player = Isaac.GetPlayer(0)
	local sound_entity = Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, player.Position, Vector(0,0), nil):ToNPC()
	sound_entity:PlaySound(index, 0.3, 0, false, 1)
	sound_entity:Remove()
end


function PotHead:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()

	--Isaac.RenderText(tostring(GreenPot), 60, 60, 1, 1,1, 1)

	if player:HasCollectible(PotHeadItem) == true and had == false then
		player:AddNullCostume(PotHeadCostume)
		had = true
	end
	if player:HasCollectible(PotHeadItem) == false and had == true then
		had = false
	end
end


function PotHead:on_Damage(entity, amount, damageflag, source, countdownframes)
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(PotHeadItem) == false then return end

	--TearMorph
	if entity:IsVulnerableEnemy() and entity:IsBoss() == false and entity.Type ~= PotEntity and source.Type == EntityType.ENTITY_TEAR then
		
		local isTear = false
		for i=1,#tears do
			if source.Entity.Index == tears[i].Index then isTear = true end
		end

		if isTear then
			local pot = Isaac.Spawn(PotEntity,math.random(0,3),0,entity.Position,Vector(0,0),player)
			entity:Remove()
		end
	end
	--PotDestroy
	if entity:IsVulnerableEnemy() and entity.Type == PotEntity and entity.HitPoints < amount and entity.HitPoints > 0 then
		if entity.Variant == BluePot then
			local npc = entity:ToNPC()
			local tearcount = 9
			local vel = Vector(7,0)

			-- This is fucking stupid
			local damage = player.Damage 
			local shotspeed = player.ShotSpeed
			local height = player.TearHeight
			local tearFlags = player.TearFlags
			local fallingspeed = player.TearFallingSpeed
			local fallaccel = player.TearFallingAcceleration
			local TearColor = player.TearColor

			player.Damage = 5
			player.ShotSpeed = 5
			player.TearHeight = -30
			player.TearFlags = 0
			player.TearFallingSpeed = 0
			player.TearFallingAcceleration = 0.14
			player.TearColor = Color(1, 1, 1, 1, 0, 0, 0)

			for i=1,tearcount do
				local t = player:FireTear(entity.Position,vel,false,true,false)
				t:SetColor(Color(1, 1, 1, 1, 0,0, 0), 99999, 99, false, false)
				t.Parent = t
				vel = vel:Rotated(360/tearcount)
				t:ChangeVariant(0)
				t.Scale = 1
			end

			player.Damage = damage
			player.ShotSpeed = shotspeed
			player.TearHeight = height
			player.TearFlags = tearFlags
			player.TearFallingSpeed = fallingspeed
			player.TearFallingAcceleration = fallaccel
			player.TearColor = TearColor
			-- end of cancerous code. 

		elseif entity.Variant == GreenPot then
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.PLAYER_CREEP_GREEN,0,entity.Position,Vector(0,0),entity):ToEffect()
			creep.LifeSpan = 120

			local r = math.random(0,5)	
			if r == 0 then creep:GetSprite():Play("BiggestBlood1",true)
			elseif r == 1 then creep:GetSprite():Play("BiggestBlood2",true)
			elseif r == 2 then creep:GetSprite():Play("BiggestBlood3",true)
			elseif r == 3 then creep:GetSprite():Play("BiggestBlood4",true)
			elseif r == 4 then creep:GetSprite():Play("BiggestBlood5",true)
			elseif r == 5 then creep:GetSprite():Play("BiggestBlood6",true)
			end
			creep:GetSprite().Scale = Vector(1.8,1.8)
			creep:SetTimeout(120)
			--creep.LifeSpan = 2600
			--creep:SetColor(Color(1, 1, 1, 1, 70, 150, 0), 99999, 99, false, false)
		elseif entity.Variant == PurplePot then
			local ents = Isaac.GetRoomEntities()
			for i=1,#ents do
				if ents[i]:IsEnemy() then
					if (ents[i].Position - entity.Position):Length() < 180 then
						ents[i]:AddFear(source,60)
					end
				end
			end

			local fart = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FART,0,entity.Position,Vector(0,0),entity)
			fart:SetColor(Color(1, 1, 1, 1, 70, 0, 150), 99999, 99, false, false)

		elseif entity.Variant == RedPot then
			if entity:GetData().put == nil then
				entity:GetData().put = true
				Game():BombExplosionEffects(entity.Position,60, 0,Color(1,1,1,1,0,0,0),entity,1,false,entity)
			end
			Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.RED_CANDLE_FLAME,0,entity.Position,Vector(0,0),entity)
		end
	end
end

PotHead:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,PotHead.on_Damage)
PotHead:AddCallback(ModCallbacks.MC_POST_RENDER,PotHead.drawText)
PotHead:AddCallback(ModCallbacks.MC_POST_UPDATE,PotHead.UPDATE)
PotHead:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,PotHead.OnRunStart)
PotHead:AddCallback(ModCallbacks.MC_NPC_UPDATE,PotHead.pot_update,PotEntity)
