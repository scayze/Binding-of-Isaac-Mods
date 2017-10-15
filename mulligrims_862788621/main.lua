
local Mulligrims = RegisterMod("Mulligrim", 1)
local mulligrimEntity = Isaac.GetEntityTypeByName("Mulligrim")
local mulligrimVariant = Isaac.GetEntityVariantByName("Mulligrim")

local spawnCD = 14

local FLAG_SPECTRAL = 1
local FLAG_PIERCING = 1<<1

--Mod Update
function Mulligrims:Update()

	--Spawn to grid:
    local player = Isaac.GetPlayer(0)
    local level = Game():GetLevel()
    local room = Game():GetRoom()
	local ents = Isaac.GetRoomEntities()
	math.randomseed(room:GetSpawnSeed())
	for i=1,#ents do 

		if ents[i].Type == 42 and ents[i].FrameCount == 2 then
			if math.random() > 0.8 then
				math.randomseed(room:GetSpawnSeed() + ents[i].Index)
				ents[i]:ToNPC():Morph(42,2,0,0)
				ents[i]:ToNPC().ProjectileCooldown = spawnCD
			end
			if math.random() < 0.2 then
				math.randomseed(room:GetSpawnSeed() + ents[i].Index)
				ents[i]:ToNPC():Morph(42,3,0,0)
				ents[i]:ToNPC().ProjectileCooldown = spawnCD
			end

		end
	end
	
end

--Ashkait: RSTA MW17, caves 1, room on the right. Isaac Hard
--Mod GHOST / NPC Update
function Mulligrims:Mulligrim_Update(npc)
  	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local level = Game():GetLevel()
	if npc.Variant == 2 then
		npc.DepthOffset = -100
		if npc.ProjectileCooldown <= 2 then 
			npc.ProjectileCooldown = spawnCD
			npc:GetSprite():Play("Shoot",true)
		end
		if npc:GetSprite():IsFinished("Shoot") then
			npc:GetSprite():Play("Idle",true)

		end
		if npc:GetSprite():IsEventTriggered("shoot") then
			Isaac.Spawn(EntityType.ENTITY_ATTACKFLY,3,1,npc.Position + Vector(0,4), Vector(0,0),npc)
			npc:PlaySound(SoundEffect.SOUND_STONESHOOT,1,0,false,1)
		end
	end

	if npc.Variant == 3 then
		--Deny original behaviour and add own
		if npc.ProjectileCooldown <= 2 then 
			npc.ProjectileCooldown = spawnCD
			npc:GetSprite():Play("Shoot",true)
		end
		--Resume Idle animation
		if npc:GetSprite():IsFinished("Shoot") then
			npc:GetSprite():Play("Idle",true)
		end
		--On Shoot
		if npc:GetSprite():IsEventTriggered("shoot") then
			npc:PlaySound(SoundEffect.SOUND_STONESHOOT,1,0,false,1)
			--PlaySound (SoundEffect ID, float Volume, integer FrameDelay, boolean Loop, float Pitch)
			local od = player.Damage
			player.Damage = 0
			local tear = player:FireTear(npc.Position, (player.Position - npc.Position):Resized(6),false,true,false)
			tear.TearFlags = FLAG_PIERCING | FLAG_SPECTRAL
			tear.FallingSpeed = -6
			tear.FallingAcceleration = 0.3
			tear:ChangeVariant(TearVariant.STONE)
			tear:GetSprite():Load("gfx/085.000_spider.anm2",true)
			tear:GetSprite():Play("Idle",true)
			tear:GetSprite().Rotation = 0
			tear.Rotation = 0
			player.Damage = od
			npc:GetData().t = tear

		end
		--On Tear ded.
		if npc:GetData().t ~= nil then
			npc:GetData().t:GetSprite().Rotation = 0
			npc:GetData().t.Rotation = 0
			--npc:GetData().t:SetColor(Color(1, 1, 1, 1, 0, 0, 0), 99999, 99, false, false)
			if npc:GetData().t:Exists() == false then

				local s = Isaac.Spawn(EntityType.ENTITY_SPIDER,0,0,npc:GetData().t.Position, Vector(0,0),npc)
				s:GetSprite():Play("Idle",true)
				npc:GetData().t = nil 
			end
		end
	end
end

--On a new run 
function Mulligrims:NewRun()
	local player = Isaac.GetPlayer(0)


end

--update
Mulligrims:AddCallback(ModCallbacks.MC_POST_UPDATE, Mulligrims.Update)
--npc update
Mulligrims:AddCallback(ModCallbacks.MC_NPC_UPDATE, Mulligrims.Mulligrim_Update, mulligrimEntity)
--post player init
Mulligrims:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mulligrims.NewRun)
