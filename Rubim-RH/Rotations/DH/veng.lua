--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
-- Lua
local pairs = pairs;

local S = RubimRH.Spell[581]

S.Fracture.TextureSpellID = { 279450 }
S.Sever.TextureSpellID = { 279450 }

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");
-- APL Main
local function APL()
    if not Player:AffectingCombat() then
        return 0, 462338
    end
    -- Unit Update
    HL.GetEnemies(20, true); -- Fel Devastation (I think it's 20 thp)
    HL.GetEnemies(8, true); -- Sigil of Flame & Spirit Bomb

    -- Misc
    local SoulFragments = Player:BuffStack(S.SoulFragments);
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);

    --- Defensives
    if S.Metamorphosis:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[581].metamorphosis then
        return S.Metamorphosis:Cast()
    end

    if S.SoulBarrier:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[581].soulbarrier then
        return S.SoulBarrier:Cast()
    end

    -- Demon Spikes
    if S.DemonSpikes:IsReady("Melee") and Player:Pain() >= 20 and not Player:Buff(S.DemonSpikesBuff) and (Player:ActiveMitigationNeeded() or Player:HealthPercentage() <= 85) and (IsTanking or not Player:HealingAbsorbed()) then
        return S.DemonSpikes:Cast()
    end

    if S.DemonSpikes:IsReady("Melee") and Player:Pain() >= 20 and not Player:Buff(S.DemonSpikesBuff) and IsTanking and not Player:HealingAbsorbed() and S.DemonSpikes:ChargesFractional() >= 1.8 then
        return S.DemonSpikes:Cast()
    end
    if RubimRH.config.Spells[1].isActive and S.InfernalStrike:TimeSinceLastCast() > 2 and S.InfernalStrike:IsReady("Melee") and S.InfernalStrike:ChargesFractional() >= 2.0 - Player:GCD()/10 then
        return S.InfernalStrike:Cast()
    end
    -- actions+=/spirit_bomb,if=soul_fragments=5|debuff.frailty.down
    -- Note: Looks like the debuff takes time to refresh so we add TimeSinceLastCast to offset that.
    if S.Fracture:IsAvailable() and S.Fracture:IsReady("Melee") and SoulFragments <= 3 and Player:PainDeficit() <= 25 then
        return S.Fracture:Cast()
    end

    if S.SpiritBomb:IsReady() and S.SpiritBomb:TimeSinceLastCast() > Player:GCD() * 2 and Cache.EnemiesCount[8] >= 1 and (SoulFragments >= 4 or (Target:DebuffDownP(S.Frailty) and SoulFragments >= 1)) then
        return S.SpiritBomb:Cast()
    end

    if RubimRH.config.Spells[2].isActive and S.FieryBrand:IsReady("Melee") then
        return S.FieryBrand:Cast()
    end
    -- actions+=/soul_carver
    if S.SoulCarver:IsReady("Melee") then
        return S.SoulCarver:Cast()
    end
    -- actions+=/immolation_aura,if=pain<=80
    if S.ImmolationAura:IsReady() and Cache.EnemiesCount[8] >= 1 and not Player:Buff(S.ImmolationAura) and Player:Pain() <= 80 then
        return S.ImmolationAura:Cast()
    end
    -- actions+=/felblade,if=pain<=70
    if S.Felblade:IsReady(15) and Player:Pain() <= 75 then
        return S.Felblade:Cast()
    end
    -- actions+=/fel_devastation
    if RubimRH.CDsON() and S.FelDevastation:IsReady(20, true) and RubimRH.lastMoved() > 1 and Player:Pain() >= 30 then
        return S.FelDevastation:Cast()
    end
    -- actions+=/sigil_of_flame
    if S.SigilofFlame:IsReady() and Cache.EnemiesCount[8] >= 1 then
        return S.SigilofFlame:Cast()
    end
    if Target:IsInRange("Melee") then
        -- actions+=/soul_cleave,if=pain>=80
        if not S.Fracture:IsAvailable() and S.SoulCleave:IsReady() and S.SoulCleave:IsReady() and not S.SpiritBomb:IsAvailable() and (Player:Pain() >= 80 or SoulFragments >= 5) then
            return S.SoulCleave:Cast()
        end

        if S.Fracture:IsAvailable() and S.SoulCleave:IsReady() and S.SoulCleave:IsReady() and not S.SpiritBomb:IsAvailable() and (Player:Pain() >= 75 or SoulFragments >= 5) then
            return S.SoulCleave:Cast()
        end
        -- actions+=/sever
        if S.Sever:IsReady("Melee") then
            --Hacky Stuff
            return S.Sever:Cast()
        end

        if S.Fracture:IsAvailable() and S.Fracture:IsReady("Melee") then
            return S.Fracture:Cast()
        end

        -- actions+=/shear
        if S.Shear:IsReady("Melee") then
            return S.Shear:Cast()
        end
    end
    if Target:IsInRange(30) and S.ThrowGlaive:IsReady() then
        return S.ThrowGlaive:Cast()
    end
    return 0, 135328
end
RubimRH.Rotation.SetAPL(581, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(581, PASSIVE);