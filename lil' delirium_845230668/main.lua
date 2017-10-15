local LilDelirium = RegisterMod( "Lil Delirium",1 );
local LilDeliriumItem = Isaac.GetItemIdByName("Lil' Delirium")
--Familiar Variants

Familiars = {}

Familiars[3] = "littlechubby.png"
Familiars[4] = "littlegish.png"
Familiars[47] = "cubeofmeatlevel4.png"
Familiars[51] = "drybaby.png"
Familiars[53] = "robobaby20.png"
Familiars[54] = "rottenbaby.png"
Familiars[55] = "headlessbaby.png"
Familiars[58] = "bff.png"
Familiars[59] = "bobsbrain.png"
Familiars[61] = "lilbrimstone.png"
Familiars[63] = "lilhaunt.png"
Familiars[80] = "incubus.png"
Familiars[87] = "lilgurdy.png"
Familiars[92] = "seraphim.png"
Familiars[107] = "hushy.png"
Familiars[108] = "lilmonstro.png"
Familiars[112] = "acidbaby.png"


local had = 0
local entityList = {}

function LilDelirium:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)

	if player:HasCollectible(LilDeliriumItem) == false then return end

	if player:GetCollectibleNum(LilDeliriumItem) > had then
		respawnFamiliar(had+1)
		had = had + 1
	end


	if #entityList == 0 then return end

	for i=1,#entityList do

		if entityList[i]:GetData().timer == nil then entityList[i]:GetData().timer = 0 end

		entityList[i]:GetData().timer = entityList[i]:GetData().timer + 1
		if entityList[i]:GetData().timer >=300 then
			entityList[i]:GetData().timer = 0
			respawnFamiliar(i)
		end
	end
end

function LilDelirium:OnRunStart()
	had = 0
	entityList = {}
end

function LilDelirium:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()

	--if entityList[0]:GetData().timer ~= nil then Isaac.RenderText(tostring(entityList[0]:GetData().timer),100,60,1,1,1,255) end
	--if entityList[1]:GetData().timer ~= nil then Isaac.RenderText(tostring(entityList[1]:GetData().timer),100,75,1,1,1,255) end
	--if entityList[2]:GetData().timer ~= nil then Isaac.RenderText(tostring(entityList[2]:GetData().timer),100,90,1,1,1,255) end
end

function respawnFamiliar(index)
	local player = Isaac.GetPlayer(0)
	local pos = player.Position
	local vel = Vector(0, 0)

	if entityList[index] ~= nil then
		pos = entityList[index].Position
		vel = entityList[index].Velocity
		entityList[index]:Remove()
	end

	entityList[index] = Isaac.Spawn(3,LilDelirium:randomTable(Familiars),0,pos,vel,player)
	local data = entityList[index]:GetData()
	data.timer = 0

	local sprite = entityList[index]:GetSprite()


	if entityList[index].Variant == 47 then 
		sprite:Load("gfx/com.anm2",false)
		sprite:ReplaceSpritesheet(1,"gfx/Spritesheets/" .. Familiars[entityList[index].Variant])
		sprite:ReplaceSpritesheet(0,"gfx/Spritesheets/" .. "sexylegs.png")
		sprite:LoadGraphics()
		return
	end

	sprite:ReplaceSpritesheet(0,"gfx/Spritesheets/" .. Familiars[entityList[index].Variant])
	sprite:LoadGraphics()




	return entityList[index]
end

function LilDelirium:randomTable(t)
	local keys, i = {}, 1
	for k,_ in pairs(t) do
		keys[i] = k
		i= i+1
	end
	return keys[math.random(1,#keys)]
	--return t[keys[rand]]
end

LilDelirium:AddCallback(ModCallbacks.MC_POST_RENDER,LilDelirium.drawText)
LilDelirium:AddCallback(ModCallbacks.MC_POST_UPDATE,LilDelirium.UPDATE)

LilDelirium:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,LilDelirium.OnRunStart)