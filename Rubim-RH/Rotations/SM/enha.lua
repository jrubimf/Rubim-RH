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

--Enhancement
RubimRH.Spell[263] = {
  -- Racials
  Berserking            = Spell(26297),
  BloodFury             = Spell(20572),
  Fireblood             = Spell(265221),
  AncestralCall         = Spell(274738),

  -- Abilities
  CrashLightning        = Spell(187874),
  CrashLightningBuff    = Spell(187878), -- CrashLightning buff for hitting 2 or more targets
  Flametongue           = Spell(193796),
  FlametongueBuff       = Spell(194084),
  Frostbrand            = Spell(196834),
  FrostbrandBuff        = Spell(196834),
  StormStrike           = Spell(17364),
  StormbringerBuff      = Spell(201846),
  EarthElemental        = Spell(198103),
  GatheringStormsBuff   = Spell(198300),

  FeralSpirit           = Spell(51533),
  LavaLash              = Spell(60103),
  LightningBolt         = Spell(187837),
  Rockbiter             = Spell(193786),
  WindStrike            = Spell(115356),
  HealingSurge          = Spell(188070),

  -- Talents
  HotHand               = Spell(201900),
  HotHandBuff           = Spell(215785),
  Landslide             = Spell(197992),
  LandslideBuff         = Spell(202004),
  Hailstorm             = Spell(210853),
  Overcharge            = Spell(210727),
  CrashingStorm         = Spell(192246),
  FuryOfAir             = Spell(197211),
  FuryOfAirBuff         = Spell(197211),
  Sundering             = Spell(197214),
  Ascendance            = Spell(114051),
  AscendanceBuff        = Spell(114051),
  EarthenSpike          = Spell(188089),
  EarthenSpikeDebuff    = Spell(188089),
  ForcefulWinds         = Spell(262647),
  SearingAssault        = Spell(192087),
  LightningShield       = Spell(192106),
  LightningShieldBuff   = Spell(192106),
  ElementalSpirits      = Spell(262624),

  TotemMastery          = Spell(262395),
  ResonanceTotemBuff    = Spell(262417),
  StormTotemBuff        = Spell(262397),
  EmberTotemBuff        = Spell(262399),
  TailwindTotemBuff     = Spell(262400),

  -- Utility
  WindShear             = Spell(57994),

  -- Legion Trinkets
  SpecterOfBetrayal     = Spell(246461),
  HornOfValor           = Spell(215956),

  -- Item Buffs
  BSARBuff              = Spell(270058),
  DFRBuff               = Spell(224001),

  -- Azerite
  LightningConduit 		= Spell(275388),
  LightNingConduitDebuff = Spell(275391),


  
}

local S = RubimRH.Spell[263]
local G = RubimRH.Spell[1] -- General Skills



-- Items
if not Item.Shaman then
	Item.Shaman = {};
end
Item.Shaman.Enhancement = {

  -- BfA Consumables
  Healthstone               = Item(5512),

  BPoA                      = Item(163223),  -- Battle Potion of Agility
  CHP                       = Item(152494),  -- Coastal Healing Potion
  BSAR                      = Item(160053),  -- Battle-Scarred Augment Rune
}
local I = Item.Shaman.Enhancement;

local EnemyRanges = {"Melee", 10, 30, 40}
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


--- APL Variables
-- actions+=/variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
local function furyCheck45()
  return (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 45))
end

-- actions+=/variable,name=furyCheck35,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>35))
local function furyCheck35()
  return (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 35))
end

-- actions+=/variable,name=furyCheck25,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>25))
local function furyCheck25()
  return (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 25))
end


-- actions+=/variable,name=OCPool80,value=(!talent.overcharge.enabled|active_enemies>1|(talent.overcharge.enabled&active_enemies=1&(cooldown.lightning_bolt.remains>=2*gcd|maelstrom>80)))
local function OCPool80()
  return (not S.Overcharge:IsAvailable() or Cache.EnemiesCount[10] > 1 or (S.Overcharge:IsAvailable() and Cache.EnemiesCount[10] > 1 and (S.LightningBolt:CooldownRemainsP() >= 2 * Player:GCD() or Player:Maelstrom() > 80)))
end

-- actions+=/variable,name=OCPool70,value=(!talent.overcharge.enabled|active_enemies>1|(talent.overcharge.enabled&active_enemies=1&(cooldown.lightning_bolt.remains>=2*gcd|maelstrom>70)))
local function OCPool70()
  return (not S.Overcharge:IsAvailable() or Cache.EnemiesCount[10] > 1 or (S.Overcharge:IsAvailable() and Cache.EnemiesCount[10] > 1 and (S.LightningBolt:CooldownRemainsP() >= 2 * Player:GCD() or Player:Maelstrom() > 70)))
end

-- actions+=/variable,name=OCPool60,value=(!talent.overcharge.enabled|active_enemies>1|(talent.overcharge.enabled&active_enemies=1&(cooldown.lightning_bolt.remains>=2*gcd|maelstrom>60)))
local function OCPool60()
  return (not S.Overcharge:IsAvailable() or Cache.EnemiesCount[10] > 1 or (S.Overcharge:IsAvailable() and Cache.EnemiesCount[10] > 1 and (S.LightningBolt:CooldownRemainsP() >= 2 * Player:GCD() or Player:Maelstrom() > 60)))
end

local function APL()

        local Precombat
            UpdateRanges()
            Precombat = function()
            end

        if not Player:AffectingCombat() then
        
        if Precombat() ~= nil then
             return Precombat()
        end

         return 0, 462338
    end

    -- In Combat
  	      if S.WindShear:IsReady(30) and RubimRH.db.profile.mainOption.useInterrupts and Player:Maelstrom() >= S.WindStrike:Cost() and Target:IsInterruptible() then
      return S.WindShear:Cast() 
	    end


    -- Healing surge when we have less than the set health threshold!
    if S.HealingSurge:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[263].sk1 then
      -- Instant casts using maelstrom only.
      if Player:Maelstrom() >= 20 then
       return S.HealingSurge:Cast()
      end
    end
   
    -- Lightning Shield: Not in the APL, but if we are talented into it and don't use it, what good is it?
    if S.LightningShield:IsAvailable() and not Player:Buff(S.LightningShieldBuff) then
      return S.LightningShield:Cast()
    end

    -- actions+=/call_action_list,name=asc,if=buff.ascendance.up
    if Player:Buff(S.AscendanceBuff) then
      -- actions.asc=crash_lightning,if=!buff.crash_lightning.up&active_enemies>1&variable.furyCheck25
      if S.CrashLightning:IsReady("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (not Player:Buff(S.CrashLightningBuff) and Cache.EnemiesCount[10] > 1 and furyCheck25()) then
        return S.CrashLightning:Cast()
      end

      -- actions.asc+=/rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
      if S.Rockbiter:IsReady(20) and S.Landslide:IsAvailable() and not Player:Buff(S.LandslideBuff) and S.Rockbiter:ChargesFractional() > 1.7 then
        return S.Rockbiter:Cast()
      end

      -- actions.asc+=/windstrike
      if S.WindStrike:IsReady(30) and Player:Maelstrom() >= S.WindStrike:Cost() then
        return S.WindStrike:Cast()
      end
    end

    -- actions+=/call_action_list,name=buffs
    -- actions.buffs=crash_lightning,if=!buff.crash_lightning.up&active_enemies>1&variable.furyCheck25
    if S.CrashLightning:IsReady("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (not Player:Buff(S.CrashLightningBuff) and Cache.EnemiesCount[10] > 1 and furyCheck25()) then
      return S.CrashLightning:Cast()
    end

    -- actions.buffs+=/rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
    if S.Rockbiter:IsReady(20) and (S.Landslide:IsAvailable() and not Player:Buff(S.LandslideBuff) and S.Rockbiter:ChargesFractional() > 1.7) then
      return S.Rockbiter:Cast()
    end

    -- actions.buffs+=/fury_of_air,if=!ticking&maelstrom>=20
    if S.FuryOfAir:IsReady(10, true) and Player:Maelstrom() >= S.FuryOfAir:Cost() and (not Player:Buff(S.FuryOfAirBuff) and Player:Maelstrom() >= 20) then
      return S.FuryOfAir:Cast()
    end

    -- actions.buffs+=/flametongue,if=!buff.flametongue.up
    if S.Flametongue:IsReady(20) and (not Player:Buff(S.FlametongueBuff)) then
      return S.Flametongue:Cast()
    end

    -- actions.buffs+=/frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck25
    if S.Frostbrand:IsReady(20) and Player:Maelstrom() >= S.Frostbrand:Cost() and (S.Hailstorm:IsAvailable() and not Player:Buff(S.FrostbrandBuff) and furyCheck25()) then
      return S.Frostbrand:Cast()
    end

    -- actions.buffs+=/flametongue,if=buff.flametongue.remains<4.8+gcd
    if S.Flametongue:IsReady(20) and (Player:BuffRemainsP(S.FlametongueBuff) < 4.8 + Player:GCD()) then
      return S.Flametongue:Cast()
    end

    -- actions.buffs+=/frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8+gcd&variable.furyCheck25
    if S.Frostbrand:IsReady(20) and Player:Maelstrom() >= S.Frostbrand:Cost() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 4.8 + Player:GCD() and furyCheck25()) then
      return S.Frostbrand:Cast()
    end

    -- Not exact, but if we don't have totems down then place them
    -- actions.buffs+=/totem_mastery,if=buff.resonance_totem.remains<2
    if S.TotemMastery:IsReady() and (not Player:Buff(S.ResonanceTotemBuff)) then
      return S.TotemMastery:Cast()
    end

    -- actions+=/call_action_list,name=cds
    if RubimRH.CDsON() then
      -- Racial
      -- actions.cds+=/berserking,if=(talent.ascendance.enabled&buff.ascendance.up)|(talent.elemental_spirits.enabled&feral_spirit.remains>5)|(!talent.ascendance.enabled&!talent.elemental_spirits.enabled)
      if S.Berserking:IsReady() and (S.Ascendance:IsAvailable() or (S.ElementalSpirits:IsAvailable() and S.FeralSpirit:TimeSinceLastCast() <= 10) or (not S.Ascendance:IsAvailable() and not S.ElementalSpirits:IsAvailable())) then
        return S.Berserking:Cast()
      end

      -- Racial
      -- actions.cds+=/blood_fury,if=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
      if S.BloodFury:IsReady() and ((S.Ascendance:IsAvailable() and (Player:Buff(S.AscendanceBuff) or S.Ascendance:TimeSinceLastCast() <= 130)) or (not S.Ascendance:IsAvailable() and (S.FeralSpirit:TimeSinceLastCast() <= 10 or S.Ascendance:TimeSinceLastCast() <= 130))) then
        return S.BloodFury:Cast()
      end

      -- Racial
      -- actions.cds+=/fireblood,if=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
      if S.Fireblood:IsReady() and ((S.Ascendance:IsAvailable() and (Player:Buff(S.AscendanceBuff) or S.Ascendance:TimeSinceLastCast() <= 130)) or (not S.Ascendance:IsAvailable() and (S.FeralSpirit:TimeSinceLastCast() <= 10 or S.Ascendance:TimeSinceLastCast() <= 130))) then
        return S.Fireblood:Cast()
      end

      -- Racial
      -- actions.cds+=/ancestral_call,if=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
      if S.AncestralCall:IsReady() and ((S.Ascendance:IsAvailable() and (Player:Buff(S.AscendanceBuff) or S.Ascendance:TimeSinceLastCast() <= 130)) or (not S.Ascendance:IsAvailable() and (S.FeralSpirit:TimeSinceLastCast() <= 10 or S.Ascendance:TimeSinceLastCast() <= 130))) then
         return S.AncestralCall:Cast()
      end

      -- actions.cds+=/potion,if=buff.ascendance.up|!talent.ascendance.enabled&feral_spirit.remains>5|target.time_to_die<=60
      -- Already handled

      -- actions.cds+=/feral_spirit
      if S.FeralSpirit:IsReady() then
        return S.FeralSpirit:Cast()
      end

      -- actions.cds+=/ascendance,if=cooldown.strike.remains>0
      if S.Ascendance:IsReady() and ((S.WindStrike:CooldownRemainsP() > 0 or S.StormStrike:CooldownRemainsP() > 0)) then
        return S.Ascendance:Cast()
      end

      -- actions.cds+=/earth_elemental
      if S.EarthElemental:IsReady()  then
        return S.EarthElemental:Cast()
      end
    end

    -- actions+=/call_action_list,name=core
    -- actions.core=earthen_spike,if=variable.furyCheck25
    if S.EarthenSpike:IsReady(10) and Player:Maelstrom() >= S.EarthenSpike:Cost() and (furyCheck25()) then
      return S.EarthenSpike:Cast()
    end

    -- actions.core+=/sundering,if=active_enemies>=3
    if S.Sundering:IsReady(10) and Player:Maelstrom() >= S.Sundering:Cost() and (Cache.EnemiesCount[10] >= 3) then
      return S.Sundering:Cast()
    end

 
    -- actions.core+=/stormstrike,cycle_targets=1,if=azerite.lightning_conduit.enabled&!debuff.lightning_conduit.up&active_enemies>1&(buff.stormbringer.up|(variable.OCPool70&variable.furyCheck35))
     if S.StormStrike:IsReady("Melee") and S.LightningConduit:AzeriteEnabled() and not Target:Debuff(S.LightNingConduitDebuff) and Cache.EnemiesCount[8] >= 1 and (Player:Buff(S.StormbringerBuff) or OCPool70() and furyCheck35()) then
    	return S.StormStrike:Cast()
    end

    -- actions.core+=/stormstrike,if=buff.stormbringer.up|(buff.gathering_storms.up&variable.OCPool70&variable.furyCheck35)
    if S.StormStrike:IsReady("Melee") and Player:Maelstrom() >= S.StormStrike:Cost() and (Player:Buff(S.StormbringerBuff) or (Player:Buff(S.GatheringStormsBuff) and OCPool70() and furyCheck35())) then
      return S.StormStrike:Cast()
    end

    -- actions.core+=/crash_lightning,if=active_enemies>=3&variable.furyCheck25
    if S.CrashLightning:IsReady("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (Cache.EnemiesCount[10] >= 3 and furyCheck25()) then
      return S.CrashLightning:Cast()
    end

    -- actions.core+=/lightning_bolt,if=talent.overcharge.enabled&active_enemies=1&variable.furyCheck45&maelstrom>=40
    if S.LightningBolt:IsReady(40) and (S.Overcharge:IsAvailable() and Cache.EnemiesCount[40] == 1 and furyCheck45() and Player:Maelstrom() >= 40) then
      return S.LightningBolt:Cast()
    end

    -- actions.core+=/stormstrike,if=variable.OCPool70&variable.furyCheck35
    if S.StormStrike:IsReady("Melee") and Player:Maelstrom() >= S.StormStrike:Cost() and (OCPool70() and furyCheck35()) then
      return S.StormStrike:Cast()
    end

    -- actions.filler+=/sundering
    if S.Sundering:IsReady(10) and Player:Maelstrom() >= S.Sundering:Cost() then
      return S.Sundering:Cast()
    end

    -- actions.core+=/crash_lightning,if=talent.forceful_winds.enabled&active_enemies>1&variable.furyCheck25
    if S.CrashLightning:IsReady("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (S.ForcefulWinds:IsAvailable() and Cache.EnemiesCount[10] > 1 and furyCheck25()) then
      return S.CrashLightning:Cast()
    end

    -- actions.core+=/flametongue,if=talent.searing_assault.enabled
    if S.Flametongue:IsReady(20) and (S.SearingAssault:IsAvailable()) then
      return S.Flametongue:Cast()
    end

    -- actions.core+=/lava_lash,if=talent.hot_hand.enabled&buff.hot_hand.react
    if S.LavaLash:IsReady("Melee") and Player:Maelstrom() >= S.LavaLash:Cost() and (S.HotHand:IsAvailable() and Player:Buff(S.HotHandBuff)) then
      return S.LavaLash:Cast()
    end

    -- actions.core+=/crash_lightning,if=active_enemies>1&variable.furyCheck25
    if S.CrashLightning:IsReady("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (Cache.EnemiesCount[10] > 1 and furyCheck25()) then
    return S.CrashLightning:Cast()
    end

    -- actions+=/call_action_list,name=filler
    -- actions.filler=rockbiter,if=maelstrom<70
    if S.Rockbiter:IsReady(20) and (Player:Maelstrom() < 70) then
      return S.Rockbiter:Cast()
    end

    -- actions.filler+=/crash_lightning,if=talent.crashing_storm.enabled&variable.OCPool60
    if S.CrashLightning:IsReady("Melee", true) and Player:Maelstrom() >= S.CrashLightning:Cost() and (S.CrashingStorm:IsAvailable() and OCPool60()) then
      return S.CrashLightning:Cast()
    end

    -- actions.filler+=/lava_lash,if=variable.OCPool80&variable.furyCheck45
    if S.LavaLash:IsReady("Melee") and Player:Maelstrom() >= S.LavaLash:Cost() then
        return S.LavaLash:Cast()
    end

    -- actions.filler+=/rockbiter
    if S.Rockbiter:IsReady(20) then
      return S.Rockbiter:Cast()
    end

    -- actions.filler+=/flametongue
    if S.Flametongue:IsReady(20) then
        return S.Flametongue:Cast()
    end

  end

RubimRH.Rotation.SetAPL(263, APL)


local function PASSIVE()

	if S.LightningShield:IsAvailable() and not Player:Buff(S.LightningShieldBuff) then
      return S.LightningShield:Cast()
    end

        if S.WindShear:IsReady(30) and RubimRH.db.profile.mainOption.useInterrupts and Player:Maelstrom() >= S.WindStrike:Cost() and Target:IsInterruptible() then
      return S.WindShear:Cast() 
	    end

    return RubimRH.Shared()
	

end


RubimRH.Rotation.SetPASSIVE(263, PASSIVE);
