--- ============================ HEADER ============================
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...;
-- AethysCore
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Party = Unit.Party;
local Spell = AC.Spell;
local Item = AC.Item;


--- ============================ CONTENT ============================

if not Spell.Paladin then
    Spell.Paladin = {};
end
Spell.Paladin.Protection = {
    -- Racials

    -- Abilities
    AvengersShield = Spell(31935),
    AvengingWrath = Spell(31884),
    Consecration = Spell(26573),
    ConsecrationBuff = Spell(188370),
    HammeroftheRighteous = Spell(53595),
    Judgment = Spell(20271),
    ShieldoftheRighteous = Spell(53600),
    ShieldoftheRighteousBuff = Spell(132403),
    GrandCrusader = Spell(85043),
    -- Talents
    BlessedHammer = Spell(204019),
    ConsecratedHammer = Spell(203785),
    CrusadersJudgment = Spell(204023),
    -- Artifact
    EyeofTyr = Spell(209202),
    -- Defensive
    LightoftheProtector = Spell(184092),
    HandoftheProtector = Spell(213652),
    -- Utility
    Rebuke = Spell(96231),
    -- Legendaries

    -- Misc

    -- Macros

};
local S = Spell.Paladin.Protection;
-- Items
if not Item.Paladin then
    Item.Paladin = {};
end
Item.Paladin.Protection = {
    -- Legendaries

};
local I = Item.Paladin.Protection;
-- Rotation Var
local T202PC, T204PC = AC.HasTier("T20");
local T212PC, T214PC = AC.HasTier("T21");
-- GUI Settings


--- ======= ACTION LISTS =======


--- ======= MAIN =======
function PaladinProtection()
    -- Unit Update
    AC.GetEnemies(10, true);

    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);
    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();
    --INTERRUPT
    -- Out of Combat
    if not Player:AffectingCombat() then
        -- Flask
        -- Food
        -- Rune
        -- PrePot w/ Bossmod Countdown
        -- Opener
        if Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost() then
            -- Avenger's Shield
            if S.AvengersShield:IsCastable() then
                return S.AvengersShield:ID()
            end
            -- Judgment
            if S.Judgment:IsCastable() then
                return S.Judgment:ID()
            end
        end
        return 146250
    end
    -- In Combat
    if Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost() then
        -- CDs
        -- SotR (HP or (AS on CD and 3 Charges))
        if S.ShieldoftheRighteous:IsCastable("Melee") and IsTanking and Player:BuffRefreshable(S.ShieldoftheRighteousBuff, 4) and (Player:ActiveMitigationNeeded() or (not S.AvengersShield:CooldownUp() and S.ShieldoftheRighteous:ChargesFractional() >= 2.65)) then
            return S.ShieldoftheRighteous:ID()
        end
        -- Avengin Wrath (CDs On)
        if CDsON() and S.AvengingWrath:IsCastable("Melee") then
            return S.AvengingWrath:ID()
        end
        -- Defensives
        if Target:IsInRange(10) then
            if not Player:HealingAbsorbed() then
                -- LotP (HP) / HotP (HP)
                if S.LightoftheProtector:IsCastable() and Player:HealthPercentage() <= RubimRH.db.profile.pl.prot.lightoftheprotector then
                    return S.LightoftheProtector:ID()
                end
                if S.HandoftheProtector:IsCastable() and Player:HealthPercentage() <= 75 then
                    return 250389
                end
            end
        end
        -- Avenger's Shield
        if S.AvengersShield:IsCastable(30) then
            return S.AvengersShield:ID()
        end
        -- Consecration
        if S.Consecration:IsCastable("Melee") and lastMoved() > 1 then
            return S.Consecration:ID()
        end
        -- Judgment
        if S.Judgment:IsCastable(30) then
            return S.Judgment:ID()
        end
        -- Blessed Hammer
        if S.BlessedHammer:IsCastable(10, true) and S.BlessedHammer:Charges() > 1 then
            return S.BlessedHammer:ID()
        end
        if Target:IsInRange("Melee") then
            -- Shield of the Righteous
            if S.ShieldoftheRighteous:IsCastable() and S.ShieldoftheRighteous:Charges() == 3 and IsTanking then
                return S.ShieldoftheRighteous:ID()
            end
            -- Hammer of the Righteous
            if (S.ConsecratedHammer:IsAvailable() or S.HammeroftheRighteous:IsCastable()) then
                return S.HammeroftheRighteous:ID()
            end
        end
    end
    return 233159
end

--- ======= SIMC =======
--- Last Update: 04/30/2017
-- I did it for my Paladin alt to tank Dungeons, so I took these talents: 3133121