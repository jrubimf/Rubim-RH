--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- AethysCore
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;
-- Lua
local pairs = pairs;

-- Spell
if not Spell.DemonHunter then Spell.DemonHunter = {}; end
Spell.DemonHunter.Vengeance = {
    -- Abilities
    Felblade = Spell(232893),
    FelDevastation = Spell(212084),
    Fracture = Spell(263642),
    FractureTalent = Spell(227700),
    Frailty = Spell(247456),
    ImmolationAura = Spell(178740),
    Sever = Spell(235964),
    Shear = Spell(203782),
    SigilofFlame = Spell(204596),
    SpiritBomb = Spell(247454),
    SoulCleave = Spell(228477),
    SoulFragments = Spell(203981),
    ThrowGlaive = Spell(204157),
    -- Offensive
    SoulCarver = Spell(207407),
    -- Defensive
    FieryBrand = Spell(204021),
    DemonSpikes = Spell(203720),
    DemonSpikesBuff = Spell(203819),
    -- Utility
    ConsumeMagic = Spell(183752),
    InfernalStrike = Spell(189110)
};
local S = Spell.DemonHunter.Vengeance;

local T202PC, T204PC = AC.HasTier("T20");
local T212PC, T214PC = AC.HasTier("T21");
-- APL Main
local function APL()
    if not Player:AffectingCombat() then
        return 0, 462338
    end
    -- Unit Update
    AC.GetEnemies(20, true); -- Fel Devastation (I think it's 20 thp)
    AC.GetEnemies(8, true); -- Sigil of Flame & Spirit Bomb

    -- Misc
    local SoulFragments = Player:BuffStack(S.SoulFragments);
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);

    --- Defensives
    -- Demon Spikes
    if S.DemonSpikes:IsCastable("Melee") and Player:Pain() >= 20 and not Player:Buff(S.DemonSpikesBuff) and (Player:ActiveMitigationNeeded() or Player:HealthPercentage() <= 85) and (IsTanking or not Player:HealingAbsorbed()) then
        return S.DemonSpikes:ID()
    end

    if S.DemonSpikes:IsCastable("Melee") and Player:Pain() >= 20 and not Player:Buff(S.DemonSpikesBuff) and IsTanking and not Player:HealingAbsorbed() and S.DemonSpikes:ChargesFractional() >= 1.8 then
        return S.DemonSpikes:ID()
    end
    if S.InfernalStrike:TimeSinceLastCast() > 2 and S.InfernalStrike:IsCastable("Melee") and S.InfernalStrike:ChargesFractional() >= 2.0 - Player:GCD()/10 then
        return S.InfernalStrike:ID()
    end
    -- actions+=/spirit_bomb,if=soul_fragments=5|debuff.frailty.down
    -- Note: Looks like the debuff takes time to refresh so we add TimeSinceLastCast to offset that.
    if S.SpiritBomb:IsCastable() and S.SpiritBomb:TimeSinceLastCast() > Player:GCD() * 2 and Cache.EnemiesCount[8] >= 1 and (SoulFragments >= 4 or (Target:DebuffDownP(S.Frailty) and SoulFragments >= 1)) then
        return S.SpiritBomb:ID()
    end

    if S.FieryBrand:IsCastable("Melee") then
        return S.FieryBrand:ID()
    end
    -- actions+=/soul_carver
    if S.SoulCarver:IsCastable("Melee") then
        return S.SoulCarver:ID()
    end
    -- actions+=/immolation_aura,if=pain<=80
    if S.ImmolationAura:IsCastable() and Cache.EnemiesCount[8] >= 1 and not Player:Buff(S.ImmolationAura) and Player:Pain() <= 80 then
        return S.ImmolationAura:ID()
    end
    -- actions+=/felblade,if=pain<=70
    if S.Felblade:IsCastable(15) and Player:Pain() <= 75 then
        return S.Felblade:ID()
    end
    -- actions+=/fel_devastation
    if RubimRH.CDsON() and S.FelDevastation:IsCastable(20, true) and RubimRH.lastMoved() > 1 and Player:Pain() >= 30 then
        return S.FelDevastation:ID()
    end
    -- actions+=/sigil_of_flame
    if S.SigilofFlame:IsCastable() and Cache.EnemiesCount[8] >= 1 then
        return S.SigilofFlame:ID()
    end
    if Target:IsInRange("Melee") then
        -- actions+=/soul_cleave,if=pain>=80
        if not S.Fracture:IsAvailable() and S.SoulCleave:IsCastable() and S.SoulCleave:IsReady() and not S.SpiritBomb:IsAvailable() and (Player:Pain() >= 80 or SoulFragments >= 5) then
            return S.SoulCleave:ID()
        end

        if S.Fracture:IsAvailable() and S.SoulCleave:IsCastable() and S.SoulCleave:IsReady() and not S.SpiritBomb:IsAvailable() and (Player:Pain() >= 75 or SoulFragments >= 5) then
            return S.SoulCleave:ID()
        end
        -- actions+=/sever
        if S.Sever:IsCastable() then
            --Hacky Stuff
            return 203783
        end

        if S.Fracture:IsAvailable() and S.Fracture:IsReady() then
            return 279450
        end

        -- actions+=/shear
        if S.Shear:IsCastable() then
            return S.Shear:ID()
        end
    end
    if Target:IsInRange(30) and S.ThrowGlaive:IsCastable() then
        return S.ThrowGlaive:ID()
    end
    return 0, 975743
end
RubimRH.Rotation.SetAPL(581, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(581, PASSIVE);