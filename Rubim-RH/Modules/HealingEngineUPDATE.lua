local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell = HL.Spell
local Item = HL.Item
local mainAddon = RubimRH
local currentZoneID = select(8, GetInstanceInfo())

local TargetColor = CreateFrame("Frame", "TargetColor", UIParent)
TargetColor:SetBackdrop(nil)
TargetColor:SetFrameStrata("TOOLTIP")
TargetColor:SetToplevel(true)
TargetColor:SetSize(1, 1)
TargetColor:SetScale(1);
TargetColor:SetPoint("TOPLEFT", 442, 0)
TargetColor.texture = TargetColor:CreateTexture(nil, "TOOLTIP")
TargetColor.texture:SetAllPoints(true)
TargetColor.texture:SetColorTexture(0, 0, 0, 1.0)
local members, incDMG_members, R_CustomT = {}, {}, {}
local R_Tanks, R_DPS, R_Heal, R_Stacked = {}, {}, {}, {}
local Frequency, FrequencyPairs = {}, {}

local type, pairs, wipe, huge = 
	  type, pairs, wipe, math.huge
local UnitAffectingCombat, UnitGetTotalAbsorbs = 
 UnitAffectingCombat, UnitGetTotalAbsorbs
local UnitGetIncomingHeals, UnitHealth, UnitHealthMax, UnitInRange, UnitGUID, UnitIsCharmed, UnitIsDeadOrGhost, UnitIsConnected, UnitThreatSituation, UnitIsUnit, UnitExists, UnitIsPlayer =
UnitGetIncomingHeals, UnitHealth, UnitHealthMax, UnitInRange, UnitGUID, UnitIsCharmed, UnitIsDeadOrGhost, UnitIsConnected, UnitThreatSituation, UnitIsUnit, UnitExists, UnitIsPlayer

--Update
RubimRH.HealingEngine = {}
RubimRH.HealingEngine.Refresh = 10
RubimRH.HealingEngine.UpdatePause = 0

RubimRH.HealingEngine.Members = {
	ALL = {},
	TANK = {},
	DAMAGER = {},
	HEALER = {},
	RAID = {},
	MOSTLYINCDMG = {},
}

RubimRH.HealingEngine.Frequency = {
	Actual = {},
	Temp = {},
}

function RubimRH.HealingEngine.Members:Wipe()
	for k, v in pairs(self) do 
		if type(v) == "table" then 
			wipe(self[k])	
		end 
	end 
end 

function RubimRH.HealingEngine.Frequency:Wipe()
	for k, v in pairs(self) do 
		if type(v) == "table" then 
			wipe(self[k])	
		end 
	end 
end 
	  
local Aura = {
	SmokeBomb = 76577,
} 	  

local function CalculateHP(unitID)	
    local incomingheals = UnitGetIncomingHeals(unitID) or 0
	local cHealth, mHealth = UnitHealth(unitID), UnitHealthMax(unitID)
	
    local PercentWithIncoming = 100 * (cHealth + incomingheals) / mHealth
    local ActualWithIncoming = mHealth - (cHealth + incomingheals)
	
    return PercentWithIncoming, ActualWithIncoming, cHealth, mHealth
end


local function CanHeal(unitID, unitGUID)
    return 
		UnitInRange(unitID)
		and UnitIsConnected(unitID)
		--and UnitCanCooperate("player", unitID)
		and not UnitIsCharmed(unitID)			
		and not RubimRH.InLOS(unitGUID or UnitGUID(unitID)) -- LOS System (target)
		and not RubimRH.InLOS(unitID)           		 	-- LOS System (another such as party)
	    and not UnitIsDeadOrGhost(unitID)
end

local healingTarget, healingTargetGUID = "None", "None"

local function HealingEngine(MODE, useActualHP)   
	local mode = MODE or "ALL"
    local ActualHP = useActualHP or false
	RubimRH.HealingEngine.Members:Wipe()
	
	if IsInRaid() then
        grouptype = "raid"
    elseif IsInGroup() then
        grouptype = "party"
    end	
	
    if grouptype ~= "raid" then 
		local pHP, aHP, _, mHP = CalculateHP("player")
        table.insert(RubimRH.HealingEngine.Members.ALL, { Unit = "player", GUID = UnitGUID("player"), HP = pHP, AHP = aHP, isPlayer = true, incDMG = getRealTimeDMG("player") })
    end 	
	
    local isQueuedDispel = false 
    local group = grouptype
    for i = 1, GetNumGroupMembers() do
        local member = group .. i        
        local memberhp, memberahp, _, membermhp = CalculateHP(member)
        local memberGUID = UnitGUID(member)

        -- Note: We can't use CanHeal here because it will take not all units results could be wrong
		RubimRH.HealingEngine.Frequency.Temp.MAXHP = (RubimRH.HealingEngine.Frequency.Temp.MAXHP or 0) + membermhp 
        RubimRH.HealingEngine.Frequency.Temp.AHP = (RubimRH.HealingEngine.Frequency.Temp.AHP or 0) + memberahp
        
        -- Party/Raid
        if CanHeal(member, memberGUID) then
            local DMG = getRealTimeDMG(member) 
            local Actual_DMG = DMG
            
            -- Stop decrease predict HP if offset for DMG more than 15% of member's HP
            local DMG_offset = membermhp * 0.15
            if DMG > DMG_offset then 
                DMG = DMG_offset
            end
            
            -- Checking if Member has threat
			local threat = UnitThreatSituation(member)
            if threat == 3 then
                memberhp = memberhp - threat
            end            
            
			-- Enable specific instructions by profile 
			--if RubimRH.IsGGLprofile then 
				-- Holy Paladin 
				if RubimRH.playerSpec == 65 then                 
					if (not isQueuedDispel and Unit(member, RubimRH.HealingEngine.Refresh):IsHealer()) and SpellUsable(4987) and not UnitIsUnit("player", member) then 
						-- DISPEL PRIORITY
						isQueuedDispel = true 
						-- if we will have lower unit than 50% then don't dispel it
						memberhp = 50
						if Unit(member, RubimRH.HealingEngine.Refresh):IsHealer() then 
							memberhp = 25
						end
					elseif Spell(287268):AzeriteRank() > 0 and Spell(20473):CooldownRemainsP() <= RubimRH.CurrentTimeGCD() and Unit(member, 0.5):BuffsRemainsP(287280) <= Player:GCD() then 
						-- Glimmer of Light 
						-- Generally, prioritize players that might die in the next few seconds > non-Beaconed tank (without Glimmer buff) > Beaconed tank (without Glimmer buff) > players without the Glimmer buff
						if RubimRH.PredictHeal("HolyShock", member) then 
							if Unit(member, RubimRH.HealingEngine.Refresh):IsTank() then 
								if Unit(member):HasBuffs({156910, 53563}, "player") == 0 then 
									memberhp = 35
								else 
									memberhp = 45
								end 
							else 
								memberhp = memberhp - 35
							end 
						else
							memberhp = memberhp - 10
						end 
					elseif memberhp < 100 then      
						-- Beacon HPS SYSTEM + hot current ticking and total duration
						local BestowFaith1, BestowFaith2 = Unit(member):HasBuffs(223306, "player")
						if BestowFaith1 > 0 then 
							memberhp = memberhp + ( 100 * (RubimRH.GetDescription(223306)[1]) / membermhp )
						end 
						-- Checking if Member has Beacons on them            
						if Unit(member):HasBuffs({53563, 156910}, "player") > 0 then
							memberhp = memberhp + ( 100 * (getHPS("player") * 0.4) / membermhp ) - ( 100 * DMG / membermhp )
						end  
					end 
				end 
				
				-- Restor Druid 
				if RubimRH.playerSpec == 105) then 					
					if (not isQueuedDispel or Unit(member, RubimRH.HealingEngine.Refresh):IsHealer()) and RubimRH.SpellUsable(88423) and not UnitIsUnit("player", member) and RubimRH.Dispel(member) then 
						-- DISPEL PRIORITY
						isQueuedDispel = true 
						memberhp = 50 
						-- if we will have lower unit than 50% then don't dispel it
						if Unit(member, RubimRH.HealingEngine.Refresh):IsHealer() then 
							memberhp = 25
						end						
					elseif memberhp < 100 then   
						-- HOT SYSTEM: current ticking and total duration
						local Rejuvenation1, Rejuvenation2 = Unit(member):HasBuffs(774, "player")
						local Regrowth1, Regrowth2 = Unit(member):HasBuffs(8936, "player")
						local WildGrowth1, WildGrowth2 = Unit(member):HasBuffs(48438, "player")
						local Lifebloom1, Lifebloom2 = Unit(member):HasBuffs(33763, "player")                
						local Germination1, Germination2 = Unit(member):HasBuffs(155777, "player") -- Rejuvenation Talent 
						local summup, summdmg = 0, {}
						if Rejuvenation1 > 0 then 
							summup = summup + (RubimRH.GetDescription(774)[1] / Rejuvenation2 * Rejuvenation1)
							table.insert(summdmg, Rejuvenation1)
						else
							-- If current target is Tank then to prevent staying on that target we will cycle rest units 
							if healingTarget and healingTarget ~= "None" and Unit(healingTarget, RubimRH.HealingEngine.Refresh):IsTank() then 
								memberhp = memberhp - 15
							else 
								summup = summup - (RubimRH.GetDescription(774)[1] * 3)
							end 
						end
						
						if Regrowth1 > 0 then 
							summup = summup + (RubimRH.GetDescription(8936)[2] / Regrowth2 * Regrowth1)
							table.insert(summdmg, Regrowth1)
						end
						
						if WildGrowth1 > 0 then 
							summup = summup + (RubimRH.GetDescription(48438)[1] / WildGrowth2 * WildGrowth1)
							table.insert(summdmg, WildGrowth1)                    
						end
						
						if Lifebloom1 > 0 then 
							summup = summup + (RubimRH.GetDescription(33763)[1] / Lifebloom2 * Lifebloom1) 
							table.insert(summdmg, Lifebloom1)    
						end
						
						if Germination1 > 0 then -- same with Rejuvenation
							summup = summup + (RubimRH.GetDescription(774)[1] / Germination2 * Germination1)
							table.insert(summdmg, Germination1)    
						end
						
						-- Get longer hot duration and predict incoming damage by that 
						table.sort(summdmg, function (x, y)
								return x > y
						end)
						
						-- Now we convert it to persistent (from value to % as HP)
						if summup > 0 then 
							-- current HP % with pre casting heal + predict hot heal - predict incoming dmg 
							memberhpHotSystem = memberhp + ( 100 * summup / membermhp ) - ( 100 * (DMG * summdmg[1]) / membermhp )
							if memberhpHotSystem < 100 then
								memberhp = memberhpHotSystem
							end
						end                    
					end
				end
				
				-- Discipline Priest
				if RubimRH.playerSpec == 256) then                 
					if (not isQueuedDispel or Unit(member, RubimRH.HealingEngine.Refresh):IsHealer()) and not UnitIsUnit("player", member) and (RubimRH.Dispel(member) or RubimRH.Purje(member) or RubimRH.MassDispel(member)) then 
						-- DISPEL PRIORITY
						isQueuedDispel = true 
						memberhp = 50 
						-- if we will have lower unit than 50% then don't dispel it
						if Unit(member, RubimRH.HealingEngine.Refresh):IsHealer() then 
							memberhp = 25
						end 
					elseif AtonementRenew_Toggle and Unit(member):HasBuffs(81749, "player") <= RubimRH.CurrentTimeGCD() then 				
						-- Toggle "Group Atonement/Renew﻿"
						memberhp = 50
					elseif memberhp < 100 then                    
						-- Atonement priority 
						if Unit(member):HasBuffs(81749, "player") > 0 and RubimRH.oPR and RubimRH.oPR["AtonementHPS"] then 
							memberhp = memberhp + ( 100 * RubimRH.oPR["AtonementHPS"] / membermhp )
						end 
						
						-- Absorb system 
						-- Pre pare 
						if CombatTime("player") <= 5 and 
						(
							CombatTime("player") > 0 or 
							(
								-- Pre shield before battle will start
								( RubimRH.Zone == "arena" or RubimRH.Zone == "pvp" ) and
								HL.GetTime() - RubimRH.ZoneTimeStampSinceJoined < 120                             
							)
						) and getAbsorb(member, 17) == 0 then 
							memberhp = memberhp - 10
						end                     
						
						-- Toggle or PrePare combat or while Rapture always
						if HE_Absorb or CombatTime("player") <= 5 or Unit("player"):HasBuffs(47536, "player") > RubimRH.CurrentTimeGCD() then 
							memberhp = memberhp + ( 100 * getAbsorb(member, 17) / membermhp )
						end 
					end 
				end 
				
				-- Holy Priest
				if RubimRH.playerSpec == 257) then                 
					if (not isQueuedDispel or Unit(member, RubimRH.HealingEngine.Refresh):IsHealer()) and not UnitIsUnit("player", member) and (RubimRH.Dispel(member) or RubimRH.Purje(member) or RubimRH.MassDispel(member)) then 
						-- DISPEL PRIORITY
						isQueuedDispel = true 
						memberhp = 50 
						-- if we will have lower unit than 50% then don't dispel it
						if Unit(member, RubimRH.HealingEngine.Refresh):IsHealer() then 
							memberhp = 25
						end  
					elseif AtonementRenew_Toggle and Unit(member):HasBuffs(139, "player") <= RubimRH.CurrentTimeGCD() then 				
						-- Toggle "Group Atonement/Renew﻿"
						memberhp = 50
					elseif memberhp < 100 then 
						if UnitIsTrailOfLight(member) then 
							-- Single Rotation 
							local ST = RubimRH.IsIconDisplay("TMW:icon:1RhherQmOw_V") or 0
							if ST == 2061 then 
								memberhp = memberhp + ( 100 * (RubimRH.GetDescription(2061)[1] * 0.35) / membermhp )
							elseif ST == 2060 then 
								memberhp = memberhp + ( 100 * (RubimRH.GetDescription(2060)[1] * 0.35) / membermhp )
							end 
						end 
					end 
				end 
			   
				-- Mistweaver Monk 
				if RubimRH.IsInitialized and ACTION_CONST_MONK_MW and UnitSpec("player", ACTION_CONST_MONK_MW) then 
					if (not isQueuedDispel or Unit(member, RubimRH.HealingEngine.Refresh):IsHealer()) and not UnitIsUnit("player", member) and RubimRH.AuraIsValid(member, "UseDispel", "Dispel") then 
						-- DISPEL PRIORITY
						isQueuedDispel = true 
						memberhp = 50 
						-- If we will have lower unit than 50% then don't dispel it
						if Unit(member, RubimRH.HealingEngine.Refresh):IsHealer() then 
							memberhp = 25
						end 
					elseif memberhp < 100 and RubimRH.GetToggle(2, "HealingEngineAutoHot") and A[ACTION_CONST_MONK_MW].RenewingMist:IsReady() then 
						-- Keep Renewing Mist hots as much as it possible on cooldown
						local RenewingMist = Unit(member):HasBuffs(A[ACTION_CONST_MONK_MW].RenewingMist.ID, true)
						if RenewingMist == 0 and RubimRH.PredictHeal("RenewingMist", A[ACTION_CONST_MONK_MW].RenewingMist.ID, member) then 
							memberhp = memberhp - 40
							if memberhp < 55 then 
								memberhp = 55 
							end 
						end 
					end 
				end 
			--end 
			
            -- Misc: Sort by Roles 		
            -- Tank			
            if Unit(member, RubimRH.HealingEngine.Refresh):IsTank() then
                memberhp = memberhp - 2
				
				if mode == "TANK" then 
					table.insert(RubimRH.HealingEngine.Members.TANK, 		{ Unit = member, GUID = memberGUID, HP = memberhp, AHP = memberahp, isPlayer = true, incDMG = Actual_DMG })      
				end 
            -- Healer
			elseif Unit(member, RubimRH.HealingEngine.Refresh):IsHealer() then                
                if UnitIsUnit("player", member) and memberhp < 95 then 
					--If we are in pvp and our current target is bursting
					if Player:InPvP() and Target:IsBursting() then 
						memberhp = memberhp - 20
					else 
						memberhp = memberhp - 2
					end 
                else 
                    memberhp = memberhp + 2
                end
				
				if mode == "HEALER" then 
					table.insert(RubimRH.HealingEngine.Members.HEALER, { Unit = member, GUID = memberGUID, HP = memberhp, AHP = memberahp, isPlayer = true, incDMG = Actual_DMG })  
				elseif mode == "RAID" then 	
					table.insert(RubimRH.HealingEngine.Members.RAID, { Unit = member, GUID = memberGUID, HP = memberhp, AHP = memberahp, isPlayer = true, incDMG = Actual_DMG })  
				end 				 
			else 
				memberhp = memberhp - 1
				
				if mode == "DAMAGER" then 
					table.insert(RubimRH.HealingEngine.Members.DAMAGER, { Unit = member, GUID = memberGUID, HP = memberhp, AHP = memberahp, isPlayer = true, incDMG = Actual_DMG })  
				elseif mode == "RAID" then  
					table.insert(RubimRH.HealingEngine.Members.RAID, { Unit = member, GUID = memberGUID, HP = memberhp, AHP = memberahp, isPlayer = true, incDMG = Actual_DMG })  
				end			 
            end

            table.insert(RubimRH.HealingEngine.Members.ALL, { Unit = member, GUID = memberGUID, HP = memberhp, AHP = memberahp, isPlayer = true, incDMG = Actual_DMG })  
        end        
        
        -- Pets 
        if RubimRH.HealPetsON() then
            local memberpet = group .. "pet" .. i
			local memberpetGUID = UnitGUID(memberpet)
			local memberpethp, memberpetahp, _, memberpetmhp = CalculateHP(memberpet) 
			
			-- Note: We can't use CanHeal here because it will take not all units results could be wrong
			RubimRH.HealingEngine.Frequency.Temp.MAXHP = (RubimRH.HealingEngine.Frequency.Temp.MAXHP or 0) + memberpetmhp 
			RubimRH.HealingEngine.Frequency.Temp.AHP = (RubimRH.HealingEngine.Frequency.Temp.AHP   or 0) + memberpetahp			
			
			if CanHeal(memberpet, memberpetGUID) then 
				if CombatTime("player") > 0 then                
					memberpethp  = memberpethp * 1.35
					memberpetahp = memberpetahp * 1.35
				else                
					memberpethp  = memberpethp * 1.15
					memberpetahp = memberpetahp * 1.15
				end
				
				table.insert(RubimRH.HealingEngine.Members.ALL, { Unit = memberpet, GUID = memberpetGUID, HP = memberpethp, AHP = memberpetahp, isPlayer = false, incDMG = getRealTimeDMG(memberpet) }) 
			end 
        end
    end
    
    -- Frequency (Summary)
    if RubimRH.HealingEngine.Frequency.Temp.MAXHP and RubimRH.HealingEngine.Frequency.Temp.MAXHP > 0 then 
        table.insert(RubimRH.HealingEngine.Frequency.Actual, { 	                
                -- Max Group HP
                MAXHP = RubimRH.HealingEngine.Frequency.Temp.MAXHP, 
                -- Current Group Actual HP
                AHP = RubimRH.HealingEngine.Frequency.Temp.AHP,
				-- Current Time on this record 
				TIME = HL.GetTime(), 
        })
		
		-- Clear temp by old record
        wipe(RubimRH.HealingEngine.Frequency.Temp)
		
		-- Clear actual from older records
        for i = #RubimRH.HealingEngine.Frequency.Actual, 1, -1 do             
            -- Remove data longer than 5 seconds 
            if HL.GetTime() - RubimRH.HealingEngine.Frequency.Actual[i].TIME > 10 then 
                table.remove(RubimRH.HealingEngine.Frequency.Actual, i)                
            end 
        end 
    end 
    
	-- Sort for next target / incDMG (Summary)
    if #RubimRH.HealingEngine.Members.ALL > 1 then 
        -- Sort by most damage receive
		for i = 1, #RubimRH.HealingEngine.Members.ALL do 
			local t = RubimRH.HealingEngine.Members.ALL[i]
			table.insert(RubimRH.HealingEngine.Members.MOSTLYINCDMG, { Unit = t.Unit, GUID = t.GUID, incDMG = t.incDMG })
		end 
        table.sort(RubimRH.HealingEngine.Members.MOSTLYINCDMG, function(x, y)
                return x.incDMG > y.incDMG
        end)  
        
        -- Sort by Percent or Actual
        if not ActualHP then
			for k, v in pairs(RubimRH.HealingEngine.Members) do 
				if type(v) == "table" and #v > 1 and v[1].HP then 
					table.sort(v, function(x, y) return x.HP < y.HP end)
				end 
			end 		
        elseif ActualHP then
			for k, v in pairs(RubimRH.HealingEngine.Members) do 
				if type(v) == "table" and #v > 1 and v[1].AHP then 
					table.sort(v, function(x, y) return x.AHP > y.AHP end)
				end 
			end 		
        end
    end 
end

local function setHealingTarget(MODE, HP)
    local mode = MODE or "ALL"
    local hp = HP or 99
	
	if #RubimRH.HealingEngine.Members[mode] > 0 and RubimRH.HealingEngine.Members[mode][1].HP < hp then 
		healingTarget 		= RubimRH.HealingEngine.Members[mode][1].Unit
		healingTargetGUID 	= RubimRH.HealingEngine.Members[mode][1].GUID
		return 
	end 
	
    healingTarget 	  = "None"
    healingTargetGUID = "None"
end

local function setColorTarget(isForced)
    --Default 
    TargetColor.texture:SetColorTexture(0, 0, 0, 1.0)   
	
	if not isForced then 
		--If we have no one to heal
		if healingTarget == nil or healingTarget == "None" or healingTargetGUID == nil or healingTargetGUID == "None" then
			return
		end	
		
		--If we have a mouseover friendly unit
		if UnitIsFriend("target", "mouseover") and UnitExists("mouseover") then       
			return
		end
		
		--If we have a current target equiled to suggested or he is a boss
		if UnitExists("target") and (healingTargetGUID == UnitGUID("target") or Unit("target", RubimRH.HealingEngine.Refresh):IsBoss()) then
			return
		end     
		
		--If we have enemy as primary unit 
		--TODO: Remove for old profiles until June 2019
		if healingTarget == nil or healingTargetGUID == nil or (UnitExists("mouseover") and not UnitIsFriend("target", "mouseover")) or RubimRH.TargetIsValid() then
			-- Old profiles 
			return 
		end 
    end 
	
    --Party
    if healingTarget == "party1" then
        TargetColor.texture:SetColorTexture(0.345098, 0.239216, 0.741176, 1.0)
        return
    end
    if healingTarget == "party2" then
        TargetColor.texture:SetColorTexture(0.407843, 0.501961, 0.086275, 1.0)
        return
    end
    if healingTarget == "party3" then
        TargetColor.texture:SetColorTexture(0.160784, 0.470588, 0.164706, 1.0)
        return
    end
    if healingTarget == "party4" then
        TargetColor.texture:SetColorTexture(0.725490, 0.572549, 0.647059, 1.0)
        return
    end   
    
    --PartyPET
    if healingTarget == "partypet1" then
        TargetColor.texture:SetColorTexture(0.486275, 0.176471, 1.000000, 1.0)
        return
    end
    if healingTarget == "partypet2" then
        TargetColor.texture:SetColorTexture(0.031373, 0.572549, 0.152941, 1.0)
        return
    end
    if healingTarget == "partypet3" then
        TargetColor.texture:SetColorTexture(0.874510, 0.239216, 0.239216, 1.0)
        return
    end
    if healingTarget == "partypet4" then
        TargetColor.texture:SetColorTexture(0.117647, 0.870588, 0.635294, 1.0)
        return
    end        
    
    --Raid
    if healingTarget == "raid1" then
        TargetColor.texture:SetColorTexture(0.192157, 0.878431, 0.015686, 1.0)
        return
    end
    if healingTarget == "raid2" then
        TargetColor.texture:SetColorTexture(0.780392, 0.788235, 0.745098, 1.0)
        return
    end
    if healingTarget == "raid3" then
        TargetColor.texture:SetColorTexture(0.498039, 0.184314, 0.521569, 1.0)
        return
    end
    if healingTarget == "raid4" then
        TargetColor.texture:SetColorTexture(0.627451, 0.905882, 0.882353, 1.0)
        return
    end
    if healingTarget == "raid5" then
        TargetColor.texture:SetColorTexture(0.145098, 0.658824, 0.121569, 1.0)
        return
    end
    if healingTarget == "raid6" then
        TargetColor.texture:SetColorTexture(0.639216, 0.490196, 0.921569, 1.0)
        return
    end
    if healingTarget == "raid7" then
        TargetColor.texture:SetColorTexture(0.172549, 0.368627, 0.427451, 1.0)
        return
    end
    if healingTarget == "raid8" then
        TargetColor.texture:SetColorTexture(0.949020, 0.333333, 0.980392, 1.0)
        return
    end
    if healingTarget == "raid9" then
        TargetColor.texture:SetColorTexture(0.109804, 0.388235, 0.980392, 1.0)
        return
    end
    if healingTarget == "raid10" then
        TargetColor.texture:SetColorTexture(0.615686, 0.694118, 0.435294, 1.0)
        return
    end
    if healingTarget == "raid11" then
        TargetColor.texture:SetColorTexture(0.066667, 0.243137, 0.572549, 1.0)
        return
    end
    if healingTarget == "raid12" then
        TargetColor.texture:SetColorTexture(0.113725, 0.129412, 1.000000, 1.0)
        return
    end
    if healingTarget == "raid13" then
        TargetColor.texture:SetColorTexture(0.592157, 0.023529, 0.235294, 1.0)
        return
    end
    if healingTarget == "raid14" then
        TargetColor.texture:SetColorTexture(0.545098, 0.439216, 1.000000, 1.0)
        return
    end
    if healingTarget == "raid15" then
        TargetColor.texture:SetColorTexture(0.890196, 0.800000, 0.854902, 1.0)
        return
    end
    if healingTarget == "raid16" then
        TargetColor.texture:SetColorTexture(0.513725, 0.854902, 0.639216, 1.0)
        return
    end
    if healingTarget == "raid17" then
        TargetColor.texture:SetColorTexture(0.078431, 0.541176, 0.815686, 1.0)
        return
    end
    if healingTarget == "raid18" then
        TargetColor.texture:SetColorTexture(0.109804, 0.184314, 0.666667, 1.0)
        return
    end
    if healingTarget == "raid19" then
        TargetColor.texture:SetColorTexture(0.650980, 0.572549, 0.098039, 1.0)
        return
    end
    if healingTarget == "raid20" then
        TargetColor.texture:SetColorTexture(0.541176, 0.466667, 0.027451, 1.0)
        return
    end
    if healingTarget == "raid21" then
        TargetColor.texture:SetColorTexture(0.000000, 0.988235, 0.462745, 1.0)
        return
    end
    if healingTarget == "raid22" then
        TargetColor.texture:SetColorTexture(0.211765, 0.443137, 0.858824, 1.0)
        return
    end
    if healingTarget == "raid23" then
        TargetColor.texture:SetColorTexture(0.949020, 0.949020, 0.576471, 1.0)
        return
    end
    if healingTarget == "raid24" then
        TargetColor.texture:SetColorTexture(0.972549, 0.800000, 0.682353, 1.0)
        return
    end
    if healingTarget == "raid25" then
        TargetColor.texture:SetColorTexture(0.031373, 0.619608, 0.596078, 1.0)
        return
    end
    if healingTarget == "raid26" then
        TargetColor.texture:SetColorTexture(0.670588, 0.925490, 0.513725, 1.0)
        return
    end
    if healingTarget == "raid27" then
        TargetColor.texture:SetColorTexture(0.647059, 0.945098, 0.031373, 1.0)
        return
    end
    if healingTarget == "raid28" then
        TargetColor.texture:SetColorTexture(0.058824, 0.490196, 0.054902, 1.0)
        return
    end
    if healingTarget == "raid29" then
        TargetColor.texture:SetColorTexture(0.050980, 0.992157, 0.239216, 1.0)
        return
    end
    if healingTarget == "raid30" then
        TargetColor.texture:SetColorTexture(0.949020, 0.721569, 0.388235, 1.0)
        return
    end
    if healingTarget == "raid31" then
        TargetColor.texture:SetColorTexture(0.254902, 0.749020, 0.627451, 1.0)
        return
    end
    if healingTarget == "raid32" then
        TargetColor.texture:SetColorTexture(0.470588, 0.454902, 0.603922, 1.0)
        return
    end
    if healingTarget == "raid33" then
        TargetColor.texture:SetColorTexture(0.384314, 0.062745, 0.266667, 1.0)
        return
    end
    if healingTarget == "raid34" then
        TargetColor.texture:SetColorTexture(0.639216, 0.168627, 0.447059, 1.0)
        return
    end    
    if healingTarget == "raid35" then
        TargetColor.texture:SetColorTexture(0.874510, 0.058824, 0.400000, 1.0)
        return
    end
    if healingTarget == "raid36" then
        TargetColor.texture:SetColorTexture(0.925490, 0.070588, 0.713725, 1.0)
        return
    end
    if healingTarget == "raid37" then
        TargetColor.texture:SetColorTexture(0.098039, 0.803922, 0.905882, 1.0)
        return
    end
    if healingTarget == "raid38" then
        TargetColor.texture:SetColorTexture(0.243137, 0.015686, 0.325490, 1.0)
        return
    end
    if healingTarget == "raid39" then
        TargetColor.texture:SetColorTexture(0.847059, 0.376471, 0.921569, 1.0)
        return
    end
    if healingTarget == "raid40" then
        TargetColor.texture:SetColorTexture(0.341176, 0.533333, 0.231373, 1.0)
        return
    end
    if healingTarget == "raidpet1" then
        TargetColor.texture:SetColorTexture(0.458824, 0.945098, 0.784314, 1.0)
        return
    end
    if healingTarget == "raidpet2" then
        TargetColor.texture:SetColorTexture(0.239216, 0.654902, 0.278431, 1.0)
        return
    end
    if healingTarget == "raidpet3" then
        TargetColor.texture:SetColorTexture(0.537255, 0.066667, 0.905882, 1.0)
        return
    end
    if healingTarget == "raidpet4" then
        TargetColor.texture:SetColorTexture(0.333333, 0.415686, 0.627451, 1.0)
        return
    end
    if healingTarget == "raidpet5" then
        TargetColor.texture:SetColorTexture(0.576471, 0.811765, 0.011765, 1.0)
        return
    end
    if healingTarget == "raidpet6" then
        TargetColor.texture:SetColorTexture(0.517647, 0.164706, 0.627451, 1.0)
        return
    end
    if healingTarget == "raidpet7" then
        TargetColor.texture:SetColorTexture(0.439216, 0.074510, 0.941176, 1.0)
        return
    end
    if healingTarget == "raidpet8" then
        TargetColor.texture:SetColorTexture(0.984314, 0.854902, 0.376471, 1.0)
        return
    end
    if healingTarget == "raidpet9" then
        TargetColor.texture:SetColorTexture(0.082353, 0.286275, 0.890196, 1.0)
        return
    end
    if healingTarget == "raidpet10" then
        TargetColor.texture:SetColorTexture(0.058824, 0.003922, 0.964706, 1.0)
        return
    end
    if healingTarget == "raidpet11" then
        TargetColor.texture:SetColorTexture(0.956863, 0.509804, 0.949020, 1.0)
        return
    end
    if healingTarget == "raidpet12" then
        TargetColor.texture:SetColorTexture(0.474510, 0.858824, 0.031373, 1.0)
        return
    end
    if healingTarget == "raidpet13" then
        TargetColor.texture:SetColorTexture(0.509804, 0.882353, 0.423529, 1.0)
        return
    end
    if healingTarget == "raidpet14" then
        TargetColor.texture:SetColorTexture(0.337255, 0.647059, 0.427451, 1.0)
        return
    end
    if healingTarget == "raidpet15" then
        TargetColor.texture:SetColorTexture(0.611765, 0.525490, 0.352941, 1.0)
        return
    end
    if healingTarget == "raidpet16" then
        TargetColor.texture:SetColorTexture(0.921569, 0.129412, 0.913725, 1.0)
        return
    end
    if healingTarget == "raidpet17" then
        TargetColor.texture:SetColorTexture(0.117647, 0.933333, 0.862745, 1.0)
        return
    end
    if healingTarget == "raidpet18" then
        TargetColor.texture:SetColorTexture(0.733333, 0.015686, 0.937255, 1.0)
        return
    end
    if healingTarget == "raidpet19" then
        TargetColor.texture:SetColorTexture(0.819608, 0.392157, 0.686275, 1.0)
        return
    end
    if healingTarget == "raidpet20" then
        TargetColor.texture:SetColorTexture(0.823529, 0.976471, 0.541176, 1.0)
        return
    end
    if healingTarget == "raidpet21" then
        TargetColor.texture:SetColorTexture(0.043137, 0.305882, 0.800000, 1.0)
        return
    end
    if healingTarget == "raidpet22" then
        TargetColor.texture:SetColorTexture(0.737255, 0.270588, 0.760784, 1.0)
        return
    end
    if healingTarget == "raidpet23" then
        TargetColor.texture:SetColorTexture(0.807843, 0.368627, 0.058824, 1.0)
        return
    end
    if healingTarget == "raidpet24" then
        TargetColor.texture:SetColorTexture(0.364706, 0.078431, 0.078431, 1.0)
        return
    end
    if healingTarget == "raidpet25" then
        TargetColor.texture:SetColorTexture(0.094118, 0.901961, 1.000000, 1.0)
        return
    end
    if healingTarget == "raidpet26" then
        TargetColor.texture:SetColorTexture(0.772549, 0.690196, 0.047059, 1.0)
        return
    end
    if healingTarget == "raidpet27" then
        TargetColor.texture:SetColorTexture(0.415686, 0.784314, 0.854902, 1.0)
        return
    end
    if healingTarget == "raidpet28" then
        TargetColor.texture:SetColorTexture(0.470588, 0.733333, 0.047059, 1.0)
        return
    end
    if healingTarget == "raidpet29" then
        TargetColor.texture:SetColorTexture(0.619608, 0.086275, 0.572549, 1.0)
        return
    end
    if healingTarget == "raidpet30" then
        TargetColor.texture:SetColorTexture(0.517647, 0.352941, 0.678431, 1.0)
        return
    end
    if healingTarget == "raidpet31" then
        TargetColor.texture:SetColorTexture(0.003922, 0.149020, 0.694118, 1.0)
        return
    end
    if healingTarget == "raidpet32" then
        TargetColor.texture:SetColorTexture(0.454902, 0.619608, 0.831373, 1.0)
        return
    end
    if healingTarget == "raidpet33" then
        TargetColor.texture:SetColorTexture(0.674510, 0.741176, 0.050980, 1.0)
        return
    end
    if healingTarget == "raidpet34" then
        TargetColor.texture:SetColorTexture(0.560784, 0.713725, 0.784314, 1.0)
        return
    end
    if healingTarget == "raidpet35" then
        TargetColor.texture:SetColorTexture(0.400000, 0.721569, 0.737255, 1.0)
        return
    end
    if healingTarget == "raidpet36" then
        TargetColor.texture:SetColorTexture(0.094118, 0.274510, 0.392157, 1.0)
        return
    end
    if healingTarget == "raidpet37" then
        TargetColor.texture:SetColorTexture(0.298039, 0.498039, 0.462745, 1.0)
        return
    end
    if healingTarget == "raidpet38" then
        TargetColor.texture:SetColorTexture(0.125490, 0.196078, 0.027451, 1.0)
        return
    end
    if healingTarget == "raidpet39" then
        TargetColor.texture:SetColorTexture(0.937255, 0.564706, 0.368627, 1.0)
        return
    end
    if healingTarget == "raidpet40" then
        TargetColor.texture:SetColorTexture(0.929412, 0.592157, 0.501961, 1.0)
        return
    end
    
    --Stuff
    if healingTarget == "player" then
        TargetColor.texture:SetColorTexture(0.788235, 0.470588, 0.858824, 1.0)
        return
    end
    if healingTarget == "focus" then
        TargetColor.texture:SetColorTexture(0.615686, 0.227451, 0.988235, 1.0)
        return
    end
    --[[
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.411765, 0.760784, 0.176471, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.780392, 0.286275, 0.415686, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.584314, 0.811765, 0.956863, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.513725, 0.658824, 0.650980, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.913725, 0.180392, 0.737255, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.576471, 0.250980, 0.160784, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.803922, 0.741176, 0.874510, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.647059, 0.874510, 0.713725, 1.0)
        return
    end   
    if healingTarget == PLACEHOLDER then --was party5
        TargetColor.texture:SetColorTexture(0.007843, 0.301961, 0.388235, 1.0)
        return
    end     
    if healingTarget == PLACEHOLDER then --was party5pet
        TargetColor.texture:SetColorTexture(0.572549, 0.705882, 0.984314, 1.0)
        return
    end
    ]]
end

-----------------------
--- OLD RUBIM PART ----
-----------------------

--healingTarget = "None"
--healingTargetGUID = "None"

function ForceHealingTarget(TARGET)
    local target = TARGET or nil
    healingTarget = "None"
    healingTargetGUID = "None"
    --showHealingColor(healingTarget)
	setColorTarget(true)

    if TARGET == "TANK" then
        healingTarget = RubimRH.HealingEngine.Members.TANK[1].Unit
        healingTargetGUID = RubimRH.HealingEngine.Members.TANK[1].GUID
        --showHealingColor(healingTarget)
		setColorTarget(true)
        return
    end

    if TARGET == "DPS" and RubimRH.HealingEngine.Members.DAMAGER[1].HP < hp then
        healingTarget = RubimRH.HealingEngine.Members.DAMAGER[1].Unit
        healingTargetGUID = RubimRH.HealingEngine.Members.DAMAGER[1].GUID
        --showHealingColor(healingTarget)
		setColorTarget(true)
        return
    end

    if TARGET == "HEAL" and RubimRH.HealingEngine.Members.HEALER[1].HP < hp then
        healingTarget = RubimRH.HealingEngine.Members.HEALER[1].Unit
        healingTargetGUID = RubimRH.HealingEngine.Members.HEALER[1].GUID
        --showHealingColor(healingTarget)
		setColorTarget(true)
        return
    end

    if TARGET == "ALL" and RubimRH.HealingEngine.Members.ALL[1].HP < 99 then
        healingTarget = RubimRH.HealingEngine.Members.ALL[1].Unit
        healingTargetGUID = RubimRH.HealingEngine.Members.ALL[1].GUID
        --showHealingColor(healingTarget)
		setColorTarget(true)
        return
    end
end

function setHealingTarget(TARGET, HP)
    local target = TARGET or nil
    local hp = HP or 99
    
    if TARGET == "TANK" and #RubimRH.HealingEngine.Members.TANK > 0 then
        healingTarget = RubimRH.HealingEngine.Members.TANK[1].Unit
        healingTargetGUID = RubimRH.HealingEngine.Members.TANK[1].GUID
        return RubimRH.HealingEngine.Members.TANK[1].HP
    end
    
    if TARGET == "DAMAGER" and #RubimRH.HealingEngine.Members.DAMAGER > 0 and RubimRH.HealingEngine.Members.DAMAGER[1].HP < hp then
        healingTarget = RubimRH.HealingEngine.Members.DAMAGER[1].Unit
        healingTargetGUID = RubimRH.HealingEngine.Members.DAMAGER[1].GUID
        return RubimRH.HealingEngine.Members.DAMAGER[1].HP
    end
    
    if TARGET == "HEALER" and #RubimRH.HealingEngine.Members.HEALER > 0 and RubimRH.HealingEngine.Members.HEALER[1].HP < hp then
        healingTarget = RubimRH.HealingEngine.Members.HEALER[1].Unit
        healingTargetGUID = RubimRH.HealingEngine.Members.HEALER[1].GUID
        return RubimRH.HealingEngine.Members.HEALER[1].HP
    end
    
    if TARGET == "RAID" then -- No Tanks
        if #RubimRH.HealingEngine.Members.DAMAGER > 0 and #RubimRH.HealingEngine.Members.HEALER > 0 and RubimRH.HealingEngine.Members.DAMAGER[1].HP <= RubimRH.HealingEngine.Members.HEALER[1].HP then 
            healingTarget = RubimRH.HealingEngine.Members.DAMAGER[1].Unit
            healingTargetGUID = RubimRH.HealingEngine.Members.DAMAGER[1].GUID
            return RubimRH.HealingEngine.Members.DAMAGER[1].HP 
        elseif #RubimRH.HealingEngine.Members.HEALER > 0 then 
            healingTarget = RubimRH.HealingEngine.Members.HEALER[1].Unit
            healingTargetGUID = RubimRH.HealingEngine.Members.HEALER[1].GUID
            return RubimRH.HealingEngine.Members.HEALER[1].HP
        end
    end
    
    if TARGET == nil and #RubimRH.HealingEngine.Members.ALL > 0 and RubimRH.HealingEngine.Members.ALL[1].HP < 99 then
        healingTarget = RubimRH.HealingEngine.Members.ALL[1].Unit
        healingTargetGUID = RubimRH.HealingEngine.Members.ALL[1].GUID
        return RubimRH.HealingEngine.Members.ALL[1].HP
    end
    healingTarget = "None"
    healingTargetGUID = "None"
end


-----------------------
----- LOS PART --------
-----------------------
local function UpdateLOS()
	if UnitExists("target") then
		if not UnitIsFriend("target", "player")) then 
			-- New profiles 			
				GetLOS(UnitGUID("target"))			 		
		elseif not UnitIsFriend("target", "mouseover") or not MouseHasFrame() then 
			-- TODO: Remove on old profiles until June 2019
			-- Old profiles 
			GetLOS(UnitGUID("target"))
		end 
	end 
end

local function HealingEngineInit()
	if Player:IsHealer() then 
		RubimRH.Listener:Add("Rubim_Events", "PLAYER_TARGET_CHANGED", 	UpdateLOS)
		RubimRH.Listener:Add("Rubim_Events", "PLAYER_REGEN_ENABLED", 	function() wipe(RubimRH.HealingEngine.Frequency.Actual) end)
		RubimRH.Listener:Add("Rubim_Events", "PLAYER_REGEN_DISABLED", 	function() wipe(RubimRH.HealingEngine.Frequency.Actual) end)
		TargetColor:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = (self.elapsed or 0) + elapsed   
			local INTV = 0.25 + RubimRH.HealingEngine.UpdatePause
			if Player:IsHealer() and self.elapsed > INTV then 
				HealingEngine("ALL") 
				setHealingTarget("ALL") 
				setColorTarget()   
				UpdateLOS() 
				self.elapsed = 0
			end			
		end)
	elseif #RubimRH.HealingEngine.Members.ALL > 0 then
		RubimRH.HealingEngine.Members:Wipe()
		RubimRH.HealingEngine.Frequency:Wipe()
		Listener:Remove("Rubim_Events", "PLAYER_TARGET_CHANGED")
		Listener:Remove("Rubim_Events", "PLAYER_REGEN_ENABLED")
		Listener:Remove("Rubim_Events", "PLAYER_REGEN_DISABLED")
		TargetColor:SetScript("OnUpdate", nil)
	end 
end 

RubimRH.Listener:Add("Rubim_Events", "PLAYER_ENTERING_WORLD", 			HealingEngineInit)
RubimRH.Listener:Add("Rubim_Events", "UPDATE_INSTANCE_INFO", 			HealingEngineInit)
RubimRH.Listener:Add("Rubim_Events", "PLAYER_SPECIALIZATION_CHANGED", 	HealingEngineInit)


--- ============================= API ==============================
--- API valid only for healer specializations  
--- Members are depend on _G.HE_Pets variable 

--- SetTarget Controller 
function RubimRH.HealingEngine.SetTargetMostlyIncDMG()
	local GUID = UnitGUID("target")
	if GUID and GUID ~= healingTargetGUID and #RubimRH.HealingEngine.Members.MOSTLYINCDMG > 0 then 
		healingTargetGUID 	= RubimRH.HealingEngine.Members.MOSTLYINCDMG[1].GUID
		healingTarget		= RubimRH.HealingEngine.Members.MOSTLYINCDMG[1].Unit
		setColorTarget(true)
		RubimRH.HealingEngine.UpdatePause = 2
	end 
end 

function RubimRH.HealingEngine.SetTarget(unitID)
	local GUID = UnitGUID(unitID)
	if GUID and GUID ~= healingTargetGUID and #RubimRH.HealingEngine.Members.ALL > 0 then 
		healingTargetGUID 	= GUID
		healingTarget		= unitID
		setColorTarget(true)
		RubimRH.HealingEngine.UpdatePause = 2
	end 
end 

--- Group Controller 
function RubimRH.HealingEngine.GetMembersAll()
	-- @return table 
	return RubimRH.HealingEngine.Members.ALL 
end 

function RubimRH.HealingEngine.GetMembersByMode()
	-- @return table 
	--TODO Implement UI option to choose healing mode
	local mode = "ALL" -- or RubimRH.mainoption.healingmode
	return RubimRH.HealingEngine.Members[mode] 
end 

function RubimRH.HealingEngine.GetBuffsCount(ID, duration, source)
	-- @return number 	
	-- Only players 
    local total = 0
	local m = RubimRH.HealingEngine.GetMembersAll()
    if #m > 0 then 
        for i = 1, #m do
            if UnitIsPlayer(m[i].Unit) and (m[i].Unit):BuffRemainsP(ID, source) > (duration or 0) then
                total = total + 1
            end
        end
    end 
    return total 
end 
RubimRH.HealingEngine.GetBuffsCount = RubimRH.MakeFunctionCachedDynamic(RubimRH.HealingEngine.GetBuffsCount)

function RubimRH.HealingEngine.GetDeBuffsCount(ID, duration)
	-- @return number 	
	-- Only players 
    local total = 0
	local m = RubimRH.HealingEngine.GetMembersAll()
    if #m > 0 then 
        for i = 1, #m do
		 
            if UnitIsPlayer(m[i].Unit) and (m[i].Unit):DebuffRemainsP(ID) > (duration or 0) then
                total = total + 1
            end
        end
    end 
    return total 
end 
RubimRH.HealingEngine.GetDeBuffsCount = RubimRH.MakeFunctionCachedDynamic(RubimRH.HealingEngine.GetDeBuffsCount)

function RubimRH.HealingEngine.GetHealth()
	-- @return number 
	-- Return actual group health 
	local f = RubimRH.HealingEngine.Frequency.Actual 
	if #f > 0 then 
		return f[#f].AHP
	end 
	return huge
end 

function RubimRH.HealingEngine.GetHealthAVG() 
	-- @return number 
	-- Return current percent (%) of the group health
	local f = RubimRH.HealingEngine.Frequency.Actual
	if #f > 0 then 
		return f[#f].AHP * 100 / f[#f].MAXHP
	end 
	return 100  
end 
RubimRH.HealingEngine.GetHealthAVG = RubimRH.MakeFunctionCachedStatic(RubimRH.HealingEngine.GetHealthAVG)

function RubimRH.HealingEngine.GetHealthFrequency(timer)
	-- @return number 
	-- Return percent (%) of the group HP changed during lasts 'timer'. Positive (+) is HP lost, Negative (-) is HP gain, 0 - nothing is not changed 
    local total, counter = 0, 0
	local f = RubimRH.HealingEngine.Frequency.Actual
    if #f > 1 then 
        for i = 1, #f - 1 do 
            -- Getting history during that time rate
            if HL.GetTime() - f[i].TIME <= timer then 
                counter = counter + 1
                total 	= total + f[i].AHP
            end 
        end        
    end 
	
	if total > 0 then           
		total = (f[#f].AHP * 100 / f[#f].MAXHP) - (total / counter * 100 / f[#f].MAXHP)
	end  	
	
    return total 
end 
RubimRH.HealingEngine.GetHealthFrequency = RubimRH.MakeFunctionCachedDynamic(RubimRH.HealingEngine.GetHealthFrequency)

function RubimRH.HealingEngine.GetIncomingDMG()
	-- @return number, number 
	-- Return REALTIME actual: total - group HP lose per second, avg - average unit HP lose per second
	local total, avg = 0, 0
	local m = RubimRH.HealingEngine.GetMembersAll()
    if #m > 0 then 
        for i = 1, #m do
            total = total + m[i].incDMG
        end
		
		avg = total / #m
    end 
    return total, avg 
end 
RubimRH.HealingEngine.GetIncomingDMG = RubimRH.MakeFunctionCachedStatic(RubimRH.HealingEngine.GetIncomingDMG)

function RubimRH.HealingEngine.GetIncomingHPS()
	-- @return number , number
	-- Return PERSISTENT actual: total - group HP gain per second, avg - average unit HP gain per second 
	local total, avg = 0, 0
	local m = RubimRH.HealingEngine.GetMembersAll()
    if #m > 0 then 
        for i = 1, #m do
            total = total + getHEAL(m[i].Unit)
        end
		
		avg = total / #m
    end 
    return total, avg 
end 
RubimRH.HealingEngine.GetIncomingHPS = RubimRH.MakeFunctionCachedStatic(RubimRH.HealingEngine.GetIncomingHPS)

function RubimRH.HealingEngine.GetIncomingDMGAVG()
	-- @return number  
	-- Return REALTIME average percent group HP lose per second 
	local avg = 0
	local f = RubimRH.HealingEngine.Frequency.Actual
    if #f > 0 then 
		avg = RubimRH.HealingEngine.GetIncomingDMG() * 100 / f[#f].MAXHP
    end 
    return avg 
end
RubimRH.HealingEngine.GetIncomingDMGAVG = RubimRH.MakeFunctionCachedStatic(RubimRH.HealingEngine.GetIncomingDMGAVG)

function RubimRH.HealingEngine.GetIncomingHPSAVG()
	-- @return number  
	-- Return REALTIME average percent group HP gain per second 
	local avg = 0
	local f = RubimRH.HealingEngine.Frequency.Actual
    if #f > 0 then 
		avg = RubimRH.HealingEngine.GetIncomingHPS() * 100 / f[#f].MAXHP
    end 
    return avg 
end 
RubimRH.HealingEngine.GetIncomingHPSAVG = RubimRH.MakeFunctionCachedStatic(RubimRH.HealingEngine.GetIncomingHPSAVG)

function RubimRH.HealingEngine.GetTimeToDieUnits(timer)
	-- @return number 
	local total = 0
	local m = RubimRH.HealingEngine.GetMembersAll()
    if #m > 0 then 
        for i = 1, #m do
            if RubimRH.TimeToDie(m[i].Unit) <= timer then
                total = total + 1
            end
        end
    end 
    return total 
end 

function RubimRH.HealingEngine.GetTimeToDieMagicUnits(timer)
	-- @return number 
	local total = 0
	local m = RubimRH.HealingEngine.GetMembersAll()
    if #m > 0 then 
        for i = 1, #m do
            if TimeToDieMagic(m[i].Unit) <= timer then
                total = total + 1
            end
        end
    end 
    return total 
end 

function RubimRH.HealingEngine.GetTimeToFullHealth()
	-- @return number
	local f = RubimRH.HealingEngine.Frequency.Actual
	if #f > 0 then 
		local HPS = RubimRH.HealingEngine.GetIncomingHPS()
		if HPS > 0 then
			return (f[#f].MAXHP - f[#f].AHP) / HPS
		end 
	end 
	return 0 
end 

function RubimRH.HealingEngine.GetMinimumUnits(fullPartyMinus, raidLimit)
	-- @return number 
	-- This is easy template to known how many people minimum required be to heal by AoE with different group size or if some units out of range or in cyclone and etc..
	-- More easy to figure - which minimum units require if available group members <= 1 / <= 3 / <= 5 or > 5
	local m = RubimRH.HealingEngine.GetMembersAll()
	local members = #m
	return 	( members <= 1 and 1 ) or 
			( members <= 3 and members ) or 
			( members <= 5 and members - (fullPartyMinus or 0) ) or 
			(
				members > 5 and 
				(
					(
						raidLimit ~= nil and
						(
							(
								members >= raidLimit and 
								raidLimit
							) or 
							(
								members < raidLimit and 
								members
							)
						)
					) or 
					(
						raidLimit == nil and 
						members
					)
				)
			)
end 

function RubimRH.HealingEngine.GetBelowHealthPercentUnits(pHP, range)
	local total = 0 
	local m = RubimRH.HealingEngine.GetMembersAll()
    if #m > 0 then 
        for i = 1, #m do
            if (not range or RubimRH.SpellInteract(m[i].Unit, range)) and m[i].HP <= pHP then
                total = total + 1
            end
        end
    end 
	return total 
end 

function RubimRH.HealingEngine.HealingByRange(range, predictName, spellID, isMelee)
	-- @return number 
	-- Return how much members can be healed by specified range with spell
	local total = 0
	local m = RubimRH.HealingEngine.GetMembersAll()
	if #m > 0 then 		
		for i = 1, #m do 
			if (not (m[i].Unit):IsMelee() or Unit(m[i].Unit, RubimRH.HealingEngine.Refresh):IsMelee()) and 
				RubimRH.SpellInteract(m[i].Unit, range) and
				(
					-- Old profiles 
					-- TODO: Remove after rewrite old profiles 
					(RubimRH.PredictHeal(predictName, m[i].Unit)) or 
					-- New profiles 
					(RubimRH.PredictHeal(predictName, spellID, m[i].Unit))
				)
			then
                total = total + 1
            end
		end 		
	end 
	return total 
end 

function RubimRH.HealingEngine.HealingBySpell(predictName, spellID, isMelee)
	-- @return number 
	-- Return how much members can be healed by specified spell 
	local total = 0
	local m = RubimRH.HealingEngine.GetMembersAll()
	if #m > 0 then 		
		for i = 1, #m do 
			if (not (m[i].Unit):IsMelee() or Unit(m[i].Unit, RubimRH.HealingEngine.Refresh):IsMelee()) and 
				RubimRH.SpellInRange(m[i].Unit, spellID) and
				(
					-- Old profiles 
					-- TODO: Remove after rewrite old profiles 
					(and RubimRH.PredictHeal(predictName, m[i].Unit)) or 
					-- New profiles 
					(RubimRH.PredictHeal(predictName, spellID, m[i].Unit))
				)
			then
                total = total + 1
            end
		end 		
	end 
	return total 
end 

--- Unit Controller 
function RubimRH.HealingEngine.IsMostlyIncDMG(unitID)
	-- @return boolean, number (realtime incoming damage)	
	if #RubimRH.HealingEngine.Members.MOSTLYINCDMG > 0 then 
		return UnitIsUnit(unitID, RubimRH.HealingEngine.Members.MOSTLYINCDMG[1].Unit), RubimRH.HealingEngine.Members.MOSTLYINCDMG[1].incDMG
	end 
	return false, 0
end 

function RubimRH.HealingEngine.GetTarget()
	return healingTarget, healingTargetGUID
end 

--- =========================== OLD API ============================
-- TODO: Remove since we have now Action
local tableexist = tableexist
local UnitIsPlayer = UnitIsPlayer
function GetMembers()
    return RubimRH.HealingEngine.GetMembersAll()
end 
function MostlyIncDMG(unitID)
    return RubimRH.HealingEngine.IsMostlyIncDMG(unitID)
end 
function Group_incDMG()
    return select(2, RubimRH.HealingEngine.GetIncomingDMG())
end
function Group_getHEAL()
    return select(2, RubimRH.HealingEngine.GetIncomingHPS())
end
function FrequencyAHP(timer)    
    return RubimRH.HealingEngine.GetHealthFrequency(timer)
end 
function AoETTD(timer)
    return RubimRH.HealingEngine.GetTimeToDieUnits(timer)   
end
function AoEBuffsExist(ID, duration)
	return RubimRH.HealingEngine.GetBuffsCount(ID, duration)
end
function AoEHP(pHP)
    return RubimRH.HealingEngine.GetBelowHealthPercentUnits(pHP) 
end
function AoEHealingByRange(range, predictName, isMelee)
	return RubimRH.HealingEngine.HealingByRange(range, predictName, nil, isMelee)
end
function AoEHealingBySpell(spell, predictName, isMelee) 
	return RubimRH.HealingEngine.HealingBySpell(predictName, spell, isMelee)
end
-- Deprecated
function ValidMembers(IsPlayer)
	if not IsPlayer or not _G.HE_Pets then 
		return #RubimRH.HealingEngine.Members.ALL
	else 
		local total = 0 
		local f = RubimRH.HealingEngine.GetMembersAll()
		if #f > 0 then 
			for i = 1, #f do
				if UnitIsPlayer(f[i].Unit) then
					total = total + 1
				end
			end 
		end 
		return total 
	end 
end
function AoEMembers(IsPlayer, SubStract, Limit)
    if not SubStract then SubStract = 1 end 
    if not Limit then Limit = 4 end
    local ValidUnits = ValidMembers(IsPlayer)
    return 
    ( ValidUnits <= 1 and 1 ) or    
    ( ValidUnits <= 3 and 2 ) or 
    ( ValidUnits <= 5 and ValidUnits - SubStract ) or 
    ( 
        ValidUnits > 5 and 
        (
            (
                Limit <= ValidUnits and 
                Limit 
            ) or 
            (
                Limit > ValidUnits and 
                ValidUnits
            )
        )
    )
end
function AoEHPAvg(isPlayer, minCount)
    local total, maxhp, counter = 0, 0, 0
	local members = RubimRH.HealingEngine.GetMembersAll()
    if tableexist(members) then 
        for i = 1, #members do
            if (not isPlayer or UnitIsPlayer(members[i].Unit)) then                
                total = total + UnitHealth(members[i].Unit)
                maxhp = maxhp + UnitHealthMax(members[i].Unit)
                counter = counter + 1
            end
        end
        if total > 0 and (not minCount or counter >= minCount) then 
            total = total * 100 / maxhp
        end 
    end
    return total  
end

-- Restor Druid 
function RubimRH.AoEFlourish(pHP)   
	local members = RubimRH.HealingEngine.GetMembersAll()
    if tableexist(members) then 
        local total = 0
        for i = 1, #members do
            if UNITHP(members[i].Unit) <= pHP and
            -- Rejuvenation
            Unit(members[i].Unit):BuffRemainsP(774) > 0 and 
            (
                -- Wild Growth
                Unit(members[i].Unit):BuffRemainsP(48438) > 0 or 
                -- Lifebloom  
                Unit(members[i].Unit):BuffRemainsP(33763) > 0 or 
				-- or Regrowth
				Unit(members[i].Unit):BuffRemainsP(8936) > 0 or 
				-- or Germination
				Unit(members[i].Unit):BuffRemainsP(155777) > 0  
            )
            then
                total = total + 1
            end
        end
        return total >= #members * 0.3
    end 
    return false
end

-- PVE Dispels
local types = {
    Poison = {
        -- Venomfang Strike
        { id = 252687, dur = 0, stack = 0},
        -- Hidden Blade
        { id = 270865, dur = 0, stack = 0},
        -- Embalming Fluid 
        { id = 271563, dur = 0, stack = 3},
        -- Poison Barrage 
        { id = 270507, dur = 0, stack = 0},
        -- Stinging Venom Coating
        { id = 275835, dur = 0, stack = 4},
        -- Neurotoxin 
        { id = 273563, dur = 1.49, stack = 0},
        -- Cytotoxin 
        { id = 267027, dur = 0, stack = 2},
        -- Venomous Spit
        { id = 272699, dur = 0, stack = 0},
        -- Widowmaker Toxin
        { id = 269298, dur = 0, stack = 2}, 
        -- Stinging Venom
        { id = 275836, dur = 0, stack = 5},        
    },
    Disease = {
        -- Infected Wound
        { id = 258323, dur = 0, stack = 1},
        -- Plague Step
        { id = 257775, dur = 0, stack = 0},
        -- Wretched Discharge
        { id = 267763, dur = 0, stack = 0},
        -- Plague 
        { id = 269686, dur = 0, stack = 0},
        -- Festering Bite
        { id = 263074, dur = 0, stack = 0},
        -- Decaying Mind
        { id = 278961, dur = 0, stack = 0},
        -- Decaying Spores
        { id = 259714, dur = 0, stack = 1},
        -- Festering Bite
        { id = 263074, dur = 0, stack = 0},
    }, 
    Curse = {
        -- Wracking Pain
        { id = 250096, dur = 0, stack = 0},
        -- Pit of Despair
        { id = 276031, dur = 0, stack = 0},
        -- Hex 
        { id = 270492, dur = 0, stack = 0},
        -- Cursed Slash
        { id = 257168, dur = 0, stack = 2},
        -- Withering Curse
        { id = 252687, dur = 0, stack = 2},
    },
    Magic = {
        -- Molten Gold
        { id = 255582, dur = 0, stack = 0},
        -- Terrifying Screech
        { id = 255041, dur = 0, stack = 0},
        -- Terrifying Visage
        { id = 255371, dur = 0, stack = 0},
        -- Oiled Blade
        { id = 257908, dur = 0, stack = 0},
        -- Choking Brine
        { id = 264560, dur = 0, stack = 0},
        -- Electrifying Shock
        { id = 268233, dur = 0, stack = 0},
        -- Touch of the Drowned (if no party member is afflicted by Mental Assault (268391))
        { id = 268322, dur = 0, stack = 0},
        -- Mental Assault 
        { id = 268391, dur = 0, stack = 0},
        -- Explosive Void
        { id = 269104, dur = 0, stack = 0},
        -- Choking Waters
        { id = 272571, dur = 0, stack = 0},
        -- Putrid Waters
        { id = 274991, dur = 0, stack = 0},
        -- Flame Shock (if no party member is afflicted by Snake Charm (268008)))
        { id = 268013, dur = 0, stack = 0},
        -- Snake Charm
        { id = 268008, dur = 0, stack = 0},
        -- Brain Freeze
        { id = 280605, dur = 1.49, stack = 0},
        -- Transmute: Enemy to Goo
        { id = 268797, dur = 0, stack = 0},
        -- Chemical Burn
        { id = 259856, dur = 0, stack = 0},
        -- Debilitating Shout
        { id = 258128, dur = 0, stack = 0},
        -- Torch Strike 
        { id = 265889, dur = 0, stack = 1},
        -- Fuselighter 
        { id = 257028, dur = 0, stack = 0},
        -- Death Bolt 
        { id = 272180, dur = 0, stack = 0},
        -- Putrid Blood
        { id = 269301, dur = 0, stack = 2},
        -- Grasping Thorns
        { id = 263891, dur = 0, stack = 0},
        -- Fragment Soul
        { id = 264378, dur = 0, stack = 0},
        -- Reap Soul
        { id = 288388, dur = 0, stack = 20},
        -- Putrid Waters
        { id = 275014, dur = 0, stack = 0},
    }, 
}
local UnitAuras = {
    -- Restor Druid 
    [105] = {
        types.Poison,
        types.Curse,
        types.Magic,
    },
    -- Balance
    [102] = {
        types.Curse,
    },
    -- Feral
    [103] = {
        types.Curse,
    },
    -- Guardian
    [104] = {
        types.Curse,
    },
    -- Arcane
    [62] = {
        types.Curse,
    },
    -- Fire
    [63] = {
        types.Curse,
    },
    -- Frost
    [64] = {
        types.Curse,
    },
    -- Mistweaver
    [270] = {
        types.Poison,
        types.Disease,
        types.Magic,
    },
    -- Windwalker
    [269] = {
        types.Poison,
        types.Disease,
    },
    -- Brewmaster
    [268] = {
        types.Poison,
        types.Disease,
    },
    -- Holy Paladin
    [65] = {
        types.Poison,
        types.Disease,
        types.Magic,
    },
    -- Protection Paladin
    [66] = {
        types.Poison,
        types.Disease,
    },
    -- Retirbution Paladin
    [70] = {
        types.Poison,
        types.Disease,
    },
    -- Discipline Priest 
    [256] = {
        types.Disease,
        types.Magic,
    }, 
    -- Holy Priest 
    [257] = {
        types.Disease,
        types.Magic,
    }, 
    -- Shadow Priest 
    [258] = {
        types.Disease,
    },
    -- Elemental
    [262] = {
        types.Curse,
    },
    -- Enhancement
    [263] = {
        types.Curse,
    },
    -- Restoration
    [264] = {
        types.Curse,
        types.Magic,
    },
    -- Affliction
    [265] = {
        types.Magic,
    },
    -- Demonology
    [266] = {
        types.Magic,
    },
    -- Destruction
    [267] = {
        types.Magic,
    },
}
function RubimRH.PvEDispel(unit)
    if not RubimRH.InPvP() and UnitAuras[RubimRH.PlayerSpec] then 
        for k, v in pairs(UnitAuras[RubimRH.PlayerSpec]) do 
            for _, Spell in pairs(v) do 
                duration = (Spell.dur == 0 and Player:GCD() + RubimRH.CurrentTimeGCD()) or Spell.dur
                -- Exception 
                -- Touch of the Drowned (268322, if no party member is afflicted by Mental Assault (268391))
                -- Flame Shock (268013, if no party member is afflicted by Snake Charm (268008))
                -- Putrid Waters (275014, don't dispel self)
                if Spell.stack == 0 then 
                    if Unit(unit):DebuffRemainsP(Spell.id) > duration then 
                        if (Spell.id ~= 268322 or not RubimRH.FriendlyTeam():GetDeBuffs(268391)) and 
                        (Spell.id ~= 268013 or not RubimRH.FriendlyTeam():GetDeBuffs(268008)) and 
                        (Spell.id ~= 275014 or not UnitIsUnit("player", unit)) then 
                            return true 
                        end
                    end 
                else
                    if Unit(unit):DebuffRemainsP(Spell.id) > duration and RubimRH.DeBuffStack(unit, Spell.id, nil, true) > Spell.stack then 
                        if (Spell.id ~= 268322 or not RubimRH.FriendlyTeam():GetDeBuffs(268391)) and 
                        (Spell.id ~= 268013 or not RubimRH.FriendlyTeam():GetDeBuffs(268008)) and 
                        (Spell.id ~= 275014 or not UnitIsUnit("player", unit)) then 
                            return true 
                        end
                    end 
                end                 
            end 
        end 
    end 
    return false 
end 

