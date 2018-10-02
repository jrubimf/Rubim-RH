--- Last Edit: Bishop - 7/20/18
--- BfA Protection Warrior v1.0.2

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

RubimRH.Spell[73] = {
    ArcaneTorrent = Spell(69179),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Shadowmeld = Spell(58984),
    -- Abilities
    BerserkerRage = Spell(18499),
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
    Vengeance = Spell(202572),
    VegeanceIP = Spell(202574),
    VegeanceRV = Spell(202573),
    UnstoppableForce = Spell(275336),
    Ravager = Spell(228920),
    Bolster = Spell(280001),
    -- PVP Talents
    ShieldBash = Spell(198912),
    -- Defensive
    IgnorePain = Spell(190456),
    Pummel = Spell(6552),
    ShieldBlock = Spell(2565),
    ShieldBlockBuff = Spell(132404),
    ShieldWall = Spell(871),
    Taunt = Spell(355),
    Opressor = Spell(205800),
    Intimidated = Spell(206891),
}


local S = RubimRH.Spell[73]

--- Preliminary APL based on WoWHead Rotation Priority for 8.0.1
-- WoWHead Guide Referenced: http://www.wowhead.com/protection-warrior-rotation-guide
local function APL()
    -- Battle Shout -> Re-buff when down
    -- TODO: Need to wait for GGLoader to include this texture
    -- if not Player:Buff(ProtSpells.BattleShout) and ProtSpells.BattleShout:IsReady() then return ProtSpells.BattleShout:Cast() end

    -- Player not in combat
    if not Player:AffectingCombat() then
        if S.BattleShout:IsCastable() and not Player:BuffPvP(S.BattleShout) then
            return S.BattleShout:Cast()
        end
        return 0, 462338
    end

    if QueueSkill() ~= nil then
        return QueueSkill()
    end

    -- Update Surrounding Enemies
    HL.GetEnemies("Melee")
    HL.GetEnemies(8, true)
    HL.GetEnemies(10, true)
    HL.GetEnemies(12, true)

    -- Localize Vars
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target) -- TODO: Implement logic for PvP scenarios : IsTanking returns false, yet Shield Block is still needed
    local ThunderClapRadius = S.CracklingThunder:IsAvailable() and 12 or 8

    local LeftCtrl = IsLeftControlKeyDown()
    local LeftShift = IsLeftShiftKeyDown()

    -- Shovkwave -> Cast when left CTRL+Shift keys are pressed
    if LeftCtrl and LeftShift and S.Shockwave:IsReady(8) then
        return S.Shockwave:Cast()
    end

    -- Pummel -> 0.5 sec of cast has elapsed, or 1 second of channeling has elapsed
    if S.Pummel:IsReady() and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.Pummel:Cast()
    end

    if S.BattleShout:IsCastable() and not Player:BuffPvP(S.BattleShout) then
        return S.BattleShout:Cast()
    end

    if Player:NeedThreat() and S.ThunderClap:IsReady() and Cache.EnemiesCount[8] >= 1 then
        return S.ThunderClap:Cast()
    end

    if Player:NeedThreat() and S.Revenge:IsReady() and Cache.EnemiesCount[8] >= 1 then
        return S.Revenge:Cast()
    end

    -- Shield Bash -> PvP usage
    if S.ShieldBash:IsReady("Melee")
            and Target:IsCasting() then
        return S.ShieldBash:Cast()
    end
    -- TODO: Berserker Rage: Implement cast while feared.

    -- Shield Wall -> Panic Heal
    if S.ShieldWall:IsCastable("Melee")
            and ((Player:IncDmgPercentage() > RubimRH.db.profile[73].sk2 or Player:HealthPercentage() <= 85) or (Player:IncDmgPercentage() > RubimRH.db.profile[73].sk3 or Player:HealthPercentage() <= 85))
            and (S.Bolster:IsAvailable() and (not Player:Buff((S).LastStand))) then
        return S.ShieldWall:Cast()
    end

    -- Last Stand -> Panic Heal
    if S.LastStand:IsCastable("Melee")
            and ((Player:IncDmgPercentage() > RubimRH.db.profile[73].sk3 or Player:HealthPercentage() <= 85) or (Player:IncDmgPercentage() > RubimRH.db.profile[73].sk2 or Player:HealthPercentage() <= 85))
            and (not Player:Buff(S.ShieldWall)) then
        return S.LastStand:Cast()
    end

    -- Shield Block -> Primary rage dump
    if S.ShieldBlock:IsCastable("Melee")
            and Player:Rage() >= 30
            and not Player:Buff(S.ShieldBlockBuff)
            and ((not S.Bolster:IsAvailable())
            or (S.Bolster:IsAvailable() and not Player:Buff(S.LastStand)))
            and S.ShieldBlock:ChargesFractional() >= 1
            and ((Player:IncDmgPercentage() > RubimRH.db.profile[73].sk1 or Player:HealthPercentage() <= 85)
            or (Player:IncDmgPercentage() > RubimRH.db.profile[73].sk2 or Player:HealthPercentage() <= 85)
            or (Player:IncDmgPercentage() > RubimRH.db.profile[73].sk3 or Player:HealthPercentage() <= 85)) then
        return S.ShieldBlock:Cast()
    end

    -- Avatar -> Cast when not in a group (solo conent), Target TTD >= 10, and we're at >= 20 rage deficit
    if S.Avatar:IsCastable("Melee")
            and ((Target:TimeToDie() >= 10) or (GetNumGroupMembers() == 0)) -- Use all the time in solo content
            and Player:RageDeficit() >= 20 then
        return S.Avatar:Cast()
    end

    -- Demoralizing Shout -> Use on CD with Boomking Shout
    if ((S.BoomingVoice:IsCastable() and Player:Rage() <= 60)
            or (Cache.EnemiesCount[ThunderClapRadius] >= 3)
            or (GetNumGroupMembers() == 0))
            and S.DemoralizingShout:IsReady("Melee") then
        return S.DemoralizingShout:Cast()
    end

    -- Impending Victory -> Cast when < 85% HP
    if S.ImpendingVictory:IsReady("Melee")
            and Player:HealthPercentage() <= 85 then
        return S.VictoryRush:Cast()
    end

    -- Victory Rush -> Cast when < 85% HP
    if Player:Buff(S.Victorious)
            and S.VictoryRush:IsReady("Melee")
            and Player:HealthPercentage() <= 85 then
        return S.VictoryRush:Cast()
    end

    if S.Revenge:IsReady("Melee")
            and Player:RageDeficit() <= 15 then
        return S.Revenge:Cast()
    end

    -- Shield Slam
    if S.ShieldSlam:IsReady("Melee")
            and Player:RageDeficit() >= 15 then
        return S.ShieldSlam:Cast()
    end

    -- ThunderClap
    if S.ThunderClap:IsReady() and Player:RageDeficit() >= 5 and Cache.EnemiesCount[8] >= 1 then
        return S.ThunderClap:Cast()
    end

    -- Revenge Rage Dump
    local RevengeDumpRage = S.BoomingVoice:IsAvailable() and 60 or 80
    if S.Revenge:IsReady("Melee")
            and (((Player:Rage() >= RevengeDumpRage)
            or Player:Buff(S.RevengeBuff))
            or (S.Revenge:IsReady("Melee") and Player:Buff(S.VegeanceRV) and Player:Rage() >= 20)) then
        return S.Revenge:Cast()
    end

    -- Ravager -> AoE scenarios
    if S.Ravager:IsReady("Melee")
            and Cache.EnemiesCount[8] >= 3 then
        return S.Ravager:Cast()
    end

    -- Shield Bash -> Target not casting / lower priority
--    if S.ShieldBash:IsReady("Melee") then
--        return S.ShieldBash:Cast()
    --end

    -- Ignore Pain -> Vengeance Ignore Pain
    if S.IgnorePain:IsCastable("Melee")
            and Player:Buff(S.VegeanceIP)
            and Player:Rage() >= ((40 / 3) * 2)
            and not Player:Buff(S.IgnorePain) then
        return S.IgnorePain:Cast()
    end

    -- Revenge -> Rage dump
    if S.Revenge:IsReady("Melee")
            and S.ShieldBlock:ChargesFractional() < 0.6
            and Player:Rage() >= 30 then
        return S.Revenge:Cast()
    end

    -- Victory Rush -> Buff about to expire
    if Player:Buff(S.Victorious)
            and Player:BuffRemains(S.Victorious) <= 2
            and S.VictoryRush:IsReady("Melee") then
        return S.VictoryRush:Cast()
    end

    -- Ignore Pain -> Only cast in place of Devastate
    if S.IgnorePain:IsCastable("Melee")
            and Player:Rage() >= 40
            and not Player:Buff(S.IgnorePain)
            and ((Player:IncDmgPercentage() > RubimRH.db.profile[73].sk1 or Player:HealthPercentage() <= 85) or (Player:IncDmgPercentage() > RubimRH.db.profile[73].sk2 or Player:HealthPercentage() <= 85)) then
        -- TODO: See IsTanking note
        return S.IgnorePain:Cast()
    end

    if S.Devastate:IsReady("Melee") then
        return S.Devastate:Cast()
    end

    return 0, 135328
end
RubimRH.Rotation.SetAPL(73, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(73, PASSIVE);