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

local BrewSpells = RubimRH.Spell[268]

--- Returns if energy will cap within the next GCD
local function EnergyWillCap()
    return (Player:Energy() + (Player:EnergyRegen() * Player:GCDRemains())) >= 100
end

local function AoE()
    if BrewSpells.BreathOfFire:IsReady("Melee") then
        return BrewSpells.BreathOfFire:Cast()
    end

    if BrewSpells.RushingJadeWind:IsReady(8)
            and not Player:Buff(BrewSpells.RushingJadeWind) then
        return BrewSpells.RushingJadeWind:Cast()
    end

    if BrewSpells.ChiBurst:IsReady(40)
            and RubimRH.lastMoved() >= 1 then
        return BrewSpells.ChiBurst:Cast()
    end

    if (Player:Buff(BrewSpells.BlackoutComboBuff) or EnergyWillCap())
            and BrewSpells.TigerPalm:IsReady("Melee") then
        return BrewSpells.TigerPalm:Cast()
    end

    if BrewSpells.BlackoutStrike:IsReady("Melee") then
        return BrewSpells.BlackoutStrike:Cast()
    end

    if BrewSpells.ChiWave:IsReady(40) then
        return BrewSpells.ChiWave:Cast()
    end

    if BrewSpells.TigerPalm:IsReady("Melee")
            and Player:Energy() >= 55 then
        return BrewSpells.TigerPalm:Cast()
    end

    if BrewSpells.RushingJadeWind:IsReady(8) then
        return BrewSpells.RushingJadeWind:Cast()
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

    -- Misc
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target)

    -- Kick
    if BrewSpells.SpearHandStrike:IsReady("Melee")
            and Target:IsInterruptible()
            and Target:CastRemains() <= 0.5 then
        return BrewSpells.SpearHandStrike:Cast()
    end

    --- Defensive Rotation

    if BrewSpells.Brews:ChargesFractional() <= 1
            and BrewSpells.BlackOxBrew:IsAvailable()
            and BrewSpells.BlackOxBrew:IsReady() then
        return BrewSpells.BlackOxBrew:Cast()
    end

    if BrewSpells.Brews:ChargesFractional() >= 1
            and (not Player:Buff(BrewSpells.IronskinBrewBuff) or (Player:Buff(BrewSpells.IronskinBrewBuff) and Player:BuffRemains(BrewSpells.IronskinBrewBuff) <= Player:GCD()))
            and IsTanking then
        return BrewSpells.IronskinBrew:Cast()
    end

    if Player:Debuff(BrewSpells.HeavyStagger)
            and Player:Buff(BrewSpells.IronskinBrewBuff)
            and Player:BuffRemains(BrewSpells.IronskinBrewBuff) > Player:GCD() * 2
            and IsTanking then
        return BrewSpells.PurifyingBrew:Cast()
    end

    if Player:HealthPercentage() <= 85
            and BrewSpells.HealingElixir:IsReady() then
        return BrewSpells.HealingElixir:Cast()
    end

    if Player:Debuff(BrewSpells.HeavyStagger)
            and Player:HealthPercentage() <= 80
            and BrewSpells.Guard:IsReady() then
        return BrewSpells.Guard:Cast()
    end

    --- Cooldowns

    if RubimRH.CDsON()
            and BrewSpells.BloodFury:IsReady("Melee") then
        return BrewSpells.BloodFury:ID()
    end

    if RubimRH.CDsON()
            and BrewSpells.Berserking:IsReady("Melee") then
        return BrewSpells.Berserking:ID()
    end

    -- TODO: Handle proper logic for locating distance to statue
    --    if Cache.EnemiesCount[8] >= 3
    --            and BlackOxStatue:IsReady(8)
    --            and (not Pet:IsActive() or Player:FindRange("pet") > 8) then
    --        return BlackOxStatue:Cast()
    --    end

    --- Universal Rotation - Does not change based on targets

    if BrewSpells.InvokeNiuzaotheBlackOx:IsAvailable()
            and BrewSpells.InvokeNiuzaotheBlackOx:IsReady(40) then
        return BrewSpells.InvokeNiuzaotheBlackOx:Cast()
    end

    if BrewSpells.KegSmash:IsReady(15) then
        return BrewSpells.KegSmash:Cast()
    end

    --- Return different priority for 3+ target AoE
    if Cache.EnemiesCount[8] >= 3
            and AoE() ~= nil then
        return AoE()
    end

    --- Single-Target priority
    if BrewSpells.BlackoutStrike:IsReady("Melee")
            and (not Player:Buff(BrewSpells.BlackoutComboBuff) or not BrewSpells.BlackoutCombo:IsAvailable()) then
        return BrewSpells.BlackoutStrike:Cast()
    end

    if (Player:Buff(BrewSpells.BlackoutComboBuff) or EnergyWillCap())
            and BrewSpells.TigerPalm:IsReady("Melee") then
        return BrewSpells.TigerPalm:Cast()
    end

    if BrewSpells.BreathOfFire:IsReady("Melee") then
        return BrewSpells.BreathOfFire:Cast()
    end

    if BrewSpells.RushingJadeWind:IsReady(8)
            and not Player:Buff(BrewSpells.RushingJadeWind) then
        return BrewSpells.RushingJadeWind:Cast()
    end

    if BrewSpells.ChiBurst:IsReady(40)
            and RubimRH.lastMoved() >= 1 then
        return BrewSpells.ChiBurst:Cast()
    end

    if BrewSpells.ChiWave:IsReady(40) then
        return BrewSpells.ChiWave:Cast()
    end

    if BrewSpells.TigerPalm:IsReady()
            and Player:Energy() >= 55 then
        return BrewSpells.TigerPalm:Cast()
    end

    if BrewSpells.RushingJadeWind:IsReady() then
        return BrewSpells.RushingJadeWind:Cast()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(268, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(268, PASSIVE);