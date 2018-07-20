--
-- User: Rubim
-- Date: 09/04/2018
-- Time: 10:26
--

--- Localize Vars
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

-- APL from T21_Shaman_Elemental on 2017-12-06

-- APL Local Vars
-- Spells
if not Spell.Shaman then
    Spell.Shaman = {};
end
Spell.Shaman.Elemental = {
    -- Racials
    Berserking = Spell(26297),
    BloodFury = Spell(33697),

    -- Abilities
    FlameShock = Spell(188389),
    FlameShockDebuff = Spell(188389),
    BloodLust = Spell(2825),
    BloodLustBuff = Spell(2825),

    TotemMastery = Spell(210643),
    EmberTotemBuff = Spell(210658),
    TailwindTotemBuff = Spell(210659),
    ResonanceTotemBuff = Spell(202192),
    StormTotemBuff = Spell(210652),

    HealingSurge = Spell(188070),

    EarthShock = Spell(8042),
    LavaBurst = Spell(51505),
    FireElemental = Spell(198067),
    EarthElemental = Spell(198103),
    LightningBolt = Spell(188196),
    LavaBeam = Spell(114074),
    EarthQuake = Spell(61882),
    LavaSurgeBuff = Spell(77762),
    ChainLightning = Spell(188443),
    ElementalFocusBuff = Spell(16246),
    FrostShock = Spell(196840),

    -- Talents
    ElementalMastery = Spell(16166),
    ElementalMasteryBuff = Spell(16166),
    Ascendance = Spell(114050),
    AscendanceBuff = Spell(114050),
    LightningRod = Spell(210689),
    LightningRodDebuff = Spell(197209),
    LiquidMagmaTotem = Spell(192222),
    ElementalBlast = Spell(117014),
    Aftershock = Spell(210707),
    Icefury = Spell(210714),
    IcefuryBuff = Spell(210714),

    -- Artifact
    Stormkeeper = Spell(205495),
    StormkeeperBuff = Spell(205495),
    SwellingMaelstrom = Spell(238105),
    PowerOfTheMaelstrom = Spell(191861),
    PowerOfTheMaelstromBuff = Spell(191861),

    -- Tier bonus
    EarthenStrengthBuff = Spell(252141),

    -- Utility
    WindShear = Spell(57994),

    -- Misc
    PoolFocus = Spell(9999000010)
}
local S = Spell.Shaman.Elemental

-- Items
if not Item.Shaman then
    Item.Shaman = {}
end
Item.Shaman.Elemental = {
    -- Legendaries
    SmolderingHeart = Item(151819, { 10 }),
    TheDeceiversBloodPact = Item(137035, { 8 }),

    -- Trinkets
    SpecterOfBetrayal = Item(151190, { 13, 14 }),

    -- Rings
    GnawedThumbRing = Item(134526, { 11 }, { 12 }),

    -- Misc
    PoPP = Item(142117),
    Healthstone = Item(5512),
}
local I = Item.Shaman.Elemental

-- APL Main

function TotemMastery()
    for i = 1, 5 do
        local active, totemName, startTime, duration, textureId  = GetTotemInfo(i)
        if active == true and textureId == 511726 then
            return startTime + duration - GetTime()
        end
    end
    return 0
end

--136024 - Earth
--135790 - Fire
function ElementalUp()
    for i = 1, 5 do
        local active, totemName, startTime, duration, textureId  = GetTotemInfo(i)
        if active == true and (textureId == 135790 or textureId == 136024 or textureId == 1020304) then
            return startTime + duration - GetTime()
        end
    end
    return 0
end

local function aoe()
    --# Multi target action priority list
    --actions.aoe=stormkeeper
    if S.Stormkeeper:IsReady() then
        return S.Stormkeeper.Cast()
    end

    --actions.aoe+=/ascendance
    if S.Ascendance:IsReady() then
        return S.Ascendance:Cast()
    end

    --actions.aoe+=/liquid_magma_totem
    if S.LiquidMagmaTotem:IsReady() then
        return S.LiquidMagmaTotem:Cast()
    end

    --actions.aoe+=/flame_shock,if=spell_targets.chain_lightning<4,target_if=refreshable
    if S.FlameShock:IsReady() and Cache.EnemiesCount[40] < 4 and Target:DebuffRemains(S.FlameShockDebuff) <= 2.5 then
        return S.FlameShock:Cast()
    end

    --actions.aoe+=/earthquake
    if S.EarthShock:IsReady() then
        return S.EarthShock:Cast()
    end

    --# Only cast Lava Burst on three targets if it is an instant.
    --actions.aoe+=/lava_burst,if=dot.flame_shock.remains>cast_time&buff.lava_surge.up&spell_targets.chain_lightning<4
    if S.LavaBurst:IsReady() and Target:DebuffRemains(S.FlameShockDebuff) > S.LavaBurst:CastTime() and Player:Buff(S.LavaSurgeBuff) and Cache.EnemiesCount[40] < 4 then
        return S.LavaBurst:Cast()
    end

    --actions.aoe+=/elemental_blast,if=spell_targets.chain_lightning<4
    if S.ElementalBlast:IsReady() and Cache.EnemiesCount[40] < 4 then
        return S.ElementalBlast:Cast()
    end

    --actions.aoe+=/lava_beam
    if S.LavaBeam:IsReady() then
        return S.LavaBeam:Cast()
    end

    --actions.aoe+=/chain_lightning
    if S.ChainLightning:IsReady() then
        return S.ChainLightning:Cast()
    end

    --actions.aoe+=/lava_burst,moving=1
    if S.LavaBurst:IsReady() and Player:IsMoving() then
        return S.LavaBurst:Cast()
    end

    --actions.aoe+=/flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsReady() and Player:IsMoving() and Target:DebuffRemains(S.FlameShockDebuff) <= 2.5 then
        return S.FlameShock:Cast()
    end
end

local function single_target()
    --# Single Target Action Priority List
    --actions.single_target=flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
    if S.FlameShock:IsReady() and (not Target:Debuff(S.FlameShockDebuff) or (Target:DebuffRemains(S.FlameShockDebuff) <= Player:GCDRemains())) then
        return S.FlameShock:Cast()
    end

    --actions.single_target+=/ascendance,if=(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0
    if S.Ascendance:IsReady() and RubimRH.CDsON() and ((HL.CombatTime() >= 60 or Player:Buff(S.BloodLustBuff)) and S.LavaBurst:CooldownRemains() > 0) then
        return S.Ascendance:Cast()
    end

    --actions.single_target+=/elemental_blast
    if S.ElementalBlast:IsReady() then
        return S.ElementalBlast:Cast()
    end

    --actions.single_target+=/icefury
    if S.Icefury:IsReady() then
        return S.Icefury:Cast()
    end

    --# Keep SK for large or soon add waves.
    --actions.single_target+=/stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.Stormkeeper:IsReady() and not RubimRH.useAoE then
        return S.Stormkeeper:Cast()
    end

    --actions.single_target+=/liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
    if S.LiquidMagmaTotem:IsReady() and not RubimRH.useAoE then
        return S.LiquidMagmaTotem:Cast()
    end

    --actions.single_target+=/frost_shock,if=buff.icefury.up&maelstrom>=20
    if S.FrostShock:IsReady() and Player:Buff(S.IcefuryBuff) and Player:Maelstrom() >= 20 then
        return S.FrostShock:Cast()
    end

    --actions.single_target+=/earth_shock
    if S.EarthShock:IsReady() then
        return S.EarthShock:Cast()
    end

    --actions.single_target+=/lava_burst,if=dot.flame_shock.remains>cast_time&(cooldown_react|buff.ascendance.up)
    if S.LavaBurst:IsReady() and (Target:DebuffRemains(S.FlameShockDebuff) > S.LavaBurst:CastTime()) then
        return S.LavaBurst:Cast()
    end

    --actions.single_target+=/flame_shock,if=maelstrom>=20,target_if=refreshable
    if S.FlameShock:IsReady() and Player:Maelstrom() >= 20 and Target:DebuffRemains(S.FlameShockDebuff) <= 2.5 then
        return S.FlameShock:Cast()
    end

    --actions.single_target+=/totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
    if S.TotemMastery:IsReady() and (TotemMastery() < 10 or (TotemMastery() < Player:BuffRemains(S.AscendanceBuff) + S.Ascendance:CooldownRemains()) and S.Ascendance:CooldownRemains() < 15) then
        return S.TotemMastery:Cast()
    end


    --actions.single_target+=/lava_beam,if=active_enemies>1&spell_targets.lava_beam>1
    if S.LavaBeam:IsReady() and Cache.EnemiesCount[40] > 1 then
        return S.LavaBeam:Cast()
    end

    --actions.single_target+=/chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
    if S.ChainLightning:IsReady() and Cache.EnemiesCount[40] > 1 then
        return S.ChainLightning:Cast()
    end

    --actions.single_target+=/lightning_bolt
    if S.LightningBolt:IsReady() then
        return S.LightningBolt:Cast()
    end

    --actions.single_target+=/flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastable() and Player:IsMoving() and Target:DebuffRemains(S.FlameShockDebuff) <= 2.5 then
        return S.FlameShock:Cast()
    end

    --actions.single_target+=/flame_shock,moving=1,if=movement.distance>6
    if S.FlameShock:IsCastable() and Player:IsMoving() then
        return S.FlameShock:Cast()
    end

end

local function APL ()
    HL.GetEnemies(40)  -- General casting range
    --# Executed before combat begins. Accepts non-harmful actions only.
    --actions.precombat=flask
    --actions.precombat+=/food
    --actions.precombat+=/augmentation
    --# Snapshot raid buffed stats before combat begins and pre-potting is done.
    --actions.precombat+=/snapshot_stats
    --actions.precombat+=/totem_mastery
    --actions.precombat+=/fire_elemental
    --actions.precombat+=/potion
    --actions.precombat+=/elemental_blast
    -- Out of Combat

    if not Player:AffectingCombat() then
        return 0, 462338
    end

    if Player:IsCasting() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end

    --actions+=/blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
    if S.BloodFury:IsReady() and (not S.Ascendance:IsAvailable() or Player:Buff(S.AscendanceBuff) or S.Ascendance:CooldownRemains() > 50) then
        return S.BloodFury:Cast()
    end

    --actions+=/berserking,if=!talent.ascendance.enabled|buff.ascendance.up
    if S.Berserking:IsReady() and (not S.Ascendance:IsAvailable() or Player:Buff(S.AscendanceBuff)) then
        return S.Berserking:Cast()
    end

    --actions+=/run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
    if Cache.EnemiesCount[40] > 2 and RubimRH.useAoE and aoe() ~= nil then
        return aoe()
    end

    --actions+=/run_action_list,name=single_target
    if single_target() ~= nil then
        return single_target()
    end

    return 0, 975743
end

RubimRH.Rotation.SetAPL(262, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(262, PASSIVE);