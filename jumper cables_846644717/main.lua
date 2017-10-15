local JumperCables = RegisterMod( "JumperCables",1 )
local JumperItem = Isaac.GetItemIdByName( "Jumper Cables" )

local killcount = 0
--local sprite = nil
local lastent = 0


function JumperCables:post_update( )

	local player = Isaac.GetPlayer(0)
	--Stop if he doesnt have the item
	if killcount >= 15 then
		killcount = 0 

		player:SetActiveCharge(player:GetActiveCharge() + 1)
	end

end


function JumperCables:on_Damage(entity, amount, damageflag, source, countdownframes)
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(JumperItem) == false then return end


	if entity:IsEnemy() and amount >= entity.HitPoints and entity.Type ~= EntityType.ENTITY_FIREPLACE then --FUCK YOU FIREPLACEES
		killcount = killcount + 1
		lastent = entity.Type
	end
end


function JumperCables:new_run()
	killcount = 0
end

JumperCables:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, JumperCables.new_run);
JumperCables:AddCallback( ModCallbacks.MC_POST_UPDATE, JumperCables.post_update);
JumperCables:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG, JumperCables.on_Damage);