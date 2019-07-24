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
RubimRH.Spell[252] = {
  RaiseDead                             = Spell(46584),
  ArmyoftheDead                         = Spell(42650),
  DeathandDecay                         = Spell(43265),
  DeathandDecayBuff                     = Spell(188290),
  Apocalypse                            = Spell(275699),
  Defile                                = Spell(152280),
  Epidemic                              = Spell(207317),
  DeathCoil                             = Spell(47541),
  ScourgeStrike                         = Spell(55090),
  ClawingShadows                        = Spell(207311),
  FesteringStrike                       = Spell(85948),
  FesteringWoundDebuff                  = Spell(194310),
  BurstingSores                         = Spell(207264),
  SuddenDoomBuff                        = Spell(81340),
  UnholyFrenzyBuff                      = Spell(207289),
  DarkTransformation                    = Spell(63560),
  SummonGargoyle                        = Spell(49206),
  SummonGargoyle2                       = Spell(207349),
  UnholyFrenzy                          = Spell(207289),
  MagusoftheDead                        = Spell(288417),
  SoulReaper                            = Spell(130736),
  UnholyBlight                          = Spell(115989),
  Pestilence                            = Spell(277234),
  ArcaneTorrent                         = Spell(50613),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArmyoftheDamned                       = Spell(276837),
  Outbreak                              = Spell(77575),
  VirulentPlagueDebuff                  = Spell(191587),
  DeathStrike                           = Spell(49998),
  DeathStrikeBuff                       = Spell(101568),
  MindFreeze                            = Spell(47528),
  DarkSuccor                            = Spell(101568),
  DeathsAdvance                         = Spell(48265),
  DeathGrip                             = Spell(49576),
  DeathPact                             = Spell(48743),
  IceboundFortitude                     = Spell(48792),
  NecroticStrike                        = Spell(223829),
  RaiseAlly                             = Spell(61999),
  DarkSimulacrum                        = Spell(77606),
  Asphyxiate                            = Spell(108194),
  AntiMagicShell                        = Spell(48707),
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
  RecklessForceCounter                  = Spell(298409),
  RecklessForceCounter2                 = Spell(302917),
  RecklessForceBuff                     = Spell(302932),
  ConcentratedFlameBurn                 = Spell(295368)
};
local S = RubimRH.Spell[252]
--S.ClawingShadows.TextureSpellID = { 241367 }

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Unholy = {
  BattlePotionofStrength           = Item(163224),
  RampingAmplitudeGigavoltEngine   = Item(165580),
  BygoneBeeAlmanac                 = Item(163936),
  JesHowler                        = Item(159627),
  GalecallersBeak                  = Item(161379),
  GrongsPrimalRage                 = Item(165574),
  VisionofDemise                   = Item(169307)
};
local I = Item.DeathKnight.Unholy;

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
  S.RecklessForceCounter = S.RecklessForceCounter2:IsAvailable() and S.RecklessForceCounter2 or S.RecklessForceCounter
  S.SummonGargoyle = S.SummonGargoyle2:IsAvailable() and S.SummonGargoyle2 or S.SummonGargoyle
end

-- Variables
local VarPoolingForGargoyle = 0;

HL:RegisterForEvent(function()
  VarPoolingForGargoyle = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {30, 8}
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

local function DeathStrikeHeal()
  return Player:HealthPercentage() <= RubimRH.db.profile[252].sk3 and true or false;
end

local function EvaluateCycleFesteringStrike40(TargetUnit)
  return TargetUnit:DebuffStackP(S.FesteringWoundDebuff) <= 1 and bool(S.DeathandDecay:CooldownRemainsP())
end

local function EvaluateCycleSoulReaper163(TargetUnit)
  return TargetUnit:TimeToDie() < 8 and TargetUnit:TimeToDie() > 4
end

local function EvaluateCycleOutbreak303(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.VirulentPlagueDebuff) <= Player:GCD()
end

--HL.RegisterNucleusAbility(152280, 8, 6)               -- Defile
--HL.RegisterNucleusAbility(115989, 8, 6)               -- Unholy Blight
--HL.RegisterNucleusAbility(43265, 8, 6)                -- Death and Decay

--- ======= ACTION LISTS =======
local function APL()
  local Precombat_DBM, Precombat, Aoe, Cooldowns, Essences, Generic
  UpdateRanges()
  DetermineEssenceRanks()
  local no_heal = not DeathStrikeHeal()
  --local Gargoyle = S.DarkArbiter:IsLearned() and S.DarkArbiter or S.SummonGargoyle
  
  	-- Anti channeling interrupt
	if Player:IsChanneling() or Player:IsCasting() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end	

	Precombat_DBM = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- raise_dead
        if S.RaiseDead:IsCastableP() and not Pet:IsActive() then
            return S.RaiseDead:Cast()
        end
		--Prepots
        if I.BattlePotionofStrength:IsReady() and RubimRH.DBM_PullTimer() > 0.1 + Player:GCD() and RubimRH.DBM_PullTimer() < 0.5 + Player:GCD() then
            return 967532
        end
        -- death_and_decay,if=cooldown.apocalypse.remains
        if S.DeathandDecay:IsCastableP() and RubimRH.DBM_PullTimer() > 0.1 and RubimRH.DBM_PullTimer() < 0.5 then
            return S.DeathandDecay:Cast()
        end		
    end  
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    -- raise_dead
    if S.RaiseDead:IsCastableP() and not Pet:IsActive() then
      return S.RaiseDead:Cast()
    end
    -- army_of_the_dead,delay=2
    --if RubimRH.TargetIsValid() then
      if S.ArmyoftheDead:IsCastableP() then
        return S.ArmyoftheDead:Cast()
      end
    --end
  end
  
  Aoe = function()
    -- death_and_decay,if=cooldown.apocalypse.remains
    if S.DeathandDecay:IsCastableP() and (bool(S.Apocalypse:CooldownRemainsP())) then
      return S.DeathandDecay:Cast()
    end
    -- defile
    if S.Defile:IsCastableP() then
      return S.Defile:Cast()
    end
    -- epidemic,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
    if S.Epidemic:IsReadyP() and (Player:BuffP(S.DeathandDecayBuff) and Player:Rune() < 2 and not bool(VarPoolingForGargoyle)) then
      return S.Epidemic:Cast()
    end
    -- death_coil,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:BuffP(S.DeathandDecayBuff) and Player:Rune() < 2 and not bool(VarPoolingForGargoyle)) then
      return S.DeathCoil:Cast()
    end
    -- scourge_strike,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ScourgeStrike:IsCastableP() and (Player:BuffP(S.DeathandDecayBuff) and bool(S.Apocalypse:CooldownRemainsP())) then
      return S.ScourgeStrike:Cast()
    end
    -- clawing_shadows,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ClawingShadows:IsCastableP() and (Player:BuffP(S.DeathandDecayBuff) and bool(S.Apocalypse:CooldownRemainsP())) then
      return S.ClawingShadows:Cast()
    end
    -- epidemic,if=!variable.pooling_for_gargoyle
    if S.Epidemic:IsReadyP() and (not bool(VarPoolingForGargoyle)) then
      return S.Epidemic:Cast()
    end
    -- festering_strike,target_if=debuff.festering_wound.stack<=1&cooldown.death_and_decay.remains
    if S.FesteringStrike:IsCastableP() and EvaluateCycleFesteringStrike40(Target) then
      return S.FesteringStrike:Cast()
    end
    -- festering_strike,if=talent.bursting_sores.enabled&spell_targets.bursting_sores>=2&debuff.festering_wound.stack<=1
    if S.FesteringStrike:IsCastableP() and (S.BurstingSores:IsAvailable() and Cache.EnemiesCount[8] >= 2 and Target:DebuffStackP(S.FesteringWoundDebuff) <= 1) then
      return S.FesteringStrike:Cast()
    end
    -- death_coil,if=buff.sudden_doom.react&rune.deficit>=4
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and Player:Rune() <= 2) then
      return S.DeathCoil:Cast()
    end
    -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and not bool(VarPoolingForGargoyle) or S.SummonGargoyle:TimeSinceLastCast() <= 35) then
      return S.DeathCoil:Cast()
    end
    -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemainsP() > 5 or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and not bool(VarPoolingForGargoyle)) then
      return S.DeathCoil:Cast()
    end
    -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ScourgeStrike:IsCastableP() and ((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) then
      return S.ScourgeStrike:Cast()
    end
    -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ClawingShadows:IsCastableP() and ((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) then
      return S.ClawingShadows:Cast()
    end
    -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle)) then
      return S.DeathCoil:Cast()
    end
    -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
    if S.FesteringStrike:IsCastableP() and ((((Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not Player:BuffP(S.UnholyFrenzyBuff)) or Target:DebuffStackP(S.FesteringWoundDebuff) < 3) and S.Apocalypse:CooldownRemainsP() < 3) or Target:DebuffStackP(S.FesteringWoundDebuff) < 1) then
      return S.FesteringStrike:Cast()
    end
    -- death_coil,if=!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (not bool(VarPoolingForGargoyle)) then
      return S.DeathCoil:Cast()
    end
  end
  
  Cooldowns = function()
    -- army_of_the_dead
    if S.ArmyoftheDead:IsCastableP() then
      return S.ArmyoftheDead:Cast()
    end
    -- apocalypse,if=debuff.festering_wound.stack>=4
    if S.Apocalypse:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) >= 4) then
      return S.Apocalypse:Cast()
    end
    -- dark_transformation,if=!raid_event.adds.exists|raid_event.adds.in>15
    if S.DarkTransformation:IsCastableP() and (not (Cache.EnemiesCount[8] > 1)) then
      return S.DarkTransformation:Cast()
    end
    -- summon_gargoyle,if=runic_power.deficit<14
    if S.SummonGargoyle:IsCastableP() and (Player:RunicPowerDeficit() < 14) then
      return S.SummonGargoyle:Cast()
    end
    -- unholy_frenzy,if=debuff.festering_wound.stack<4&!(equipped.ramping_amplitude_gigavolt_engine|azerite.magus_of_the_dead.enabled)
    if S.UnholyFrenzy:IsCastableP() and (Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not (I.RampingAmplitudeGigavoltEngine:IsEquipped() or S.MagusoftheDead:AzeriteEnabled())) then
      return S.UnholyFrenzy:Cast()
    end
    -- unholy_frenzy,if=cooldown.apocalypse.remains<2&(equipped.ramping_amplitude_gigavolt_engine|azerite.magus_of_the_dead.enabled)
    if S.UnholyFrenzy:IsCastableP() and (S.Apocalypse:CooldownRemainsP() < 2 and (I.RampingAmplitudeGigavoltEngine:IsEquipped() or S.MagusoftheDead:AzeriteEnabled())) then
      return S.UnholyFrenzy:Cast()
    end
    -- unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
    if S.UnholyFrenzy:IsCastableP() and (Cache.EnemiesCount[8] >= 2 and ((S.DeathandDecay:CooldownRemainsP() <= Player:GCD() and not S.Defile:IsAvailable()) or (S.Defile:CooldownRemainsP() <= Player:GCD() and S.Defile:IsAvailable()))) then
      return S.UnholyFrenzy:Cast()
    end
    -- soul_reaper,target_if=target.time_to_die<8&target.time_to_die>4
    if S.SoulReaper:IsCastableP() and EvaluateCycleSoulReaper163(Target) then
      return S.SoulReaper:Cast()
    end
    -- soul_reaper,if=(!raid_event.adds.exists|raid_event.adds.in>20)&rune<=(1-buff.unholy_frenzy.up)
    if S.SoulReaper:IsCastableP() and ((not (Cache.EnemiesCount[8] > 1)) and Player:Rune() <= (1 - num(Player:BuffP(S.UnholyFrenzyBuff)))) then
      return S.SoulReaper:Cast()
    end
    -- unholy_blight
    if S.UnholyBlight:IsCastableP() then
      return S.UnholyBlight:Cast()
    end
  end
  
  Essences = function()
    -- memory_of_lucid_dreams,if=rune.time_to_1>gcd&runic_power<40
    if S.MemoryofLucidDreams:IsCastableP() and (Player:RuneTimeToX(1) > Player:GCD() and Player:RunicPower() < 40) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- blood_of_the_enemy,if=(cooldown.death_and_decay.remains&spell_targets.death_and_decay>1)|(cooldown.defile.remains&spell_targets.defile>1)|(cooldown.apocalypse.remains&cooldown.death_and_decay.ready)
    if S.BloodoftheEnemy:IsCastableP() and ((bool(S.DeathandDecay:CooldownRemainsP()) and Cache.EnemiesCount[8] > 1) or (bool(S.Defile:CooldownRemainsP()) and Cache.EnemiesCount[8] > 1) or (bool(S.Apocalypse:CooldownRemainsP()) and S.DeathandDecay:IsCastableP())) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth,if=cooldown.apocalypse.ready
    if S.GuardianofAzeroth:IsCastableP() and (S.Apocalypse:IsCastableP()) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<11
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(RecklessForceBuff) or Player:BuffStackP(S.RecklessForceCounter) < 11) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- focused_azerite_beam,if=!death_and_decay.ticking
    if S.FocusedAzeriteBeam:IsCastableP() and (not Player:BuffP(S.DeathandDecayBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame,if=dot.concentrated_flame_burn.remains=0
    if S.ConcentratedFlame:IsCastableP() and (Target:DebuffDownP(S.ConcentratedFlameBurn)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast,if=!death_and_decay.ticking
    if S.PurifyingBlast:IsCastableP() and (not Player:BuffP(S.DeathandDecayBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance,if=!death_and_decay.ticking
    if S.WorldveinResonance:IsCastableP() and (not Player:BuffP(S.DeathandDecayBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space,if=!death_and_decay.ticking
    if S.RippleInSpace:IsCastableP() and (not Player:BuffP(S.DeathandDecayBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
  end
  
  Generic = function()
    -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
    if S.DeathCoil:IsUsableP() and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and not bool(VarPoolingForGargoyle) or S.SummonGargoyle:TimeSinceLastCast() <= 35) then
      return S.DeathCoil:Cast()
    end
    -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemainsP() > 5 or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and not bool(VarPoolingForGargoyle)) then
      return S.DeathCoil:Cast()
    end
    -- death_and_decay,if=talent.pestilence.enabled&cooldown.apocalypse.remains
    if S.DeathandDecay:IsCastableP() and (S.Pestilence:IsAvailable() and bool(S.Apocalypse:CooldownRemainsP())) then
      return S.DeathandDecay:Cast()
    end
    -- defile,if=cooldown.apocalypse.remains
    if S.Defile:IsCastableP() and (bool(S.Apocalypse:CooldownRemainsP())) then
      return S.Defile:Cast()
    end
    -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ScourgeStrike:IsCastableP() and ((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) then
      return S.ScourgeStrike:Cast()
    end
    -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ClawingShadows:IsCastableP() and ((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) then
      return S.ClawingShadows:Cast()
    end
    -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle)) then
      return S.DeathCoil:Cast()
    end
    -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
    if S.FesteringStrike:IsCastableP() and ((((Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not Player:BuffP(S.UnholyFrenzyBuff)) or Target:DebuffStackP(S.FesteringWoundDebuff) < 3) and S.Apocalypse:CooldownRemainsP() < 3) or Target:DebuffStackP(S.FesteringWoundDebuff) < 1) then
      return S.FesteringStrike:Cast()
    end
    -- death_coil,if=!variable.pooling_for_gargoyle
    if S.DeathCoil:IsUsableP() and (not bool(VarPoolingForGargoyle)) then
      return S.DeathCoil:Cast()
    end
  end
  
    -- call DBM precombat
	if not Player:AffectingCombat() and RubimRH.PrecombatON() and RubimRH.PerfectPullON() then
        if Precombat_DBM() ~= nil then
            return Precombat_DBM()
        end
	end

    -- call NON DBM precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and not RubimRH.PerfectPullON() then
        if Precombat() ~= nil then
            return Precombat()
        end
    end
  
  -- Combat Start
  if RubimRH.TargetIsValid() then
    --QueueSkill system
	if QueueSkill() ~= nil then
        return QueueSkill()
    end
    -- Antimagic Shell
	if S.AntiMagicShell:IsAvailable() and S.AntiMagicShell:CooldownRemainsP() < 0.1 and Player:HealthPercentage() <= RubimRH.db.profile[252].sk5 then
        return S.AntiMagicShell:Cast()
    end	

    --Mov Speed
    if Player:MovingFor() >= 1 and S.DeathsAdvance:IsReadyMorph() then
        return S.DeathsAdvance:Cast()
    end

    --Death Grip
    if Target:MinDistanceToPlayer(true) >= 15 and Target:MinDistanceToPlayer(true) <= 40 and S.DeathGrip:IsReady() and Target:IsQuestMob() then
        return S.DeathGrip:Cast()
    end
    -- custom
    if Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[252].sk1 then
        return S.DeathStrike:Cast()
    end

    if Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 95 and Player:BuffRemains(S.DarkSuccor) <= 2 then
        return S.DeathStrike:Cast()
    end

    if S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[252].sk3 then
        if S.DeathStrike:IsReady() then
            return S.DeathStrike:Cast()
        else
            S.DeathStrike:Queue()
            return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
        end
    end

    if S.DeathPact:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[252].sk4 then
        return S.DeathPact:Cast()
    end

    -- auto_attack
    -- mind_freeze
    if S.MindFreeze:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() and (true) then
        return S.MindFreeze:Cast()
    end

    if S.RaiseDead:IsCastable() and not Pet:IsActive() then
        return S.RaiseDead:Cast()
    end
    -- use DeathStrike on low HP in Solo Mode
    if not no_heal and S.DeathStrike:IsReadyP("Melee") then
      return S.DeathStrike:Cast()
    end
    -- use DeathStrike with Proc in Solo Mode
    --if Settings.General.SoloMode and S.DeathStrike:IsReadyP("Melee") and Player:BuffP(S.DeathStrikeBuff) then
    --  return S.DeathStrike:Cast()
    --end
    -- auto_attack
    -- variable,name=pooling_for_gargoyle,value=cooldown.summon_gargoyle.remains<5&talent.summon_gargoyle.enabled
    if (true) then
      VarPoolingForGargoyle = num(S.SummonGargoyle:CooldownRemainsP() < 5 and S.SummonGargoyle:IsAvailable())
    end
    -- arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
    if S.ArcaneTorrent:IsCastableP() and RubimRH.CDsON() and (Player:RunicPowerDeficit() > 65 and (S.SummonGargoyle:TimeSinceLastCast() <= 35 or not S.SummonGargoyle:IsAvailable()) and Player:Rune() <= 1) then
      return S.ArcaneTorrent:Cast()
    end
    -- blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (S.SummonGargoyle:TimeSinceLastCast() <= 35 or not S.SummonGargoyle:IsAvailable()) then
      return S.BloodFury:Cast()
    end
    -- berserking,if=buff.unholy_frenzy.up|pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.UnholyFrenzyBuff) or S.SummonGargoyle:TimeSinceLastCast() <= 35 or not S.SummonGargoyle:IsAvailable()) then
      return S.Berserking:Cast()
    end
    -- use_items,if=time>20|!equipped.ramping_amplitude_gigavolt_engine|!equipped.vision_of_demise
    -- use_item,name=vision_of_demise,if=(cooldown.apocalypse.ready&debuff.festering_wound.stack>=4&essence.vision_of_perfection.enabled)|buff.unholy_frenzy.up|pet.gargoyle.active
    if I.VisionofDemise:IsReady() and ((S.Apocalypse:CooldownUpP() and Target:DebuffStackP(S.FesteringWoundDebuff) >= 4 and S.VisionofPerfection:IsAvailable()) or Player:BuffP(S.UnholyFrenzyBuff) or S.SummonGargoyle:TimeSinceLastCast() <= 35) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_item,name=ramping_amplitude_gigavolt_engine,if=cooldown.apocalypse.remains<2|talent.army_of_the_damned.enabled|raid_event.adds.in<5
    if I.RampingAmplitudeGigavoltEngine:IsReady() and (S.Apocalypse:CooldownRemainsP() < 2 or S.ArmyoftheDamned:IsAvailable()) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_item,name=bygone_bee_almanac,if=cooldown.summon_gargoyle.remains>60|!talent.summon_gargoyle.enabled&time>20|!equipped.ramping_amplitude_gigavolt_engine
    if I.BygoneBeeAlmanac:IsReady() and (S.SummonGargoyle:CooldownRemainsP() > 60 or not S.SummonGargoyle:IsAvailable() and HL.CombatTime() > 20 or not I.RampingAmplitudeGigavoltEngine:IsEquipped()) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_item,name=jes_howler,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled&time>20|!equipped.ramping_amplitude_gigavolt_engine
    if I.JesHowler:IsReady() and (S.SummonGargoyle:TimeSinceLastCast() <= 35 or not S.SummonGargoyle:IsAvailable() and HL.CombatTime() > 20 or not I.RampingAmplitudeGigavoltEngine:IsEquipped()) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_item,name=galecallers_beak,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled&time>20|!equipped.ramping_amplitude_gigavolt_engine
    if I.GalecallersBeak:IsReady() and (S.SummonGargoyle:TimeSinceLastCast() <= 35 or not S.SummonGargoyle:IsAvailable() and HL.CombatTime() > 20 or not I.RampingAmplitudeGigavoltEngine:IsEquipped()) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_item,name=grongs_primal_rage,if=rune<=3&(time>20|!equipped.ramping_amplitude_gigavolt_engine)
    if I.GrongsPrimalRage:IsReady() and (Player:Rune() <= 3 and (HL.CombatTime() > 20 or not I.RampingAmplitudeGigavoltEngine:IsEquipped())) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
    if I.BattlePotionofStrength:IsReady() and (S.ArmyoftheDead:CooldownUpP() or S.SummonGargoyle:TimeSinceLastCast() <= 35 or Player:BuffP(S.UnholyFrenzyBuff)) then
      return 967532
    end
    -- outbreak,target_if=dot.virulent_plague.remains<=gcd
    if S.Outbreak:IsCastableP() and EvaluateCycleOutbreak303(Target) then
      return S.Outbreak:Cast()
    end
    -- call_action_list,name=essences
    if (true) then
      local ShouldReturn = Essences(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if (Cache.EnemiesCount[8] >= 2) then
      return Aoe();
    end
    -- call_action_list,name=generic
    if (true) then
      local ShouldReturn = Generic(); if ShouldReturn then return ShouldReturn; end
    end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(252, APL)

local function PASSIVE()
    if S.IceboundFortitude:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[252].sk2 then
        return S.IceboundFortitude:Cast()
    end

    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(252, PASSIVE)