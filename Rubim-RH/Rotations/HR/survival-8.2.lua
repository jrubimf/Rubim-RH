--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Pet = Unit.Pet;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
-- Spells

--Survival
RubimRH.Spell[255] = {
  SummonPet                             = Spell(883),
  SteelTrapDebuff                       = Spell(162487),
  SteelTrap                             = Spell(162488),
  Harpoon                               = Spell(190925),
  MongooseBite                          = Spell(259387),
  MongooseBiteEagle                     = Spell(265888),
  --MongooseBite                        = MultiSpell(259387, 265888),
  CoordinatedAssaultBuff                = Spell(266779),
  BlurofTalonsBuff                      = Spell(277969),
  RaptorStrikeEagle                     = Spell(265189),
  RaptorStrike                          = Spell(186270),
  --RaptorStrike                        = MultiSpell(186270, 265189),
  FlankingStrike                        = Spell(269751),
  KillCommand                           = Spell(259489),
  CounterShot                           = Spell(147362),
  --WildfireBomb                        = MultiSpell(259495, 270335, 270323, 271045),
  WildfireBomb                          = Spell(259495),
  WildfireBombDebuff                    = Spell(269747),
  ShrapnelBomb                          = Spell(270335),
  PheromoneBomb                         = Spell(270323),
  VolatileBomb                          = Spell(271045),
  SerpentSting                          = Spell(259491),
  SerpentStingDebuff                    = Spell(259491),
  MongooseFuryBuff                      = Spell(259388),
  AMurderofCrows                        = Spell(131894),
  CoordinatedAssault                    = Spell(266779),
  TipoftheSpearBuff                     = Spell(260286),
  ShrapnelBombDebuff                    = Spell(270339),
  Chakrams                              = Spell(259391),
  BloodFury                             = Spell(20572),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  Berserking                            = Spell(26297),
  BerserkingBuff                        = Spell(26297),
  BloodFuryBuff                         = Spell(20572),
  AspectoftheEagle                      = Spell(186289),
  Exhilaration                          = Spell(109304),
  RecklessForceBuff                     = Spell(302932),
  ConcentratedFlameBurn                 = Spell(295368),
  Carve                                 = Spell(187708),
  GuerrillaTactics                      = Spell(264332),
  LatentPoisonDebuff                    = Spell(273286),
  BloodseekerDebuff                     = Spell(259277),
  Butchery                              = Spell(212436),
  WildfireInfusion                      = Spell(271014),
  InternalBleedingDebuff                = Spell(270343),
  VipersVenomBuff                       = Spell(268552),
  TermsofEngagement                     = Spell(265895),
  VipersVenom                           = Spell(268501),
  AlphaPredator                         = Spell(269737),
  ArcaneTorrent                         = Spell(50613),
  RazorCoralDebuff                      = Spell(303568),
  CyclotronicBlast                      = Spell(167672),
  -- Pet
  CallPet                               = Spell(883),
  Intimidation                          = Spell(19577),
  MendPet                               = Spell(136),
  RevivePet                             = Spell(982),
  -- Defensive
  AspectoftheTurtle                     = Spell(186265),
  Exhilaration                          = Spell(109304),
  -- Utility
  FreezingTrap                          = Spell(187650),
  AspectoftheEagle                      = Spell(186289),
  Muzzle                                = Spell(187707),
  -- PvP
  WingClip                              = Spell(195645),
  LatentPoison                          = Spell(273284),
  LatentPoisonDebuff                    = Spell(273286),
  HydrasBite                            = Spell(260241),
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

local S = RubimRH.Spell[255]
-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Survival = {
  PotionofUnbridledFury            = Item(169299),
  AshvanesRazorCoral               = Item(169311),
  PocketsizedComputationDevice     = Item(167555),
  GalecallersBoon                  = Item(159614)
};
local I = Item.Hunter.Survival;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

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
  --Hunter Specific
  S.RaptorStrike = S.RaptorStrikeEagle:IsAvailable() and S.RaptorStrikeEagle or S.RaptorStrike
  S.MongooseBite = S.MongooseBiteEagle:IsAvailable() and S.MongooseBiteEagle or S.MongooseBite
end

S.MongooseBite.TextureSpellID = { 224795 } -- Raptor Strikes
S.Butchery.TextureSpellID = { 203673 } -- Carve
S.ShrapnelBomb.TextureSpellID = { 269747 }
S.PheromoneBomb.TextureSpellID = { 269747 }
S.VolatileBomb.TextureSpellID = { 269747 }
S.WildfireBomb.TextureSpellID = { 269747 }
S.WingClip.TextureSpellID = { 76151 }

local function UpdateWFB()
    if S.ShrapnelBomb:IsReadyMorph() then
        S.WildfireBomb = Spell(270335)
    elseif S.VolatileBomb:IsReadyMorph() then
        S.WildfireBomb = Spell(271045)
    elseif S.PheromoneBomb:IsReadyMorph() then
        S.WildfireBomb = Spell(270323)
    else
        S.WildfireBomb = Spell(259495)
    end
    S.ShrapnelBomb.TextureSpellID = { 269747 }
    S.PheromoneBomb.TextureSpellID = { 269747 }
    S.VolatileBomb.TextureSpellID = { 269747 }
    S.WildfireBomb.TextureSpellID = { 269747 }

end

-- Stuns
local StunInterrupts = {
  {S.Intimidation, "Cast Intimidation (Interrupt)", function () return true; end},
};

-- Variables
local VarCarveCdr = 0;

HL:RegisterForEvent(function()
  VarCarveCdr = 0
end, "PLAYER_REGEN_ENABLED")

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

local function EvaluateTargetIfFilterMongooseBite396(TargetUnit)
  return TargetUnit:DebuffStackP(S.LatentPoisonDebuff)
end

local function EvaluateTargetIfMongooseBite405(TargetUnit)
  return TargetUnit:DebuffStackP(S.LatentPoisonDebuff) == 10
end

local function EvaluateTargetIfFilterKillCommand413(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.BloodseekerDebuff)
end

local function EvaluateTargetIfKillCommand426(TargetUnit)
  return Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax()
end

local function EvaluateTargetIfFilterSerpentSting462(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.SerpentStingDebuff)
end

local function EvaluateTargetIfSerpentSting479(TargetUnit)
  return bool(Player:BuffStackP(S.VipersVenomBuff))
end

local function EvaluateTargetIfFilterSerpentSting497(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.SerpentStingDebuff)
end

local function EvaluateTargetIfSerpentSting520(TargetUnit)
  return TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff) and Player:BuffStackP(S.TipoftheSpearBuff) < 3
end

local function EvaluateTargetIfFilterMongooseBite526(TargetUnit)
  return TargetUnit:DebuffStackP(S.LatentPoisonDebuff)
end

local function EvaluateTargetIfFilterRaptorStrike537(TargetUnit)
  return TargetUnit:DebuffStackP(S.LatentPoisonDebuff)
end

local function cacheOverwrite()
    Cache.Persistent.SpellLearned.Player[S.MendPet.SpellID] = true
end

--HL.RegisterNucleusAbility(187708, 8, 6)                           -- Carve
--HL.RegisterNucleusAbility(212436, 8, 6)                           -- Butchery
--HL.RegisterNucleusAbility({259495, 270335, 270323, 271045}, 8, 6) -- Bombs
--HL.RegisterNucleusAbility(259391, 40, 6)                          -- Chakrams

--- ======= ACTION LISTS =======
local function APL()
  local Precombat_DBM, Precombat, Apst, Apwfi, Cds, Cleave, St, Wfi
  UpdateRanges()
  DetermineEssenceRanks()
  UpdateWFB()
  
    Precombat_DBM = function()
    -- flask
    -- augmentation
    -- food
    -- summon_pet
    if S.SummonPet:IsCastableP() and not Pet:Exists() then
      return S.SummonPet:Cast()
    end
    -- snapshot_stats
    --if RubimRH.TargetIsValid() then
      -- potion
      if I.PotionofUnbridledFury:IsReady() and RubimRH.DBM_PullTimer() >= S.Harpoon:CastTime() + 1 and RubimRH.DBM_PullTimer() <= S.Harpoon:CastTime() + 2 then
         return 967532
      end
      -- steel_trap
      --if S.SteelTrap:IsCastableP() and Player:DebuffDownP(S.SteelTrapDebuff) then
      --  return S.SteelTrap:Cast()
      --end
      -- harpoon
      if S.Harpoon:IsCastableP() and RubimRH.DBM_PullTimer() > 1 and RubimRH.DBM_PullTimer() <= S.Harpoon:CastTime() then
        return S.Harpoon:Cast()
      end
      -- use_item,effect_name=cyclotronic_blast,if=!raid_event.invulnerable.exists
      -- Using main icon, since this is the last item in Precombat
      if I.PocketsizedComputationDevice:IsReady() and S.CyclotronicBlast:IsAvailable() then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
      end
   -- end
  end
  
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- summon_pet
    if S.SummonPet:IsCastableP() and not Pet:Exists() then
      return S.SummonPet:Cast()
    end
    -- snapshot_stats
    --if RubimRH.TargetIsValid() then
      -- potion
      -- steel_trap
      if S.SteelTrap:IsCastableP() and Player:DebuffDownP(S.SteelTrapDebuff) then
        return S.SteelTrap:Cast()
      end
      -- harpoon
      if S.Harpoon:IsCastableP() then
        return S.Harpoon:Cast()
      end
      -- use_item,effect_name=cyclotronic_blast,if=!raid_event.invulnerable.exists
      -- Using main icon, since this is the last item in Precombat
      if I.PocketsizedComputationDevice:IsReady() and S.CyclotronicBlast:IsAvailable() then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
      end
   -- end
  end
  
  Apst = function()
    -- mongoose_bite,if=buff.coordinated_assault.up&(buff.coordinated_assault.remains<1.5*gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<1.5*gcd)
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffRemainsP(S.CoordinatedAssaultBuff) < 1.5 * Player:GCD() or Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < 1.5 * Player:GCD())) then
      return S.MongooseBite:Cast()
    end
    -- raptor_strike,if=buff.coordinated_assault.up&(buff.coordinated_assault.remains<1.5*gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<1.5*gcd)
    if S.RaptorStrike:IsReadyP() and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffRemainsP(S.CoordinatedAssaultBuff) < 1.5 * Player:GCD() or Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < 1.5 * Player:GCD())) then
      return S.RaptorStrike:Cast()
    end
    -- flanking_strike,if=focus+cast_regen<focus.max
    if S.FlankingStrike:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
      return S.FlankingStrike:Cast()
    end
    -- kill_command,if=full_recharge_time<1.5*gcd&focus+cast_regen<focus.max-10
    if S.KillCommand:IsCastableP() and (S.KillCommand:FullRechargeTimeP() < 1.5 * Player:GCD() and Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() - 10) then
      return S.KillCommand:Cast()
    end
    -- steel_trap,if=focus+cast_regen<focus.max
    if S.SteelTrap:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.SteelTrap:ExecuteTime()) < Player:FocusMax()) then
      return S.SteelTrap:Cast()
    end
    -- wildfire_bomb,if=focus+cast_regen<focus.max&!ticking&!buff.memory_of_lucid_dreams.up&(full_recharge_time<1.5*gcd|!dot.wildfire_bomb.ticking&!buff.coordinated_assault.up)
    if S.WildfireBomb:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() and not Target:DebuffP(S.WildfireBombDebuff) and not Player:BuffP(S.MemoryOfLucidDreams) and (S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD() or not Target:DebuffP(S.WildfireBombDebuff) and not Player:BuffP(S.CoordinatedAssaultBuff))) then
      return S.WildfireBomb:Cast()
    end
    -- serpent_sting,if=!dot.serpent_sting.ticking&!buff.coordinated_assault.up
    if S.SerpentSting:IsReadyP() and (not Target:DebuffP(S.SerpentStingDebuff) and not Player:BuffP(S.CoordinatedAssaultBuff)) then
      return S.SerpentSting:Cast()
    end
    -- kill_command,if=focus+cast_regen<focus.max&(buff.mongoose_fury.stack<5|focus<action.mongoose_bite.cost)
    if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and (Player:BuffStackP(S.MongooseFuryBuff) < 5 or Player:Focus() < S.MongooseBite:Cost())) then
      return S.KillCommand:Cast()
    end
    -- serpent_sting,if=refreshable&!buff.coordinated_assault.up&buff.mongoose_fury.stack<5
    if S.SerpentSting:IsReadyP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not Player:BuffP(S.CoordinatedAssaultBuff) and Player:BuffStackP(S.MongooseFuryBuff) < 5) then
      return S.SerpentSting:Cast()
    end
    -- a_murder_of_crows,if=!buff.coordinated_assault.up
    if S.AMurderofCrows:IsCastableP() and (not Player:BuffP(S.CoordinatedAssaultBuff)) then
      return S.AMurderofCrows:Cast()
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() and RubimRH.CDsON() then
      return S.CoordinatedAssault:Cast()
    end
    -- mongoose_bite,if=buff.mongoose_fury.up|focus+cast_regen>focus.max-10|buff.coordinated_assault.up
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() + Player:FocusCastRegen(S.MongooseBite:ExecuteTime()) > Player:FocusMax() - 10 or Player:BuffP(S.CoordinatedAssaultBuff)) then
      return S.MongooseBite:Cast()
    end
    -- raptor_strike
    if S.RaptorStrike:IsReadyP() then
      return S.RaptorStrike:Cast()
    end
    -- wildfire_bomb,if=!ticking
    if S.WildfireBomb:IsCastableP() and (not Target:DebuffP(S.WildfireBombDebuff)) then
      return S.WildfireBomb:Cast()
    end
  end
  
  Apwfi = function()
    -- mongoose_bite,if=buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < Player:GCD()) then
      return S.MongooseBite:Cast()
    end
    -- raptor_strike,if=buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd
    if S.RaptorStrike:IsReadyP() and (Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < Player:GCD()) then
      return S.RaptorStrike:Cast()
    end
    -- serpent_sting,if=!dot.serpent_sting.ticking
    if S.SerpentSting:IsReadyP() and (not Target:DebuffP(S.SerpentStingDebuff)) then
      return S.SerpentSting:Cast()
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      return S.AMurderofCrows:Cast()
    end
    -- wildfire_bomb,if=full_recharge_time<1.5*gcd|focus+cast_regen<focus.max&(next_wi_bomb.volatile&dot.serpent_sting.ticking&dot.serpent_sting.refreshable|next_wi_bomb.pheromone&!buff.mongoose_fury.up&focus+cast_regen<focus.max-action.kill_command.cast_regen*3)
    if S.WildfireBomb:IsCastableP() and (S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD() or Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() and (S.VolatileBomb:IsLearned() and Target:DebuffP(S.SerpentStingDebuff) and Target:DebuffRefreshableCP(S.SerpentStingDebuff) or S.PheromoneBomb:IsLearned() and not Player:BuffP(S.MongooseFuryBuff) and Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() - Player:FocusCastRegen(S.KillCommand:ExecuteTime()) * 3)) then
      return S.WildfireBomb:Cast()
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() and RubimRH.CDsON() then
      return S.CoordinatedAssault:Cast()
    end
    -- mongoose_bite,if=buff.mongoose_fury.remains&next_wi_bomb.pheromone
    if S.MongooseBite:IsReadyP() and (bool(Player:BuffRemainsP(S.MongooseFuryBuff)) and S.PheromoneBomb:IsLearned()) then
      return S.MongooseBite:Cast()
    end
    -- kill_command,if=full_recharge_time<1.5*gcd&focus+cast_regen<focus.max-20
    if S.KillCommand:IsCastableP() and (S.KillCommand:FullRechargeTimeP() < 1.5 * Player:GCD() and Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() - 20) then
      return S.KillCommand:Cast()
    end
    -- steel_trap,if=focus+cast_regen<focus.max
    if S.SteelTrap:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.SteelTrap:ExecuteTime()) < Player:FocusMax()) then
      return S.SteelTrap:Cast()
    end
    -- raptor_strike,if=buff.tip_of_the_spear.stack=3|dot.shrapnel_bomb.ticking
    if S.RaptorStrike:IsReadyP() and (Player:BuffStackP(S.TipoftheSpearBuff) == 3 or Target:DebuffP(S.ShrapnelBombDebuff)) then
      return S.RaptorStrike:Cast()
    end
    -- mongoose_bite,if=dot.shrapnel_bomb.ticking
    if S.MongooseBite:IsReadyP() and (Target:DebuffP(S.ShrapnelBombDebuff)) then
      return S.MongooseBite:Cast()
    end
    -- wildfire_bomb,if=next_wi_bomb.shrapnel&focus>30&dot.serpent_sting.remains>5*gcd
    if S.WildfireBomb:IsCastableP() and (S.ShrapnelBomb:IsLearned() and Player:Focus() > 30 and Target:DebuffRemainsP(S.SerpentStingDebuff) > 5 * Player:GCD()) then
      return S.WildfireBomb:Cast()
    end
    -- chakrams,if=!buff.mongoose_fury.remains
    if S.Chakrams:IsCastableP() and (not bool(Player:BuffRemainsP(S.MongooseFuryBuff))) then
      return S.Chakrams:Cast()
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsReadyP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      return S.SerpentSting:Cast()
    end
    -- kill_command,if=focus+cast_regen<focus.max&(buff.mongoose_fury.stack<5|focus<action.mongoose_bite.cost)
    if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and (Player:BuffStackP(S.MongooseFuryBuff) < 5 or Player:Focus() < S.MongooseBite:Cost())) then
      return S.KillCommand:Cast()
    end
    -- raptor_strike
    if S.RaptorStrike:IsReadyP() then
      return S.RaptorStrike:Cast()
    end
    -- mongoose_bite,if=buff.mongoose_fury.up|focus>40|dot.shrapnel_bomb.ticking
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 40 or Target:DebuffP(S.ShrapnelBombDebuff)) then
      return S.MongooseBite:Cast()
    end
    -- wildfire_bomb,if=next_wi_bomb.volatile&dot.serpent_sting.ticking|next_wi_bomb.pheromone|next_wi_bomb.shrapnel&focus>50
    if S.WildfireBomb:IsCastableP() and (S.VolatileBomb:IsLearned() and Target:DebuffP(S.SerpentStingDebuff) or S.PheromoneBomb:IsLearned() or S.ShrapnelBomb:IsLearned() and Player:Focus() > 50) then
      return S.WildfireBomb:Cast()
    end
  end
  
  Cds = function()
    -- blood_fury,if=cooldown.coordinated_assault.remains>30
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
      return S.BloodFury:Cast()
    end
    -- ancestral_call,if=cooldown.coordinated_assault.remains>30
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
      return S.AncestralCall:Cast()
    end
    -- fireblood,if=cooldown.coordinated_assault.remains>30
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
      return S.Fireblood:Cast()
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() then
      return S.LightsJudgment:Cast()
    end
    -- berserking,if=cooldown.coordinated_assault.remains>60|time_to_die<13
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 60 or Target:TimeToDie() < 13) then
      return S.Berserking:Cast()
    end
    -- potion,if=buff.coordinated_assault.up&(buff.berserking.up|buff.blood_fury.up|!race.troll&!race.orc)|(consumable.potion_of_unbridled_fury&target.time_to_die<61|target.time_to_die<26)
    if I.PotionofUnbridledFury:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffP(S.BerserkingBuff) or Player:BuffP(S.BloodFuryBuff) or not Player:IsRace("Troll") and not Player:IsRace("Orc")) or Target:TimeToDie() < 61) then
      return 967532
    end
    -- aspect_of_the_eagle,if=target.distance>=6
    if S.AspectoftheEagle:IsCastableP() and RubimRH.CDsON() and (not Target:IsInRange(8) and Target:IsInRange(40)) then
      return S.AspectoftheEagle:Cast()
    end
    -- use_item,name=ashvanes_razor_coral,if=buff.memory_of_lucid_dreams.up|buff.guardian_of_azeroth.up|debuff.razor_coral_debuff.down|target.time_to_die<20
    if I.AshvanesRazorCoral:IsReady() and (Player:BuffP(S.MemoryOfLucidDreams) or Player:BuffP(S.GuardianOfAzeroth) or Target:DebuffDownP(S.RazorCoralDebuff) or Target:TimeToDie() < 20) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_item,name=galecallers_boon,if=cooldown.memory_of_lucid_dreams.remains|talent.wildfire_infusion.enabled&cooldown.coordinated_assault.remains|cooldown.cyclotronic_blast.remains|!essence.memory_of_lucid_dreams.major&!talent.wildfire_infusion.enabled
    if I.GalecallersBoon:IsReady() and (bool(S.MemoryOfLucidDreams:CooldownRemainsP()) or S.WildfireInfusion:IsAvailable() and bool(S.CoordinatedAssault:CooldownRemainsP()) or bool(S.CyclotronicBlast:CooldownRemainsP()) or not S.MemoryOfLucidDreams:IsAvailable() and not S.WildfireInfusion:IsAvailable()) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams,if=focus<focus.max-30&buff.coordinated_assault.up
    if S.MemoryOfLucidDreams:IsCastableP() and (Player:FocusDeficit() > 30 and Player:BuffP(S.CoordinatedAssaultBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- blood_of_the_enemy,if=buff.coordinated_assault.up
    if S.BloodOfTheEnemy:IsCastableP() and (Player:BuffP(S.CoordinatedAssaultBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth
    if S.GuardianOfAzeroth:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame,if=full_recharge_time<1*gcd
    if S.ConcentratedFlame:IsCastableP() and (S.ConcentratedFlame:FullRechargeTimeP() < 1 * Player:GCD()) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force,if=buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
  end
  
  Cleave = function()
    -- variable,name=carve_cdr,op=setif,value=active_enemies,value_else=5,condition=active_enemies<5
    VarCarveCdr = math.min(Cache.EnemiesCount[8], 5)
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      return S.AMurderofCrows:Cast()
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() and RubimRH.CDsON() then
      return S.CoordinatedAssault:Cast()
    end
    -- carve,if=dot.shrapnel_bomb.ticking
    if S.Carve:IsReadyP() and (Target:DebuffP(S.ShrapnelBombDebuff)) then
      return S.Carve:Cast()
    end
    -- wildfire_bomb,if=!talent.guerrilla_tactics.enabled|full_recharge_time<gcd
    if S.WildfireBomb:IsCastableP() and (not S.GuerrillaTactics:IsAvailable() or S.WildfireBomb:FullRechargeTimeP() < Player:GCD()) then
      return S.WildfireBomb:Cast()
    end
    -- mongoose_bite,target_if=max:debuff.latent_poison.stack,if=debuff.latent_poison.stack=10
    if S.MongooseBite:IsReadyP() and EvaluateTargetIfFilterMongooseBite396(Target) and EvaluateTargetIfMongooseBite405(Target) then
      return S.MongooseBite:Cast()
    end
    -- chakrams
    if S.Chakrams:IsCastableP() then
      return S.Chakrams:Cast()
    end
    -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max
    if S.KillCommand:IsCastableP() and EvaluateTargetIfFilterKillCommand413(Target) and EvaluateTargetIfKillCommand426(Target) then
      return S.KillCommand:Cast()
    end
    -- butchery,if=full_recharge_time<gcd|!talent.wildfire_infusion.enabled|dot.shrapnel_bomb.ticking&dot.internal_bleeding.stack<3
    if S.Butchery:IsCastableP() and (S.Butchery:FullRechargeTimeP() < Player:GCD() or not S.WildfireInfusion:IsAvailable() or Target:DebuffP(S.ShrapnelBombDebuff) and Target:DebuffStackP(S.InternalBleedingDebuff) < 3) then
      return S.Butchery:Cast()
    end
    -- carve,if=talent.guerrilla_tactics.enabled
    if S.Carve:IsReadyP() and (S.GuerrillaTactics:IsAvailable()) then
      return S.Carve:Cast()
    end
    -- flanking_strike,if=focus+cast_regen<focus.max
    if S.FlankingStrike:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
      return S.FlankingStrike:Cast()
    end
    -- wildfire_bomb,if=dot.wildfire_bomb.refreshable|talent.wildfire_infusion.enabled
    if S.WildfireBomb:IsCastableP() and (Target:DebuffRefreshableCP(S.WildfireBombDebuff) or S.WildfireInfusion:IsAvailable()) then
      return S.WildfireBomb:Cast()
    end
    -- serpent_sting,target_if=min:remains,if=buff.vipers_venom.react
    if S.SerpentSting:IsReadyP() and EvaluateTargetIfFilterSerpentSting462(Target) and EvaluateTargetIfSerpentSting479(Target) then
      return S.SerpentSting:Cast()
    end
    -- carve,if=cooldown.wildfire_bomb.remains>variable.carve_cdr%2
    if S.Carve:IsReadyP() and (S.WildfireBomb:CooldownRemainsP() > VarCarveCdr / 2) then
      return S.Carve:Cast()
    end
    -- steel_trap
    if S.SteelTrap:IsCastableP() then
      return S.SteelTrap:Cast()
    end
    -- harpoon,if=talent.terms_of_engagement.enabled
    if S.Harpoon:IsCastableP() and (S.TermsofEngagement:IsAvailable()) then
      return S.Harpoon:Cast()
    end
    -- serpent_sting,target_if=min:remains,if=refreshable&buff.tip_of_the_spear.stack<3
    if S.SerpentSting:IsReadyP() and EvaluateTargetIfFilterSerpentSting497(Target) and EvaluateTargetIfSerpentSting520(Target) then
      return S.SerpentSting:Cast()
    end
    -- mongoose_bite,target_if=max:debuff.latent_poison.stack
    if S.MongooseBite:IsReadyP() and EvaluateTargetIfFilterMongooseBite526(Target) then
      return S.MongooseBite:Cast()
    end
    -- raptor_strike,target_if=max:debuff.latent_poison.stack
    if S.RaptorStrike:IsReadyP() and EvaluateTargetIfFilterRaptorStrike537(Target) then
      return S.RaptorStrike:Cast()
    end
  end
  
  St = function()
    -- harpoon,if=talent.terms_of_engagement.enabled
    if S.Harpoon:IsCastableP() and (S.TermsofEngagement:IsAvailable()) then
      return S.Harpoon:Cast()
    end
    -- flanking_strike,if=focus+cast_regen<focus.max
    if S.FlankingStrike:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
      return S.FlankingStrike:Cast()
    end
    -- raptor_strike,if=buff.coordinated_assault.up&(buff.coordinated_assault.remains<1.5*gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<1.5*gcd)
    if S.RaptorStrike:IsReadyP() and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffRemainsP(S.CoordinatedAssaultBuff) < 1.5 * Player:GCD() or Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < 1.5 * Player:GCD())) then
      return S.RaptorStrike:Cast()
    end
    -- mongoose_bite,if=buff.coordinated_assault.up&(buff.coordinated_assault.remains<1.5*gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<1.5*gcd)
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffRemainsP(S.CoordinatedAssaultBuff) < 1.5 * Player:GCD() or Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < 1.5 * Player:GCD())) then
      return S.MongooseBite:Cast()
    end
    -- kill_command,if=focus+cast_regen<focus.max
    if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) + 15 < Player:FocusMax()) then
      return S.KillCommand:Cast()
    end
    -- steel_trap,if=focus+cast_regen<focus.max
    if S.SteelTrap:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.SteelTrap:ExecuteTime()) < Player:FocusMax()) then
      return S.SteelTrap:Cast()
    end
    -- wildfire_bomb,if=focus+cast_regen<focus.max&!ticking&!buff.memory_of_lucid_dreams.up&(full_recharge_time<1.5*gcd|!dot.wildfire_bomb.ticking&!buff.coordinated_assault.up)
    if S.WildfireBomb:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() and not Target:DebuffP(S.WildfireBombDebuff) and not Player:BuffP(S.MemoryOfLucidDreams) and (S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD() or not Target:DebuffP(S.WildfireBombDebuff) and not Player:BuffP(S.CoordinatedAssaultBuff))) then
      return S.WildfireBomb:Cast()
    end
    -- mongoose_bite,if=buff.mongoose_fury.stack>5&!cooldown.coordinated_assault.remains
    if S.MongooseBite:IsReadyP() and (Player:BuffStackP(S.MongooseFuryBuff) > 5 and not bool(S.CoordinatedAssault:CooldownRemainsP())) then
      return S.MongooseBite:Cast()
    end
    -- serpent_sting,if=buff.vipers_venom.up&dot.serpent_sting.remains<4*gcd|dot.serpent_sting.refreshable&!buff.coordinated_assault.up
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff) and Target:DebuffRemainsP(S.SerpentStingDebuff) < 4 * Player:GCD() or Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not Player:BuffP(S.CoordinatedAssaultBuff)) then
      return S.SerpentSting:Cast()
    end
    -- a_murder_of_crows,if=!buff.coordinated_assault.up
    if S.AMurderofCrows:IsCastableP() and (not Player:BuffP(S.CoordinatedAssaultBuff)) then
      return S.AMurderofCrows:Cast()
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() and RubimRH.CDsON() then
      return S.CoordinatedAssault:Cast()
    end
    -- mongoose_bite,if=buff.mongoose_fury.up|focus+cast_regen>focus.max-20&talent.vipers_venom.enabled|focus+cast_regen>focus.max-1&talent.terms_of_engagement.enabled|buff.coordinated_assault.up
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() + Player:FocusCastRegen(S.MongooseBite:ExecuteTime()) > Player:FocusMax() - 20 and S.VipersVenom:IsAvailable() or Player:Focus() + Player:FocusCastRegen(S.MongooseBite:ExecuteTime()) > Player:FocusMax() - 1 and S.TermsofEngagement:IsAvailable() or Player:BuffP(S.CoordinatedAssaultBuff)) then
      return S.MongooseBite:Cast()
    end
    -- raptor_strike
    if S.RaptorStrike:IsReadyP() then
      return S.RaptorStrike:Cast()
    end
    -- wildfire_bomb,if=dot.wildfire_bomb.refreshable
    if S.WildfireBomb:IsCastableP() and (Target:DebuffRefreshableCP(S.WildfireBombDebuff)) then
      return S.WildfireBomb:Cast()
    end
    -- serpent_sting,if=buff.vipers_venom.up
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff)) then
      return S.SerpentSting:Cast()
    end
  end
  
  Wfi = function()
    -- harpoon,if=focus+cast_regen<focus.max&talent.terms_of_engagement.enabled
    if S.Harpoon:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.Harpoon:ExecuteTime()) < Player:FocusMax() and S.TermsofEngagement:IsAvailable()) then
      return S.Harpoon:Cast()
    end
    -- mongoose_bite,if=buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < Player:GCD()) then
      return S.MongooseBite:Cast()
    end
    -- raptor_strike,if=buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd
    if S.RaptorStrike:IsReadyP() and (Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < Player:GCD()) then
      return S.RaptorStrike:Cast()
    end
    -- serpent_sting,if=buff.vipers_venom.up&buff.vipers_venom.remains<1.5*gcd|!dot.serpent_sting.ticking
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff) and Player:BuffRemainsP(S.VipersVenomBuff) < 1.5 * Player:GCD() or not Target:DebuffP(S.SerpentStingDebuff)) then
      return S.SerpentSting:Cast()
    end
    -- wildfire_bomb,if=full_recharge_time<1.5*gcd&focus+cast_regen<focus.max|(next_wi_bomb.volatile&dot.serpent_sting.ticking&dot.serpent_sting.refreshable|next_wi_bomb.pheromone&!buff.mongoose_fury.up&focus+cast_regen<focus.max-action.kill_command.cast_regen*3)
    if S.WildfireBomb:IsCastableP() and (S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD() and Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() or (S.VolatileBomb:IsLearned() and Target:DebuffP(S.SerpentStingDebuff) and Target:DebuffRefreshableCP(S.SerpentStingDebuff) or S.PheromoneBomb:IsLearned() and not Player:BuffP(S.MongooseFuryBuff) and Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() - Player:FocusCastRegen(S.KillCommand:ExecuteTime()) * 3)) then
      return S.WildfireBomb:Cast()
    end
    -- kill_command,if=focus+cast_regen<focus.max-focus.regen
    if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() - Player:FocusRegen()) then
      return S.KillCommand:Cast()
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      return S.AMurderofCrows:Cast()
    end
    -- steel_trap,if=focus+cast_regen<focus.max
    if S.SteelTrap:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.SteelTrap:ExecuteTime()) < Player:FocusMax()) then
      return S.SteelTrap:Cast()
    end
    -- wildfire_bomb,if=full_recharge_time<1.5*gcd
    if S.WildfireBomb:IsCastableP() and (S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD()) then
      return S.WildfireBomb:Cast()
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() and RubimRH.CDsON() then
      return S.CoordinatedAssault:Cast()
    end
    -- serpent_sting,if=buff.vipers_venom.up&dot.serpent_sting.remains<4*gcd
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff) and Target:DebuffRemainsP(S.SerpentStingDebuff) < 4 * Player:GCD()) then
      return S.SerpentSting:Cast()
    end
    -- mongoose_bite,if=dot.shrapnel_bomb.ticking|buff.mongoose_fury.stack=5
    if S.MongooseBite:IsReadyP() and (Target:DebuffP(S.ShrapnelBombDebuff) or Player:BuffStackP(S.MongooseFuryBuff) == 5) then
      return S.MongooseBite:Cast()
    end
    -- wildfire_bomb,if=next_wi_bomb.shrapnel&dot.serpent_sting.remains>5*gcd
    if S.WildfireBomb:IsCastableP() and (S.ShrapnelBomb:IsLearned() and Target:DebuffRemainsP(S.SerpentStingDebuff) > 5 * Player:GCD()) then
      return S.WildfireBomb:Cast()
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsReadyP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      return S.SerpentSting:Cast()
    end
    -- chakrams,if=!buff.mongoose_fury.remains
    if S.Chakrams:IsCastableP() and (not bool(Player:BuffRemainsP(S.MongooseFuryBuff))) then
      return S.Chakrams:Cast()
    end
    -- mongoose_bite
    if S.MongooseBite:IsReadyP() then
      return S.MongooseBite:Cast()
    end
    -- raptor_strike
    if S.RaptorStrike:IsReadyP() then
      return S.RaptorStrike:Cast()
    end
    -- serpent_sting,if=buff.vipers_venom.up
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff)) then
      return S.SerpentSting:Cast()
    end
    -- wildfire_bomb,if=next_wi_bomb.volatile&dot.serpent_sting.ticking|next_wi_bomb.pheromone|next_wi_bomb.shrapnel
    if S.WildfireBomb:IsCastableP() and (S.VolatileBomb:IsLearned() and Target:DebuffP(S.SerpentStingDebuff) or S.PheromoneBomb:IsLearned() or S.ShrapnelBomb:IsLearned()) then
      return S.WildfireBomb:Cast()
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

    -- countershot in combat
	if S.CounterShot:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.CounterShot:Cast()
    end
	-- Queueskill system 
    if QueueSkill() ~= nil then
        return QueueSkill()
    end
	-- Pet healing 
    if S.MendPet:IsCastable() and Pet:IsActive() and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= RubimRH.db.profile[255].sk1 and not Pet:Buff(S.MendPet) then
        return S.MendPet:Cast()
    end
	-- Pet handler in case of problem
    if Pet:IsDeadOrGhost() then
        return S.MendPet:Cast()
    end
	-- Interrupts
    if S.Muzzle:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Muzzle:Cast()
    end   
    -- auto_attack
    -- use_items
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=apwfi,if=active_enemies<3&talent.chakrams.enabled&talent.alpha_predator.enabled
    if (Cache.EnemiesCount[8] < 3 and S.Chakrams:IsAvailable() and S.AlphaPredator:IsAvailable()) then
      local ShouldReturn = Apwfi(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=wfi,if=active_enemies<3&talent.chakrams.enabled
    if (Cache.EnemiesCount[8] < 3 and S.Chakrams:IsAvailable()) then
      local ShouldReturn = Wfi(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=st,if=active_enemies<3&!talent.alpha_predator.enabled&!talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[8] < 3 and not S.AlphaPredator:IsAvailable() and not S.WildfireInfusion:IsAvailable()) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=apst,if=active_enemies<3&talent.alpha_predator.enabled&!talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[8] < 3 and S.AlphaPredator:IsAvailable() and not S.WildfireInfusion:IsAvailable()) then
      local ShouldReturn = Apst(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=apwfi,if=active_enemies<3&talent.alpha_predator.enabled&talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[8] < 3 and S.AlphaPredator:IsAvailable() and S.WildfireInfusion:IsAvailable()) then
      local ShouldReturn = Apwfi(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=wfi,if=active_enemies<3&!talent.alpha_predator.enabled&talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[8] < 3 and not S.AlphaPredator:IsAvailable() and S.WildfireInfusion:IsAvailable()) then
      local ShouldReturn = Wfi(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cleave,if=active_enemies>1
    if (Cache.EnemiesCount[8] > 1) then
      local ShouldReturn = Cleave(); if ShouldReturn then return ShouldReturn; end
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and RubimRH.CDsON() then
      return S.ArcaneTorrent:Cast()
    end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(255, APL);

local function PASSIVE()

    if S.AspectoftheTurtle:IsCastable() and Player:HealthPercentage() <= RubimRH.db.profile[255].sk2 then
        return S.AspectoftheTurtle:Cast()
    end

    if S.Exhilaration:IsCastable() and Player:HealthPercentage() <= RubimRH.db.profile[255].sk3 then
        return S.Exhilaration:Cast()
    end

    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(255, PASSIVE);