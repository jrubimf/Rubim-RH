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
RubimRH.Spell[63] = {
  ArcaneIntellectBuff                   = Spell(1459),
  ArcaneIntellect                       = Spell(1459),
  MirrorImage                           = Spell(55342),
  Pyroblast                             = Spell(11366),
  LivingBomb                            = Spell(44457),
  CombustionBuff                        = Spell(190319),
  Combustion                            = Spell(190319),
  Meteor                                = Spell(153561),
  RuneofPowerBuff                       = Spell(116014),
  RuneofPower                           = Spell(116011),
  Firestarter                           = Spell(205026),
  LightsJudgment                        = Spell(255647),
  FireBlast                             = Spell(108853),
  BlasterMasterBuff                     = Spell(274598),
  Fireball                              = Spell(133),
  BlasterMaster                         = Spell(274596),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Scorch                                = Spell(2948),
  HeatingUpBuff                         = Spell(48107),
  HotStreakBuff                         = Spell(48108),
  PyroclasmBuff                         = Spell(269651),
  PhoenixFlames                         = Spell(257541),
  DragonsBreath                         = Spell(31661),
  FlameOn                               = Spell(205029),
  Flamestrike                           = Spell(2120),
  FlamePatch                            = Spell(205037),
  SearingTouch                          = Spell(269644),
  AlexstraszasFury                      = Spell(235870),
  Kindling                              = Spell(155148),
  Counterspell                          = Spell(2139),
  Spellsteal                            = Spell(30449),
  IceBlock                              = Spell(45438),
  BlazingBarrier                        = Spell(235313),
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
  MemoryOfLucidDreamsMinor1             = Spell(298357),
  MemoryOfLucidDreamsMinor2             = Spell(299372),
  MemoryOfLucidDreamsMinor3             = Spell(299374),
  RecklessForce                         = Spell(302932),
  RecklessForceBuff                     = Spell(302932),
  CyclotronicBlast                      = Spell(167672)
};
local S = RubimRH.Spell[63];

-- Items
if not Item.Mage then Item.Mage = {} end
Item.Mage.Fire = {
  PotionofUnbridledFury            = Item(169299),
  TidestormCodex                   = Item(165576),
  MalformedHeraldsLegwraps         = Item(167835),
  PocketsizedComputationDevice     = Item(167555),
  AzsharasFontofPower              = Item(169314),
  HyperthreadWristwraps            = Item(168989)
};
local I = Item.Mage.Fire;

-- Rotation Var
local ShouldReturn; -- Used to get the return string
local EnemiesCount;

-- Variables
local VarCombustionRopCutoff = 0;
local VarFireBlastPooling = 0;
local VarPhoenixPooling = 0;

HL:RegisterForEvent(function()
  VarCombustionRopCutoff = 0
  VarFireBlastPooling = 0
  VarPhoenixPooling = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
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

local function GetEnemiesCount(range)
    if range == nil then range = 10 end
	 -- Unit Update - Update differently depending on if splash data is being used
	if RubimRH.AoEON() then       
	        if RubimRH.db.profile[63].useSplashData == "Enabled" then	
                HL.GetEnemies(range, nil, true, Target)
                return Cache.EnemiesCount[range]
            else
                return active_enemies()
            end
    else
        return 1
    end
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
  S.MemoryOfLucidDreamsMinor = S.MemoryOfLucidDreamsMinor2:IsAvailable() and S.MemoryOfLucidDreamsMinor2 or S.MemoryOfLucidDreamsMinor1
  S.MemoryOfLucidDreamsMinor = S.MemoryOfLucidDreamsMinor3:IsAvailable() and S.MemoryOfLucidDreamsMinor3 or S.MemoryOfLucidDreamsMinor1
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

S.Pyroblast:RegisterInFlight()
S.Fireball:RegisterInFlight()
S.Meteor:RegisterInFlight()
S.PhoenixFlames:RegisterInFlight();
S.Pyroblast:RegisterInFlight(S.CombustionBuff);
S.Fireball:RegisterInFlight(S.CombustionBuff);

function S.Firestarter:ActiveStatus()
    return (S.Firestarter:IsAvailable() and (Target:HealthPercentage() > 90)) and 1 or 0
end

function S.Firestarter:ActiveRemains()
    return S.Firestarter:IsAvailable() and ((Target:HealthPercentage() > 90) and Target:TimeToX(90, 3) or 0) or 0
end

--HL.RegisterNucleusAbility(157981, 8, 6)               -- Blast Wave
--HL.RegisterNucleusAbility(153561, 8, 6)               -- Meteor
--HL.RegisterNucleusAbility(31661, 8, 6)                -- Dragon's Breath
--HL.RegisterNucleusAbility(44457, 10, 6)               -- Living Bomb
--HL.RegisterNucleusAbility(2120, 8, 6)                 -- Flamestrike
--HL.RegisterNucleusAbility(257541, 8, 6)               -- Phoenix Flames

--- ======= ACTION LISTS =======
local function APL()
  local Precombat_DBM, Precombat, ActiveTalents, BmCombustionPhase, CombustionPhase, RopPhase, StandardRotation
  EnemiesCount = GetEnemiesCount(8)
  HL.GetEnemies(40) -- For interrupts
  DetermineEssenceRanks()
 
 
   	Precombat_DBM = function()
        -- flask
        -- food
        -- augmentation
        -- arcane_intellect
        if S.ArcaneIntellect:IsCastableP() and Player:BuffDownP(S.ArcaneIntellectBuff, true) then
          return S.ArcaneIntellect:Cast()
        end
	    -- potion
        if I.PotionofUnbridledFury:IsReady() and RubimRH.DBM_PullTimer() >= S.Pyroblast:CastTime() + 1 and RubimRH.DBM_PullTimer() <= S.Pyroblast:CastTime() + 2 then
            return 967532
        end
        -- pyroblast
        if S.Pyroblast:IsCastableP() and RubimRH.DBM_PullTimer() > 1 and RubimRH.DBM_PullTimer() <= S.Pyroblast:CastTime() then
            return S.Pyroblast:Cast()
        end
    end
  
 
 Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- arcane_intellect
    if S.ArcaneIntellect:IsCastableP() and Player:BuffDownP(S.ArcaneIntellectBuff, true) then
      return S.ArcaneIntellect:Cast()
    end
      -- variable,name=combustion_rop_cutoff,op=set,value=60
      if (true) then
        VarCombustionRopCutoff = 60
      end
      -- snapshot_stats
      -- mirror_image
      if S.MirrorImage:IsCastableP() then
        return S.MirrorImage:Cast()
      end
      -- pyroblast
      if S.Pyroblast:IsCastableP() then
        return S.Pyroblast:Cast()
      end
  end
  
  ActiveTalents = function()
    -- living_bomb,if=active_enemies>1&buff.combustion.down&(cooldown.combustion.remains>cooldown.living_bomb.duration|cooldown.combustion.ready)
    if S.LivingBomb:IsCastableP() and (EnemiesCount > 1 and Player:BuffDownP(S.CombustionBuff) and (S.Combustion:CooldownRemainsP() > S.LivingBomb:BaseDuration() or S.Combustion:CooldownUpP())) then
      return S.LivingBomb:Cast()
    end
    -- meteor,if=buff.rune_of_power.up&(firestarter.remains>cooldown.meteor.duration|!firestarter.active)|cooldown.rune_of_power.remains>target.time_to_die&action.rune_of_power.charges<1|(cooldown.meteor.duration<cooldown.combustion.remains|cooldown.combustion.ready)&!talent.rune_of_power.enabled&(cooldown.meteor.duration<firestarter.remains|!talent.firestarter.enabled|!firestarter.active)
    if S.Meteor:IsCastableP() and (Player:BuffP(S.RuneofPowerBuff) and (S.Firestarter:ActiveRemains() > S.Meteor:BaseDuration() or not bool(S.Firestarter:ActiveStatus())) or S.RuneofPower:CooldownRemainsP() > Target:TimeToDie() and S.RuneofPower:ChargesP() < 1 or (S.Meteor:BaseDuration() < S.Combustion:CooldownRemainsP() or S.Combustion:CooldownUpP()) and not S.RuneofPower:IsAvailable() and (S.Meteor:BaseDuration() < S.Firestarter:ActiveRemains() or not S.Firestarter:IsAvailable() or not bool(S.Firestarter:ActiveStatus()))) then
      return S.Meteor:Cast()
    end
  end
  
  BmCombustionPhase = function()
    -- lights_judgment,if=buff.combustion.down
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() and (Player:BuffDownP(S.CombustionBuff)) then
      return S.LightsJudgment:Cast()
    end
    -- living_bomb,if=buff.combustion.down&active_enemies>1
    if S.LivingBomb:IsCastableP() and (Player:BuffDownP(S.CombustionBuff) and EnemiesCount > 1) then
      return S.LivingBomb:Cast()
    end
    -- rune_of_power,if=buff.combustion.down
    if S.RuneofPower:IsCastableP() and (Player:BuffDownP(S.CombustionBuff)) then
      return S.RuneofPower:Cast()
    end
    -- fire_blast,use_while_casting=1,if=buff.blaster_master.down&(talent.rune_of_power.enabled&action.rune_of_power.executing&action.rune_of_power.execute_remains<0.6|(cooldown.combustion.ready|buff.combustion.up)&!talent.rune_of_power.enabled&!action.pyroblast.in_flight&!action.fireball.in_flight)
    if S.FireBlast:IsCastableP() and Player:BuffDownP(S.BlasterMasterBuff) and (S.RuneofPower:IsAvailable() and Player:IsCasting(S.RuneofPower) and Player:CastRemains() < 0.6 or (S.Combustion:CooldownUpP() or Player:BuffP(S.CombustionBuff)) and not S.RuneofPower:IsAvailable() and not S.Pyroblast:InFlight() and not S.Fireball:InFlight()) then
      return S.FireBlast:Cast()
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- combustion,use_off_gcd=1,use_while_casting=1,if=azerite.blaster_master.enabled&((action.meteor.in_flight&action.meteor.in_flight_remains<0.2)|!talent.meteor.enabled|prev_gcd.1.meteor)&(buff.rune_of_power.up|!talent.rune_of_power.enabled)
    if S.Combustion:IsCastableP() and RubimRH.CDsON() and S.BlasterMaster:AzeriteEnabled() and ((S.Meteor:InFlight() and S.Meteor:TimeSinceLastCast() > 2.8) or not S.Meteor:IsAvailable() or Player:PrevGCDP(1, S.Meteor)) and (Player:BuffP(S.RuneofPowerBuff) or not S.RuneofPower:IsAvailable()) then
      return S.Combustion:Cast()
    end
    -- potion
    -- blood_fury
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
      return S.BloodFury:Cast()
    end
    -- berserking
    if S.Berserking:IsCastableP() and RubimRH.CDsON() then
      return S.Berserking:Cast()
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
      return S.Fireblood:Cast()
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() then
      return S.AncestralCall:Cast()
    end
    -- call_action_list,name=trinkets
    -- pyroblast,if=prev_gcd.1.scorch&buff.heating_up.up
    if S.Pyroblast:IsCastableP() and (Player:PrevGCDP(1, S.Scorch) and Player:BuffP(S.HeatingUpBuff)) then
      return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.hot_streak.up
    if S.Pyroblast:IsCastableP() and (Player:BuffP(S.HotStreakBuff)) then
      return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.pyroclasm.react&cast_time<buff.combustion.remains
    if S.Pyroblast:IsCastableP() and not Player:IsCasting(S.Pyroblast) and Player:BuffP(S.PyroclasmBuff) and S.Pyroblast:CastTime() < Player:BuffRemainsP(S.CombustionBuff) then
      return S.Pyroblast:Cast()
    end
    -- phoenix_flames
    if S.PhoenixFlames:IsCastableP() then
      return S.PhoenixFlames:Cast()
    end
    -- fire_blast,use_off_gcd=1,if=buff.blaster_master.stack=1&buff.hot_streak.down&!buff.pyroclasm.react&prev_gcd.1.pyroblast&(buff.blaster_master.remains<0.15|gcd.remains<0.15)
    if S.FireBlast:IsCastableP() and Player:BuffStackP(S.BlasterMasterBuff) == 1 and Player:BuffDownP(S.HotStreakBuff) and Player:BuffDownP(S.PyroclasmBuff) and Player:PrevGCDP(1, S.Pyroblast) and (Player:BuffRemainsP(S.BlasterMasterBuff) < 0.15 or Player:GCDRemains() < 0.15) then
      return S.FireBlast:Cast()
    end
    -- fire_blast,use_while_casting=1,if=buff.blaster_master.stack=1&(action.scorch.executing&action.scorch.execute_remains<0.15|buff.blaster_master.remains<0.15)
    if S.FireBlast:IsCastableP() and Player:BuffStackP(S.BlasterMasterBuff) == 1 and (Player:IsCasting(S.Scorch) and Player:CastRemains() < 0.15 or Player:BuffRemainsP(S.BlasterMasterBuff) < 0.15) then
      return S.FireBlast:Cast()
    end
    -- scorch,if=buff.hot_streak.down&(cooldown.fire_blast.remains<cast_time|action.fire_blast.charges>0)
    if S.Scorch:IsCastableP() and Player:BuffDownP(S.HotStreakBuff) and (S.FireBlast:CooldownRemainsP() < S.Scorch:CastTime() or S.FireBlast:ChargesP() > 0) then
      return S.Scorch:Cast()
    end
    -- fire_blast,use_while_casting=1,use_off_gcd=1,if=buff.blaster_master.stack>1&(prev_gcd.1.scorch&!buff.hot_streak.up&!action.scorch.executing|buff.blaster_master.remains<0.15)
    if S.FireBlast:IsCastableP() and Player:BuffStackP(S.BlasterMasterBuff) > 1 and (Player:PrevGCDP(1, S.Scorch) and not Player:BuffP(S.HotStreakBuff) and not Player:IsCasting(S.Scorch) or Player:BuffRemainsP(S.BlasterMasterBuff) < 0.15) then
      return S.FireBlast:Cast()
    end
    -- living_bomb,if=buff.combustion.remains<gcd.max&active_enemies>1
    if S.LivingBomb:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) < Player:GCD() and EnemiesCount > 1) then
      return S.LivingBomb:Cast()
    end
    -- dragons_breath,if=buff.combustion.remains<gcd.max
    if S.DragonsBreath:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) < Player:GCD()) then
      return S.DragonsBreath:Cast()
    end
    -- scorch
    if S.Scorch:IsCastableP() then
      return S.Scorch:Cast()
    end
  end
  
  CombustionPhase = function()
    -- lights_judgment,if=buff.combustion.down
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() and Player:BuffDownP(S.CombustionBuff) then
      return S.LightsJudgment:Cast()
    end
    -- use_item,name=azsharas_font_of_power
    if I.AzsharasFontofPower:IsReady() then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=hyperthread_wristwraps,if=buff.combustion.up&action.fire_blast.charges_fractional<1.2
    if I.HyperthreadWristwraps:IsReady() and Player:BuffP(S.CombustionBuff) and S.FireBlast:ChargesFractionalP() < 1.2 then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- blood_of_the_enemy
    if S.BloodOfTheEnemy:IsCastableP() then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth
    if S.GuardianOfAzeroth:IsCastableP() then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- call_action_list,name=bm_combustion_phase,if=azerite.blaster_master.enabled&talent.flame_on.enabled&!essence.memory_of_lucid_dreams.major
    if S.BlasterMaster:AzeriteEnabled() and S.FlameOn:IsAvailable() and not S.MemoryOfLucidDreams:IsAvailable() then
      local ShouldReturn = BmCombustionPhase(); if ShouldReturn then return ShouldReturn; end
    end
    -- memory_of_lucid_dreams
    if S.MemoryOfLucidDreams:IsCastableP() then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- rune_of_power,if=buff.combustion.down
    if S.RuneofPower:IsCastableP() and (Player:BuffDownP(S.CombustionBuff)) then
      return S.RuneofPower:Cast()
    end
    -- call_action_list,name=active_talents,if=(azerite.blaster_master.enabled&buff.blaster_master.stack>=3)|!azerite.blaster_master.enabled
    if (S.BlasterMaster:AzeriteEnabled() and Player:BuffStackP(S.BlasterMasterBuff) >= 3) or not S.BlasterMaster:AzeriteEnabled() then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- combustion,use_off_gcd=1,use_while_casting=1,if=!essence.memory_of_lucid_dreams.major&(!azerite.blaster_master.enabled|!talent.flame_on.enabled)&((action.meteor.in_flight&action.meteor.in_flight_remains<=0.5)|!talent.meteor.enabled)&(buff.rune_of_power.up|!talent.rune_of_power.enabled)
    if S.Combustion:IsCastableP() and RubimRH.CDsON() and not S.MemoryOfLucidDreams:IsAvailable() and (not S.BlasterMaster:AzeriteEnabled() or not S.FlameOn:IsAvailable()) and ((S.Meteor:InFlight() and S.Meteor:TimeSinceLastCast() >= 2.5) or not S.Meteor:IsAvailable()) and (Player:BuffP(S.RuneofPowerBuff) or not S.RuneofPower:IsAvailable()) then
      return S.Combustion:Cast()
    end
    -- combustion,use_off_gcd=1,use_while_casting=1,if=essence.memory_of_lucid_dreams.major&(buff.rune_of_power.up|!talent.rune_of_power.enabled)
    if S.Combustion:IsCastableP() and RubimRH.CDsON() and S.MemoryOfLucidDreams:IsAvailable() and (Player:BuffP(S.RuneofPowerBuff) or not S.RuneofPower:IsAvailable()) then
      return S.Combustion:Cast()
    end
    -- potion
    -- blood_fury
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
      return S.BloodFury:Cast()
    end
    -- berserking
    if S.Berserking:IsCastableP() and RubimRH.CDsON() then
      return S.Berserking:Cast()
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
      return S.Fireblood:Cast()
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() then
      return S.AncestralCall:Cast()
    end
    -- call_action_list,name=trinkets
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>2)|active_enemies>6)&buff.hot_streak.react&!azerite.blaster_master.enabled
    if S.Flamestrike:IsCastableP() and ((S.FlamePatch:IsAvailable() and EnemiesCount > 2) or EnemiesCount > 6) and Player:BuffP(S.HotStreakBuff) and not S.BlasterMaster:AzeriteEnabled() then
      return S.Flamestrike:Cast()
    end
    -- pyroblast,if=buff.pyroclasm.react&buff.combustion.remains>cast_time
    if S.Pyroblast:IsCastableP() and not Player:IsCasting(S.Pyroblast) and Player:BuffP(S.PyroclasmBuff) and Player:BuffRemainsP(S.CombustionBuff) > S.Pyroblast:CastTime() then
      return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.hot_streak.react
    if S.Pyroblast:IsCastableP() and Player:BuffP(S.HotStreakBuff) then
      return S.Pyroblast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=essence.memory_of_lucid_dreams.major&(charges_fractional>1.3|buff.blaster_master.remains<0.5|buff.combustion.remains<buff.blaster_master.duration|!azerite.blaster_master.enabled)&((buff.combustion.up&(buff.heating_up.react&!action.pyroblast.in_flight&!action.scorch.executing)|(action.scorch.execute_remains&buff.heating_up.down&buff.hot_streak.down&!action.pyroblast.in_flight)))
    if S.FireBlast:IsCastableP() and S.MemoryOfLucidDreams:IsAvailable() and (S.FireBlast:ChargesFractional() > 1.3 or Player:BuffRemainsP(S.BlasterMasterBuff) < 0.5 or Player:BuffRemainsP(S.CombustionBuff) < S.BlasterMasterBuff:BaseDuration() or not S.BlasterMaster:AzeriteEnabled()) and ((Player:BuffP(S.CombustionBuff) and (Player:BuffP(S.HeatingUpBuff) and not S.Pyroblast:InFlight() and not Player:IsCasting(S.Scorch)) or (Player:IsCasting(S.Scorch) and Player:BuffDownP(S.HeatingUpBuff) and Player:BuffDownP(S.HotStreakBuff) and not S.Pyroblast:InFlight()))) then
      return S.FireBlast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=!essence.memory_of_lucid_dreams.major&(!azerite.blaster_master.enabled|!talent.flame_on.enabled)&((buff.combustion.up&(buff.heating_up.react&!action.pyroblast.in_flight&!action.scorch.executing)|(action.scorch.execute_remains&buff.heating_up.down&buff.hot_streak.down&!action.pyroblast.in_flight)))
    if S.FireBlast:IsCastableP() and not S.MemoryOfLucidDreams:IsAvailable() and (not S.BlasterMaster:AzeriteEnabled() or not S.FlameOn:IsAvailable()) and ((Player:BuffP(S.CombustionBuff) and (Player:BuffP(S.HeatingUpBuff) and not S.Pyroblast:InFlight() and not Player:IsCasting(S.Scorch)) or (Player:IsCasting(S.Scorch) and Player:BuffDownP(S.HeatingUpBuff) and Player:BuffDownP(S.HotStreakBuff) and not S.Pyroblast:InFlight()))) then
      return S.FireBlast:Cast()
    end
    -- pyroblast,if=prev_gcd.1.scorch&buff.heating_up.up
    if S.Pyroblast:IsCastableP() and (Player:PrevGCDP(1, S.Scorch) and Player:BuffP(S.HeatingUpBuff)) then
      return S.Pyroblast:Cast()
    end
    -- phoenix_flames
    if S.PhoenixFlames:IsCastableP() then
      return S.PhoenixFlames:Cast()
    end
    -- scorch,if=buff.combustion.remains>cast_time&buff.combustion.up|buff.combustion.down
    if S.Scorch:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) > S.Scorch:CastTime() and Player:BuffP(S.CombustionBuff) or Player:BuffDownP(S.CombustionBuff)) then
      return S.Scorch:Cast()
    end
    -- living_bomb,if=buff.combustion.remains<gcd.max&active_enemies>1
    if S.LivingBomb:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) < Player:GCD() and EnemiesCount > 1) then
      return S.LivingBomb:Cast()
    end
    -- dragons_breath,if=buff.combustion.remains<gcd.max&buff.combustion.up
    if S.DragonsBreath:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) < Player:GCD() and Player:BuffP(S.CombustionBuff)) then
      return S.DragonsBreath:Cast()
    end
    -- scorch,if=target.health.pct<=30&talent.searing_touch.enabled
    if S.Scorch:IsCastableP() and (Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) then
      return S.Scorch:Cast()
    end
  end
  
  RopPhase = function()
    -- rune_of_power
    if S.RuneofPower:IsCastableP() then
      return S.RuneofPower:Cast()
    end
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|active_enemies>4)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and ((S.FlamePatch:IsAvailable() and EnemiesCount > 1) or EnemiesCount > 4) and Player:BuffP(S.HotStreakBuff) then
      return S.Flamestrike:Cast()
    end
    -- pyroblast,if=buff.hot_streak.react
    if S.Pyroblast:IsCastableP() and (Player:BuffP(S.HotStreakBuff)) then
      return S.Pyroblast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=(cooldown.combustion.remains>0|firestarter.active&buff.rune_of_power.up)&(!buff.heating_up.react&!buff.hot_streak.react&!prev_off_gcd.fire_blast&(action.fire_blast.charges>=2|(action.phoenix_flames.charges>=1&talent.phoenix_flames.enabled)|(talent.alexstraszas_fury.enabled&cooldown.dragons_breath.ready)|(talent.searing_touch.enabled&target.health.pct<=30)|(talent.firestarter.enabled&firestarter.active)))
    if S.FireBlast:IsCastableP() and (S.Combustion:CooldownRemainsP() > 0 or bool(S.Firestarter:ActiveStatus()) and Player:BuffP(S.RuneofPowerBuff)) and (Player:BuffDownP(S.HeatingUpBuff) and Player:BuffDownP(S.HotStreakBuff) and not Player:PrevOffGCDP(1, S.FireBlast) and (S.FireBlast:ChargesP() >= 2 or (S.PhoenixFlames:ChargesP() >= 1 and S.PhoenixFlames:IsAvailable()) or (S.AlexstraszasFury:IsAvailable() and S.DragonsBreath:CooldownUpP()) or (S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30) or (S.Firestarter:IsAvailable() and bool(S.Firestarter:ActiveStatus())))) then
      return S.FireBlast:Cast()
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- pyroblast,if=buff.pyroclasm.react&cast_time<buff.pyroclasm.remains&buff.rune_of_power.remains>cast_time
    if S.Pyroblast:IsCastableP() and Player:BuffP(S.PyroclasmBuff) and S.Pyroblast:CastTime() < Player:BuffRemainsP(S.PyroclasmBuff) and Player:BuffRemainsP(S.RuneofPowerBuff) > S.Pyroblast:CastTime() then
      return S.Pyroblast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=(cooldown.combustion.remains>0|firestarter.active&buff.rune_of_power.up)&(buff.heating_up.react&(target.health.pct>=30|!talent.searing_touch.enabled))
    if S.FireBlast:IsCastableP() and (S.Combustion:CooldownRemainsP() > 0 or bool(S.Firestarter:ActiveStatus()) and Player:BuffP(S.RuneofPowerBuff)) and (Player:BuffP(S.HeatingUpBuff) and (Target:HealthPercentage() >= 30 or not S.SearingTouch:IsAvailable())) then
      return S.FireBlast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=(cooldown.combustion.remains>0|firestarter.active&buff.rune_of_power.up)&talent.searing_touch.enabled&target.health.pct<=30&(buff.heating_up.react&!action.scorch.executing|!buff.heating_up.react&!buff.hot_streak.react)
    if S.FireBlast:IsCastableP() and (S.Combustion:CooldownRemainsP() > 0 or bool(S.Firestarter:ActiveStatus()) and Player:BuffP(S.RuneofPowerBuff)) and S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 and (Player:BuffP(S.HeatingUpBuff) and not Player:IsCasting(S.Scorch) or Player:BuffDownP(S.HeatingUpBuff) and Player:BuffDownP(S.HotStreakBuff)) then
      return S.FireBlast:Cast()
    end
    -- pyroblast,if=prev_gcd.1.scorch&buff.heating_up.up&talent.searing_touch.enabled&target.health.pct<=30&(!talent.flame_patch.enabled|active_enemies=1)
    if S.Pyroblast:IsCastableP() and (Player:PrevGCDP(1, S.Scorch) and Player:BuffP(S.HeatingUpBuff) and S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 and (not S.FlamePatch:IsAvailable() or EnemiesCount == 1)) then
      return S.Pyroblast:Cast()
    end
    -- phoenix_flames,if=!prev_gcd.1.phoenix_flames&buff.heating_up.react
    if S.PhoenixFlames:IsCastableP() and (not Player:PrevGCDP(1, S.PhoenixFlames) and Player:BuffP(S.HeatingUpBuff)) then
      return S.PhoenixFlames:Cast()
    end
    -- scorch,if=target.health.pct<=30&talent.searing_touch.enabled
    if S.Scorch:IsCastableP() and Player:IsMoving() and (Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) then
      return S.Scorch:Cast()
    end
    -- dragons_breath,if=active_enemies>2
    if S.DragonsBreath:IsCastableP() and (EnemiesCount > 2) then
      return S.DragonsBreath:Cast()
    end
    -- flamestrike,if=(talent.flame_patch.enabled&active_enemies>2)|active_enemies>5
    if S.Flamestrike:IsCastableP() and ((S.FlamePatch:IsAvailable() and EnemiesCount > 2) or EnemiesCount > 5) then
      return S.Flamestrike:Cast()
    end
    -- fireball
    if S.Fireball:IsCastableP() then
      return S.Fireball:Cast()
    end
  end
  
  StandardRotation = function()
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>1&!firestarter.active)|active_enemies>4)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and (((S.FlamePatch:IsAvailable() and EnemiesCount > 1 and not bool(S.Firestarter:ActiveStatus())) or EnemiesCount > 4) and Player:BuffP(S.HotStreakBuff)) then
      return S.Flamestrike:Cast()
    end
    -- pyroblast,if=buff.hot_streak.react&buff.hot_streak.remains<action.fireball.execute_time
    if S.Pyroblast:IsCastableP() and (Player:BuffP(S.HotStreakBuff) and Player:BuffRemainsP(S.HotStreakBuff) < S.Fireball:ExecuteTime()) then
      return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.hot_streak.react&(prev_gcd.1.fireball|firestarter.active|action.pyroblast.in_flight)
    if S.Pyroblast:IsCastableP() and (Player:BuffP(S.HotStreakBuff) and (Player:PrevGCDP(1, S.Fireball) or bool(S.Firestarter:ActiveStatus()) or S.Pyroblast:InFlight())) then
      return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.hot_streak.react&target.health.pct<=30&talent.searing_touch.enabled
    if S.Pyroblast:IsCastableP() and (Player:BuffP(S.HotStreakBuff) and Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) then
      return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.pyroclasm.react&cast_time<buff.pyroclasm.remains
    if S.Pyroblast:IsCastableP() and (Player:BuffP(S.PyroclasmBuff) and S.Pyroblast:CastTime() < Player:BuffRemainsP(S.PyroclasmBuff)) then
      return S.Pyroblast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=(cooldown.combustion.remains>0&buff.rune_of_power.down|firestarter.active)&!talent.kindling.enabled&!variable.fire_blast_pooling&(((action.fireball.executing|action.pyroblast.executing)&(buff.heating_up.react|firestarter.active&!buff.hot_streak.react&!buff.heating_up.react))|(talent.searing_touch.enabled&target.health.pct<=30&(buff.heating_up.react&!action.scorch.executing|!buff.hot_streak.react&!buff.heating_up.react&action.scorch.executing&!action.pyroblast.in_flight&!action.fireball.in_flight))|(firestarter.active&(action.pyroblast.in_flight|action.fireball.in_flight)&!buff.heating_up.react&!buff.hot_streak.react))
    if S.FireBlast:IsCastableP() and (S.Combustion:CooldownRemainsP() > 0 and Player:BuffDownP(S.RuneofPowerBuff) or bool(S.Firestarter:ActiveStatus())) and not S.Kindling:IsAvailable() and not bool(VarFireBlastPooling) and ((Player:IsCasting(S.Fireball) or Player:IsCasting(S.Pyroblast)) and (Player:BuffP(S.HeatingUpBuff) or bool(S.Firestarter:ActiveStatus()) and Player:BuffDownP(S.HotStreakBuff) and Player:BuffDownP(S.HeatingUpBuff))) or (S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 and (Player:BuffP(S.HeatingUpBuff) and not Player:IsCasting(S.Scorch) or Player:BuffDownP(S.HotStreakBuff) and Player:BuffDownP(S.HeatingUpBuff) and Player:IsCasting(S.Scorch) and not S.Pyroblast:InFlight() and not S.Fireball:InFlight())) or (bool(S.Firestarter:ActiveStatus()) and (S.Pyroblast:InFlight() or S.Fireball:InFlight()) and Player:BuffDownP(S.HeatingUpBuff) and Player:BuffDownP(S.HotStreakBuff)) then
      return S.FireBlast:Cast()
    end
    -- fire_blast,if=talent.kindling.enabled&buff.heating_up.react&(cooldown.combustion.remains>full_recharge_time+2+talent.kindling.enabled|firestarter.remains>full_recharge_time|(!talent.rune_of_power.enabled|cooldown.rune_of_power.remains>target.time_to_die&action.rune_of_power.charges<1)&cooldown.combustion.remains>target.time_to_die)
    if S.FireBlast:IsCastableP() and S.Kindling:IsAvailable() and Player:BuffP(S.HeatingUpBuff) and (S.Combustion:CooldownRemainsP() > S.FireBlast:FullRechargeTimeP() + 2 + num(S.Kindling:IsAvailable()) or S.Firestarter:ActiveRemains() > S.FireBlast:FullRechargeTimeP() or (not S.RuneofPower:IsAvailable() or S.RuneofPower:CooldownRemainsP() > Target:TimeToDie() and S.RuneofPower:ChargesP() < 1) and S.Combustion:CooldownRemainsP() > Target:TimeToDie()) then
      return S.FireBlast:Cast()
    end
	-- fire_blast,use_while_casting=1,if=buff.blaster_master.stack=1&(action.scorch.executing&action.scorch.execute_remains<0.15|buff.blaster_master.remains<0.15)
    if S.FireBlast:IsCastableP() and Player:BuffP(S.HeatingUpBuff) then
      return S.FireBlast:Cast()
    end
    -- pyroblast,if=prev_gcd.1.scorch&buff.heating_up.up&talent.searing_touch.enabled&target.health.pct<=30&((talent.flame_patch.enabled&active_enemies=1&!firestarter.active)|(active_enemies<4&!talent.flame_patch.enabled))
    if S.Pyroblast:IsCastableP() and (Player:PrevGCDP(1, S.Scorch) and Player:BuffP(S.HeatingUpBuff) and S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 and ((S.FlamePatch:IsAvailable() and EnemiesCount == 1 and not bool(S.Firestarter:ActiveStatus())) or (EnemiesCount < 4 and not S.FlamePatch:IsAvailable()))) then
      return S.Pyroblast:Cast()
    end
    -- phoenix_flames,if=(buff.heating_up.react|(!buff.hot_streak.react&(action.fire_blast.charges>0|talent.searing_touch.enabled&target.health.pct<=30)))&!variable.phoenix_pooling
    if S.PhoenixFlames:IsCastableP() and ((Player:BuffP(S.HeatingUpBuff) or (Player:BuffDownP(S.HotStreakBuff) and (S.FireBlast:ChargesP() > 0 or S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30))) and not bool(VarPhoenixPooling)) then
      return S.PhoenixFlames:Cast()
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- dragons_breath,if=active_enemies>1
    if S.DragonsBreath:IsCastableP() and (EnemiesCount > 1) then
      return S.DragonsBreath:Cast()
    end
    -- use_item,name=tidestorm_codex,if=cooldown.combustion.remains>20|talent.firestarter.enabled&firestarter.remains>20
    if I.TidestormCodex:IsReady() and (S.Combustion:CooldownRemainsP() > 20 or S.Firestarter:IsAvailable() and S.Firestarter:ActiveRemains() > 20) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,effect_name=cyclotronic_blast,if=cooldown.combustion.remains>20|talent.firestarter.enabled&firestarter.remains>20
    if I.PocketsizedComputationDevice:IsReady() and S.CyclotronicBlast:IsAvailable() and (S.Combustion:CooldownRemainsP() > 20 or S.Firestarter:IsAvailable() and S.Firestarter:ActiveRemains() > 20) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- scorch,if=target.health.pct<=30&talent.searing_touch.enabled
    if S.Scorch:IsCastableP() and (Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) then
      return S.Scorch:Cast()
    end
    -- fireball
    if S.Fireball:IsCastableP() then
      return S.Fireball:Cast()
    end
    -- scorch
    if S.Scorch:IsCastableP() then
      return S.Scorch:Cast()
    end
  end
  
  	-- Protect against interrupt of channeled spells
    if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) or Player:IsChanneling() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end 
  
    -- call precombat DBM
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and RubimRH.PerfectPullON() and not Player:IsCasting() then
        if Precombat_DBM() ~= nil then
            return Precombat_DBM()
        end
    end
	-- call precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and not RubimRH.PerfectPullON() and not Player:IsCasting() then
        if Precombat() ~= nil then
            return Precombat()
        end
    end
  
  -- In Combat
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
	-- scorch.moving
    if S.Scorch:IsCastableP() and Player:IsMoving() then
      return S.Scorch:Cast()
    end
    -- mirror_image,if=buff.combustion.down
    if S.MirrorImage:IsCastableP() and (Player:BuffDownP(S.CombustionBuff)) then
      return S.MirrorImage:Cast()
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
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
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force
    if S.TheUnboundForce:IsCastableP() then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- rune_of_power,if=talent.firestarter.enabled&firestarter.remains>full_recharge_time|cooldown.combustion.remains>variable.combustion_rop_cutoff&buff.combustion.down|target.time_to_die<cooldown.combustion.remains&buff.combustion.down
    if S.RuneofPower:IsCastableP() and (S.Firestarter:IsAvailable() and S.Firestarter:ActiveRemains() > S.RuneofPower:FullRechargeTimeP() or S.Combustion:CooldownRemainsP() > VarCombustionRopCutoff and Player:BuffDownP(S.CombustionBuff) or Target:TimeToDie() < S.Combustion:CooldownRemainsP() and Player:BuffDownP(S.CombustionBuff)) then
      return S.RuneofPower:Cast()
    end
    -- use_item,name=malformed_heralds_legwraps,if=cooldown.combustion.remains>55
    if I.MalformedHeraldsLegwraps:IsReady() and (S.Combustion:CooldownRemainsP() > 55) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- call_action_list,name=combustion_phase,if=(talent.rune_of_power.enabled&cooldown.combustion.remains<=action.rune_of_power.cast_time|cooldown.combustion.ready)&!firestarter.active|buff.combustion.up
    if RubimRH.CDsON() and (S.RuneofPower:IsAvailable() and S.Combustion:CooldownRemainsP() <= S.RuneofPower:CastTime() or S.Combustion:CooldownUpP()) and not bool(S.Firestarter:ActiveStatus()) or Player:BuffP(S.CombustionBuff) then
      local ShouldReturn = CombustionPhase(); if ShouldReturn then return ShouldReturn; end
    end
    -- fire_blast,use_while_casting=1,use_off_gcd=1,if=(essence.memory_of_lucid_dreams.major|essence.memory_of_lucid_dreams.minor&azerite.blaster_master.enabled)&charges=max_charges&!buff.hot_streak.react&!(buff.heating_up.react&(buff.combustion.up&(action.fireball.in_flight|action.pyroblast.in_flight|action.scorch.executing)|target.health.pct<=30&action.scorch.executing))&!(!buff.heating_up.react&!buff.hot_streak.react&buff.combustion.down&(action.fireball.in_flight|action.pyroblast.in_flight))
    if S.FireBlast:IsCastableP() and (S.MemoryOfLucidDreams:IsAvailable() or S.MemoryOfLucidDreamsMinor:IsAvailable() and S.BlasterMaster:AzeriteEnabled()) and S.FireBlast:ChargesP() == S.FireBlast:MaxCharges() and not Player:BuffP(S.HotStreakBuff) and not (Player:BuffP(S.HeatingUpBuff) and (Player:BuffP(S.CombustionBuff) and (S.Fireball:InFlight() or S.Pyroblast:InFlight() or Player:IsCasting(S.Scorch)) or Target:HealthPercentage() <= 30 and Player:IsCasting(S.Scorch))) and not (not Player:BuffP(S.HeatingUpBuff) and not Player:BuffP(S.HotStreakBuff) and Player:BuffDownP(S.CombustionBuff) and (S.Fireball:InFlight() or S.Pyroblast:InFlight())) then
      return S.FireBlast:Cast()
    end
    -- call_action_list,name=rop_phase,if=buff.rune_of_power.up&buff.combustion.down
    if Player:BuffP(S.RuneofPowerBuff) and Player:BuffDownP(S.CombustionBuff) then
      local ShouldReturn = RopPhase(); if ShouldReturn then return ShouldReturn; end
    end
    -- variable,name=fire_blast_pooling,value=talent.rune_of_power.enabled&cooldown.rune_of_power.remains<cooldown.fire_blast.full_recharge_time&(cooldown.combustion.remains>variable.combustion_rop_cutoff|firestarter.active)&(cooldown.rune_of_power.remains<target.time_to_die|action.rune_of_power.charges>0)|cooldown.combustion.remains<action.fire_blast.full_recharge_time+cooldown.fire_blast.duration*azerite.blaster_master.enabled&!firestarter.active&cooldown.combustion.remains<target.time_to_die|talent.firestarter.enabled&firestarter.active&firestarter.remains<cooldown.fire_blast.full_recharge_time+cooldown.fire_blast.duration*azerite.blaster_master.enabled
    if (true) then
      VarFireBlastPooling = num(S.RuneofPower:IsAvailable() and S.RuneofPower:CooldownRemainsP() < S.FireBlast:FullRechargeTimeP() and (S.Combustion:CooldownRemainsP() > VarCombustionRopCutoff or bool(S.Firestarter:ActiveStatus())) and (S.RuneofPower:CooldownRemainsP() < Target:TimeToDie() or S.RuneofPower:ChargesP() > 0) or S.Combustion:CooldownRemainsP() < S.FireBlast:FullRechargeTimeP() + S.FireBlast:BaseDuration() * num(S.BlasterMaster:AzeriteEnabled()) and not bool(S.Firestarter:ActiveStatus()) and S.Combustion:CooldownRemainsP() < Target:TimeToDie() or S.Firestarter:IsAvailable() and bool(S.Firestarter:ActiveStatus()) and S.Firestarter:ActiveRemains() < S.FireBlast:FullRechargeTimeP() + S.FireBlast:BaseDuration() * num(S.BlasterMaster:AzeriteEnabled()))
    end
    -- variable,name=phoenix_pooling,value=talent.rune_of_power.enabled&cooldown.rune_of_power.remains<cooldown.phoenix_flames.full_recharge_time&cooldown.combustion.remains>variable.combustion_rop_cutoff&(cooldown.rune_of_power.remains<target.time_to_die|action.rune_of_power.charges>0)|cooldown.combustion.remains<action.phoenix_flames.full_recharge_time&cooldown.combustion.remains<target.time_to_die
    if (true) then
      VarPhoenixPooling = num(S.RuneofPower:IsAvailable() and S.RuneofPower:CooldownRemainsP() < S.PhoenixFlames:FullRechargeTimeP() and S.Combustion:CooldownRemainsP() > VarCombustionRopCutoff and (S.RuneofPower:CooldownRemainsP() < Target:TimeToDie() or S.RuneofPower:ChargesP() > 0) or S.Combustion:CooldownRemainsP() < S.PhoenixFlames:FullRechargeTimeP() and S.Combustion:CooldownRemainsP() < Target:TimeToDie())
    end
    -- call_action_list,name=standard_rotation
    if (true) then
      local ShouldReturn = StandardRotation(); if ShouldReturn then return ShouldReturn; end
    end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(63, APL)

local function PASSIVE()
    if S.IceBlock:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[63].sk1 then
        return S.IceBlock:Cast()
    end

    if S.BlazingBarrier:IsReady() and not Player:Buff(S.BlazingBarrier) and  Player:HealthPercentage() <= RubimRH.db.profile[63].sk2 then
        return S.BlazingBarrier:Cast()
    end
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(63, PASSIVE)