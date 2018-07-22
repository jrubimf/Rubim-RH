--- Last Update: Bishop 7/21/18

local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")

local addonName, addonTable = ...;
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Party = Unit.Party;
local Spell = HL.Spell;
local Item = HL.Item;

--- Ability declarations
if not Spell.Paladin then
    Spell.Paladin = {};
end
Spell.Paladin.Protection = {
    -- Racials
    ArcaneTorrent = Spell(155145),
    -- Primary rotation abilities
    AvengersShield = Spell(31935),
    AvengersValor = Spell(197561),
    AvengingWrath = Spell(31884),
    Consecration = Spell(26573),
    HammerOfTheRighteous = Spell(53595),
    Judgment = Spell(275779),
    ShieldOfTheRighteous = Spell(53600),
    ShieldOfTheRighteousBuff = Spell(132403),
    GrandCrusader = Spell(85043),
    -- Talents
    BlessedHammer = Spell(204019),
    ConsecratedHammer = Spell(203785),
    CrusadersJudgment = Spell(204023),
    -- Defensive / Utility
    LightOfTheProtector = Spell(184092),
    HandOfTheProtector = Spell(213652),
    LayOnHands = Spell(633),
    GuardianofAncientKings = Spell(86659),
    ArdentDefender = Spell(31850),
    BlessingOfFreedom = Spell(1044),
    HammerOfJustice = Spell(853),
    BlessingOfProtection = Spell(1022),
    BlessingOfSacrifice = Spell(6940),
    -- Utility
    Rebuke = Spell(96231)
}
local ProtSpells = Spell.Paladin.Protection;

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

local function APL()

    if not Player:AffectingCombat() then
        return 0, 462338
    end

    --- Determine if we're tanking
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);
    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();

    --- Unit update
    HL.GetEnemies(10, true);

    --- Kick
    if ProtSpells.Rebuke:IsReady("Melee")
            and Target:IsInterruptible()
            and Target:CastRemains() <= 0.5 then
        return ProtSpells.Rebuke:Cast()
    end

    --- Defensives / Healing

    -- Shield of the Righteous
    if (not Player:Buff(ProtSpells.ShieldOfTheRighteousBuff) or (Player:Buff(ProtSpells.ShieldOfTheRighteousBuff) and Player:BuffRemains(ProtSpells.ShieldOfTheRighteousBuff) <= Player:GCD()))
            and ProtSpells.ShieldOfTheRighteous:IsReady("Melee")
            and (ProtSpells.ShieldOfTheRighteous:ChargesFractional() >= 2 or Player:ActiveMitigationNeeded())
            and (Player:Buff(ProtSpells.AvengersValor) or (not Player:Buff(ProtSpells.AvengersValor) and ProtSpells.AvengersShield:CooldownRemains() >= Player:GCD() * 2)) then
        return ProtSpells.ShieldOfTheRighteous:Cast()
    end

    -- Light of the Protector
    local VersatilityHealIncrease = (GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100
    local SpellPower = GetSpellBonusDamage(2) -- Same result for all schools
    local LotPHeal = (SpellPower * 2.8) + ((SpellPower * 2.8) * VersatilityHealIncrease)
    LotPHeal = (LotPHeal * ((100 - Player:HealthPercentage()) / 100)) + LotPHeal
    local ShouldLotP = Player:Health() <= (Player:MaxHealth() - LotPHeal) and true or false
    if (ProtSpells.LightOfTheProtector:IsReady() or ProtSpells.HandOfTheProtector:IsReady())
            and ShouldLotP then
        return ProtSpells.LightOfTheProtector:Cast()
    end

    -- Hand of the Protector
    local MouseoverUnitValid = (Unit("mouseover"):Exists() and UnitIsFriend("player", "mouseover")) and true or false
    local MouseoverUnit = (MouseoverUnitValid) and Unit("mouseover") or nil
    local MouseoverUnitNeedsHelp = (MouseoverUnitValid and (LotPHeal <= (MouseoverUnit:MaxHealth() - MouseoverUnit:Health()))) and true or false
    if ProtSpells.HandOfTheProtector:IsReady(40, false, MouseoverUnit)
            and MouseoverUnitNeedsHelp then
        return ProtSpells.HandOfTheProtector:Cast()
    end

    -- Blessing of Protection
    local MouseoverUnitNeedsBoP = (MouseoverUnitValid and (MouseoverUnit:HealthPercentage() <= 40)) and true or false
    if ProtSpells.BlessingOfProtection:IsReady(40, false, MouseoverUnit)
            and MouseoverUnitNeedsBoP then
        return ProtSpells.BlessingOfProtection:Cast()
    end

    -- TODO: Waiting for GGLoader to add spell texture for Blessing of Sacrifice
    --Blessing Of Sacrifice
    --    local MouseoverUnitNeedsBlessingOfSacrifice = (MouseoverUnitValid and Player:HealthPercentage() <= 80) and true or false
    --    if MouseoverUnitNeedsBlessingOfSacrifice
    --            and ProtSpells.BlessingOfSacrifice:IsReady(40, false, MouseoverUnit) then
    --        return ProtSpells.BlessingOfSacrifice:Cast()
    --    end

    local MovementSpeed = select(1, GetUnitSpeed("player"))
    if MovementSpeed < 7 -- Standard base run speed is 7 yards per second
            and MovementSpeed ~= 0 -- 0 move speed = not moving
            and ProtSpells.BlessingOfFreedom:IsReady() then
        return ProtSpells.BlessingOfFreedom:Cast()
    end

    if Target:Exists()
            and ProtSpells.HammerOfJustice:IsReady(10)
            and LeftCtrl
            and LeftShift then
        return ProtSpells.HammerOfJustice:Cast()
    end

    --- Offensive CDs
    --print(Target:TimeToDie())
    if RubimRH.CDsON()
            and (Target:TimeToDie() >= 20 or (Player:Health() <= 50 and ProtSpells.LightOfTheProtector:CooldownRemains() <= Player:GCD() * 2)) -- Use as offensive or big defensive reactive CD
            and ProtSpells.AvengingWrath:IsReady() then
        return ProtSpells.AvengingWrath:Cast()
    end

    --- Main damage rotation: all executed as soon as they're available
    if not Player:Buff(ProtSpells.Consecration)
            and (Target:Exists() and Target:IsInRange("Melee"))
            and ProtSpells.Consecration:IsReady() then
        return ProtSpells.Consecration:Cast()
    end

    if ProtSpells.Judgment:IsReady(30) then
        return ProtSpells.Judgment:Cast()
    end

    if ProtSpells.AvengersShield:IsReady(30) then
        return ProtSpells.AvengersShield:Cast()
    end

    if ProtSpells.BlessedHammer:IsReady()
            and Target:Exists()
            and Target:IsInRange("Melee") then
        return ProtSpells.BlessedHammer:Cast()
    end

    if ProtSpells.HammerOfTheRighteous:IsReady("Melee") then
        return ProtSpells.HammerOfTheRighteous:Cast()
    end

    if ProtSpells.Consecration:IsReady()
            and (Target:Exists() and Target:IsInRange("Melee")) then
        return ProtSpells.Consecration:Cast()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(66, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(66, PASSIVE);