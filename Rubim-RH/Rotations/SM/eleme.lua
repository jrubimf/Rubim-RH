--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL     = HeroLib;
local Cache  = HeroCache;
local Unit   = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Pet    = Unit.Pet;
local Spell  = HL.Spell;
local Item   = HL.Item;
local MouseOver = Unit.MouseOver;

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[262] = {
  TotemMastery                          = Spell(210643),
  StormkeeperBuff                       = Spell(191634),
  Stormkeeper                           = Spell(191634),
  FireElemental                         = Spell(198067),
  StormElemental                        = Spell(192249),
  ElementalBlast                        = Spell(117014),
  LavaBurst                             = Spell(51505),
  ChainLightning                        = Spell(188443),
  FlameShock                            = Spell(188389),
  FlameShockDebuff                      = Spell(188389),
  WindGustBuff                          = Spell(263806),
  Ascendance                            = Spell(114050),
  Icefury                               = Spell(210714),
  IcefuryBuff                           = Spell(210714),
  LiquidMagmaTotem                      = Spell(192222),
  Earthquake                            = Spell(61882),
  MasteroftheElements                   = Spell(16166),
  MasteroftheElementsBuff               = Spell(260734),
  LavaSurgeBuff                         = Spell(77762),
  AscendanceBuff                        = Spell(114050),
  FrostShock                            = Spell(196840),
  LavaBeam                              = Spell(114074),
  SurgeofPowerBuff                      = Spell(285514),
  NaturalHarmony                        = Spell(278697),
  SurgeofPower                          = Spell(262303),
  LightningBolt                         = Spell(188196),
  EarthShock                            = Spell(8042),
  CalltheThunder                        = Spell(260897),
  EchooftheElementals                   = Spell(275381),
  ResonanceTotemBuff                    = Spell(202192),
  WindShear                             = Spell(57994),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Purge									= Spell(370),
  CleanseSpirit							= Spell(51886),
  PrimalElementalist                    = Spell(117013),
  EyeOfTheStorm                         = Spell(157375), 
  CallLightning                         = Spell(157348),    
  AstralShift                           = Spell(108271),    
  
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
  
};
local S = RubimRH.Spell[262]

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Elemental = {
  BattlePotionOfIntellect          = Item(163222)
};
local I = Item.Shaman.Elemental;

-- Rotation Var
local ShouldReturn; -- Used to get the return string


local EnemyRanges = {40, 5}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function FutureMaelstromPower()
  local MaelstromPower = Player:Maelstrom()
  local overloadChance = Player:MasteryPct() / 100
  local factor = 1 + 0.75 * overloadChance
  local resonance = 0

  if Player:AffectingCombat() then
    if S.TotemMastery:IsCastableP() then
      resonance = Player:CastRemains()
    end
    if not Player:IsCasting() then
      return MaelstromPower
    else
      if Player:IsCasting(S.LightningBolt) then
        return MaelstromPower + 8 + resonance
      elseif Player:IsCasting(S.LavaBurst) then
        return MaelstromPower + 10 + resonance
      elseif Player:IsCasting(S.ChainLightning) then
        local enemiesHit = min(Cache.EnemiesCount[40], 3)
        return MaelstromPower + 4 * enemiesHit * factor + resonance
      elseif Player:IsCasting(S.Icefury) then
        return MaelstromPower + 25 * factor + resonance
      else
        return MaelstromPower
      end
    end
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
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

-- Pet functions
local PetType = {
  [77942] = {"Primal Storm Elemental", 30},
};

HL.ElementalGuardiansTable = {
    --{PetType,petID,dateEvent,UnitPetGUID,CastsLeft}
    Pets = {
    },
    PetList={
    [77942]="Primal Storm Elemental",
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
    
	local PetType=HL.ElementalGuardiansTable.PetList[tonumber(t[6])]
    if PetType then
        table.insert(HL.ElementalGuardiansTable.Pets,{PetType,tonumber(t[6]),GetTime(),UnitPetGUID,5})
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
        [77942] = {"Primal Storm Elemental", 30},
    }
    local maxduration = 0
    for key, Value in pairs(HL.ElementalGuardiansTable.Pets) do
        if HL.ElementalGuardiansTable.Pets[key][1] == PetType then
            if (PetsInfo[HL.ElementalGuardiansTable.Pets[key][2]][2] - (GetTime() - HL.ElementalGuardiansTable.Pets[key][3])) > maxduration then
                maxduration = HL.OffsetRemains((PetsInfo[HL.ElementalGuardiansTable.Pets[key][2]][2] - (GetTime() - HL.ElementalGuardiansTable.Pets[key][3])), "Auto" );
            end
        end
    end
    return maxduration
end

local function StormElementalIsActive()
    if PetDuration("Primal Storm Elemental") > 1 then
        return true
   else
        return false
    end
end

--136024 - Earth
--135790 - Fire
function ElementalUp()
    for i = 1, 5 do
        local active, totemName, startTime, duration, textureId  = GetTotemInfo(i)
        if active == true and (textureId == 135790 or textureId == 136024 or textureId == 1020304) then
            return startTime + duration - GetTime()
        end
    end
    return 0
end

local function GetEnemiesCount()
  if RubimRH.AoEON() then
    if RubimRH.db.profile[262].useSplashData == "Enabled" then
      RubimRH.UpdateSplashCount(Target, 10)
      return RubimRH.GetSplashCount(Target, 10)
    else
      UpdateRanges()
      return Cache.EnemiesCount[40]
	  --return active_enemies()
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
  local Precombat_DBM, Precombat, Aoe, SingleTarget
  UpdateRanges()
  
   Precombat_DBM = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- totem_mastery
    if S.TotemMastery:IsCastableP() and not Player:PrevGCDP(1, S.TotemMastery) and TotemMastery() < 2 then
      return S.TotemMastery:Cast()
    end
    -- earth_elemental,if=!talent.primal_elementalist.enabled
    -- stormkeeper,if=talent.stormkeeper.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)
    if S.Stormkeeper:IsCastableP() and RubimRH.CDsON() and Player:BuffDownP(S.StormkeeperBuff) and S.Stormkeeper:IsAvailable() and RubimRH.DBM_PullTimer() >= 0.1 then
      return S.Stormkeeper:Cast()
    end
    -- potion
    if I.BattlePotionOfIntellect:IsReady() and RubimRH.DBM_PullTimer() > (S.LavaBurst:CastTime() + S.LavaBurst:TravelTime()) and RubimRH.DBM_PullTimer() <= (S.LavaBurst:CastTime() + S.LavaBurst:TravelTime() + 1) then
        return 967532
    end
    -- elemental_blast,if=talent.elemental_blast.enabled&Cache.EnemiesCount[40].chain_lightning<3
    if S.ElementalBlast:IsCastableP() and (S.ElementalBlast:IsAvailable() and GetEnemiesCount() < 3) and RubimRH.DBM_PullTimer() <= (S.ElementalBlast:CastTime() + S.ElementalBlast:TravelTime()) and RubimRH.DBM_PullTimer() >= 0.1 then
      return S.ElementalBlast:Cast()
    end
    -- lava_burst,if=!talent.elemental_blast.enabled&Cache.EnemiesCount[40].chain_lightning<3
    if S.LavaBurst:IsCastableP() and (not S.ElementalBlast:IsAvailable() and GetEnemiesCount() < 3) and RubimRH.DBM_PullTimer() <= (S.LavaBurst:CastTime() + S.LavaBurst:TravelTime()) and RubimRH.DBM_PullTimer() >= 0.1 then
      return S.LavaBurst:Cast()
    end
    -- chain_lightning,if=Cache.EnemiesCount[40].chain_lightning>2
    if S.ChainLightning:IsCastableP() and (GetEnemiesCount() > 2) then
      return S.ChainLightning:Cast()
    end
  end
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- totem_mastery
    if S.TotemMastery:IsCastableP() and not Player:PrevGCDP(1, S.TotemMastery) and TotemMastery() < 2 then
      return S.TotemMastery:Cast()
    end
    -- earth_elemental,if=!talent.primal_elementalist.enabled
    -- stormkeeper,if=talent.stormkeeper.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)
    if S.Stormkeeper:IsCastableP() and RubimRH.CDsON() and Player:BuffDownP(S.StormkeeperBuff) and S.Stormkeeper:IsAvailable() then
      return S.Stormkeeper:Cast()
    end
    -- fire_elemental,if=!talent.storm_elemental.enabled
    if S.FireElemental:IsCastableP() and RubimRH.CDsON() and (not S.StormElemental:IsAvailable()) then
      return S.FireElemental:Cast()
    end
    -- storm_elemental,if=talent.storm_elemental.enabled
    if S.StormElemental:IsCastableP() and RubimRH.CDsON() and (S.StormElemental:IsAvailable()) then
      return S.StormElemental:Cast()
    end
    -- potion
    -- elemental_blast,if=talent.elemental_blast.enabled&Cache.EnemiesCount[40].chain_lightning<3
    if S.ElementalBlast:IsCastableP() and (S.ElementalBlast:IsAvailable() and GetEnemiesCount() < 3) then
      return S.ElementalBlast:Cast()
    end
    -- lava_burst,if=!talent.elemental_blast.enabled&Cache.EnemiesCount[40].chain_lightning<3
    if S.LavaBurst:IsCastableP() and (not S.ElementalBlast:IsAvailable() and GetEnemiesCount() < 3) then
      return S.LavaBurst:Cast()
    end
    -- chain_lightning,if=Cache.EnemiesCount[40].chain_lightning>2
    if S.ChainLightning:IsCastableP() and (GetEnemiesCount() > 2) then
      return S.ChainLightning:Cast()
    end
  end
 
  Aoe = function()
    -- stormkeeper,if=talent.stormkeeper.enabled
    if S.Stormkeeper:IsCastableP() and (S.Stormkeeper:IsAvailable()) then
      return S.Stormkeeper:Cast()
    end
    -- flame_shock,target_if=refreshable&(Cache.EnemiesCount[40].chain_lightning<(5-!talent.totem_mastery.enabled)|!talent.storm_elemental.enabled&(cooldown.fire_elemental.remains>(120+14*spell_haste)|cooldown.fire_elemental.remains<(24-14*spell_haste)))&(!talent.storm_elemental.enabled|cooldown.storm_elemental.remains<120|Cache.EnemiesCount[40].chain_lightning=3&buff.wind_gust.stack<14)
    if S.FlameShock:IsCastableP() and Target:DebuffRefreshableCP(S.FlameShockDebuff) and (GetEnemiesCount() < (5 - num(not S.TotemMastery:IsAvailable())) or not S.StormElemental:IsAvailable() and (S.FireElemental:CooldownRemainsP() > (120 + 14 * Player:SpellHaste()) or S.FireElemental:CooldownRemainsP() < (24 - 14 * Player:SpellHaste()))) and (not S.StormElemental:IsAvailable() or S.StormElemental:CooldownRemainsP() < 120 or GetEnemiesCount() == 3 and Player:BuffStackP(S.WindGustBuff) < 14) then
        return S.FlameShock:Cast()
	end
    -- ascendance,if=talent.ascendance.enabled&(talent.storm_elemental.enabled&cooldown.storm_elemental.remains<120&cooldown.storm_elemental.remains>15|!talent.storm_elemental.enabled)&(!talent.icefury.enabled|!buff.icefury.up&!cooldown.icefury.up)
    if S.Ascendance:IsCastableP() and RubimRH.CDsON() and (S.Ascendance:IsAvailable() and (S.StormElemental:IsAvailable() and S.StormElemental:CooldownRemainsP() < 120 and S.StormElemental:CooldownRemainsP() > 15 or not S.StormElemental:IsAvailable()) and (not S.Icefury:IsAvailable() or not Player:BuffP(S.IcefuryBuff) and not S.Icefury:CooldownUpP())) then
      return S.Ascendance:Cast()
    end
    -- liquid_magma_totem,if=talent.liquid_magma_totem.enabled
    if S.LiquidMagmaTotem:IsCastableP() and S.LiquidMagmaTotem:IsAvailable() then
      return S.LiquidMagmaTotem:Cast()
    end
    -- earthquake,if=!talent.master_of_the_elements.enabled|buff.stormkeeper.up|maelstrom>=(100-4*Cache.EnemiesCount[40].chain_lightning)|buff.master_of_the_elements.up|Cache.EnemiesCount[40].chain_lightning>3
  if (not S.MasteroftheElements:IsAvailable() or Player:Buff(S.StormkeeperBuff) or FutureMaelstromPower() >= (100-4* min(GetEnemiesCount(), 3)) or Player:Buff(S.MasteroftheElementsBuff) or GetEnemiesCount() > 3) then
    if (FutureMaelstromPower() >= 60) then
      return S.Earthquake:Cast()
    end
  end
    -- chain_lightning,if=buff.stormkeeper.remains<3*gcd*buff.stormkeeper.stack
    if S.ChainLightning:IsCastableP() and (Player:BuffRemainsP(S.StormkeeperBuff) < 3 * Player:GCD() * Player:BuffStackP(S.StormkeeperBuff)) then
      return S.ChainLightning:Cast()
    end
    -- lava_burst,if=buff.lava_surge.up&Cache.EnemiesCount[40].chain_lightning<4&(!talent.storm_elemental.enabled|cooldown.storm_elemental.remains<120)&dot.flame_shock.ticking
    if S.LavaBurst:IsCastableP() and (Player:BuffP(S.LavaSurgeBuff) and GetEnemiesCount() < 4 and (not S.StormElemental:IsAvailable() or S.StormElemental:CooldownRemainsP() < 120) and Target:DebuffP(S.FlameShockDebuff)) then
      return S.LavaBurst:Cast()
    end
    -- icefury,if=Cache.EnemiesCount[40].chain_lightning<4&!buff.ascendance.up
    if S.Icefury:IsCastableP() and GetEnemiesCount() < 4 and not Player:BuffP(S.AscendanceBuff) then
      return S.Icefury:Cast()
    end
    -- frost_shock,if=Cache.EnemiesCount[40].chain_lightning<4&buff.icefury.up&!buff.ascendance.up
    if S.FrostShock:IsCastableP() and GetEnemiesCount() < 4 and Player:BuffP(S.IcefuryBuff) and not Player:BuffP(S.AscendanceBuff) then
      return S.FrostShock:Cast()
    end
    -- elemental_blast,if=talent.elemental_blast.enabled&Cache.EnemiesCount[40].chain_lightning<4&(!talent.storm_elemental.enabled|cooldown.storm_elemental.remains<120)
    if S.ElementalBlast:IsCastableP() and (S.ElementalBlast:IsAvailable() and GetEnemiesCount() < 4 and (not S.StormElemental:IsAvailable() or S.StormElemental:CooldownRemainsP() < 120)) then
      return S.ElementalBlast:Cast()
    end
    -- lava_beam,if=talent.ascendance.enabled
    if S.LavaBeam:IsCastableP() and (S.Ascendance:IsAvailable()) then
      return S.LavaBeam:Cast()
    end
    -- chain_lightning
    if S.ChainLightning:IsCastableP() then
      return S.ChainLightning:Cast()
    end
    -- lava_burst,moving=1,if=talent.ascendance.enabled
    if S.LavaBurst:IsCastableP() and Player:IsMoving() and (S.Ascendance:IsAvailable()) then
      return S.LavaBurst:Cast()
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and Player:IsMoving() and Target:DebuffRefreshableCP(S.FlameShockDebuff) then
      return S.FlameShock:Cast()
    end
    -- frost_shock,moving=1
    if S.FrostShock:IsCastableP() and Player:IsMoving() then
      return S.FrostShock:Cast()
    end
  end
  
  SingleTarget = function()
    -- flame_shock,if=(!ticking|talent.storm_elemental.enabled&cooldown.storm_elemental.remains<2*gcd|dot.flame_shock.remains<=gcd|talent.ascendance.enabled&dot.flame_shock.remains<(cooldown.ascendance.remains+buff.ascendance.duration)&cooldown.ascendance.remains<4&(!talent.storm_elemental.enabled|talent.storm_elemental.enabled&cooldown.storm_elemental.remains<120))&buff.wind_gust.stack<14&!buff.surge_of_power.up
    if S.FlameShock:IsCastableP() and ((not Target:DebuffP(S.FlameShockDebuff) or S.StormElemental:IsAvailable() and S.StormElemental:CooldownRemainsP() < 2 * Player:GCD() or Target:DebuffRemainsP(S.FlameShockDebuff) <= Player:GCD() or S.Ascendance:IsAvailable() and Target:DebuffRemainsP(S.FlameShockDebuff) < (S.Ascendance:CooldownRemainsP() + S.AscendanceBuff:BaseDuration()) and S.Ascendance:CooldownRemainsP() < 4 and (not S.StormElemental:IsAvailable() or S.StormElemental:IsAvailable() and S.StormElemental:CooldownRemainsP() < 120)) and Player:BuffStackP(S.WindGustBuff) < 14 and not Player:BuffP(S.SurgeofPowerBuff)) then
      return S.FlameShock:Cast()
    end
    -- flame_shock,moving=1,target_if=duration<6
    if S.FlameShock:IsCastableP() and Target:DebuffRemainsP(S.FlameShockDebuff) <= 6 then
      return S.FlameShock:Cast()
    end
    --actions.single_target+=/earth_shock
    if S.LavaBurst:CooldownRemains() >= 1 and FutureMaelstromPower() >= 60  then        
          return S.EarthShock:Cast()
    end
    -- ascendance,if=talent.ascendance.enabled&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&(!talent.storm_elemental.enabled|cooldown.storm_elemental.remains>120)&(!talent.icefury.enabled|!buff.icefury.up&!cooldown.icefury.up)
    if S.Ascendance:IsCastableP() and RubimRH.CDsON() and (S.Ascendance:IsAvailable() and (HL.CombatTime() >= 60 or Player:HasHeroism()) and S.LavaBurst:CooldownRemainsP() > 0 and (not S.StormElemental:IsAvailable() or S.StormElemental:CooldownRemainsP() > 120) and (not S.Icefury:IsAvailable() or not Player:BuffP(S.IcefuryBuff) and not S.Icefury:CooldownUpP())) then
      return S.Ascendance:Cast()
    end
    -- elemental_blast,if=talent.elemental_blast.enabled&(talent.master_of_the_elements.enabled&buff.master_of_the_elements.up&maelstrom<60|!talent.master_of_the_elements.enabled)&(!(cooldown.storm_elemental.remains>120&talent.storm_elemental.enabled)|azerite.natural_harmony.rank=3&buff.wind_gust.stack<14)
    if S.ElementalBlast:IsCastableP() and S.ElementalBlast:IsAvailable() and (S.MasteroftheElements:IsAvailable() and Player:BuffP(S.MasteroftheElementsBuff) and FutureMaelstromPower() < 60 or not S.MasteroftheElements:IsAvailable()) and (not (S.StormElemental:CooldownRemainsP() > 120 and S.StormElemental:IsAvailable()) or S.NaturalHarmony:AzeriteEnabled() and Player:BuffStackP(S.WindGustBuff) < 14) then
      return S.ElementalBlast:Cast()
    end
    -- stormkeeper,if=talent.stormkeeper.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)&(!talent.surge_of_power.enabled|buff.surge_of_power.up|maelstrom>=44)
    if S.Stormkeeper:IsCastableP() and (S.Stormkeeper:IsAvailable() and ((GetEnemiesCount() - 1) < 3) and (not S.SurgeofPower:IsAvailable() or Player:BuffP(S.SurgeofPowerBuff) or FutureMaelstromPower() >= 44)) then
      return S.Stormkeeper:Cast()
    end
    -- liquid_magma_totem,if=talent.liquid_magma_totem.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)
    if S.LiquidMagmaTotem:IsCastableP() and S.LiquidMagmaTotem:IsAvailable() and ((GetEnemiesCount() - 1) < 3) then
      return S.LiquidMagmaTotem:Cast()
    end
    -- lightning_bolt,if=buff.stormkeeper.up&Cache.EnemiesCount[40].chain_lightning<2&(buff.master_of_the_elements.up&!talent.surge_of_power.enabled|buff.surge_of_power.up)
    if S.LightningBolt:IsCastableP() and FutureMaelstromPower() <= 100 and (Player:BuffP(S.StormkeeperBuff) and GetEnemiesCount() < 2 and (Player:BuffP(S.MasteroftheElementsBuff) and not S.SurgeofPower:IsAvailable() or Player:BuffP(S.SurgeofPowerBuff))) then
      return S.LightningBolt:Cast()
    end
    --# There might come an update for this line with some SoP logic.
    --actions.single_target+=/earthquake,if=active_enemies>1&Cache.EnemiesCount[40].chain_lightning>1&(!talent.surge_of_power.enabled|!dot.flame_shock.refreshable|cooldown.storm_elemental.remains>120)&(!talent.master_of_the_elements.enabled|buff.master_of_the_elements.up|maelstrom>=92)
    if S.EarthShock:IsCastableP() and (GetEnemiesCount() >= 1 and (not S.SurgeofPower:IsAvailable() or S.StormElemental:CooldownRemains() > 120) and (not S.MasteroftheElements:IsAvailable() or Player:Buff(S.MasteroftheElementsBuff) or FutureMaelstromPower() >= 92)) then
        if FutureMaelstromPower() >= 60 then
            return S.EarthShock:Cast()
        end
    end
    --# Boy...what a condition. With Master of the Elements pool Maelstrom up to 8 Maelstrom below the cap to ensure it's used with Earth Shock. Without Master of the Elements, use Earth Shock either if Stormkeeper is up, Maelstrom is 10 Maelstrom below the cap or less, or either Storm Elemental isn't talented or it's not active and your last Storm Elemental of the fight will have only a partial duration.
    --actions.single_target+=/earth_shock,if=!buff.surge_of_power.up&talent.master_of_the_elements.enabled&(buff.master_of_the_elements.up|maelstrom>=92+30*talent.call_the_thunder.enabled|buff.stormkeeper.up&active_enemies<2)|!talent.master_of_the_elements.enabled&(buff.stormkeeper.up|maelstrom>=90+30*talent.call_the_thunder.enabled|!(cooldown.storm_elemental.remains>120&talent.storm_elemental.enabled)&expected_combat_length-time-cooldown.storm_elemental.remains-150*floor((expected_combat_length-time-cooldown.storm_elemental.remains)%150)>=30*(1+(azerite.echo_of_the_elementals.rank>=2)))
   -- if S.EarthShock:IsCastableP() and not Player:Buff(S.SurgeofPowerBuff) and S.MasteroftheElements:IsAvailable() and (Player:Buff(S.MasteroftheElementsBuff) or (FutureMaelstromPower() >= 122 and S.CallTheThunder:IsAvailable()) or Player:Buff(S.StormkeeperBuff) and Cache.EnemiesCount[40] < 2) or not S.MasteroftheElements:IsAvailable() and (Player:Buff(S.StormkeeperBuff) or (FutureMaelstromPower() >= 120 and S.CallTheThunder:IsAvailable()) or not (S.StormElemental:CooldownRemains() >120 and S.StormElemental:IsAvailable())) then
   --     if FutureMaelstromPower() >= 60 then
   --         return S.EarthShock:Cast()
   --     end
   -- end
    --# Use Earth Shock if Surge of Power is talented, but neither it nor a DPS Elemental is active at the moment, and Lava Burst is ready or will be within the next GCD.
    --actions.single_target+=/earth_shock,if=talent.surge_of_power.enabled&!buff.surge_of_power.up&cooldown.lava_burst.remains<=gcd&(!talent.storm_elemental.enabled&!(cooldown.fire_elemental.remains>120)|talent.storm_elemental.enabled&!(cooldown.storm_elemental.remains>120))
    if S.SurgeofPower:IsAvailable() and not Player:Buff(S.SurgeofPowerBuff) and S.LavaBurst:CooldownRemains() <= Player:GCD() and (not S.StormElemental:IsAvailable() and not (S.FireElemental:CooldownRemains() > 120) or S.StormElemental:IsAvailable() and not (S.StormElemental:CooldownRemains() >120)) then
        if (FutureMaelstromPower() >=60) then
          return S.EarthShock:Cast()
        end
    end
    -- lightning_bolt,if=cooldown.storm_elemental.remains>120&talent.storm_elemental.enabled
    if S.LightningBolt:IsCastableP() and FutureMaelstromPower() <= 100 and (S.StormElemental:CooldownRemainsP() > 120 and S.StormElemental:IsAvailable()) then
      return S.LightningBolt:Cast()
    end
    -- frost_shock,if=talent.icefury.enabled&talent.master_of_the_elements.enabled&buff.icefury.up&buff.master_of_the_elements.up
    if S.FrostShock:IsCastableP() and S.Icefury:IsAvailable() and S.MasteroftheElements:IsAvailable() and Player:BuffP(S.IcefuryBuff) and Player:BuffP(S.MasteroftheElementsBuff) then
      return S.FrostShock:Cast()
    end
    -- lava_burst,if=buff.ascendance.up
    if S.LavaBurst:IsCastableP() and (Player:BuffP(S.AscendanceBuff)) then
      return S.LavaBurst:Cast()
    end
    -- flame_shock,target_if=refreshable&active_enemies>1&buff.surge_of_power.up
    if S.FlameShock:IsCastableP() and Target:DebuffRefreshableCP(S.FlameShockDebuff) and GetEnemiesCount() > 1 and Player:BuffP(S.SurgeofPowerBuff) then
      return S.FlameShock:Cast()
    end
    -- lava_burst,if=talent.storm_elemental.enabled&cooldown_react&buff.surge_of_power.up&(expected_combat_length-time-cooldown.storm_elemental.remains-150*floor((expected_combat_length-time-cooldown.storm_elemental.remains)%150)<30*(1+(azerite.echo_of_the_elementals.rank>=2))|(1.16*(expected_combat_length-time)-cooldown.storm_elemental.remains-150*floor((1.16*(expected_combat_length-time)-cooldown.storm_elemental.remains)%150))<(expected_combat_length-time-cooldown.storm_elemental.remains-150*floor((expected_combat_length-time-cooldown.storm_elemental.remains)%150)))
    if S.LavaBurst:IsCastableP() and S.StormElemental:IsAvailable() and S.LavaBurst:CooldownUpP() and Player:BuffP(S.SurgeofPowerBuff) then
      return S.LavaBurst:Cast()
    end
    -- lava_burst,if=!talent.storm_elemental.enabled&cooldown_react&buff.surge_of_power.up&(expected_combat_length-time-cooldown.fire_elemental.remains-150*floor((expected_combat_length-time-cooldown.fire_elemental.remains)%150)<30*(1+(azerite.echo_of_the_elementals.rank>=2))|(1.16*(expected_combat_length-time)-cooldown.fire_elemental.remains-150*floor((1.16*(expected_combat_length-time)-cooldown.fire_elemental.remains)%150))<(expected_combat_length-time-cooldown.fire_elemental.remains-150*floor((expected_combat_length-time-cooldown.fire_elemental.remains)%150)))
    if S.LavaBurst:IsCastableP() and not S.StormElemental:IsAvailable() and S.LavaBurst:CooldownUpP() and Player:BuffP(S.SurgeofPowerBuff) then
      return S.LavaBurst:Cast()
    end
    -- lightning_bolt,if=buff.surge_of_power.up
    if S.LightningBolt:IsCastableP() and FutureMaelstromPower() <= 100 and (Player:BuffP(S.SurgeofPowerBuff)) then
      return S.LightningBolt:Cast()
    end
    -- lava_burst,if=cooldown_react
    if S.LavaBurst:IsCastableP() and (S.LavaBurst:CooldownUpP()) then
      return S.LavaBurst:Cast()
    end
    -- flame_shock,target_if=refreshable&!buff.surge_of_power.up
    if S.FlameShock:IsCastableP() and Target:DebuffRefreshableCP(S.FlameShockDebuff) and not Player:BuffP(S.SurgeofPowerBuff) then
      return S.FlameShock:Cast()
    end
    -- totem_mastery,if=talent.totem_mastery.enabled&(buff.resonance_totem.remains<6|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15))
    if S.TotemMastery:IsCastableP() and not Player:PrevGCDP(1, S.TotemMastery) and S.TotemMastery:IsAvailable() and (TotemMastery() < 6 or TotemMastery() < (S.AscendanceBuff:BaseDuration() + S.Ascendance:CooldownRemainsP()) and S.Ascendance:CooldownRemainsP() < 15) then
      return S.TotemMastery:Cast()
    end
    -- frost_shock,if=talent.icefury.enabled&buff.icefury.up&(buff.icefury.remains<gcd*4*buff.icefury.stack|buff.stormkeeper.up|!talent.master_of_the_elements.enabled)
    if S.FrostShock:IsCastableP() and S.Icefury:IsAvailable() and Player:BuffP(S.IcefuryBuff) and (Player:BuffRemainsP(S.IcefuryBuff) < Player:GCD() * 4 * Player:BuffStackP(S.IcefuryBuff) or Player:BuffP(S.StormkeeperBuff) or not S.MasteroftheElements:IsAvailable()) then
      return S.FrostShock:Cast()
    end
    -- icefury,if=talent.icefury.enabled
    if S.Icefury:IsCastableP() and S.Icefury:IsAvailable() then
      return S.Icefury:Cast()
    end
    -- lightning_bolt
    if S.LightningBolt:IsCastableP() and FutureMaelstromPower() <= 60 then
      return S.LightningBolt:Cast()
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and Player:IsMoving() and Target:DebuffRefreshableCP(S.FlameShockDebuff) then
      return S.FlameShock:Cast()
    end
    -- flame_shock,moving=1,if=movement.distance>6
    if S.FlameShock:IsCastableP() and Player:IsMoving() then
      return S.FlameShock:Cast()
    end
    -- frost_shock,moving=1
    if S.FrostShock:IsCastableP() and Player:IsMoving() then
      return S.FrostShock:Cast()
    end
  end
    
	-- call precombat_dbm
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and RubimRH.PerfectPullON() and not Player:IsCasting() then
        local ShouldReturn = Precombat_DBM(); if ShouldReturn then return ShouldReturn; end
    end 
    -- call precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and not RubimRH.PerfectPullON() and not Player:IsCasting() then
        local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
    end  

  --  if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) then
  --      return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
  --  end
  
  -- combat start
  if RubimRH.TargetIsValid() then
  
    if QueueSkill() ~= nil then
        return QueueSkill()
    end
	
-- call_action_list,name=essences
    local ShouldReturn = Essences(); 
	if ShouldReturn and (true) then 
	    return ShouldReturn; 
	end
    -- bloodlust,if=azerite.ancestral_resonance.enabled
    -- potion,if=expected_combat_length-time<30|cooldown.fire_elemental.remains>120|cooldown.storm_elemental.remains>120
    -- wind_shear
    if S.WindShear:IsCastableP() and Target:IsInterruptible() and RubimRH.InterruptsON() then
      return S.WindShear:Cast()
    end
	-- purge (offensive dispell)
    if S.Purge:IsCastableP() and Target:HasStealableBuff() then
      return S.Purge:Cast()
    end
	-- Astral Shift
    if S.AstralShift:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[262].sk2 then
        return S.AstralShift:Cast()
    end
	-- defensive dispell
	--if MouseOver:HasDispelableDebuff("Curse") then
    --    return S.CleanseSpirit:Cast()
    --end
    -- totem_mastery,if=talent.totem_mastery.enabled&buff.resonance_totem.remains<2
    if S.TotemMastery:IsCastableP() and not Player:PrevGCDP(1, S.TotemMastery) and (S.TotemMastery:IsAvailable() and TotemMastery() < 2) then
      return S.TotemMastery:Cast()
    end
    -- fire_elemental,if=!talent.storm_elemental.enabled
    if S.FireElemental:IsCastableP() and RubimRH.CDsON() and (not S.StormElemental:IsAvailable()) then
      return S.FireElemental:Cast()
    end
    -- storm_elemental,if=talent.storm_elemental.enabled&(!talent.icefury.enabled|!buff.icefury.up&!cooldown.icefury.up)
    if S.StormElemental:IsCastableP() and RubimRH.CDsON() and (S.StormElemental:IsAvailable() and (not S.Icefury:IsAvailable() or not Player:BuffP(S.IcefuryBuff) and not S.Icefury:CooldownUpP())) then
      return S.StormElemental:Cast()
    end
	-- Eye of the Storm if Storm Elemental is up and we got Primal Elementalists
	if S.EyeOfTheStorm:CooldownRemainsP() < 0.1 and S.PrimalElementalist:IsAvailable() and RubimRH.CDsON() and StormElementalIsActive() and S.CallLightning:CooldownRemainsP() > 1 then
        return S.EyeOfTheStorm:Cast()
    end
    -- earth_elemental,if=!talent.primal_elementalist.enabled|talent.primal_elementalist.enabled&(cooldown.fire_elemental.remains<120&!talent.storm_elemental.enabled|cooldown.storm_elemental.remains<120&talent.storm_elemental.enabled)
    -- use_items
    -- blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
      return S.BloodFury:Cast()
    end
    -- berserking,if=!talent.ascendance.enabled|buff.ascendance.up
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff)) then
      return S.Berserking:Cast()
    end
    -- fireblood,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
      return S.Fireblood:Cast()
    end
    -- ancestral_call,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
      return S.AncestralCall:Cast()
    end
    -- run_action_list,name=aoe,if=active_enemies>2&(Cache.EnemiesCount[40].chain_lightning>2|Cache.EnemiesCount[40].lava_beam>2)
    if (GetEnemiesCount() > 1) and RubimRH.AoEON() then
      return Aoe();
    end
    -- run_action_list,name=single_target
    if (GetEnemiesCount() < 2) or not RubimRH.AoEON() then
      return SingleTarget();
    end
  return 0, 135328
end
end
RubimRH.Rotation.SetAPL(262, APL);

local function PASSIVE()
   -- print(GetEnemiesCount());
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(262, PASSIVE);
