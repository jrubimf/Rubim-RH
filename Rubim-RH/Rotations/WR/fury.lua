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
local MultiSpell = HL.MultiSpell
local Item       = HL.Item

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[72] = {
  -- Abilities
  BattleShout                           = Spell(6673),
  RecklessnessBuff                      = Spell(1719),
  Recklessness                          = Spell(1719),
  FuriousSlashBuff                      = Spell(202539),
  FuriousSlash                          = Spell(100130),
  RecklessAbandon                       = Spell(202751),
  HeroicLeap                            = Spell(6544),
  Siegebreaker                          = Spell(280772),
  Rampage                               = Spell(184367),
  FrothingBerserker                     = Spell(215571),
  Carnage                               = Spell(202922),
  EnrageBuff                            = Spell(184362),
  Massacre                              = Spell(206315),
 -- Execute                               = MultiSpell(5308, 280735),
  Bloodthirst                           = Spell(23881),
  RagingBlow                            = Spell(85288),
  Bladestorm                            = Spell(46924),
  SiegebreakerDebuff                    = Spell(280773),
  DragonRoar                            = Spell(118000),
  Whirlwind                             = Spell(190411),
  Charge                                = Spell(100),
  FujiedasFuryBuff                      = Spell(207775),
  MeatCleaverBuff                       = Spell(85739),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Pummel                                = Spell(6552),
  IntimidatingShout                     = Spell(5246),
  ColdSteelHotBlood                     = Spell(288080),
  Victorious                            = Spell(32216),
  VictoryRush                           = Spell(34428),
  ImpendingVictory                      = Spell(202168),
  -- Defensive
  RallyingCry = Spell(97462),
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
  RecklessForce                         = Spell(302932)
};
local S = RubimRH.Spell[72]

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Fury = {
  BattlePotionofStrength           = Item(163224),
  RampingAmplitudeGigavoltEngine   = Item(165580)
};
local I = Item.Warrior.Fury;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- Stuns
local StunInterrupts = {
  {S.IntimidatingShout, "Cast Intimidating Shout (Interrupt)", function () return true; end},
};

local EnemyRanges = {8}
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

S.ExecuteDefault    = Spell(5308)
S.ExecuteMassacre   = Spell(280735)

local function UpdateExecuteID()
   S.Execute = S.Massacre:IsAvailable() and S.ExecuteMassacre or S.ExecuteDefault
end

local function ExecuteRange()
	return S.Massacre:IsAvailable() and 35 or 20;
end

--HL.RegisterNucleusAbility(46924, 8, 6)               -- Bladestorm
--HL.RegisterNucleusAbility(118000, 12, 6)             -- Dragon Roar
--HL.RegisterNucleusAbility(190411, 8, 6)              -- Whirlwind


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

-- # Essences
local function Essences()
  -- blood_of_the_enemy
  if S.BloodOfTheEnemy:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- concentrated_flame
  if S.ConcentratedFlame:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- guardian_of_azeroth
  if S.GuardianOfAzeroth:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- focused_azerite_beam
  if S.FocusedAzeriteBeam:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- purifying_blast
  if S.PurifyingBlast:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- the_unbound_force
  if S.TheUnboundForce:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- ripple_in_space
  if S.RippleInSpace:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- worldvein_resonance
  if S.WorldveinResonance:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- memory_of_lucid_dreams,if=fury<40&buff.metamorphosis.up
  if S.MemoryOfLucidDreams:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  return false
end


--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Movement, SingleTarget
  UpdateRanges()
  UpdateExecuteID()
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    --if RubimRH.TargetIsValid() then
      -- potion
      --if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions then
      --  return I.BattlePotionofStrength:Cast()
      --end
      -- memory_of_lucid_dreams
      if S.MemoryOfLucidDreams:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
      end
      -- guardian_of_azeroth
      if S.GuardianOfAzeroth:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
      end
      -- recklessness,if=!talent.furious_slash.enabled
      if S.Recklessness:IsCastableP() and (not S.FuriousSlash:IsAvailable()) then
        return S.Recklessness:Cast()
      end
    --end
  end
  
  Movement = function()
    -- heroic_leap
    if S.HeroicLeap:IsCastableP() then
      return S.HeroicLeap:Cast()
    end
  end
  
  SingleTarget = function()
    -- siegebreaker
    if S.Siegebreaker:IsCastableP() and RubimRH.CDsON() then
      return S.Siegebreaker:Cast()
    end
    -- rampage,if=(buff.recklessness.up|buff.memory_of_lucid_dreams.up)|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
    if S.Rampage:IsReadyP() and ((Player:BuffP(S.RecklessnessBuff) or Player:BuffP(S.MemoryOfLucidDreams)) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90))) then
      return S.Rampage:Cast()
    end
    -- execute
    if S.Execute:IsCastableP() and (Target:HealthPercentage() < ExecuteRange()) then
      return S.Execute:Cast()
    end
    -- bladestorm,if=prev_gcd.1.rampage
    if S.Bladestorm:IsCastableP() and RubimRH.CDsON() and (Player:PrevGCDP(1, S.Rampage)) then
      return S.Bladestorm:Cast()
    end
    -- bloodthirst,if=buff.enrage.down|azerite.cold_steel_hot_blood.rank>1
    if S.Bloodthirst:IsCastableP() and (Player:BuffDownP(S.EnrageBuff) or S.ColdSteelHotBlood:AzeriteRank() > 1) then
      return S.Bloodthirst:Cast()
    end
    -- dragon_roar,if=buff.enrage.up
    if S.DragonRoar:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.EnrageBuff)) then
      return S.DragonRoar:Cast()
    end
    -- raging_blow,if=charges=2
    if S.RagingBlow:IsCastableP() and (S.RagingBlow:ChargesP() == 2) then
      return S.RagingBlow:Cast()
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP() then
      return S.Bloodthirst:Cast()
    end
    -- raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
    if S.RagingBlow:IsCastableP() and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
      return S.RagingBlow:Cast()
    end
    -- furious_slash,if=talent.furious_slash.enabled
    if S.FuriousSlash:IsCastableP() and (S.FuriousSlash:IsAvailable()) then
      return S.FuriousSlash:Cast()
    end
    -- whirlwind
    if S.Whirlwind:IsCastableP() then
      return S.Whirlwind:Cast()
    end
  end
 
 -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  -- call combat
  if RubimRH.TargetIsValid() then
    -- auto_attack
	-- Queue system
    if QueueSkill() ~= nil then
        return QueueSkill()
    end
	-- Battleshout in combat refresh
	if S.BattleShout:IsCastable() and not Player:BuffP(S.BattleShout) then
        return S.BattleShout:Cast()
    end
    -- charge
    if S.Charge:IsReady() and Target:MaxDistanceToPlayer(true) >= 8 then
        return S.Charge:Cast()
    end
	-- Victory Rush
    if S.VictoryRush:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[72].sk1 then
        return S.VictoryRush:Cast()
    end
	-- Victory Rush -> Buff about to expire
    if Player:Buff(S.Victorious) and Player:BuffRemains(S.Victorious) <= 2 and S.VictoryRush:IsReady("Melee") then
        return S.VictoryRush:Cast()
    end
	-- Victory Rush
    if S.ImpendingVictory:IsReadyMorph() and Player:HealthPercentage() <= RubimRH.db.profile[72].sk2 then
        return S.VictoryRush:Cast()
    end
	-- RallyingCry
    if S.RallyingCry:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[72].sk3 then
        return S.RallyingCry:Cast()
    end
    -- Interrupts
    if S.Pummel:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Pummel:Cast()
    end
    -- run_action_list,name=movement,if=movement.distance>5
    -- heroic_leap,if=(raid_event.movement.distance>25&raid_event.movement.in>45)|!raid_event.movement.exists
    if ((not Target:IsInRange("Melee")) and Target:IsInRange(S.HeroicLeap)) then
      return Movement();
    end
    -- potion during combat...
    --if I.BattlePotionofStrength:IsReady() then
    --  return I.BattlePotionofStrength:Cast()
    --end
    -- furious_slash,if=talent.furious_slash.enabled&(buff.furious_slash.stack<3|buff.furious_slash.remains<3|(cooldown.recklessness.remains<3&buff.furious_slash.remains<9))
    if S.FuriousSlash:IsCastableP() and (S.FuriousSlash:IsAvailable() and (Player:BuffStackP(S.FuriousSlashBuff) < 3 or Player:BuffRemainsP(S.FuriousSlashBuff) < 3 or (S.Recklessness:CooldownRemainsP() < 3 and Player:BuffRemainsP(S.FuriousSlashBuff) < 9))) then
      return S.FuriousSlash:Cast()
    end
    -- rampage,if=cooldown.recklessness.remains<3
    if S.Rampage:IsReadyP() and (S.Recklessness:CooldownRemainsP() < 3) then
      return S.Rampage:Cast()
    end
    -- blood_of_the_enemy,if=buff.recklessness.up
    if S.BloodOfTheEnemy:IsCastableP() and (Player:BuffP(S.RecklessnessBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.PurifyingBlast:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.RippleInSpace:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.WorldveinResonance:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- focused_azerite_beam,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.FocusedAzeriteBeam:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame,if=!buff.recklessness.up&!buff.siegebreaker.up&dot.concentrated_flame_burn.remains=0
    -- Need spell ID for ConcentratedFlame DoT
    if S.ConcentratedFlame:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force,if=buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForce)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth,if=!buff.recklessness.up
    if S.GuardianOfAzeroth:IsCastableP() and (Player:BuffDownP(S.RecklessnessBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams,if=!buff.recklessness.up
    if S.MemoryOfLucidDreams:IsCastableP() and (Player:BuffDownP(S.RecklessnessBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- recklessness,if=!essence.condensed_lifeforce.major|cooldown.guardian_of_azeroth.remains>20|buff.guardian_of_azeroth.up
    if S.Recklessness:IsCastableP() and RubimRH.CDsON() and (not S.CondensedLifeforce:IsAvailable() or S.GuardianOfAzeroth:CooldownRemainsP() > 20 or Player:BuffP(S.GuardianOfAzeroth)) then
      return S.Recklessness:Cast()
    end
    -- whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
    if S.Whirlwind:IsCastableP() and (Cache.EnemiesCount[8] > 1 and not Player:BuffP(S.MeatCleaverBuff)) then
      return S.Whirlwind:Cast()
    end
    -- use_item,name=ramping_amplitude_gigavolt_engine
   -- if I.RampingAmplitudeGigavoltEngine:IsReady() then
   --   return I.RampingAmplitudeGigavoltEngine:Cast()
   -- end
    -- blood_fury,if=buff.recklessness.up
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      return S.BloodFury:Cast()
    end
    -- berserking,if=buff.recklessness.up
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      return S.Berserking:Cast()
    end
    -- lights_judgment,if=buff.recklessness.down
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() and (Player:BuffDownP(S.RecklessnessBuff)) then
      return S.LightsJudgment:Cast()
    end
    -- fireblood,if=buff.recklessness.up
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      return S.Fireblood:Cast()
    end
    -- ancestral_call,if=buff.recklessness.up
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      return S.AncestralCall:Cast()
    end
    -- run_action_list,name=single_target
    if (true) then
      return SingleTarget();
    end
  end
  return 0, 135328
end


RubimRH.Rotation.SetAPL(72, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(72, PASSIVE);
