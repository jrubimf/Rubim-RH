local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")

local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

local ISpell = RubimRH.Spell[104]

if not Item.Druid then Item.Druid = {} end
Item.Druid.Guardian = {
    -- Legendaries
    EkowraithCreatorofWorlds = Item(137015, {5}),
    LuffaWrappings = Item(137056, {9})
}
local I = Item.Druid.Guardian;

local function Bear()

    --- Declarations
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target)

    local IncomingDamage = select(1, RubimRH.getDMG("player"))

    local NeedMinorHealing = ((IncomingDamage >= (Player:MaxHealth() * 0.05)) or Player:HealthPercentage() <= 50) and true or false -- Taking 5% max HP in DPS
    local NeedBigHealing = ((IncomingDamage >= (Player:MaxHealth() * 0.1))) and true or false -- Taking 10% max HP in DPS

    local RangeMod = ISpell.BalanceAffinity:IsAvailable() and true or false
    local AbilityRange = {
        Moonfire = (RangeMod) and 43 or 40,
        Mangle = (RangeMod) and 8 or "Melee",
        Thrash = (RangeMod) and 11 or 8,
        Swipe = (RangeMod) and 11 or 8,
        Maul = (RangeMod) and 8 or "Melee",
        Pulverize = (RangeMod) and 8 or "Melee",
        SkullBash = (RangeMod) and 13 or 10
    }
    AbilityRange.Thrash = (I.LuffaWrappings:IsEquipped()) and AbilityRange.Thrash * 1.25 or AbilityRange.Thrash

    --- Defensives / Healing

    -- Bristling Fur
    if ISpell.BristlingFur:IsReadyMorph()
            and NeedMinorHealing then
        return ISpell.BristlingFur:Cast()
    end

    -- Survival Instincts
    if ISpell.SurvivalInstincts:IsReadyMorph()
            and not Player:Buff(ISpell.Barkskin)
            and not Player:Buff(ISpell.SurvivalInstincts)
            and NeedBigHealing then
        return ISpell.SurvivalInstincts:Cast()
    end

    -- TODO: Fix texture after GGLoader properly updates the Barkskin pixels
    -- Barkskin
    if ISpell.Barkskin:IsReady()
            and not Player:Buff(ISpell.SurvivalInstincts)
            and not Player:Buff(ISpell.Barkskin)
            and NeedMinorHealing then
        return ISpell.WarStomp:Cast()
    end

    -- Ironfur
    local WaitForGuardianOfElune = not (Player:Buff(ISpell.GuardianOfEluneBuff) or (not Player:Buff(ISpell.GuardianOfEluneBuff) and ISpell.Mangle:CooldownRemains() > Player:GCD() * 2))
    if ISpell.Ironfur:IsReadyMorph()
            and Player:BuffRemains(ISpell.Ironfur) <= 0.5
            and not WaitForGuardianOfElune
            and IsTanking then
        return ISpell.Ironfur:Cast()
    end

    -- Frenzied Regeneration
    local FrenziedRegenerationHeal = (Player:Buff(ISpell.GuardianOfEluneBuff)) and 21 or 18
    local FrenziedOverHeal = (FrenziedRegenerationHeal + Player:HealthPercentage() >= 100) and true or false
    if ISpell.FrenziedRegeneration:IsReadyMorph()
            and not FrenziedOverHeal
            and NeedMinorHealing
            and ISpell.FrenziedRegeneration:ChargesFractional() >= 1 then
        return ISpell.FrenziedRegeneration:Cast()
    end

    --- Main Damage Rotation

    -- Moonfire
    if Target:DebuffRemains(ISpell.MoonfireDebuff) <= Player:GCD()
            and ISpell.Moonfire:IsReadyMorph(AbilityRange.Moonfire) then
        return ISpell.Moonfire:Cast()
    end

    -- Thrash
    if ISpell.Thrash:IsReadyMorph(AbilityRange.Thrash)
            and Target:DebuffStack(ISpell.ThrashDebuff) < 3 then
        return ISpell.Thrash:Cast()
    end

    -- Pulverize
    if Target:DebuffStack(ISpell.ThrashDebuff) == 3
            and ISpell.Pulverize:IsReadyMorph(AbilityRange.Pulverize) then
        return ISpell.Pulverize:Cast()
    end

    -- Mangle
    if ISpell.Mangle:IsReadyMorph(AbilityRange.Mangle) then
        return ISpell.Mangle:Cast()
    end

    -- Thrash
    if ISpell.Thrash:IsReadyMorph(AbilityRange.Thrash) then
        return ISpell.Thrash:Cast()
    end

    -- Moonfire
    if ISpell.Moonfire:IsReadyMorph(AbilityRange.Moonfire)
            and Player:Buff(ISpell.GalacticGuardianBuff) then
        return ISpell.Moonfire:Cast()
    end

    -- Maul
    if ISpell.Maul:IsReadyMorph(AbilityRange.Maul)
            and Player:Rage() >= 90 then
        return ISpell.Maul:Cast()
    end

    -- Swipe
    if ISpell.Swipe:IsReadyMorph(AbilityRange.Swipe) then
        return ISpell.Swipe:Cast()
    end
end

-- TODO: Cat AoE
local function Cat()
    HL.GetEnemies("Melee");
    HL.GetEnemies(8, true);
    HL.GetEnemies(10, true);
    HL.GetEnemies(20, true);

    local CatWeave = ISpell.FeralAffinity:IsAvailable()
    if CatWeave then
        if Player:ComboPoints() == 5
                and Target:DebuffRemains(ISpell.Rip) <= Player:GCD() * 5
                and ISpell.Rip:IsReadyMorph("Melee") then
            return ISpell.Rip:Cast()
        end

        if Player:ComboPoints() == 5
                and Target:DebuffRemains(ISpell.Rip) >= Player:GCD() * 5
                and ISpell.FerociousBite:IsReadyMorph("Melee") then
            return ISpell.FerociousBite:Cast()
        end

        if Player:ComboPoints() <= 5
                and Target:DebuffRemains(ISpell.RakeDebuff) <= Player:GCD() then
            return ISpell.Rake:Cast()
        end
    end

    if ISpell.ThrashCat:IsReadyMorph("Melee")
            and Target:DebuffRemains(ISpell.ThrashCat) <= Player:GCD() then
        return ISpell.ThrashCat:Cast()
    end

    return ISpell.Shred:Cast()
end

local function Moonkin()
    -- Base cast range for Balance Affinity is 43 yards on all abilities
    local AbilityRange = 43

    -- Moonfire
    if ISpell.Moonfire:IsReadyMorph(AbilityRange)
            and (Target:DebuffRemains(ISpell.MoonfireDebuff) <= Player:GCD() or Player:Buff(ISpell.GalacticGuardianBuff)) then
        return ISpell.Moonfire:Cast()
    end

    -- Sunfire
    if ISpell.Sunfire:IsReadyMorph(AbilityRange)
            and Target:DebuffRemains(ISpell.SunfireDebuff) <= Player:GCD() then
        return ISpell.Sunfire:Cast()
    end

    -- Stationary damage rotation
    if not Player:IsMoving() then

        -- Starsurge
        if ISpell.Starsurge:IsReadyMorph(AbilityRange)
                and not Player:Buff(ISpell.LunarEmpowerment)
                and not Player:Buff(ISpell.SolarEmpowerment) then
            return ISpell.Starsurge:Cast()
        end

        -- Lunar Strike
        if ISpell.LunarStrike:IsReadyMorph(AbilityRange) and
                Player:Buff(ISpell.LunarEmpowerment) then
            return ISpell.LunarStrike:Cast()
        end

        -- Wrath spam
        if ISpell.Wrath:IsReadyMorph(AbilityRange) then return ISpell.Wrath:Cast() end
    else
        -- Moonfire spam on the move
        if ISpell.Moonfire:IsReadyMorph(AbilityRange) then return ISpell.Moonfire:Cast() end
    end

    return nil
end

local function APL()

    if not Player:AffectingCombat() then return 0, 462338 end

    local ShapeshiftStance = {
        Bear = (Player:Buff(ISpell.BearForm)),
        Cat = (Player:Buff(ISpell.CatForm)),
        Travel = (Player:Buff(ISpell.TravelForm)),
        Moonkin = (Player:Buff(ISpell.MoonkinForm)),
        NoStance = false
    }
    ShapeshiftStance.NoStance = (not ShapeshiftStance.Bear and not ShapeshiftStance.Cat and not ShapeshiftStance.Travel and not ShapeshiftStance.Moonkin)

    -- TODO: Implement when GGLoader fixes Mighty Bash texture
    --    local CTRL = IsLeftControlKeyDown()
    --    local SHIFT = IsLeftShiftKeyDown()
    --    if CTRL and SHIFT then
    --        if S.Typhoon:IsReadyMorph(15) then return S.Typhoon:Cast() end
    --        if S.MightyBash:IsReadyMorph("Melee") then return S.MightyBash:Cast() end
    --        if S.Entanglement:IsReadyMorph("Melee") then return S.Entanglement:Cast() end
    --    end

    if ShapeshiftStance.Bear and Bear() ~= nil then return Bear() end
    if ShapeshiftStance.Cat and Cat() ~= nil then return Cat() end
    if ShapeshiftStance.Moonkin and Moonkin() ~= nil then return Moonkin() end

    return 0, 975743
end

RubimRH.Rotation.SetAPL(104, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(104, PASSIVE);