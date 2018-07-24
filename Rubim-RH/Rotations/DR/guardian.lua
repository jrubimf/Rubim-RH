local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

if not Spell.Druid then Spell.Druid = {}; end
Spell.Druid.Guardian = {
    -- Racials
    WarStomp             = Spell(20549),
    -- Abilities
    FrenziedRegeneration = Spell(22842),
    Gore				 = Spell(210706),
    GoreBuff             = Spell(93622),
    GoryFur              = Spell(201671),
    Ironfur              = Spell(192081),
    Mangle               = Spell(33917),
    Maul                 = Spell(6807),
    Moonfire             = Spell(8921),
    MoonfireDebuff       = Spell(164812),
    Sunfire              = Spell(197630),
    SunfireDebuff        = Spell(164815),
    Starsurge            = Spell(197626),
    LunarEmpowerment     = Spell(164547),
    SolarEmpowerment     = Spell(164545),
    LunarStrike          = Spell(197628),
    Wrath                = Spell(197629),
    Regrowth             = Spell(8936),
    Swipe                = Spell(213771),
    Thrash               = Spell(77758),
    ThrashDebuff         = Spell(192090),
    ThrashCat            = Spell(106830),
    Prowl                = Spell(5215),
    -- Talents
    BalanceAffinity      = Spell(197488),
    BloodFrenzy          = Spell(203962),
    Brambles             = Spell(203953),
    BristlingFur         = Spell(155835),
    Earthwarden          = Spell(203974),
    EarthwardenBuff      = Spell(203975),
    FeralAffinity        = Spell(202155),
    GalacticGuardian     = Spell(203964),
    GalacticGuardianBuff = Spell(213708),
    GuardianOfElune 	 = Spell(155578),
    GuardianOfEluneBuff  = Spell(213680),
    Incarnation          = Spell(102558),
    LunarBeam            = Spell(204066),
    Pulverize            = Spell(80313),
    PulverizeBuff        = Spell(158792),
    RestorationAffinity  = Spell(197492),
    SouloftheForest      = Spell(158477),
    MightyBash           = Spell(5211),
    Typhoon              = Spell(132469),
    Entanglement         = Spell(102359),
    -- Artifact
    RageoftheSleeper     = Spell(200851),
    -- Defensive
    SurvivalInstincts    = Spell(61336),
    Barkskin             = Spell(22812),
    -- Utility
    Growl                = Spell(6795),
    SkullBash            = Spell(106839),
    -- Affinity
    FerociousBite        = Spell(22568),
    HealingTouch         = Spell(5185),
    Rake                 = Spell(1822),
    RakeDebuff           = Spell(155722),
    Rejuvenation         = Spell(774),
    Rip                  = Spell(1079),
    Shred                = Spell(5221),
    Swiftmend            = Spell(18562),
    -- Shapeshift
    BearForm             = Spell(5487),
    CatForm              = Spell(768),
    MoonkinForm          = Spell(197625),
    TravelForm           = Spell(783)
};
local S = Spell.Druid.Guardian;

if not Item.Druid then Item.Druid = {}; end
Item.Druid.Guardian = {
    -- Legendaries
    EkowraithCreatorofWorlds = Item(137015, {5}),
    LuffaWrappings = Item(137056, {9})
};
local I = Item.Druid.Guardian;

function Spell:CanCast(RANGE, UNIT)

    local DebugCanCast = false
    if RANGE ~= nil then
        if tostring(RANGE) == "Melee" then RANGE = 5 end
    end

    -- Spell Cooldown
    local SpellCooldownUp

    local CurrentTime = GetTime()
    local GCDStart, GCDDuration, _ = GetSpellCooldown(61304)
    local GCDRemains = (GCDStart ~= 0) and (CurrentTime - (GCDStart + GCDDuration)) or 0

    local SpellCDStart, SpellCDDuration, _ = GetSpellCooldown(self:ID())
    local SpellCDRemains = (SpellCDStart ~= 0) and (CurrentTime - (SpellCDStart + SpellCDDuration)) or 0

    if GetSpellCharges(self:ID()) ~= nil then
        -- Spell has charges
        SpellCooldownUp = (select(1, GetSpellCharges(self:ID())) >= 1) and true or false
    else
        if SpellCDStart == 0 then
            SpellCooldownUp = true
        else
            SpellCooldownUp = HeroLib.Spell(self:ID()):CooldownUp()
        end
    end

    -- Spell Known
    local SpellKnown = (GetSpellInfo(self:Name()) ~= nil) and true or false

    -- Spell In Range
    local SpellInRange
    if RANGE ~= nil then
        if UNIT then
            SpellInRange = HeroLib.Unit(UNIT:ID()):IsInRange(RANGE)
        else
            SpellInRange = HeroLib.Unit("target"):IsInRange(RANGE)
        end
    else
        SpellInRange = true
    end

    -- Spell Usable
    local SpellUsable = IsUsableSpell(self:ID())

    if DebugCanCast then
        print("Spell name: " .. tostring(self:Name()))
        print("Range: " .. tostring(RANGE))
        print("Spell on cooldown: " .. tostring(SpellCooldownUp))
        print("Spell Known: " .. tostring(SpellKnown))
        print("Spell in range: " .. tostring(SpellInRange))
        print("Spell usable: " .. tostring(SpellUsable))
        print("Should use: " .. tostring((SpellCooldownUp) and SpellKnown and SpellInRange and SpellUsable))
    end

    return SpellCooldownUp and SpellKnown and SpellInRange and SpellUsable
end

local function Bear()

    --- Declarations
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target)

    local IncomingDamage = select(1, RubimRH.getDMG("player"))

    local NeedMinorHealing = ((IncomingDamage >= (Player:MaxHealth() * 0.05)) or Player:HealthPercentage() <= 50) and true or false -- Taking 5% max HP in DPS
    local NeedBigHealing = ((IncomingDamage >= (Player:MaxHealth() * 0.1))) and true or false -- Taking 10% max HP in DPS

    local RangeMod = S.BalanceAffinity:IsAvailable() and true or false
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
    if S.BristlingFur:IsReadyMorph()
            and NeedMinorHealing then
        return S.BristlingFur:Cast()
    end

    -- Survival Instincts
    if S.SurvivalInstincts:IsReadyMorph()
            and not Player:Buff(S.Barkskin)
            and not Player:Buff(S.SurvivalInstincts)
            and NeedBigHealing then
        return S.SurvivalInstincts:Cast()
    end

    -- TODO: Fix texture after GGLoader properly updates the Barkskin pixels
    -- Barkskin
    if S.Barkskin:IsReady()
            and not Player:Buff(S.SurvivalInstincts)
            and not Player:Buff(S.Barkskin)
            and NeedMinorHealing then
        return S.WarStomp:Cast()
    end

    -- Ironfur
    local WaitForGuardianOfElune = not (Player:Buff(S.GuardianOfEluneBuff) or (not Player:Buff(S.GuardianOfEluneBuff) and S.Mangle:CooldownRemains() > Player:GCD() * 2))
    if S.Ironfur:IsReadyMorph()
            and Player:BuffRemains(S.Ironfur) <= 0.5
            and not WaitForGuardianOfElune
            and IsTanking then
        return S.Ironfur:Cast()
    end

    -- Frenzied Regeneration
    local FrenziedRegenerationHeal = (Player:Buff(S.GuardianOfEluneBuff)) and 21 or 18
    local FrenziedOverHeal = (FrenziedRegenerationHeal + Player:HealthPercentage() >= 100) and true or false
    if S.FrenziedRegeneration:IsReadyMorph()
            and not FrenziedOverHeal
            and NeedMinorHealing
            and S.FrenziedRegeneration:ChargesFractional() >= 1 then
        return S.FrenziedRegeneration:Cast()
    end

    --- Main Damage Rotation

    -- Moonfire
    if Target:DebuffRemains(S.MoonfireDebuff) <= Player:GCD()
            and S.Moonfire:IsReadyMorph(AbilityRange.Moonfire) then
        return S.Moonfire:Cast()
    end

    -- Thrash
    if S.Thrash:IsReadyMorph(AbilityRange.Thrash)
            and Target:DebuffStack(S.ThrashDebuff) < 3 then
        return S.Thrash:Cast()
    end

    -- Pulverize
    if Target:DebuffStack(S.ThrashDebuff) == 3
            and S.Pulverize:IsReadyMorph(AbilityRange.Pulverize) then
        return S.Pulverize:Cast()
    end

    -- Mangle
    if S.Mangle:IsReadyMorph(AbilityRange.Mangle) then
        return S.Mangle:Cast()
    end

    -- Thrash
    if S.Thrash:IsReadyMorph(AbilityRange.Thrash) then
        return S.Thrash:Cast()
    end

    -- Moonfire
    if S.Moonfire:IsReadyMorph(AbilityRange.Moonfire)
            and Player:Buff(S.GalacticGuardianBuff) then
        return S.Moonfire:Cast()
    end

    -- Maul
    if S.Maul:IsReadyMorph(AbilityRange.Maul)
            and Player:Rage() >= 90 then
        return S.Maul:Cast()
    end

    -- Swipe
    if S.Swipe:IsReadyMorph(AbilityRange.Swipe) then
        return S.Swipe:Cast()
    end
end

-- TODO: Cat AoE
local function Cat()
    HL.GetEnemies("Melee");
    HL.GetEnemies(8, true);
    HL.GetEnemies(10, true);
    HL.GetEnemies(20, true);

    local CatWeave = S.FeralAffinity:IsAvailable()
    if CatWeave then
        if Player:ComboPoints() == 5
                and Target:DebuffRemains(S.Rip) <= Player:GCD() * 5
                and S.Rip:IsReadyMorph("Melee") then
            return S.Rip:Cast()
        end

        if Player:ComboPoints() == 5
                and Target:DebuffRemains(S.Rip) >= Player:GCD() * 5
                and S.FerociousBite:IsReadyMorph("Melee") then
            return S.FerociousBite:Cast()
        end

        if Player:ComboPoints() <= 5
                and Target:DebuffRemains(S.RakeDebuff) <= Player:GCD() then
            return S.Rake:Cast()
        end
    end

    if S.ThrashCat:IsReadyMorph("Melee")
            and Target:DebuffRemains(S.ThrashCat) <= Player:GCD() then
        return S.ThrashCat:Cast()
    end

    return S.Shred:Cast()
end

local function Moonkin()
    -- Base cast range for Balance Affinity is 43 yards on all abilities
    local AbilityRange = 43

    -- Moonfire
    if S.Moonfire:IsReadyMorph(AbilityRange)
            and (Target:DebuffRemains(S.MoonfireDebuff) <= Player:GCD() or Player:Buff(S.GalacticGuardianBuff)) then
        return S.Moonfire:Cast()
    end

    -- Sunfire
    if S.Sunfire:IsReadyMorph(AbilityRange)
            and Target:DebuffRemains(S.SunfireDebuff) <= Player:GCD() then
        return S.Sunfire:Cast()
    end

    -- Stationary damage rotation
    if not Player:IsMoving() then

        -- Starsurge
        if S.Starsurge:IsReadyMorph(AbilityRange)
                and not Player:Buff(S.LunarEmpowerment)
                and not Player:Buff(S.SolarEmpowerment) then
            return S.Starsurge:Cast()
        end

        -- Lunar Strike
        if S.LunarStrike:IsReadyMorph(AbilityRange) and
                Player:Buff(S.LunarEmpowerment) then
            return S.LunarStrike:Cast()
        end

        -- Wrath spam
        if S.Wrath:IsReadyMorph(AbilityRange) then return S.Wrath:Cast() end
    else
        -- Moonfire spam on the move
        if S.Moonfire:IsReadyMorph(AbilityRange) then return S.Moonfire:Cast() end
    end

    return nil
end

local function APL()

    if not Player:AffectingCombat() then return 0, 462338 end

    local ShapeshiftStance = {
        Bear = (Player:Buff(S.BearForm)),
        Cat = (Player:Buff(S.CatForm)),
        Travel = (Player:Buff(S.TravelForm)),
        Moonkin = (Player:Buff(S.MoonkinForm)),
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