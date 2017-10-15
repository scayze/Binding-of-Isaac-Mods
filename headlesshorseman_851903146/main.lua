local LilHH = RegisterMod("Headless Horseman",1 );
local familiarItem = Isaac.GetItemIdByName("Headless Horsemini")
local HeadlessHorsemanHead = Isaac.GetEntityVariantByName("HHHead")
local HeadlessHorsemanBody = Isaac.GetEntityVariantByName("HHBody")

local had = false
local headstate = 0
local headfam= nil

function LilHH:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(familiarItem) then
		if had == false then
			--local f = nil

			headfam = Isaac.Spawn(3,HeadlessHorsemanHead,0,player.Position,Vector(0,0),player)
			--headfam = f
			Isaac.Spawn(3,HeadlessHorsemanBody,0,player.Position,Vector(0,0),player)

			had = true
		end
	end
end

function LilHH:HeadInit(fam)
	local player = Isaac.GetPlayer(0)
	fam:GetData().AttackDelay = 150
	fam:GetData().Speed = 2
	fam:GetData().State = 0
	fam:GetData().Target = nil
	fam:GetData().Loops = 0
	fam:GetData().Dir = Vector(0,0)
	fam:GetData().OldSeed = 0
	fam:GetSprite():Play("FloatDown",true)
end

function LilHH:BodyInit(fam)
	local player = Isaac.GetPlayer(0)
	fam:GetData().AttackDelay = 180
	fam:GetData().Speed = 2
	fam:GetData().OldSeed = 0
	fam:GetData().TargetPos = Isaac.GetRandomPosition()
	fam:GetSprite():Play("FloatDown",true)
end


function LilHH:HeadlessHead(fam)
	--Follow Position
	local player = Isaac.GetPlayer(0)
	local sprite = fam:GetSprite()
	local room = Game():GetRoom()

	if Game():GetRoom():GetDecorationSeed() ~= fam:GetData().OldSeed then
		fam:GetData().AttackDelay = 100
		fam:GetData().Speed = 2
		fam:GetData().State = 0
		fam:GetData().Target = nil
		fam:GetData().Loops = 0
		fam:GetData().Dir = Vector(0,0)
		fam:GetData().OldSeed = Game():GetRoom():GetDecorationSeed()
	end

	headstate = fam:GetData().State
	fam:GetData().AttackDelay = fam:GetData().AttackDelay - 1

	if fam:GetData().State == 0 then
		--Isaac.DebugString("FDSF")
		local ents = Isaac.GetRoomEntities()
		local closestEnt = nil
		local closestDist = 99999999999

		fam:GetData().Speed = 2

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
			fam:GetData().Target = closestEnt
		else
			fam:GetData().Target = player
		end

		if (fam:GetData().Target.Position - fam.Position):LengthSquared() >= 110*110 then
			fam.Velocity =  fam.Velocity + (fam:GetData().Target.Position - fam.Position):Resized(0.1)
		else
			fam.Velocity =  fam.Velocity / 1.02
		end


		if room:IsClear() == false then
			if fam:GetData().AttackDelay <= 0 then
				fam:GetData().AttackDelay = 100
				fam:GetData().State = math.random(1,2)
				fam:GetData().Dir = Vector(math.sign(fam:GetData().Target.Position.X - fam.Position.X),math.sign(fam:GetData().Target.Position.Y - fam.Position.Y))
				if fam:GetData().State == 1 then
					LilHH:Sound(SoundEffect.SOUND_MONSTER_YELL_A ,0.6,1.15)
					fam:GetSprite():Play("PreCharge",true)
				end

			end
		end
	end
	if fam:GetData().State == 1 then
		fam:GetData().Speed = 13

		fam.Velocity =  fam.Velocity + Vector(fam:GetData().Dir.X * 0.3,math.sign(fam:GetData().Target.Position.Y - fam.Position.Y) * 0.017)
		if fam.Position.X <= 0 and fam:GetData().Dir.X < 0 then
			fam.Position = Vector(room:GetGridWidth() * 40,fam.Position.Y)
			fam:GetData().Loops = fam:GetData().Loops + 1
		elseif fam.Position.X >= room:GetGridWidth() * 42 and fam:GetData().Dir.X > 0 then
			fam.Position = Vector(0,fam.Position.Y)
			fam:GetData().Loops = fam:GetData().Loops + 1
		end

		if fam:GetData().Loops == 2 and fam.Position.X < room:GetGridWidth() * 40 / 2 then
			fam:GetSprite():Play("FloatDown",true)
			fam:GetData().State = 0
			fam:GetData().Loops = 0
			fam:GetData().AttackDelay = 100
		end

	end
	if fam:GetData().State == 2 then
		LilHH:Sound(SoundEffect.SOUND_MONSTER_GRUNT_0,0.6,1.15)
		local sDir = (fam:GetData().Target.Position - fam.Position):Resized(0.8)
		fam:GetSprite():Play("Attack",true)
		fam:FireProjectile(sDir)
		fam:FireProjectile(sDir:Rotated(10))
		fam:FireProjectile(sDir:Rotated(-10))
		fam:GetData().State = 0
		fam:GetData().AttackDelay = 100
	end

	if fam:GetSprite():IsFinished("Attack") then
		fam:GetSprite():Play("FloatDown",true)
	end
	if fam:GetSprite():IsFinished("PreCharge") then
		fam:GetSprite():Play("Charge",true)
	end


	if fam.Velocity:Length() >= fam:GetData().Speed then fam.Velocity = fam.Velocity / 1.1 end

	local dir = LilHH:toDirection(fam.Velocity)

	if dir== Direction.LEFT then
		fam:GetSprite().FlipX = true
	elseif dir == Direction.RIGHT then
		fam:GetSprite().FlipX = false
	end

end

function LilHH:HeadlessBody(fam)
	--Follow Position
	local player = Isaac.GetPlayer(0)
	local sprite = fam:GetSprite()
	local room = Game():GetRoom()

	if Game():GetRoom():GetDecorationSeed() ~= fam:GetData().OldSeed then
		fam:GetData().AttackDelay = 180
		fam:GetData().Speed = 2
		fam:GetData().TargetPos = Isaac.GetRandomPosition()
		fam:GetData().OldSeed = Game():GetRoom():GetDecorationSeed()
	end

	if room:IsClear() == false then fam:GetData().AttackDelay = fam:GetData().AttackDelay - 1 end

	if (fam.Position - fam:GetData().TargetPos):LengthSquared() <= 25 then 
		fam:GetData().TargetPos = Isaac.GetRandomPosition()
	end

	fam.Velocity =  fam.Velocity + (fam:GetData().TargetPos - fam.Position):Resized(0.1)
	if fam.Velocity:Length() >= fam:GetData().Speed then fam.Velocity = fam.Velocity / 1.1 end

	if fam:GetData().AttackDelay <= 0 then
		fam:GetData().AttackDelay = 180
		Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, fam.Position, Vector(0, 0), fam)
		fam:GetSprite():Play("PreSpawn",true)
	end

	if fam:GetSprite():IsFinished("PreSpawn") then
		fam:GetSprite():Play("FloatDown",true)
	end


	local dir = LilHH:toDirection(fam.Velocity)

	if dir== Direction.LEFT then
		fam:GetSprite().FlipX = true
	elseif dir == Direction.RIGHT then
		fam:GetSprite().FlipX = false
	end
end

function LilHH:toDirection(vec)
	if math.abs(vec.X) > math.abs(vec.Y) then
		if vec.X > 0 then 		return Direction.RIGHT
		elseif vec.X < 0 then	return Direction.LEFT
		end
	elseif math.abs(vec.X) < math.abs(vec.Y) then
		if vec.Y > 0 then 		return Direction.DOWN
		elseif vec.Y < 0 then	return Direction.UP
		end
	end

	return Direction.NO_DIRECTION
end


function LilHH:OnRunStart()
	had = false
end

function LilHH:Sound(index,volume,pitch)
	local player = Isaac.GetPlayer(0)
	local sound_entity = Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, player.Position, Vector(0,0), nil):ToNPC()
	sound_entity:PlaySound(index, volume, 0, false, pitch)
	sound_entity:Remove()
end


function LilHH:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
--	Isaac.RenderText(tostring(headfam.Position.X) .. " " .. tostring(headfam.Position.Y),100,60,1,1,1,255)
	--Isaac.RenderText(tostring(headstate),100,55,1,1,1,255)
	--Isaac.RenderText(tostring(room:GetGridWidth() * 40),100,75,1,1,1,255)
end



function math.sign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end




LilHH:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, LilHH.HeadInit, HeadlessHorsemanHead)
LilHH:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, LilHH.BodyInit, HeadlessHorsemanBody)
LilHH:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LilHH.HeadlessHead, HeadlessHorsemanHead)
LilHH:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LilHH.HeadlessBody, HeadlessHorsemanBody)

LilHH:AddCallback(ModCallbacks.MC_POST_RENDER,LilHH.drawText)
LilHH:AddCallback(ModCallbacks.MC_POST_UPDATE,LilHH.UPDATE)

LilHH:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,LilHH.OnRunStart)


-- Rotate vector
function LilHH:Rotate(v,angle)
	return Vector(v.X*math.cos(angle) - v.Y*math.sin(angle), v.X*math.sin(angle) + v.Y*math.cos(angle));
end

--Rotate Point around another point
function LilHH:RotateAroundPoint(p,pivot,angle)
	return Vector(math.cos(angle) * (p.X - pivot.X) - math.sin(angle) * (p.Y - pivot.Y) + pivot.X,math.sin(angle) * (p.X - pivot.X) + math.cos(angle) * (p.Y - pivot.Y) + pivot.Y)
end

--Get Rotation of vector (from (0|0))
function LilHH:GetRotation(p)
	return math.atan2(p.Y, p.X);
end

-- PI
function LilHH:PI()
	return 3.14159265359
end