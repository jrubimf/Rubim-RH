--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item
local mainAddon = RubimRH

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[MFrost] = {
  ArcaneIntellectBuff                   = Spell(1459),
  ArcaneIntellect                       = Spell(1459),
  SummonWaterElemental                  = Spell(31687),
  MirrorImage                           = Spell(55342),
  Frostbolt                             = Spell(116),
  FrozenOrb                             = Spell(84714),
  Blizzard                              = Spell(190356),
  CometStorm                            = Spell(153595),
  IceNova                               = Spell(157997),
  Flurry                                = Spell(44614),
  Ebonbolt                              = Spell(257537),
  BrainFreezeBuff                       = Spell(190446),
  IciclesBuff                           = Spell(205473),
  GlacialSpike                          = Spell(199786),
  IceLance                              = Spell(30455),
  FingersofFrostBuff                    = Spell(44544),
  RayofFrost                            = Spell(205021),
  ConeofCold                            = Spell(120),
  IcyVeins                              = Spell(12472),
  RuneofPower                           = Spell(116011),
  RuneofPowerBuff                       = Spell(116014),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Shimmer                               = Spell(212653),
  Blink                                 = Spell(1953),
  IceFloes                              = Spell(108839),
  IceFloesBuff                          = Spell(108839),
  WintersChillDebuff                    = Spell(228358),
  GlacialSpikeBuff                      = Spell(199844),
  SplittingIce                          = Spell(56377),
  FreezingRain                          = Spell(240555),
  Counterspell                          = Spell(2139),
  Invisibility                          = Spell(66),
  Freeze                                = Spell(33395),
  Spellsteal                            = Spell(30449),
  IceBarrier                            = Spell(11426),
  IceBlock                              = Spell(45438),
  --[[BloodOfTheEnemy                       = MultiSpell(297108, 298273, 298277),
  MemoryOfLucidDreams                   = MultiSpell(298357, 299372, 299374),
  PurifyingBlast                        = MultiSpell(295337, 299345, 299347),
  RippleInSpace                         = MultiSpell(302731, 302982, 302983),
  ConcentratedFlame                     = MultiSpell(295373, 299349, 299353),
  TheUnboundForce                       = MultiSpell(298452, 299376, 299378),
  WorldveinResonance                    = MultiSpell(295186, 298628, 299334),
  FocusedAzeriteBeam                    = MultiSpell(295258, 299336, 299338),
  GuardianOfAzeroth                     = MultiSpell(295840, 299355, 299358),]]--
  --8.2 Essences
  UnleashHeartOfAzeroth                 = Spell(280431),
  BloodOfTheEnemy                       = Spell(297108),
  BloodOfTheEnemy2                      = Spell(298273),
  BloodOfTheEnemy3                      = Spell(298277),
  ConcentratedFlame                     = Spell(295373),
  ConcentratedFlame2                    = Spell(299349),
  ConcentratedFlame3                    = Spell(299353),
  GuardianOfAzeroth                     = Spell(295840),
  GuardianOfAzeroth2                    = Spell(299355),
  GuardianOfAzeroth3                    = Spell(299358),
  FocusedAzeriteBeam                    = Spell(295258),
  FocusedAzeriteBeam2                   = Spell(299336),
  FocusedAzeriteBeam3                   = Spell(299338),
  PurifyingBlast                        = Spell(295337),
  PurifyingBlast2                       = Spell(299345),
  PurifyingBlast3                       = Spell(299347),
  TheUnboundForce                       = Spell(298452),
  TheUnboundForce2                      = Spell(299376),
  TheUnboundForce3                      = Spell(299378),
  RippleInSpace                         = Spell(302731),
  RippleInSpace2                        = Spell(302982),
  RippleInSpace3                        = Spell(302983),
  WorldveinResonance                    = Spell(295186),
  WorldveinResonance2                   = Spell(298628),
  WorldveinResonance3                   = Spell(299334),
  MemoryOfLucidDreams                   = Spell(298357),
  MemoryOfLucidDreams2                  = Spell(299372),
  MemoryOfLucidDreams3                  = Spell(299374),
  RecklessForce                         = Spell(302932),
  RecklessForce                         = Spell(302932),
};
local S = RubimRH.Spell[MFrost]

-- Items
if not Item.Mage then Item.Mage = {} end
Item.Mage.Frost = {
  ProlongedPower                   = Item(142117),
  TidestormCodex                   = Item(165576)
};
local I = Item.Mage.Frost;

-- Rotation Var
local ShouldReturn; -- Used to get the return string
local EnemiesCount;

local EnemyRanges = {40, 35, 10}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end



local function GetEnemiesCount(range)
   local UseSplashData = false;
  -- Unit Update - Update differently depending on if splash data is being used
  if RubimRH.AoEON() then
    if UseSplashData then
      HL.GetEnemies(range, nil, true, Target)
      return Cache.EnemiesCount[range]
    else
      UpdateRanges()
      return Cache.EnemiesCount[40]
    end
  else
    return 1
  end
end

S.FrozenOrb:RegisterInFlight()

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

S.FrozenOrb.EffectID = 84721
S.Frostbolt:RegisterInFlight()

--HL.RegisterNucleusAbility(84714, 8, 6)               -- Frost Orb
--HL.RegisterNucleusAbility(190356, 8, 6)              -- Blizzard
--HL.RegisterNucleusAbility(153595, 8, 6)              -- Comet Storm
--HL.RegisterNucleusAbility(120, 12, 6)                -- Cone of Cold

local function DetermineEssenceRanks()
  S.BloodOfTheEnemy = S.BloodOfTheEnemy2:IsAvailable() and S.BloodOfTheEnemy2 or S.BloodOfTheEnemy
  S.BloodOfTheEnemy = S.BloodOfTheEnemy3:IsAvailable() and S.BloodOfTheEnemy3 or S.BloodOfTheEnemy
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams2:IsAvailable() and S.MemoryOfLucidDreams2 or S.MemoryOfLucidDreams
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams3:IsAvailable() and S.MemoryOfLucidDreams3 or S.MemoryOfLucidDreams
  S.PurifyingBlast = S.PurifyingBlast2:IsAvailable() and S.PurifyingBlast2 or S.PurifyingBlast
  S.PurifyingBlast = S.PurifyingBlast3:IsAvailable() and S.PurifyingBlast3 or S.PurifyingBlast
  S.RippleInSpace = S.RippleInSpace2:IsAvailable() and S.RippleInSpace2 or S.RippleInSpace
  S.RippleInSpace = S.RippleInSpace3:IsAvailable() and S.RippleInSpace3 or S.RippleInSpace
  S.ConcentratedFlame = S.ConcentratedFlame2:IsAvailable() and S.ConcentratedFlame2 or S.ConcentratedFlame
  S.ConcentratedFlame = S.ConcentratedFlame3:IsAvailable() and S.ConcentratedFlame3 or S.ConcentratedFlame
  S.TheUnboundForce = S.TheUnboundForce2:IsAvailable() and S.TheUnboundForce2 or S.TheUnboundForce
  S.TheUnboundForce = S.TheUnboundForce3:IsAvailable() and S.TheUnboundForce3 or S.TheUnboundForce
  S.WorldveinResonance = S.WorldveinResonance2:IsAvailable() and S.WorldveinResonance2 or S.WorldveinResonance
  S.WorldveinResonance = S.WorldveinResonance3:IsAvailable() and S.WorldveinResonance3 or S.WorldveinResonance
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam2:IsAvailable() and S.FocusedAzeriteBeam2 or S.FocusedAzeriteBeam
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam3:IsAvailable() and S.FocusedAzeriteBeam3 or S.FocusedAzeriteBeam
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, Cooldowns, Movement, Single, TalentRop, Essences
  local BlinkAny = S.Shimmer:IsAvailable() and S.Shimmer or S.Blink
  EnemiesCount = GetEnemiesCount(8)
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- arcane_intellect
    if S.ArcaneIntellect:IsCastableP() and Player:BuffDownP(S.ArcaneIntellectBuff, true) then
      return S.ArcaneIntellect:Cast()
    end
    -- summon_water_elemental
    if S.SummonWaterElemental:IsCastableP() and not Pet:Exists() then
      return S.SummonWaterElemental:Cast()
    end
    -- snapshot_stats
    if RubimRH.TargetIsValid() then
      -- mirror_image
      if S.MirrorImage:IsCastableP() and RubimRH.CDsON() then
        return S.MirrorImage:Cast()
      end
      -- potion

      -- frostbolt
      if S.Frostbolt:IsCastableP() then
        return S.Frostbolt:Cast()
      end
    end
  end
 
 Essences = function()
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      return S.FocusedAzeriteBeam:Cast()
    end
    -- memory_of_lucid_dreams,if=buff.icicles.stack<2
    if S.MemoryOfLucidDreams:IsCastableP() and (Player:BuffStackP(S.IciclesBuff) < 2) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- blood_of_the_enemy,if=buff.icicles.stack=5&buff.brain_freeze.react|!talent.glacial_spike.enabled|active_enemies>4
    if S.BloodOfTheEnemy:IsCastableP() and (Player:BuffStackP(S.IciclesBuff) == 5 and Player:BuffP(S.BrainFreezeBuff) or not S.GlacialSpike:IsAvailable() or EnemiesCount > 4) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force,if=buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForce)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
  end
  
  Aoe = function()
    -- frozen_orb
    if S.FrozenOrb:IsCastableP() then
      return S.FrozenOrb:Cast()
    end
    -- blizzard
    if S.Blizzard:IsCastableP() then
      return S.Blizzard:Cast()
    end
    -- call_action_list,name=essences
    local ShouldReturn = Essences(); 
	if ShouldReturn and (true) then 
	    return ShouldReturn; 
	end
    -- comet_storm
    if S.CometStorm:IsCastableP() then
      return S.CometStorm:Cast()
    end
    -- ice_nova
    if S.IceNova:IsCastableP() then
      return S.IceNova:Cast()
    end
    -- flurry,if=prev_gcd.1.ebonbolt|buff.brain_freeze.react&(prev_gcd.1.frostbolt&(buff.icicles.stack<4|!talent.glacial_spike.enabled)|prev_gcd.1.glacial_spike)
    if S.Flurry:IsCastableP() and (Player:PrevGCDP(1, S.Ebonbolt) or bool(Player:BuffStackP(S.BrainFreezeBuff)) and (Player:PrevGCDP(1, S.Frostbolt) and (Player:BuffStackP(S.IciclesBuff) < 4 or not S.GlacialSpike:IsAvailable()) or Player:PrevGCDP(1, S.GlacialSpike))) then
      return S.Flurry:Cast()
    end
    -- ice_lance,if=buff.fingers_of_frost.react
    if S.IceLance:IsCastableP() and (bool(Player:BuffStackP(S.FingersofFrostBuff))) then
      return S.IceLance:Cast()
    end
    -- ray_of_frost
    if S.RayofFrost:IsCastableP() then
      return S.RayofFrost:Cast()
    end
    -- ebonbolt
    if S.Ebonbolt:IsCastableP() then
      return S.Ebonbolt:Cast()
    end
    -- glacial_spike
    if S.GlacialSpike:IsCastableP() and Player:BuffStackP(S.IciclesBuff) == 5 then
      return S.GlacialSpike:Cast()
    end
    -- cone_of_cold
    if S.ConeofCold:IsCastableP() and (EnemiesCount >= 1) then
      return S.ConeofCold:Cast()
    end
    -- use_item,name=tidestorm_codex,if=buff.icy_veins.down&buff.rune_of_power.down
    --if I.TidestormCodex:IsReady() and (Player:BuffDownP(S.IcyVeins) and Player:BuffDownP(S.RuneofPowerBuff)) then
    --  if RubimRH.Cast(I.TidestormCodex:Cast()
    --end
    -- frostbolt
    if S.Frostbolt:IsCastableP() then
      return S.Frostbolt:Cast()
    end
    -- call_action_list,name=movement
    if (true) then
      local ShouldReturn = Movement(); 
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
    -- ice_lance
    if S.IceLance:IsCastableP() then
      return S.IceLance:Cast()
    end
  end
  
  Cooldowns = function()
    -- guardian_of_azeroth
    if S.GuardianOfAzeroth:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- icy_veins
    if S.IcyVeins:IsCastableP() and RubimRH.CDsON() then
      return S.IcyVeins:Cast()
    end
    -- mirror_image
    if S.MirrorImage:IsCastableP() and RubimRH.CDsON() then
      return S.MirrorImage:Cast()
    end
    -- rune_of_power,if=prev_gcd.1.frozen_orb|target.time_to_die>10+cast_time&target.time_to_die<20
    if S.RuneofPower:IsCastableP() and (Player:PrevGCDP(1, S.FrozenOrb) or Target:TimeToDie() > 10 + S.RuneofPower:CastTime() and Target:TimeToDie() < 20) then
      return S.RuneofPower:Cast()
    end
    -- call_action_list,name=talent_rop,if=talent.rune_of_power.enabled&active_enemies=1&cooldown.rune_of_power.full_recharge_time<cooldown.frozen_orb.remains
    if (S.RuneofPower:IsAvailable() and EnemiesCount == 1 and S.RuneofPower:FullRechargeTimeP() < S.FrozenOrb:CooldownRemainsP()) then
      local ShouldReturn = TalentRop(); 
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
    -- potion,if=prev_gcd.1.icy_veins|target.time_to_die<30
    --if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:PrevGCDP(1, S.IcyVeins) or Target:TimeToDie() < 30) then
    --  if RubimRH.CastSuggested(I.ProlongedPower:Cast()prolonged_power 96"; end
    --end
    -- use_items
    -- blood_fury
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
      return S.BloodFury:Cast()
    end
    -- berserking
    if S.Berserking:IsCastableP() and RubimRH.CDsON() then
      return S.Berserking:Cast()
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() then
      return S.LightsJudgment:Cast()
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
      return S.Fireblood:Cast()
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() then
      return S.AncestralCall:Cast()
    end
  end
  
  Movement = function()
    -- blink,if=movement.distance>10
    if BlinkAny:IsCastableP() and (not Target:IsInRange(S.Frostbolt:MaximumRange())) then
      S.BlinkAny:Cast()
    end
    -- ice_floes,if=buff.ice_floes.down
    if S.IceFloes:IsCastableP() and (Player:BuffDownP(S.IceFloesBuff)) then
      return S.IceFloes:Cast()
    end
  end
  
  Single = function()
    -- ice_nova,if=cooldown.ice_nova.ready&debuff.winters_chill.up
    if S.IceNova:IsCastableP() and (S.IceNova:CooldownUpP() and Target:DebuffP(S.WintersChillDebuff)) then
      return S.IceNova:Cast()
    end
    -- flurry,if=talent.ebonbolt.enabled&prev_gcd.1.ebonbolt&(!talent.glacial_spike.enabled|buff.icicles.stack<4|buff.brain_freeze.react)
    if S.Flurry:IsCastableP() and (S.Ebonbolt:IsAvailable() and Player:PrevGCDP(1, S.Ebonbolt) and (not S.GlacialSpike:IsAvailable() or Player:BuffStackP(S.IciclesBuff) < 4 or bool(Player:BuffStackP(S.BrainFreezeBuff)))) then
      return S.Flurry:Cast()
    end
    -- flurry,if=talent.glacial_spike.enabled&prev_gcd.1.glacial_spike&buff.brain_freeze.react
    if S.Flurry:IsCastableP() and (S.GlacialSpike:IsAvailable() and Player:PrevGCDP(1, S.GlacialSpike) and bool(Player:BuffStackP(S.BrainFreezeBuff))) then
      return S.Flurry:Cast()
    end
    -- flurry,if=prev_gcd.1.frostbolt&buff.brain_freeze.react&(!talent.glacial_spike.enabled|buff.icicles.stack<4)
    if S.Flurry:IsCastableP() and (Player:PrevGCDP(1, S.Frostbolt) and bool(Player:BuffStackP(S.BrainFreezeBuff)) and (not S.GlacialSpike:IsAvailable() or Player:BuffStackP(S.IciclesBuff) < 4)) then
      return S.Flurry:Cast()
    end
    -- frozen_orb
    if S.FrozenOrb:IsCastableP() then
      return S.FrozenOrb:Cast()
    end
    -- blizzard,if=active_enemies>2|active_enemies>1&cast_time=0&buff.fingers_of_frost.react<2
    if S.Blizzard:IsCastableP() and (EnemiesCount > 2 or EnemiesCount > 1 and S.Blizzard:CastTime() == 0 and Player:BuffStackP(S.FingersofFrostBuff) < 2) then
      return S.Blizzard:Cast()
    end
    -- ice_lance,if=buff.fingers_of_frost.react
    if S.IceLance:IsCastableP() and (bool(Player:BuffStackP(S.FingersofFrostBuff))) then
      return S.IceLance:Cast()
    end
    -- comet_storm
    if S.CometStorm:IsCastableP() then
      return S.CometStorm:Cast()
    end
    -- ebonbolt
    if S.Ebonbolt:IsCastableP() then
      return S.Ebonbolt:Cast()
    end
    -- ray_of_frost,if=!action.frozen_orb.in_flight&ground_aoe.frozen_orb.remains=0
    if S.RayofFrost:IsCastableP() and (not S.FrozenOrb:InFlight() and Player:FrozenOrbGroundAoeRemains() == 0) then
      return S.RayofFrost:Cast()
    end
    -- blizzard,if=cast_time=0|active_enemies>1
    if S.Blizzard:IsCastableP() and (S.Blizzard:CastTime() == 0 or EnemiesCount > 1) then
      return S.Blizzard:Cast()
    end
    -- glacial_spike,if=buff.brain_freeze.react|prev_gcd.1.ebonbolt|active_enemies>1&talent.splitting_ice.enabled
    if S.GlacialSpike:IsReadyP() and Player:BuffStackP(S.IciclesBuff) == 5 and (Player:Buff(S.BrainFreezeBuff) or Player:PrevGCDP(1, S.Ebonbolt) or Player:EnemiesAround(35) > 1 and S.SplittingIce:IsAvailable()) then
        return S.GlacialSpike:Cast()
    end
    -- ice_nova
    if S.IceNova:IsCastableP() then
      return S.IceNova:Cast()
    end
    -- use_item,name=tidestorm_codex,if=buff.icy_veins.down&buff.rune_of_power.down
    --if I.TidestormCodex:IsReady() and (Player:BuffDownP(S.IcyVeins) and Player:BuffDownP(S.RuneofPowerBuff)) then
    --  if RubimRH.Cast(I.TidestormCodex:Cast()tidestorm_codex 218"; end
    --end
    -- frostbolt
    if S.Frostbolt:IsCastableP() then
      return S.Frostbolt:Cast()
    end
    -- call_action_list,name=movement
    -- if (true) then
    --   local ShouldReturn = Movement(); if ShouldReturn then return ShouldReturn; end
    -- end
    -- ice_lance
    if S.IceLance:IsCastableP() then
      return S.IceLance:Cast()
    end
  end
  TalentRop = function()
    -- rune_of_power,if=talent.glacial_spike.enabled&buff.icicles.stack=5&(buff.brain_freeze.react|talent.ebonbolt.enabled&cooldown.ebonbolt.remains<cast_time)
    if S.RuneofPower:IsCastableP() and (S.GlacialSpike:IsAvailable() and Player:BuffStackP(S.IciclesBuff) == 5 and (bool(Player:BuffStackP(S.BrainFreezeBuff)) or S.Ebonbolt:IsAvailable() and S.Ebonbolt:CooldownRemainsP() < S.RuneofPower:CastTime())) then
      return S.RuneofPower:Cast()
    end
    -- rune_of_power,if=!talent.glacial_spike.enabled&(talent.ebonbolt.enabled&cooldown.ebonbolt.remains<cast_time|talent.comet_storm.enabled&cooldown.comet_storm.remains<cast_time|talent.ray_of_frost.enabled&cooldown.ray_of_frost.remains<cast_time|charges_fractional>1.9)
    if S.RuneofPower:IsCastableP() and (not S.GlacialSpike:IsAvailable() and (S.Ebonbolt:IsAvailable() and S.Ebonbolt:CooldownRemainsP() < S.RuneofPower:CastTime() or S.CometStorm:IsAvailable() and S.CometStorm:CooldownRemainsP() < S.RuneofPower:CastTime() or S.RayofFrost:IsAvailable() and S.RayofFrost:CooldownRemainsP() < S.RuneofPower:CastTime() or S.RuneofPower:ChargesFractionalP() > 1.9)) then
      return S.RuneofPower:Cast()
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and (not Player:IsCasting() or Player:IsCasting(S.WaterElemental)) then
    local ShouldReturn = Precombat(); 
	if ShouldReturn then 
	    return ShouldReturn; 
	end
  end
  
  if RubimRH.TargetIsValid() then
	-- Queue sys
	if QueueSkill() ~= nil then
        return QueueSkill()
    end
    -- counterspell
	if S.Counterspell:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Counterspell:Cast()
    end
	-- spell steal
	if S.Spellsteal:IsReady() and RubimRH.InterruptsON() and Target:HasStealableBuff() then
        return S.Spellsteal:Cast()
    end

    -- ice_lance,if=prev_gcd.1.flurry&!buff.fingers_of_frost.react
    if S.IceLance:IsCastableP() and (Player:PrevGCDP(1, S.Flurry) and not bool(Player:BuffStackP(S.FingersofFrostBuff))) then
      return S.IceLance:Cast()
    end
    -- call_action_list,name=cooldowns
    if RubimRH.CDsON() then
      local ShouldReturn = Cooldowns(); 
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
    -- call_action_list,name=aoe,if=active_enemies>3&talent.freezing_rain.enabled|active_enemies>4
    if (EnemiesCount > 3 and S.FreezingRain:IsAvailable() or EnemiesCount > 4) then
      local ShouldReturn = Aoe(); 
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
    -- call_action_list,name=single
    if (true) then
      local ShouldReturn = Single(); 
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(64, APL)

local function PASSIVE()
    if S.IceBlock:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[64].sk1 then
        return S.IceBlock:Cast()
    end

    if S.IceBarrier:IsReady() and not Player:Buff(S.IceBarrier) and  Player:HealthPercentage() <= RubimRH.db.profile[64].sk2 then
        return S.IceBarrier:Cast()
    end

    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(64, PASSIVE)
