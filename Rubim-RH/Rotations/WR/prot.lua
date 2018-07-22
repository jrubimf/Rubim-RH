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
--- Ability declarations
if not Spell.Warrior then
    Spell.Warrior = {};
end
Spell.Warrior.Protection = {
    ArcaneTorrent = Spell(69179),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Shadowmeld = Spell(58984),
    -- Abilities
    BerserkerRage = Spell(18499), -- TODO: Implement cast while feared
    Charge = Spell(100), -- Unused
    DemoralizingShout = Spell(1160),
    Devastate = Spell(20243),
    HeroicLeap = Spell(6544), -- Unused
    HeroicThrow = Spell(57755), -- Unused
    Revenge = Spell(6572),
    RevengeBuff = Spell(5302),
    ShieldSlam = Spell(23922),
    ThunderClap = Spell(6343),
    VictoryRush = Spell(34428),
    Victorious = Spell(32216),
    LastStand = Spell(12975),
    Avatar = Spell(107574),
    BattleShout = Spell(6673),
    -- Talents
    BoomingVoice = Spell(202743),
    ImpendingVictory = Spell(202168),
    Shockwave = Spell(46968),
    CracklingThunder = Spell(203201),
    Vengeance = Spell(202572), -- TODO: See below
    VegeanceIP = Spell(202574), -- TODO: Vengeance logic, currently very weak talent to use
    VegeanceRV = Spell(202573),
    UnstoppableForce = Spell(275336), -- TODO: Implement higher priority Thunderclap during Avatar
    Ravager = Spell(228920),
    Bolster = Spell(280001),
    -- PVP Talents
    ShieldBash = Spell(198912),
    -- Defensive
    IgnorePain = Spell(190456),
    Pummel = Spell(6552), -- TODO: Implement with new Rubim PvP logic
    ShieldBlock = Spell(2565),
    ShieldBlockBuff = Spell(132404)
}
local ProtSpells = Spell.Warrior.Protection;

-- Items : Currently unused
if not Item.Warrior then Item.Warrior = {}; end
Item.Warrior.Protection = {};
local I = Item.Warrior.Protection; -- Unused

local T202PC, T204PC = HL.HasTier("T20"); -- Unused
local T212PC, T214PC = HL.HasTier("T21"); -- Unused

--- Class-specific Spell:CanCast function, spellRage optional
function Spell:CanCast(spellRange, spellRage, playerRage)
    spellRange = spellRange or nil
    spellRage = spellRage or nil
    playerRage = playerRage or 0

    if spellRage then
        return self:IsCastable(spellRange) and playerRage >= spellRage
    else
        return self:IsCastable(spellRange)
    end

end

--- Preliminary APL based on WoWHead Rotation Priority for 8.0.1
-- WoWHead Guide Referenced: http://www.wowhead.com/protection-warrior-rotation-guide
local function APL()
    -- Re-buff when Battle Shout is down
    -- TODO: Need to wait for GGLoader to include this texture
    -- if not Player:Buff(ProtSpells.BattleShout) and ProtSpells.BattleShout:IsReady() then return ProtSpells.BattleShout:Cast() end

    -- Player not in combat
    if not Player:AffectingCombat() then return 0, 462338 end

    -- Update Surrounding Enemies
    HL.GetEnemies("Melee")
    HL.GetEnemies(8, true)
    HL.GetEnemies(10, true)
    HL.GetEnemies(12, true)

    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target) -- TODO: Implement logic for PvP scenarios : IsTanking returns false, yet Shield Block is still needed
    local ThunderClapRadius = ProtSpells.CracklingThunder:IsAvailable() and 12 or 8

    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();

    if LeftCtrl and LeftShift and ProtSpells.Shockwave:IsCastable(8) then
        return ProtSpells.Shockwave:Cast()
    end

    -- SHIELD BLOCK PRIMARY RAGE DUMP
    if ProtSpells.ShieldBlock:IsCastable("Melee")
            and Player:Rage() >= 30
            and not Player:Buff(ProtSpells.ShieldBlockBuff)
            and ((not ProtSpells.Bolster:IsAvailable()) or (ProtSpells.Bolster:IsAvailable() and not Player:Buff(ProtSpells.LastStand)))
            and ProtSpells.ShieldBlock:ChargesFractional() >= 1
            and IsTanking then -- TODO: See IsTanking note
        return ProtSpells.ShieldBlock:Cast()
    end

    if ProtSpells.Avatar:IsCastable("Melee")
            and Target:TimeToDie() >= 10
            and Player:RageDeficit() >= 20 then
        return ProtSpells.Avatar:Cast()
    end

    -- PvP Shield Bash
    if ProtSpells.ShieldBash:IsCastable("Melee")
            and Target:IsCasting() then
        return ProtSpells.ShieldBash:Cast()
    end

    -- USE ON COOLDOWN WITH BOOMING VOICE
    if ((ProtSpells.BoomingVoice:IsAvailable() and Player:Rage() <= 60) or Cache.EnemiesCount[ThunderClapRadius] >= 3)
            and ProtSpells.DemoralizingShout:IsCastable("Melee") then
        return ProtSpells.DemoralizingShout:Cast()
    end

    if ProtSpells.ShieldSlam:IsCastable("Melee")
            and Player:RageDeficit() >= 15 then
        return ProtSpells.ShieldSlam:Cast()
    end

    if ProtSpells.ThunderClap:IsCastable(ThunderClapRadius)
            and Player:RageDeficit() >= 5 then
        return ProtSpells.ThunderClap:Cast()
    end

    -- Revenge Rage Dump
    local RevengeDumpRage = ProtSpells.BoomingVoice:IsAvailable() and 60 or 80
    if ProtSpells.Revenge:IsCastable("Melee")
            and (((Player:Rage() >= RevengeDumpRage) or Player:Buff(ProtSpells.RevengeBuff))
            or (ProtSpells.Revenge:IsCastable("Melee") and ProtSpells.Vengeance:IsAvailable() and Player:Buff(ProtSpells.VegeanceRV) and Player:Rage() >= 20)) then
        return ProtSpells.Revenge:Cast()
    end

    if ProtSpells.ImpendingVictory:IsCastable("Melee")
            and Player:HealthPercentage() <= 85 then
        return ProtSpells.VictoryRush:Cast()
    end

    if Player:Buff(ProtSpells.Victorious)
            and ProtSpells.VictoryRush:IsCastable("Melee")
            and Player:HealthPercentage() <= 85 then
        return ProtSpells.VictoryRush:Cast()
    end

    if ProtSpells.Ravager:IsCastable("Melee")
            and Cache.EnemiesCount[8] >= 3 then
        return ProtSpells.Ravager:Cast()
    end

    if ProtSpells.ShieldBash:IsCastable("Melee") then
        return ProtSpells.ShieldBash:Cast()
    end

    if Player:Buff(ProtSpells.VegeanceIP)
            and Player:Rage() >= ((40 / 3) * 2)
            and not Player:Buff(ProtSpells.IgnorePain) then
        return ProtSpells.IgnorePain:Cast()
    end

    if ProtSpells.Revenge:IsCastable("Melee")
            and ProtSpells.ShieldBlock:ChargesFractional() < 0.6
            and Player:Rage() >= 30 then
        return ProtSpells.Revenge:Cast()
    end

    if Player:Buff(ProtSpells.Victorious)
            and Player:BuffRemains(ProtSpells.Victorious) <= 2
            and ProtSpells.VictoryRush:IsCastable("Melee") then
        return ProtSpells.VictoryRush:Cast()
    end

    if ProtSpells.IgnorePain:IsCastable("Melee")
            and Player:Rage() >= 40
            and not Player:Buff(ProtSpells.IgnorePain)
            and IsTanking then -- TODO: See IsTanking note
        return ProtSpells.IgnorePain:Cast()
    end

    if ProtSpells.Devastate:IsCastable("Melee") then
        return ProtSpells.Devastate:Cast()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(73, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(73, PASSIVE);