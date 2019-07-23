---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rubim.
--- DateTime: 12/07/2018 07:01
---

local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell = HL.Spell
local Item = HL.Item
local mainAddon = RubimRH

local ProlongedPower = Item(142117)
local Healthstone = 5512
local autoAttack = Spell(6603)

function Item:IsBuffTrinket()

end

local AreaTrinket = {
    159611,
}

local function IsAreaTrinket(itemID)
    for i, itemArray in pairs() do
        if itemID == itemArray then
            return true
        end
    end
    return false
end

-- Trinket var
local trinket2 = 1030910
local trinket1 = 1030902

-- Trinket Ready
local function trinketReady(trinketPosition)
    local inventoryPosition
    
	if trinketPosition == 1 then
        inventoryPosition = 13
    end
    
	if trinketPosition == 2 then
        inventoryPosition = 14
    end
    
	local start, duration, enable = GetInventoryItemCooldown("Player", inventoryPosition)
    if enable == 0 then
        return false
    end

    if start + duration - GetTime() > 0 then
        return false
    end
	
	if RubimRH.db.profile.mainOption.useTrinkets[1] == false then
	    return false
	end
	
   	if RubimRH.db.profile.mainOption.useTrinkets[2] == false then
	    return false
	end	
	
    if RubimRH.db.profile.mainOption.trinketsUsage == "Everything" then
        return true
    end
	
	if RubimRH.db.profile.mainOption.trinketsUsage == "Boss Only" then
        if not UnitExists("boss1") then
            return false
        end

        if UnitExists("target") and not (UnitClassification("target") == "worldboss" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "rare") then
            return false
        end
    end	
    return true
end

-- Essence fix for QueueSkill
local EssencesID = {   
  297108,
  298273,
  298277,
  295373,
  299349,
  299353,
  295840,
  299355,
  299358,
  295258,
  299336,
  299338,
  295337,
  299345,
  299347,
  298452,
  299376,
  299378,
  302731,
  302982,
  302983,
  295186,
  298628,
  299334,
  298357,
  299372,
  299374,
}

function QueueSkill()
    local UnleashHeartOfAzeroth = Spell(280431)
    
	if RubimRH.QueuedSpell():ID() ~= 1 and Player:PrevGCDP(1, RubimRH.QueuedSpell()) then
        RubimRH.queuedSpell = { RubimRH.Spell[1].Empty, 0 }
    end
    
	--[[if RubimRH.QueuedSpell():IsReadyQueue() then
        -- Essence fix for QueueSkill
		for i = 1, #EssencesID do		
		    if RubimRH.QueuedSpell():ID() == #EssencesID[i] then
                return UnleashHeartOfAzeroth:Cast()		
		    else
                return RubimRH.QueuedSpell():Cast()
			end
        end
    end]]--

    if RubimRH.QueuedSpellAuto():ID() ~= 1 and Player:PrevGCDP(1, RubimRH.QueuedSpellAuto()) then
        RubimRH.queuedSpellAuto = { RubimRH.Spell[1].Empty, 0 }
    end

    if RubimRH.QueuedSpellAuto():IsReadyQueue() then
        return RubimRH.QueuedSpellAuto():Cast()
    end
end
--#TODO FIX THIS
-- 13.05.19 - Should now work as intended
function RubimRH.Shared()
    local ValidUnits = ValidMembersAlive(IsPlayer)  

   -- Start attack if we find a target in 40yards
	if (not Target:Exists() or Target:IsDeadOrGhost()) and RubimRH.AutoAttackON() then
	    --print("It works");  
		HL.GetEnemies(40)
		if Cache.EnemiesCount[40] >= 1 then
	        return 133015   
        end
    end
    
	if Player:AffectingCombat() then

        if Player:ShouldStopCasting() and Player:IsCasting() then
            return 249170
        end
		
		-- Healthstone in raid with at least 10 raid members alive. 
        if Item(Healthstone):IsReady() and IsInRaid() and ValidUnits >= 10 and Player:HealthPercentage() <= RubimRH.db.profile.mainOption.healthstoneper then
            return 538745
        end

        if Item(Healthstone):IsReady() and not IsInRaid() and Player:HealthPercentage() <= RubimRH.db.profile.mainOption.healthstoneper then
            return 538745
        end

        if HL.CombatTime() > 5 and Target:Exists() and ((Player:IsMelee() and Target:MaxDistanceToPlayer(true) <= 8) or (not Player:IsMelee())) and RubimRH.CDsON() and Player:CanAttack(Target) then
            for i = 1, #RubimRH.db.profile.mainOption.useTrinkets do
                if RubimRH.db.profile.mainOption.useTrinkets[1] == true then
                    if trinketReady(1) then
                        return trinket1
                    end
                end

                if RubimRH.db.profile.mainOption.useTrinkets[2] == true then
                    if trinketReady(2) then
                        return trinket2
                    end
                end
            end
        end

    end
end
