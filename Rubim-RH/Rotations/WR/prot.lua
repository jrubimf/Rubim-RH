--- Last Edit: Bishop - 7/20/18
--- Version: BFA-1.0.0

--- Localize Vars
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
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

--- Spells

-- Racials
local ArcaneTorrent = Spell(69179)
local Berserking = Spell(26297)
local BloodFury = Spell(20572)
local Shadowmeld = Spell(58984)
-- Abilities
local BerserkerRage = Spell(18499) -- TODO: Implement cast while feared
local Charge = Spell(100) -- Unused
local DemoralizingShout = Spell(1160)
local Devastate = Spell(20243)
local HeroicLeap = Spell(6544) -- Unused
local HeroicThrow = Spell(57755) -- Unused
local Revenge = Spell(6572)
local RevengeBuff = Spell(5302)
local ShieldSlam = Spell(23922)
local ThunderClap = Spell(6343)
local VictoryRush = Spell(34428)
local Victorious = Spell(32216)
local LastStand = Spell(12975)
local Avatar = Spell(107574)
local BattleShout = Spell(6673)
-- Talents
local BoomingVoice = Spell(202743)
local ImpendingVictory = Spell(202168)
local Shockwave = Spell(46968)
local CracklingThunder = Spell(203201)
local Vengeance = Spell(202572) -- TODO: See below
local VegeanceIP = Spell(202574) -- TODO: Vengeance logic, currently very weak talent to use
local VegeanceRV = Spell(202573)
local UnstoppableForce = Spell(275336) -- TODO: Implement higher priority Thunderclap during Avatar
local Ravager = Spell(228920)
-- PVP Talents
local ShieldBash = Spell(198912)
-- Defensive
local IgnorePain = Spell(190456)
local LastStand = Spell(12975)
local Pummel = Spell(6552) -- TODO: Implement with new Rubim PvP logic
local ShieldBlock = Spell(2565)
local ShieldBlockBuff = Spell(132404)

-- Items : Currentl unused
if not Item.Warrior then Item.Warrior = {}; end
Item.Warrior.Protection = {};
local I = Item.Warrior.Protection; -- Unused

local T202PC, T204PC = HL.HasTier("T20"); -- Unused
local T212PC, T214PC = HL.HasTier("T21"); -- Unused

--- Class-specific Spell:CanCast function, spellRage optional
function Spell:CanCast(spellRange, spellRage)
    spellRange = spellRange or 0
    spellRage = spellRage or 0

    return self:IsCastable(spellRange) and (Player:Rage() >= spellRage)
end

--- Preliminary APL based on WoWHead Rotation Priority for 8.0.1
-- WoWHead Guide Referenced: http://www.wowhead.com/protection-warrior-rotation-guide
local function APL()
    -- Re-buff when Battle Shout is down
    -- TODO: Need to wait for GGLoader to include this texture
    -- if not Player:Buff(BattleShout) and BattleShout:IsReady() then return BattleShout:Cast() end

    -- Player not in combat
    if not Player:AffectingCombat() then return 0, 462338 end

    -- Update Surrounding Enemies
    HL.GetEnemies("Melee")
    HL.GetEnemies(8, true)
    HL.GetEnemies(10, true)
    HL.GetEnemies(12, true)

    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target) -- TODO: Implement logic for PvP scenarios : IsTanking returns false, yet Shield Block is still needed
    local ThunderClapRadius = CracklingThunder:IsAvailable() and 12 or 8

    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();

    if LeftCtrl and LeftShift and Shockwave:CanCast(8) then
        return Shockwave:Cast()
    end

    -- SHIELD BLOCK PRIMARY RAGE DUMP
    if ShieldBlock:CanCast("Melee", 30)
            and not Player:Buff(ShieldBlockBuff)
            and not Player:Buff(LastStand)
            and ShieldBlock:ChargesFractional() >= 1
            and IsTanking then
        return ShieldBlock:Cast()
    end

    if Avatar:CanCast("Melee")
            and Target:TimeToDie() >= 10
            and Player:RageDeficit() >= 20 then
        return Avatar:Cast()
    end

    -- USE ON COOLDOWN WITH BOOMING VOICE
    if ((BoomingVoice:IsAvailable() and Player:Rage() <= 60) or Cache.EnemiesCount[ThunderClapRadius] >= 3)
            and DemoralizingShout:CanCast("Melee") then
        return DemoralizingShout:Cast()
    end

    if ShieldSlam:CanCast("Melee")
            and Player:RageDeficit() >= 15 then
        return ShieldSlam:Cast()
    end

    if ThunderClap:CanCast(ThunderClapRadius)
            and Player:RageDeficit() >= 5 then
        return ThunderClap:Cast()
    end

    -- Revenge Rage Dump
    local RevengeDumpRage = BoomingVoice:IsAvailable() and 60 or 80
    if Revenge:CanCast("Melee", RevengeDumpRage) or Player:Buff(RevengeBuff) then
        return Revenge:Cast()
    end

    if ImpendingVictory:CanCast("Melee")
            and Player:HealthPercentage() <= 85 then
        return VictoryRush:Cast()
    end

    if Player:Buff(Victorious)
            and VictoryRush:CanCast("Melee")
            and Player:HealthPercentage() <= 85 then
        return VictoryRush:Cast()
    end

    -- PvP Shield Bash
    if ShieldBash:CanCast("Melee")
            and Target:IsCasting() then
        return ShieldBash:Cast()
    end

    -- TODO: Re-work Vengeance Logic for proper Revenge/Ignore Pain usage
    if Player:Buff(VegeanceRV)
            and Player:Rage() >= 20
            and (Player:Buff(ShieldBlockBuff) and Player:BuffRemains(ShieldBlockBuff) >= Player:GCD() and ShieldBlock:CanCast("Melee", 30))
            and Revenge:CanCast("Melee") then
        return Revenge:Cast()
    end

    if Ravager:CanCast("Melee")
            and Cache.EnemiesCount[8] >= 3 then
        return Ravager:Cast()
    end

    if ShieldBash:CanCast("Melee") then
        return ShieldBash:Cast()
    end

    if Player:Buff(VegeanceIP)
            and Player:Rage() >= ((40 / 3) * 2)
            and not Player:Buff(IgnorePain) then
        return IgnorePain:Cast()
    end

    if Revenge:CanCast("Melee", 30) and
            ShieldBlock:ChargesFractional() < 0.6 then
        return Revenge:Cast()
    end

    if Player:Buff(Victorious)
            and Player:BuffRemains(Victorious) <= 2
            and VictoryRush:CanCast("Melee") then
        return VictoryRush:Cast()
    end

    if IgnorePain:CanCast("Melee", 40)
            and not Player:Buff(IgnorePain)
            and IsTanking then
        return IgnorePain:Cast()
    end

    if Devastate:CanCast("Melee") then
        return Devastate:Cast()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(73, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(73, PASSIVE);