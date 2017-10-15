local ImaginaryFriend = RegisterMod( "ImaginaryFriend",1 )
local JumperItem = Isaac.GetItemIdByName( "Imaginary Friends" )
local IFcostume = Isaac.GetCostumeIdByPath("gfx/characters/frndscostume.anm2")

local lastent = 0
local list = {}
local indexlist = {}
local flylist = {}
local roomID = 0
local floor = 0
local had = false

function ImaginaryFriend:post_update( )
	local room = Game():GetRoom()
	local player = Isaac.GetPlayer(0)
	--Stop if he doesnt have the item
	if player:HasCollectible(JumperItem) == false then return end
		had = true
	if roomID ~= room:GetDecorationSeed() then
		list = {}
		indexlist = {}
		roomID = room:GetDecorationSeed()
	end

	if floor ~= Game():GetLevel():GetStage() then
		for i=1,#flylist do
			if flylist[i]:GetSprite():GetFilename() == "gfx/budgoldbomb.anm2" or flylist[i]:GetSprite():GetFilename() == "gfx/budgoldkey.anm2" then
				flylist[i]:Remove()
			end
		end
		floor = Game():GetLevel():GetStage()
	end

	--Loop through entities and check for picups
	local ents = Isaac.GetRoomEntities()

	for i=1,#ents do
		if ents[i].Type == EntityType.ENTITY_PICKUP and ents[i]:Exists() == true then
			local e = nil
			if ents[i].Variant == PickupVariant.PICKUP_HEART then
				e = ents[i]
			elseif ents[i].Variant == PickupVariant.PICKUP_COIN then
				e = ents[i]
			elseif ents[i].Variant == PickupVariant.PICKUP_KEY then
				e = ents[i]
			elseif ents[i].Variant == PickupVariant.PICKUP_BOMB then
				e = ents[i]
			elseif ents[i].Variant == PickupVariant.PICKUP_LIL_BATTERY then
				e = ents[i]
			end

			if e ~= nil then
				local is = false
				for i=1,#indexlist do
					if indexlist[i] == e.Index then
						is = true 
					end
				end

				if is==false then
					table.insert(indexlist,e.Index)
					table.insert(list,e)
				end
			end
		end
	end

	for i=1,#list do
		if list[i] ~= nil then
			if list[i]:Exists() == false then

				if list[i].Variant == PickupVariant.PICKUP_HEART then
					if list[i].SubType == HeartSubType.HEART_FULL then
						local player = Isaac.GetPlayer(0)
						ImaginaryFriend:spawnHeartFly()
					elseif list[i].SubType == HeartSubType.HEART_HALF then
						ImaginaryFriend:spawnHeartFly()
					elseif list[i].SubType == HeartSubType.HEART_SOUL then
						ImaginaryFriend:spawnSoulHeartFly()
					elseif list[i].SubType == HeartSubType.HEART_SCARED then
						ImaginaryFriend:spawnHeartFly()
					elseif list[i].SubType == HeartSubType.HEART_DOUBLEPACK then
						ImaginaryFriend:spawnHeartFly()
						ImaginaryFriend:spawnHeartFly()
					elseif list[i].SubType == HeartSubType.HEART_BLACK then
						ImaginaryFriend:spawnBlackHeartFly()
					elseif list[i].SubType == HeartSubType.HEART_GOLDEN then
						ImaginaryFriend:spawnHeartFly()
						ImaginaryFriend:spawnCoinFly()
					elseif list[i].SubType == HeartSubType.HEART_HALF_SOUL then
						ImaginaryFriend:spawnSoulHeartFly()
					elseif list[i].SubType == HeartSubType.HEART_BLENDED then
						ImaginaryFriend:spawnBlackHeartFly()
						ImaginaryFriend:spawnSoulHeartFly()
					end

				elseif list[i].Variant == PickupVariant.PICKUP_COIN then

					if list[i].SubType == CoinSubType.COIN_PENNY or list[i].SubType == CoinSubType.COIN_LUCKYPENNY  then
						ImaginaryFriend:spawnCoinFly()
					elseif list[i].SubType == CoinSubType.COIN_NICKEL or list[i].SubType == CoinSubType.COIN_STICKYNICKEL then
						for i=1,5 do
							ImaginaryFriend:spawnCoinFly()
						end
					elseif list[i].SubType == CoinSubType.COIN_DIME then
						for i=1,10 do
							ImaginaryFriend:spawnCoinFly()	
						end
					elseif list[i].SubType == CoinSubType.COIN_DOUBLEPACK then
						for i=1,2 do
							ImaginaryFriend:spawnCoinFly()
						end
					end

				elseif list[i].Variant == PickupVariant.PICKUP_KEY then

					if list[i].SubType == KeySubType.KEY_NORMAL then
						ImaginaryFriend:spawnKeyFly()
					elseif list[i].SubType == KeySubType.KEY_GOLDEN then
						ImaginaryFriend:spawnGoldenKeyFly()
					elseif list[i].SubType == KeySubType.KEY_DOUBLEPACK then
						ImaginaryFriend:spawnKeyFly()
						ImaginaryFriend:spawnKeyFly()
					elseif list[i].SubType == KeySubType.KEY_CHARGED then
						ImaginaryFriend:spawnKeyFly()
						ImaginaryFriend:spawnBatteryFly()
					end

				elseif list[i].Variant == PickupVariant.PICKUP_BOMB then

					if list[i].SubType == BombSubType.BOMB_NORMAL then
						ImaginaryFriend:spawnBombFly()
					elseif list[i].SubType == BombSubType.BOMB_DOUBLEPACK then
						ImaginaryFriend:spawnBombFly()
						ImaginaryFriend:spawnBombFly()
					elseif list[i].SubType == BombSubType.BOMB_TROLL then

					elseif list[i].SubType == BombSubType.BOMB_GOLDEN then
						ImaginaryFriend:spawnGoldenBombFly()
					end

				elseif list[i].Variant == PickupVariant.PICKUP_LIL_BATTERY then
					ImaginaryFriend:spawnBatteryFly()
				end


				list[i] = nil
				indexlist[i] = nil
			end
		end
	end

end

function ImaginaryFriend:spawnHeartFly()
	local player = Isaac.GetPlayer(0)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector(0,0), player)
	fly:GetSprite():Load("gfx/budheart.anm2",true)
	fly:GetSprite():Play("Idle",true)
	fly:GetData().Type = "heart"
	table.insert(flylist,fly)
end

function ImaginaryFriend:spawnSoulHeartFly()
	local player = Isaac.GetPlayer(0)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector(0,0), player)
	fly:GetSprite():Load("gfx/budsoulheart.anm2",true)
	fly:GetSprite():Play("Idle",true)
	fly:GetData().Type = "soulheart"
	table.insert(flylist,fly)
end

function ImaginaryFriend:spawnBlackHeartFly()
	local player = Isaac.GetPlayer(0)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector(0,0), player)
	fly:GetSprite():Load("gfx/budblackheart.anm2",true)
	fly:GetSprite():Play("Idle",true)
	fly:GetData().Type = "blackheart"
	table.insert(flylist,fly)
end

function ImaginaryFriend:spawnCoinFly()
	local player = Isaac.GetPlayer(0)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector(0,0), player)
	fly:GetSprite():Load("gfx/budcoin.anm2",true)
	fly:GetSprite():Play("Idle",true)
	fly:GetData().Type = "coin"
	table.insert(flylist,fly)
end

function ImaginaryFriend:spawnKeyFly()
	local player = Isaac.GetPlayer(0)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector(0,0), player)
	fly:GetSprite():Load("gfx/budkey.anm2",true)
	fly:GetSprite():Play("Idle",true)
	fly:GetData().Type = "key"
	table.insert(flylist,fly)
end

function ImaginaryFriend:spawnGoldenKeyFly()
	local player = Isaac.GetPlayer(0)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector(0,0), player)
	fly:GetSprite():Load("gfx/budgoldkey.anm2",true)
	fly:GetSprite():Play("Idle",true)
	fly:GetData().Type = "goldenkey"
	table.insert(flylist,fly)
end

function ImaginaryFriend:spawnBombFly()
	local player = Isaac.GetPlayer(0)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector(0,0), player)
	fly:GetSprite():Load("gfx/budbomb.anm2",true)
	fly:GetSprite():Play("Idle",true)
	fly:GetData().Type = "bomb"
	table.insert(flylist,fly)
end

function ImaginaryFriend:spawnGoldenBombFly()
	local player = Isaac.GetPlayer(0)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector(0,0), player)
	fly:GetSprite():Load("gfx/budgoldbomb.anm2",true)
	fly:GetSprite():Play("Idle",true)
	fly:GetData().Type = "goldenbomb"
	table.insert(flylist,fly)
end

function ImaginaryFriend:spawnBatteryFly()
	local player = Isaac.GetPlayer(0)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector(0,0), player)
	fly:GetSprite():Load("gfx/budbattery.anm2",true)
	fly:GetSprite():Play("Idle",true)
	fly:GetData().Type = "battery"
	table.insert(flylist,fly)
end

function ImaginaryFriend:on_Damage(entity, amount, damageflag, source, countdownframes)
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(JumperItem) == false then return end

	if source.Type == EntityType.ENTITY_FAMILIAR and source.Variant == FamiliarVariant.BLUE_FLY then
		local e = nil 
		for i=1,#flylist do
			if flylist[i].Index == source.Entity.Index then e = flylist[i] end
		end


		if e:GetSprite():GetFilename() == "gfx/budkey.anm2" then
			entity:TakeDamage(amount,0,EntityRef(entity),0)
		end

		if e:GetSprite():GetFilename() == "gfx/budbomb.anm2" then
			Game():BombExplosionEffects(source.Position,50, 0,Color(1,1,1,1,0,0,0),player,1,false, true)
		end

		if e:GetSprite():GetFilename() == "gfx/budgoldkey.anm2" then
			entity:TakeDamage(amount,0,EntityRef(entity),0)
			ImaginaryFriend:spawnGoldenKeyFly()
		end

		if e:GetSprite():GetFilename() == "gfx/budgoldbomb.anm2" then
			Game():BombExplosionEffects(source.Position,50, 0,Color(1,1,1,1,0,0,0),player,1,false, true)
			ImaginaryFriend:spawnGoldenBombFly()
		end

		if e:GetSprite():GetFilename() == "gfx/budbattery.anm2" then
			entity:AddFreeze(source, 30)
		end

		if e:GetSprite():GetFilename() == "gfx/budheart.anm2" then
			entity:AddCharmed(30)
		end

		if e:GetSprite():GetFilename() == "gfx/budsoulheart.anm2" then
			Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CRACK_THE_SKY,0,e.Position,Vector(0,0),player)
		end

		if e:GetSprite():GetFilename() == "gfx/budblackheart.anm2" then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, false, false, false, false)
		end

	end

end



function ImaginaryFriend:post_render( )
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(JumperItem) == true and had == false then
		had = true
		player:AddNullCostume(IFcostume)
	end
	if player:HasCollectible(JumperItem) == false and had == true then
		had = false 
	end
end



function ImaginaryFriend:new_run()
	had = false
end

ImaginaryFriend:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG,ImaginaryFriend.on_Damage)
ImaginaryFriend:AddCallback( ModCallbacks.MC_POST_RENDER, ImaginaryFriend.post_render);
ImaginaryFriend:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, ImaginaryFriend.new_run);
ImaginaryFriend:AddCallback( ModCallbacks.MC_POST_UPDATE, ImaginaryFriend.post_update);