--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
local mainAddon = RubimRH
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[265] = {  
  DreadfulCalling                      = Spell(278727),
  SummonPet                            = Spell(691),
  GrimoireofSacrificeBuff              = Spell(196099),
  GrimoireofSacrifice                  = Spell(108503),
  SeedofCorruptionDebuff               = Spell(27243),
  SeedofCorruption                     = Spell(27243),
  HauntDebuff                          = Spell(48181),
  Haunt                                = Spell(48181),
  ShadowBolt                           = Spell(232670),
  DarkSoulMisery                       = Spell(113860),
  SummonDarkglare                      = Spell(205180),
  DarkSoul                             = Spell(113860),
  Fireblood                            = Spell(265221),
  BloodFury                            = Spell(20572),
  SiphonLife                           = Spell(63106),
  SiphonLifeDebuff                     = Spell(63106),
  AgonyDebuff                          = Spell(980),
  CorruptionDebuff                     = Spell(146739),
  Agony                                = Spell(980),
  Corruption                           = Spell(172),
  CreepingDeath                        = Spell(264000),
  WritheInAgony                        = Spell(196102),
  UnstableAffliction                   = Spell(30108),
  UnstableAfflictionDebuff             = Spell(30108),
  Deathbolt                            = Spell(264106),
  NightfallBuff                        = Spell(264571),
  AbsoluteCorruption                   = Spell(196103),
  DrainLife                            = Spell(234153),
  InevitableDemiseBuff                 = Spell(273525),
  PhantomSingularity                   = Spell(205179),
  VileTaint                            = Spell(278350),
  DrainSoul                            = Spell(198590),
  ShadowEmbraceDebuff                  = Spell(32390),
  ShadowEmbrace                        = Spell(32388),
  CascadingCalamity                    = Spell(275372),
  CascadingCalamityBuff                = Spell(275378),
  WrackingBrillianceBuff               = Spell(272891),
  SowtheSeeds                          = Spell(196226),
  ActiveUasBuff                        = Spell(233490),
  PhantomSingularityDebuff             = Spell(205179),
  SpellLock                            = Spell(119898),
  Shadowfury                           = Spell(30283),
  PandemicInvocation                   = Spell(289364),
  Berserking                           = Spell(26297), 
  ShiverVenomDebuff                    = Spell(301624),
  -- Defensive
  UnendingResolve                      = Spell(104773), 
  --8.2 Essences
  UnleashHeartOfAzeroth                = Spell(280431),
  BloodOfTheEnemy                      = Spell(297108),
  BloodOfTheEnemy2                     = Spell(298273),
  BloodOfTheEnemy3                     = Spell(298277),
  ConcentratedFlame                    = Spell(295373),
  ConcentratedFlame2                   = Spell(299349),
  ConcentratedFlame3                   = Spell(299353),
  GuardianOfAzeroth                    = Spell(295840),
  GuardianOfAzeroth2                   = Spell(299355),
  GuardianOfAzeroth3                   = Spell(299358),
  FocusedAzeriteBeam                   = Spell(295258),
  FocusedAzeriteBeam2                  = Spell(299336),
  FocusedAzeriteBeam3                  = Spell(299338),
  PurifyingBlast                       = Spell(295337),
  PurifyingBlast2                      = Spell(299345),
  PurifyingBlast3                      = Spell(299347),
  TheUnboundForce                      = Spell(298452),
  TheUnboundForce2                     = Spell(299376),
  TheUnboundForce3                     = Spell(299378),
  RippleInSpace                        = Spell(302731),
  RippleInSpace2                       = Spell(302982),
  RippleInSpace3                       = Spell(302983),
  WorldveinResonance                   = Spell(295186),
  WorldveinResonance2                  = Spell(298628),
  WorldveinResonance3                  = Spell(299334),
  MemoryOfLucidDreams                  = Spell(298357),
  MemoryOfLucidDreams2                 = Spell(299372),
  MemoryOfLucidDreams3                 = Spell(299374),
  VisionOfPerfectionMinor              = Spell(296320),
  VisionOfPerfectionMinor2             = Spell(299367),
  VisionOfPerfectionMinor3             = Spell(299369),

};
local S = RubimRH.Spell[265]

-- Items
if not Item.Warlock then Item.Warlock = {} end
Item.Warlock.Affliction = {
  PotionofUnbridledFury            = Item(169299),
  AzsharasFontofPower              = Item(169314),
  PocketsizedComputationDevice     = Item(167555),
  RotcrustedVoodooDoll             = Item(159624),
  ShiverVenomRelic                 = Item(168905),
  AquipotentNautilus               = Item(169305),
  TidestormCodex                   = Item(165576),
  VialofStorms                     = Item(158224)
};
local I = Item.Warlock.Affliction;

-- Rotation Var
local ShouldReturn; -- Used to get the return string
local EnemiesCount;

-- Variables
local VarMaintainSe = 0;
local VarUseSeed = 0;
local VarPadding = 0;

HL:RegisterForEvent(function()
  VarMaintainSe = 0
  VarUseSeed = 0
  VarPadding = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {40, 5}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function GetEnemiesCount(range)
  -- Unit Update - Update differently depending on if splash data is being used
  if RubimRH.AoEON() then
    if RubimRH.db.profile[265].useSplashData == "Enabled" then
      HL.GetEnemies(range, nil, true, Target)
      return Cache.EnemiesCount[range]
    else
      UpdateRanges()
      return active_enemies()
    end
  else
    return 1
  end
end

S.SeedofCorruption:RegisterInFlight()
S.ConcentratedFlame:RegisterInFlight()
S.ShadowBolt:RegisterInFlight()

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function TimeToShard()
  local ActiveAgony = S.Agony:ActiveDot()
  if ActiveAgony == 0 then
    return 10000 
  end
  return 1 / (0.16 / math.sqrt(ActiveAgony) * (ActiveAgony == 1 and 1.15 or 1) * ActiveAgony / S.Agony:TickTime())
end

local UnstableAfflictionDebuffs = {
  Spell(233490),
  Spell(233496),
  Spell(233497),
  Spell(233498),
  Spell(233499)
};

local function ActiveUAs ()
  local UACount = 0
  for _, UADebuff in pairs(UnstableAfflictionDebuffs) do
    if Target:DebuffRemainsP(UADebuff) > 0 then UACount = UACount + 1 end
  end
  return UACount
end

local function Contagion()
  local MaximumDuration = 0
  for _, UADebuff in pairs(UnstableAfflictionDebuffs) do
    local UARemains = Target:DebuffRemainsP(UADebuff)
    if UARemains > MaximumDuration then
      MaximumDuration = UARemains
    end
  end
  return MaximumDuration
end

-- Pet functions
local PetType = {
  [103673] = {"Darkglare", 20},
};

HL.AffliGuardiansTable = {
    --{PetType,petID,dateEvent,UnitPetGUID,CastsLeft}
    Pets = {
    },
    PetList={
    [103673]="Darkglare",
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
    
    local PetType=HL.AffliGuardiansTable.PetList[tonumber(t[6])]
    if PetType then
        table.insert(HL.AffliGuardiansTable.Pets,{PetType,tonumber(t[6]),GetTime(),UnitPetGUID,5})
    end
end
    , "SPELL_SUMMON"
);

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
  S.VisionOfPerfectionMinor = S.VisionOfPerfectionMinor2:IsAvailable() and S.VisionOfPerfectionMinor2 or S.VisionOfPerfectionMinor
  S.VisionOfPerfectionMinor = S.VisionOfPerfectionMinor3:IsAvailable() and S.VisionOfPerfectionMinor3 or S.VisionOfPerfectionMinor
end
        
-- Summoned pet duration
local function PetDuration(PetType)
    if not PetType then 
        return 0 
    end
    local PetsInfo = {
        [103673] = {"Darkglare", 20},
    }
    local maxduration = 0
    for key, Value in pairs(HL.AffliGuardiansTable.Pets) do
        if HL.AffliGuardiansTable.Pets[key][1] == PetType then
            if (PetsInfo[HL.AffliGuardiansTable.Pets[key][2]][2] - (GetTime() - HL.AffliGuardiansTable.Pets[key][3])) > maxduration then
                maxduration = HL.OffsetRemains((PetsInfo[HL.AffliGuardiansTable.Pets[key][2]][2] - (GetTime() - HL.AffliGuardiansTable.Pets[key][3])), "Auto" );
            end
        end
    end
    return maxduration
end

local function DarkglareIsActive()
    if PetDuration("Darkglare") > 5.25 then
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

S.ShadowBolt:RegisterInFlight()
S.SeedofCorruption:RegisterInFlight()

--HL.RegisterNucleusAbility(27285, 10, 6)               -- Seed Explosion

--- ======= ACTION LISTS =======
local function APL()
  local Precombat_DBM, Precombat, Cooldowns, DbRefresh, Dots, Fillers, Spenders
  EnemiesCount = GetEnemiesCount(10)
  DetermineEssenceRanks()
  HL.GetEnemies(40) -- To populate Cache.Enemies[40] for CastCycles
  time_to_shard = TimeToShard()
  contagion = Contagion()
    
  Precombat_DBM = function()
    -- summon_pet
    if S.SummonPet:IsCastableP() and (not Player:IsMoving()) and not Player:ShouldStopCasting() and not Pet:IsActive() and (not bool(Player:BuffRemainsP(S.GrimoireofSacrificeBuff)))  then
      return S.SummonPet:Cast()
    end
    -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
    if S.GrimoireofSacrifice:IsCastableP() and Player:BuffDownP(S.GrimoireofSacrificeBuff) and (S.GrimoireofSacrifice:IsAvailable()) then
      return S.GrimoireofSacrifice:Cast()
    end
    -- snapshot_stats
    -- pre potion haunt
    if I.PotionofUnbridledFury:IsReady() and S.Haunt:IsAvailable() and RubimRH.DBM_PullTimer() > S.Haunt:CastTime() + 1 and RubimRH.DBM_PullTimer() <= S.Haunt:CastTime() + 2 then
        return 967532
    end
    -- pre potion no haunt
    if I.PotionofUnbridledFury:IsReady() and not S.Haunt:IsAvailable() and RubimRH.DBM_PullTimer() > S.Haunt:CastTime() + 1 and RubimRH.DBM_PullTimer() <= S.ShadowBolt:CastTime() + 2 then
         return 967532
    end
    -- haunt
    if S.Haunt:IsCastableP() and not Player:IsMoving() and RubimRH.DBM_PullTimer() > 0.1 and RubimRH.DBM_PullTimer() <= S.Haunt:CastTime() and (not Player:IsMoving()) and not Player:ShouldStopCasting() and Player:DebuffDownP(S.HauntDebuff) then
      return S.Haunt:Cast()
    end
    -- shadow_bolt,if=!talent.haunt.enabled&spell_targets.seed_of_corruption_aoe<3
    if S.ShadowBolt:IsCastableP() and RubimRH.DBM_PullTimer() > 0.1 and RubimRH.DBM_PullTimer() <= S.ShadowBolt:CastTime() and (not Player:IsMoving()) and not Player:ShouldStopCasting() and (not S.Haunt:IsAvailable() and active_enemies() < 3) then
      return S.ShadowBolt:Cast()
    end
    return 0, 462338
  end
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- summon_pet
    if S.SummonPet:IsCastableP() and (not Player:IsMoving()) and not Player:ShouldStopCasting() and not Pet:IsActive() and (not bool(Player:BuffRemainsP(S.GrimoireofSacrificeBuff)))  then
      return S.SummonPet:Cast()
    end
    -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
    if S.GrimoireofSacrifice:IsCastableP() and Player:BuffDownP(S.GrimoireofSacrificeBuff) and (S.GrimoireofSacrifice:IsAvailable()) then
      return S.GrimoireofSacrifice:Cast()
    end
      -- potion
      -- seed_of_corruption,if=spell_targets.seed_of_corruption_aoe>=3
      if S.SeedofCorruption:IsCastableP() and Player:SoulShardsP() > 0 and Player:DebuffDownP(S.SeedofCorruptionDebuff) and (EnemiesCount >= 3) then
        return S.SeedofCorruption:Cast()
      end
      -- haunt
      if S.Haunt:IsCastableP() and not Player:IsMoving() and Player:DebuffDownP(S.HauntDebuff) then
        return S.Haunt:Cast()
      end
      -- shadow_bolt,if=!talent.haunt.enabled&spell_targets.seed_of_corruption_aoe<3
      if S.ShadowBolt:IsCastableP() and (not S.Haunt:IsAvailable() and EnemiesCount < 3) then
        return S.ShadowBolt:Cast()
      end
  end
  
  Cooldowns = function()
    -- use_item,name=azsharas_font_of_power,if=(!talent.phantom_singularity.enabled|cooldown.phantom_singularity.remains<4*spell_haste|!cooldown.phantom_singularity.remains)&cooldown.summon_darkglare.remains<15*spell_haste&dot.agony.remains&dot.corruption.remains&(dot.siphon_life.remains|!talent.siphon_life.enabled)
    if I.AzsharasFontofPower:IsReady() and ((not S.PhantomSingularity:IsAvailable() or S.PhantomSingularity:CooldownRemainsP() < 4 * Player:SpellHaste() or S.PhantomSingularity:CooldownUpP()) and S.SummonDarkglare:CooldownRemainsP() < 15 * Player:SpellHaste() and Target:DebuffP(S.AgonyDebuff) and Target:DebuffP(S.CorruptionDebuff) and (Target:DebuffP(S.SiphonLifeDebuff) or not S.SiphonLife:IsAvailable())) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- potion,if=(talent.dark_soul_misery.enabled&cooldown.summon_darkglare.up&cooldown.dark_soul.up)|cooldown.summon_darkglare.up|target.time_to_die<30
    -- use_items,if=cooldown.summon_darkglare.remains>70|time_to_die<20|((buff.active_uas.stack=5|soul_shard=0)&(!talent.phantom_singularity.enabled|cooldown.phantom_singularity.remains)&(!talent.deathbolt.enabled|cooldown.deathbolt.remains<=gcd|!cooldown.deathbolt.remains)&!cooldown.summon_darkglare.remains)
    -- use_item,name=pocketsized_computation_device,if=cooldown.summon_darkglare.remains>=25&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.PocketsizedComputationDevice:IsReady() and (S.SummonDarkglare:CooldownRemainsP() >= 25 and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- fireblood,if=!cooldown.summon_darkglare.up
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (not S.SummonDarkglare:CooldownUpP()) then
      return S.Fireblood:Cast()
    end
    -- blood_fury,if=!cooldown.summon_darkglare.up
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (not S.SummonDarkglare:CooldownUpP()) then
      return S.BloodFury:Cast()
    end
    -- memory_of_lucid_dreams,if=time>30
    if S.MemoryOfLucidDreams:IsCastableP() and (HL.CombatTime() > 30) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- blood_of_the_enemy,if=pet.darkglare.remains|(!cooldown.deathbolt.remains|!talent.deathbolt.enabled)&cooldown.summon_darkglare.remains>=80&essence.blood_of_the_enemy.rank>1
    if S.BloodOfTheEnemy:IsCastableP() and (S.SummonDarkglare:CooldownRemainsP() > 160 or (S.Deathbolt:CooldownUpP() or not S.Deathbolt:IsAvailable()) and S.SummonDarkglare:CooldownRemainsP() >= 80 and not S.BloodOfTheEnemy:ID() == 297108) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
	-- use_item,name=pocketsized_computation_device,if=cooldown.summon_darkglare.remains>=25&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.PocketsizedComputationDevice:IsReady() and (S.SummonDarkglare:CooldownRemainsP() >= 25 and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=rotcrusted_voodoo_doll,if=cooldown.summon_darkglare.remains>=25&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.RotcrustedVoodooDoll:IsReady() and (S.SummonDarkglare:CooldownRemainsP() >= 25 and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=shiver_venom_relic,if=cooldown.summon_darkglare.remains>=25&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.ShiverVenomRelic:IsReady() and Target:DebuffStackP(S.ShiverVenomDebuff) >= 5 and (S.SummonDarkglare:CooldownRemainsP() >= 25 and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=aquipotent_nautilus,if=cooldown.summon_darkglare.remains>=25&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.AquipotentNautilus:IsReady() and (S.SummonDarkglare:CooldownRemainsP() >= 25 and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=tidestorm_codex,if=cooldown.summon_darkglare.remains>=25&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.TidestormCodex:IsReady() and (S.SummonDarkglare:CooldownRemainsP() >= 25 and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- use_item,name=vial_of_storms,if=cooldown.summon_darkglare.remains>=25&(cooldown.deathbolt.remains|!talent.deathbolt.enabled)
    if I.VialofStorms:IsReady() and (S.SummonDarkglare:CooldownRemainsP() >= 25 and (bool(S.Deathbolt:CooldownRemainsP()) or not S.Deathbolt:IsAvailable())) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- worldvein_resonance,if=buff.lifeblood.stack<3
    if S.WorldveinResonance:IsCastableP() and (Player:BuffStackP(S.LifebloodBuff) < 3) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
  end
  
  DbRefresh = function()
    -- siphon_life,line_cd=15,if=(dot.siphon_life.remains%dot.siphon_life.duration)<=(dot.agony.remains%dot.agony.duration)&(dot.siphon_life.remains%dot.siphon_life.duration)<=(dot.corruption.remains%dot.corruption.duration)&dot.siphon_life.remains<dot.siphon_life.duration*1.3
    if S.SiphonLife:IsCastableP() and ((Target:DebuffRemainsP(S.SiphonLifeDebuff) / S.SiphonLifeDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.AgonyDebuff) / S.AgonyDebuff:BaseDuration()) and (Target:DebuffRemainsP(S.SiphonLifeDebuff) / S.SiphonLifeDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.CorruptionDebuff) / S.CorruptionDebuff:BaseDuration()) and Target:DebuffRemainsP(S.SiphonLifeDebuff) < S.SiphonLifeDebuff:BaseDuration() * 1.3) then
      return S.SiphonLife:Cast()
    end
    -- agony,line_cd=15,if=(dot.agony.remains%dot.agony.duration)<=(dot.corruption.remains%dot.corruption.duration)&(dot.agony.remains%dot.agony.duration)<=(dot.siphon_life.remains%dot.siphon_life.duration)&dot.agony.remains<dot.agony.duration*1.3
    if S.Agony:IsCastableP() and ((Target:DebuffRemainsP(S.AgonyDebuff) / S.AgonyDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.CorruptionDebuff) / S.CorruptionDebuff:BaseDuration()) and (Target:DebuffRemainsP(S.AgonyDebuff) / S.AgonyDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.SiphonLifeDebuff) / S.SiphonLifeDebuff:BaseDuration()) and Target:DebuffRemainsP(S.AgonyDebuff) < S.AgonyDebuff:BaseDuration() * 1.3) then
      return S.Agony:Cast()
    end
    -- corruption,line_cd=15,if=(dot.corruption.remains%dot.corruption.duration)<=(dot.agony.remains%dot.agony.duration)&(dot.corruption.remains%dot.corruption.duration)<=(dot.siphon_life.remains%dot.siphon_life.duration)&dot.corruption.remains<dot.corruption.duration*1.3
    if S.Corruption:IsCastableP() and not S.AbsoluteCorruption:IsAvailable() and ((Target:DebuffRemainsP(S.CorruptionDebuff) / S.CorruptionDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.AgonyDebuff) / S.AgonyDebuff:BaseDuration()) and (Target:DebuffRemainsP(S.CorruptionDebuff) / S.CorruptionDebuff:BaseDuration()) <= (Target:DebuffRemainsP(S.SiphonLifeDebuff) / S.SiphonLifeDebuff:BaseDuration()) and Target:DebuffRemainsP(S.CorruptionDebuff) < S.CorruptionDebuff:BaseDuration() * 1.3) then
      return S.Corruption:Cast()
    end
  end
  
  Dots = function()
    -- seed_of_corruption,if=dot.corruption.remains<=action.seed_of_corruption.cast_time+time_to_shard+4.2*(1-talent.creeping_death.enabled*0.15)&spell_targets.seed_of_corruption_aoe>=3+raid_event.invulnerable.up+talent.writhe_in_agony.enabled&!dot.seed_of_corruption.remains&!action.seed_of_corruption.in_flight
    if S.SeedofCorruption:IsCastableP() and Player:SoulShardsP() > 0 and (Target:DebuffRemainsP(S.CorruptionDebuff) <= S.SeedofCorruption:CastTime() + time_to_shard + 4.2 * (1 - num(S.CreepingDeath:IsAvailable()) * 0.15) and EnemiesCount >= 3 + num(S.WritheInAgony:IsAvailable()) and Target:DebuffDownP(S.SeedofCorruptionDebuff) and not S.SeedofCorruption:InFlight()) then
      return S.SeedofCorruption:Cast()
    end
    -- agony,target_if=min:remains,if=talent.creeping_death.enabled&active_dot.agony<6&target.time_to_die>10&(remains<=gcd|cooldown.summon_darkglare.remains>10&(remains<5|!azerite.pandemic_invocation.rank&refreshable))
    if S.Agony:IsCastableP() and S.CreepingDeath:IsAvailable() and S.AgonyDebuff:ActiveDot() < 6 and Target:TimeToDie() > 10 and (Target:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 10 and (Target:DebuffRemainsP(S.AgonyDebuff) < 5 or not bool(S.PandemicInvocation:AzeriteRank()) and Target:DebuffRefreshableCP(S.AgonyDebuff))) then
      return S.Agony:Cast()
    end
    -- agony,target_if=min:remains,if=!talent.creeping_death.enabled&active_dot.agony<8&target.time_to_die>10&(remains<=gcd|cooldown.summon_darkglare.remains>10&(remains<5|!azerite.pandemic_invocation.rank&refreshable))
    if S.Agony:IsCastableP() and not S.CreepingDeath:IsAvailable() and S.AgonyDebuff:ActiveDot() < 8 and Target:TimeToDie() > 10 and (Target:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 10 and (Target:DebuffRemainsP(S.AgonyDebuff) < 5 or not bool(S.PandemicInvocation:AzeriteRank()) and Target:DebuffRefreshableCP(S.AgonyDebuff))) then
      return S.Agony:Cast()
    end
    -- siphon_life,target_if=min:remains,if=(active_dot.siphon_life<8-talent.creeping_death.enabled-spell_targets.sow_the_seeds_aoe)&target.time_to_die>10&refreshable&(!remains&spell_targets.seed_of_corruption_aoe=1|cooldown.summon_darkglare.remains>soul_shard*action.unstable_affliction.execute_time)
    if S.SiphonLife:IsCastableP() and (S.SiphonLifeDebuff:ActiveDot() < 8 - num(S.CreepingDeath:IsAvailable()) - EnemiesCount) and Target:TimeToDie() > 10 and Target:DebuffRefreshableCP(S.SiphonLifeDebuff) and (not bool(Target:DebuffRemainsP(S.SiphonLifeDebuff)) and EnemiesCount == 1 or S.SummonDarkglare:CooldownRemainsP() > Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) then
      return S.SiphonLife:Cast()
    end
    -- corruption,cycle_targets=1,if=!prevgcd.corruption&refreshable&target.time_to_die<=5
    if S.Corruption:IsCastableP() and S.AbsoluteCorruption:IsAvailable() and not Player:PrevGCDP(1, S.Corruption) and not Target:Debuff(S.CorruptionDebuff) and HL.CombatTime() <= 5 then
        return S.Corruption:Cast()
    end	
    -- corruption,cycle_targets=1,if=spell_targets.seed_of_corruption_aoe<3+raid_event.invulnerable.up+talent.writhe_in_agony.enabled&(remains<=gcd|cooldown.summon_darkglare.remains>10&refreshable)&target.time_to_die>10
    if S.Corruption:IsCastableP() and active_enemies() < 3 and Target:DebuffRemainsP(S.CorruptionDebuff) <= Player:GCD() and not S.AbsoluteCorruption:IsAvailable() and Target:DebuffRefreshableCP(S.CorruptionDebuff) then
      return S.Corruption:Cast()
    end
  end
  
  Fillers = function()
    -- unstable_affliction,line_cd=15,if=cooldown.deathbolt.remains<=gcd*2&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&cooldown.summon_darkglare.remains>20
    if S.UnstableAffliction:IsReadyP() and (S.Deathbolt:CooldownRemainsP() <= Player:GCD() * 2 and EnemiesCount == 1 and S.SummonDarkglare:CooldownRemainsP() > 20) then
      return S.UnstableAffliction:Cast()
    end
    -- call_action_list,name=db_refresh,if=talent.deathbolt.enabled&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&(dot.agony.remains<dot.agony.duration*0.75|dot.corruption.remains<dot.corruption.duration*0.75|dot.siphon_life.remains<dot.siphon_life.duration*0.75)&cooldown.deathbolt.remains<=action.agony.gcd*4&cooldown.summon_darkglare.remains>20
    if (S.Deathbolt:IsAvailable() and EnemiesCount == 1 and (Target:DebuffRemainsP(S.AgonyDebuff) < S.AgonyDebuff:BaseDuration() * 0.75 or Target:DebuffRemainsP(S.CorruptionDebuff) < S.CorruptionDebuff:BaseDuration() * 0.75 or Target:DebuffRemainsP(S.SiphonLifeDebuff) < S.SiphonLifeDebuff:BaseDuration() * 0.75) and S.Deathbolt:CooldownRemainsP() <= S.Agony:GCD() * 4 and S.SummonDarkglare:CooldownRemainsP() > 20) then
      local ShouldReturn = DbRefresh(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=db_refresh,if=talent.deathbolt.enabled&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&cooldown.summon_darkglare.remains<=soul_shard*action.agony.gcd+action.agony.gcd*3&(dot.agony.remains<dot.agony.duration*1|dot.corruption.remains<dot.corruption.duration*1|dot.siphon_life.remains<dot.siphon_life.duration*1)
    if (S.Deathbolt:IsAvailable() and EnemiesCount == 1 and S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.Agony:GCD() + S.Agony:GCD() * 3 and (Target:DebuffRemainsP(S.AgonyDebuff) < S.AgonyDebuff:BaseDuration() * 1 or Target:DebuffRemainsP(S.CorruptionDebuff) < S.CorruptionDebuff:BaseDuration() * 1 or Target:DebuffRemainsP(S.SiphonLifeDebuff) < S.SiphonLifeDebuff:BaseDuration() * 1)) then
      local ShouldReturn = DbRefresh(); if ShouldReturn then return ShouldReturn; end
    end
    -- deathbolt,if=cooldown.summon_darkglare.remains>=30+gcd|cooldown.summon_darkglare.remains>140
    if S.Deathbolt:IsCastableP() and (S.SummonDarkglare:CooldownRemainsP() >= 30 + Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 140) then
      return S.Deathbolt:Cast()
    end
    -- shadow_bolt,if=buff.movement.up&buff.nightfall.remains
    if S.ShadowBolt:IsCastableP() and (Player:IsMoving() and bool(Player:BuffRemainsP(S.NightfallBuff))) then
      return S.ShadowBolt:Cast()
    end
    -- agony,if=buff.movement.up&!(talent.siphon_life.enabled&(prev_gcd.1.agony&prev_gcd.2.agony&prev_gcd.3.agony)|prev_gcd.1.agony)
    if S.Agony:IsCastableP() and (Player:IsMoving() and not (S.SiphonLife:IsAvailable() and (Player:PrevGCDP(1, S.Agony) and Player:PrevGCDP(2, S.Agony) and Player:PrevGCDP(3, S.Agony)) or Player:PrevGCDP(1, S.Agony))) then
      return S.Agony:Cast()
    end
    -- siphon_life,if=buff.movement.up&!(prev_gcd.1.siphon_life&prev_gcd.2.siphon_life&prev_gcd.3.siphon_life)
    if S.SiphonLife:IsCastableP() and (Player:IsMoving() and not (Player:PrevGCDP(1, S.SiphonLife) and Player:PrevGCDP(2, S.SiphonLife) and Player:PrevGCDP(3, S.SiphonLife))) then
      return S.SiphonLife:Cast()
    end
    -- corruption,if=buff.movement.up&!prev_gcd.1.corruption&!talent.absolute_corruption.enabled
    if S.Corruption:IsCastableP() and not Target:DebuffP(S.CorruptionDebuff) and Player:IsMoving() and not Player:PrevGCDP(1, S.Corruption) and not S.AbsoluteCorruption:IsAvailable() then
      return S.Corruption:Cast()
    end
    --  drain_life,if=buff.inevitable_demise.stack>10&target.time_to_die<=10
    if S.DrainLife:IsCastableP() and (Player:BuffStackP(S.InevitableDemiseBuff) > 10 and Target:TimeToDie() <= 10) then
      return S.DrainLife:Cast()
    end
    -- drain_life,if=talent.siphon_life.enabled&buff.inevitable_demise.stack>=50-20*(spell_targets.seed_of_corruption_aoe-raid_event.invulnerable.up>=2)&dot.agony.remains>5*spell_haste&dot.corruption.remains>gcd&(dot.siphon_life.remains>gcd|!talent.siphon_life.enabled)&(debuff.haunt.remains>5*spell_haste|!talent.haunt.enabled)&contagion>5*spell_haste
    if S.DrainLife:IsCastableP() and (S.SiphonLife:IsAvailable() and Player:BuffStackP(S.InevitableDemiseBuff) >= 50 - 20 * num(EnemiesCount >= 2) and Target:DebuffRemainsP(S.AgonyDebuff) > 5 * Player:SpellHaste() and Target:DebuffRemainsP(S.CorruptionDebuff) > Player:GCD() and (Target:DebuffRemainsP(S.SiphonLifeDebuff) > Player:GCD() or not S.SiphonLife:IsAvailable()) and (Target:DebuffRemainsP(S.HauntDebuff) > 5 * Player:SpellHaste() or not S.Haunt:IsAvailable()) and contagion > 5 * Player:SpellHaste()) then
      return S.DrainLife:Cast()
    end
    -- drain_life,if=talent.writhe_in_agony.enabled&buff.inevitable_demise.stack>=50-20*(spell_targets.seed_of_corruption_aoe-raid_event.invulnerable.up>=3)-5*(spell_targets.seed_of_corruption_aoe-raid_event.invulnerable.up=2)&dot.agony.remains>5*spell_haste&dot.corruption.remains>gcd&(debuff.haunt.remains>5*spell_haste|!talent.haunt.enabled)&contagion>5*spell_haste
    if S.DrainLife:IsCastableP() and (S.WritheInAgony:IsAvailable() and Player:BuffStackP(S.InevitableDemiseBuff) >= 50 - 20 * num(EnemiesCount >= 3) - 5 * num(EnemiesCount == 2) and Target:DebuffRemainsP(S.AgonyDebuff) > 5 * Player:SpellHaste() and Target.DebuffRemainsP(S.CorruptionDebuff) > Player:GCD() and (Target:DebuffRemainsP(S.HauntDebuff) > 5 * Player:SpellHaste() or not S.Haunt:IsAvailable()) and contagion > 5 * Player:SpellHaste()) then
      return S.DrainLife:Cast()
    end
    -- drain_life,if=talent.absolute_corruption.enabled&buff.inevitable_demise.stack>=50-20*(spell_targets.seed_of_corruption_aoe-raid_event.invulnerable.up>=4)&dot.agony.remains>5*spell_haste&(debuff.haunt.remains>5*spell_haste|!talent.haunt.enabled)&contagion>5*spell_haste
    if S.DrainLife:IsCastableP() and (S.AbsoluteCorruption:IsAvailable() and Player:BuffStackP(S.InevitableDemiseBuff) >= 50 - 20 * num(EnemiesCount >= 4) and Target:DebuffRemainsP(S.AgonyDebuff) > 5 * Player:SpellHaste() and (Target:DebuffRemainsP(S.HauntDebuff) > 5 * Player:SpellHaste() or not S.Haunt:IsAvailable()) and contagion > 5 * Player:SpellHaste()) then
      return S.DrainLife:Cast()
    end
    -- haunt
    if S.Haunt:IsCastableP() and not Player:IsMoving() then
      return S.Haunt:Cast()
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
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
    -- drain_soul,interrupt_global=1,chain=1,interrupt=1,cycle_targets=1,if=target.time_to_die<=gcd
    if S.DrainSoul:IsCastableP() and Target:TimeToDie() <= Player:GCD() then
      return S.DrainSoul:Cast()
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,chain=1,interrupt_if=ticks_remain<5,interrupt_global=1,if=talent.shadow_embrace.enabled&variable.maintain_se&!debuff.shadow_embrace.remains
    if S.DrainSoul:IsCastableP() and S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe) and not bool(Target:DebuffRemainsP(S.ShadowEmbraceDebuff)) then
      return S.DrainSoul:Cast()
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,chain=1,interrupt_if=ticks_remain<5,interrupt_global=1,if=talent.shadow_embrace.enabled&variable.maintain_se
    if S.DrainSoul:IsCastableP() and S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe) then
      return S.DrainSoul:Cast()
    end
    -- drain_soul,interrupt_global=1,chain=1,interrupt=1
    if S.DrainSoul:IsCastableP() then
      return S.DrainSoul:Cast()
    end
    -- shadow_bolt,cycle_targets=1,if=talent.shadow_embrace.enabled&variable.maintain_se&!debuff.shadow_embrace.remains&!action.shadow_bolt.in_flight
    if S.ShadowBolt:IsCastableP() and S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe) and not bool(Target:DebuffRemainsP(S.ShadowEmbraceDebuff)) and not S.ShadowBolt:InFlight() then
      return S.ShadowBolt:Cast()
    end
    -- shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&variable.maintain_se
    if S.ShadowBolt:IsCastableP() and S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe) then
      return S.ShadowBolt:Cast()
    end
    -- shadow_bolt
    if S.ShadowBolt:IsCastableP() then
      return S.ShadowBolt:Cast()
    end
  end
  
  Spenders = function()
    -- unstable_affliction,if=cooldown.summon_darkglare.remains<=soul_shard*(execute_time+azerite.dreadful_calling.rank)&(!talent.deathbolt.enabled|cooldown.deathbolt.remains<=soul_shard*execute_time)
    if S.UnstableAffliction:IsReadyP() and (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * (S.UnstableAffliction:ExecuteTime() + S.DreadfulCalling:AzeriteRank()) and (not S.Deathbolt:IsAvailable() or S.Deathbolt:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime())) then
      return S.UnstableAffliction:Cast()
    end
    -- call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<time_to_shard*(6-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
    if ((S.SummonDarkglare:CooldownRemainsP() < time_to_shard * (6 - Player:SoulShardsP()) or S.SummonDarkglare:CooldownUpP()) and Target:TimeToDie() > S.SummonDarkglare:CooldownRemainsP()) then
      local ShouldReturn = Fillers(); if ShouldReturn then return ShouldReturn; end
    end
    -- seed_of_corruption,if=variable.use_seed
    if S.SeedofCorruption:IsCastableP() and Player:SoulShardsP() > 0 and (bool(VarUseSeed)) then
      return S.SeedofCorruption:Cast()
    end
    -- unstable_affliction,if=!variable.use_seed&!prev_gcd.1.summon_darkglare&(talent.deathbolt.enabled&cooldown.deathbolt.remains<=execute_time&!azerite.cascading_calamity.enabled|(soul_shard>=5&spell_targets.seed_of_corruption_aoe<2|soul_shard>=2&spell_targets.seed_of_corruption_aoe>=2)&target.time_to_die>4+execute_time&spell_targets.seed_of_corruption_aoe=1|target.time_to_die<=8+execute_time*soul_shard)
    if S.UnstableAffliction:IsReadyP() and (not bool(VarUseSeed) and not Player:PrevGCDP(1, S.SummonDarkglare) and (S.Deathbolt:IsAvailable() and S.Deathbolt:CooldownRemainsP() <= S.UnstableAffliction:ExecuteTime() and not S.CascadingCalamity:AzeriteEnabled() or (Player:SoulShardsP() >= 5 and EnemiesCount < 2 or Player:SoulShardsP() >= 2 and EnemiesCount >= 2) and Target:TimeToDie() > 4 + S.UnstableAffliction:ExecuteTime() and EnemiesCount == 1 or Target:TimeToDie() <= 8 + S.UnstableAffliction:ExecuteTime() * Player:SoulShardsP())) then
      return S.UnstableAffliction:Cast()
    end
    -- unstable_affliction,if=!variable.use_seed&contagion<=cast_time+variable.padding
    if S.UnstableAffliction:IsReadyP() and (not bool(VarUseSeed) and contagion <= S.UnstableAffliction:CastTime() + VarPadding) then
      return S.UnstableAffliction:Cast()
    end
    -- unstable_affliction,cycle_targets=1,if=!variable.use_seed&(!talent.deathbolt.enabled|cooldown.deathbolt.remains>time_to_shard|soul_shard>1)&(!talent.vile_taint.enabled|soul_shard>1)&contagion<=cast_time+variable.padding&(!azerite.cascading_calamity.enabled|buff.cascading_calamity.remains>time_to_shard)
    if S.UnstableAffliction:IsReadyP() and not bool(VarUseSeed) and (not S.Deathbolt:IsAvailable() or S.Deathbolt:CooldownRemainsP() > time_to_shard or Player:SoulShardsP() > 1) and (not S.VileTaint:IsAvailable() or Player:SoulShardsP() > 1) and contagion <= S.UnstableAffliction:CastTime() + VarPadding and (not S.CascadingCalamity:AzeriteEnabled() or Player:BuffRemainsP(S.CascadingCalamityBuff) > time_to_shard) then
      return S.UnstableAffliction:Cast()
    end
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
  
  -- Protect against interrupt of channeled spells
  if (Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2)) or Player:IsChanneling() then
      return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
  end 
  
  -- Combat
  if RubimRH.TargetIsValid() then
  
    -- Queue system
    if QueueSkill() ~= nil then
        return QueueSkill()
    end
	
	-- corruption,cycle_targets=1,if=!prevgcd.corruption&refreshable&target.time_to_die<=5
    if S.Corruption:IsCastableP() and not Target:Debuff(S.CorruptionDebuff) then
        return S.Corruption:Cast()
    end	
    
    -- Auto multidot
    if RubimRH.AoEON() and RubimRH.AffliAutoAoEON() and Target:DebuffRemainsP(S.AgonyDebuff) >= S.Agony:BaseDuration() * 0.90 and not Player:IsChanneling() and active_enemies() >= 2 and active_enemies() < 7 and CombatTime("player") > 0 and 
( -- Agony
    not IsSpellInRange(980, "target") or   
    (
        CombatTime("target") == 0 and
        not Player:InPvP()
    ) 
) and
(
    -- Corruption
    MultiDots(40, S.Corruption, 10, 1) >= 1 or MultiDots(40, S.Agony, 10, 1) >= 1 or
    (
        CombatTime("target") == 0 and
        not Player:InPvP()
    ) 
) then 
      return 133015 
   end

    -- unending resolve,defensive,player.health<=40
    if S.UnendingResolve:IsCastableP() and Player:HealthPercentage() <= mainAddon.db.profile[265].sk1 then
        return S.UnendingResolve:Cast()
    end  
    -- Mythic+ - interrupt2 (command demon)
    if S.SpellLock:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\wl_lock_red.tga"
    end
    -- Mythic+ - Shadowfury aoe stun test
    if S.Shadowfury:IsCastableP() and not Player:IsMoving() and RubimRH.InterruptsON() and active_enemies() >= 2 and Target:IsInterruptible() then
        return S.Shadowfury:Cast()
    end      
    -- variable,name=use_seed,value=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>=3+raid_event.invulnerable.up|talent.siphon_life.enabled&spell_targets.seed_of_corruption>=5+raid_event.invulnerable.up|spell_targets.seed_of_corruption>=8+raid_event.invulnerable.up
    if (true) then
      VarUseSeed = num(S.SowtheSeeds:IsAvailable() and EnemiesCount >= 3 or S.SiphonLife:IsAvailable() and EnemiesCount >= 5 or EnemiesCount >= 8)
    end
    -- variable,name=padding,op=set,value=action.shadow_bolt.execute_time*azerite.cascading_calamity.enabled
    if (true) then
      VarPadding = S.ShadowBolt:ExecuteTime() * num(S.CascadingCalamity:AzeriteEnabled())
    end
    -- variable,name=padding,op=reset,value=gcd,if=azerite.cascading_calamity.enabled&(talent.drain_soul.enabled|talent.deathbolt.enabled&cooldown.deathbolt.remains<=gcd)
    if (S.CascadingCalamity:AzeriteEnabled() and (S.DrainSoul:IsAvailable() or S.Deathbolt:IsAvailable() and S.Deathbolt:CooldownRemainsP() <= Player:GCD())) then
      VarPadding = 0
    end
    -- variable,name=maintain_se,value=spell_targets.seed_of_corruption_aoe<=1+talent.writhe_in_agony.enabled+talent.absolute_corruption.enabled*2+(talent.writhe_in_agony.enabled&talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>2)+(talent.siphon_life.enabled&!talent.creeping_death.enabled&!talent.drain_soul.enabled)+raid_event.invulnerable.up
    if (true) then
      VarMaintainSe = num(EnemiesCount <= 1 + num(S.WritheInAgony:IsAvailable()) + num(S.AbsoluteCorruption:IsAvailable()) * 2 + num((S.WritheInAgony:IsAvailable() and S.SowtheSeeds:IsAvailable() and EnemiesCount > 2)) + num((S.SiphonLife:IsAvailable() and not S.CreepingDeath:IsAvailable() and not S.DrainSoul:IsAvailable())))
    end
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- drain_soul,interrupt_global=1,chain=1,cycle_targets=1,if=target.time_to_die<=gcd&soul_shard<5
    if S.DrainSoul:IsCastableP() and Target:TimeToDie() <= Player:GCD() and Player:SoulShardsP() < 5 then
      return S.DrainSoul:Cast()
    end
    -- haunt,if=spell_targets.seed_of_corruption_aoe<=2+raid_event.invulnerable.up
    if S.Haunt:IsCastableP() and not Player:IsMoving() and (EnemiesCount <= 2) then
      return S.Haunt:Cast()
    end
    -- summon_darkglare,if=dot.agony.ticking&dot.corruption.ticking&(buff.active_uas.stack=5|soul_shard=0)&(!talent.phantom_singularity.enabled|dot.phantom_singularity.remains)&(!talent.deathbolt.enabled|cooldown.deathbolt.remains<=gcd|!cooldown.deathbolt.remains|spell_targets.seed_of_corruption_aoe>1+raid_event.invulnerable.up)
    if S.SummonDarkglare:IsCastableP() and RubimRH.CDsON() and Target:DebuffP(S.AgonyDebuff) and (Target:DebuffP(S.CorruptionDebuff) or S.AbsoluteCorruption:IsAvailable()) and (ActiveUAs() == 5 or Player:SoulShardsP() == 0) and (not S.PhantomSingularity:IsAvailable() or Target:DebuffP(S.PhantomSingularityDebuff)) and (not S.Deathbolt:IsAvailable() or S.Deathbolt:CooldownRemainsP() <= Player:GCD() or S.Deathbolt:CooldownUpP() or EnemiesCount > 1) then
      return S.SummonDarkglare:Cast()
    end
    -- deathbolt,if=cooldown.summon_darkglare.remains&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&(!essence.vision_of_perfection.minor&!azerite.dreadful_calling.rank|cooldown.summon_darkglare.remains>30)
    if S.Deathbolt:IsCastableP() and (bool(S.SummonDarkglare:CooldownRemainsP()) and EnemiesCount == 1 and (not S.VisionOfPerfectionMinor:IsAvailable() and not bool(S.DreadfulCalling:AzeriteRank()) or S.SummonDarkglare:CooldownRemainsP() > 30)) then
      return S.Deathbolt:Cast()
    end
    -- the_unbound_force,if=buff.reckless_force.remains
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForce)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- agony,target_if=min:dot.agony.remains,if=remains<=gcd+action.shadow_bolt.execute_time&target.time_to_die>8
    if S.Agony:IsCastableP() and Target:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() + S.ShadowBolt:ExecuteTime() and Target:TimeToDie() > 8 then
      return S.Agony:Cast()
    end
    -- memory_of_lucid_dreams,if=time<30
    if S.MemoryOfLucidDreams:IsCastableP() and (HL.CombatTime() < 30) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- use_item,name=azsharas_font_of_power,if=cooldown.summon_darkglare.remains<10
    if I.AzsharasFontofPower:IsReady() and (S.SummonDarkglare:CooldownRemainsP() < 10) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- unstable_affliction,target_if=!contagion&target.time_to_die<=8
    if S.UnstableAffliction:IsReadyP() and not bool(contagion) and Target:TimeToDie() <= 8 then
      return S.UnstableAffliction:Cast()
    end
    -- drain_soul,target_if=min:debuff.shadow_embrace.remains,cancel_if=ticks_remain<5,if=talent.shadow_embrace.enabled&variable.maintain_se&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=gcd*2
    if S.DrainSoul:IsCastableP() and S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe) and bool(Target:DebuffRemainsP(S.ShadowEmbraceDebuff)) and Target:DebuffRemainsP(S.ShadowEmbraceDebuff) <= Player:GCD() * 2 then
      return S.DrainSoul:Cast()
    end
    -- shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&variable.maintain_se&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=execute_time*2+travel_time&!action.shadow_bolt.in_flight
    if S.ShadowBolt:IsCastableP() and S.ShadowEmbrace:IsAvailable() and bool(VarMaintainSe) and bool(Target:DebuffRemainsP(S.ShadowEmbraceDebuff)) and Target:DebuffRemainsP(S.ShadowEmbraceDebuff) <= S.ShadowBolt:ExecuteTime() * 2 + S.ShadowBolt:TravelTime() and not S.ShadowBolt:InFlight() then
      return S.ShadowBolt:Cast()
    end
    -- phantom_singularity,target_if=max:target.time_to_die,if=time>35&target.time_to_die>16*spell_haste&(!essence.vision_of_perfection.minor&!azerite.dreadful_calling.rank|cooldown.summon_darkglare.remains>45|cooldown.summon_darkglare.remains<15*spell_haste)
    if S.PhantomSingularity:IsCastableP() and HL.CombatTime() > 35 and Target:TimeToDie() > 16 * Player:SpellHaste() and (not S.VisionOfPerfectionMinor:IsAvailable() and not bool(S.DreadfulCalling:AzeriteRank()) or S.SummonDarkglare:CooldownRemainsP() > 45 or S.SummonDarkglare:CooldownRemainsP() < 15 * Player:SpellHaste()) then
      return S.PhantomSingularity:Cast()
    end
    -- unstable_affliction,target_if=min:contagion,if=!variable.use_seed&soul_shard=5
    if S.UnstableAffliction:IsReadyP() and not bool(VarUseSeed) and Player:SoulShardsP() == 5 then
      return S.UnstableAffliction:Cast()
    end
    -- seed_of_corruption,if=variable.use_seed&soul_shard=5
    if S.SeedofCorruption:IsCastableP() and (bool(VarUseSeed) and Player:SoulShardsP() == 5) then
      return S.SeedofCorruption:Cast()
    end
    -- call_action_list,name=dots
    if (true) then
      local ShouldReturn = Dots(); if ShouldReturn then return ShouldReturn; end
    end
    -- vile_taint,target_if=max:target.time_to_die,if=time>15&target.time_to_die>=10&(cooldown.summon_darkglare.remains>30|cooldown.summon_darkglare.remains<10&dot.agony.remains>=10&dot.corruption.remains>=10&(dot.siphon_life.remains>=10|!talent.siphon_life.enabled))
    if S.VileTaint:IsCastableP() and HL.CombatTime() > 15 and Target:TimeToDie() >= 10 and (S.SummonDarkglare:CooldownRemainsP() > 30 or S.SummonDarkglare:CooldownRemainsP() < 10 and Target:DebuffRemainsP(S.CorruptionDebuff) >= 10 and (Target:DebuffRemainsP(S.SiphonLifeDebuff) >= 10 or not S.SiphonLife:IsAvailable())) then
      return S.VileTaint:Cast()
    end
    -- use_item,name=azsharas_font_of_power,if=time<=3
    if I.AzsharasFontofPower:IsReady() and (HL.CombatTime() <= 3) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- phantom_singularity,if=time<=35
    if S.PhantomSingularity:IsCastableP() and (HL.CombatTime() <= 35) then
      return S.PhantomSingularity:Cast()
    end
    -- vile_taint,if=time<15
    if S.VileTaint:IsCastableP() and (HL.CombatTime() < 15) then
      return S.VileTaint:Cast()
    end
    -- guardian_of_azeroth,if=cooldown.summon_darkglare.remains<15+soul_shard*azerite.dreadful_calling.enabled|(azerite.dreadful_calling.rank|essence.vision_of_perfection.rank)&time>30&target.time_to_die>=210)&(dot.phantom_singularity.remains|dot.vile_taint.remains|!talent.phantom_singularity.enabled&!talent.vile_taint.enabled)|target.time_to_die<30+gcd
    if S.GuardianOfAzeroth:IsCastableP() and (S.SummonDarkglare:CooldownRemainsP() < 15 + Player:SoulShardsP() * num(S.DreadfulCalling:AzeriteEnabled()) or ((S.DreadfulCalling:AzeriteEnabled() or S.VisionofPerfectionMinor:IsAvailable()) and HL.CombatTime() > 30 and Target:TimeToDie() >= 210) and (Target:DebuffP(S.PhantomSingularityDebuff) or Target:DebuffP(S.VileTaint) or not S.PhantomSingularity:IsAvailable() and not S.VileTaint:IsAvailable()) or Target:TimeToDie() < 30 + Player:GCD()) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- dark_soul,if=cooldown.summon_darkglare.remains<15+soul_shard*azerite.dreadful_calling.enabled&(dot.phantom_singularity.remains|dot.vile_taint.remains|!talent.phantom_singularity.enabled&!talent.vile_taint.enabled)|target.time_to_die<20+gcd|spell_targets.seed_of_corruption_aoe>1+raid_event.invulnerable.up
    if S.DarkSoul:IsCastableP() and RubimRH.CDsON() and (S.SummonDarkglare:CooldownRemainsP() < 15 + Player:SoulShardsP() * num(S.DreadfulCalling:AzeriteEnabled()) and (Target:DebuffP(S.PhantomSingularityDebuff) or Target:DebuffP(S.PhantomSingularityDebuff) or not S.PhantomSingularity:IsAvailable() and not S.VileTaint:IsAvailable()) or Target:TimeToDie() < 20 + Player:GCD() or EnemiesCount > 1) then
      return S.DarkSoul:Cast()
    end
    -- berserking
    if S.Berserking:IsCastableP() and RubimRH.CDsON() then
      return S.Berserking:Cast()
    end
    -- call_action_list,name=spenders
    if (true) then
      local ShouldReturn = Spenders(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=fillers
    if (true) then
      local ShouldReturn = Fillers(); if ShouldReturn then return ShouldReturn; end
    end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(265, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(265, PASSIVE)