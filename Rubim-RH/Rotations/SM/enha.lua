--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
local mainAddon = RubimRH
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item
--local MultiSpell = HL.MultiSpell

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[263] = {
  LightningShield                       = Spell(192106),
  CrashLightning                        = Spell(187874),
  CrashLightningBuff                    = Spell(187874),
  Rockbiter                             = Spell(193786),
  Landslide                             = Spell(197992),
  LandslideBuff                         = Spell(202004),
  Windstrike                            = Spell(115356),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  AscendanceBuff                        = Spell(114051),
  Ascendance                            = Spell(114051),
  FeralSpirit                           = Spell(51533),
  EarthenSpike                          = Spell(188089),
  Stormstrike                           = Spell(17364),
  LightningConduit                      = Spell(275388),
  LightningConduitDebuff                = Spell(275391),
  StormbringerBuff                      = Spell(201845),
  GatheringStormsBuff                   = Spell(198300),
  LightningBolt                         = Spell(187837),
  Overcharge                            = Spell(210727),
  Sundering                             = Spell(197214),
  ForcefulWinds                         = Spell(262647),
  Flametongue                           = Spell(193796),
  SearingAssault                        = Spell(192087),
  LavaLash                              = Spell(60103),
  PrimalPrimer                          = Spell(272992),
  HotHand                               = Spell(201900),
  HotHandBuff                           = Spell(215785),
  StrengthofEarthBuff                   = Spell(273465),
  CrashingStorm                         = Spell(192246),
  Frostbrand                            = Spell(196834),
  Hailstorm                             = Spell(210853),
  FrostbrandBuff                        = Spell(196834),
  PrimalPrimerDebuff                    = Spell(273006),
  FlametongueBuff                       = Spell(194084),
  FuryofAir                             = Spell(197211),
  FuryofAirBuff                         = Spell(197211),
  TotemMastery                          = Spell(262395),
  ResonanceTotemBuff                    = Spell(262419),
  SunderingDebuff                       = Spell(197214),
  NaturalHarmony                        = Spell(278697),
  NaturalHarmonyFrostBuff               = Spell(279029),
  NaturalHarmonyFireBuff                = Spell(279028),
  NaturalHarmonyNatureBuff              = Spell(279033),
  WindShear                             = Spell(57994),
  EarthenSpikeDebuff                    = Spell(188089),
  Boulderfist                           = Spell(246035),
  StrengthofEarth                       = Spell(273461),
  RecklessForce                         = Spell(302932),
  
  		  --8.2 Essences
  UnleashHeartOfAzeroth = Spell(280431),
  BloodOfTheEnemy       = Spell(297108),
  BloodOfTheEnemy2      = Spell(298273),
  BloodOfTheEnemy3      = Spell(298277),
  ConcentratedFlame     = Spell(295373),
  ConcentratedFlame2    = Spell(299349),
  ConcentratedFlame3    = Spell(299353),
  GuardianOfAzeroth     = Spell(295840),
  GuardianOfAzeroth2    = Spell(299355),
  GuardianOfAzeroth3    = Spell(299358),
  FocusedAzeriteBeam    = Spell(295258),
  FocusedAzeriteBeam2   = Spell(299336),
  FocusedAzeriteBeam3   = Spell(299338),
  PurifyingBlast        = Spell(295337),
  PurifyingBlast2       = Spell(299345),
  PurifyingBlast3       = Spell(299347),
  TheUnboundForce       = Spell(298452),
  TheUnboundForce2      = Spell(299376),
  TheUnboundForce3      = Spell(299378),
  RippleInSpace         = Spell(302731),
  RippleInSpace2        = Spell(302982),
  RippleInSpace3        = Spell(302983),
  WorldveinResonance    = Spell(295186),
  WorldveinResonance2   = Spell(298628),
  WorldveinResonance3   = Spell(299334),
  MemoryOfLucidDreams   = Spell(298357),
  MemoryOfLucidDreams2  = Spell(299372),
  MemoryOfLucidDreams3  = Spell(299374),
  
  -- 8.2 Essences
 -- BloodOfTheEnemy                       = MultiSpell(297108, 298273, 298277),
 -- MemoryOfLucidDreams                   = MultiSpell(298357, 299372, 299374),
 -- PurifyingBlast                        = MultiSpell(295337, 299345, 299347),
 -- ConcentratedFlame                     = MultiSpell(295373, 299349, 299353),
 -- TheUnboundForce                       = MultiSpell(298452, 299376, 299378),
 -- WorldveinResonance                    = MultiSpell(295186, 298628, 299334),
 -- FocusedAzeriteBeam                    = MultiSpell(295258, 299336, 299338),
 -- GuardianOfAzeroth                     = MultiSpell(295840, 299355, 299358),
  
};
local S = RubimRH.Spell[263]

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Enhancement = {
  BattlePotionofAgility            = Item(163223)
};
local I = Item.Shaman.Enhancement;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- Variables
local VarFurycheckCl = 0;
local VarCooldownSync = 0;
local VarFurycheckEs = 0;
local VarFurycheckSs = 0;
local VarFurycheckLb = 0;
local VarOcpoolSs = 0;
local VarOcpoolCl = 0;
local VarOcpoolLl = 0;
local VarFurycheckLl = 0;
local VarFurycheckFb = 0;
local VarClpoolLl = 0;
local VarClpoolSs = 0;
local VarFreezerburnEnabled = 0;
local VarOcpool = 0;
local VarOcpoolFb = 0;
local VarRockslideEnabled = 0;

HL:RegisterForEvent(function()
  VarFurycheckCl = 0
  VarCooldownSync = 0
  VarFurycheckEs = 0
  VarFurycheckSs = 0
  VarFurycheckLb = 0
  VarOcpoolSs = 0
  VarOcpoolCl = 0
  VarOcpoolLl = 0
  VarFurycheckLl = 0
  VarFurycheckFb = 0
  VarClpoolLl = 0
  VarClpoolSs = 0
  VarFreezerburnEnabled = 0
  VarOcpool = 0
  VarOcpoolFb = 0
  VarRockslideEnabled = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {8, 5}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

function TotemMastery()
    for i = 1, 5 do
        local active, totemName, startTime, duration, textureId  = GetTotemInfo(i)
        if active == true and textureId == 511726 then
            return startTime + duration - GetTime()
        end
    end
    return 0
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local PetType = {
  [29264] = {"Spirit Wolf", 15},
};

HL.EnhancementGuardiansTable = {
    --{PetType,petID,dateEvent,UnitPetGUID,CastsLeft}
    Pets = {
    },
    PetList={
    [29264]="Spirit Wolf",
}
};
    
HL:RegisterForSelfCombatEvent(
function (...)
    local dateEvent,_,_,_,_,_,_,UnitPetGUID=select(1,...)
    local t={} ; i=1
  
    for str in string.gmatch(UnitPetGUID, "([^-]+)") do
        t[i] = str
        i = i + 1
    end
    local PetType=HL.EnhancementGuardiansTable.PetList[tonumber(t[6])]
    if PetType then
        table.insert(HL.EnhancementGuardiansTable.Pets,{PetType,tonumber(t[6]),GetTime(),UnitPetGUID,5})
    end
end
    , "SPELL_SUMMON"
);
        
-- Summoned pet duration
local function PetDuration(PetType)
    if not PetType then 
        return 0 
    end
    local PetsInfo = {
        [29264] = {"Spirit Wolf", 15},
    }
    local maxduration = 0
    for key, Value in pairs(HL.EnhancementGuardiansTable.Pets) do
        if HL.EnhancementGuardiansTable.Pets[key][1] == PetType then
            if (PetsInfo[HL.EnhancementGuardiansTable.Pets[key][2]][2] - (GetTime() - HL.EnhancementGuardiansTable.Pets[key][3])) > maxduration then
                maxduration = HL.OffsetRemains((PetsInfo[HL.EnhancementGuardiansTable.Pets[key][2]][2] - (GetTime() - HL.EnhancementGuardiansTable.Pets[key][3])), "Auto" );
            end
        end
    end
    return maxduration
end

local function SpiritWolfIsActive()
    if PetDuration("Spirit Wolf") > 0.1 then
        return true
    else
        return false
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

--[[local function DetermineEssenceRanks()
  S.BloodOfTheEnemy = S.BloodOfTheEnemy2:IsAvailable() and S.BloodOfTheEnemy2 or S.BloodOfTheEnemy
  S.BloodOfTheEnemy = S.BloodOfTheEnemy3:IsAvailable() and S.BloodOfTheEnemy3 or S.BloodOfTheEnemy
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams2:IsAvailable() and S.MemoryOfLucidDreams2 or S.MemoryOfLucidDreams
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams3:IsAvailable() and S.MemoryOfLucidDreams3 or S.MemoryOfLucidDreams
  S.PurifyingBlast = S.PurifyingBlast2:IsAvailable() and S.PurifyingBlast2 or S.PurifyingBlast
  S.PurifyingBlast = S.PurifyingBlast3:IsAvailable() and S.PurifyingBlast3 or S.PurifyingBlast
  S.ConcentratedFlame = S.ConcentratedFlame2:IsAvailable() and S.ConcentratedFlame2 or S.ConcentratedFlame
  S.ConcentratedFlame = S.ConcentratedFlame3:IsAvailable() and S.ConcentratedFlame3 or S.ConcentratedFlame
  S.TheUnboundForce = S.TheUnboundForce2:IsAvailable() and S.TheUnboundForce2 or S.TheUnboundForce
  S.TheUnboundForce = S.TheUnboundForce3:IsAvailable() and S.TheUnboundForce3 or S.TheUnboundForce
  S.WorldveinResonance = S.WorldveinResonance2:IsAvailable() and S.WorldveinResonance2 or S.WorldveinResonance
  S.WorldveinResonance = S.WorldveinResonance3:IsAvailable() and S.WorldveinResonance3 or S.WorldveinResonance
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam2:IsAvailable() and S.FocusedAzeriteBeam2 or S.FocusedAzeriteBeam
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam3:IsAvailable() and S.FocusedAzeriteBeam3 or S.FocusedAzeriteBeam
  S.GuardianOfAzeroth = S.GuardianOfAzeroth2:IsAvailable() and S.GuardianOfAzeroth2 or S.GuardianOfAzeroth
  S.GuardianOfAzeroth = S.GuardianOfAzeroth3:IsAvailable() and S.GuardianOfAzeroth3 or S.GuardianOfAzeroth
end]]--

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
  local Precombat, Asc, Cds, DefaultCore, Filler, FreezerburnCore, Maintenance, Opener, Priority
  UpdateRanges()

  Precombat = function()
   	  --essences updater
	  DetermineEssenceRanks()	
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion

    -- lightning_shield
    if S.LightningShield:IsCastableP() and not Player:BuffP(S.LightningShield) then
      return S.LightningShield:Cast()
    end
  end
  
  Asc = function()
    -- crash_lightning,if=!buff.crash_lightning.up&active_enemies>1&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and not Player:BuffP(S.CrashLightningBuff) and active_enemies() > 1 and bool(VarFurycheckCl) then
      return S.CrashLightning:Cast()
    end
    -- rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
    if S.Rockbiter:IsCastableP() and (S.Landslide:IsAvailable() and not Player:BuffP(S.LandslideBuff) and S.Rockbiter:ChargesFractionalP() > 1.7) then
      return S.Rockbiter:Cast()
    end
    -- windstrike
    if S.Windstrike:CooldownRemainsP() < 0.1 then
      return S.Windstrike:Cast()
    end
  end
  
  Cds = function()
  
-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn and (true) then return ShouldReturn; end
    -- bloodlust,if=azerite.ancestral_resonance.enabled
    -- berserking,if=variable.cooldown_sync
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and (bool(VarCooldownSync)) then
      return S.Berserking:Cast()
    end
    -- blood_fury,if=variable.cooldown_sync
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (bool(VarCooldownSync)) then
      return S.BloodFury:Cast()
    end
    -- fireblood,if=variable.cooldown_sync
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (bool(VarCooldownSync)) then
      return S.Fireblood:Cast()
    end
    -- ancestral_call,if=variable.cooldown_sync
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() and (bool(VarCooldownSync)) then
      return S.AncestralCall:Cast()
    end
    -- potion,if=buff.ascendance.up|!talent.ascendance.enabled&feral_spirit.remains>5|target.time_to_die<=60
    -- actions.cds+=/guardian_of_azeroth
   -- if S.GuardianOfAzeroth:IsCastableP() then
   --   return S.GuardianOfAzeroth:Cast()
   -- end

    -- actions.cds+=/memory_of_lucid_dreams
   -- if S.MemoryOfLucidDreams:IsCastableP() then
   --   return S.MemoryOfLucidDreams:Cast()
   -- end
    -- feral_spirit
    if S.FeralSpirit:IsCastableP() then
      return S.FeralSpirit:Cast()
    end
	-- actions.cds+=/blood_of_the_enemy
   -- if S.BloodOfTheEnemy:IsCastableP() then
    --  return S.BloodOfTheEnemy:Cast()
   -- end
    -- ascendance,if=cooldown.strike.remains>0
    if S.Ascendance:IsCastableP() then
      return S.Ascendance:Cast()
    end
    -- earth_elemental
  end
  
  DefaultCore = function()
    -- earthen_spike,if=variable.furyCheck_ES
    if S.EarthenSpike:IsCastableP() and (bool(VarFurycheckEs)) then
      return S.EarthenSpike:Cast()
    end
    -- stormstrike,cycle_targets=1,if=active_enemies>1&azerite.lightning_conduit.enabled&!debuff.lightning_conduit.up&variable.furyCheck_SS
    if S.Stormstrike:IsCastableP() and active_enemies() > 1 and S.LightningConduit:AzeriteEnabled() and not TargetUnit:DebuffP(S.LightningConduitDebuff) and bool(VarFurycheckSs) then
      return Stormstrike:Cast()
    end
    -- stormstrike,if=buff.stormbringer.up|(active_enemies>1&buff.gathering_storms.up&variable.furyCheck_SS)
    if S.Stormstrike:IsCastableP() and (Player:BuffP(S.StormbringerBuff) or (active_enemies() > 1 and Player:BuffP(S.GatheringStormsBuff) and bool(VarFurycheckSs))) then
      return S.Stormstrike:Cast()
    end
    -- crash_lightning,if=active_enemies>=3&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and active_enemies() >= 3 and bool(VarFurycheckCl) then
      return S.CrashLightning:Cast()
    end
    -- lightning_bolt,if=talent.overcharge.enabled&active_enemies=1&variable.furyCheck_LB&maelstrom>=40
    if S.LightningBolt:IsCastableP() and (S.Overcharge:IsAvailable() and active_enemies() == 1 and bool(VarFurycheckLb) and Player:Maelstrom() >= 40) then
      return S.LightningBolt:Cast()
    end
    -- stormstrike,if=variable.OCPool_SS&variable.furyCheck_SS
    if S.Stormstrike:IsCastableP() and (bool(VarOcpoolSs) and bool(VarFurycheckSs)) then
      return S.Stormstrike:Cast()
    end
  end
 
 Filler = function()
    -- sundering
    if S.Sundering:IsCastableP() then
      return S.Sundering:Cast()
    end
	-- actions.filler+=/focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      return S.FocusedAzeriteBeam:Cast()
    end

    -- actions.filler+=/purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      return S.PurifyingBlast:Cast()
    end

    -- actions.filler+=/concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
      return S.ConcentratedFlame:Cast()
    end

    -- actions.filler+=/worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
      return S.WorldveinResonance:Cast()
    end
    -- crash_lightning,if=talent.forceful_winds.enabled&active_enemies>1&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and S.ForcefulWinds:IsAvailable() and active_enemies() > 1 and bool(VarFurycheckCl) then
      return S.CrashLightning:Cast()
    end
    -- flametongue,if=talent.searing_assault.enabled
    if S.Flametongue:IsCastableP() and (S.SearingAssault:IsAvailable()) then
      return S.Flametongue:Cast()
    end
    -- lava_lash,if=!azerite.primal_primer.enabled&talent.hot_hand.enabled&buff.hot_hand.react
    if S.LavaLash:IsCastableP() and (not S.PrimalPrimer:AzeriteEnabled() and S.HotHand:IsAvailable() and bool(Player:BuffStackP(S.HotHandBuff))) then
      return S.LavaLash:Cast()
    end
    -- crash_lightning,if=active_enemies>1&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and active_enemies() > 1 and bool(VarFurycheckCl) then
      return S.CrashLightning:Cast()
    end
    -- rockbiter,if=maelstrom<70&!buff.strength_of_earth.up
    if S.Rockbiter:IsCastableP() and (Player:Maelstrom() < 70 and not Player:BuffP(S.StrengthofEarthBuff)) then
      return S.Rockbiter:Cast()
    end
    -- crash_lightning,if=talent.crashing_storm.enabled&variable.OCPool_CL
    if S.CrashLightning:IsCastableP() and active_enemies() > 1 and S.CrashingStorm:IsAvailable() and bool(VarOcpoolCl) then
      return S.CrashLightning:Cast()
    end
    -- lava_lash,if=variable.OCPool_LL&variable.furyCheck_LL
    if S.LavaLash:IsCastableP() and (bool(VarOcpoolLl) and bool(VarFurycheckLl)) then
      return S.LavaLash:Cast()
    end
    -- rockbiter
    if S.Rockbiter:IsCastableP() then
      return S.Rockbiter:Cast()
    end
    -- frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8+gcd&variable.furyCheck_FB
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and Player:BuffRemainsP(S.FrostbrandBuff) < 4.8 + Player:GCD() and bool(VarFurycheckFb)) then
      return S.Frostbrand:Cast()
    end
    -- flametongue
    if S.Flametongue:IsCastableP() then
      return S.Flametongue:Cast()
    end
  end
 
 FreezerburnCore = function()
    -- lava_lash,target_if=max:debuff.primal_primer.stack,if=azerite.primal_primer.rank>=2&debuff.primal_primer.stack=10&variable.furyCheck_LL&variable.CLPool_LL
    if S.LavaLash:IsCastableP() and TargetUnit:DebuffStackP(S.PrimalPrimerDebuff) then
      return S.LavaLash:Cast()
    end
    -- earthen_spike,if=variable.furyCheck_ES
    if S.EarthenSpike:IsCastableP() and (bool(VarFurycheckEs)) then
      return S.EarthenSpike:Cast()
    end
    -- stormstrike,cycle_targets=1,if=active_enemies>1&azerite.lightning_conduit.enabled&!debuff.lightning_conduit.up&variable.furyCheck_SS
    if S.Stormstrike:IsCastableP() and active_enemies() > 1 and S.LightningConduit:AzeriteEnabled() and not TargetUnit:DebuffP(S.LightningConduitDebuff) and bool(VarFurycheckSs) then
      return S.Stormstrike:Cast()
    end
    -- stormstrike,if=buff.stormbringer.up|(active_enemies>1&buff.gathering_storms.up&variable.furyCheck_SS)
    if S.Stormstrike:IsCastableP() and (Player:BuffP(S.StormbringerBuff) or (Cache.EnemiesCount[8] > 1 and Player:BuffP(S.GatheringStormsBuff) and bool(VarFurycheckSs))) then
      return S.Stormstrike:Cast()
    end
    -- crash_lightning,if=active_enemies>=3&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and active_enemies() > 1 and bool(VarFurycheckCl) then
      return S.CrashLightning:Cast()
    end
    -- lightning_bolt,if=talent.overcharge.enabled&active_enemies=1&variable.furyCheck_LB&maelstrom>=40
    if S.LightningBolt:IsCastableP() and (S.Overcharge:IsAvailable() and active_enemies() == 1 and bool(VarFurycheckLb) and Player:Maelstrom() >= 40) then
      return S.LightningBolt:Cast()
    end
    -- lava_lash,if=azerite.primal_primer.rank>=2&debuff.primal_primer.stack>7&variable.furyCheck_LL&variable.CLPool_LL
    if S.LavaLash:IsCastableP() and (S.PrimalPrimer:AzeriteRank() >= 2 and Target:DebuffStackP(S.PrimalPrimerDebuff) > 7 and bool(VarFurycheckLl) and bool(VarClpoolLl)) then
      return S.LavaLash:Cast()
    end
    -- stormstrike,if=variable.OCPool_SS&variable.furyCheck_SS&variable.CLPool_SS
    if S.Stormstrike:IsCastableP() and (bool(VarOcpoolSs) and bool(VarFurycheckSs) and bool(VarClpoolSs)) then
      return S.Stormstrike:Cast()
    end
    -- lava_lash,if=debuff.primal_primer.stack=10&variable.furyCheck_LL
    if S.LavaLash:IsCastableP() and (Target:DebuffStackP(S.PrimalPrimerDebuff) == 10 and bool(VarFurycheckLl)) then
      return S.LavaLash:Cast()
    end
  end
 
 Maintenance = function()
    -- flametongue,if=!buff.flametongue.up
    if S.Flametongue:IsCastableP() and (not Player:BuffP(S.FlametongueBuff)) then
      return S.Flametongue:Cast()
    end
    -- frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck_FB
    if S.Frostbrand:IsCastableP() and (S.Hailstorm:IsAvailable() and not Player:BuffP(S.FrostbrandBuff) and bool(VarFurycheckFb)) then
      return S.Frostbrand:Cast()
    end
  end
 
 Opener = function()
    -- rockbiter,if=maelstrom<15&time<gcd
    if S.Rockbiter:IsCastableP() and (Player:Maelstrom() < 15 and HL.CombatTime() < Player:GCD()) then
      return S.Rockbiter:Cast()
    end
  end
  
  Priority = function()
    -- crash_lightning,if=active_enemies>=(8-(talent.forceful_winds.enabled*3))&variable.freezerburn_enabled&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and active_enemies() >= (8 - (num(S.ForcefulWinds:IsAvailable()) * 3)) and bool(VarFreezerburnEnabled) and bool(VarFurycheckCl) then
      return S.CrashLightning:Cast()
    end
	-- actions.priority+=/the_unbound_force,if=buff.reckless_force.up|time<5
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForce) or HL.CombatTime() < 5) then
      return S.TheUnboundForce:Cast()
    end
    -- lava_lash,if=azerite.primal_primer.rank>=2&debuff.primal_primer.stack=10&active_enemies=1&variable.freezerburn_enabled&variable.furyCheck_LL
    if S.LavaLash:IsCastableP() and (S.PrimalPrimer:AzeriteRank() >= 2 and Target:DebuffStackP(S.PrimalPrimerDebuff) == 10 and active_enemies() == 1 and bool(VarFreezerburnEnabled) and bool(VarFurycheckLl)) then
      return S.LavaLash:Cast()
    end
    -- crash_lightning,if=!buff.crash_lightning.up&active_enemies>1&variable.furyCheck_CL
    if S.CrashLightning:IsCastableP() and not Player:BuffP(S.CrashLightningBuff) and active_enemies() > 1 and bool(VarFurycheckCl) then
      return S.CrashLightning:Cast()
    end
    -- fury_of_air,if=!buff.fury_of_air.up&maelstrom>=20&spell_targets.fury_of_air_damage>=(1+variable.freezerburn_enabled)
    if S.FuryofAir:IsCastableP() and (not Player:BuffP(S.FuryofAirBuff) and Player:Maelstrom() >= 20 and Cache.EnemiesCount[5] >= (1 + VarFreezerburnEnabled)) then
      return S.FuryofAir:Cast()
    end
    -- fury_of_air,if=buff.fury_of_air.up&&spell_targets.fury_of_air_damage<(1+variable.freezerburn_enabled)
    if S.FuryofAir:IsCastableP() and (Player:BuffP(S.FuryofAirBuff) and true and Cache.EnemiesCount[5] < (1 + VarFreezerburnEnabled)) then
      return S.FuryofAir:Cast()
    end
    if S.TotemMastery:IsCastableP() and TotemMastery() < 2 then
      return S.TotemMastery:Cast()
    end
    -- sundering,if=active_enemies>=3
    if S.Sundering:IsCastableP() and (active_enemies() >= 3) then
      return S.Sundering:Cast()
    end
	 -- actions.priority+=/focused_azerite_beam,if=active_enemies>=3
    if S.FocusedAzeriteBeam:IsCastableP() and (Cache.EnemiesCount[10] >= 3) then
      return S.FocusedAzeriteBeam:Cast()
    end
    -- actions.priority+=/purifying_blast,if=active_enemies>=3
    if S.PurifyingBlast:IsCastableP() and (Cache.EnemiesCount[10] >= 3) then
      return S.PurifyingBlast:Cast()
    end
    -- rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
    if S.Rockbiter:IsCastableP() and (S.Landslide:IsAvailable() and not Player:BuffP(S.LandslideBuff) and S.Rockbiter:ChargesFractionalP() > 1.7) then
      return S.Rockbiter:Cast()
    end
    -- frostbrand,if=(azerite.natural_harmony.enabled&buff.natural_harmony_frost.remains<=2*gcd)&talent.hailstorm.enabled&variable.furyCheck_FB
    if S.Frostbrand:IsCastableP() and ((S.NaturalHarmony:AzeriteEnabled() and Player:BuffRemainsP(S.NaturalHarmonyFrostBuff) <= 2 * Player:GCD()) and S.Hailstorm:IsAvailable() and bool(VarFurycheckFb)) then
      return S.Frostbrand:Cast()
    end
    -- flametongue,if=(azerite.natural_harmony.enabled&buff.natural_harmony_fire.remains<=2*gcd)
    if S.Flametongue:IsCastableP() and ((S.NaturalHarmony:AzeriteEnabled() and Player:BuffRemainsP(S.NaturalHarmonyFireBuff) <= 2 * Player:GCD())) then
      return S.Flametongue:Cast()
    end
    -- rockbiter,if=(azerite.natural_harmony.enabled&buff.natural_harmony_nature.remains<=2*gcd)&maelstrom<70
    if S.Rockbiter:IsCastableP() and ((S.NaturalHarmony:AzeriteEnabled() and Player:BuffRemainsP(S.NaturalHarmonyNatureBuff) <= 2 * Player:GCD()) and Player:Maelstrom() < 70) then
      return S.Rockbiter:Cast()
    end
  end
  
  -- call precombat
  if not Player:AffectingCombat() and RubimRH.PrecombatON() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
 -- combat
 if RubimRH.TargetIsValid() then
 	-- Anti channeling interrupt
	if Player:IsChanneling() or Player:IsCasting() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end	
    if QueueSkill() ~= nil then
        return QueueSkill()
    end
    -- wind_shear
    if S.WindShear:IsCastableP() and Target:IsInterruptible() and RubimRH.InterruptsON() then
      return S.WindShear:Cast()
    end
    -- variable,name=cooldown_sync,value=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
    if (true) then
      VarCooldownSync = num((S.Ascendance:IsAvailable() and (Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50)) or (not S.Ascendance:IsAvailable() and (PetDuration("Spirit Wolf") > 5 or S.FeralSpirit:CooldownRemainsP() > 50)))
    end
    -- variable,name=furyCheck_SS,value=maelstrom>=(talent.fury_of_air.enabled*(6+action.stormstrike.cost))
    if (true) then
      VarFurycheckSs = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + S.Stormstrike:Cost())))
    end
    -- variable,name=furyCheck_LL,value=maelstrom>=(talent.fury_of_air.enabled*(6+action.lava_lash.cost))
    if (true) then
      VarFurycheckLl = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + S.LavaLash:Cost())))
    end
    -- variable,name=furyCheck_CL,value=maelstrom>=(talent.fury_of_air.enabled*(6+action.crash_lightning.cost))
    if (true) then
      VarFurycheckCl = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + S.CrashLightning:Cost())))
    end
    -- variable,name=furyCheck_FB,value=maelstrom>=(talent.fury_of_air.enabled*(6+action.frostbrand.cost))
    if (true) then
      VarFurycheckFb = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + S.Frostbrand:Cost())))
    end
    -- variable,name=furyCheck_ES,value=maelstrom>=(talent.fury_of_air.enabled*(6+action.earthen_spike.cost))
    if (true) then
      VarFurycheckEs = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + S.EarthenSpike:Cost())))
    end
    -- variable,name=furyCheck_LB,value=maelstrom>=(talent.fury_of_air.enabled*(6+40))
    if (true) then
      VarFurycheckLb = num(Player:Maelstrom() >= (num(S.FuryofAir:IsAvailable()) * (6 + 40)))
    end
    -- variable,name=OCPool,value=(active_enemies>1|(cooldown.lightning_bolt.remains>=2*gcd))
    if (true) then
      VarOcpool = num((Cache.EnemiesCount[8] > 1 or (S.LightningBolt:CooldownRemainsP() >= 2 * Player:GCD())))
    end
    -- variable,name=OCPool_SS,value=(variable.OCPool|maelstrom>=(talent.overcharge.enabled*(40+action.stormstrike.cost)))
    if (true) then
      VarOcpoolSs = num((bool(VarOcpool) or Player:Maelstrom() >= (num(S.Overcharge:IsAvailable()) * (40 + S.Stormstrike:Cost()))))
    end
    -- variable,name=OCPool_LL,value=(variable.OCPool|maelstrom>=(talent.overcharge.enabled*(40+action.lava_lash.cost)))
    if (true) then
      VarOcpoolLl = num((bool(VarOcpool) or Player:Maelstrom() >= (num(S.Overcharge:IsAvailable()) * (40 + S.LavaLash:Cost()))))
    end
    -- variable,name=OCPool_CL,value=(variable.OCPool|maelstrom>=(talent.overcharge.enabled*(40+action.crash_lightning.cost)))
    if (true) then
      VarOcpoolCl = num((bool(VarOcpool) or Player:Maelstrom() >= (num(S.Overcharge:IsAvailable()) * (40 + S.CrashLightning:Cost()))))
    end
    -- variable,name=OCPool_FB,value=(variable.OCPool|maelstrom>=(talent.overcharge.enabled*(40+action.frostbrand.cost)))
    if (true) then
      VarOcpoolFb = num((bool(VarOcpool) or Player:Maelstrom() >= (num(S.Overcharge:IsAvailable()) * (40 + S.Frostbrand:Cost()))))
    end
    -- variable,name=CLPool_LL,value=active_enemies=1|maelstrom>=(action.crash_lightning.cost+action.lava_lash.cost)
    if (true) then
      VarClpoolLl = num(Cache.EnemiesCount[8] == 1 or Player:Maelstrom() >= (S.CrashLightning:Cost() + S.LavaLash:Cost()))
    end
    -- variable,name=CLPool_SS,value=active_enemies=1|maelstrom>=(action.crash_lightning.cost+action.stormstrike.cost)
    if (true) then
      VarClpoolSs = num(Cache.EnemiesCount[8] == 1 or Player:Maelstrom() >= (S.CrashLightning:Cost() + S.Stormstrike:Cost()))
    end
    -- variable,name=freezerburn_enabled,value=(talent.hot_hand.enabled&talent.hailstorm.enabled&azerite.primal_primer.enabled)
    if (true) then
      VarFreezerburnEnabled = num((S.HotHand:IsAvailable() and S.Hailstorm:IsAvailable() and S.PrimalPrimer:AzeriteEnabled()))
    end
    -- variable,name=rockslide_enabled,value=(!variable.freezerburn_enabled&(talent.boulderfist.enabled&talent.landslide.enabled&azerite.strength_of_earth.enabled))
    if (true) then
      VarRockslideEnabled = num((not bool(VarFreezerburnEnabled) and (S.Boulderfist:IsAvailable() and S.Landslide:IsAvailable() and S.StrengthofEarth:AzeriteEnabled())))
    end
    -- auto_attack
    -- use_items
    -- call_action_list,name=opener
    if (true) then
      local ShouldReturn = Opener(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=asc,if=buff.ascendance.up
    if (Player:BuffP(S.AscendanceBuff)) then
      local ShouldReturn = Asc(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=priority
    if (true) then
      local ShouldReturn = Priority(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=maintenance,if=active_enemies<3
    if (active_enemies() < 3) then
      local ShouldReturn = Maintenance(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=freezerburn_core,if=variable.freezerburn_enabled
    if (bool(VarFreezerburnEnabled)) then
      local ShouldReturn = FreezerburnCore(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=default_core,if=!variable.freezerburn_enabled
    if (not bool(VarFreezerburnEnabled)) then
      local ShouldReturn = DefaultCore(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=maintenance,if=active_enemies>=3
    if (active_enemies() >= 3) then
      local ShouldReturn = Maintenance(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=filler
    if (true) then
      local ShouldReturn = Filler(); if ShouldReturn then return ShouldReturn; end
    end
  return 0, 135328
end
end 

RubimRH.Rotation.SetAPL(263, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(263, PASSIVE);
