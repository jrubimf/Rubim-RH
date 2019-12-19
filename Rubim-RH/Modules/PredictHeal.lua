local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
local Focus, MouseOver = Unit.Focus, Unit.MouseOver;
local Arena, Boss, Nameplate = Unit.Arena, Unit.Boss, Unit.Nameplate;
local Party, Raid = Unit.Party, Unit.Raid;
local UnitClass, UnitRace, UnitAura, UnitCastingInfo, UnitChannelInfo, UnitName, UnitIsDeadOrGhost, UnitIsFeignDeath, UnitHealth, UnitHealthMax, UnitExists,
UnitGroupRolesAssigned, UnitEffectiveLevel, UnitIsQuestBoss, UnitLevel, UnitCanAttack, UnitIsEnemy, UnitIsUnit, UnitDetailedThreatSituation, GetUnitSpeed, UnitIsPlayer,
UnitPower, UnitPowerMax = 
UnitClass, UnitRace, UnitAura, UnitCastingInfo, UnitChannelInfo, UnitName, UnitIsDeadOrGhost, UnitIsFeignDeath, UnitHealth, UnitHealthMax, UnitExists,
UnitGroupRolesAssigned, UnitEffectiveLevel, UnitIsQuestBoss, UnitLevel, UnitCanAttack, UnitIsEnemy, UnitIsUnit, UnitDetailedThreatSituation, GetUnitSpeed, UnitIsPlayer,
UnitPower, UnitPowerMax 
--- 11.05.2019
-- Stuff
-- Buffs TMW
function RubimRH.Buffs(unitID, spell, source, byID)
    local dur, duration
    local filter = "HELPFUL" .. (source and " PLAYER" or "")
    
    if type(spell) == "table" then         
        for i = 1, #spell do            
            dur, duration = RubimRH.AuraDur(unitID, not byID and strlowerCache[GetSpellInfo(spell[i])] or spell[i], filter)                       
            if dur > 0 then
                break
            end
        end
    else
        dur, duration = RubimRH.AuraDur(unitID, not byID and strlowerCache[GetSpellInfo(spell)] or spell, filter)
    end   
    
    return dur, duration
end

--- Prediction Healing
--- ============================= CORE ==============================
function RubimRH.PredictHeal(SPELLID, UNIT, VARIATION)   
    -- Exception penalty for low level units / friendly boss
    --local UnitLvL = RubimRH.UNITLevel(UNIT)
    --if UnitLvL > 0 and UnitLvL < RubimRH.UNITLevel("player") - 10 then
    --    return true, 0
    --end         
    
    -- Header
    local variation = (VARIATION and (VARIATION / 100)) or 1    
    
    local total = 0
    local DMG, HPS = RubimRH.incdmg(UNIT), RubimRH.getHEAL(UNIT)      
    local DifficultHP = UnitHealthMax(UNIT) - UnitHealth(UNIT)  
    
    -- Spells
    if SPELLID == "Frenzied Regeneration" then
        local pre_heal = UnitGetIncomingHeals(UNIT) or 0
        local multifier = 1
        if RubimRH.UNITSpec("player", 104) and RubimRH.Buffs("player", 213680, "player") > 0 then
            multifier = 1.2
        end
        total = (UnitHealthMax("player")*0.24) * multifier + (HPS*3) + pre_heal - (DMG*3)
    end
    
    if SPELLID == "Swiftmend" then
        total = RubimRH.GetDescription(18562)[1] * variation
    end
    
    if SPELLID == "Rejuvenation" then       
        if CombatTime("player") == 0 then
            total = 0
        else
            local pre_heal = UnitGetIncomingHeals(UNIT) or 0
            local hot = 1
            if RubimRH.UNITSpec("player", 105) and -- Restor
            -- Talent Soul of Forest
            RubimRH.Buffs("player", 114108, "player") > 0 then               
                hot = 2
            end
            total = RubimRH.GetDescription(774)[1] * variation * hot + (HPS*15) + pre_heal -- - (DMG*15)
        end
    end    
    
    if SPELLID == "Regrowth" then
	    --local Regrowth = 8936
        if CombatTime("player") == 0 then
            total = 0
        else
            local pre_heal = UnitGetIncomingHeals(UNIT) or 0
            local Regrowth = RubimRH.GetDescription(8936)
            local crit, hot = 1, 1
            if 
            RubimRH.UNITSpec("player", 102) and -- Balance
            --RubimRH.InPvP() and 
            -- Protector of the Grove
            --RubimRH.PvPTalentLearn(209730) and
            not UnitIsUnit("player", UNIT) then
                crit = 2
            end
            if RubimRH.UNITSpec("player", 105) and -- Restor
            -- Talent Soul of Forest
            RubimRH.Buffs("player", 114108, "player") > 0 then
                crit = 2
                hot = 2
            end
            
            total = (Regrowth[1] * variation * crit) + (Regrowth[2] * variation * hot) + pre_heal -- + (HPS*12) - (DMG*12)
        end
    end
    
    if SPELLID == "Lunar Beam" then
        if CombatTime("player") == 0 then
            total = 0
        else
            local pre_heal = UnitGetIncomingHeals(UNIT) or 0
            total = RubimRH.GetDescription(204066)[1] * variation + (HPS*8) + pre_heal - (DMG*8)
        end
    end
    
    if SPELLID == "Wild Growth" then
	    --local WildGrowth = 48438
        if CombatTime("player") == 0 then
            total = 0
        else
            local pre_heal = UnitGetIncomingHeals(UNIT) or 0
            local WildGrowth = RubimRH.GetDescription(48438)
            local hot = 1        
            if RubimRH.UNITSpec("player", 105) and -- Restor
            -- Talent Soul of Forest
            RubimRH.Buffs("player", 114108, "player") > 0 then
                hot = 1.75
            end
            
            total = WildGrowth[1] * variation * hot + pre_heal + (HPS*7) -- - (DMG*7)
        end
    end
    
    if SPELLID == "Lifebloom" then 
        if CombatTime("player") == 0 then
            total = 0
        else
            local pre_heal = UnitGetIncomingHeals(UNIT) or 0
            total = RubimRH.GetDescription(33763)[1] * variation + pre_heal + (HPS*15) -- - (DMG*15)
        end
    end
    
    if SPELLID == "Cenarion Ward" then 
        if (CombatTime("player") == 0 or RubimRH.getRealTimeDMG(UNIT) == 0) and
        select(2, IsInInstance()) == "arena" then -- exception, for arena always pre buff
            total = 88888888888888
        else
            local pre_heal = UnitGetIncomingHeals(UNIT) or 0
            if CombatTime("player") == 0 then
                total = 0
            else
                total = RubimRH.GetDescription(102351)[1] * variation + (HPS*8) + pre_heal -- - (DMG*8)
            end
            
        end
    end
    
    if SPELLID == "Tranquility" then 
        if CombatTime("player") == 0 then
            total = 88888888888888 -- don't use out of combat
        else
            local pre_heal = UnitGetIncomingHeals(UNIT) or 0
            local raid_hot = 1
            if Player:IsInRaid() then
                raid_hot = 2
            end
            total = RubimRH.GetDescription(740)[1] + (RubimRH.GetDescription(740)[2] * 5 * raid_hot) + pre_heal + (HPS*15.1) - (DMG*15.1)
        end
    end    
    
    if SPELLID == "Efflorescence" then 
        local pre_heal = UnitGetIncomingHeals(UNIT) or 0
        local flowers = 0
		--local Efflorescence = 207385
        --if Efflorescence:IsAvailable() then
        --    flowers = RubimRH.GetDescription(207385)[1] * variation
        --end
        total = RubimRH.GetDescription(145205)[1] / 1.8 * 30 + flowers + pre_heal -- + (HPS*30) - (DMG*30)
    end    
    
    if SPELLID == "Overgrowth" then 
        if CombatTime("player") == 0 then
            total = 88888888888888 -- don't use out of combat
        else
            -- REFRESH ABLE: Wild growth and Lifebloom
            if UNIT:DebuffRefreshableCP(48438) and UNIT:DebuffRefreshableCP(33763) then 
                local SoulOfForest = RubimRH.Buffs("player", 114108, "player") > 0
                local pre_heal = UnitGetIncomingHeals(UNIT) or 0
                -- LifeBloom 15sec
                local LB = RubimRH.GetDescription(33763)[1]
                total = RubimRH.GetDescription(33763)[1]
                -- Wild Growth 7 sec
                local WG = RubimRH.GetDescription(48438)[1]                  
                if SoulOfForest then                    
                    WG = WG * 1.75
                end
                -- Regrowth (hot) 12 sec
                local RG = RubimRH.GetDescription(8936)[2]                
                if SoulOfForest then
                    RG = RG * 2
                end
                -- Rejuvenation 15 sec
                local RN = RubimRH.GetDescription(774)[1]
                if SoulOfForest then
                    RN = RN * 2
                end
                -- Average heal dur: (15 + 15 + 12 + 7) / 4 = 12.25
                total = pre_heal + RG + WG + LB + RN + (HPS*12.25) - (DMG*12.25)
            else 
                total = 88888888888888 -- skip
            end
        end
    end
    
    -- 8.1 PvP
    if SPELLID == "Nourish" then
        if CombatTime("player") == 0 then
            total = 0
        else
            local pre_heal = UnitGetIncomingHeals(UNIT) or 0
            local Nourish = RubimRH.GetDescription(289022) * variation
            local cast = RubimRH.CastTime(289022) + RubimRH.CurrentTimeGCD() + 0.2
            local crit = 1
            if TimeToDie(UNIT) <= cast * 2.6 then
                total = 88888888888888 -- don't heal if we can lose unit
            else
                if 
                -- Rejuvenation
                RubimRH.Buffs(UNIT, 774, "player") >= cast and 
                -- Germination
                (
                    not RubimRH.TalentLearn(155675) or 
                    RubimRH.Buffs(UNIT, 155777, "player") >= cast
                ) and
                -- Lifebloom
                RubimRH.Buffs(UNIT, 33763, "player") > cast and
                -- Wild Growth
                RubimRH.Buffs(UNIT, 48438, "player") > cast and
                -- Regrowth
                RubimRH.Buffs(UNIT, 8936, "player") > cast
                then
                    crit = 2
                end
                
                total = (Nourish[1] * crit) + (HPS*cast) + pre_heal - (DMG*cast)
            end
        end
    end    
    
    return DifficultHP >= total, total
end