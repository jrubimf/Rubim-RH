--- Last Edit: Bishop : 7/21/18

local addonName, addonTable = ...
-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell = HL.Spell

-- Spells
local ArcaneTorrent = Spell(50613)
local Berserking = Spell(26297)
local BlackoutCombo = Spell(196736)
local BlackoutComboBuff = Spell(228563)
local BlackoutStrike = Spell(205523)
local BlackOxBrew = Spell(115399)
local BloodFury = Spell(20572)
local BreathOfFire = Spell(115181)
local BreathofFireDotDebuff = Spell(123725)
local Brews = Spell(115308)
local ChiBurst = Spell(123986)
local ChiWave = Spell(115098)
local DampenHarm = Spell(122278)
local DampenHarmBuff = Spell(122278)
local ExplodingKeg = Spell(214326)
local FortifyingBrew = Spell(115203)
local FortifyingBrewBuff = Spell(115203)
local InvokeNiuzaotheBlackOx = Spell(132578)
local IronskinBrew = Spell(115308)
local IronskinBrewBuff = Spell(215479)
local KegSmash = Spell(121253)
local LightBrewing = Spell(196721)
local PotentKick = Spell(213047)
local PurifyingBrew = Spell(119582)
local RushingJadeWind = Spell(116847)
local TigerPalm = Spell(100780)
local HeavyStagger = Spell(124273)
local ModerateStagger = Spell(124274)
local LightStagger = Spell(124275)
local SpearHandStrike = Spell(116705)
local ModerateStagger = Spell(124274)
local HeavyStagger = Spell(124273)
local HealingElixir = Spell(122281)
local BlackOxStatue = Spell(115315)
local Guard = Spell(202162)
-- Misc
local PoolEnergy = Spell(9999000010)

--- Class-specific Spell:CanCast function, parameters optional
function Spell:CanCast(spellRange, spellEnergy)
    spellRange = spellRange or 0
    spellEnergy = spellEnergy or 0

    return self:IsCastable(spellRange) and (Player:Energy() >= spellEnergy)
end

--- Returns if energy will cap within the next GCD
local function EnergyWillCap()
    return (Player:Energy() + (Player:EnergyRegen() * Player:GCDRemains())) >= 100
end

local function AoE()
    if BreathOfFire:CanCast("Melee") then
        return BreathOfFire:Cast()
    end

    if RushingJadeWind:CanCast(8)
            and not Player:Buff(RushingJadeWind) then
        return RushingJadeWind:Cast()
    end

    if ChiBurst:CanCast(40)
            and RubimRH.lastMoved() >= 1 then
        return ChiBurst:Cast()
    end

    if (Player:Buff(BlackoutComboBuff) or EnergyWillCap())
            and TigerPalm:CanCast("Melee") then
        return TigerPalm:Cast()
    end

    if BlackoutStrike:CanCast("Melee") then
        return BlackoutStrike:Cast()
    end

    if ChiWave:CanCast(40) then
        return ChiWave:Cast()
    end

    if TigerPalm:CanCast("Melee")
            and Player:Energy() >= 55 then
        return TigerPalm:Cast()
    end

    if RushingJadeWind:CanCast(8) then
        return RushingJadeWind:Cast()
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
    if SpearHandStrike:CanCast("Melee")
            and Target:IsInterruptible()
            and Target:CastRemains() <= 0.5 then
        return SpearHandStrike:Cast()
    end

    --- Defensive Rotation

    if Brews:ChargesFractional() <= 1
            and BlackOxBrew:IsAvailable()
            and BlackOxBrew:CanCast() then
        return BlackOxBrew:Cast()
    end

    if Brews:ChargesFractional() >= 1
            and (not Player:Buff(IronskinBrewBuff) or (Player:Buff(IronskinBrewBuff) and Player:BuffRemains(IronskinBrewBuff) <= Player:GCD()))
            and IsTanking then
        return IronskinBrew:Cast()
    end

    if Player:Debuff(HeavyStagger)
            and Player:Buff(IronskinBrewBuff)
            and Player:BuffRemains(IronskinBrewBuff) > Player:GCD() * 2
            and IsTanking then
        return PurifyingBrew:Cast()
    end

    if Player:HealthPercentage() <= 85
        and HealingElixir:CanCast() then
        return HealingElixir:Cast()
    end

    if Player:Buff(HeavyStagger)
        and Player:HealthPercentage() <= 80
        and Guard:CanCast() then
        return Guard:Cast()
    end

    --- Cooldowns

    if RubimRH.CDsON()
            and BloodFury:CanCast("Melee") then
        return BloodFury:ID()
    end

    if RubimRH.CDsON()
            and Berserking:CanCast("Melee") then
        return Berserking:ID()
    end

    -- TODO: Handle proper logic for locating distance to statue
--    if Cache.EnemiesCount[8] >= 3
--            and BlackOxStatue:CanCast(8)
--            and (not Pet:IsActive() or Player:FindRange("pet") > 8) then
--        return BlackOxStatue:Cast()
--    end

    --- Universal Rotation - Does not change based on targets

    if InvokeNiuzaotheBlackOx:IsAvailable()
            and InvokeNiuzaotheBlackOx:CanCast(40) then
        return InvokeNiuzaotheBlackOx:Cast()
    end

    if KegSmash:CanCast(15) then
        return KegSmash:Cast()
    end

    --- Return different priority for 3+ target AoE
    if Cache.EnemiesCount[8] >= 3
            and AoE() ~= nil then
        return AoE()
    end

    --- Single-Target priority
    if BlackoutStrike:CanCast("Melee")
            and (not Player:Buff(BlackoutComboBuff) or not BlackoutCombo:IsAvailable()) then
        return BlackoutStrike:Cast()
    end

    if (Player:Buff(BlackoutComboBuff) or EnergyWillCap())
            and TigerPalm:CanCast("Melee") then
        return TigerPalm:Cast()
    end

    if BreathOfFire:CanCast("Melee") then
        return BreathOfFire:Cast()
    end

    if RushingJadeWind:CanCast(8)
            and not Player:Buff(RushingJadeWind) then
        return RushingJadeWind:Cast()
    end

    if ChiBurst:CanCast(40)
            and RubimRH.lastMoved() >= 1 then
        return ChiBurst:Cast()
    end

    if ChiWave:CanCast(40) then
        return ChiWave:Cast()
    end

    if TigerPalm:CanCast()
            and Player:Energy() >= 55 then
        return TigerPalm:Cast()
    end

    if RushingJadeWind:CanCast() then
        return RushingJadeWind:Cast()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(268, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(268, PASSIVE);