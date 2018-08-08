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
    ArcaneTorrent = Spell(80483),
    Shadowmeld = Spell(58984),
    -- Abilities
    Annihilation = Spell(201427),
    BladeDance = Spell(188499),
    ConsumeMagic = Spell(183752),
    ChaosStrike = Spell(162794),
    ChaosNova = Spell(179057),
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
    TrailofRuin = Spell(258881),
    -- Set Bonuses
    T21_4pc_Buff = Spell(252165),
}


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


-- Rotation Var
local CleaveRangeID = tostring(S.ConsumeMagic:ID()); -- 20y range

local EnemyRanges = { "Melee", 8, 20, 30, 40 }
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

local function num(val)
    if val then
        return 1
    else
        return 0
    end
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

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

-- Variables
local VarPoolingForMeta = 0;
local VarWaitingForNemesis = 0;
local VarBladeDance = 0;
local VarPoolingForBladeDance = 0;
local VarWaitingForMomentum = 0;
local VarWaitingForDarkSlash = 0;

-- Spells Config
--{ spellID = FelRush, isActive = true },
--{ spellID = EyeBeam, isActive = true },
--{ spellID = FelBarrage, isActive = true }

-- Main APL
local function APL()
    local Precombat, Cooldown, DarkSlash, Demonic, Normal
    UpdateRanges()

    if Player:IsChanneling(S.EyeBeam) or Player:IsChanneling(S.FelBarrage) then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
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
        --if S.Metamorphosis:IsReady() and Player:BuffDownP(S.MetamorphosisBuff) then
        --return S.Metamorphosis:Cast()
        --end
        return 0, 462338
    end

    Cooldown = function()
        -- metamorphosis,if=!(talent.demonic.enabled|variable.pooling_for_meta|variable.waiting_for_nemesis)|target.time_to_die<25
        if S.Metamorphosis:IsReady() and (not (S.Demonic:IsAvailable() or bool(VarPoolingForMeta) or bool(VarWaitingForNemesis)) or Target:TimeToDie() < 25) then
            return S.Metamorphosis:Cast()
        end
        -- metamorphosis,if=talent.demonic.enabled&buff.metamorphosis.up
        if S.Metamorphosis:IsReady() and (S.Demonic:IsAvailable() and Player:BuffP(S.MetamorphosisBuff)) then
            return S.Metamorphosis:Cast()
        end
        -- nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&(active_enemies>desired_targets|raid_event.adds.in>60)
        if S.Nemesis:IsReady() and (Target:DebuffDownP(S.NemesisDebuff) and (Cache.EnemiesCount[40] > 1)) then
            return S.Nemesis:Cast()
        end
        -- nemesis,if=!raid_event.adds.exists
        if S.Nemesis:IsReady() then
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
        -- fel_barrage,if=active_enemies>desired_targets|raid_event.adds.in>30
        if S.FelBarrage:IsReady() and (Cache.EnemiesCount[30] > 1 or 10000000000 > 30) then
            return S.FelBarrage:Cast()
        end
        -- death_sweep,if=variable.blade_dance
        if S.DeathSweep:IsReadyMorph() and (bool(VarBladeDance)) then
            return S.DeathSweep:Cast()
        end
        -- blade_dance,if=variable.blade_dance&cooldown.eye_beam.remains>5&!cooldown.metamorphosis.ready
        if S.BladeDance:IsReady() and (bool(VarBladeDance) and S.EyeBeam:CooldownRemainsP() > 5 and not S.Metamorphosis:CooldownUpP()) then
            return S.BladeDance:Cast()
        end
        -- immolation_aura
        if S.ImmolationAura:IsReady() and (true) then
            return S.ImmolationAura:Cast()
        end
        -- felblade,if=fury<40|(buff.metamorphosis.down&fury.deficit>=40)
        if S.Felblade:IsReady() and (Player:Fury() < 40 or (Player:BuffDownP(S.MetamorphosisBuff) and Player:FuryDeficit() >= 40)) then
            return S.Felblade:Cast()
        end
        -- eye_beam,if=(!talent.blind_fury.enabled|fury.deficit>=70)&(!buff.metamorphosis.extended_by_demonic|(set_bonus.tier21_4pc&buff.metamorphosis.remains>16))
        if S.EyeBeam:IsReady() and ((not S.BlindFury:IsAvailable() or Player:FuryDeficit() >= 70) and (not IsMetaExtendedByDemonic() or (HL.Tier21_4Pc and Player:BuffRemainsP(S.MetamorphosisBuff) > 16))) then
            return S.EyeBeam:Cast()
        end
        -- annihilation,if=(talent.blind_fury.enabled|fury.deficit<30|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
        if S.Annihilation:IsReadyMorph() and IsInMeleeRange() and ((S.BlindFury:IsAvailable() or Player:FuryDeficit() < 30 or Player:BuffRemainsP(S.MetamorphosisBuff) < 5) and not bool(VarPoolingForBladeDance)) then
            return S.Annihilation:Cast()
        end
        -- chaos_strike,if=(talent.blind_fury.enabled|fury.deficit<30)&!variable.pooling_for_meta&!variable.pooling_for_blade_dance
        if S.ChaosStrike:IsReady() and IsInMeleeRange() and ((S.BlindFury:IsAvailable() or Player:FuryDeficit() < 30) and not bool(VarPoolingForMeta) and not bool(VarPoolingForBladeDance)) then
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
        if S.ThrowGlaive:IsReady() and (Target:MaxDistanceToPlayer(True) > 10) then
            return S.ThrowGlaive:Cast()
        end
        -- fel_rush,if=movement.distance>15|buff.out_of_range.up
        if S.FelRush:IsReady() and (Target:MaxDistanceToPlayer(True) > 10) then
            return S.FelRush:Cast()
        end
        -- vengeful_retreat,if=movement.distance>15
        --if S.VengefulRetreat:IsReady() and (Target:MaxDistanceToPlayer(True) > 10) then
          --  return S.VengefulRetreat:Cast()
        --end
        -- throw_glaive,if=talent.demon_blades.enabled
        if S.ThrowGlaive:IsReady() and (S.DemonBlades:IsAvailable()) then
            return S.ThrowGlaive:Cast()
        end
        return 0, 135328
    end

    Normal = function()
        -- vengeful_retreat,if=talent.momentum.enabled&buff.prepared.down
        if S.VengefulRetreat:IsReady() and (S.Momentum:IsAvailable() and Player:BuffDownP(S.PreparedBuff)) then
            return S.VengefulRetreat:Cast()
        end
        -- fel_rush,if=(variable.waiting_for_momentum|talent.fel_mastery.enabled)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
        if S.FelRush:IsReady() and ((bool(VarWaitingForMomentum) or S.FelMastery:IsAvailable()) and (S.FelRush:ChargesP() == 2 or (10000000000 > 10 and 10000000000 > 10))) then
            return S.FelRush:Cast()
        end
        -- fel_barrage,if=!variable.waiting_for_momentum&(active_enemies>desired_targets|raid_event.adds.in>30)
        if S.FelBarrage:IsReady() and (not bool(VarWaitingForMomentum) and (Cache.EnemiesCount[30] > 1 or 10000000000 > 30)) then
            return S.FelBarrage:Cast()
        end
        -- immolation_aura
        if S.ImmolationAura:IsReady() and (true) then
            return S.ImmolationAura:Cast()
        end
        -- eye_beam,if=active_enemies>1&(!raid_event.adds.exists|raid_event.adds.up)&!variable.waiting_for_momentum
        if S.EyeBeam:IsReady() and (Cache.EnemiesCount[20] > 1 and (not false or false) and not bool(VarWaitingForMomentum)) then
            return S.EyeBeam:Cast()
        end
        -- death_sweep,if=variable.blade_dance
        if S.DeathSweep:IsReadyMorph() and (bool(VarBladeDance)) then
            return S.DeathSweep:Cast()
        end
        -- blade_dance,if=variable.blade_dance
        if S.BladeDance:IsReady() and (bool(VarBladeDance)) then
            return S.BladeDance:Cast()
        end
        -- felblade,if=fury.deficit>=40
        if S.Felblade:IsReady() and (Player:FuryDeficit() >= 40) then
            return S.Felblade:Cast()
        end
        -- eye_beam,if=!talent.blind_fury.enabled&!variable.waiting_for_dark_slash&raid_event.adds.in>cooldown
        if S.EyeBeam:IsReady() and (not S.BlindFury:IsAvailable() and not bool(VarWaitingForDarkSlash) and 10000000000 > S.EyeBeam:Cooldown()) then
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
        if S.EyeBeam:IsReady() and (S.BlindFury:IsAvailable()) then
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
        if S.Felblade:IsReady() and (Target:MaxDistanceToPlayer(True) > 15) then
            return S.Felblade:Cast()
        end
        -- fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
        if S.FelRush:IsReady() and (Target:MaxDistanceToPlayer(True) > 15 or (Target:MaxDistanceToPlayer(True) > 15 and not S.Momentum:IsAvailable())) then
            return S.FelRush:Cast()
        end
        -- vengeful_retreat,if=movement.distance>15
        if S.VengefulRetreat:IsReady() and (Target:MaxDistanceToPlayer(True) > 15) then
            return S.VengefulRetreat:Cast()
        end
        -- throw_glaive,if=talent.demon_blades.enabled
        if S.ThrowGlaive:IsReady() and (S.DemonBlades:IsAvailable()) then
            return S.ThrowGlaive:Cast()
        end
        return 0, 135328
    end

    if not Player:AffectingCombat() then
        return Precombat()
    end

    if (true) then
        VarBladeDance = num(S.FirstBlood:IsAvailable() or HL.Tier20_4Pc or Cache.EnemiesCount[8] >= (3 - num(S.TrailofRuin:IsAvailable())))
    end
    -- variable,name=waiting_for_nemesis,value=!(!talent.nemesis.enabled|cooldown.nemesis.ready|cooldown.nemesis.remains>target.time_to_die|cooldown.nemesis.remains>60)
    if (true) then
        VarWaitingForNemesis = num(RubimRH.CDsON() == false or (not (not S.Nemesis:IsAvailable() or S.Nemesis:CooldownUpP() or S.Nemesis:CooldownRemainsP() > Target:TimeToDie() or S.Nemesis:CooldownRemainsP() > 60)))
    end
    -- variable,name=pooling_for_meta,value=!talent.demonic.enabled&cooldown.metamorphosis.remains<6&fury.deficit>30&(!variable.waiting_for_nemesis|cooldown.nemesis.remains<10)
    if (true) then
        VarPoolingForMeta = num(RubimRH.CDsON() == false or (not S.Demonic:IsAvailable() and S.Metamorphosis:CooldownRemainsP() < 6 and Player:FuryDeficit() > 30 and (not bool(VarWaitingForNemesis) or S.Nemesis:CooldownRemainsP() < 10)))
    end
    -- variable,name=pooling_for_blade_dance,value=variable.blade_dance&(fury<75-talent.first_blood.enabled*20)
    if (true) then
        VarPoolingForBladeDance = num(bool(VarBladeDance) and (Player:Fury() < 75 - num(S.FirstBlood:IsAvailable()) * 20))
    end
    -- variable,name=waiting_for_dark_slash,value=talent.dark_slash.enabled&!variable.pooling_for_blade_dance&!variable.pooling_for_meta&cooldown.dark_slash.up
    if (true) then
        VarWaitingForDarkSlash = num(S.DarkSlash:IsAvailable() and not bool(VarPoolingForBladeDance) and not bool(VarPoolingForMeta) and S.DarkSlash:CooldownUpP())
    end
    -- variable,name=waiting_for_momentum,value=talent.momentum.enabled&!buff.momentum.up
    if (true) then
        VarWaitingForMomentum = num(S.Momentum:IsAvailable() and not Player:BuffP(S.MomentumBuff))
    end

    if S.Darkness:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[577].darkness then
        return S.Darkness:Cast()
    end

    if S.Blur:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[577].blur then
        return S.Blur:Cast()
    end

    -- disrupt
    --if S.Disrupt:IsReady() and (true) then
        --return S.Disrupt:Cast()
    --end
    -- call_action_list,name=cooldown,if=gcd.remains=0
    if Cooldown() ~= nil and (Player:GCDRemains() == 0) and RubimRH.CDsON() then
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