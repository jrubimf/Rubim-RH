--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL         = HeroLib
local Cache      = HeroCache
local Unit       = HL.Unit
local Player     = Unit.Player
local Target     = Unit.Target
local Pet        = Unit.Pet
local Spell      = HL.Spell
--local MultiSpell = HL.MultiSpell
local Item       = HL.Item

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[577] = {
    -- Racials
    ArcaneTorrent          = Spell(202719),
    Shadowmeld             = Spell(58984),
	Berserking             = Spell(26297),
    BloodFury              = Spell(20572),
    Fireblood              = Spell(265221),
    -- Abilities
    Annihilation           = Spell(201427),
    BladeDance             = Spell(188499),
    ConsumeMagic           = Spell(278326),
    ChaosStrike            = Spell(162794),
    ChaosNova              = Spell(179057),
    Disrupt                = Spell(183752),
    DeathSweep             = Spell(210152),
    DemonsBite             = Spell(162243),
    EyeBeam                = Spell(198013),
    FelRush                = Spell(195072),
    Metamorphosis          = Spell(191427),
    MetamorphosisImpact    = Spell(200166),
    MetamorphosisBuff      = Spell(162264),
    ThrowGlaive            = Spell(185123),
    VengefulRetreat        = Spell(198793),
    -- Talents
    BlindFury              = Spell(203550),
    Bloodlet               = Spell(206473),
    ChaosBlades            = Spell(247938),
    ChaosCleave            = Spell(206475),
    DemonBlades            = Spell(203555),
    Demonic                = Spell(213410),
    DemonicAppetite        = Spell(206478),
    DemonReborn            = Spell(193897),
    Felblade               = Spell(232893),
    FelEruption            = Spell(211881),
    FelMastery             = Spell(192939),
    FirstBlood             = Spell(206416),
    MasterOfTheGlaive      = Spell(203556),
    Momentum               = Spell(206476),
    MomentumBuff           = Spell(208628),
    Nemesis                = Spell(206491),
    NemesisDebuff          = Spell(206491),
    TrailofRuin            = Spell(258881),
    -- Artifact
    Blur                   = Spell(198589),
    Darkness               = Spell(196718),
	RazorCoralDebuff       = Spell(303568),
    -- Talents
    ImmolationAura         = Spell(258920),
    FelBarrage             = Spell(258925),
    DarkSlash              = Spell(258860),
    DarkSlashDebuff        = Spell(258860),
    PreparedBuff           = Spell(203650),
    -- Set Bonuses
    T21_4pc_Buff           = Spell(252165),
    -- azerite
    RevolvingBlades        = Spell(279581),
    UnboundChaos           = Spell(275144),
    ChaoticTransformation  = Spell(288754),
    CyclotronicBlast       = Spell(293491),
    --8.2 Essences
    UnleashHeartOfAzeroth  = Spell(280431),
    BloodOfTheEnemy        = Spell(297108),
    BloodOfTheEnemy2       = Spell(298273),
    BloodOfTheEnemy3       = Spell(298277),
    ConcentratedFlame      = Spell(295373),
    ConcentratedFlame2     = Spell(299349),
    ConcentratedFlame3     = Spell(299353),
    GuardianOfAzeroth      = Spell(295840),
    GuardianOfAzeroth2     = Spell(299355),
    GuardianOfAzeroth3     = Spell(299358),
    FocusedAzeriteBeam     = Spell(295258),
    FocusedAzeriteBeam2    = Spell(299336),
    FocusedAzeriteBeam3    = Spell(299338),
    PurifyingBlast         = Spell(295337),
    PurifyingBlast2        = Spell(299345),
    PurifyingBlast3        = Spell(299347),
    TheUnboundForce        = Spell(298452),
    TheUnboundForce2       = Spell(299376),
    TheUnboundForce3       = Spell(299378),
    RippleInSpace          = Spell(302731),
    RippleInSpace2         = Spell(302982),
    RippleInSpace3         = Spell(302983),
    WorldveinResonance     = Spell(295186),
    WorldveinResonance2    = Spell(298628),
    WorldveinResonance3    = Spell(299334),
    MemoryOfLucidDreams    = Spell(298357),
    MemoryOfLucidDreams2   = Spell(299372),
    MemoryOfLucidDreams3   = Spell(299374),
}
local S = RubimRH.Spell[577]

-- Items
if not Item.DemonHunter then Item.DemonHunter = {} end
Item.DemonHunter.Havoc = {
  PotionofFocusedResolve           = Item(168506),
  AshvanesRazorCoral               = Item(169311),
  DribblingInkpod                  = Item(169319)
};
local I = Item.DemonHunter.Havoc;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- Interrupts List
local StunInterrupts = {
  {S.FelEruption, "Cast Fel Eruption (Interrupt)", function () return true; end},
  {S.ChaosNova, "Cast Chaos Nova (Interrupt)", function () return true; end},
};

-- Variables
local VarPoolingForMeta = 0;
local VarWaitingForNemesis = 0;
local VarBladeDance = 0;
local VarPoolingForBladeDance = 0;
local VarPoolingForEyeBeam = 0;
local VarWaitingForMomentum = 0;
local VarWaitingForDarkSlash = 0;

HL:RegisterForEvent(function()
  VarPoolingForMeta = 0
  VarWaitingForNemesis = 0
  VarBladeDance = 0
  VarPoolingForBladeDance = 0
  VarPoolingForEyeBeam = 0
  VarWaitingForMomentum = 0
  VarWaitingForDarkSlash = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {40, 20, 8}
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

-- Trinket var
local trinket2 = 1030910
local trinket1 = 1030902

-- Trinket Ready
local function trinketReady(trinketPosition)
        local inventoryPosition

        if trinketPosition == 1 then
                inventoryPosition = 13
        end
        if trinketPosition == 2 then
                inventoryPosition = 14
        end

        local start, duration, enable = GetInventoryItemCooldown("Player", inventoryPosition)

        if enable == 0 then
                return false
        end

        if start + duration - GetTime() > 0 then
                return false
        end

        return true
end

local function IsInMeleeRange()
  if S.Felblade:TimeSinceLastCast() <= Player:GCD() then
    return true
  elseif S.VengefulRetreat:TimeSinceLastCast() < 1.0 then
    return false
  end
  return Target:IsInRange("Melee")
end

local function DetermineEssenceRanks()
    S.BloodOfTheEnemy = S.BloodOfTheEnemy2:IsAvailable() and S.BloodOfTheEnemy2 or S.BloodOfTheEnemy;
    S.BloodOfTheEnemy = S.BloodOfTheEnemy3:IsAvailable() and S.BloodOfTheEnemy3 or S.BloodOfTheEnemy;
    S.MemoryOfLucidDreams = S.MemoryOfLucidDreams2:IsAvailable() and S.MemoryOfLucidDreams2 or S.MemoryOfLucidDreams;
    S.MemoryOfLucidDreams = S.MemoryOfLucidDreams3:IsAvailable() and S.MemoryOfLucidDreams3 or S.MemoryOfLucidDreams;
    S.PurifyingBlast = S.PurifyingBlast2:IsAvailable() and S.PurifyingBlast2 or S.PurifyingBlast;
    S.PurifyingBlast = S.PurifyingBlast3:IsAvailable() and S.PurifyingBlast3 or S.PurifyingBlast;
    S.RippleInSpace = S.RippleInSpace2:IsAvailable() and S.RippleInSpace2 or S.RippleInSpace;
    S.RippleInSpace = S.RippleInSpace3:IsAvailable() and S.RippleInSpace3 or S.RippleInSpace;
    S.ConcentratedFlame = S.ConcentratedFlame2:IsAvailable() and S.ConcentratedFlame2 or S.ConcentratedFlame;
    S.ConcentratedFlame = S.ConcentratedFlame3:IsAvailable() and S.ConcentratedFlame3 or S.ConcentratedFlame;
    S.TheUnboundForce = S.TheUnboundForce2:IsAvailable() and S.TheUnboundForce2 or S.TheUnboundForce;
    S.TheUnboundForce = S.TheUnboundForce3:IsAvailable() and S.TheUnboundForce3 or S.TheUnboundForce;
    S.WorldveinResonance = S.WorldveinResonance2:IsAvailable() and S.WorldveinResonance2 or S.WorldveinResonance;
    S.WorldveinResonance = S.WorldveinResonance3:IsAvailable() and S.WorldveinResonance3 or S.WorldveinResonance;
    S.FocusedAzeriteBeam = S.FocusedAzeriteBeam2:IsAvailable() and S.FocusedAzeriteBeam2 or S.FocusedAzeriteBeam;
    S.FocusedAzeriteBeam = S.FocusedAzeriteBeam3:IsAvailable() and S.FocusedAzeriteBeam3 or S.FocusedAzeriteBeam;
    S.GuardianOfAzeroth = S.GuardianOfAzeroth2:IsAvailable() and S.GuardianOfAzeroth2 or S.GuardianOfAzeroth;
    S.GuardianOfAzeroth = S.GuardianOfAzeroth3:IsAvailable() and S.GuardianOfAzeroth3 or S.GuardianOfAzeroth;
end
-- Register Splash Data Nucleus Abilities
--HL.RegisterNucleusAbility(191427, 8, 6)               -- Metamorphosis
--HL.RegisterNucleusAbility(198013, 20, 6)              -- Eye Beam
--HL.RegisterNucleusAbility(188499, 8, 6)               -- Blade Dance
--HL.RegisterNucleusAbility(210152, 8, 6)               -- Death Sweep
--HL.RegisterNucleusAbility(258920, 8, 6)               -- Immolation Aura
--HL.RegisterNucleusAbility(179057, 8, 6)               -- Chaos Nova

--- ======= ACTION LISTS =======
local function APL()
  local Precombat_DBM, Precombat, Essences, Cooldown, DarkSlash, Demonic, Normal
  UpdateRanges()
  DetermineEssenceRanks()
    
	Precombat_DBM = function()
        -- flask
        -- augmentation
        -- food
        -- snapshot_stats
        -- potion
	    if I.PotionofFocusedResolve:IsReady() and RubimRH.DBM_PullTimer() > Player:GCD() and RubimRH.DBM_PullTimer() <= 2 then
            return 967532
        end
        -- metamorphosis
        if S.Metamorphosis:IsCastable() and Player:BuffDownP(S.MetamorphosisBuff) and RubimRH.CDsON() and RubimRH.DBM_PullTimer() > 0.1 and RubimRH.DBM_PullTimer() <= 0.5 then
            return S.Metamorphosis:Cast()
        end
		-- demons_bite
        if S.DemonsBite:IsReady() and IsInMeleeRange() and (true) and RubimRH.DBM_PullTimer() >= 0.1 and RubimRH.DBM_PullTimer() <= 0.2 then
            return S.DemonsBite:Cast()
        end
        return 0, 462338
    end
  
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- snapshot_stats
    -- potion
    -- Immolation Aura
    if S.ImmolationAura:IsReady() then
      return S.ImmolationAura:Cast()
    end
    -- metamorphosis,if=!azerite.chaotic_transformation.enabled
    if S.Metamorphosis:IsReady(40) and RubimRH.CDsON() and (Player:BuffDownP(S.MetamorphosisBuff) and not S.ChaoticTransformation:AzeriteEnabled()) then
      return S.Metamorphosis:Cast()
    end
  end
 
  Essences = function()
    -- concentrated_flame
    if S.ConcentratedFlame:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- blood_of_the_enemy,if=buff.metamorphosis.up|target.time_to_die<=10
    if S.BloodOfTheEnemy:IsReady() and (Player:BuffP(S.MetamorphosisBuff) or Target:TimeToDie() <= 10) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth
    if S.GuardianOfAzeroth:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- focused_azerite_beam,if=spell_targets.blade_dance1>=2|raid_event.adds.in>60
    if S.FocusedAzeriteBeam:IsReady() and (Cache.EnemiesCount[8] >= 2) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast,if=spell_targets.blade_dance1>=2|raid_event.adds.in>60
    if S.PurifyingBlast:IsReady() and (Cache.EnemiesCount[8] >= 2) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force
    if S.TheUnboundForce:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space
    if S.RippleInSpace:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance,if=buff.lifeblood.stack<3
    if S.WorldveinResonance:IsReady() and (Player:BuffStackP(S.Lifeblood) < 3) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams,if=fury<40&buff.metamorphosis.up
    if S.MemoryOfLucidDreams:IsReady() and (Player:Fury() < 40 and Player:BuffP(S.MetamorphosisBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
  end
  
  Cooldown = function()
    -- metamorphosis,if=!(talent.demonic.enabled|variable.pooling_for_meta|variable.waiting_for_nemesis)|target.time_to_die<25
    if S.Metamorphosis:IsReady(40) and (Player:BuffDownP(S.MetamorphosisBuff) and not (S.Demonic:IsAvailable() or bool(VarPoolingForMeta) or bool(VarWaitingForNemesis)) or Target:TimeToDie() < 25) then
      return S.Metamorphosis:Cast()
    end
    -- metamorphosis,if=talent.demonic.enabled&(!azerite.chaotic_transformation.enabled|(cooldown.eye_beam.remains>20&cooldown.blade_dance.remains>gcd.max))
    if S.Metamorphosis:IsReady(40) and (Player:BuffDownP(S.MetamorphosisBuff) and S.Demonic:IsAvailable() and (not S.ChaoticTransformation:AzeriteEnabled() or (S.EyeBeam:CooldownRemainsP() > 12 and S.BladeDance:CooldownRemainsP() > Player:GCD()))) then
      return S.Metamorphosis:Cast()
    end
    -- nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&(active_enemies>desired_targets|raid_event.adds.in>60)
    -- nemesis,if=!raid_event.adds.exists
    if S.Nemesis:IsReady(50) and (not Cache.EnemiesCount[40] > 1) then
      return S.Nemesis:Cast()
    end
	-- berserking,if=buff.metamorphosis.up
    if S.Berserking:IsReady() and RubimRH.CDsON() and Player:BuffP(S.MetamorphosisBuff) then
      return S.Berserking:Cast()
    end
    -- blood_fury,if=buff.metamorphosis.up
    if S.BloodFury:IsReady() and RubimRH.CDsON() and Player:BuffP(S.MetamorphosisBuff) then
      return S.BloodFury:Cast()
    end
    -- fireblood,if=buff.metamorphosis.up
    if S.Fireblood:IsReady() and RubimRH.CDsON() and Player:BuffP(S.MetamorphosisBuff) then
      return S.Fireblood:Cast()
    end
    -- potion,if=buff.metamorphosis.remains>25|target.time_to_die<60
    -- use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.down|(!equipped.dribbling_inkpod&(buff.metamorphosis.remains>20|target.time_to_die<20))|(equipped.dribbling_inkpod&target.health.pct<31)
    if I.AshvanesRazorCoral:IsReady() and (Target:DebuffDownP(S.RazorCoralDebuff) or (not I.DribblingInkpod:IsEquipped() and (Player:BuffRemainsP(S.MetamorphosisBuff) > 20 or Target:TimeToDie() < 20)) or (I.DribblingInkpod:IsEquipped() and Target:HealthPercentage() < 31)) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
	-- all trinkets
	if RubimRH.TargetIsValid() and RubimRH.CDsON() then
		if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- call_action_list,name=essences
    if (true) then
      local ShouldReturn = Essences(); if ShouldReturn then return ShouldReturn; end
    end
  end
 
  DarkSlash = function()
    -- dark_slash,if=fury>=80&(!variable.blade_dance|!cooldown.blade_dance.ready)
    if S.DarkSlash:IsReady() and IsInMeleeRange() and (Player:Fury() >= 80 and (not bool(VarBladeDance) or not S.BladeDance:CooldownUpP())) then
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
    if S.DeathSweep:IsReadyMorph() and IsInMeleeRange() and (bool(VarBladeDance)) then
      return S.DeathSweep:Cast()
    end
    -- eye_beam,if=raid_event.adds.up|raid_event.adds.in>25
    if S.EyeBeam:IsReady(20) then
      return S.EyeBeam:Cast()
    end
    -- fel_barrage,if=((!cooldown.eye_beam.up|buff.metamorphosis.up)&raid_event.adds.in>30)|active_enemies>desired_targets
    if S.FelBarrage:IsReady() and IsInMeleeRange() and (not S.EyeBeam:CooldownUpP() or Player:BuffP(S.MetamorphosisBuff) or Cache.EnemiesCount[8] > 1) then
      return S.FelBarrage:Cast()
    end
    -- blade_dance,if=variable.blade_dance&!cooldown.metamorphosis.ready&(cooldown.eye_beam.remains>(5-azerite.revolving_blades.rank*3)|(raid_event.adds.in>cooldown&raid_event.adds.in<25))
    if S.BladeDance:IsReady() and IsInMeleeRange() and bool(VarBladeDance) and (S.EyeBeam:CooldownRemainsP() > (5 - S.RevolvingBlades:AzeriteRank() * 3)) then
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
    if S.Felblade:IsReady(15) and (Player:FuryDeficit() >= 40) then
      return S.Felblade:Cast()
    end
    -- chaos_strike,if=!variable.pooling_for_blade_dance&!variable.pooling_for_eye_beam
    if S.ChaosStrike:IsReady() and IsInMeleeRange() and not bool(VarPoolingForBladeDance) and not bool(VarPoolingForEyeBeam) then
      return S.ChaosStrike:Cast()
    end
    -- fel_rush,if=talent.demon_blades.enabled&!cooldown.eye_beam.ready&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
    if S.FelRush:IsReady(20, true) and (S.DemonBlades:IsAvailable() and not S.EyeBeam:CooldownUpP()) then
        return S.FelRush:Cast()
    end
    -- demons_bite
    if S.DemonsBite:IsReady() and IsInMeleeRange() then
      return S.DemonsBite:Cast()
    end
    -- throw_glaive,if=buff.out_of_range.up
    if S.ThrowGlaive:IsReady(30) and (not IsInMeleeRange()) then
      return S.ThrowGlaive:Cast()
    end
    -- fel_rush,if=movement.distance>15|buff.out_of_range.up
    -- if S.FelRush:IsReady(20, true) and (not IsInMeleeRange() and ConserveFelRush()) then
      -- if CastFelRush:Cast()
    -- end
    -- vengeful_retreat,if=movement.distance>15
    -- if S.VengefulRetreat:IsReady("Melee", true) then
      -- return S.VengefulRetreat:Cast()vengeful_retreat 143"; end
    -- end
    -- throw_glaive,if=talent.demon_blades.enabled
    if S.ThrowGlaive:IsReady(30) and (S.DemonBlades:IsAvailable()) then
      return S.ThrowGlaive:Cast()
    end
  end
  
  Normal = function()
    -- vengeful_retreat,if=talent.momentum.enabled&buff.prepared.down&time>1
    if S.VengefulRetreat:IsReady("Melee", true) and (S.Momentum:IsAvailable() and Player:BuffDownP(S.PreparedBuff) and HL.CombatTime() > 1) then
      return S.VengefulRetreat:Cast()
    end
    -- fel_rush,if=(variable.waiting_for_momentum|talent.fel_mastery.enabled)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
    if S.FelRush:IsReady(20, true) and ((bool(VarWaitingForMomentum) or S.FelMastery:IsAvailable())) then
        return S.FelRush:Cast()
    end
    -- fel_barrage,if=!variable.waiting_for_momentum&(active_enemies>desired_targets|raid_event.adds.in>30)
    if S.FelBarrage:IsReady() and IsInMeleeRange() and not bool(VarWaitingForMomentum) and Cache.EnemiesCount[8] > 1 then
      return S.FelBarrage:Cast()
    end
    -- death_sweep,if=variable.blade_dance
    if S.DeathSweep:IsReadyMorph() and IsInMeleeRange() and (bool(VarBladeDance)) then
      return S.DeathSweep:Cast()
    end
    -- immolation_aura
    if S.ImmolationAura:IsReady() then
      return S.ImmolationAura:Cast()
    end
    -- eye_beam,if=active_enemies>1&(!raid_event.adds.exists|raid_event.adds.up)&!variable.waiting_for_momentum
    if S.EyeBeam:IsReady(20) and (Cache.EnemiesCount[20] > 1 and not bool(VarWaitingForMomentum)) then
      return S.EyeBeam:Cast()
    end
    -- blade_dance,if=variable.blade_dance
    if S.BladeDance:IsReady() and IsInMeleeRange() and (bool(VarBladeDance)) then
      return S.BladeDance:Cast()
    end
    -- felblade,if=fury.deficit>=40
    if S.Felblade:IsReady(15) and (Player:FuryDeficit() >= 40) then
      return S.Felblade:Cast()
    end
    -- eye_beam,if=!talent.blind_fury.enabled&!variable.waiting_for_dark_slash&raid_event.adds.in>cooldown
    if S.EyeBeam:IsReady(20) and (not S.BlindFury:IsAvailable() and not bool(VarWaitingForDarkSlash)) then
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
    if S.EyeBeam:IsReady(20) and (S.BlindFury:IsAvailable()) then
      return S.EyeBeam:Cast()
    end
    -- demons_bite
    if S.DemonsBite:IsReady() and IsInMeleeRange() then
      return S.DemonsBite:Cast()
    end
    -- fel_rush,if=!talent.momentum.enabled&raid_event.movement.in>charges*10&talent.demon_blades.enabled
    if S.FelRush:IsReady(20, true) and (not S.Momentum:IsAvailable() and S.DemonBlades:IsAvailable()) then
      return S.FelRush:Cast()
    end
    -- felblade,if=movement.distance>15|buff.out_of_range.up
    -- if S.Felblade:IsReady(15) and (not IsInMeleeRange()) then
      -- return S.Felblade:Cast()felblade 255"; end
    -- end
    -- fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
    -- if S.FelRush:IsReady(20, true) and (not IsInMeleeRange() and not S.Momentum:IsAvailable() and ConserveFelRush()) then
      -- if CastFelRush(:Cast()fel_rush 259"; end
    -- end
    -- vengeful_retreat,if=movement.distance>15
    -- if S.VengefulRetreat:IsReady("Melee", true) then
      -- return S.VengefulRetreat:Cast()vengeful_retreat 265"; end
    -- end
    -- throw_glaive,if=talent.demon_blades.enabled
    if S.ThrowGlaive:IsReady(30) and (S.DemonBlades:IsAvailable()) then
      return S.ThrowGlaive:Cast()
    end
  end
  
    -- Protect against interrupt of channeled spells
  if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) or Player:IsChanneling() then
      return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
  end 

  -- Call combat
  if RubimRH.TargetIsValid() then
    if QueueSkill() ~= nil then
		return QueueSkill()
    end    
    -- auto_attack
    
    -- Set Variables
    -- variable,name=blade_dance,value=talent.first_blood.enabled|spell_targets.blade_dance1>=(3-talent.trail_of_ruin.enabled)
    VarBladeDance = num(S.FirstBlood:IsAvailable() or Cache.EnemiesCount[8] >= (3 - num(S.TrailofRuin:IsAvailable())))
    -- variable,name=waiting_for_nemesis,value=!(!talent.nemesis.enabled|cooldown.nemesis.ready|cooldown.nemesis.remains>target.time_to_die|cooldown.nemesis.remains>60)
    VarWaitingForNemesis = num(not (not S.Nemesis:IsAvailable() or S.Nemesis:CooldownUpP() or S.Nemesis:CooldownRemainsP() > Target:TimeToDie() or S.Nemesis:CooldownRemainsP() > 60))
    -- variable,name=pooling_for_meta,value=!talent.demonic.enabled&cooldown.metamorphosis.remains<6&fury.deficit>30&(!variable.waiting_for_nemesis|cooldown.nemesis.remains<10)
    VarPoolingForMeta = num(not S.Demonic:IsAvailable() and S.Metamorphosis:CooldownRemainsP() < 6 and Player:FuryDeficit() > 30 and (not bool(VarWaitingForNemesis) or S.Nemesis:CooldownRemainsP() < 10))
    -- variable,name=pooling_for_blade_dance,value=variable.blade_dance&(fury<75-talent.first_blood.enabled*20)
    VarPoolingForBladeDance = num(bool(VarBladeDance) and (Player:Fury() < 75 - num(S.FirstBlood:IsAvailable()) * 20))
    -- variable,name=pooling_for_eye_beam,value=talent.demonic.enabled&!talent.blind_fury.enabled&cooldown.eye_beam.remains<(gcd.max*2)&fury.deficit>20
    VarPoolingForEyeBeam = num(S.Demonic:IsAvailable() and not S.BlindFury:IsAvailable() and S.EyeBeam:CooldownRemainsP() < (Player:GCD() * 2) and Player:FuryDeficit() > 20)
    -- variable,name=waiting_for_dark_slash,value=talent.dark_slash.enabled&!variable.pooling_for_blade_dance&!variable.pooling_for_meta&cooldown.dark_slash.up
    VarWaitingForDarkSlash = num(S.DarkSlash:IsAvailable() and not bool(VarPoolingForBladeDance) and not bool(VarPoolingForMeta) and S.DarkSlash:CooldownUpP())
    -- variable,name=waiting_for_momentum,value=talent.momentum.enabled&!buff.momentum.up
    VarWaitingForMomentum = num(S.Momentum:IsAvailable() and not Player:BuffP(S.MomentumBuff))
    
	-- call DBM precombat
	if not Player:AffectingCombat() and RubimRH.PrecombatON() and RubimRH.PerfectPullON() and not Target:IsQuestMob() then
        return Precombat_DBM()
	end
    -- call non DBM precombat
	if not Player:AffectingCombat() and RubimRH.PrecombatON() and not RubimRH.PerfectPullON() and not Target:IsQuestMob() then		
        return Precombat()
	end
    
    -- Utilities
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
    if RubimRH.CDsON() then
      local ShouldReturn = Cooldown(); if ShouldReturn then return ShouldReturn; end
    end
    
    -- pick_up_fragment,if=fury.deficit>=35
    -- TODO: Can't detect when orbs actually spawn, we could possibly show a suggested icon when we DON'T want to pick up souls so people can avoid moving?
    
    -- call_action_list,name=dark_slash,if=talent.dark_slash.enabled&(variable.waiting_for_dark_slash|debuff.dark_slash.up)
    if (S.DarkSlash:IsAvailable() and (bool(VarWaitingForDarkSlash) or Target:DebuffP(S.DarkSlashDebuff))) then
      local ShouldReturn = DarkSlash(); if ShouldReturn then return ShouldReturn; end
    end
    
    -- run_action_list,name=demonic,if=talent.demonic.enabled
    if (S.Demonic:IsAvailable()) then
      local ShouldReturn = Demonic(); if ShouldReturn then return ShouldReturn; end
    end
    
    -- run_action_list,name=normal
    if (true) then
      local ShouldReturn = Normal(); if ShouldReturn then return ShouldReturn; end
    end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(577, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(577, PASSIVE)