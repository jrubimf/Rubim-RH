--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
local mainAddon = RubimRH
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
local MouseOver = Unit.MouseOver;
--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999
-- Spells
RubimRH.Spell[267] = {  
  SummonPet                             = Spell(688),
  GrimoireofSacrifice                   = Spell(108503),
  SoulFire                              = Spell(6353),
  Incinerate                            = Spell(29722),
  RainofFire                            = Spell(5740),
  CrashingChaosBuff                     = Spell(277706),
  GrimoireofSupremacy                   = Spell(266086),
  Havoc                                 = Spell(80240),
  RainofFireDebuff                      = Spell(5740),
  ChannelDemonfire                      = Spell(196447),
  ImmolateDebuff                        = Spell(157736),
  Immolate                              = Spell(348),
  Cataclysm                             = Spell(152108),
  HavocDebuff                           = Spell(80240),
  ChaosBolt                             = Spell(116858),
  Inferno                               = Spell(270545),
  FireandBrimstone                      = Spell(196408),
  BackdraftBuff                         = Spell(117828),
  Conflagrate                           = Spell(17962),
  Shadowburn                            = Spell(17877),
  SummonInfernal                        = Spell(1122),
  DarkSoulInstability                   = Spell(113858),
  DarkSoulInstabilityBuff               = Spell(113858),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  Fireblood                             = Spell(265221),
  InternalCombustion                    = Spell(266134),
  ShadowburnDebuff                      = Spell(17877),
  Flashover                             = Spell(267115),
  CrashingChaos                         = Spell(277644),
  Eradication                           = Spell(196412),
  EradicationDebuff                     = Spell(196414),
  ShiverVenomDebuff                     = Spell(301624),
  RecklessForceBuff                     = Spell(302932),
  -- Pet abilities
  CauterizeMaster                       = Spell(119905),--imp
  Suffering                             = Spell(119907),--voidwalker
  Whiplash                              = Spell(119909),--Bitch
  ShadowLock                            = Spell(171140),--doomguard
  MeteorStrike                          = Spell(171152),--infernal
  SingeMagic                            = Spell(119905),--imp
  SpellLock 							= Spell(119898),
  Shadowfury                            = Spell(30283),
  AxeToss 								= Spell(119914), --FelGuard
  -- Defensive
  UnendingResolve                       = Spell(104773),
  SummonDoomGuard                       = Spell(18540),
  SummonDoomGuardSuppremacy             = Spell(157757),
  SummonInfernalSuppremacy              = Spell(157898),
  SummonImp                             = Spell(688),
  GrimoireImp                           = Spell(111859),
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
local S = RubimRH.Spell[267]

-- Items
if not Item.Warlock then Item.Warlock = {} end
Item.Warlock.Destruction = {
  PotionofUnbridledFury            = Item(169299),
  AzsharasFontofPower              = Item(169314),
  PocketsizedComputationDevice     = Item(167555),
  RotcrustedVoodooDoll             = Item(159624),
  ShiverVenomRelic                 = Item(168905),
  AquipotentNautilus               = Item(169305),
  TidestormCodex                   = Item(165576),
  VialofStorms                     = Item(158224)
};
local I = Item.Warlock.Destruction;

-- Rotation Var
local ShouldReturn; -- Used to get the return string
local EnemiesCount;

-- Variables
local VarPoolSoulShards = 0;

HL:RegisterForEvent(function()
  VarPoolSoulShards = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function GetEnemiesCount(range)
    if range == nil then range = 10 end
	 -- Unit Update - Update differently depending on if splash data is being used
	if RubimRH.AoEON() then       
	        if RubimRH.db.profile[267].useSplashData == "Enabled" then	
                HL.GetEnemies(range, nil, true, Target)
                return Cache.EnemiesCount[range]
            else
                return active_enemies()
            end
    else
        return 1
    end
end

S.ConcentratedFlame:RegisterInFlight()
S.ChaosBolt:RegisterInFlight()

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function FutureShard()
  local Shard = Player:SoulShards()
  if not Player:IsCasting() then
    return Shard
  else
    if Player:IsCasting(S.UnstableAffliction) 
        or Player:IsCasting(S.SeedOfCorruption) then
      return Shard - 1
    elseif Player:IsCasting(S.SummonDoomGuard) 
        or Player:IsCasting(S.SummonDoomGuardSuppremacy) 
        or Player:IsCasting(S.SummonInfernal) 
        or Player:IsCasting(S.SummonInfernalSuppremacy) 
        or Player:IsCasting(S.GrimoireFelhunter) 
        or Player:IsCasting(S.SummonFelhunter) then
      return Shard - 1
    else
      return Shard
    end
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

local PetType = {
  [89] = {"Infernal", 30},
};

HL.DestroGuardiansTable = {
    --{PetType,petID,dateEvent,UnitPetGUID,CastsLeft}
    Pets = {
    },
    PetList={
    [89]="Infernal",
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
    local PetType=HL.DestroGuardiansTable.PetList[tonumber(t[6])]
    if PetType then
        table.insert(HL.DestroGuardiansTable.Pets,{PetType,tonumber(t[6]),GetTime(),UnitPetGUID,5})
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
        [89] = {"Infernal", 30},
    }
    local maxduration = 0
    for key, Value in pairs(HL.DestroGuardiansTable.Pets) do
        if HL.DestroGuardiansTable.Pets[key][1] == PetType then
            if (PetsInfo[HL.DestroGuardiansTable.Pets[key][2]][2] - (GetTime() - HL.DestroGuardiansTable.Pets[key][3])) > maxduration then
                maxduration = HL.OffsetRemains((PetsInfo[HL.DestroGuardiansTable.Pets[key][2]][2] - (GetTime() - HL.DestroGuardiansTable.Pets[key][3])), "Auto" );
            end
        end
    end
    return maxduration
end

local function InfernalIsActive()
    if PetDuration("Infernal") > 1 then
        return true
   else
        return false
    end
end

local function EnemyHasHavoc()
  for _, Value in pairs(Cache.Enemies[40]) do
    if Value:Debuff(S.Havoc) then
      return Value:DebuffRemainsP(S.Havoc)
    end
  end
  return 0
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

--HL.RegisterNucleusAbility(42223, 8, 6)               -- Rain of Fire
--HL.RegisterNucleusAbility(152108, 8, 6)              -- Cataclysm
--HL.RegisterNucleusAbility(22703, 10, 6)               -- Summon Infernal

--- ======= ACTION LISTS =======
local function IsPetInvoked (testBigPets)
    testBigPets = testBigPets or false
    return S.Suffering:IsLearned() or S.SpellLock:IsLearned() or S.Whiplash:IsLearned() or S.CauterizeMaster:IsLearned() or S.AxeToss:IsLearned() or (testBigPets and (S.ShadowLock:IsLearned() or S.MeteorStrike:IsLearned()))
end

local function APL()
  local Precombat_DBM, Precombat, Aoe, Cds, Havoc
  EnemiesCount = GetEnemiesCount(10)
  DetermineEssenceRanks()
  HL.GetEnemies(40) -- To populate Cache.Enemies[40] for CastCycles
  
  -- Mouseover checker on Havoc
  local MouseoverEnemy = UnitExists("mouseover") and not UnitIsFriend("target", "mouseover")

  --if RubimRH.TargetIsValid() then
  --  print(EnemiesCount)
  --end
  
  	Precombat_DBM = function()
        -- flask
        -- food
        -- augmentation
        -- summon_pet
        if S.SummonPet:IsCastableP() and not IsPetInvoked() then
            return S.SummonPet:Cast()
        end
        -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
        if S.GrimoireofSacrifice:IsCastableP() and (S.GrimoireofSacrifice:IsAvailable()) then
            return S.GrimoireofSacrifice:Cast()
        end
        -- snapshot_stats
	    -- potion
        if I.PotionofUnbridledFury:IsReady() and RubimRH.DBM_PullTimer() >= S.Incinerate:CastTime() + 1 and RubimRH.DBM_PullTimer() <= S.Incinerate:CastTime() + 2 then
            return 967532
        end
        -- soul_fire
        if S.SoulFire:IsCastableP() and RubimRH.DBM_PullTimer() > 1 and RubimRH.DBM_PullTimer() <= S.SoulFire:CastTime() then
            return S.SoulFire:Cast()
        end
        -- incinerate,if=!talent.soul_fire.enabled
        if S.Incinerate:IsCastableP() and Player:SoulShardsP() < 4.5 and (not S.SoulFire:IsAvailable()) and RubimRH.DBM_PullTimer() > 0.1 and RubimRH.DBM_PullTimer() <= S.Incinerate:CastTime() + S.Incinerate:TravelTime() then
            return S.Incinerate:Cast()
        end
    end
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- summon_pet
    if S.SummonPet:IsCastableP() and not IsPetInvoked() then
      return S.SummonPet:Cast()
    end
    -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
    if S.GrimoireofSacrifice:IsCastableP() and (S.GrimoireofSacrifice:IsAvailable()) then
      return S.GrimoireofSacrifice:Cast()
    end
    -- snapshot_stats
    if RubimRH.TargetIsValid() then
      -- potion
      -- soul_fire
      if S.SoulFire:IsCastableP() then
        return S.SoulFire:Cast()
      end
      -- incinerate,if=!talent.soul_fire.enabled
      if S.Incinerate:IsCastableP() and (not S.SoulFire:IsAvailable()) then
        return S.Incinerate:Cast()
      end
    end
  end
  
  Aoe = function()
    -- rain_of_fire,if=pet.infernal.active&(buff.crashing_chaos.down|!talent.grimoire_of_supremacy.enabled)&(!cooldown.havoc.ready|active_enemies>3)
    if S.RainofFire:IsReadyP() and (S.SummonInfernal:CooldownRemainsP() > 150 and (Player:BuffDownP(S.CrashingChaosBuff) or not S.GrimoireofSupremacy:IsAvailable()) and (not S.Havoc:CooldownUpP() or EnemiesCount > 3)) then
      return S.RainofFire:Cast()
    end
    -- channel_demonfire,if=dot.immolate.remains>cast_time
    if S.ChannelDemonfire:IsCastableP() and (Target:DebuffRemainsP(S.ImmolateDebuff) > S.ChannelDemonfire:CastTime()) then
      return S.ChannelDemonfire:Cast()
    end
    -- immolate,cycle_targets=1,if=remains<5&(!talent.cataclysm.enabled|cooldown.cataclysm.remains>remains)
    if S.Immolate:IsCastableP() and Target:DebuffRemainsP(S.ImmolateDebuff) < 5 and (not S.Cataclysm:IsAvailable() or S.Cataclysm:CooldownRemainsP() > Target:DebuffRemainsP(S.ImmolateDebuff)) then
      return S.Immolate:Cast()
    end
    -- call_action_list,name=cds
    if RubimRH.CDsON() then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- havoc,cycle_targets=1,if=!(target=self.target)&active_enemies<4
    if S.Havoc:IsCastableP() and Cache.EnemiesCount[40] < 4 then
      return S.Havoc:Cast()
    end
    -- chaos_bolt,if=talent.grimoire_of_supremacy.enabled&pet.infernal.active&(havoc_active|talent.cataclysm.enabled|talent.inferno.enabled&active_enemies<4)
    if S.ChaosBolt:IsReadyP() and (S.GrimoireofSupremacy:IsAvailable() and S.SummonInfernal:CooldownRemainsP() > 150 and (bool(EnemyHasHavoc()) or S.Cataclysm:IsAvailable() or S.Inferno:IsAvailable() and EnemiesCount < 4)) then
      return S.ChaosBolt:Cast()
    end
    -- rain_of_fire
    if S.RainofFire:IsReadyP() then
      return S.RainofFire:Cast()
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- havoc,cycle_targets=1,if=!(target=self.target)&(!talent.grimoire_of_supremacy.enabled|!talent.inferno.enabled|talent.grimoire_of_supremacy.enabled&pet.infernal.remains<=10)
    if S.Havoc:IsCastableP() and (not S.GrimoireofSupremacy:IsAvailable() or not S.Inferno:IsAvailable() or S.GrimoireofSupremacy:IsAvailable() and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
      return S.Havoc:Cast()
    end
    -- incinerate,if=talent.fire_and_brimstone.enabled&buff.backdraft.up&soul_shard<5-0.2*active_enemies
    if S.Incinerate:IsCastableP() and (S.FireandBrimstone:IsAvailable() and Player:BuffP(S.BackdraftBuff) and Player:SoulShardsP() < 5 - 0.2 * EnemiesCount) then
      return S.Incinerate:Cast()
    end
    -- soul_fire
    if S.SoulFire:IsCastableP() then
      return S.SoulFire:Cast()
    end
    -- conflagrate,if=buff.backdraft.down
    if S.Conflagrate:IsCastableP() and (Player:BuffDownP(S.BackdraftBuff)) then
      return S.Conflagrate:Cast()
    end
    -- shadowburn,if=!talent.fire_and_brimstone.enabled
    if S.Shadowburn:IsCastableP() and (not S.FireandBrimstone:IsAvailable()) then
      return S.Shadowburn:Cast()
    end
    -- concentrated_flame,if=!dot.concentrated_flame_burn.remains&!action.concentrated_flame.in_flight&active_enemies<5
    -- Need ConcentratedFlame DoT Spell ID
    if S.ConcentratedFlame:IsCastableP() and (EnemiesCount < 5) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- incinerate
    if S.Incinerate:IsCastableP() then
      return S.Incinerate:Cast()
    end
  end
  
  Cds = function()
    -- use_item,name=azsharas_font_of_power,if=cooldown.summon_infernal.up|cooldown.summon_infernal.remains<5
    if I.AzsharasFontofPower:IsReady() and (S.SummonInfernal:CooldownUpP() or S.SummonInfernal:CooldownRemainsP() < 5) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- summon_infernal,if=cooldown.dark_soul_instability.ready|cooldown.memory_of_lucid_dreams.ready|(!talent.dark_soul_instability.enabled&!essence.memory_of_lucid_dreams.major)|cooldown.dark_soul_instability.remains<=10|cooldown.memory_of_lucid_dreams.remains<=10
    if S.SummonInfernal:IsCastableP() and (S.DarkSoulInstability:CooldownUpP() or S.MemoryOfLucidDreams:CooldownUpP() or (not S.DarkSoulInstability:IsAvailable() and not S.MemoryOfLucidDreams:IsAvailable()) or S.DarkSoulInstability:CooldownRemainsP() <= 10 or S.MemoryOfLucidDreams:CooldownRemainsP() <= 10) then
      return S.SummonInfernal:Cast()
    end
    -- guardian_of_azeroth,if=pet.infernal.active
    if S.GuardianOfAzeroth:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() > 150) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- dark_soul_instability,if=pet.infernal.active&pet.infernal.remains<=20
    if S.DarkSoulInstability:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() > 150 and Player:BuffRemainsP(S.DarkSoulInstabilityBuff) <= 20) then
      return S.DarkSoulInstability:Cast()
    end
    -- memory_of_lucid_dreams,if=pet.infernal.active&pet.infernal.remains<=20
    if S.MemoryOfLucidDreams:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() > 150 and S.SummonInfernal:CooldownRemainsP() <= 170) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- summon_infernal,if=target.time_to_die>cooldown.summon_infernal.duration+30
    if S.SummonInfernal:IsCastableP() and (Target:TimeToDie() > S.SummonInfernal:BaseDuration() + 30) then
      return S.SummonInfernal:Cast()
    end
    -- guardian_of_azeroth,if=time>30&target.time_to_die>cooldown.guardian_of_azeroth.duration+30
    if S.GuardianOfAzeroth:IsCastableP() and (HL.CombatTime() > 30 and Target:TimeToDie() > S.GuardianOfAzeroth:BaseDuration() + 30) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- summon_infernal,if=talent.dark_soul_instability.enabled&cooldown.dark_soul_instability.remains>target.time_to_die
    if S.SummonInfernal:IsCastableP() and (S.DarkSoulInstability:IsAvailable() and S.DarkSoulInstability:CooldownRemainsP() > Target:TimeToDie()) then
      return S.SummonInfernal:Cast()
    end
    -- guardian_of_azeroth,if=cooldown.summon_infernal.remains>target.time_to_die
    if S.GuardianOfAzeroth:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() > Target:TimeToDie()) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- dark_soul_instability,if=cooldown.summon_infernal.remains>target.time_to_die
    if S.DarkSoulInstability:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() > Target:TimeToDie()) then
      return S.DarkSoulInstability:Cast()
    end
    -- memory_of_lucid_dreams,if=cooldown.summon_infernal.remains>target.time_to_die
    if S.MemoryOfLucidDreams:IsCastableP() and (S.SummonInfernal:CooldownRemainsP() > Target:TimeToDie()) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- summon_infernal,if=target.time_to_die<30
    if S.SummonInfernal:IsCastableP() and (Target:TimeToDie() < 30) then
      return S.SummonInfernal:Cast()
    end
    -- guardian_of_azeroth,if=target.time_to_die<30
    if S.GuardianOfAzeroth:IsCastableP() and (Target:TimeToDie() < 30) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- dark_soul_instability,if=target.time_to_die<20
    if S.DarkSoulInstability:IsCastableP() and (Target:TimeToDie() < 20) then
      return S.DarkSoulInstability:Cast()
    end
    -- memory_of_lucid_dreams,if=target.time_to_die<20
    if S.MemoryOfLucidDreams:IsCastableP() and (Target:TimeToDie() < 20) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- blood_of_the_enemy
    if S.BloodOfTheEnemy:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- potion,if=pet.infernal.active|target.time_to_die<30
    -- berserking,if=pet.infernal.active|buff.memory_of_lucid_dreams.remains|buff.dark_soul_instability.remains|target.time_to_die<30
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and (S.SummonInfernal:CooldownRemainsP() > 150 or Player:BuffP(S.MemoryOfLucidDreams) or Player:BuffP(S.DarkSoulInstabilityBuff) or Target:TimeToDie() < 30) then
      return S.Berserking:Cast()
    end
    -- blood_fury,if=pet.infernal.active|buff.memory_of_lucid_dreams.remains|buff.dark_soul_instability.remains|target.time_to_die<30
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (S.SummonInfernal:CooldownRemainsP() > 150 or Player:BuffP(S.MemoryOfLucidDreams) or Player:BuffP(S.DarkSoulInstabilityBuff) or Target:TimeToDie() < 30) then
      return S.BloodFury:Cast()
    end
    -- fireblood,if=pet.infernal.active|buff.memory_of_lucid_dreams.remains|buff.dark_soul_instability.remains|target.time_to_die<30
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (S.SummonInfernal:CooldownRemainsP() > 150 or Player:BuffP(S.MemoryOfLucidDreams) or Player:BuffP(S.DarkSoulInstabilityBuff) or Target:TimeToDie() < 30) then
      return S.Fireblood:Cast()
    end
    -- use_items,if=pet.infernal.active|buff.memory_of_lucid_dreams.remains|buff.dark_soul_instability.remains|target.time_to_die<30
    -- use_item,name=pocketsized_computation_device,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.PocketsizedComputationDevice:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=rotcrusted_voodoo_doll,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.RotcrustedVoodooDoll:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=shiver_venom_relic,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.ShiverVenomRelic:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=aquipotent_nautilus,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.AquipotentNautilus:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=tidestorm_codex,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.TidestormCodex:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=vial_of_storms,if=dot.immolate.remains>=5&(cooldown.summon_infernal.remains>=20|target.time_to_die<30)
    if I.VialofStorms:IsReady() and (Target:DebuffRemainsP(S.ImmolateDebuff) >= 5 and (S.SummonInfernal:CooldownRemainsP() >= 20 or Target:TimeToDie() < 30)) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
  end
  
  Havoc = function()
    -- conflagrate,if=buff.backdraft.down&soul_shard>=1&soul_shard<=4
    if S.Conflagrate:IsCastableP() and (Player:BuffDownP(S.BackdraftBuff) and Player:SoulShardsP() >= 1 and Player:SoulShardsP() <= 4) then
      return S.Conflagrate:Cast()
    end
    -- immolate,if=talent.internal_combustion.enabled&remains<duration*0.5|!talent.internal_combustion.enabled&refreshable
    if S.Immolate:IsCastableP() and (S.InternalCombustion:IsAvailable() and Target:DebuffRemainsP(S.ImmolateDebuff) < S.ImmolateDebuff:BaseDuration() * 0.5 or not S.InternalCombustion:IsAvailable() and Target:DebuffRefreshableCP(S.ImmolateDebuff)) then
      return S.Immolate:Cast()
    end
    -- chaos_bolt,if=cast_time<havoc_remains
    if S.ChaosBolt:IsReadyP() and (S.ChaosBolt:CastTime() < EnemyHasHavoc()) then
      return S.ChaosBolt:Cast()
    end
    -- soul_fire
    if S.SoulFire:IsCastableP() then
      return S.SoulFire:Cast()
    end
    -- shadowburn,if=active_enemies<3|!talent.fire_and_brimstone.enabled
    if S.Shadowburn:IsCastableP() and (EnemiesCount < 3 or not S.FireandBrimstone:IsAvailable()) then
      return S.Shadowburn:Cast()
    end
    -- incinerate,if=cast_time<havoc_remains
    if S.Incinerate:IsCastableP() and (S.Incinerate:CastTime() < EnemyHasHavoc()) then
      return S.Incinerate:Cast()
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
  
  -- call combat
  if RubimRH.TargetIsValid() then
    if QueueSkill() ~= nil then
		return QueueSkill()
    end
    -- auto switch target on havoc cast and not player tabbing
    if S.Havoc:CooldownRemainsP() > 1 and bool(Target:DebuffRemainsP(S.HavocDebuff)) and RubimRH.AoEON() then
       return 133015
    end
    -- unending resolve,defensive,player.health<=40
    if S.UnendingResolve:IsCastableP() and Player:HealthPercentage() <= mainAddon.db.profile[267].sk1 then
       return S.UnendingResolve:Cast()
    end  
    -- Mythic+ - interrupt2 (command demon)
    if S.SpellLock:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
       return 0, "Interface\\Addons\\Rubim-RH\\Media\\wl_lock_red.tga"
	end
	-- Mythic+ - Shadowfury aoe stun test
    if S.Shadowfury:IsCastableP() and (not Player:IsMoving()) and not Player:ShouldStopCasting() and RubimRH.InterruptsON() and active_enemies() >= 3 and Target:IsInterruptible() then
	   return S.Shadowfury:Cast()
    end	
    -- call_action_list,name=havoc,if=havoc_active&active_enemies<5-talent.inferno.enabled+(talent.inferno.enabled&talent.internal_combustion.enabled)
    if (bool(EnemyHasHavoc()) and EnemiesCount < 5 - num(S.Inferno:IsAvailable()) + num((S.Inferno:IsAvailable() and S.InternalCombustion:IsAvailable()))) then
       local ShouldReturn = Havoc(); if ShouldReturn then return ShouldReturn; end
    end
    -- cataclysm
    if S.Cataclysm:IsCastableP() then
       return S.Cataclysm:Cast()
    end
    -- call_action_list,name=aoe,if=active_enemies>2
    if (EnemiesCount > 2) then
       local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
    end
    -- immolate,cycle_targets=1,if=refreshable&(!talent.cataclysm.enabled|cooldown.cataclysm.remains>remains)
    if S.Immolate:IsCastableP() and Target:DebuffRefreshableCP(S.ImmolateDebuff) and (not S.Cataclysm:IsAvailable() or S.Cataclysm:CooldownRemainsP() > Target:DebuffRemainsP(S.ImmolateDebuff)) then
       return S.Immolate:Cast()
    end
    -- immolate,if=talent.internal_combustion.enabled&action.chaos_bolt.in_flight&remains<duration*0.5
    if S.Immolate:IsCastableP() and (S.InternalCombustion:IsAvailable() and S.ChaosBolt:InFlight() and Target:DebuffRemainsP(S.ImmolateDebuff) < S.ImmolateDebuff:BaseDuration() * 0.5) then
       return S.Immolate:Cast()
    end
    -- call_action_list,name=cds
    if RubimRH.CDsON() then
       local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- focused_azerite_beam,if=!pet.infernal.active|!talent.grimoire_of_supremacy.enabled
    if S.FocusedAzeriteBeam:IsCastableP() and (not S.SummonInfernal:CooldownRemainsP() > 150 or not S.GrimoireofSupremacy:IsAvailable()) then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force,if=buff.reckless_force.react
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff)) then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame,if=!dot.concentrated_flame_burn.remains&!action.concentrated_flame.in_flight
    if S.ConcentratedFlame:IsCastableP() then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- channel_demonfire
    if S.ChannelDemonfire:IsCastableP() then
       return S.ChannelDemonfire:Cast()
    end
    -- havoc,cycle_targets=1,if=!(target=self.target)&(dot.immolate.remains>dot.immolate.duration*0.5|!talent.internal_combustion.enabled)&(!cooldown.summon_infernal.ready|!talent.grimoire_of_supremacy.enabled|talent.grimoire_of_supremacy.enabled&pet.infernal.remains<=10)
    if S.Havoc:IsCastableP() and (Target:DebuffRemainsP(S.ImmolateDebuff) > S.ImmolateDebuff:BaseDuration() * 0.5 or not S.InternalCombustion:IsAvailable()) and (not S.SummonInfernal:CooldownUpP() or not S.GrimoireofSupremacy:IsAvailable() or S.GrimoireofSupremacy:IsAvailable() and Target:DebuffRemainsP(S.HavocDebuff) <= 10) then
       return S.Havoc:Cast()
    end
    -- soul_fire
    if S.SoulFire:IsCastableP() then
       return S.SoulFire:Cast()
    end
    -- conflagrate,if=buff.backdraft.down&soul_shard>=1.5-0.3*talent.flashover.enabled&!variable.pool_soul_shards
    if S.Conflagrate:IsCastableP() and (Player:BuffDownP(S.BackdraftBuff) and Player:SoulShardsP() >= 1.5 - 0.3 * num(S.Flashover:IsAvailable()) and not bool(VarPoolSoulShards)) then
       return S.Conflagrate:Cast()
    end
    -- shadowburn,if=soul_shard<2&(!variable.pool_soul_shards|charges>1)
    if S.Shadowburn:IsCastableP() and (Player:SoulShardsP() < 2 and (not bool(VarPoolSoulShards) or S.Shadowburn:ChargesP() > 1)) then
       return S.Shadowburn:Cast()
    end
    -- variable,name=pool_soul_shards,value=active_enemies>1&cooldown.havoc.remains<=10|cooldown.summon_infernal.remains<=20&(talent.grimoire_of_supremacy.enabled|talent.dark_soul_instability.enabled&cooldown.dark_soul_instability.remains<=20)|talent.dark_soul_instability.enabled&cooldown.dark_soul_instability.remains<=20&(cooldown.summon_infernal.remains>target.time_to_die|cooldown.summon_infernal.remains+cooldown.summon_infernal.duration>target.time_to_die)
    if (true) then
      VarPoolSoulShards = num(EnemiesCount > 1 and S.Havoc:CooldownRemainsP() <= 10 or S.SummonInfernal:CooldownRemainsP() <= 20 and (S.GrimoireofSupremacy:IsAvailable() or S.DarkSoulInstability:IsAvailable() and S.DarkSoulInstability:CooldownRemainsP() <= 20) or S.DarkSoulInstability:IsAvailable() and S.DarkSoulInstability:CooldownRemainsP() <= 20 and (S.SummonInfernal:CooldownRemainsP() > Target:TimeToDie() or S.SummonInfernal:CooldownRemainsP() + S.SummonInfernal:BaseDuration() > Target:TimeToDie()))
    end
    -- chaos_bolt,if=(talent.grimoire_of_supremacy.enabled|azerite.crashing_chaos.enabled)&pet.infernal.active|buff.dark_soul_instability.up|buff.reckless_force.react&buff.reckless_force.remains>cast_time
    if S.ChaosBolt:IsReadyP() and ((S.GrimoireofSupremacy:IsAvailable() or S.CrashingChaos:AzeriteEnabled()) and S.SummonInfernal:CooldownRemainsP() > 150 or Player:BuffP(S.DarkSoulInstabilityBuff) or Player:BuffP(S.RecklessForceBuff) and Player:BuffRemainsP(S.RecklessForceBuff) > S.ChaosBolt:CastTime()) then
		return S.ChaosBolt:Cast()
    end
    -- chaos_bolt,if=!variable.pool_soul_shards&!talent.eradication.enabled
    if S.ChaosBolt:IsReadyP() and (not bool(VarPoolSoulShards) and not S.Eradication:IsAvailable()) then
      return S.ChaosBolt:Cast()
    end
    -- chaos_bolt,if=!variable.pool_soul_shards&talent.eradication.enabled&(debuff.eradication.remains<cast_time|buff.backdraft.up)
    if S.ChaosBolt:IsReadyP() and (not bool(VarPoolSoulShards) and S.Eradication:IsAvailable() and (Target:DebuffRemainsP(S.EradicationDebuff) < S.ChaosBolt:CastTime() or Player:BuffP(S.BackdraftBuff))) then
      return S.ChaosBolt:Cast()
    end
    -- chaos_bolt,if=(soul_shard>=4.5-0.2*active_enemies)
    if S.ChaosBolt:IsReadyP() and ((Player:SoulShardsP() >= 4.5 - 0.2 * EnemiesCount)) then
      return S.ChaosBolt:Cast()
    end
    -- conflagrate,if=charges>1
    if S.Conflagrate:IsCastableP() and (S.Conflagrate:ChargesP() > 1) then
      return S.Conflagrate:Cast()
    end
    -- incinerate
    if S.Incinerate:IsCastableP() then
      return S.Incinerate:Cast()
    end
   end
   return 0, 135328
end

RubimRH.Rotation.SetAPL(267, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(267, PASSIVE)