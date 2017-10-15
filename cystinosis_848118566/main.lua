local StoneShot = RegisterMod( "Cystinosis",1 );
local StoneShotItem = Isaac.GetItemIdByName("Cystinosis")
local StoneShotCostume = Isaac.GetCostumeIdByPath("gfx/characters/rockshothead.anm2")
local StoneShotTear = Isaac.GetEntityVariantByName("StoneTear")

local FLAG_CONFUSING = 1<<14

local had = false
local tears = {}
local test = 0
local tearDown = false

local oldSeed = nil
function StoneShot:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)
	
	if oldSeed ~= room:GetDecorationSeed() then
		oldSeed = room:GetDecorationSeed()
		tears = {}
	end


	if player:HasCollectible(StoneShotItem) then
		local cTable = {}
		
		i,v = next(tears, nil)
		while i do
	        cTable[i] = v
	        i,v = next(tears,i)
        end


		local ents = Isaac.GetRoomEntities()
		for i=1,#ents do
			if ents[i].Type == EntityType.ENTITY_TEAR then
				cTable[ents[i].Index] = nil
			end
			if ents[i].Type == EntityType.ENTITY_TEAR and ents[i].Variant ~= TearVariant.STONE then
				test = ents[i].Index
				ents[i]:ToTear().FallingSpeed = -2
				ents[i]:ToTear():ChangeVariant(TearVariant.STONE)
				local spr = ents[i]:GetSprite()
				spr:ReplaceSpritesheet(0,"gfx/rockshot.png")
				spr:LoadGraphics()
				tears[ents[i].Index] = ents[i]
			end
		end

		for key,value in pairs(cTable) do
			if value ~= nil then
				Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.IMPACT,0,value.Position,Vector(0,0),player)
				StoneShot:Sound(SoundEffect.SOUND_ROCK_CRUMBLE   )
				tears[key] = nil
			end
		end
	end
end

function StoneShot:onRunStart()
	tearDown = false
	had = false
end

function StoneShot:Sound(index)
	local player = Isaac.GetPlayer(0)
	local sound_entity = Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, player.Position, Vector(0,0), nil):ToNPC()
	sound_entity:PlaySound(index, 0.3, 0, false, 1)
	sound_entity:Remove()
end

--Stats and concussion effect
function StoneShot:Eval_Cache(play, cache)

	--Does the player have the item?
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(StoneShotItem) == false then return end
	--Range
	if cache == CacheFlag.CACHE_RANGE then
		player.TearHeight = player.TearHeight - 2
		player.TearFallingAcceleration = player.TearFallingAcceleration + 0.1
	end
	--Shotspeed
	if cache == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed - 0.2

	end
	--Damage
	if cache == CacheFlag.CACHE_DAMAGE then
		if tearDown == false then
			player.MaxFireDelay = math.floor(player.MaxFireDelay*1.2);
			tearDown = true
		end
		player.Damage = player.Damage +1

	end
	--Teardelay
	if cache == CacheFlag.CACHE_FIREDELAY then
		player.TearDelay = player.TearDelay - 50
	end

end

function StoneShot:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()

	if player:HasCollectible(StoneShotItem) == true and had == false then
		player:AddNullCostume(StoneShotCostume)
		had = true
	end
	if player:HasCollectible(StoneShotItem) == false and had == true then
		had = false
	end
end



function StoneShot:on_Damage(entity, amount, damageflag, source, countdownframes)
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(StoneShotItem) == false then return end

	if player.Luck + 4 > 20 * math.random() then
		if source.Type == EntityType.ENTITY_TEAR and entity:IsEnemy() then
			Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.SHOCKWAVE,0,source.Position,Vector(0,0),player):ToEffect():SetRadii(5,20)
		end
	end
end

StoneShot:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,StoneShot.on_Damage)
StoneShot:AddCallback(ModCallbacks.MC_POST_RENDER,StoneShot.drawText)
StoneShot:AddCallback(ModCallbacks.MC_POST_UPDATE,StoneShot.UPDATE)
StoneShot:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,StoneShot.OnRunStart)
StoneShot:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,StoneShot.Eval_Cache)