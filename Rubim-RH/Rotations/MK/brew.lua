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

local ISpell = RubimRH.Spell[268]

--- Returns if energy will cap within the next GCD
local function EnergyWillCap()
    return (Player:Energy() + (Player:EnergyRegen() * Player:GCDRemains())) >= 100
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

    -- Misc
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target)

    -- Kick
    if ISpell.SpearHandStrike:IsReady("Melee")
            and Target:IsInterruptible()
            and Target:CastRemains() <= 0.5 then
        return ISpell.SpearHandStrike:Cast()
    end

    --- Defensive Rotation

    if ISpell.Brews:ChargesFractional() < 1
            and ISpell.BlackOxBrew:IsAvailable()
            and ISpell.BlackOxBrew:IsReady() then
        return ISpell.BlackOxBrew:Cast()
    end

    if ISpell.Brews:ChargesFractional() >= 1
            and (not Player:Buff(ISpell.IronskinBrewBuff) or (Player:Buff(ISpell.IronskinBrewBuff) and Player:BuffRemains(ISpell.IronskinBrewBuff) <= Player:GCD()))
            and IsTanking then
        return ISpell.IronskinBrew:Cast()
    end

    if Player:Debuff(ISpell.HeavyStagger)
            and Player:Buff(ISpell.IronskinBrewBuff)
            and Player:BuffRemains(ISpell.IronskinBrewBuff) > Player:GCD() * 2
            and IsTanking then
        return ISpell.PurifyingBrew:Cast()
    end

    if Player:HealthPercentage() <= 85
            and ISpell.HealingElixir:IsReady() then
        return ISpell.HealingElixir:Cast()
    end

    if Player:Debuff(ISpell.HeavyStagger)
            and Player:HealthPercentage() <= 80
            and ISpell.Guard:IsReady() then
        return ISpell.Guard:Cast()
    end

    --- Cooldowns

    if RubimRH.CDsON()
            and ISpell.BloodFury:IsReady("Melee") then
        return ISpell.BloodFury:ID()
    end

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

    if ISpell.InvokeNiuzaotheBlackOx:IsAvailable()
            and ISpell.InvokeNiuzaotheBlackOx:IsReady(40) then
        return ISpell.InvokeNiuzaotheBlackOx:Cast()
    end

    if ISpell.KegSmash:IsReady(15) then
        return ISpell.KegSmash:Cast()
    end

    --- Return different priority for 3+ target AoE
    if Cache.EnemiesCount[8] >= 3
            and AoE() ~= nil then
        return AoE()
    end

    --- Single-Target priority
    if ISpell.BlackoutStrike:IsReady("Melee")
            and (not Player:Buff(ISpell.BlackoutComboBuff) or not ISpell.BlackoutCombo:IsAvailable()) then
        return ISpell.BlackoutStrike:Cast()
    end

    if (Player:Buff(ISpell.BlackoutComboBuff) or EnergyWillCap())
            and ISpell.TigerPalm:IsReady("Melee") then
        return ISpell.TigerPalm:Cast()
    end

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

    if ISpell.ChiWave:IsReady(40) then
        return ISpell.ChiWave:Cast()
    end

    if ISpell.TigerPalm:IsReady()
            and Player:Energy() >= 55 then
        return ISpell.TigerPalm:Cast()
    end

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