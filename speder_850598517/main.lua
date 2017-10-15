local SpiderFriend = RegisterMod("SpeederFriend",1 );
local familiarItem = Isaac.GetItemIdByName("Rainbow spider")

local had = false
local timer = 0
local spider = nil

function SpiderFriend:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(familiarItem) == false then return end

	if had == false or timer >= 100 then
		timer = 0
		spider = Isaac.Spawn(EntityType.ENTITY_FAMILIAR,FamiliarVariant.BLUE_SPIDER,0,player.Position,Vector(0,0),player)
		SpiderFriend:FamiliarInit()
		had = true
	end

	if spider:Exists() == false then
		timer = timer + 1
	end





end

function SpiderFriend:FamiliarInit()
	spider:GetData().Type = 0
	SpiderFriend:rerollSpider()
end


function SpiderFriend:randomPos()
	local room = Game():GetRoom()
	--math.randomseed(room:GetDecorationSeed())
	return Isaac.GetRandomPosition()
end

function SpiderFriend:toDirection(vec)
	if 		vec.X > 0 then return Direction.RIGHT
	elseif 	vec.X < 0 then return Direction.LEFT
	end

	return Direction.NO_DIRECTION
end

function SpiderFriend:randomTable(t)
	local keys, i = {}, 1
	for k,_ in pairs(t) do
	 keys[i] = k
	 i= i+1
	end

	local rand
	rand = math.random(1,#keys)
	return t[keys[rand]]
end

function SpiderFriend:rerollSpider()
	local room = Game():GetRoom()

	math.randomseed(Game():GetFrameCount())
	spider:GetData().Type = math.random(1,8)

	local sprite = spider:GetSprite()
	sprite:Load("gfx/spiderfrienda.anm2",false)
	sprite:ReplaceSpritesheet(0,"gfx/black.png")
	if spider:GetData().Type == 1 then
		sprite:ReplaceSpritesheet(0,"gfx/black.png")
	elseif spider:GetData().Type == 2 then
		sprite:ReplaceSpritesheet(0,"gfx/green.png")
	elseif spider:GetData().Type == 3 then
		sprite:ReplaceSpritesheet(0,"gfx/orange.png")
	elseif spider:GetData().Type == 4 then
		sprite:ReplaceSpritesheet(0,"gfx/red.png")
	elseif spider:GetData().Type == 5 then
		sprite:ReplaceSpritesheet(0,"gfx/white.png")
	elseif spider:GetData().Type == 6 then
		sprite:ReplaceSpritesheet(0,"gfx/yellow.png")
	elseif spider:GetData().Type == 7 then
		sprite:ReplaceSpritesheet(0,"gfx/purple.png")
	elseif spider:GetData().Type == 8 then
		sprite:ReplaceSpritesheet(0,"gfx/blue.png")
	end

	sprite:LoadGraphics()

	--sprite:Play("FloatDown",false)
	Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,spider.Position,Vector(0,0),player)
end

function SpiderFriend:on_Damage(entity, amount, damageflag, source, countdownframes)
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(familiarItem) == false then return end
	if entity:IsEnemy() and spider.Index == source.Entity.Index and source.Type == EntityType.ENTITY_FAMILIAR and source.Variant == FamiliarVariant.BLUE_SPIDER then
		if spider:GetData().Type == 1 then
			entity:AddFear(source,30)
		elseif spider:GetData().Type == 2 then
			entity:AddPoison(source,30,4)
		elseif spider:GetData().Type == 3 then
			entity:AddBurn(source,30,5)
		elseif spider:GetData().Type == 4 then
			entity:AddCharmed(30)
		elseif spider:GetData().Type == 5 then
			entity:AddSlowing(source,30,1,Color(1,1,1,1,0,0,0))
		elseif spider:GetData().Type == 6 then
			entity:AddFreeze(source,30)
		elseif spider:GetData().Type == 7 then
			entity:AddShrink(source,30)
		elseif spider:GetData().Type == 8 then
			entity:AddConfusion(source,30,true)
		end
	end
end

function SpiderFriend:OnRunStart()
	local had = false
	local timer = 0
	local spider = nil
end

function SpiderFriend:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	--Isaac.RenderText(tostring(player.Position.X) .. " " .. tostring(player.Position.Y),100,60,1,1,1,255)
	--if spider == nil then return end
	--Isaac.RenderText(tostring(spider:GetData().Type),100,75,1,1,1,255)
end

SpiderFriend:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,SpiderFriend.on_Damage)
SpiderFriend:AddCallback(ModCallbacks.MC_POST_RENDER,SpiderFriend.drawText)
SpiderFriend:AddCallback(ModCallbacks.MC_POST_UPDATE,SpiderFriend.UPDATE)

SpiderFriend:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,SpiderFriend.OnRunStart)