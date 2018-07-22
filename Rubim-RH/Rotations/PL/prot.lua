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
local Spells = Spell.Paladin.Retribution;

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

--- Class-specific Spell:CanCast function, parameters optional
function Spell:CanCast(spellRange, spellUnit)
    spellRange = spellRange or nil
    spellUnit = spellUnit or nil

    return self:IsCastable(spellRange, spellUnit)
end

local function APL()

    if not Player:AffectingCombat() then
        return 0, 462338
    end

    print(RubimRH.getDMG(Player))

    --- Determine if we're tanking
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);
    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();

    --- Unit update
    HL.GetEnemies(10, true);

    --- Kick
    if Spells.Rebuke:CanCast("Melee")
            and Target:IsInterruptible()
            and Target:CastRemains() <= 0.5 then
        return Spells.Rebuke:Cast()
    end

    --- Defensives / Healing

    -- Shield of the Righteous
    if (not Player:Buff(Spells.ShieldOfTheRighteousBuff) or (Player:Buff(Spells.ShieldOfTheRighteousBuff) and Player:BuffRemains(Spells.ShieldOfTheRighteousBuff) <= Player:GCD()))
            and Spells.ShieldOfTheRighteous:CanCast("Melee")
            and (Spells.ShieldOfTheRighteous:ChargesFractional() >= 2 or Player:ActiveMitigationNeeded())
            and (Player:Buff(Spells.AvengersValor) or (not Player:Buff(Spells.AvengersValor) and Spells.AvengersShield:CooldownRemains() >= Player:GCD() * 2)) then
        return Spells.ShieldOfTheRighteous:Cast()
    end

    -- Light of the Protector
    local VersatilityHealIncrease = (GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100
    local SpellPower = GetSpellBonusDamage(2) -- Same result for all schools
    local LotPHeal = (SpellPower * 2.8) + ((SpellPower * 2.8) * VersatilityHealIncrease)
    LotPHeal = (LotPHeal * ((100 - Player:HealthPercentage()) / 100)) + LotPHeal
    local ShouldLotP = Player:Health() <= (Player:MaxHealth() - LotPHeal) and true or false
    if (Spells.LightOfTheProtector:CanCast(nil, Player) or Spells.HandOfTheProtector:CanCast(nil, Player))
            and ShouldLotP then
        return Spells.LightOfTheProtector:Cast()
    end

    -- Hand of the Protector
    local MouseoverUnitValid = (Unit("mouseover"):Exists() and UnitIsFriend("player", "mouseover")) and true or false
    local MouseoverUnit = (MouseoverUnitValid) and Unit("mouseover") or nil
    local MouseoverUnitNeedsHelp = (MouseoverUnitValid and (LotPHeal <= (MouseoverUnit:MaxHealth() - MouseoverUnit:Health()))) and true or false
    if Spells.HandOfTheProtector:CanCast(40, MouseoverUnit)
            and MouseoverUnitNeedsHelp then
        return Spells.HandOfTheProtector:Cast()
    end

    -- Blessing of Protection
    local MouseoverUnitNeedsBoP = (MouseoverUnitValid and (MouseoverUnit:HealthPercentage() <= 40)) and true or false
    if Spells.BlessingOfProtection:CanCast(40, MouseoverUnit)
            and MouseoverUnitNeedsBoP then
        return Spells.BlessingOfProtection:Cast()
    end

    --Blessing Of Sacrifice
    local MouseoverUnitNeedsBlessingOfSacrifice = (MouseoverUnitValid and RubimRH.getDMG(MouseoverUnit) >= (MouseoverUnit:MaxHealth() / 20)) and true or false
    if MouseoverUnitNeedsBlessingOfSacrifice
            and Spells.BlessingOfSacrifice:CanCast(40, MouseoverUnit) then
        return Spells.BlessingOfSacrifice:Cast()
    end

    local MovementSpeed = select(1, GetUnitSpeed("player"))
    if MovementSpeed < 7 -- Standard base run speed is 7 yards per second
            and MovementSpeed ~= 0 -- 0 move speed = not moving
            and Spells.BlessingOfFreedom:CanCast() then
        return Spells.BlessingOfFreedom:Cast()
    end

    if Target:Exists()
            and Spells.HammerOfJustice:CanCast(10)
            and LeftCtrl
            and LeftShift then
        return Spells.HammerOfJustice:Cast()
    end

    --- Offensive CDs
    --print(Target:TimeToDie())
    if RubimRH.CDsON()
            and (Target:TimeToDie() >= 20 or (Player:Health() <= 50 and Spells.LightOfTheProtector:CooldownRemains() <= Player:GCD() * 2)) -- Use as offensive or big defensive reactive CD
            and Spells.AvengingWrath:IsReady() then
        return Spells.AvengingWrath:Cast()
    end

    --- Main damage rotation: all executed as soon as they're available
    if not Player:Buff(Spells.Consecration)
            and ((RubimRH.lastMoved() >= 1 and IsTanking) or (Player:IsTanking(Target) and Target:IsInRange(8)))
            and Spells.Consecration:CanCast() then
        return Spells.Consecration:Cast()
    end

    if Spells.Judgment:CanCast(30) then
        return Spells.Judgment:Cast()
    end

    if Spells.AvengersShield:CanCast(30) then
        return Spells.AvengersShield:Cast()
    end

    if Spells.BlessedHammer:CanCast("Melee") then
        return Spells.BlessedHammer:Cast()
    end

    if Spells.HammerOfTheRighteous:CanCast("Melee") then
        return Spells.HammerOfTheRighteous:Cast()
    end

    if Spells.Consecration:CanCast() then
        return Spells.Consecration:Cast()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(66, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(66, PASSIVE);