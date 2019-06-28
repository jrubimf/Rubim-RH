--- ============================ HEADER ============================
--- ======= LOCALIZE =======

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
--Retribution
RubimRH.Spell[70] = {
  -- Racials
  LightsJudgment = Spell(255647),
  ArcaneTorrent = Spell(28730),
  GiftoftheNaaru = Spell(59547),
  Fireblood = Spell(265221),
  -- Abilities
  BladeofJustice = Spell(184575),
  Consecration = Spell(205228),
  CrusaderStrike = Spell(35395),
  DivineJudgment = Spell(271580),
  DivineHammer = Spell(198034),
  DivinePurpose = Spell(223817),
  DivinePurposeBuff = Spell(223819),
  DivineStorm = Spell(53385),
  ExecutionSentence = Spell(267798),
  GreaterJudgment = Spell(218718),
  HolyWrath = Spell(210220),
  Judgment = Spell(20271),
  JudgmentDebuff = Spell(197277),
  JusticarsVengeance = Spell(215661),
  TemplarsVerdict = Spell(85256),
  TheFiresofJustice = Spell(203316),
  TheFiresofJusticeBuff = Spell(209785),
  ShieldOfVengeance = Spell(184662),
  Zeal = Spell(217020),
  FinalVerdict = Spell(198038),
  Forbearance = Spell(25771),
  -- Offensive
   AvengingWrath = Spell(31884),
   Crusade = Spell(231895),
  --Talent
  Inquisition = Spell(84963),
  DivineJudgement = Spell(271580),
  HammerofWrath = Spell(24275),
  WakeofAshes = Spell(255937),
  RighteousVerdict = Spell(267610),
  -- Azerite Power
  EmpyreanPowerAzerite = Spell(286390),
  EmpyreanPowerBuffAzerite = Spell(286393),
  DivineStormBuffAzerite = Spell(278523),
  DivineRight = Spell(277678),
  -- Defensive
  FlashOfLight = Spell(19750),
  SelfLessHealerBuff = Spell(114250),
  DivineShield = Spell(642),
  LayOnHands = Spell(633),
  WordofGlory = Spell(210191),
  -- Utility
  HammerofJustice = Spell(853),
  Rebuke = Spell(96231),
  DivineSteed = Spell(190784),
  -- PvP Talent
  HammerOfReckoning                     = Spell(247675),
  HammerOfReckoningBuff                 = Spell(247677),
  HandOfHidrance                        = Spell(183218),  
  RecklessForce                         = Spell(302932),
  SeethingRageBuff                      = Spell(297126),
  InquisitionBuff                       = Spell(84963),
  
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
};
local S = RubimRH.Spell[70]

-- Items
if not Item.Paladin then Item.Paladin = {} end
Item.Paladin.Retribution = {
  BattlePotionofStrength           = Item(163224)
};
local I = Item.Paladin.Retribution;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

local StunInterrupts = {
  {S.HammerofJustice, "Cast Hammer of Justice (Interrupt)", function () return true; end},
};

-- Variables
local VarOpenerDone = 1;
local VarDsCastable = 0;
local VarHow = 0;
local Opener1 = 0;
local Opener2 = 0;
local Opener3 = 0;
local Opener4 = 0;
local Opener5 = 0;
local Opener6 = 0;
local Opener7 = 0;
local Opener8 = 0;
local Opener9 = 0;

HL:RegisterForEvent(function()
  VarOpenerDone = 0
  Opener1 = 0
  Opener2 = 0
  Opener3 = 0
  Opener4 = 0
  Opener5 = 0
  Opener6 = 0
  Opener7 = 0
  Opener8 = 0
  Opener9 = 0
  VarDsCastable = 0
  VarHow = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {30, 8, 5}
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
  local Precombat, Cooldowns, Finishers, Generators, Opener
  local PlayerGCD = Player:GCD()
  UpdateRanges()
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    
      -- potion
     -- if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions then
     --   return I.BattlePotionofStrength:Cast()
     -- end
      -- memory_of_lucid_dreams
      if S.MemoryOfLucidDreams:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
      end
      -- arcane_torrent,if=!talent.wake_of_ashes.enabled
      if S.ArcaneTorrent:IsCastableP() and RubimRH.CDsON() and (not S.WakeofAshes:IsAvailable()) then
        return S.ArcaneTorrent:Cast()
      end
    
  end
  
  Cooldowns = function()
    -- potion,if=(buff.bloodlust.react|buff.avenging_wrath.up|buff.crusade.up&buff.crusade.remains<25|target.time_to_die<=40)
   -- if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions and ((Player:HasHeroism() or Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffRemainsP(S.CrusadeBuff) < 25 or Target:TimeToDie() <= 40)) then
   --   return I.BattlePotionofStrength:Cast()
   -- end
    -- lights_judgment,if=spell_targets.lights_judgment>=2|(!raid_event.adds.exists|raid_event.adds.in>75)
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() and (Cache.EnemiesCount[5] >= 2 or (not (Cache.EnemiesCount[30] > 1) or 10000000000 > 75)) then
      return S.LightsJudgment:Cast()
    end
    -- fireblood,if=buff.avenging_wrath.up|buff.crusade.up&buff.crusade.stack=10
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) == 10) then
      return S.Fireblood:Cast()
    end
    -- shield_of_vengeance,if=buff.seething_rage.down&buff.memory_of_lucid_dreams.down
    if S.ShieldOfVengeance:IsCastableP() and (Player:BuffDownP(S.SeethingRageBuff) and Player:BuffDownP(S.MemoryOfLucidDreams)) then
      return S.ShieldOfVengeance:Cast()
    end
    -- the_unbound_force,if=time<=2|buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (HL.CombatTime() <= 2 or Player:BuffP(S.RecklessForce)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- blood_of_the_enemy,if=buff.avenging_wrath.up|buff.crusade.up&buff.crusade.stack=10
    if S.BloodOfTheEnemy:IsCastableP() and (Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) == 10) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth,if=!talent.crusade.enabled&(cooldown.avenging_wrath.remains<gcd&holy_power>=3|cooldown.avenging_wrath.remains>=45)|(talent.crusade.enabled&cooldown.crusade.remains<gcd&holy_power>=4|cooldown.crusade.remains>=45)
    if S.GuardianOfAzeroth:IsCastableP() and (not S.Crusade:IsAvailable() and (S.AvengingWrath:CooldownRemainsP() < PlayerGCD and Player:HolyPower() >= 3 or S.AvengingWrath:CooldownRemainsP() >= 45) or (S.Crusade:IsAvailable() and S.Crusade:CooldownRemainsP() < PlayerGCD and Player:HolyPower() >= 4 or S.Crusade:CooldownRemainsP() >= 45)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance,if=cooldown.avenging_wrath.remains<gcd&holy_power>=3|cooldown.crusade.remains<gcd&holy_power>=4|cooldown.avenging_wrath.remains>=45|cooldown.crusade.remains>=45
    if S.WorldveinResonance:IsCastableP() and (S.AvengingWrath:CooldownRemainsP() < PlayerGCD and Player:HolyPower() >= 3 or S.Crusade:CooldownRemainsP() < PlayerGCD and Player:HolyPower() >= 4 or S.AvengingWrath:CooldownRemainsP() >= 45 or S.Crusade:CooldownRemainsP() >= 45) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- focused_azerite_beam,if=(!raid_event.adds.exists|raid_event.adds.in>30|spell_targets.divine_storm>=2)&(buff.avenging_wrath.down|buff.crusade.down)&(cooldown.blade_of_justice.remains>gcd*3&cooldown.judgment.remains>gcd*3)
    if S.FocusedAzeriteBeam:IsCastableP() and ((Cache.EnemiesCount[8] >= 2) and (Player:BuffDownP(S.AvengingWrathBuff) or Player:BuffDownP(S.CrusadeBuff)) and (S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 3 and S.Judgment:CooldownRemainsP() > PlayerGCD * 3)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams,if=(buff.avenging_wrath.up|buff.crusade.up&buff.crusade.stack=10)&holy_power<=3
    if S.MemoryOfLucidDreams:IsCastableP() and ((Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) == 10) and Player:HolyPower() <= 3) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast,if=(!raid_event.adds.exists|raid_event.adds.in>30|spell_targets.divine_storm>=2)
    if S.PurifyingBlast:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- avenging_wrath,if=buff.inquisition.up|!talent.inquisition.enabled
    if S.AvengingWrath:IsCastableP() and (Player:BuffP(S.InquisitionBuff) or not S.Inquisition:IsAvailable()) then
      return S.AvengingWrath:Cast()
    end
    -- crusade,if=holy_power>=4
    if S.Crusade:IsCastableP() and (Player:HolyPower() >= 4) then
      return S.Crusade:Cast()
    end
  end
  
  Finishers = function()
    -- variable,name=ds_castable,value=spell_targets.divine_storm>=2&!talent.righteous_verdict.enabled|spell_targets.divine_storm>=3&talent.righteous_verdict.enabled
    if (true) then
      VarDsCastable = num(Cache.EnemiesCount[8] >= 2 and not S.RighteousVerdict:IsAvailable() or Cache.EnemiesCount[8] >= 3 and S.RighteousVerdict:IsAvailable())
    end
    -- inquisition,if=buff.inquisition.down|buff.inquisition.remains<5&holy_power>=3|talent.execution_sentence.enabled&cooldown.execution_sentence.remains<10&buff.inquisition.remains<15|cooldown.avenging_wrath.remains<15&buff.inquisition.remains<20&holy_power>=3
    if S.Inquisition:IsReadyP() and (Player:BuffDownP(S.InquisitionBuff) or Player:BuffRemainsP(S.InquisitionBuff) < 5 and Player:HolyPower() >= 3 or S.ExecutionSentence:IsAvailable() and S.ExecutionSentence:CooldownRemainsP() < 10 and Player:BuffRemainsP(S.InquisitionBuff) < 15 or S.AvengingWrath:CooldownRemainsP() < 15 and Player:BuffRemainsP(S.InquisitionBuff) < 20 and Player:HolyPower() >= 3) then
      return S.Inquisition:Cast()
    end
    -- execution_sentence,if=spell_targets.divine_storm<=2&(!talent.crusade.enabled&cooldown.avenging_wrath.remains>10|talent.crusade.enabled&buff.crusade.down&cooldown.crusade.remains>10|buff.crusade.stack>=7)
    if S.ExecutionSentence:IsReadyP() and (Cache.EnemiesCount[8] <= 2 and (not S.Crusade:IsAvailable() and S.AvengingWrath:CooldownRemainsP() > 10 or S.Crusade:IsAvailable() and Player:BuffDownP(S.CrusadeBuff) and S.Crusade:CooldownRemainsP() > 10 or Player:BuffStackP(S.CrusadeBuff) >= 7)) then
      return S.ExecutionSentence:Cast()
    end
    -- divine_storm,if=variable.ds_castable&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)|buff.empyrean_power.up&debuff.judgment.down&buff.divine_purpose.down
    if S.DivineStorm:IsReadyP() and (bool(VarDsCastable) and (not S.Crusade:IsAvailable() or S.Crusade:CooldownRemainsP() > PlayerGCD * 2) or Player:BuffP(S.EmpyreanPowerBuff) and Target:DebuffDownP(S.JudgmentDebuff) and Player:BuffDownP(S.DivinePurposeBuff)) then
      return S.DivineStorm:Cast()
    end
    -- templars_verdict,if=(!talent.crusade.enabled&cooldown.avenging_wrath.remains>gcd*3|cooldown.crusade.remains>gcd*3)&(!talent.execution_sentence.enabled|cooldown.execution_sentence.remains>gcd*2|cooldown.avenging_wrath.remains>gcd*3&cooldown.avenging_wrath.remains<10|buff.crusade.up&buff.crusade.stack<10)
    if S.TemplarsVerdict:IsReadyP() and ((not S.Crusade:IsAvailable() and S.AvengingWrath:CooldownRemainsP() > PlayerGCD * 3 or S.Crusade:CooldownRemainsP() > PlayerGCD * 3) and (not S.ExecutionSentence:IsAvailable() or S.ExecutionSentence:CooldownRemainsP() > PlayerGCD * 2 or S.AvengingWrath:CooldownRemainsP() > PlayerGCD * 3 and S.AvengingWrath:CooldownRemainsP() < 10 or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) < 10)) then
      return S.TemplarsVerdict:Cast()
    end
  end
  
  Generators = function()
    -- variable,name=HoW,value=(!talent.hammer_of_wrath.enabled|target.health.pct>=20&(buff.avenging_wrath.down|buff.crusade.down))
    if (true) then
      VarHow = num((not S.HammerofWrath:IsAvailable() or Target:HealthPercentage() >= 20 and (Player:BuffDownP(S.AvengingWrathBuff) or Player:BuffDownP(S.CrusadeBuff))))
    end
    -- call_action_list,name=finishers,if=holy_power>=5|buff.memory_of_lucid_dreams.up|buff.seething_rage.up
    if (Player:HolyPower() >= 5 or Player:BuffP(S.MemoryOfLucidDreams) or Player:BuffP(S.SeethingRageBuff)) then
      local ShouldReturn = Finishers();
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
    -- wake_of_ashes,if=(!raid_event.adds.exists|raid_event.adds.in>15|spell_targets.wake_of_ashes>=2)&(holy_power<=0|holy_power=1&cooldown.blade_of_justice.remains>gcd)&(cooldown.avenging_wrath.remains>10|talent.crusade.enabled&cooldown.crusade.remains>10)
    if S.WakeofAshes:IsCastableP() and ((not (Cache.EnemiesCount[30] > 1) or Cache.EnemiesCount[8] >= 2) and (Player:HolyPower() <= 0 or Player:HolyPower() == 1 and S.BladeofJustice:CooldownRemainsP() > PlayerGCD) and (S.AvengingWrath:CooldownRemainsP() > 10 or S.Crusade:IsAvailable() and S.Crusade:CooldownRemainsP() > 10)) then
      return S.WakeofAshes:Cast()
    end
    -- blade_of_justice,if=holy_power<=2|(holy_power=3&(cooldown.hammer_of_wrath.remains>gcd*2|variable.HoW))
    if S.BladeofJustice:IsCastableP() and (Player:HolyPower() <= 2 or (Player:HolyPower() == 3 and (S.HammerofWrath:CooldownRemainsP() > PlayerGCD * 2 or bool(VarHow)))) then
      return S.BladeofJustice:Cast()
    end
    -- judgment,if=holy_power<=2|(holy_power<=4&(cooldown.blade_of_justice.remains>gcd*2|variable.HoW))
    if S.Judgment:IsCastableP() and (Player:HolyPower() <= 2 or (Player:HolyPower() <= 4 and (S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 2 or bool(VarHow)))) then
      return S.Judgment:Cast()
    end
    -- hammer_of_wrath,if=holy_power<=4
    if S.HammerofWrath:IsCastableP() and (Player:HolyPower() <= 4) then
      return S.HammerofWrath:Cast()
    end
    -- consecration,if=holy_power<=2|holy_power<=3&cooldown.blade_of_justice.remains>gcd*2|holy_power=4&cooldown.blade_of_justice.remains>gcd*2&cooldown.judgment.remains>gcd*2
    if S.Consecration:IsCastableP() and (Player:HolyPower() <= 2 or Player:HolyPower() <= 3 and S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 2 or Player:HolyPower() == 4 and S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 2 and S.Judgment:CooldownRemainsP() > PlayerGCD * 2) then
      return S.Consecration:Cast()
    end
    -- call_action_list,name=finishers,if=talent.hammer_of_wrath.enabled&(target.health.pct<=20|buff.avenging_wrath.up|buff.crusade.up)
    if (S.HammerofWrath:IsAvailable() and (Target:HealthPercentage() <= 20 or Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff))) then
      local ShouldReturn = Finishers();
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
    -- crusader_strike,if=cooldown.crusader_strike.charges_fractional>=1.75&(holy_power<=2|holy_power<=3&cooldown.blade_of_justice.remains>gcd*2|holy_power=4&cooldown.blade_of_justice.remains>gcd*2&cooldown.judgment.remains>gcd*2&cooldown.consecration.remains>gcd*2)
    if S.CrusaderStrike:IsCastableP() and (S.CrusaderStrike:ChargesFractionalP() >= 1.75 and (Player:HolyPower() <= 2 or Player:HolyPower() <= 3 and S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 2 or Player:HolyPower() == 4 and S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 2 and S.Judgment:CooldownRemainsP() > PlayerGCD * 2 and S.Consecration:CooldownRemainsP() > PlayerGCD * 2)) then
      return S.CrusaderStrike:Cast()
    end
    -- call_action_list,name=finishers
    if (true) then
      local ShouldReturn = Finishers(); 
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- crusader_strike,if=holy_power<=4
    if S.CrusaderStrike:IsCastableP() and (Player:HolyPower() <= 4) then
      return S.CrusaderStrike:Cast()
    end
    -- arcane_torrent,if=holy_power<=4
    if S.ArcaneTorrent:IsCastableP() and RubimRH.CDsON() and (Player:HolyPower() <= 4) then
      return S.ArcaneTorrent:Cast()
    end
  end
  
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); 
	if ShouldReturn then 
	    return ShouldReturn; 
	end
  end
  
  --In Combat
  if RubimRH.TargetIsValid() then
    -- auto_attack

    if S.Rebuke:IsReady(30) and RubimRH.db.profile.mainOption.useInterrupts and Target:IsInterruptible() then
        return S.Rebuke:Cast()
    end
	-- Queue system
    if QueueSkill() ~= nil then
        return QueueSkill()
    end
    --FlashOfLight
    if S.FlashOfLight:IsReady() and Player:BuffStack(S.SelfLessHealerBuff) == 4 and Player:HealthPercentage() <= RubimRH.db.profile[70].sk2 and Player:StoppedFor() >= 0.5 then
        return S.FlashOfLight:Cast()
    end
    --Justicars Vengeance
    if S.JusticarsVengeance:IsReady() and Target:IsInRange("Melee") then
        -- Regular
        if Player:HealthPercentage() <= RubimRH.db.profile[70].sk3 and not Player:Buff(S.DivinePurposeBuff) and Player:HolyPower() >= 5 then
            return S.JusticarsVengeance:Cast()
        end
        -- Divine Purpose
        if Player:HealthPercentage() <= RubimRH.db.profile[70].sk3 - 5 and Player:Buff(S.DivinePurposeBuff) then
            return S.JusticarsVengeance:Cast()
        end

    end
    -- Word of Glory
    if S.WordofGlory:IsCastable() then
        -- Regular
        if Player:HealthPercentage() <= RubimRH.db.profile[70].sk6 and not Player:Buff(S.DivinePurposeBuff) and Player:HolyPower() >= 3 then
            return S.WordofGlory:Cast()
        end
        -- Divine Purpose
        if Player:HealthPercentage() <= RubimRH.db.profile[70].sk6 - 5 and Player:Buff(S.DivinePurposeBuff) then
            return S.WordofGlory:Cast()
        end
    end
    -- call_action_list,name=cooldowns
    if VarOpenerDone == 1 and RubimRH.CDsON() then
      local ShouldReturn = Cooldowns(); 
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
    -- call_action_list,name=generators
    if VarOpenerDone == 1 then
      local ShouldReturn = Generators(); 
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(70, APL);

local function PASSIVE()
    if S.ShieldOfVengeance:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[70].sk1 then
        return S.ShieldOfVengeance:Cast()
    end

    if S.DivineShield:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[70].sk4 and not Player:Debuff(S.Forbearance) then
        return S.DivineShield:Cast()
    end

    if S.LayOnHands:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[70].sk5 and not Player:Debuff(S.Forbearance) then
        return S.LayOnHands:Cast()
    end

    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(70, PASSIVE);