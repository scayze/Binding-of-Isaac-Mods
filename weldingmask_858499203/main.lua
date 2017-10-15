local WeldingMask = RegisterMod( "Welding Mask",1 );
local WeldingMaskItem = Isaac.GetItemIdByName("Welding Mask")
local WeldingMaskCostume = Isaac.GetCostumeIdByPath("gfx/characters/weldinghead.anm2")

local had = false

local oldSeed = nil
local t1 = Vector(0, 0)
local t2 = Vector(0, 0)

function WeldingMask:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(WeldingMaskItem) == false then return end

	local ents = Isaac.GetRoomEntities()
	for i=1,#ents do
		if ents[i].Type == EntityType.ENTITY_LASER then
			local laser = ents[i]:ToLaser()

			local p1 = laser.Position + Vector(0,-25)
			local p2 = laser:GetEndPoint() --+ (laser:GetEndPoint() - laser.Position):Resized(5000)
			local p3 = player.Position + Vector(0,-15)

			t1 = p2
			t2 = p1

			--Vektor von p1 nach p3;
			local vP1_P3 = Vector(p3.X - p1.X, p3.Y - p1.Y)
			--Vektor von P1 nach P2;
			local vP1_P2 = Vector(p2.X - p1.X, p2.Y - p1.Y)
			--Vektor vP1_P2 normalisiert
			local vP1_P2_norm = vP1_P2:Normalized()
			--Vektor vP1_P2_norm um nach links gedreht ( 90° )
			local vP1_P2_leftnorm = Vector(-vP1_P2_norm.Y, vP1_P2_norm.X)
			--Länge des Vektors vP1_P2 auf vP1_P2_leftnorm projektiert
			local projectedOnNormal = vP1_P3:Dot(vP1_P2_leftnorm:Normalized())
			--Länge des Vektors vP1_P2 auf vP1_P2_norm projektiert
			local projectedOnP1P2 = vP1_P3:Dot(vP1_P2_norm:Normalized())

			if math.abs(projectedOnNormal) < 20 and vP1_P2:Dot(vP1_P3) > 0 then--and projectedOnP1P2 < vP1_P2:Length() then
				--Findet eine Kollision Statt
				if laser:GetData().length == nil then

					laser:GetData().length = laser.LaserLength
				end
				Isaac.DebugString("shortend")
				laser:SetMaxDistance(vP1_P3:Length() - 30)
			else
				Isaac.DebugString("org")
				if laser:GetData().length ~= nil then
					laser:SetMaxDistance(laser:GetData().length)
				end
			end
		end
	end
		
end

function WeldingMask:onRunStart()
	had = false
end

function WeldingMask:drawText( )
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
--Isaac.RenderText(":",room:WorldToScreenPosition(t1).X,room:WorldToScreenPosition(t1).Y, 1,1, 1, 1)
--Isaac.RenderText(":",room:WorldToScreenPosition(t2).X,room:WorldToScreenPosition(t2).Y, 1,1, 1, 1)
	if player:HasCollectible(WeldingMaskItem) == true and had == false then
		player:AddNullCostume(WeldingMaskCostume)
		had = true
	end
	if player:HasCollectible(WeldingMaskItem) == false and had == true then
		had = false
	end
end



function WeldingMask:on_Damage(entity, amount, damageflag, source, countdownframes)
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(WeldingMaskItem) == false then return end
	--Isaac.RenderText(":",WorldToScreenPosition(t1).X,WorldToScreenPosition(t1).Y, float R, float G, float B, float A)
	if entity.Type == EntityType.ENTITY_PLAYER then
		if damageflag & DamageFlag.DAMAGE_LASER > 0 then
			return false
		end
	end
end

WeldingMask:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,WeldingMask.on_Damage)
WeldingMask:AddCallback(ModCallbacks.MC_POST_RENDER,WeldingMask.drawText)
WeldingMask:AddCallback(ModCallbacks.MC_POST_UPDATE,WeldingMask.UPDATE)
WeldingMask:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,WeldingMask.OnRunStart)