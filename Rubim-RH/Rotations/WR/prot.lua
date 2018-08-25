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

local ISpell = RubimRH.Spell[73]

local OffensiveCDs = {
    ISpell.Avatar,
    ISpell.ShieldWall,
    ISpell.LastStand,
}

local function UpdateCDs()
    if RubimRH.CDsON() then
        for i, spell in pairs(OffensiveCDs) do
            if not spell:IsEnabledCD() then
                RubimRH.delSpellDisabledCD(spell:ID())
            end
        end

    end
    if not RubimRH.CDsON() then
        for i, spell in pairs(OffensiveCDs) do
            if spell:IsEnabledCD() then
                RubimRH.addSpellDisabledCD(spell:ID())
            end
        end
    end
end

--- Preliminary APL based on WoWHead Rotation Priority for 8.0.1
-- WoWHead Guide Referenced: http://www.wowhead.com/protection-warrior-rotation-guide
local function APL()
    -- Battle Shout -> Re-buff when down
    -- TODO: Need to wait for GGLoader to include this texture
    -- if not Player:Buff(ProtSpells.BattleShout) and ProtSpells.BattleShout:IsReady() then return ProtSpells.BattleShout:Cast() end

    -- Player not in combat
    UpdateCDs()
    if not Player:AffectingCombat() then
        return 0, 462338
    end

    if Target:Exists()
            and Player:CanAttack(Unit("target")) then

        -- Update Surrounding Enemies
        HL.GetEnemies("Melee")
        HL.GetEnemies(8, true)
        HL.GetEnemies(10, true)
        HL.GetEnemies(12, true)

        -- Localize Vars
        local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target) -- TODO: Implement logic for PvP scenarios : IsTanking returns false, yet Shield Block is still needed
        local ThunderClapRadius = ISpell.CracklingThunder:IsAvailable() and 12 or 8

        local LeftCtrl = IsLeftControlKeyDown()
        local LeftShift = IsLeftShiftKeyDown()

        -- Shovkwave -> Cast when left CTRL+Shift keys are pressed
        if LeftCtrl and LeftShift and ISpell.Shockwave:IsReady(8) then
            return ISpell.Shockwave:Cast()
        end

        -- Pummel -> 0.5 sec of cast has elapsed, or 1 second of channeling has elapsed
        if ISpell.Pummel:IsReady("Melee")
                and RubimRH.InterruptsON()
                and Target:IsInterruptible()
                and (((Target:IsCasting() and Target:CastRemains() <= 0.7) or Target:IsChanneling())) then
            return ISpell.Pummel:Cast()
        end

        -- TODO: Berserker Rage: Implement cast while feared.

        -- Shield Wall -> Panic Heal
        if ISpell.ShieldWall:IsReady("Melee")
                and (Player:NeedMajorHealing() or Player:NeedPanicHealing())
                and (ISpell.Bolster:IsAvailable() and (not Player:Buff(ISpell.LastStand))) then
            return ISpell.ShieldWall:Cast()
        end

        -- Last Stand -> Panic Heal
        if ISpell.LastStand:IsReady("Melee")
                and (Player:NeedPanicHealing() or Player:NeedMajorHealing())
                and (not Player:Buff(ISpell.ShieldWall)) then
            return ISpell.LastStand:Cast()
        end

        -- Shield Block -> Primary rage dump
        if ISpell.ShieldBlock:IsReady("Melee")
                and Player:Rage() >= 30
                and not Player:Buff(ISpell.ShieldBlockBuff)
                and ((not ISpell.Bolster:IsAvailable())
                or (ISpell.Bolster:IsAvailable() and not Player:Buff(ISpell.LastStand)))
                and ISpell.ShieldBlock:ChargesFractional() >= 1
                and (Player:NeedMinorHealing()
                or Player:NeedMajorHealing()
                or Player:NeedPanicHealing()) then
            return ISpell.ShieldBlock:Cast()
        end

        -- Avatar -> Cast when not in a group (solo conent), Target TTD >= 10, and we're at >= 20 rage deficit
        if ISpell.Avatar:IsReady("Melee")
                and ((Target:TimeToDie() >= 10) or (GetNumGroupMembers() == 0)) -- Use all the time in solo content
                and Player:RageDeficit() >= 20 then
            return ISpell.Avatar:Cast()
        end

        -- Shield Bash -> PvP usage
        if ISpell.ShieldBash:IsReady("Melee")
                and Target:IsCasting() then
            return ISpell.ShieldBash:Cast()
        end

        -- Demoralizing Shout -> Use on CD with Boomking Shout
        if ((ISpell.BoomingVoice:IsAvailable() and Player:Rage() <= 60)
                or (Cache.EnemiesCount[ThunderClapRadius] >= 3)
                or (GetNumGroupMembers() == 0))
                and ISpell.DemoralizingShout:IsReady("Melee") then
            return ISpell.DemoralizingShout:Cast()
        end

        -- Impending Victory -> Cast when < 85% HP
        if ISpell.ImpendingVictory:IsReady("Melee")
                and Player:HealthPercentage() <= 85 then
            return ISpell.VictoryRush:Cast()
        end

        -- Victory Rush -> Cast when < 85% HP
        if Player:Buff(ISpell.Victorious)
                and ISpell.VictoryRush:IsReady("Melee")
                and Player:HealthPercentage() <= 85 then
            return ISpell.VictoryRush:Cast()
        end

        -- Shield Slam
        if ISpell.ShieldSlam:IsReady("Melee")
                and Player:RageDeficit() >= 15 then
            return ISpell.ShieldSlam:Cast()
        end

        -- ThunderClap
        if ISpell.ThunderClap:IsReady() and Player:RageDeficit() >= 5 and Cache.EnemiesCount[8] >= 1 then
            return ISpell.ThunderClap:Cast()
        end

        -- Revenge Rage Dump
        local RevengeDumpRage = ISpell.BoomingVoice:IsAvailable() and 60 or 80
        if ISpell.Revenge:IsReady("Melee")
                and (((Player:Rage() >= RevengeDumpRage)
                or Player:Buff(ISpell.RevengeBuff))
                or (ISpell.Revenge:IsReady("Melee") and Player:Buff(ISpell.VegeanceRV) and Player:Rage() >= 20)) then
            return ISpell.Revenge:Cast()
        end

        -- Ravager -> AoE scenarios
        if ISpell.Ravager:IsReady("Melee")
                and Cache.EnemiesCount[8] >= 3 then
            return ISpell.Ravager:Cast()
        end

        -- Shield Bash -> Target not casting / lower priority
        if ISpell.ShieldBash:IsReady("Melee") then
            return ISpell.ShieldBash:Cast()
        end

        -- Ignore Pain -> Vengeance Ignore Pain
        if ISpell.IgnorePain:IsReady("Melee")
                and Player:Buff(ISpell.VegeanceIP)
                and Player:Rage() >= ((40 / 3) * 2)
                and not Player:Buff(ISpell.IgnorePain) then
            return ISpell.IgnorePain:Cast()
        end

        -- Revenge -> Rage dump
        if ISpell.Revenge:IsReady("Melee")
                and ISpell.ShieldBlock:ChargesFractional() < 0.6
                and Player:Rage() >= 30 then
            return ISpell.Revenge:Cast()
        end

        -- Victory Rush -> Buff about to expire
        if Player:Buff(ISpell.Victorious)
                and Player:BuffRemains(ISpell.Victorious) <= 2
                and ISpell.VictoryRush:IsReady("Melee") then
            return ISpell.VictoryRush:Cast()
        end

        -- Ignore Pain -> Only cast in place of Devastate
        if ISpell.IgnorePain:IsReady("Melee")
                and Player:Rage() >= 40
                and not Player:Buff(ISpell.IgnorePain)
                and (Player:NeedMinorHealing() or Player:NeedMajorHealing()) then
            -- TODO: See IsTanking note
            return ISpell.IgnorePain:Cast()
        end

        if ISpell.Devastate:IsReady("Melee") then
            return ISpell.Devastate:Cast()
        end
    end

    return 0, 135328
end
RubimRH.Rotation.SetAPL(73, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(73, PASSIVE);