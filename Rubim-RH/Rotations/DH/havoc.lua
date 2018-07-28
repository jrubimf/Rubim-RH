--- ============================ HEADER ============================
--- ======= LOCALIZE =======
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
-- Lua
local pairs = pairs;
local select = select;

Player.CSPrediction = {
    CritCount = 0;
};

local ChaosStrikeMHDamageID = 222031;
local AnnihilationMHDamageID = 227518;
local ChaosStrikeEnergizeId = 193840;

-- Return CS adjusted Fury HeroLib
function Player:FuryWithCSRefund()
    return math.min(Player:Fury() + Player.CSPrediction.CritCount * 20, Player:FuryMax());
end

-- Return CS adjusted Fury Deficit HeroLib
function Player:FuryDeficitWithCSRefund()
    return math.max(Player:FuryDeficit() - Player.CSPrediction.CritCount * 20, 0);
end

-- Zero CSPrediction after receiving any Chaos Strike energize
HL:RegisterForSelfCombatEvent(function(...)
    local rsspellid = select(12, ...)
    if (rsspellid == ChaosStrikeEnergizeId) then
        Player.CSPrediction.CritCount = 0;
        --HL.Print("Refund!");
    end
end, "SPELL_ENERGIZE");

-- Set CSPrediction on the MH impact from Chaos Strike or Annihilation
HL:RegisterForSelfCombatEvent(function(...)
    local spellID = select(12, ...)
    local spellCrit = select(21, ...)
    if (spellCrit and (spellID == ChaosStrikeMHDamageID or spellID == AnnihilationMHDamageID)) then
        Player.CSPrediction.CritCount = Player.CSPrediction.CritCount + 1;
        --HL.Print("Crit!");
    end
end, "SPELL_DAMAGE");
--- ============================ CONTENT ============================
---
---
--- GetSpell
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999


if not Item.DemonHunter then
    Item.DemonHunter = {};
end
Item.DemonHunter.Havoc = {
    -- Legendaries
    AngerOfTheHalfGiants = Item(137038, { 11, 12 }),
    DelusionsOfGrandeur = Item(144279, { 3 }),
    -- Trinkets
    ConvergenceofFates = Item(140806, { 13, 14 }),
    KiljaedensBurningWish = Item(144259, { 13, 14 }),
    DraughtofSouls = Item(140808, { 13, 14 }),
    VialofCeaselessToxins = Item(147011, { 13, 14 }),
    UmbralMoonglaives = Item(147012, { 13, 14 }),
    SpecterofBetrayal = Item(151190, { 13, 14 }),
    VoidStalkersContract = Item(151307, { 13, 14 }),
    ForgefiendsFabricator = Item(151963, { 13, 14 }),
    -- Potion
    ProlongedPower = Item(142117),
};
local I = Item.DemonHunter.Havoc;
local S = RubimRH.Spell[577]

S.Annihilation.TextureSpellID = { 204317 }
S.DeathSweep.TextureSpellID = { 199552 }
S.Metamorphosis.TextureSpellID = { 187827 }
S.DarkSlash.TextureSpellID = { S.ArcaneTorrent:ID() }
S.ImmolationAura.TextureSpellID = { S.Shadowmeld:ID() }


-- Rotation Var
local ShouldReturn; -- Used to get the return string
local CleaveRangeID = tostring(S.ConsumeMagic:ID()); -- 20y range

-- Melee Is In Range w/ Movement Handlers
local function IsInMeleeRange()
    if S.Felblade:TimeSinceLastCast() < Player:GCD() then
        return true;
    elseif S.Metamorphosis:TimeSinceLastCast() < Player:GCD() then
        return true;
    end

    return Target:IsInRange("Melee");
end

-- Special Havoc Functions
local function IsMetaExtendedByDemonic()
    if not Player:BuffP(S.MetamorphosisBuff) then
        return false;
    elseif (S.EyeBeam:TimeSinceLastCast() < S.MetamorphosisImpact:TimeSinceLastCast()) then
        return true;
    end

    return false;
end

local function MetamorphosisCooldownAdjusted()
    -- TODO: Make this better by sampling the Fury expenses over time instead of approximating
    if I.ConvergenceofFates:IsEquipped() and I.DelusionsOfGrandeur:IsEquipped() then
        return S.Metamorphosis:CooldownRemainsP() * 0.56;
    elseif I.ConvergenceofFates:IsEquipped() then
        return S.Metamorphosis:CooldownRemainsP() * 0.78;
    elseif I.DelusionsOfGrandeur:IsEquipped() then
        return S.Metamorphosis:CooldownRemainsP() * 0.67;
    end

    return S.Metamorphosis:CooldownRemainsP()
end

-- Variables
-- variable,name=waiting_for_nemesis,value=!(!talent.nemesis.enabled|cooldown.nemesis.ready|cooldown.nemesis.remains>target.time_to_die|cooldown.nemesis.remains>60)
local function WaitingForNemesis()
    return not (not S.Nemesis:IsAvailable() or S.Nemesis:IsReady() or S.Nemesis:CooldownRemainsP() > Target:TimeToDie() or S.Nemesis:CooldownRemainsP() > 60);
end

-- variable,name=waiting_for_chaos_blades,value=!(!talent.chaos_blades.enabled|cooldown.chaos_blades.ready|cooldown.chaos_blades.remains>target.time_to_die|cooldown.chaos_blades.remains>60)
local function WaitingForChaosBlades()
    return not (not S.ChaosBlades:IsAvailable() or S.ChaosBlades:IsReady() or S.ChaosBlades:CooldownRemainsP() > Target:TimeToDie()
            or S.ChaosBlades:CooldownRemainsP() > 60);
end

-- variable,name=pooling_for_meta,value=!talent.demonic.enabled&cooldown.metamorphosis.remains<6&fury.deficit>30&(!variable.waiting_for_nemesis|cooldown.nemesis.remains<10)&(!variable.waiting_for_chaos_blades|cooldown.chaos_blades.remains<6)
local function PoolingForMeta()
    if not RubimRH.CDsON() then
        return false;
    end ;
    return not S.Demonic:IsAvailable() and S.Metamorphosis:CooldownRemainsP() < 6 and Player:FuryDeficitWithCSRefund() > 30
            and (not WaitingForNemesis() or S.Nemesis:CooldownRemainsP() < 10) and (not WaitingForChaosBlades() or S.ChaosBlades:CooldownRemainsP() < 6);
end

-- variable,name=blade_dance,value=talent.first_blood.enabled|set_bonus.tier20_4pc|spell_targets.blade_dance1>=3+(talent.chaos_cleave.enabled*3)
local function BladeDance()
    return S.FirstBlood:IsAvailable() or HL.Tier20_4Pc or (Cache.EnemiesCount[8] >= 3 + (S.ChaosCleave:IsAvailable() and 3 or 0));
end

-- variable,name=pooling_for_blade_dance,value=variable.blade_dance&(fury<75-talent.first_blood.enabled*20)
local function PoolingForBladeDance()
    return BladeDance() and (Player:FuryWithCSRefund() < (75 - (S.FirstBlood:IsAvailable() and 20 or 0)));
end

local function WaitingForDarkSlash()
    return S.DarkSlash:IsAvailable() and not PoolingForBladeDance() and not PoolingForMeta() and S.DarkSlash:IsReady();
end
-- variable,name=waiting_for_momentum,value=talent.momentum.enabled&!buff.momentum.up
local function WaitingForMomentum()
    return S.Momentum:IsAvailable() and not Player:BuffP(S.MomentumBuff);
end

-- variable,name=pooling_for_chaos_strike,value=talent.chaos_cleave.enabled&fury.deficit>40&!raid_event.adds.up&raid_event.adds.in<2*gcd
local function PoolingForChaosStrike()
    return false;
end

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");
-- Main APL
local function APL()
    if not Player:AffectingCombat() then
        return 0, 462338
    end

    if Player:IsChanneling(S.EyeBeam) or Player:IsChanneling(S.FelBarrage) then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end

    local function Cooldown()
        -- Locals for tracking if we should display these suggestions together

        -- metamorphosis,if=!(talent.demonic.enabled|variable.pooling_for_meta|variable.waiting_for_nemesis|variable.waiting_for_chaos_blades)|target.time_to_die<25
        if S.Metamorphosis:IsReady("Melee")
                and (not (S.Demonic:IsAvailable() or PoolingForMeta() or WaitingForNemesis() or WaitingForChaosBlades()) or Target:TimeToDie() < 25) then
            return S.Metamorphosis:Cast()

        end
        -- metamorphosis,if=talent.demonic.enabled&buff.metamorphosis.up
        if S.Metamorphosis:IsReady("Melee") and (S.Demonic:IsAvailable() and Player:BuffP(S.MetamorphosisBuff)) then
            return S.Metamorphosis:Cast()
        end
        -- chaos_blades,if=buff.metamorphosis.up|cooldown.metamorphosis.adjusted_remains>60|target.time_to_die<=duration
        if S.ChaosBlades:IsReady("Melee")
                and (Player:BuffP(S.MetamorphosisBuff) or MetamorphosisCooldownAdjusted() > 60 or Target:TimeToDie() <= 18) then
            return S.ChaosBlades:Cast()
        end
        -- nemesis,if=!raid_event.adds.exists&(buff.chaos_blades.up|buff.metamorphosis.up|cooldown.metamorphosis.adjusted_remains<20|target.time_to_die<=60)
        if S.Nemesis:IsAvailable() and S.Nemesis:IsReady("Melee") and ((Player:BuffP(S.ChaosBlades)
                or Player:BuffP(S.MetamorphosisBuff) or MetamorphosisCooldownAdjusted() < 20 or Target:TimeToDie() <= 60)) then
            return S.Nemesis:Cast()
        end

        if S.FelBarrage:IsReady() and Cache.EnemiesCount[8] >= 1 then
            return S.FelBarrage:Cast()
        end
        -- potion,if=buff.metamorphosis.remains>25|target.time_to_die<60
    end

    local function DarkSlash()
        -- dark_slash,if=fury>=80&(!variable.blade_dance|!cooldown.blade_dance.ready)
        if S.DarkSlash:IsReady("Melee") and ((Player:Fury() >= 80
                and (not BladeDance() or (not S.BladeDance:IsReady() and not S.DeathSweep:IsReadyMorph())))) then
            return S.DarkSlash:Cast()
        end
        -- annihilation,if=debuff.dark_slash.up
        if S.Annihilation:IsReadyMorph("Melee") and Target:DebuffP(S.DarkSlash) then
            return S.Annihilation:Cast()
        end
        -- chaos_strike,if=debuff.dark_slash.up
        if S.ChaosStrike:IsReady("Melee") and Target:DebuffP(S.DarkSlash) then
            return S.ChaosStrike:Cast()
        end
    end

    local function Demonic()
        local InMeleeRange = IsInMeleeRange()

        -- fel_barrage,if=active_enemies>desired_targets|raid_event.adds.in>30
        if RubimRH.config.Spells[3].isActive and S.FelBarrage:IsReady(8, true) then
            return S.FelBarrage:Cast()
        end
        -- death_sweep,if=variable.blade_dance
        if S.DeathSweep:IsReadyMorph(8, true) and BladeDance() then
            return S.DeathSweep:Cast()
        end
        -- blade_dance,if=variable.blade_dance&cooldown.eye_beam.remains>5&!cooldown.metamorphosis.ready
        if S.BladeDance:IsReady(8, true)
                and BladeDance() and S.EyeBeam:CooldownRemainsP() > 5 and not S.Metamorphosis:IsReady() then
            return S.BladeDance:Cast()
        end
        -- immolation_aura
        if S.ImmolationAura:IsAvailable() and S.ImmolationAura:IsReady(8, true) then
            return S.ImmolationAura:Cast()
        end
        -- felblade,if=fury<40|(buff.metamorphosis.down&fury.deficit>=40)
        if S.Felblade:IsReady(S.Felblade)
                and (Player:Fury() < 40 or (not Player:BuffP(S.MetamorphosisBuff) and Player:FuryDeficit() >= 40)) then
            return S.Felblade:Cast()
        end
        -- eye_beam,if=(!talent.blind_fury.enabled|fury.deficit>=70)&(!buff.metamorphosis.extended_by_demonic|(set_bonus.tier21_4pc&buff.metamorphosis.remains>16))
        if RubimRH.config.Spells[2].isActive and RubimRH.lastMoved() > 0.2 and S.EyeBeam:IsReady(20, true) and (not S.BlindFury:IsAvailable() or Player:FuryDeficit() >= 70)
                and (not IsMetaExtendedByDemonic() or (HL.Tier21_4Pc and Player:BuffRemainsP(S.MetamorphosisBuff) > 16)) then
            return S.EyeBeam:Cast()
        end
        -- annihilation,if=(talent.blind_fury.enabled|fury.deficit<30|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
        if InMeleeRange and S.Annihilation:IsReadyMorph("Melee")
                and (S.BlindFury:IsAvailable() or Player:FuryDeficit() < 30 or Player:BuffRemainsP(S.MetamorphosisBuff) < 5) and not PoolingForBladeDance() then
            return S.Annihilation:Cast()
        end
        -- chaos_strike,if=(talent.blind_fury.enabled|fury.deficit<30)&!variable.pooling_for_meta&!variable.pooling_for_blade_dance
        if InMeleeRange and S.ChaosStrike:IsReady("Melee")
                and (S.BlindFury:IsAvailable() or Player:FuryDeficit() < 30) and not PoolingForBladeDance() then
            return S.ChaosStrike:Cast()
        end
        -- fel_rush,if=talent.demon_blades.enabled&!cooldown.eye_beam.ready&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
        if RubimRH.config.Spells[1].isActive and S.FelRush:IsReady(20, true) and S.DemonBlades:IsAvailable() and not S.EyeBeam:IsReady() then
            return S.FelRush:Cast()
        end
        -- demons_bite
        if InMeleeRange and S.DemonsBite:IsReady() then
            return S.DemonsBite:Cast()
        end
        -- throw_glaive,if=buff.out_of_range.up
        if S.ThrowGlaive:IsReady(S.ThrowGlaive) and not IsInMeleeRange() then
            return S.ThrowGlaive:Cast()
        end
        -- fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
        if RubimRH.config.Spells[1].isActive and S.FelRush:IsReady(20) and (not IsInMeleeRange() and not S.Momentum:IsAvailable()) then
            return S.FelRush:Cast()
        end
        -- throw_glaive,if=talent.demon_blades.enabled
        if S.ThrowGlaive:IsReady(S.ThrowGlaive) and S.DemonBlades:IsAvailable() then
            return S.ThrowGlaive:Cast()
        end
    end

    local function Normal()
        local InMeleeRange = IsInMeleeRange()

        -- vengeful_retreat,if=talent.momentum.enabled&buff.prepared.down
        if S.VengefulRetreat:IsReady("Melee", true) and S.Momentum:IsAvailable() and S.FelRush:ChargesFractional() >= 1 then
            return S.VengefulRetreat:Cast()
        end
        -- fel_rush,if=(variable.waiting_for_momentum|talent.fel_mastery.enabled)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
        if RubimRH.config.Spells[1].isActive and S.FelRush:IsReady(20, true) and (S.Momentum:IsAvailable() or S.FelMastery:IsAvailable()) then
            return S.FelRush:Cast()
        end
        -- fel_barrage,if=!variable.waiting_for_momentum&(active_enemies>desired_targets|raid_event.adds.in>30)
        if RubimRH.config.Spells[3].isActive and S.FelBarrage:IsReady(8, true) and not WaitingForMomentum() then
            return S.FelBarrage:Cast()
        end
        -- immolation_aura
        if S.ImmolationAura:IsAvailable() and S.ImmolationAura:IsReady(8, true) then
            return S.ImmolationAura:Cast()
        end
        -- eye_beam,if=active_enemies>1&(!raid_event.adds.exists|raid_event.adds.up)&!variable.waiting_for_momentum
        if RubimRH.config.Spells[2].isActive and RubimRH.lastMoved() > 0.2 and S.EyeBeam:IsReady(20, true) and RubimRH.AoEON() and Cache.EnemiesCount[CleaveRangeID] > 1 and not WaitingForMomentum() then
            return S.EyeBeam:Cast()
        end
        -- death_sweep,if=variable.blade_dance
        if S.DeathSweep:IsReadyMorph(8, true) and BladeDance() then
            return S.DeathSweep:Cast()
        end
        -- blade_dance,if=variable.blade_dance
        if S.BladeDance:IsReady(8, true) and BladeDance() then
            return S.BladeDance:Cast()
        end
        -- felblade,if=fury.deficit>=40
        if S.Felblade:IsReady(S.Felblade) and Player:FuryDeficit() >= 40 then
            return S.Felblade:Cast()
        end
        -- eye_beam,if=!talent.blind_fury.enabled&!variable.waiting_for_dark_slash&raid_event.adds.in>cooldown
        if RubimRH.config.Spells[2].isActive and RubimRH.lastMoved() > 0.2 and S.EyeBeam:IsReady(20, true) and not S.BlindFury:IsAvailable() and not WaitingForDarkSlash() then
            return S.EyeBeam:Cast()
        end
        -- annihilation,if=(talent.demon_blades.enabled|!variable.waiting_for_momentum|fury.deficit<30|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance&!variable.waiting_for_dark_slash
        if InMeleeRange and S.Annihilation:IsReadyMorph("Melee")
                and (S.DemonBlades:IsAvailable() or not WaitingForMomentum() or Player:FuryDeficit() < 30 or Player:BuffRemainsP(S.MetamorphosisBuff) < 5)
                and not PoolingForBladeDance() and not WaitingForDarkSlash() then
            return S.Annihilation:Cast()
        end
        -- chaos_strike,if=(talent.demon_blades.enabled|!variable.waiting_for_momentum|fury.deficit<30)&!variable.pooling_for_meta&!variable.pooling_for_blade_dance&!variable.waiting_for_dark_slash
        if InMeleeRange and S.ChaosStrike:IsReady("Melee")
                and (S.DemonBlades:IsAvailable() or not WaitingForMomentum() or Player:FuryDeficit() < 30)
                and not PoolingForBladeDance() and not WaitingForDarkSlash() then
            return S.ChaosStrike:Cast()
        end
        -- eye_beam,if=talent.blind_fury.enabled&raid_event.adds.in>cooldown
        if RubimRH.config.Spells[2].isActive and RubimRH.lastMoved() > 0.2 and S.EyeBeam:IsReady(20, true) and S.BlindFury:IsAvailable() then
            return S.EyeBeam:Cast()
        end
        -- demons_bite
        if InMeleeRange and S.DemonsBite:IsReady() then
            return S.DemonsBite:Cast()
        end
        -- fel_rush,if=!talent.momentum.enabled&raid_event.movement.in>charges*10&talent.demon_blades.enabled
        if RubimRH.config.Spells[1].isActive and S.FelRush:IsReady(20) and not S.Momentum:IsAvailable() and S.DemonBlades:IsAvailable() then
            return S.FelRush:Cast()
        end
        -- felblade,if=movement.distance>15|buff.out_of_range.up
        if S.Felblade:IsReady(S.Felblade) and (not IsInMeleeRange()) then
            return S.Felblade:Cast()
        end
        -- fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
        if RubimRH.config.Spells[1].isActive and S.FelRush:IsReady(20) and (not IsInMeleeRange() and not S.Momentum:IsAvailable()) then
            return S.FelRush:Cast()
        end
        -- throw_glaive,if=talent.demon_blades.enabled
        if S.ThrowGlaive:IsReady(S.ThrowGlaive) and S.DemonBlades:IsAvailable() then
            return S.ThrowGlaive:Cast()
        end
    end

    -- Unit Update
    HL.GetEnemies(6, true); -- Fury of the Illidari
    HL.GetEnemies(8, true); -- Blade Dance/Chaos Nova
    HL.GetEnemies(S.ConsumeMagic, true); -- 20y, use for TG Bounce and Eye Beam
    HL.GetEnemies("Melee"); -- Melee

    -- call_action_list,name=cooldown,if=gcd.remains=0
    if RubimRH.CDsON() and Cooldown() ~= nil then
        return Cooldown()
    end

    -- actions+=/pick_up_fragment,if=fury.deficit>=35&((cooldown.eye_beam.remains>5|!talent.blind_fury.enabled&!set_bonus.tier21_4pc)|(buff.metamorphosis.up&!set_bonus.tier21_4pc))
    -- TODO: Can't detect when orbs actually spawn, we could possibly show a suggested icon when we DON'T want to pick up souls so people can avoid moving?

    -- call_action_list,name=dark_slash,if=talent.dark_slash.enabled&(variable.waiting_for_dark_slash|debuff.dark_slash.up)
    if S.DarkSlash:IsAvailable() and (WaitingForDarkSlash() or Target:DebuffP(S.DarkSlash)) and DarkSlash() ~= nil then
        return DarkSlash()
    end

    -- run_action_list,name=demonic,if=talent.demonic.enabled
    -- run_action_list,name=normal
    if S.Demonic:IsAvailable() and Demonic() ~= nil then
        return Demonic()
    end

    if Normal() ~= nil then
        return Normal()
    end

    return 0, 975743
end

RubimRH.Rotation.SetAPL(577, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(577, PASSIVE)

--# Executed every time the actor is available.
--actions=auto_attack
--actions+=/variable,name=blade_dance,value=talent.first_blood.enabled|set_bonus.tier20_4pc|spell_targets.blade_dance1>=3
--actions+=/variable,name=waiting_for_nemesis,value=!(!talent.nemesis.enabled|cooldown.nemesis.ready|cooldown.nemesis.remains>target.time_to_die|cooldown.nemesis.remains>60)
--actions+=/variable,name=pooling_for_meta,value=!talent.demonic.enabled&cooldown.metamorphosis.remains<6&fury.deficit>30&(!variable.waiting_for_nemesis|cooldown.nemesis.remains<10)
--actions+=/variable,name=pooling_for_blade_dance,value=variable.blade_dance&(fury<75-talent.first_blood.enabled*20)
--actions+=/variable,name=waiting_for_dark_slash,value=talent.dark_slash.enabled&!variable.pooling_for_blade_dance&!variable.pooling_for_meta&cooldown.dark_slash.up
--actions+=/variable,name=waiting_for_momentum,value=talent.momentum.enabled&!buff.momentum.up
--actions+=/disrupt
--actions+=/call_action_list,name=cooldown,if=gcd.remains=0
--actions+=/pick_up_fragment,if=fury.deficit>=35
--actions+=/call_action_list,name=dark_slash,if=talent.dark_slash.enabled&(variable.waiting_for_dark_slash|debuff.dark_slash.up)
--actions+=/run_action_list,name=demonic,if=talent.demonic.enabled
--actions+=/run_action_list,name=normal

--actions.cooldown=metamorphosis,if=!(talent.demonic.enabled|variable.pooling_for_meta|variable.waiting_for_nemesis)|target.time_to_die<25
--actions.cooldown+=/metamorphosis,if=talent.demonic.enabled&buff.metamorphosis.up
--actions.cooldown+=/nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&(active_enemies>desired_targets|raid_event.adds.in>60)
--actions.cooldown+=/nemesis,if=!raid_event.adds.exists
--actions.cooldown+=/potion,if=buff.metamorphosis.remains>25|target.time_to_die<60

--actions.dark_slash=dark_slash,if=fury>=80&(!variable.blade_dance|!cooldown.blade_dance.ready)
--actions.dark_slash+=/annihilation,if=debuff.dark_slash.up
--actions.dark_slash+=/chaos_strike,if=debuff.dark_slash.up

--actions.demonic=fel_barrage,if=active_enemies>desired_targets|raid_event.adds.in>30
--actions.demonic+=/death_sweep,if=variable.blade_dance
--actions.demonic+=/blade_dance,if=variable.blade_dance&cooldown.eye_beam.remains>5&!cooldown.metamorphosis.ready
--actions.demonic+=/immolation_aura
--actions.demonic+=/felblade,if=fury<40|(buff.metamorphosis.down&fury.deficit>=40)
--actions.demonic+=/eye_beam,if=(!talent.blind_fury.enabled|fury.deficit>=70)&(!buff.metamorphosis.extended_by_demonic|(set_bonus.tier21_4pc&buff.metamorphosis.remains>16))
--actions.demonic+=/annihilation,if=(talent.blind_fury.enabled|fury.deficit<30|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
--actions.demonic+=/chaos_strike,if=(talent.blind_fury.enabled|fury.deficit<30)&!variable.pooling_for_meta&!variable.pooling_for_blade_dance
--actions.demonic+=/fel_rush,if=talent.demon_blades.enabled&!cooldown.eye_beam.ready&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
--actions.demonic+=/demons_bite
--actions.demonic+=/throw_glaive,if=buff.out_of_range.up
--actions.demonic+=/fel_rush,if=movement.distance>15|buff.out_of_range.up
--actions.demonic+=/vengeful_retreat,if=movement.distance>15
--actions.demonic+=/throw_glaive,if=talent.demon_blades.enabled

--actions.normal=vengeful_retreat,if=talent.momentum.enabled&buff.prepared.down
--actions.normal+=/fel_rush,if=(variable.waiting_for_momentum|talent.fel_mastery.enabled)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
--actions.normal+=/fel_barrage,if=!variable.waiting_for_momentum&(active_enemies>desired_targets|raid_event.adds.in>30)
--actions.normal+=/immolation_aura
--actions.normal+=/eye_beam,if=active_enemies>1&(!raid_event.adds.exists|raid_event.adds.up)&!variable.waiting_for_momentum
--actions.normal+=/death_sweep,if=variable.blade_dance
--actions.normal+=/blade_dance,if=variable.blade_dance
--actions.normal+=/felblade,if=fury.deficit>=40
--actions.normal+=/eye_beam,if=!talent.blind_fury.enabled&!variable.waiting_for_dark_slash&raid_event.adds.in>cooldown
--actions.normal+=/annihilation,if=(talent.demon_blades.enabled|!variable.waiting_for_momentum|fury.deficit<30|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance&!variable.waiting_for_dark_slash
--actions.normal+=/chaos_strike,if=(talent.demon_blades.enabled|!variable.waiting_for_momentum|fury.deficit<30)&!variable.pooling_for_meta&!variable.pooling_for_blade_dance&!variable.waiting_for_dark_slash
--actions.normal+=/eye_beam,if=talent.blind_fury.enabled&raid_event.adds.in>cooldown
--actions.normal+=/demons_bite
--actions.normal+=/fel_rush,if=!talent.momentum.enabled&raid_event.movement.in>charges*10&talent.demon_blades.enabled
--actions.normal+=/felblade,if=movement.distance>15|buff.out_of_range.up
--actions.normal+=/fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
--actions.normal+=/vengeful_retreat,if=movement.distance>15
--actions.normal+=/throw_glaive,if=talent.demon_blades.enabled