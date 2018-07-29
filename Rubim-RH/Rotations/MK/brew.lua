--- Last Edit: Bishop : 7/21/18
--- BfA Brewmaster v1.0.2
local addonName, addonTable = ...
-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell = HL.Spell

-- Macro Settings
UseBlackOxStatue = false
UseLegSweep = false
UseKick = false

local ISpell = RubimRH.Spell[268]

--- Energy Cap -> Returns true if energy will cap in the next GCD
local function EnergyWillCap()
    return (Player:Energy() + (Player:EnergyRegen() * Player:GCD())) >= 100
end


local function AoE()
    if ISpell.BreathOfFire:IsReady("Melee") then
        return ISpell.BreathOfFire:Cast()
    end

    if ISpell.RushingJadeWind:IsReady(8)
        and not Player:Buff(ISpell.RushingJadeWind) then
        return ISpell.RushingJadeWind:Cast()
    end

    if ISpell.ChiBurst:IsReady(40)
        and RubimRH.lastMoved() >= 1 then
        return ISpell.ChiBurst:Cast()
    end

    if (Player:Buff(ISpell.BlackoutComboBuff) or EnergyWillCap())
        and ISpell.TigerPalm:IsReady("Melee") then
        return ISpell.TigerPalm:Cast()
    end

    if ISpell.BlackoutStrike:IsReady("Melee") then
        return ISpell.BlackoutStrike:Cast()
    end

    if ISpell.ChiWave:IsReady(40) then
        return ISpell.ChiWave:Cast()
    end

    if ISpell.TigerPalm:IsReady("Melee")
        and Player:Energy() >= 55 then
        return ISpell.TigerPalm:Cast()
    end

    if ISpell.RushingJadeWind:IsReady(8) then
        return ISpell.RushingJadeWind:Cast()
    end

    return nil
end

--- Preliminary APL based on Peak of Serenity Rotation Priority for 8.0.1
-- Guide Referenced: http://www.peakofserenity.com/bfa/brewmaster/guide/
local function APL()

    --- Not in combat
    if not Player:AffectingCombat() then
        return 0, 462338
    end

    -- Unit Update
    HL.GetEnemies(8, true);
    HL.GetEnemies(15, true);
    HL.GetEnemies(40, true);

    -- Misc
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target)

    --- Player Macro Options

    -- Leg Sweep
    if ISpell.LegSweep:IsReady()
        and UseLegSweep then
        return ISpell.LegSweep:Cast()
    elseif UseLegSweep and 
        (not ISpell.LegSweep:IsReady()) then
        UseLegSweep = false
    end

    -- Black Ox Statue
    if ISpell.BlackOxStatue:IsReady()
        and UseBlackOxStatue then
        return ISpell.BlackOxStatue:Cast()
    elseif UseBlackOxStatue
        and not ISpell.BlackOxStatue:IsReady() then
        UseBlackOxStatue = false
    end

    -- Kick
    if ISpell.SpearHandStrike:IsReady("Melee")
        and ((Target:IsInterruptible()
        and Target:CastRemains() <= 0.5) or UseKick) then
        return ISpell.SpearHandStrike:Cast()
    elseif UseKick 
        and not ISpell.SpearHandStrike:IsReady() then
        UseKick = false
    end

    --- Defensive Rotation

    -- Fortifying Brew
    if ISpell.FortifyingBrew:IsReady()
        and NeedPanicHealing() then
        return ISpell.FortifyingBrew:Cast()
    end

    -- Black Ox Brew
    if ISpell.Brews:ChargesFractional() < 1
        and NeedMajorHealing()
        and ISpell.BlackOxBrew:IsAvailable()
        and ISpell.BlackOxBrew:IsReady() then
        return ISpell.BlackOxBrew:Cast()
    end

    -- Ironskin Brew
    if ISpell.Brews:ChargesFractional() >= 1
        and (not Player:Buff(ISpell.IronskinBrewBuff) or (Player:Buff(ISpell.IronskinBrewBuff) and Player:BuffRemains(ISpell.IronskinBrewBuff) <= Player:GCD()))
        and IsTanking then
        return ISpell.IronskinBrew:Cast()
    end

    -- Purifying Brew
    if (Player:Debuff(ISpell.HeavyStagger) or (Player:Debuff(ISpell.ModerateStagger) and Player:HealthPercentage() < 70))
        and ISpell.Brews:ChargesFractional() >= 1
        and NeedMajorHealing() then
        return ISpell.PurifyingBrew:Cast()
    end

    -- Healing Elixir
    if Player:HealthPercentage() <= 85
        and ISpell.HealingElixir:IsReady() then
        return ISpell.HealingElixir:Cast()
    end

    -- Guard
    if Player:Debuff(ISpell.HeavyStagger)
        and Player:HealthPercentage() <= 80
        and ISpell.Guard:IsReady() then
        return ISpell.Guard:Cast()
    end

    --- Cooldowns

    -- Blood Fury
    if RubimRH.CDsON()
        and ISpell.BloodFury:IsReady("Melee") then
        return ISpell.BloodFury:ID()
    end

    -- Berserking
    if RubimRH.CDsON()
        and ISpell.Berserking:IsReady("Melee") then
        return ISpell.Berserking:ID()
    end

    -- TODO: Handle proper logic for locating distance to statue
    --    if Cache.EnemiesCount[8] >= 3
    --            and BlackOxStatue:IsReady(8)
    --            and (not Pet:IsActive() or Player:FindRange("pet") > 8) then
    --        return BlackOxStatue:Cast()
    --    end

    --- Universal Rotation - Does not change based on targets

    -- Invoke Niuzao: The Black Ox
    if ISpell.InvokeNiuzaotheBlackOx:IsAvailable()
        and ISpell.InvokeNiuzaotheBlackOx:IsReady(40) then
        return ISpell.InvokeNiuzaotheBlackOx:Cast()
    end

    -- Keg Smash
    if ISpell.KegSmash:IsReady(15) then
        return ISpell.KegSmash:Cast()
    end

    --- AoE Priority
    if Cache.EnemiesCount[8] >= 3
        and AoE() ~= nil then
        return AoE()
    end

    --- Single-Target Priority

    -- Blackout Strike
    if ISpell.BlackoutStrike:IsReady("Melee")
        and (not Player:Buff(ISpell.BlackoutComboBuff) or not ISpell.BlackoutCombo:IsAvailable()) then
        return ISpell.BlackoutStrike:Cast()
    end

    -- Tiger Palm
    if (Player:Buff(ISpell.BlackoutComboBuff) or EnergyWillCap())
        and ISpell.TigerPalm:IsReady("Melee") then
        return ISpell.TigerPalm:Cast()
    end

    -- Breath of Fire
    if ISpell.BreathOfFire:IsReady("Melee") then
        return ISpell.BreathOfFire:Cast()
    end

    -- Rushing Jade Wind
    if ISpell.RushingJadeWind:IsReady(8)
        and not Player:Buff(ISpell.RushingJadeWind) then
        return ISpell.RushingJadeWind:Cast()
    end

    -- Chi Burst
    if ISpell.ChiBurst:IsReady(40)
        and RubimRH.lastMoved() >= 1 then
        return ISpell.ChiBurst:Cast()
    end

    -- Chi Wave
    if ISpell.ChiWave:IsReady(40) then
        return ISpell.ChiWave:Cast()
    end

    -- Tiger Palm
    if ISpell.TigerPalm:IsReady()
        and Player:Energy() >= 55 then
        return ISpell.TigerPalm:Cast()
    end

    -- Rushing Jade Wind -> Refresh on empty GCD
    if ISpell.RushingJadeWind:IsReady() then
        return ISpell.RushingJadeWind:Cast()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(268, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(268, PASSIVE);