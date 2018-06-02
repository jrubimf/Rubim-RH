--- Localize Vars
-- Addon
local addonName, addonTable = ...;

-- AethysCore
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;

-- APL from T21_Shaman_Enhancement on 2017-12-03

-- APL Local Vars
-- Spells
if not Spell.Shaman then
    Spell.Shaman = {};
end
Spell.Shaman.Enhancement = {
    -- Racials
    Berserking = Spell(26297),
    BloodFury = Spell(20572),

    -- Abilities
    CrashLightning = Spell(187874),
    CrashLightningBuff = Spell(187878),
    LightningCrashBuff = Spell(242284),
    Flametongue = Spell(193796),
    FlametongueBuff = Spell(194084),
    Frostbrand = Spell(196834),
    FrostbrandBuff = Spell(196834),
    StormStrike = Spell(17364),
    StormbringerBuff = Spell(201846),

    FeralSpirit = Spell(51533),
    LavaLash = Spell(60103),
    LightningBolt = Spell(187837),
    Rockbiter = Spell(193786),
    WindStrike = Spell(115356),
    HealingSurge = Spell(188070),

    -- Talents
    Windsong = Spell(201898),
    HotHandBuff = Spell(215785),
    Landslide = Spell(197992),
    LandslideBuff = Spell(202004),
    Hailstorm = Spell(210853),
    Overcharge = Spell(210727),
    CrashingStorm = Spell(192246),
    FuryOfAir = Spell(197211),
    FuryOfAirBuff = Spell(197211),
    Sundering = Spell(197214),
    Ascendance = Spell(114051),
    AscendanceBuff = Spell(114051),
    Boulderfist = Spell(246035),
    EarthenSpike = Spell(188089),
    EarthenSpikeDebuff = Spell(188089),

    -- T21 2pc set bonus
    FotMBuff = Spell(254308),

    -- Artifact
    DoomWinds = Spell(204945),
    DoomWindsBuff = Spell(204945),
    AlphaWolf = Spell(198434),

    -- Utility
    WindShear = Spell(57994),

    -- ToS Trinkets
    SpecterOfBetrayal = Spell(246461),

    -- World Trinkets
    HornOfValor = Spell(215956),

    -- Misc
    PoolFocus = Spell(9999000010),
}
local S = Spell.Shaman.Enhancement

-- Items
if not Item.Shaman then
    Item.Shaman = {}
end
Item.Shaman.Enhancement = {
    -- Legendaries
    SmolderingHeart = Item(151819, { 10 }),
    AkainusAbsoluteJustice = Item(137084, { 9 }),

    -- ToS Trinkets
    SpecterOfBetrayal = Item(151190, { 13, 14 }),

    -- World Trinkets
    HornOfValor = Item(133642, { 13, 14 }),

    -- Misc
    PoPP = Item(142117),
    Healthstone = Item(5512),
}
local I = Item.Shaman.Enhancement

local T202PC, T204PC = AC.HasTier("T20");
local T212PC, T214PC = AC.HasTier("T21");
--- APL Variables
-- actions+=/variable,name=hailstormCheck,value=((talent.hailstorm.enabled&!buff.frostbrand.up)|!talent.hailstorm.enabled)
local function hailstormCheck()
    return (S.Hailstorm:IsAvailable() and not Player:Buff(S.FrostbrandBuff)) or not S.Hailstorm:IsAvailable()
end

-- actions+=/variable,name=furyCheck80,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>80))
local function furyCheck80()
    return not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 80)
end

-- actions+=/variable,name=furyCheck70,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>70))
local function furyCheck70()
    return not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 70)
end

-- actions+=/variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
local function furyCheck45()
    return not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 45)
end

-- actions+=/variable,name=furyCheck25,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>25))
local function furyCheck25()
    return not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 25)
end

-- actions+=/variable,name=OCPool70,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>70))
local function OCPool70()
    return not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and Player:Maelstrom() > 70)
end

-- actions+=/variable,name=OCPool60,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>60))
local function OCPool60()
    return not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and Player:Maelstrom() > 60)
end

-- actions+=/variable,name=heartEquipped,value=(equipped.151819)
local function heartEquipped()
    return I.SmolderingHeart:IsEquipped()
end

-- actions+=/variable,name=akainuEquipped,value=(equipped.137084)
local function akainuEquipped()
    return I.AkainusAbsoluteJustice:IsEquipped()
end

-- actions+=/variable,name=akainuAS,value=(variable.akainuEquipped&buff.hot_hand.react&!buff.frostbrand.up)
local function akainuAS()
    return akainuEquipped() and Player:Buff(S.HotHandBuff) and not Player:Buff(S.FrostbrandBuff)
end

-- actions+=/variable,name=LightningCrashNotUp,value=(!buff.lightning_crash.up&set_bonus.tier20_2pc)
local function LightningCrashNotUp()
    return (not Player:Buff(S.LightningCrashBuff)) and AC.Tier20_2Pc
end

-- actions+=/variable,name=alphaWolfCheck,value=((pet.frost_wolf.buff.alpha_wolf.remains<2&pet.fiery_wolf.buff.alpha_wolf.remains<2&pet.lightning_wolf.buff.alpha_wolf.remains<2)&feral_spirit.remains>4)
local function alphaWolfCheck()
    return S.AlphaWolf:ArtifactEnabled() and S.FeralSpirit:TimeSinceLastCast() <= 11 and (S.CrashLightning:TimeSinceLastCast() >= 6)
end

-- APL Main
function Enhancement ()
    -- Unit Update
    AC.GetEnemies(40);  -- Lightning Bolt
    AC.GetEnemies(30);  -- Purge / Wind Shear
    AC.GetEnemies(10);  -- ES / FB / FT / RB / WS /
    AC.GetEnemies(8);   -- FOA / CL / Sundering

    -- Out of Combat
    if not Player:AffectingCombat() then
        -- Opener
        -- actions+=/call_action_list,name=opener
        if Target:Exists() then
            -- actions.opener=rockbiter,if=maelstrom<15&time<gcd
            if S.Rockbiter:IsCastable(10) and Player:Maelstrom() < 15 then
                return S.Rockbiter:ID()
            end
        end
        return 146250
    end

    -- In Combat
    if Target:Exists() then
        -- Interrupts

        -- Potion of Prolonged Power

        -- Use healthstone if we have it and our health is low.

        -- Heal when we have less than the set health threshold!
        if S.HealingSurge:IsReady() and useS1 and Player:HealthPercentage() <= 50 then
            -- Instant casts using maelstrom only.
            if Player:Maelstrom() >= 20 then
                return S.HealingSurge:ID()
            end
        end


        -- actions+=/call_action_list,name=asc,if=buff.ascendance.up
        if Player:Buff(S.AscendanceBuff) then
            -- actions.asc=earthen_spike
            if S.EarthenSpike:IsCastable(10) and Player:Maelstrom() >= S.EarthenSpike:Cost() then
                return S.EarthenSpike:ID()
            end

            -- actions.asc+=/doom_winds,if=cooldown.strike.up
            if S.DoomWinds:IsCastable() and (S.WindStrike:CooldownRemainsP() > 0 or S.StormStrike:CooldownRemainsP() > 0) then
                return S.DoomWinds:ID()
            end

            -- actions.asc+=/windstrike
            if S.WindStrike:IsCastable(30) and Player:Maelstrom() >= S.EarthenSpike:Cost() then
                return S.WindStrike:ID()
            end
        end

        -- actions+=/call_action_list,name=buffs
        -- actions.buffs=rockbiter,if=talent.landslide.enabled&!buff.landslide.up
        if S.Rockbiter:IsCastable(10) and (S.Landslide:IsAvailable() and not Player:Buff(S.LandslideBuff)) then
            return S.Rockbiter:ID()
        end

        -- actions.buffs+=/fury_of_air,if=!ticking&maelstrom>22
        if S.FuryOfAir:IsCastable(8, true) and Player:Maelstrom() >= S.FuryOfAir:Cost() + 9 and (not Player:Buff(S.FuryOfAirBuff) and Player:Maelstrom() > 22) then
            return S.FuryOfAir:ID()
        end

        -- actions.buffs+=/crash_lightning,if=artifact.alpha_wolf.rank&prev_gcd.1.feral_spirit
        if S.CrashLightning:IsCastable("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (S.AlphaWolf:ArtifactEnabled() and Player:PrevGCD(1, S.FeralSpirit)) then
            return S.CrashLightning:ID()
        end

        -- actions.buffs+=/flametongue,if=!buff.flametongue.up
        if S.Flametongue:IsCastable(10) and (not Player:Buff(S.FlametongueBuff)) then
            return S.Flametongue:ID()
        end

        -- actions.buffs+=/frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck45
        if S.Frostbrand:IsCastable(10) and Player:Maelstrom() >= S.Frostbrand:Cost() and (S.Hailstorm:IsAvailable() and not Player:Buff(S.FrostbrandBuff) and furyCheck45()) then
            return S.Frostbrand:ID()
        end

        -- actions.buffs+=/flametongue,if=buff.flametongue.remains<6+gcd&cooldown.doom_winds.remains<gcd*2
        if S.Flametongue:IsCastable(10) and (Player:BuffRemainsP(S.FlametongueBuff) < 6 + Player:GCD() and S.DoomWinds:CooldownRemainsP() < Player:GCD() * 2) then
            return S.Flametongue:ID()
        end

        -- actions.buffs+=/frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<6+gcd&cooldown.doom_winds.remains<gcd*2
        if S.Frostbrand:IsCastable(10) and Player:Maelstrom() >= S.Frostbrand:Cost() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 6 + Player:GCD() and S.DoomWinds:CooldownRemainsP() < Player:GCD() * 2) then
            return S.Frostbrand:ID()
        end

        -- actions+=/call_action_list,name=cds
        if CDsON() then
            -- Racial
            -- actions.cds+=/berserking,if=buff.ascendance.up|(cooldown.doom_winds.up)|level<100
            if S.Berserking:IsCastable() and (Player:Buff(S.AscendanceBuff) or S.DoomWinds:CooldownRemainsP() > 0) then
                return S.Berserking:ID()
            end

            -- Racial
            -- actions.cds+=/blood_fury,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
            if S.BloodFury:IsCastable() and (Player:Buff(S.AscendanceBuff) or S.FeralSpirit:TimeSinceLastCast() <= 10) then
                return S.BloodFury:ID()
            end

            -- actions.cds+=/feral_spirit
            if S.FeralSpirit:IsCastable() then
                return S.FeralSpirit:ID()
            end

            -- actions.cds+=/doom_winds,if=cooldown.ascendance.remains>6|talent.boulderfist.enabled|debuff.earthen_spike.up
            if S.DoomWinds:IsCastable() and (S.Ascendance:CooldownRemainsP() > 6 or S.Boulderfist:IsAvailable() or Target:Debuff(S.EarthenSpikeDebuff)) then
                return S.DoomWinds:ID()
            end

            -- actions.cds+=/ascendance,if=(cooldown.strike.remains>0)&buff.ascendance.down
            if S.Ascendance:IsCastable() and ((S.WindStrike:CooldownRemainsP() > 0 or S.StormStrike:CooldownRemainsP() > 0) and not Player:Buff(S.AscendanceBuff)) then
                return S.Ascendance:ID()
            end
        end

        -- actions+=/call_action_list,name=core
        -- actions.core=earthen_spike,if=variable.furyCheck25
        if S.EarthenSpike:IsCastable(10) and (furyCheck25()) and Player:Maelstrom() >= S.EarthenSpike:Cost() then
            return S.EarthenSpike:ID()
        end

        -- actions.core+=/crash_lightning,if=!buff.crash_lightning.up&active_enemies>=2
        if S.CrashLightning:IsCastable("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (not Player:Buff(S.CrashLightningBuff) and Cache.EnemiesCount[8] >= 2) then
            return S.CrashLightning:ID()
        end

        -- actions.core+=/windsong
        if S.Windsong:IsCastable(10) then
            return S.Windsong:ID()
        end

        -- actions.core+=/crash_lightning,if=active_enemies>=8|(active_enemies>=6&talent.crashing_storm.enabled)
        if S.CrashLightning:IsCastable("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (Cache.EnemiesCount[8] >= 8 or (Cache.EnemiesCount[8] >= 6 and S.CrashingStorm:IsAvailable())) then
            return S.CrashLightning:ID()
        end

        -- actions.core+=/windstrike
        if S.WindStrike:IsCastable(30) and Player:Maelstrom() >= S.EarthenSpike:Cost() then
            return S.WindStrike:ID()
        end

        -- actions.core+=/stormstrike,if=buff.stormbringer.up&variable.furyCheck25
        if S.StormStrike:IsCastable("Melee") and Player:Maelstrom() >= S.StormStrike:Cost() and (Player:Buff(S.StormbringerBuff) and furyCheck25()) then
            return S.StormStrike:ID()
        end

        -- actions.core+=/crash_lightning,if=active_enemies>=4|(active_enemies>=2&talent.crashing_storm.enabled)
        if S.CrashLightning:IsCastable("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (Cache.EnemiesCount[8] >= 4 or (Cache.EnemiesCount[8] >= 2 and S.CrashingStorm:IsAvailable())) then
            return S.CrashLightning:ID()
        end

        -- actions.core+=/rockbiter,if=buff.force_of_the_mountain.up
        if S.Rockbiter:IsCastable(10) and (Player:Buff(S.FotMBuff)) then
            return S.Rockbiter:ID()
        end

        -- actions.core+=/lightning_bolt,if=talent.overcharge.enabled&variable.furyCheck45&maelstrom>=40
        if S.LightningBolt:IsCastable(40) and (S.Overcharge:IsAvailable() and furyCheck45() and Player:Maelstrom() >= 40) then
            return S.LightningBolt:ID()
        end

        -- actions.core+=/stormstrike,if=(!talent.overcharge.enabled&variable.furyCheck45)|(talent.overcharge.enabled&variable.furyCheck80)
        if S.StormStrike:IsCastable("Melee") and Player:Maelstrom() >= S.StormStrike:Cost() and ((not S.Overcharge:IsAvailable() and furyCheck45()) or (S.Overcharge:IsAvailable() and furyCheck80())) then
            return S.StormStrike:ID()
        end

        -- actions.core+=/frostbrand,if=variable.akainuAS
        if S.Frostbrand:IsCastable(10) and Player:Maelstrom() >= S.Frostbrand:Cost() and (akainuAS()) then
            return S.Frostbrand:ID()
        end

        -- actions.core+=/lava_lash,if=buff.hot_hand.react&((variable.akainuEquipped&buff.frostbrand.up)|!variable.akainuEquipped)
        if S.LavaLash:IsCastable("Melee") and Player:Maelstrom() >= S.LavaLash:Cost() and (Player:Buff(S.HotHandBuff) and ((akainuEquipped() and Player:Buff(S.FrostbrandBuff)) or not akainuEquipped())) then
            return S.LavaLash:ID()
        end

        -- actions.core+=/sundering,if=active_enemies>=3
        if S.Sundering:IsCastable() and Player:Maelstrom() >= S.Sundering:Cost() and (Cache.EnemiesCount[8] >= 3) then
            return S.Sundering:ID()
        end

        -- actions.core+=/crash_lightning,if=active_enemies>=3|variable.LightningCrashNotUp|variable.alphaWolfCheck
        if S.CrashLightning:IsCastable("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (Cache.EnemiesCount[8] >= 3 or LightningCrashNotUp() or alphaWolfCheck()) then
            return S.CrashLightning:ID()
        end

        -- actions+=/call_action_list,name=filler
        -- actions.filler=rockbiter,if=maelstrom<120
        if S.Rockbiter:IsCastable(10) and (Player:Maelstrom() < 120) then
            return S.Rockbiter:ID()
        end

        -- actions.filler+=/flametongue,if=buff.flametongue.remains<4.8
        if S.Flametongue:IsCastable(10) and (Player:BuffRemainsP(S.FlametongueBuff) < 4.8) then
            return S.Flametongue:ID()
        end

        -- actions.filler+=/crash_lightning,if=(talent.crashing_storm.enabled|active_enemies>=2)&debuff.earthen_spike.up&maelstrom>=40&variable.OCPool60
        if S.CrashLightning:IsCastable("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and ((S.CrashingStorm:IsAvailable() or Cache.EnemiesCount[8] >= 2) and Target:Debuff(S.EarthenSpikeDebuff) and Player:Maelstrom() >= 40 and OCPool60()) then
            return S.CrashLightning:ID()
        end

        -- actions.filler+=/frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8&maelstrom>40
        if S.Frostbrand:IsCastable(10) and Player:Maelstrom() >= S.Frostbrand:Cost() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 4.8 and Player:Maelstrom() > 40) then
            return S.Frostbrand:ID()
        end

        -- actions.filler+=/frostbrand,if=variable.akainuEquipped&!buff.frostbrand.up&maelstrom>=75
        if S.Frostbrand:IsCastable(10) and Player:Maelstrom() >= S.Frostbrand:Cost() and (akainuEquipped() and not Player:Buff(S.FrostbrandBuff) and Player:Maelstrom() >= 75) then
            return S.Frostbrand:ID()
        end

        -- actions.filler+=/sundering
        if S.Sundering:IsCastable() and Player:Maelstrom() >= S.Sundering:Cost() then
            return S.Sundering:ID()
        end

        -- actions.filler+=/lava_lash,if=maelstrom>=50&variable.OCPool70&variable.furyCheck80
        if S.LavaLash:IsCastable("Melee") and Player:Maelstrom() >= S.LavaLash:Cost() and (Player:Maelstrom() >= 50 and OCPool70() and furyCheck80()) then
            return S.LavaLash:ID()
        end

        -- actions.filler+=/rockbiter
        if S.Rockbiter:IsCastable(10) then
            return S.Rockbiter:ID()
        end

        -- actions.filler+=/crash_lightning,if=(maelstrom>=65|talent.crashing_storm.enabled|active_enemies>=2)&variable.OCPool60&variable.furyCheck45
        if S.CrashLightning:IsCastable("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and ((Player:Maelstrom() >= 65 or S.CrashingStorm:IsAvailable() or Cache.EnemiesCount[8] >= 2) and OCPool60() and furyCheck45()) then
            return S.CrashLightning:ID()
        end

        -- actions.filler+=/flametongue
        if S.Flametongue:IsCastable(10) then
            return S.Flametongue:ID()
        end
    end
    return 233159
end