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

local S = RubimRH.Spell[268]

--- Energy Cap -> Returns true if energy will cap in the next GCD
local function EnergyWillCap()
    return (Player:Energy() + (Player:EnergyRegen() * Player:GCD())) >= 100
end

local function AoE()
    if S.BreathOfFire:IsReady("Melee") then
        return S.BreathOfFire:Cast()
    end

    if S.RushingJadeWind:IsReady(8)
            and not Player:Buff(S.RushingJadeWind) then
        return S.RushingJadeWind:Cast()
    end

    if S.ChiBurst:IsReady(40)
            and RubimRH.lastMoved() >= 1 then
        return S.ChiBurst:Cast()
    end

    if (Player:Buff(S.BlackoutComboBuff) or EnergyWillCap())
            and S.TigerPalm:IsReady("Melee") then
        return S.TigerPalm:Cast()
    end

    if S.BlackoutStrike:IsReady("Melee") then
        return S.BlackoutStrike:Cast()
    end

    if S.ChiWave:IsReady(40) then
        return S.ChiWave:Cast()
    end

    if S.TigerPalm:IsReady("Melee")
            and Player:Energy() >= 55 then
        return S.TigerPalm:Cast()
    end

    if S.RushingJadeWind:IsReady(8) then
        return S.RushingJadeWind:Cast()
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
    if S.LegSweep:IsReady()
            and UseLegSweep then
        return S.LegSweep:Cast()
    elseif UseLegSweep and
            (not S.LegSweep:IsReady()) then
        UseLegSweep = false
    end

    -- Black Ox Statue
    if S.BlackOxStatue:IsReady()
            and UseBlackOxStatue then
        return S.BlackOxStatue:Cast()
    elseif UseBlackOxStatue
            and not S.BlackOxStatue:IsReady() then
        UseBlackOxStatue = false
    end

    -- Kick
    if S.SpearHandStrike:IsReady() and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.SpearHandStrike:Cast()
    elseif UseKick
            and not S.SpearHandStrike:IsReady() then
        UseKick = false
    end

    --- Defensive Rotation
    if S.ExpelHarm:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[268].sk1 then
        return S.ExpelHarm:Cast()
    end

    -- Fortifying Brew
    if S.FortifyingBrew:IsReady()
            and Player:NeedPanicHealing() then
        return S.FortifyingBrew:Cast()
    end

    -- Black Ox Brew
    if S.Brews:ChargesFractional() < 1
            and Player:NeedMajorHealing()
            and S.BlackOxBrew:IsAvailable()
            and S.BlackOxBrew:IsReady() then
        return S.BlackOxBrew:Cast()
    end

    -- Ironskin Brew
    if S.Brews:ChargesFractional() >= 1
            and (not Player:Buff(S.IronskinBrewBuff) or (Player:Buff(S.IronskinBrewBuff) and Player:BuffRemains(S.IronskinBrewBuff) <= Player:GCD()))
            and IsTanking then
        return S.IronskinBrew:Cast()
    end

    -- Purifying Brew
    if (Player:Debuff(S.HeavyStagger) or (Player:Debuff(S.ModerateStagger) and Player:HealthPercentage() < 70))
            and S.Brews:ChargesFractional() >= 1
            and Player:NeedMajorHealing()
            and S.PurifyingBrew:IsReady() then
        return S.PurifyingBrew:Cast()
    end

    -- Healing Elixir
    if Player:HealthPercentage() <= 85
            and S.HealingElixir:IsReady() then
        return S.HealingElixir:Cast()
    end

    -- Guard
    if Player:Debuff(S.HeavyStagger)
            and Player:HealthPercentage() <= 80
            and S.Guard:IsReady() then
        return S.Guard:Cast()
    end

    --- Cooldowns

    -- Blood Fury
    if RubimRH.CDsON()
            and S.BloodFury:IsReady("Melee") then
        return S.BloodFury:ID()
    end

    -- Berserking
    if RubimRH.CDsON()
            and S.Berserking:IsReady("Melee") then
        return S.Berserking:ID()
    end

    -- TODO: Handle proper logic for locating distance to statue
    --    if Cache.EnemiesCount[8] >= 3
    --            and BlackOxStatue:IsReady(8)
    --            and (not Pet:IsActive() or Player:FindRange("pet") > 8) then
    --        return BlackOxStatue:Cast()
    --    end

    --- Universal Rotation - Does not change based on targets

    -- Invoke Niuzao: The Black Ox
    if S.InvokeNiuzaotheBlackOx:IsAvailable()
            and S.InvokeNiuzaotheBlackOx:IsReady(40) then
        return S.InvokeNiuzaotheBlackOx:Cast()
    end

    -- Keg Smash
    if S.KegSmash:IsReady(15) then
        return S.KegSmash:Cast()
    end

    --- AoE Priority
    if Cache.EnemiesCount[8] >= 3
            and AoE() ~= nil then
        return AoE()
    end

    --- Single-Target Priority

    -- Blackout Strike
    if S.BlackoutStrike:IsReady("Melee")
            and (not Player:Buff(S.BlackoutComboBuff) or not S.BlackoutCombo:IsAvailable()) then
        return S.BlackoutStrike:Cast()
    end

    -- Tiger Palm
    if (Player:Buff(S.BlackoutComboBuff) or EnergyWillCap())
            and S.TigerPalm:IsReady("Melee") then
        return S.TigerPalm:Cast()
    end

    -- Breath of Fire
    if S.BreathOfFire:IsReady("Melee") then
        return S.BreathOfFire:Cast()
    end

    -- Rushing Jade Wind
    if S.RushingJadeWind:IsReady(8)
            and not Player:Buff(S.RushingJadeWind) then
        return S.RushingJadeWind:Cast()
    end

    -- Chi Burst
    if S.ChiBurst:IsReady(40)
            and RubimRH.lastMoved() >= 1 then
        return S.ChiBurst:Cast()
    end

    -- Chi Wave
    if S.ChiWave:IsReady(40) then
        return S.ChiWave:Cast()
    end

    -- Tiger Palm
    if S.TigerPalm:IsReady()
            and Player:Energy() >= 55 then
        return S.TigerPalm:Cast()
    end

    -- Rushing Jade Wind -> Refresh on empty GCD
    if S.RushingJadeWind:IsReady() then
        return S.RushingJadeWind:Cast()
    end

    return 0, 135328
end
RubimRH.Rotation.SetAPL(268, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(268, PASSIVE);