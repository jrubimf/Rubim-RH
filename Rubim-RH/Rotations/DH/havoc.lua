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
--Havoc
RubimRH.Spell[577] = {
    -- Racials
    ArcaneTorrent = Spell(202719),
    Shadowmeld = Spell(58984),
    -- Abilities
    Annihilation = Spell(201427),
    BladeDance = Spell(188499),
    ConsumeMagic = Spell(278326),
    ChaosStrike = Spell(162794),
    ChaosNova = Spell(179057),
    Disrupt = Spell(183752),
    DeathSweep = Spell(210152),
    DemonsBite = Spell(162243),
    EyeBeam = Spell(198013),
    FelRush = Spell(195072),
    Metamorphosis = Spell(191427),
    MetamorphosisImpact = Spell(200166),
    MetamorphosisBuff = Spell(162264),
    ThrowGlaive = Spell(185123),
    VengefulRetreat = Spell(198793),
    -- Talents
    BlindFury = Spell(203550),
    Bloodlet = Spell(206473),
    ChaosBlades = Spell(247938),
    ChaosCleave = Spell(206475),
    DemonBlades = Spell(203555),
    Demonic = Spell(213410),
    DemonicAppetite = Spell(206478),
    DemonReborn = Spell(193897),
    Felblade = Spell(232893),
    FelEruption = Spell(211881),
    FelMastery = Spell(192939),
    FirstBlood = Spell(206416),
    MasterOfTheGlaive = Spell(203556),
    Momentum = Spell(206476),
    MomentumBuff = Spell(208628),
    Nemesis = Spell(206491),
    NemesisDebuff = Spell(206491),
    TrailofRuin = Spell(258881),
    -- Artifact
    Blur = Spell(198589),
    Darkness = Spell(196718),
    -- Talents
    ImmolationAura = Spell(258920),
    FelBarrage = Spell(258925),
    DarkSlash = Spell(258860),
    DarkSlashDebuff = Spell(258860),
    PreparedBuff = Spell(203650),
    -- Set Bonuses
    T21_4pc_Buff = Spell(252165),
    -- azerite
    RevolvingBlades = Spell(279581),
    UnboundChaos = Spell(275144),
    ChaoticTransformation = Spell(288754),
}


if not Item.DemonHunter then
    Item.DemonHunter = {};
end
Item.DemonHunter.Havoc = {};
local I = Item.DemonHunter.Havoc;
local S = RubimRH.Spell[577]

S.Annihilation.TextureSpellID = { 204317 }
S.DeathSweep.TextureSpellID = { 199552 }
S.Metamorphosis.TextureSpellID = { 187827 }


-- Rotation Var
local CleaveRangeID = tostring(S.ConsumeMagic:ID()); -- 20y range

local EnemyRanges = {40, 30, 20, 8}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function IsInMeleeRange()
    if S.Felblade:TimeSinceLastCast() <= Player:GCD() then
        return true
    elseif S.VengefulRetreat:TimeSinceLastCast() < 1.0 then
        return false
    end

    if RubimRH.db.profile.mainOption.startattack and Cache.EnemiesCount[8] >= 1 then
        return true
    end

    return Target:IsInRange("Melee")
end

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


local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

-- Variables
local VarPoolingForMeta = 0;
local VarWaitingForNemesis = 0;
local VarBladeDance = 0;
local VarPoolingForBladeDance = 0;
local VarPoolingForEyeBeam = 0;
local VarWaitingForMomentum = 0;
local VarWaitingForDarkSlash = 0;

-- Spells Config
--{ spellID = FelRush, isActive = true },
--{ spellID = EyeBeam, isActive = true },
--{ spellID = FelBarrage, isActive = true }

HL:RegisterForEvent(function()
  VarPoolingForMeta = 0
  VarWaitingForNemesis = 0
  VarBladeDance = 0
  VarPoolingForBladeDance = 0
  VarPoolingForEyeBeam = 0
  VarWaitingForMomentum = 0
  VarWaitingForDarkSlash = 0
end, "PLAYER_REGEN_ENABLED")

local OffensiveCDs = {
    S.Nemesis,
    S.Metamorphosis,
}

local function UpdateCDs()
    RubimRH.db.profile.mainOption.disabledSpellsCD = {}
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

-- Main APL
local function APL()
    local Precombat, Cooldown, DarkSlash, Demonic, Normal
    UpdateRanges()
    UpdateCDs()

    if Player:IsChanneling(S.EyeBeam) or Player:IsChanneling(S.FelBarrage) then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end

    if QueueSkill() ~= nil then
        return QueueSkill()
    end

    Precombat = function()
        -- flask
        -- augmentation
        -- food
        -- snapshot_stats
        -- potion
        --if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
        --return S.ProlongedPower:Cast()
        --end
        -- metamorphosis
        --if S.Metamorphosis:IsCastable() and Player:BuffDownP(S.MetamorphosisBuff) then
        --return S.Metamorphosis:Cast()
        --end
        return 0, 462338
    end

    Cooldown = function()
        -- metamorphosis,if=!(talent.demonic.enabled|variable.pooling_for_meta|variable.waiting_for_nemesis)|target.time_to_die<25
        if S.Metamorphosis:IsCastable() and (not (S.Demonic:IsAvailable() or bool(VarPoolingForMeta) or bool(VarWaitingForNemesis)) or Target:TimeToDie() < 25) then
            return S.Metamorphosis:Cast()
        end
        -- metamorphosis,if=talent.demonic.enabled&(!azerite.chaotic_transformation.enabled|(cooldown.eye_beam.remains>20&cooldown.blade_dance.remains>gcd.max))
        if S.Metamorphosis:IsCastable() and (S.Demonic:IsAvailable() and (not S.ChaoticTransformation:AzeriteEnabled() or (S.EyeBeam:CooldownRemainsP() > 20 and S.BladeDance:CooldownRemainsP() > Player:GCD()))) then
            return S.Metamorphosis:Cast()
        end
        -- nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&(active_enemies>desired_targets|raid_event.adds.in>60)
        if S.Nemesis:IsReady() and (Target:DebuffDownP(S.NemesisDebuff) and (Cache.EnemiesCount[40] > 1)) then
            return S.Nemesis:Cast()
        end
        -- nemesis,if=!raid_event.adds.exists
        if S.Nemesis:IsReady() and (not (Cache.EnemiesCount[40] > 1)) then
            return S.Nemesis:Cast()
        end
        -- potion,if=buff.metamorphosis.remains>25|target.time_to_die<60
        --if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffRemainsP(S.MetamorphosisBuff) > 25 or Target:TimeToDie() < 60) then
        --return S.ProlongedPower:Cast()
        --end
        -- use_item,name=galecallers_boon
        --if I.GalecallersBoon:IsReady() and (true) then
        --return S.GalecallersBoon:Cast()
        --end
        -- use_item,name=lustrous_golden_plumage
        --if I.LustrousGoldenPlumage:IsReady() and (true) then
        --return S.LustrousGoldenPlumage:Cast()
        --end
    end

    DarkSlash = function()
        -- dark_slash,if=fury>=80&(!variable.blade_dance|!cooldown.blade_dance.ready)
        if S.DarkSlash:IsReady() and (Player:Fury() >= 80 and (not bool(VarBladeDance) or not S.BladeDance:CooldownUpP())) then
            return S.DarkSlash:Cast()
        end
        -- annihilation,if=debuff.dark_slash.up
        if S.Annihilation:IsReadyMorph() and IsInMeleeRange() and (Target:DebuffP(S.DarkSlashDebuff)) then
            return S.Annihilation:Cast()
        end
        -- chaos_strike,if=debuff.dark_slash.up
        if S.ChaosStrike:IsReady() and IsInMeleeRange() and (Target:DebuffP(S.DarkSlashDebuff)) then
            return S.ChaosStrike:Cast()
        end
    end

    Demonic = function()
        -- death_sweep,if=variable.blade_dance
        if S.DeathSweep:IsReadyMorph() and Cache.EnemiesCount[8] >= 1 and (bool(VarBladeDance)) then
            return S.DeathSweep:Cast()
        end
        -- eye_beam,if=raid_event.adds.up|raid_event.adds.in>25
        if S.EyeBeam:IsReady() and ((Cache.EnemiesCount[20] > 1) or 10000000000 > 25) then
            return S.EyeBeam:Cast()
        end
        -- fel_barrage,if=((!cooldown.eye_beam.up|buff.metamorphosis.up)&raid_event.adds.in>30)|active_enemies>desired_targets
        if S.FelBarrage:IsReady() and (((not S.EyeBeam:CooldownUpP() or Player:BuffP(S.MetamorphosisBuff)) and 10000000000 > 30) or Cache.EnemiesCount[30] > 1) then
            return S.FelBarrage:Cast()
        end
        -- blade_dance,if=variable.blade_dance&!cooldown.metamorphosis.ready&(cooldown.eye_beam.remains>(5-azerite.revolving_blades.rank*3)|(raid_event.adds.in>cooldown&raid_event.adds.in<25))
        -- blade_dance,if=variable.blade_dance&!cooldown.metamorphosis.ready&(cooldown.eye_beam.remains>(5-azerite.revolving_blades.rank*3)|(raid_event.adds.in>cooldown&raid_event.adds.in<25))
        if S.BladeDance:IsReady() and Cache.EnemiesCount[8] >= 1 and (bool(VarBladeDance) and not S.Metamorphosis:CooldownUpP() and (S.EyeBeam:CooldownRemainsP() > (5 - S.RevolvingBlades:AzeriteRank() * 3) or (10000000000 > S.BladeDance:CooldownRemains() and 10000000000 < 25))) then
            return S.BladeDance:Cast()
        end
        -- immolation_aura
        if S.ImmolationAura:IsReady() then
            return S.ImmolationAura:Cast()
        end
        -- annihilation,if=!variable.pooling_for_blade_dance
        if S.Annihilation:IsReadyMorph() and IsInMeleeRange() and (not bool(VarPoolingForBladeDance)) then
            return S.Annihilation:Cast()
        end
        -- felblade,if=fury.deficit>=40
        if S.Felblade:IsReady() and (Player:FuryDeficit() >= 40) then
            return S.Felblade:Cast()
        end
        -- chaos_strike,if=!variable.pooling_for_blade_dance&!variable.pooling_for_eye_beam
        if S.ChaosStrike:IsReady() and IsInMeleeRange() and (not bool(VarPoolingForBladeDance) and not bool(VarPoolingForEyeBeam)) then
            return S.ChaosStrike:Cast()
        end
        -- fel_rush,if=talent.demon_blades.enabled&!cooldown.eye_beam.ready&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
        if S.FelRush:IsReady() and (S.DemonBlades:IsAvailable() and not S.EyeBeam:CooldownUpP() and (S.FelRush:ChargesP() == 2 or (10000000000 > 10 and 10000000000 > 10))) then
            return S.FelRush:Cast()
        end
        -- demons_bite
        if S.DemonsBite:IsReady() and IsInMeleeRange() and (true) then
            return S.DemonsBite:Cast()
        end
        -- throw_glaive,if=buff.out_of_range.up
        if S.ThrowGlaive:IsReady() and (Target:MaxDistanceToPlayer(true) > 10) then
            return S.ThrowGlaive:Cast()
        end
        -- fel_rush,if=movement.distance>15|buff.out_of_range.up
        if S.FelRush:IsReady() and (Target:MaxDistanceToPlayer(true) > 10) then
            return S.FelRush:Cast()
        end
        -- vengeful_retreat,if=movement.distance>15
        --if S.VengefulRetreat:IsReady() and (Target:MaxDistanceToPlayer(true) > 10) then
          --  return S.VengefulRetreat:Cast()
        --end
        -- throw_glaive,if=talent.demon_blades.enabled
        if S.ThrowGlaive:IsReady() and (S.DemonBlades:IsAvailable()) then
            return S.ThrowGlaive:Cast()
        end
        return 0, 135328
    end

    Normal = function()
        -- vengeful_retreat,if=talent.momentum.enabled&buff.prepared.down&time>1
        if S.VengefulRetreat:IsReady() and (S.Momentum:IsAvailable() and Player:BuffDownP(S.PreparedBuff) and HL.CombatTime() > 1) then
            return S.VengefulRetreat:Cast()
        end
        -- fel_rush,if=(variable.waiting_for_momentum|talent.fel_mastery.enabled)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
        if S.FelRush:IsReady() and ((bool(VarWaitingForMomentum) or S.FelMastery:IsAvailable()) and (S.FelRush:ChargesP() == 2 or (10000000000 > 10 and 10000000000 > 10))) then
            return S.FelRush:Cast()
        end
        -- fel_barrage,if=!variable.waiting_for_momentum&(active_enemies>desired_targets|raid_event.adds.in>30)
        if S.FelBarrage:IsReady() and (not bool(VarWaitingForMomentum) and (Cache.EnemiesCount[30] > 1)) then
            return S.FelBarrage:Cast()
        end
        -- death_sweep,if=variable.blade_dance
        if S.DeathSweep:IsReadyMorph() and Cache.EnemiesCount[8] >= 1 and (bool(VarBladeDance)) then
            return S.DeathSweep:Cast()
        end
        -- immolation_aura
        if S.ImmolationAura:IsReady() and (true) then
            return S.ImmolationAura:Cast()
        end
        -- eye_beam,if=active_enemies>1&(!raid_event.adds.exists|raid_event.adds.up)&!variable.waiting_for_momentum
        if S.EyeBeam:IsReady() and Cache.EnemiesCount[10] >= 1 and (Cache.EnemiesCount[10] >= 1 and not bool(VarWaitingForMomentum)) then
            return S.EyeBeam:Cast()
        end
        -- blade_dance,if=variable.blade_dance
        if S.BladeDance:IsReady() and  Cache.EnemiesCount[8] >= 1 and (bool(VarBladeDance)) then
            return S.BladeDance:Cast()
        end
        -- fel_rush,if=!talent.momentum.enabled&!talent.demon_blades.enabled&azerite.unbound_chaos.enabled
        if S.FelRush:IsReady() and (not S.Momentum:IsAvailable() and not S.DemonBlades:IsAvailable() and S.UnboundChaos:AzeriteEnabled()) then
            return S.FelRush:Cast()
        end
        -- felblade,if=fury.deficit>=40
        if S.Felblade:IsReady() and (Player:FuryDeficit() >= 40) then
            return S.Felblade:Cast()
        end
        -- eye_beam,if=!talent.blind_fury.enabled&!variable.waiting_for_dark_slash&raid_event.adds.in>cooldown
        if S.EyeBeam:IsReady() and Cache.EnemiesCount[10] >= 1 and (not S.BlindFury:IsAvailable() and not bool(VarWaitingForDarkSlash)) then
            return S.EyeBeam:Cast()
        end
        -- annihilation,if=(talent.demon_blades.enabled|!variable.waiting_for_momentum|fury.deficit<30|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance&!variable.waiting_for_dark_slash
        if S.Annihilation:IsReadyMorph() and IsInMeleeRange() and ((S.DemonBlades:IsAvailable() or not bool(VarWaitingForMomentum) or Player:FuryDeficit() < 30 or Player:BuffRemainsP(S.MetamorphosisBuff) < 5) and not bool(VarPoolingForBladeDance) and not bool(VarWaitingForDarkSlash)) then
            return S.Annihilation:Cast()
        end
        -- chaos_strike,if=(talent.demon_blades.enabled|!variable.waiting_for_momentum|fury.deficit<30)&!variable.pooling_for_meta&!variable.pooling_for_blade_dance&!variable.waiting_for_dark_slash
        if S.ChaosStrike:IsReady() and IsInMeleeRange() and ((S.DemonBlades:IsAvailable() or not bool(VarWaitingForMomentum) or Player:FuryDeficit() < 30) and not bool(VarPoolingForMeta) and not bool(VarPoolingForBladeDance) and not bool(VarWaitingForDarkSlash)) then
            return S.ChaosStrike:Cast()
        end
        -- eye_beam,if=talent.blind_fury.enabled&raid_event.adds.in>cooldown
        if S.EyeBeam:IsReady() and Cache.EnemiesCount[10] >= 1 and (S.BlindFury:IsAvailable()) then
            return S.EyeBeam:Cast()
        end
        -- demons_bite
        if S.DemonsBite:IsReady() and IsInMeleeRange() and (true) then
            return S.DemonsBite:Cast()
        end
        -- fel_rush,if=!talent.momentum.enabled&raid_event.movement.in>charges*10&talent.demon_blades.enabled
        if S.FelRush:IsReady() and (not S.Momentum:IsAvailable() and S.DemonBlades:IsAvailable()) then
            return S.FelRush:Cast()
        end
        -- felblade,if=movement.distance>15|buff.out_of_range.up
        if S.Felblade:IsReady() and (Target:MaxDistanceToPlayer(true) > 15) then
            return S.Felblade:Cast()
        end
        -- fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
        if S.FelRush:IsReady() and (Target:MaxDistanceToPlayer(true) > 15 or (Target:MaxDistanceToPlayer(true) > 15 and not S.Momentum:IsAvailable())) then
            return S.FelRush:Cast()
        end
        -- vengeful_retreat,if=movement.distance>15
        if S.VengefulRetreat:IsReady() and (Target:MaxDistanceToPlayer(true) > 15) then
            return S.VengefulRetreat:Cast()
        end
        -- throw_glaive,if=talent.demon_blades.enabled
        if S.ThrowGlaive:IsReady() and (S.DemonBlades:IsAvailable()) then
            return S.ThrowGlaive:Cast()
        end
        return 0, 135328
    end

    if not Player:AffectingCombat() and not Target:IsQuestMob() then
        return Precombat()
    end

     -- variable,name=blade_dance,value=talent.first_blood.enabled|spell_targets.blade_dance1>=(3-talent.trail_of_ruin.enabled)
     if (true) then
     VarBladeDance = num(S.FirstBlood:IsAvailable() or Cache.EnemiesCount[8] >= (3 - num(S.TrailofRuin:IsAvailable())))
   end
   -- variable,name=waiting_for_nemesis,value=!(!talent.nemesis.enabled|cooldown.nemesis.ready|cooldown.nemesis.remains>target.time_to_die|cooldown.nemesis.remains>60)
   if (true) then
     VarWaitingForNemesis = num(not (not S.Nemesis:IsAvailable() or S.Nemesis:CooldownUpP() or S.Nemesis:CooldownRemainsP() > Target:TimeToDie() or S.Nemesis:CooldownRemainsP() > 60))
   end
   -- variable,name=pooling_for_meta,value=!talent.demonic.enabled&cooldown.metamorphosis.remains<6&fury.deficit>30&(!variable.waiting_for_nemesis|cooldown.nemesis.remains<10)
   if (true) then
     VarPoolingForMeta = num(not S.Demonic:IsAvailable() and S.Metamorphosis:CooldownRemainsP() < 6 and Player:FuryDeficit() > 30 and (not bool(VarWaitingForNemesis) or S.Nemesis:CooldownRemainsP() < 10))
   end
   -- variable,name=pooling_for_blade_dance,value=variable.blade_dance&(fury<75-talent.first_blood.enabled*20)
   if (true) then
     VarPoolingForBladeDance = num(bool(VarBladeDance) and (Player:Fury() < 75 - num(S.FirstBlood:IsAvailable()) * 20))
   end
   -- variable,name=pooling_for_eye_beam,value=talent.demonic.enabled&!talent.blind_fury.enabled&cooldown.eye_beam.remains<(gcd.max*2)&fury.deficit>20
   if (true) then
     VarPoolingForEyeBeam = num(S.Demonic:IsAvailable() and not S.BlindFury:IsAvailable() and S.EyeBeam:CooldownRemainsP() < (Player:GCD() * 2) and Player:FuryDeficit() > 20)
   end
   -- variable,name=waiting_for_dark_slash,value=talent.dark_slash.enabled&!variable.pooling_for_blade_dance&!variable.pooling_for_meta&cooldown.dark_slash.up
   if (true) then
     VarWaitingForDarkSlash = num(S.DarkSlash:IsAvailable() and not bool(VarPoolingForBladeDance) and not bool(VarPoolingForMeta) and S.DarkSlash:CooldownUpP())
   end
   -- variable,name=waiting_for_momentum,value=talent.momentum.enabled&!buff.momentum.up
   if (true) then
     VarWaitingForMomentum = num(S.Momentum:IsAvailable() and not Player:BuffP(S.MomentumBuff))
   end

    if S.Darkness:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[577].sk2 then
        return S.Darkness:Cast()
    end

    if S.Blur:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[577].sk1 then
        return S.Blur:Cast()
    end

    -- disrupt
    if S.Disrupt:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Disrupt:Cast()
    end

    if S.ConsumeMagic:IsReady() and Target:HasStealableBuff() then
        return S.ConsumeMagic:Cast()
    end

    -- call_action_list,name=cooldown,if=gcd.remains=0
    if Cooldown() ~= nil then
        return Cooldown()
    end
    -- pick_up_fragment,if=fury.deficit>=35
    --if S.PickUpFragment:IsReady() and (Player:FuryDeficit() >= 35) then
        --return S.PickUpFragment:Cast()
    --end
    -- call_action_list,name=dark_slash,if=talent.dark_slash.enabled&(variable.waiting_for_dark_slash|debuff.dark_slash.up)
    if DarkSlash() ~= nil and (S.DarkSlash:IsAvailable() and (bool(VarWaitingForDarkSlash) or Target:DebuffP(S.DarkSlashDebuff))) then
        return DarkSlash()
    end
    -- run_action_list,name=demonic,if=talent.demonic.enabled
    if (S.Demonic:IsAvailable()) then
        return Demonic();
    end
    -- run_action_list,name=normal
    if (true) then
        return Normal();
    end

    return 0, 135328
end

RubimRH.Rotation.SetAPL(577, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(577, PASSIVE)
