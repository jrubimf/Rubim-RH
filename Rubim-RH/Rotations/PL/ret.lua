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

--Retribution
RubimRH.Spell[70] = {
  ArcaneTorrent                         = Spell(50613),
  WakeofAshes                           = Spell(255937),
  AvengingWrathBuff                     = Spell(31884),
  AvengingWrathCritBuff                 = Spell(294027),
  CrusadeBuff                           = Spell(231895),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  ShieldofVengeance                     = Spell(184662),
  AvengingWrath                         = Spell(31884),
  InquisitionBuff                       = Spell(84963),
  Inquisition                           = Spell(84963),
  Crusade                               = Spell(231895),
  RighteousVerdict                      = Spell(267610),
  ExecutionSentence                     = Spell(267798),
  DivineStorm                           = Spell(53385),
  DivinePurpose                         = Spell(223817),
  DivinePurposeBuff                     = Spell(223819),
  EmpyreanPowerBuff                     = Spell(286393),
  JudgmentDebuff                        = Spell(197277),
  TemplarsVerdict                       = Spell(85256),
  HammerofWrath                         = Spell(24275),
  BladeofJustice                        = Spell(184575),
  Judgment                              = Spell(20271),
  Consecration                          = Spell(205228),
  CrusaderStrike                        = Spell(35395),
  Rebuke                                = Spell(96231),
  HammerofJustice                       = Spell(853),
  CyclotronicBlast                      = Spell(167672),
  RecklessForceBuff                     = Spell(302932),
  ConcentratedFlameBurn                 = Spell(295368),
  SeethingRageBuff                      = Spell(297126),
  RazorCoralDebuff                      = Spell(303568),
  CleanseToxins                         = Spell(213644),
  -- Defensive
  FlashOfLight                          = Spell(19750),
  SelfLessHealerBuff                    = Spell(114250),
  DivineShield                          = Spell(642),
  LayOnHands                            = Spell(633),
  WordofGlory                           = Spell(210191),
  DivineSteed                           = Spell(190784),
  ShieldOfVengance                      = Spell(184662),
  -- PvP Talent
  HammerOfReckoning                     = Spell(247675),
  HammerOfReckoningBuff                 = Spell(247677),
  HandOfHidrance                        = Spell(183218),
  Forbearance                           = Spell(25771),
  JusticarsVengeance                    = Spell(215661),
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
}

local S = RubimRH.Spell[70]
local G = RubimRH.Spell[1] -- General Skills

S.AvengingWrath.TextureSpellID = { 55748 }
S.Crusade.TextureSpellID = { 55748 }

-- Items
if not Item.Paladin then Item.Paladin = {} end
Item.Paladin.Retribution = {
  PotionofFocusedResolve           = Item(168506),
  AshvanesRazorCoral               = Item(169311),
  AzsharasFontofPower              = Item(169314),
  PocketsizedComputationDevice     = Item(167555)
};
local I = Item.Paladin.Retribution;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

local StunInterrupts = {
  {S.HammerofJustice, "Cast Hammer of Justice (Interrupt)", function () return true; end},
};

-- Variables
local VarDsCastable = 0;
local VarHow = 0;

HL:RegisterForEvent(function()
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
	
	if RubimRH.db.profile.mainOption.useTrinkets[1] == false then
	    return false
	end
	
   	if RubimRH.db.profile.mainOption.useTrinkets[2] == false then
	    return false
	end	
	
    if RubimRH.db.profile.mainOption.trinketsUsage == "Everything" then
        return true
    end
	
	if RubimRH.db.profile.mainOption.trinketsUsage == "Boss Only" then
        if not UnitExists("boss1") then
            return false
        end

        if UnitExists("target") and not (UnitClassification("target") == "worldboss" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "rare") then
            return false
        end
    end	
    return true
end

--- ======= ACTION LISTS =======
local function APL()
    local Precombat_DBM, Precombat, Cooldowns, Finishers, Generators
    local PlayerGCD = Player:GCD()
    UpdateRanges()
    DetermineEssenceRanks()
  
   Precombat_DBM = function()
	    -- pre potion 
        if I.PotionofFocusedResolve:IsReady() and RubimRH.DBM_PullTimer() > 0.01 + Player:GCD() and RubimRH.DBM_PullTimer() < 0.1 + Player:GCD() then
            return 967532
        end
	    if S.BladeofJustice:IsCastable() and RubimRH.PerfectPullON() and RubimRH.DBM_PullTimer() > 0.01 and RubimRH.DBM_PullTimer() < 0.1 then
		    return S.BladeofJustice:Cast()
        end
       return 0, 462338
   end
   
   Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
      -- potion
      -- arcane_torrent,if=!talent.wake_of_ashes.enabled
      if S.ArcaneTorrent:IsCastableP() and RubimRH.CDsON() and (not S.WakeofAshes:IsAvailable()) then
        return S.ArcaneTorrent:Cast()
      end
	  --Blade of Justice
	  if S.BladeofJustice:IsCastable() then
		 return S.BladeofJustice:Cast()
      end
   end
  
  Cooldowns = function()
    -- potion,if=(cooldown.guardian_of_azeroth.remains>90|!essence.condensed_lifeforce.major)&(buff.bloodlust.react|buff.avenging_wrath.up|buff.crusade.up&buff.crusade.remains<25)
    if I.PotionofFocusedResolve:IsReady() and (S.GuardianOfAzeroth:CooldownRemainsP() > 90 or not S.GuardianOfAzeroth:IsAvailable()) and (Player:HasHeroism() or Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffRemainsP(S.CrusadeBuff) < 25) then
      return 967532
    end
    -- lights_judgment,if=spell_targets.lights_judgment>=2|(!raid_event.adds.exists|raid_event.adds.in>75)
    if S.LightsJudgment:IsCastableP() then
      return S.LightsJudgment:Cast()
    end
    -- fireblood,if=buff.avenging_wrath.up|buff.crusade.up&buff.crusade.stack=10
    if S.Fireblood:IsCastableP() and Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) == 10 then
      return S.Fireblood:Cast()
    end
    -- shield_of_vengeance,if=buff.seething_rage.down&buff.memory_of_lucid_dreams.down
    if S.ShieldofVengeance:IsCastableP() and Player:BuffDownP(S.SeethingRageBuff) and Player:BuffDownP(S.MemoryOfLucidDreams) then
      return S.ShieldofVengeance:Cast()
    end
    -- use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.down|(buff.avenging_wrath.remains>=20|buff.crusade.stack=10&buff.crusade.remains>15)&(cooldown.guardian_of_azeroth.remains>90|target.time_to_die<30|!essence.condensed_lifeforce.major)
    if I.AshvanesRazorCoral:IsReady() and Target:DebuffDownP(S.RazorCoralDebuff) or (Player:BuffRemainsP(S.AvengingWrath) >= 20 or Player:BuffStackP(S.CrusadeBuff) == 10 and Player:BuffRemainsP(S.CrusadeBuff) > 15) and (S.GuardianOfAzeroth:CooldownRemainsP() > 90 or Target:TimeToDie() < 30 or not S.GuardianOfAzeroth:IsAvailable()) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- the_unbound_force,if=time<=2|buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (HL.CombatTime() <= 2 or Player:BuffP(S.RecklessForceBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- blood_of_the_enemy,if=buff.avenging_wrath.up|buff.crusade.up&buff.crusade.stack=10
    if S.BloodOfTheEnemy:IsCastableP() and (Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) == 10) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth,if=!talent.crusade.enabled&(cooldown.avenging_wrath.remains<5&holy_power>=3&(buff.inquisition.up|!talent.inquisition.enabled)|cooldown.avenging_wrath.remains>=45)|(talent.crusade.enabled&cooldown.crusade.remains<gcd&holy_power>=4|holy_power>=3&time<10&talent.wake_of_ashes.enabled|cooldown.crusade.remains>=45)
    if S.GuardianOfAzeroth:IsCastableP() and (not S.Crusade:IsAvailable() and (S.AvengingWrath:CooldownRemainsP() < 5 and Player:HolyPower() >= 3 and (Player:BuffP(S.InquisitionBuff) or not S.Inquisition:IsAvailable()) or S.AvengingWrath:CooldownRemainsP() >= 45) or (S.Crusade:IsAvailable() and S.Crusade:CooldownRemainsP() < PlayerGCD and Player:HolyPower() >= 4 or Player:HolyPower() >= 3 and HL.CombatTime() < 10 and S.WakeofAshes:IsAvailable() or S.Crusade:CooldownRemainsP() >= 45)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance,if=cooldown.avenging_wrath.remains<gcd&holy_power>=3|cooldown.crusade.remains<gcd&holy_power>=4|cooldown.avenging_wrath.remains>=45|cooldown.crusade.remains>=45
    if S.WorldveinResonance:IsCastableP() and (S.AvengingWrath:CooldownRemainsP() < PlayerGCD and Player:HolyPower() >= 3 or S.Crusade:CooldownRemainsP() < PlayerGCD and Player:HolyPower() >= 4 or S.AvengingWrath:CooldownRemainsP() >= 45 or S.Crusade:CooldownRemainsP() >= 45) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- focused_azerite_beam,if=(!raid_event.adds.exists|raid_event.adds.in>30|spell_targets.divine_storm>=2)&(buff.avenging_wrath.down|buff.crusade.down)&(cooldown.blade_of_justice.remains>gcd*3&cooldown.judgment.remains>gcd*3)
    if S.FocusedAzeriteBeam:IsCastableP() and (Cache.EnemiesCount[8] >= 2) and (Player:BuffDownP(S.AvengingWrathBuff) or Player:BuffDownP(S.CrusadeBuff)) and (S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 3 and S.Judgment:CooldownRemainsP() > PlayerGCD * 3) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams,if=(buff.avenging_wrath.up|buff.crusade.up&buff.crusade.stack=10)&holy_power<=3
    if S.MemoryOfLucidDreams:IsCastableP() and (Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) == 10) and Player:HolyPower() <= 3 then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast,if=(!raid_event.adds.exists|raid_event.adds.in>30|spell_targets.divine_storm>=2)
    if S.PurifyingBlast:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- use_item,effect_name=cyclotronic_blast,if=(buff.avenging_wrath.down|buff.crusade.down)&(cooldown.blade_of_justice.remains>gcd*3&cooldown.judgment.remains>gcd*3)
    if I.PocketsizedComputationDevice:IsReady() and S.CyclotronicBlast:IsAvailable() and ((Player:BuffDownP(S.AvengingWrathBuff) or Player:BuffDownP(S.CrusadeBuff)) and (S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 3 and S.Judgment:CooldownRemainsP() > PlayerGCD * 3)) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- avenging_wrath,if=(!talent.inquisition.enabled|buff.inquisition.up)&holy_power>=3
    if S.AvengingWrath:IsCastableP() and (not S.Inquisition:IsAvailable() or Player:BuffP(S.InquisitionBuff)) and Player:HolyPower() >= 3 then
      return S.AvengingWrath:Cast()
    end
    -- crusade,if=holy_power>=4|holy_power>=3&time<10&talent.wake_of_ashes.enabled
    if S.Crusade:IsCastableP() and (Player:HolyPower() >= 4 or Player:HolyPower() >= 3 and HL.CombatTime() < 10 and S.WakeofAshes:IsAvailable()) then
      return S.Crusade:Cast()
    end
  end
  
  Finishers = function()
    -- variable,name=wings_pool,value=!equipped.169314&(!talent.crusade.enabled&cooldown.avenging_wrath.remains>gcd*3|cooldown.crusade.remains>gcd*3)|equipped.169314&(!talent.crusade.enabled&cooldown.avenging_wrath.remains>gcd*6|cooldown.crusade.remains>gcd*6)
    if (true) then
      VarWingsPool = num(not I.AzsharasFontofPower:IsEquipped() and (not S.Crusade:IsAvailable() and S.AvengingWrath:CooldownRemainsP() > PlayerGCD * 3 or S.Crusade:CooldownRemainsP() > PlayerGCD * 3) or I.AzsharasFontofPower:IsEquipped() and (not S.Crusade:IsAvailable() and S.AvengingWrath:CooldownRemainsP() > PlayerGCD * 6 or S.Crusade:CooldownRemainsP() > PlayerGCD * 6))
    end
    -- variable,name=ds_castable,value=spell_targets.divine_storm>=2&!talent.righteous_verdict.enabled|spell_targets.divine_storm>=3&talent.righteous_verdict.enabled|buff.empyrean_power.up&debuff.judgment.down&buff.divine_purpose.down&buff.avenging_wrath_autocrit.down
    if (true) then
      VarDsCastable = num(Cache.EnemiesCount[8] >= 2 and not S.RighteousVerdict:IsAvailable() or Cache.EnemiesCount[8] >= 3 and S.RighteousVerdict:IsAvailable() or Player:BuffP(S.EmpyreanPowerBuff) and Target:DebuffDownP(S.JudgmentDebuff) and Player:BuffDownP(S.DivinePurposeBuff) and Player:BuffDownP(S.AvengingWrathCritBuff))
    end
    -- inquisition,if=buff.avenging_wrath.down&(buff.inquisition.down|buff.inquisition.remains<8&holy_power>=3|talent.execution_sentence.enabled&cooldown.execution_sentence.remains<10&buff.inquisition.remains<15|cooldown.avenging_wrath.remains<15&buff.inquisition.remains<20&holy_power>=3)
    if S.Inquisition:IsReadyP() and (Player:BuffDownP(S.InquisitionBuff) and (Player:BuffDownP(S.InquisitionBuff) or Player:BuffRemainsP(S.InquisitionBuff) < 8 and Player:HolyPower() >= 3 or S.ExecutionSentence:IsAvailable() and S.ExecutionSentence:CooldownRemainsP() < 10 and Player:BuffRemainsP(S.InquisitionBuff) < 15 or S.AvengingWrath:CooldownRemainsP() < 15 and Player:BuffRemainsP(S.InquisitionBuff) < 20 and Player:HolyPower() >= 3)) then
      return S.Inquisition:Cast()
    end
    -- execution_sentence,if=spell_targets.divine_storm<=2&(!talent.crusade.enabled&cooldown.avenging_wrath.remains>10|talent.crusade.enabled&buff.crusade.down&cooldown.crusade.remains>10|buff.crusade.stack>=7)
    if S.ExecutionSentence:IsReadyP() and (Cache.EnemiesCount[8] <= 2 and (not S.Crusade:IsAvailable() and S.AvengingWrath:CooldownRemainsP() > 10 or S.Crusade:IsAvailable() and Player:BuffDownP(S.CrusadeBuff) and S.Crusade:CooldownRemainsP() > 10 or Player:BuffStackP(S.CrusadeBuff) >= 7)) then
      return S.ExecutionSentence:Cast()
    end
    -- divine_storm,if=variable.ds_castable&variable.wings_pool&((!talent.execution_sentence.enabled|(spell_targets.divine_storm>=2|cooldown.execution_sentence.remains>gcd*2))|(cooldown.avenging_wrath.remains>gcd*3&cooldown.avenging_wrath.remains<10|cooldown.crusade.remains>gcd*3&cooldown.crusade.remains<10|buff.crusade.up&buff.crusade.stack<10))
    if S.DivineStorm:IsReadyP() and (bool(VarDsCastable) and bool(VarWingsPool) and ((not S.ExecutionSentence:IsAvailable() or (Cache.EnemiesCount[8] >= 2 or S.ExecutionSentence:CooldownRemainsP() > PlayerGCD * 2)) or (S.AvengingWrath:CooldownRemainsP() > PlayerGCD * 3 and S.AvengingWrath:CooldownRemainsP() < 10 or S.Crusade:CooldownRemainsP() > PlayerGCD * 3 and S.Crusade:CooldownRemainsP() < 10 or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) < 10))) then
      return S.DivineStorm:Cast()
    end
    -- templars_verdict,if=variable.wings_pool&(!talent.execution_sentence.enabled|cooldown.execution_sentence.remains>gcd*2|cooldown.avenging_wrath.remains>gcd*3&cooldown.avenging_wrath.remains<10|cooldown.crusade.remains>gcd*3&cooldown.crusade.remains<10|buff.crusade.up&buff.crusade.stack<10)
    if S.TemplarsVerdict:IsReadyP() and (bool(VarWingsPool) and (not S.ExecutionSentence:IsAvailable() or S.ExecutionSentence:CooldownRemainsP() > PlayerGCD * 2 or S.AvengingWrath:CooldownRemainsP() > PlayerGCD * 3 and S.AvengingWrath:CooldownRemainsP() < 10 or S.Crusade:CooldownRemainsP() > PlayerGCD * 3 and S.Crusade:CooldownRemainsP() < 10 or Player:BuffP(S.CrusadeBuff) and Player:BuffStackP(S.CrusadeBuff) < 10)) then
      return S.TemplarsVerdict:Cast()
    end
    -- templars_verdict fallback, in case the user is saving AW/Crusade/ExecutionSentence
    if S.TemplarsVerdict:IsReadyP() and (not RubimRH.CDsON()) then
      return S.TemplarsVerdict:Cast()
    end
  end
  
  Generators = function()
    -- variable,name=HoW,value=(!talent.hammer_of_wrath.enabled|target.health.pct>=20&(buff.avenging_wrath.down|buff.crusade.down))
    if (true) then
      VarHow = num((not S.HammerofWrath:IsAvailable() or Target:HealthPercentage() >= 20 and (Player:BuffDownP(S.AvengingWrathBuff) or Player:BuffDownP(S.CrusadeBuff))))
    end
    -- call_action_list,name=finishers,if=holy_power>=5|buff.memory_of_lucid_dreams.up|buff.seething_rage.up|buff.inquisition.down&holy_power>=3
    if (Player:HolyPower() >= 5 or Player:BuffP(S.MemoryOfLucidDreams) or Player:BuffP(S.SeethingRageBuff) or Player:BuffDownP(S.InquisitionBuff) and Player:HolyPower() >= 3) then
      local ShouldReturn = Finishers(); if ShouldReturn then return ShouldReturn; end
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
    if S.HammerofWrath:IsReady() and (Player:HolyPower() <= 4) then
      return S.HammerofWrath:Cast()
    end
    -- consecration,if=holy_power<=2|holy_power<=3&cooldown.blade_of_justice.remains>gcd*2|holy_power=4&cooldown.blade_of_justice.remains>gcd*2&cooldown.judgment.remains>gcd*2
    if S.Consecration:IsReady() and (Player:HolyPower() <= 2 or Player:HolyPower() <= 3 and S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 2 or Player:HolyPower() == 4 and S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 2 and S.Judgment:CooldownRemainsP() > PlayerGCD * 2) then
      return S.Consecration:Cast()
    end
    -- call_action_list,name=finishers,if=talent.hammer_of_wrath.enabled&target.health.pct<=20|buff.avenging_wrath.up|buff.crusade.up
    if (S.HammerofWrath:IsAvailable() and Target:HealthPercentage() <= 20 or Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.CrusadeBuff)) then
      local ShouldReturn = Finishers(); if ShouldReturn then return ShouldReturn; end
    end
    -- crusader_strike,if=cooldown.crusader_strike.charges_fractional>=1.75&(holy_power<=2|holy_power<=3&cooldown.blade_of_justice.remains>gcd*2|holy_power=4&cooldown.blade_of_justice.remains>gcd*2&cooldown.judgment.remains>gcd*2&cooldown.consecration.remains>gcd*2)
    if S.CrusaderStrike:IsReady('Melee') and (S.CrusaderStrike:ChargesFractionalP() >= 1.75 and (Player:HolyPower() <= 2 or Player:HolyPower() <= 3 and S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 2 or Player:HolyPower() == 4 and S.BladeofJustice:CooldownRemainsP() > PlayerGCD * 2 and S.Judgment:CooldownRemainsP() > PlayerGCD * 2 and S.Consecration:CooldownRemainsP() > PlayerGCD * 2)) then
      return S.CrusaderStrike:Cast()
    end
    -- call_action_list,name=finishers
    if (true) then
      local ShouldReturn = Finishers(); if ShouldReturn then return ShouldReturn; end
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- crusader_strike,if=holy_power<=4
    if S.CrusaderStrike:IsReady('Melee') and (Player:HolyPower() <= 4) then
      return S.CrusaderStrike:Cast()
    end
    -- arcane_torrent,if=holy_power<=4
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Player:HolyPower() <= 4) then
      return S.ArcaneTorrent:Cast()
    end
  end
  
  	-- Protect against interrupt of channeled spells
    if (Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2)) or Player:IsChanneling() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end
  
    -- call DBM precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and RubimRH.PerfectPullON() and not Player:IsCasting() then
        local ShouldReturn = Precombat_DBM(); 
            if ShouldReturn then return ShouldReturn; 
        end    
    end
    -- call non DBM precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and not RubimRH.PerfectPullON() and not Player:IsCasting() then        
        local ShouldReturn = Precombat(); 
            if ShouldReturn then return ShouldReturn; 
        end    
    end
  
  --Call Combat
  if RubimRH.TargetIsValid() then
    --Interrupt
    if S.Rebuke:IsReadyP(30) and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Rebuke:Cast()
    end
    -- Emergency Flash of Light
    if S.FlashOfLight:IsReady() and Player:BuffStack(S.SelfLessHealerBuff) == 4 and Player:HealthPercentage() <= RubimRH.db.profile[70].sk2 and Player:StoppedFor() >= 0.5 then
        return S.FlashOfLight:Cast()
    end
	--Mov Speed
    if Player:MovingFor() >= 1 and S.DivineSteed:IsReadyP() then
        return S.DivineSteed:Cast()
    end
    -- JusticarsVengeance
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
    if S.WordofGlory:IsReadyP() then
        -- Regular
        if Player:HealthPercentage() <= RubimRH.db.profile[70].sk6 and not Player:Buff(S.DivinePurposeBuff) and Player:HolyPower() >= 3 then
            return S.WordofGlory:Cast()
        end
        -- Divine Purpose
        if Player:HealthPercentage() <= RubimRH.db.profile[70].sk6 - 5 and Player:Buff(S.DivinePurposeBuff) then
            return S.WordofGlory:Cast()
        end
    end
    --Dispell
	if S.CleanseToxins:IsReady() and Player:HasDispelableDebuff("Poison", "Disease") then
		return S.CleanseToxins:Cast()
    end
    -- auto_attack
    -- call_action_list,name=cooldowns
    if RubimRH.CDsON() then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=generators
    if (true) then
      local ShouldReturn = Generators(); if ShouldReturn then return ShouldReturn; end
    end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(70, APL);

local function PASSIVE()

    if S.ShieldOfVengance:IsReadyP() and Player:HealthPercentage() <= RubimRH.db.profile[70].sk1 then
        return S.ShieldOfVengance:Cast()
    end

    if S.DivineShield:IsReadyP() and Player:HealthPercentage() <= RubimRH.db.profile[70].sk4 and not Player:Debuff(S.Forbearance) then
        return S.DivineShield:Cast()
    end

    if S.LayOnHands:IsReadyP() and Player:HealthPercentage() <= RubimRH.db.profile[70].sk5 and not Player:Debuff(S.Forbearance) then
        return S.LayOnHands:Cast()
    end

    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(70, PASSIVE);
