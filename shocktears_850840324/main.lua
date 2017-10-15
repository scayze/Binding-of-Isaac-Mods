local ShockTears = RegisterMod( "ShockTear",1 );
local ShockTearsItem = Isaac.GetItemIdByName("Technology Zero")
local ShockTearsCostume = Isaac.GetCostumeIdByPath("gfx/characters/zerohead.anm2")

local had = false
local oldSeed = nil
local maxDistance = 350

function ShockTears:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)
	
	if oldSeed ~= room:GetDecorationSeed() then
		oldSeed = room:GetDecorationSeed()
		tears = {}
	end


	if player:HasCollectible(ShockTearsItem) then
		local cTable = {}
		
		local ents = Isaac.GetRoomEntities()
		for i=1,#ents do
			if ents[i].Type == EntityType.ENTITY_TEAR then
				table.insert(cTable,ents[i])
			end
			if ents[i].Type == EntityType.ENTITY_EFFECT and ents[i].Variant == EffectVariant.LASER_IMPACT then
				ents[i].Visible = false
			end
		end


		for i=1,#cTable do
			if cTable[i]:GetData().Las ~= nil then

				local laser = cTable[i]:GetData().Las

				if laser:GetData().To ~= nil and laser:GetData().From ~= nil then

					local start 	= laser:GetData().From.Position + Vector(0,laser:GetData().From:ToTear().Height)
					local endPoint 	= laser:GetData().To.Position + Vector(0,laser:GetData().To:ToTear().Height)

					local laserLength = (start - endPoint):Length()
					laser:SetTimeout(2)
					laser.Position = start
					laser.Angle = (endPoint - start):GetAngleDegrees()
					laser:SetMaxDistance(laserLength)
					--laser.ParentOffset = Vector(10000,50000000)

					-- Check if the length between the two tears is too long, if yes remove them
					if laserLength > maxDistance then
						laser:Remove()
						cTable[i]:GetData().Las = nil
					end
				else
					laser:Remove()
					cTable[i]:GetData().Las = nil
				end



			else

				local closestDist = 9999999999999
				local closestIDX = nil
				for j=1,#cTable do
					if cTable[j].Index ~= cTable[i].Index then
						if cTable[j].Las == nil or cTable[j].Las:GetData().To.Index ~= cTable[j].Index then
							local thisDist = (cTable[j].Position - cTable[i].Position):LengthSquared()
							if thisDist < closestDist and thisDist < maxDistance*maxDistance then
								closestDist = thisDist 
								closestIDX = j
							end
						end
					end
				end

				if closestIDX ~= nil then
					local laser = player:FireTechLaser( Vector(cTable[i].Position.X,cTable[i].Position.Y + player.TearHeight), -1, (cTable[closestIDX].Position - cTable[i].Position):Normalized(), false,false)
					laser.TearFlags = 1
					laser:SetColor(Color(0,0,0,0.7,170,170,210),9999999,99,false,false)
					--rgb(41, 128, 185)
					laser.Parent = cTable[i]
					laser:SetMaxDistance((cTable[closestIDX].Position - cTable[i].Position):Length())
					laser:GetData().From = cTable[i]
					laser:GetData().To = cTable[closestIDX]
					laser.DisableFollowParent = true
					cTable[i]:GetData().Las = laser
				end


			end
		end



		local ents2 = Isaac.GetRoomEntities()
		for i=1,#ents2 do
			if ents2[i].Type == EntityType.ENTITY_EFFECT and ents2[i].Variant == EffectVariant.LASER_IMPACT then
				ents2[i].Visible = false
			end
		end
	end
end

function ShockTears:onRunStart()
	had = false
end

function ShockTears:Sound(index)
	local player = Isaac.GetPlayer(0)
	local sound_entity = Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, player.Position, Vector(0,0), nil):ToNPC()
	sound_entity:PlaySound(index, 0.3, 0, false, 1)
	sound_entity:Remove()
end

function ShockTears:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()


	local ents2 = Isaac.GetRoomEntities()
	for i=1,#ents2 do
		if ents2[i].Type == EntityType.ENTITY_EFFECT and ents2[i].Variant == EffectVariant.LASER_IMPACT then
			ents2[i].Visible = false
		end
	end
	--Isaac.RenderText(tostring(timesShot),50, 50,1, 1,1, 1)
	--Isaac.RenderText(tostring(#cTable),50, 70,1, 1,1, 1)
	if player:HasCollectible(ShockTearsItem) == true and had == false then
		player:AddNullCostume(ShockTearsCostume)
		had = true
	end
	if player:HasCollectible(ShockTearsItem) == false and had == true then
		had = false
	end
end



function ShockTears:on_Damage(entity, amount, damageflag, source, countdownframes)
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(ShockTearsItem) == false then return end


end

ShockTears:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,ShockTears.on_Damage)
ShockTears:AddCallback(ModCallbacks.MC_POST_RENDER,ShockTears.drawText)
ShockTears:AddCallback(ModCallbacks.MC_POST_UPDATE,ShockTears.UPDATE)
ShockTears:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,ShockTears.OnRunStart)