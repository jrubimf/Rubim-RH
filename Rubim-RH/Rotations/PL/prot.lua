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
-- Racials
local ArcaneTorrent = Spell(155145)
-- Primary rotation abilities
local AvengersShield = Spell(31935)
local AvengersValor = Spell(197561)
local AvengingWrath = Spell(31884)
local Consecration = Spell(26573)
local HammerOfTheRighteous = Spell(53595)
local Judgment = Spell(275779)
local ShieldOfTheRighteous = Spell(53600)
local ShieldOfTheRighteousBuff = Spell(132403)
local GrandCrusader = Spell(85043)
-- Talents
local BlessedHammer = Spell(204019)
local ConsecratedHammer = Spell(203785)
local CrusadersJudgment = Spell(204023)
-- Defensive / Utility
local LightOfTheProtector = Spell(184092)
local HandOfTheProtector = Spell(213652)
local LayOnHands = Spell(633)
local GuardianofAncientKings = Spell(86659)
local ArdentDefender = Spell(31850)
local BlessingOfFreedom = Spell(1044)
local HammerOfJustice = Spell(853)
local BlessingOfProtection = Spell(1022)
local BlessingOfSacrifice = Spell(6940)
-- Utility
local Rebuke = Spell(96231)


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
    if Rebuke:CanCast("Melee")
            and Target:IsInterruptible()
            and Target:CastRemains() <= 0.5 then
        return Rebuke:Cast()
    end

    --- Defensives / Healing

    -- Shield of the Righteous
    if (not Player:Buff(ShieldOfTheRighteousBuff) or (Player:Buff(ShieldOfTheRighteousBuff) and Player:BuffRemains(ShieldOfTheRighteousBuff) <= Player:GCD()))
            and ShieldOfTheRighteous:CanCast("Melee")
            and (ShieldOfTheRighteous:ChargesFractional() >= 2 or Player:ActiveMitigationNeeded())
            and (Player:Buff(AvengersValor) or (not Player:Buff(AvengersValor) and AvengersShield:CooldownRemains() >= Player:GCD() * 2)) then
        return ShieldOfTheRighteous:Cast()
    end

    -- Light of the Protector
    local VersatilityHealIncrease = (GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100
    local SpellPower = GetSpellBonusDamage(2) -- Same result for all schools
    local LotPHeal = (SpellPower * 2.8) + ((SpellPower * 2.8) * VersatilityHealIncrease)
    LotPHeal = (LotPHeal * ((100 - Player:HealthPercentage()) / 100)) + LotPHeal
    local ShouldLotP = Player:Health() <= (Player:MaxHealth() - LotPHeal) and true or false
    if (LightOfTheProtector:CanCast(nil, Player) or HandOfTheProtector:CanCast(nil, Player))
            and ShouldLotP then
        return LightOfTheProtector:Cast()
    end

    -- Hand of the Protector
    local MouseoverUnitValid = (Unit("mouseover"):Exists() and UnitIsFriend("player", "mouseover")) and true or false
    local MouseoverUnit = (MouseoverUnitValid) and Unit("mouseover") or nil
    local MouseoverUnitNeedsHelp = (MouseoverUnitValid and (LotPHeal <= (MouseoverUnit:MaxHealth() - MouseoverUnit:Health()))) and true or false
    if HandOfTheProtector:CanCast(40, MouseoverUnit)
            and MouseoverUnitNeedsHelp then
        return HandOfTheProtector:Cast()
    end

    -- Blessing of Protection
    local MouseoverUnitNeedsBoP = (MouseoverUnitValid and (MouseoverUnit:HealthPercentage() <= 40)) and true or false
    if BlessingOfProtection:CanCast(40, MouseoverUnit)
            and MouseoverUnitNeedsBoP then
        return BlessingOfProtection:Cast()
    end

     --Blessing Of Sacrifice
    local MouseoverUnitNeedsBlessingOfSacrifice = (MouseoverUnitValid and RubimRH.getDMG(MouseoverUnit) >= (MouseoverUnit:MaxHealth() / 20)) and true or false
    if MouseoverUnitNeedsBlessingOfSacrifice
        and BlessingOfSacrifice:CanCast(40, MouseoverUnit) then
        return BlessingOfSacrifice:Cast()
    end

    local MovementSpeed = select(1, GetUnitSpeed("player"))
    if MovementSpeed < 7 -- Standard base run speed is 7 yards per second
            and MovementSpeed ~= 0 -- 0 move speed = not moving
            and BlessingOfFreedom:CanCast() then
        return BlessingOfFreedom:Cast()
    end

    if Target:Exists()
            and HammerOfJustice:CanCast(10)
            and LeftCtrl
            and LeftShift then
        return HammerOfJustice:Cast()
    end

    --- Offensive CDs
    --print(Target:TimeToDie())
    if RubimRH.CDsON()
            and (Target:TimeToDie() >= 20 or (Player:Health() <= 50 and LightOfTheProtector:CooldownRemains() <= Player:GCD() * 2)) -- Use as offensive or big defensive reactive CD
            and AvengingWrath:IsReady() then
        return AvengingWrath:Cast()
    end

    --- Main damage rotation: all executed as soon as they're available
    if not Player:Buff(Consecration)
            and ((RubimRH.lastMoved() >= 1 and IsTanking) or (Player:IsTanking(Target) and Target:IsInRange(8)))
            and Consecration:CanCast() then
        return Consecration:Cast()
    end

    if Judgment:CanCast(30) then
        return Judgment:Cast()
    end

    if AvengersShield:CanCast(30) then
        return AvengersShield:Cast()
    end

    if BlessedHammer:CanCast("Melee") then
        return BlessedHammer:Cast()
    end

    if HammerOfTheRighteous:CanCast("Melee") then
        return HammerOfTheRighteous:Cast()
    end

    if Consecration:CanCast() then
        return Consecration:Cast()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(66, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(66, PASSIVE);