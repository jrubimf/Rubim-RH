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

--- 11.05.2019
--- Prediction Healing
--- ============================= CORE ==============================
function RubimRH.PredictHeal(SPELLID, UNIT, VARIATION)   
    -- Exception penalty for low level units / friendly boss
    local UnitLvL = RubimRH.UNITLevel(UNIT)
    if UnitLvL > 0 and UnitLvL < RubimRH.UNITLevel("player") - 10 then
        return true, 0
    end         
    
    -- Header
    local variation = (VARIATION and (VARIATION / 100)) or 1    
    
    local total = 0
    local DMG, HPS = RubimRH.incdmg(UNIT), getHEAL(UNIT)      
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
        if CombatTime("player") == 0 and RubimRH.PvP.Unit(UNIT):HasBuffs(8936, "player") <= RubimRH.CastTime(8936) then
            total = 0
        else
            local pre_heal = UnitGetIncomingHeals(UNIT) or 0
            local Regrowth = RubimRH.GetDescription(8936)
            local crit, hot = 1, 1
            if 
            RubimRH.UNITSpec("player", 102) and -- Balance
            RubimRH.InPvP() and 
            -- Protector of the Grove
            RubimRH.PvPTalentLearn(209730) and
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
        if CombatTime("player") == 0 and RubimRH.PvP.Unit(UNIT):HasBuffs(48438, "player") <= RubimRH.CastTime(48438) then
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
        if (CombatTime("player") == 0 or getRealTimeDMG(UNIT) == 0) and
        RubimRH.Zone ~= "arena" then -- exception, for arena always pre buff
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
            if RubimRH.Zone ~= "raid" then
                raid_hot = 2
            end
            total = RubimRH.GetDescription(740)[1] + (RubimRH.GetDescription(740)[2] * 5 * raid_hot) + pre_heal + (HPS*15.1) - (DMG*15.1)
        end
    end    
    
    if SPELLID == "Efflorescence" then 
        local pre_heal = UnitGetIncomingHeals(UNIT) or 0
        local flowers = 0
        if RubimRH.TalentLearn(207385) then
            flowers = RubimRH.GetDescription(207385)[1] * variation
        end
        total = RubimRH.GetDescription(145205)[1] / 1.8 * 30 + flowers + pre_heal -- + (HPS*30) - (DMG*30)
    end    
    
    if SPELLID == "Overgrowth" then 
        if CombatTime("player") == 0 then
            total = 88888888888888 -- don't use out of combat
        else
            -- REFRESH ABLE: Wild growth and Lifebloom
            if RubimRH.PT(UNIT, 48438) and RubimRH.PT(UNIT, 33763) then 
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

-- Prediction Heal Rubim Part
function predictHeal(SPELLID, UNIT, VARIATION)
    local variation = VARIATION or 1
    local dmgpersec, total = RubimRH.incdmg(UNIT), 0
    -- Exception penalty for low level units (beta)     
    if UnitLevel(UNIT) < UnitLevel("player") or CombatTime("player") == 0 then
        return 0
    end
    if SPELLID == "HolyShock" then
        total = UnitStat("player", 4) * 4 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() * 2 / 100))) / 100)
        -- Talent 5/2 +30% Karatel
        if Buffs("player", 105809, "player") > 0 then
            total = total * 1.30
        end
    end

    if SPELLID == "FlashofLight" then
        local castTime = select(4, GetSpellInfo(19750)) / 1000
        total = UnitStat("player", 4) * 4.5 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)
        -- Infusion of Light Buff +50% by HolyShock
        if Buffs("player", 54149, "player") > 0 then
            total = total * 1.50
        end
        -- PvP talent Buff +100%
        if Buffs("player", 210294, "player") > 0 then
            total = total * 2
        end
        -- Artefact Buff +20%
        if (not Mouseover("friendly") and Buffs("target", 200654, "player") > castTime) or (Mouseover("friendly") and Buffs("mouseover", 200654, "player") > castTime) then
            total = total * 1.2
        end
        if dmgpersec > 0 and castTime ~= nil then
            total = total - (dmgpersec * castTime)
        end
    end

    if SPELLID == "HolyLight" then
        local castTime = select(4, GetSpellInfo(82326)) / 1000
        total = UnitStat("player", 4) * 4.25 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)
        -- PvP talent Buff +100%
        if Buffs("player", 210294, "player") > 0 then
            total = total * 2
        end
        -- Artefact Buff +20%
        if (not Mouseover("friendly") and Buffs("target", 200654, "player") > castTime) or (Mouseover("friendly") and Buffs("mouseover", 200654, "player") > castTime) then
            total = total * 1.2
        end
        if dmgpersec > 0 and castTime ~= nil then
            total = total - (dmgpersec * castTime)
        end
    end

    if SPELLID == "LightofMartyr" then
        total = UnitStat("player", 4) * 5 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)
    end

    if SPELLID == "LightofDawn" then
        total = UnitStat("player", 4) * 1.8 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)
    end

    if SPELLID == "HolyPrism" then
        total = UnitStat("player", 4) * 4 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)
    end

    if SPELLID == "BestowFaith" then
        total = (UnitStat("player", 4) * 6 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)) + (getHEAL(UNIT) * 5) + UnitGetIncomingHeals(UNIT) - (RubimRH.incdmg(UNIT) * 5)
    end

    -- AW +35%
    if Buffs("player", 31842, "player") > 0 and total > 0 then
        total = total * 1.35
    end

    -- These spells doesn't relative for increasing heal buffs
    if SPELLID == "LayonHands" then
        total = UnitHealthMax("player")
    end

    if SPELLID == "GiftofNaaru" then
        total = UnitHealthMax("player") * 0.2 + (getHEAL(UNIT) * 5) + UnitGetIncomingHeals(UNIT) - (RubimRH.incdmg(UNIT) * 5)
    end

    return total + (total * variation) / 100 or 0
end