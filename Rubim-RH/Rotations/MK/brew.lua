--- Last Edit: Bishop : 7/21/18

local addonName, addonTable = ...
-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell = HL.Spell

--- Ability declarations
if not Spell.Monk then
    Spell.Monk = {};
end
Spell.Monk.Brewmaster = {
    -- Spells
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BlackoutCombo = Spell(196736),
    BlackoutComboBuff = Spell(228563),
    BlackoutStrike = Spell(205523),
    BlackOxBrew = Spell(115399),
    BloodFury = Spell(20572),
    BreathOfFire = Spell(115181),
    BreathofFireDotDebuff = Spell(123725),
    Brews = Spell(115308),
    ChiBurst = Spell(123986),
    ChiWave = Spell(115098),
    DampenHarm = Spell(122278),
    DampenHarmBuff = Spell(122278),
    ExplodingKeg = Spell(214326),
    FortifyingBrew = Spell(115203),
    FortifyingBrewBuff = Spell(115203),
    InvokeNiuzaotheBlackOx = Spell(132578),
    IronskinBrew = Spell(115308),
    IronskinBrewBuff = Spell(215479),
    KegSmash = Spell(121253),
    LightBrewing = Spell(196721),
    PotentKick = Spell(213047),
    PurifyingBrew = Spell(119582),
    RushingJadeWind = Spell(116847),
    TigerPalm = Spell(100780),
    HeavyStagger = Spell(124273),
    ModerateStagger = Spell(124274),
    LightStagger = Spell(124275),
    SpearHandStrike = Spell(116705),
    ModerateStagger = Spell(124274),
    HeavyStagger = Spell(124273),
    HealingElixir = Spell(122281),
    BlackOxStatue = Spell(115315),
    Guard = Spell(202162),
    -- Misc
    PoolEnergy = Spell(9999000010)
}
local BrewSpells = Spell.Monk.Brewmaster;

--- Returns if energy will cap within the next GCD
local function EnergyWillCap()
    return (Player:Energy() + (Player:EnergyRegen() * Player:GCDRemains())) >= 100
end

local function AoE()
    if BrewSpells.BreathOfFire:IsCastable("Melee") then
        return BrewSpells.BreathOfFire:Cast()
    end

    if BrewSpells.RushingJadeWind:IsCastable(8)
            and not Player:Buff(BrewSpells.RushingJadeWind) then
        return BrewSpells.RushingJadeWind:Cast()
    end

    if BrewSpells.ChiBurst:IsCastable(40)
            and RubimRH.lastMoved() >= 1 then
        return BrewSpells.ChiBurst:Cast()
    end

    if (Player:Buff(BrewSpells.BlackoutComboBuff) or EnergyWillCap())
            and BrewSpells.TigerPalm:IsCastable("Melee") then
        return BrewSpells.TigerPalm:Cast()
    end

    if BrewSpells.BlackoutStrike:IsCastable("Melee") then
        return BrewSpells.BlackoutStrike:Cast()
    end

    if BrewSpells.ChiWave:IsCastable(40) then
        return BrewSpells.ChiWave:Cast()
    end

    if BrewSpells.TigerPalm:IsCastable("Melee")
            and Player:Energy() >= 55 then
        return BrewSpells.TigerPalm:Cast()
    end

    if BrewSpells.RushingJadeWind:IsCastable(8) then
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
    if BrewSpells.SpearHandStrike:IsCastable("Melee")
            and Target:IsInterruptible()
            and Target:CastRemains() <= 0.5 then
        return BrewSpells.SpearHandStrike:Cast()
    end

    --- Defensive Rotation

    if BrewSpells.Brews:ChargesFractional() <= 1
            and BrewSpells.BlackOxBrew:IsAvailable()
            and BrewSpells.BlackOxBrew:IsCastable() then
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
            and BrewSpells.HealingElixir:IsCastable() then
        return BrewSpells.HealingElixir:Cast()
    end

    if Player:Debuff(BrewSpells.HeavyStagger)
            and Player:HealthPercentage() <= 80
            and BrewSpells.Guard:IsCastable() then
        return BrewSpells.Guard:Cast()
    end

    --- Cooldowns

    if RubimRH.CDsON()
            and BrewSpells.BloodFury:IsCastable("Melee") then
        return BrewSpells.BloodFury:ID()
    end

    if RubimRH.CDsON()
            and BrewSpells.Berserking:IsCastable("Melee") then
        return BrewSpells.Berserking:ID()
    end

    -- TODO: Handle proper logic for locating distance to statue
    --    if Cache.EnemiesCount[8] >= 3
    --            and BlackOxStatue:IsCastable(8)
    --            and (not Pet:IsActive() or Player:FindRange("pet") > 8) then
    --        return BlackOxStatue:Cast()
    --    end

    --- Universal Rotation - Does not change based on targets

    if BrewSpells.InvokeNiuzaotheBlackOx:IsAvailable()
            and BrewSpells.InvokeNiuzaotheBlackOx:IsCastable(40) then
        return BrewSpells.InvokeNiuzaotheBlackOx:Cast()
    end

    if BrewSpells.KegSmash:IsCastable(15) then
        return BrewSpells.KegSmash:Cast()
    end

    --- Return different priority for 3+ target AoE
    if Cache.EnemiesCount[8] >= 3
            and AoE() ~= nil then
        return AoE()
    end

    --- Single-Target priority
    if BrewSpells.BlackoutStrike:IsCastable("Melee")
            and (not Player:Buff(BrewSpells.BlackoutComboBuff) or not BrewSpells.BlackoutCombo:IsAvailable()) then
        return BrewSpells.BlackoutStrike:Cast()
    end

    if (Player:Buff(BrewSpells.BlackoutComboBuff) or EnergyWillCap())
            and BrewSpells.TigerPalm:IsCastable("Melee") then
        return BrewSpells.TigerPalm:Cast()
    end

    if BrewSpells.BreathOfFire:IsCastable("Melee") then
        return BrewSpells.BreathOfFire:Cast()
    end

    if BrewSpells.RushingJadeWind:IsCastable(8)
            and not Player:Buff(BrewSpells.RushingJadeWind) then
        return BrewSpells.RushingJadeWind:Cast()
    end

    if BrewSpells.ChiBurst:IsCastable(40)
            and RubimRH.lastMoved() >= 1 then
        return BrewSpells.ChiBurst:Cast()
    end

    if BrewSpells.ChiWave:IsCastable(40) then
        return BrewSpells.ChiWave:Cast()
    end

    if BrewSpells.TigerPalm:IsCastable()
            and Player:Energy() >= 55 then
        return BrewSpells.TigerPalm:Cast()
    end

    if BrewSpells.RushingJadeWind:IsCastable() then
        return BrewSpells.RushingJadeWind:Cast()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(268, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(268, PASSIVE);