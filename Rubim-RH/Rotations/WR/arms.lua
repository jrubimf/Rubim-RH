--- ============================ HEADER ============================
--- ======= LOCALIZE =======
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
local mainAddon = RubimRH

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

RubimRH.Spell[71] = {
    -- Racials
    ArcaneTorrent = Spell(80483),
    AncestralCall = Spell(274738),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Fireblood = Spell(265221),
    GiftoftheNaaru = Spell(59547),
    LightsJudgment = Spell(255647),

    -- Abilities
    BattleShout = Spell(6673),
    Skullsplitter = Spell(260643),
    DeadlyCalm = Spell(262228),
    DeadlyCalmBuff = Spell(262228),
    Bladestorm = Spell(227847),
    ColossusSmash = Spell(167105),
    Warbreaker = Spell(262161),
    Ravager = Spell(152277),
    ColossusSmashDebuff = Spell(208086),
    Cleave = Spell(845),
    Slam = Spell(1464),
    CrushingAssaultBuff = Spell(278826),
    MortalStrike = Spell(12294),
    OverpowerBuff = Spell(7384),
    Dreadnaught = Spell(262150),
    ExecutionersPrecisionBuff = Spell(272866),
    Overpower = Spell(7384),
    Execute = Spell(163201),
    SweepingStrikesBuff = Spell(260708),
    TestofMight = Spell(275529),
    TestofMightBuff = Spell(275540),
    DeepWoundsDebuff = Spell(262115),
    SuddenDeathBuff = Spell(52437),
    StoneHeartBuff = Spell(225947),
    SweepingStrikes = Spell(260708),
    Whirlwind = Spell(1680),
    FervorofBattle = Spell(202316),
    Rend = Spell(772),
    RendDebuff = Spell(772),
    AngerManagement = Spell(152278),
    SeismicWave = Spell(277639),
    Charge = Spell(100),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    ArcaneTorrent = Spell(50613),
    LightsJudgment = Spell(255647),
    Fireblood = Spell(265221),
    AncestralCall = Spell(274738),
    Avatar = Spell(107574),
    Massacre = Spell(281001),

    -- Defensive
    RallyingCry = Spell(97462),
    DefensiveStance = Spell(197690),
    DiebytheSword = Spell(118038),
    Victorious = Spell(32216),
    VictoryRush = Spell(34428),
    ImpendingVictory = Spell(202168),

    -- Utility
    HeroicLeap = Spell(6544), -- Unused
    Disarm = Spell(236077),
    Pummel = Spell(6552),
    Hamstring = Spell(1715),
    SharpenBlade = Spell(198817),
    SpellReflection = Spell(216890),
    Shockwave = Spell(46968),
    ShatteredDefensesBuff = Spell(248625),
    PreciseStrikesBuff = Spell(209492),

    -- Misc
    WeightedBlade = Spell(253383),

    -- Azerite
    TestofMight = Spell(275529),
    TestofMightBuff = Spell(275540),
    SeismicWave = Spell(277639),
    DeathSentence = Spell(198500),
	
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
    RecklessForce         = Spell(302932),
	Stormbolt             = Spell(302932),
};

local S = RubimRH.Spell[71]
-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Arms = {
  BattlePotionofStrength           = Item(163224)
};
local I = Item.Warrior.Arms;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- Stuns
local StunInterrupts = {
  {S.IntimidatingShout, "Cast Intimidating Shout (Interrupt)", function () return true; end},
};

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

S.ExecuteDefault    = Spell(163201)
S.ExecuteMassacre   = Spell(281000)

local function UpdateExecuteID()
    S.Execute = S.Massacre:IsAvailable() and S.ExecuteMassacre or S.ExecuteDefault
end

--HL.RegisterNucleusAbility(152277, 8, 6)               -- Ravager
--HL.RegisterNucleusAbility(227847, 8, 6)               -- Bladestorm
--HL.RegisterNucleusAbility(845, 8, 6)                  -- Cleave
--HL.RegisterNucleusAbility(1680, 8, 6)                 -- Whirlwind

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
  local Precombat, Execute, FiveTarget, Hac, SingleTarget
  UpdateRanges()
  UpdateExecuteID()
  DetermineEssenceRanks()
  
    -- Anti channeling interrupt
	if Player:IsChanneling() or Player:IsCasting() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end	

     
      -- potion
    Precombat = function()
	    -- Charge
       if Target:MinDistanceToPlayer(true) >= 8 and Target:MinDistanceToPlayer(true) <= 40 and S.Charge:IsReady() and S.Charge:TimeSinceLastCast() >= Player:GCD() then
         return S.Charge:Cast()
       end
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- potion
      if S.BattleShout:IsCastable() and not Player:BuffPvP(S.BattleShout) then
        return S.BattleShout:Cast()
      end
      -- memory_of_lucid_dreams
      if S.MemoryOfLucidDreams:IsCastableP() then
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
    end
  
  
  Execute = function()
    -- skullsplitter,if=rage<60&buff.deadly_calm.down&buff.memory_of_lucid_dreams.down
    if S.Skullsplitter:IsCastableP() and (Player:Rage() < 60 and Player:BuffDownP(S.DeadlyCalmBuff) and Player:BuffDownP(S.MemoryOfLucidDreams)) then
      return S.Skullsplitter:Cast()
    end
    -- ravager,if=!buff.deadly_calm.up&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.Ravager:IsCastableP() and RubimRH.CDsON() and (not Player:BuffP(S.DeadlyCalmBuff) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      return S.Ravager:Cast()
    end
    -- colossus_smash,if=!essence.memory_of_lucid_dreams.major|(buff.memory_of_lucid_dreams.up|cooldown.memory_of_lucid_dreams.remains>10)
    if S.ColossusSmash:IsCastableP() and (not S.MemoryOfLucidDreams:IsAvailable() or (Player:BuffP(S.MemoryOfLucidDreams) or S.MemoryOfLucidDreams:CooldownRemainsP() > 10)) then
      return S.ColossusSmash:Cast()
    end
    -- warbreaker,if=!essence.memory_of_lucid_dreams.major|(buff.memory_of_lucid_dreams.up|cooldown.memory_of_lucid_dreams.remains>10)
    if S.Warbreaker:IsCastableP() and RubimRH.CDsON() and (not S.MemoryOfLucidDreams:IsAvailable() or (Player:BuffP(S.MemoryOfLucidDreams) or S.MemoryOfLucidDreams:CooldownRemainsP() > 10)) then
      return S.Warbreaker:Cast()
    end
    -- deadly_calm
    if S.DeadlyCalm:IsCastableP() then
      return S.DeadlyCalm:Cast()
    end
    -- bladestorm,if=!buff.memory_of_lucid_dreams.up&buff.test_of_might.up&rage<30&!buff.deadly_calm.up
    if S.Bladestorm:IsReady() and RubimRH.CDsON() and (Player:BuffDownP(S.MemoryOfLucidDreams) and Player:BuffP(S.TestofMightBuff) and Player:Rage() < 30 and Player:BuffDownP(S.DeadlyCalmBuff)) then
      return S.Bladestorm:Cast()
    end
    -- cleave,if=spell_targets.whirlwind>2
    if S.Cleave:IsReadyP() and (Cache.EnemiesCount[8] > 2) then
      return S.Cleave:Cast()
    end
    -- slam,if=buff.crushing_assault.up&buff.memory_of_lucid_dreams.down
    if S.Slam:IsReadyP() and (Player:BuffP(S.CrushingAssaultBuff) and Player:BuffDownP(S.MemoryOfLucidDreams)) then
      return S.Slam:Cast()
    end
    -- mortal_strike,if=buff.overpower.stack=2&talent.dreadnaught.enabled|buff.executioners_precision.stack=2
    if S.MortalStrike:IsReadyP() and (Player:BuffStackP(S.OverpowerBuff) == 2 and S.Dreadnaught:IsAvailable() or Player:BuffStackP(S.ExecutionersPrecisionBuff) == 2) then
      return S.MortalStrike:Cast()
    end
    -- execute,if=buff.memory_of_lucid_dreams.up|buff.deadly_calm.up
    if S.Execute:IsReadyMorph() and (Player:BuffP(S.MemoryOfLucidDreams) or Player:BuffP(S.DeadlyCalmBuff)) then
      return S.Execute:Cast()
    end
    -- overpower
    if S.Overpower:IsCastableP() then
      return S.Overpower:Cast()
    end
    -- execute
    if S.Execute:IsReadyMorph() then
      return S.Execute:Cast()
    end
  end
 
  FiveTarget = function()
    -- skullsplitter,if=rage<60&(!talent.deadly_calm.enabled|buff.deadly_calm.down)
    if S.Skullsplitter:IsCastableP() and (Player:Rage() < 60 and (not S.DeadlyCalm:IsAvailable() or Player:BuffDownP(S.DeadlyCalmBuff))) then
      return S.Skullsplitter:Cast()
    end
    -- ravager,if=(!talent.warbreaker.enabled|cooldown.warbreaker.remains<2)
    if S.Ravager:IsCastableP() and RubimRH.CDsON() and ((not S.Warbreaker:IsAvailable() or S.Warbreaker:CooldownRemainsP() < 2)) then
      return S.Ravager:Cast()
    end
    -- colossus_smash,if=debuff.colossus_smash.down
    if S.ColossusSmash:IsCastableP() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      return S.ColossusSmash:Cast()
    end
    -- warbreaker,if=debuff.colossus_smash.down
    if S.Warbreaker:IsCastableP() and RubimRH.CDsON() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      return S.Warbreaker:Cast()
    end
    -- bladestorm,if=buff.sweeping_strikes.down&(!talent.deadly_calm.enabled|buff.deadly_calm.down)&((debuff.colossus_smash.remains>4.5&!azerite.test_of_might.enabled)|buff.test_of_might.up)
    if S.Bladestorm:IsReady() and RubimRH.CDsON() and (Player:BuffDownP(S.SweepingStrikesBuff) and (not S.DeadlyCalm:IsAvailable() or Player:BuffDownP(S.DeadlyCalmBuff)) and ((Target:DebuffRemainsP(S.ColossusSmashDebuff) > 4.5 and not S.TestofMight:AzeriteEnabled()) or Player:BuffP(S.TestofMightBuff))) then
      return S.Bladestorm:Cast()
    end
    -- deadly_calm
    if S.DeadlyCalm:IsCastableP() then
      return S.DeadlyCalm:Cast()
    end
    -- cleave
    if S.Cleave:IsReadyP() then
      return S.Cleave:Cast()
    end
    -- execute,if=(!talent.cleave.enabled&dot.deep_wounds.remains<2)|(buff.sudden_death.react|buff.stone_heart.react)&(buff.sweeping_strikes.up|cooldown.sweeping_strikes.remains>8)
    if S.Execute:IsReadyMorph() and ((not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2) or (bool(Player:BuffStackP(S.SuddenDeathBuff)) or bool(Player:BuffStackP(S.StoneHeartBuff))) and (Player:BuffP(S.SweepingStrikesBuff) or S.SweepingStrikes:CooldownRemainsP() > 8)) then
      return S.Execute:Cast()
    end
    -- mortal_strike,if=(!talent.cleave.enabled&dot.deep_wounds.remains<2)|buff.sweeping_strikes.up&buff.overpower.stack=2&(talent.dreadnaught.enabled|buff.executioners_precision.stack=2)
    if S.MortalStrike:IsReadyP() and ((not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2) or Player:BuffP(S.SweepingStrikesBuff) and Player:BuffStackP(S.OverpowerBuff) == 2 and (S.Dreadnaught:IsAvailable() or Player:BuffStackP(S.ExecutionersPrecisionBuff) == 2)) then
      return S.MortalStrike:Cast()
    end
    -- whirlwind,if=debuff.colossus_smash.up|(buff.crushing_assault.up&talent.fervor_of_battle.enabled)
    if S.Whirlwind:IsReadyP() and (Target:DebuffP(S.ColossusSmashDebuff) or (Player:BuffP(S.CrushingAssaultBuff) and S.FervorofBattle:IsAvailable())) then
      return S.Whirlwind:Cast()
    end
    -- whirlwind,if=buff.deadly_calm.up|rage>60
    if S.Whirlwind:IsReadyP() and (Player:BuffP(S.DeadlyCalmBuff) or Player:Rage() > 60) then
      return S.Whirlwind:Cast()
    end
    -- overpower
    if S.Overpower:IsCastableP() then
      return S.Overpower:Cast()
    end
    -- whirlwind
    if S.Whirlwind:IsReadyP() then
      return S.Whirlwind:Cast()
    end
  end
  
  Hac = function()
    -- rend,if=remains<=duration*0.3&(!raid_event.adds.up|buff.sweeping_strikes.up)
    if S.Rend:IsReadyP() and (Target:DebuffRemainsP(S.RendDebuff) <= S.RendDebuff:BaseDuration() * 0.3 and (not (Cache.EnemiesCount[8] > 1) or Player:BuffP(S.SweepingStrikesBuff))) then
      return S.Rend:Cast()
    end
    -- skullsplitter,if=rage<60&(cooldown.deadly_calm.remains>3|!talent.deadly_calm.enabled)
    if S.Skullsplitter:IsCastableP() and (Player:Rage() < 60 and (S.DeadlyCalm:CooldownRemainsP() > 3 or not S.DeadlyCalm:IsAvailable())) then
      return S.Skullsplitter:Cast()
    end
    -- deadly_calm,if=(cooldown.bladestorm.remains>6|talent.ravager.enabled&cooldown.ravager.remains>6)&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.DeadlyCalm:IsCastableP() and ((S.Bladestorm:CooldownRemainsP() > 6 or S.Ravager:IsAvailable() and S.Ravager:CooldownRemainsP() > 6) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      return S.DeadlyCalm:Cast()
    end
    -- ravager,if=(raid_event.adds.up|raid_event.adds.in>target.time_to_die)&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.Ravager:IsCastableP() and RubimRH.CDsON() and (((Cache.EnemiesCount[8] > 1) or 10000000000 > Target:TimeToDie()) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      return S.Ravager:Cast()
    end
    -- colossus_smash,if=raid_event.adds.up|raid_event.adds.in>40|(raid_event.adds.in>20&talent.anger_management.enabled)
    if S.ColossusSmash:IsCastableP() and ((Cache.EnemiesCount[8] > 1) or 10000000000 > 40 or (10000000000 > 20 and S.AngerManagement:IsAvailable())) then
      return S.ColossusSmash:Cast()
    end
    -- warbreaker,if=raid_event.adds.up|raid_event.adds.in>40|(raid_event.adds.in>20&talent.anger_management.enabled)
    if S.Warbreaker:IsCastableP() and RubimRH.CDsON() and ((Cache.EnemiesCount[8] > 1) or 10000000000 > 40 or (10000000000 > 20 and S.AngerManagement:IsAvailable())) then
      return S.Warbreaker:Cast()
    end
    -- bladestorm,if=(debuff.colossus_smash.up&raid_event.adds.in>target.time_to_die)|raid_event.adds.up&((debuff.colossus_smash.remains>4.5&!azerite.test_of_might.enabled)|buff.test_of_might.up)
    if S.Bladestorm:IsReady() and RubimRH.CDsON() and ((Target:DebuffP(S.ColossusSmashDebuff) and 10000000000 > Target:TimeToDie()) or (Cache.EnemiesCount[8] > 1) and ((Target:DebuffRemainsP(S.ColossusSmashDebuff) > 4.5 and not S.TestofMight:AzeriteEnabled()) or Player:BuffP(S.TestofMightBuff))) then
      return S.Bladestorm:Cast()
    end
    -- overpower,if=!raid_event.adds.up|(raid_event.adds.up&azerite.seismic_wave.enabled)
    if S.Overpower:IsCastableP() and (not (Cache.EnemiesCount[8] > 1) or ((Cache.EnemiesCount[8] > 1) and S.SeismicWave:AzeriteEnabled())) then
      return S.Overpower:Cast()
    end
    -- cleave,if=spell_targets.whirlwind>2
    if S.Cleave:IsReadyP() and (Cache.EnemiesCount[8] > 2) then
      return S.Cleave:Cast()
    end
    -- execute,if=!raid_event.adds.up|(!talent.cleave.enabled&dot.deep_wounds.remains<2)|buff.sudden_death.react
    if S.Execute:IsReadyMorph() and (not (Cache.EnemiesCount[8] > 1) or (not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2) or bool(Player:BuffStackP(S.SuddenDeathBuff))) then
      return S.Execute:Cast()
    end
    -- mortal_strike,if=!raid_event.adds.up|(!talent.cleave.enabled&dot.deep_wounds.remains<2)
    if S.MortalStrike:IsReadyP() and (not (Cache.EnemiesCount[8] > 1) or (not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2)) then
      return S.MortalStrike:Cast()
    end
    -- whirlwind,if=raid_event.adds.up
    if S.Whirlwind:IsReadyP() and (Cache.EnemiesCount[8] > 1) then
      return S.Whirlwind:Cast()
    end
    -- overpower
    if S.Overpower:IsCastableP() then
      return S.Overpower:Cast()
    end
    -- whirlwind,if=talent.fervor_of_battle.enabled
    if S.Whirlwind:IsReadyP() and (S.FervorofBattle:IsAvailable()) then
      return S.Whirlwind:Cast()
    end
    -- slam,if=!talent.fervor_of_battle.enabled&!raid_event.adds.up
    if S.Slam:IsReadyP() and (not S.FervorofBattle:IsAvailable() and not (Cache.EnemiesCount[8] > 1)) then
      return S.Slam:Cast()
    end
  end
  
  SingleTarget = function()
    -- rend,if=remains<=duration*0.3&debuff.colossus_smash.down
    if S.Rend:IsReadyP() and (Target:DebuffRemainsP(S.RendDebuff) <= S.RendDebuff:BaseDuration() * 0.3 and Target:DebuffDownP(S.ColossusSmashDebuff)) then
      return S.Rend:Cast()
    end
    -- skullsplitter,if=rage<60&buff.deadly_calm.down&buff.memory_of_lucid_dreams.down
    if S.Skullsplitter:IsCastableP() and (Player:Rage() < 60 and Player:BuffDownP(S.DeadlyCalmBuff) and Player:BuffDownP(S.MemoryOfLucidDreams)) then
      return S.Skullsplitter:Cast()
    end
    -- ravager,if=!buff.deadly_calm.up&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
    if S.Ravager:IsCastableP() and RubimRH.CDsON() and (not Player:BuffP(S.DeadlyCalmBuff) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
      return S.Ravager:Cast()
    end
    -- colossus_smash,if=!essence.memory_of_lucid_dreams.major|(buff.memory_of_lucid_dreams.up|cooldown.memory_of_lucid_dreams.remains>10)
    if S.ColossusSmash:IsCastableP() and (not S.MemoryOfLucidDreams:IsAvailable() or (Player:BuffP(S.MemoryOfLucidDreams) or S.MemoryOfLucidDreams:CooldownRemainsP() > 10)) then
      return S.ColossusSmash:Cast()
    end
    -- warbreaker,if=!essence.memory_of_lucid_dreams.major|(buff.memory_of_lucid_dreams.up|cooldown.memory_of_lucid_dreams.remains>10)
    if S.Warbreaker:IsCastableP() and RubimRH.CDsON() and (not S.MemoryOfLucidDreams:IsAvailable() or (Player:BuffP(S.MemoryOfLucidDreams) or S.MemoryOfLucidDreams:CooldownRemainsP() > 10)) then
      return S.Warbreaker:Cast()
    end
    -- deadly_calm
    if S.DeadlyCalm:IsCastableP() then
      return S.DeadlyCalm:Cast()
    end
    -- execute,if=buff.sudden_death.react
    if S.Execute:IsReadyMorph() and (bool(Player:BuffStackP(S.SuddenDeathBuff))) then
      return S.Execute:Cast()
    end
    -- bladestorm,if=cooldown.mortal_strike.remains&(!talent.deadly_calm.enabled|buff.deadly_calm.down)&((debuff.colossus_smash.up&!azerite.test_of_might.enabled)|buff.test_of_might.up)&buff.memory_of_lucid_dreams.down
    if S.Bladestorm:IsReady() and RubimRH.CDsON() and (bool(S.MortalStrike:CooldownRemainsP()) and (not S.DeadlyCalm:IsAvailable() or Player:BuffDownP(S.DeadlyCalmBuff)) and ((Target:DebuffP(S.ColossusSmashDebuff) and not S.TestofMight:AzeriteEnabled()) or Player:BuffP(S.TestofMightBuff)) and Player:BuffDownP(S.MemoryOfLucidDreams)) then
      return S.Bladestorm:Cast()
    end
    -- cleave,if=spell_targets.whirlwind>2
    if S.Cleave:IsReadyP() and (Cache.EnemiesCount[8] > 2) then
      return S.Cleave:Cast()
    end
    -- overpower,if=rage<30&buff.memory_of_lucid_dreams.up&debuff.colossus_smash.up
    if S.Overpower:IsCastableP() and (Player:Rage() < 30 and Player:BuffP(S.MemoryOfLucidDreams) and Target:DebuffP(S.ColossusSmashDebuff)) then
      return S.Overpower:Cast()
    end
    -- mortal_strike
    if S.MortalStrike:IsReadyP() then
      return S.MortalStrike:Cast()
    end
    -- whirlwind,if=talent.fervor_of_battle.enabled&(buff.memory_of_lucid_dreams.up|buff.deadly_calm.up)
    if S.Whirlwind:IsReadyP() and (S.FervorofBattle:IsAvailable() and (Player:BuffP(S.MemoryOfLucidDreams) or Player:BuffP(S.DeadlyCalmBuff))) then
      return S.Whirlwind:Cast()
    end
    -- overpower
    if S.Overpower:IsCastableP() then
      return S.Overpower:Cast()
    end
    -- whirlwind,if=talent.fervor_of_battle.enabled
    if S.Whirlwind:IsReadyP() and (S.FervorofBattle:IsAvailable()) then
      return S.Whirlwind:Cast()
    end
    -- slam,if=!talent.fervor_of_battle.enabled
    if S.Slam:IsReadyP() and (not S.FervorofBattle:IsAvailable()) then
      return S.Slam:Cast()
    end
  end
    -- Protect against interrupt of channeled spells
  if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) or Player:IsChanneling() then
      return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
  end 
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); 
	if ShouldReturn then 
	    return ShouldReturn; 
	end
  end
  -- In Combat
  if RubimRH.TargetIsValid() then
    -- Charge
    if Target:MinDistanceToPlayer(true) >= 8 and Target:MinDistanceToPlayer(true) <= 40 and S.Charge:IsReady() and not Target:IsQuestMob() and S.Charge:TimeSinceLastCast() >= Player:GCD() then
        return S.Charge:Cast()
    end
	local ShouldReturn = Essences(); 
	if ShouldReturn and (true) then 
	    return ShouldReturn; 
	end
	       -- execute,if=buff.sudden_death.react
        if S.Execute:IsReadyMorph() and (bool(Player:Buff(S.SuddenDeathBuff))) then
            return S.Execute:Cast()
        end
	-- Victory Rush db.profil
    if S.VictoryRush:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].sk1 then
        return S.VictoryRush:Cast()
    end
	-- Victory Rush -> Buff about to expire
    if Player:Buff(S.Victorious) and Player:BuffRemains(S.Victorious) <= 2 and S.VictoryRush:IsReady("Melee") then
        return S.VictoryRush:Cast()
    end
	-- Victory Rush - Impending Victory
    if S.ImpendingVictory:IsReadyMorph() and Player:HealthPercentage() <= RubimRH.db.profile[71].sk2 then
        return S.VictoryRush:Cast()
    end
    -- Rallying Cry
    if S.RallyingCry:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].sk4 then
        return S.RallyingCry:Cast()
    end
    -- interrupt
    if S.Pummel:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Pummel:Cast()
    end
    -- auto_attack
    -- potion
    --if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions then
    --  if RubimRH.CastSuggested(I.BattlePotionofStrength:Cast()battle_potion_of_strength 354"; end
   -- end
    -- blood_fury,if=debuff.colossus_smash.up
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
      return S.BloodFury:Cast()
    end
    -- berserking,if=debuff.colossus_smash.up
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
      return S.Berserking:Cast()
    end
    -- arcane_torrent,if=debuff.colossus_smash.down&cooldown.mortal_strike.remains>1.5&rage<50
    if S.ArcaneTorrent:IsCastableP() and RubimRH.CDsON() and (Target:DebuffDownP(S.ColossusSmashDebuff) and S.MortalStrike:CooldownRemainsP() > 1.5 and Player:Rage() < 50) then
      return S.ArcaneTorrent:Cast()
    end
    -- lights_judgment,if=debuff.colossus_smash.down
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
      return S.LightsJudgment:Cast()
    end
    -- fireblood,if=debuff.colossus_smash.up
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
      return S.Fireblood:Cast()
    end
    -- ancestral_call,if=debuff.colossus_smash.up
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
      return S.AncestralCall:Cast()
    end
    -- avatar,if=cooldown.colossus_smash.remains<8|(talent.warbreaker.enabled&cooldown.warbreaker.remains<8)
    if S.Avatar:IsCastableP() and RubimRH.CDsON() and (S.ColossusSmash:CooldownRemainsP() < 8 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 8)) then
      return S.Avatar:Cast()
    end
    -- sweeping_strikes,if=spell_targets.whirlwind>1&(cooldown.bladestorm.remains>10|cooldown.colossus_smash.remains>8|azerite.test_of_might.enabled)
    if S.SweepingStrikes:IsCastableP() and (Cache.EnemiesCount[8] > 1 and (S.Bladestorm:CooldownRemainsP() > 10 or S.ColossusSmash:CooldownRemainsP() > 8 or S.TestofMight:AzeriteEnabled())) then
      return S.SweepingStrikes:Cast()
    end
    -- blood_of_the_enemy,if=buff.test_of_might.up|(debuff.colossus_smash.up&!azerite.test_of_might.enabled)
    if S.BloodOfTheEnemy:IsCastableP() and (Player:BuffP(S.TestofMightBuff) or (Target:DebuffP(S.ColossusSmashDebuff) and not S.TestofMight:IsAvailable())) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast,if=!debuff.colossus_smash.up&!buff.test_of_might.up
    if S.PurifyingBlast:IsCastableP() and (not Target:DebuffP(S.ColossusSmashDebuff) and not Player:BuffP(S.TestofMightBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space,if=!debuff.colossus_smash.up&!buff.test_of_might.up
    if S.RippleInSpace:IsCastableP() and (not Target:DebuffP(S.ColossusSmashDebuff) and not Player:BuffP(S.TestofMightBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- focused_azerite_beam,if=!debuff.colossus_smash.up&!buff.test_of_might.up
    if S.FocusedAzeriteBeam:IsCastableP() and (not Target:DebuffP(S.ColossusSmashDebuff) and not Player:BuffP(S.TestofMightBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame,if=!debuff.colossus_smash.up&!buff.test_of_might.up&dot.concentrated_flame_burn.remains=0
    -- Need debuff spell ID for ConcentratedFlame higher ranks
    if S.ConcentratedFlame:IsCastableP() and (not Target:DebuffP(S.ColossusSmashDebuff) and not Player:BuffP(S.TestofMightBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force,if=buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForce)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth,if=cooldown.colossus_smash.remains<10
    if S.GuardianOfAzeroth:IsCastableP() and (S.ColossusSmash:CooldownRemainsP() < 10) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams,if=cooldown.colossus_smash.remains<3
    if S.MemoryOfLucidDreams:IsCastableP() and (S.ColossusSmash:CooldownRemainsP() < 3) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- run_action_list,name=hac,if=raid_event.adds.exists
    if (Cache.EnemiesCount[8] > 1) then
      return Hac();
    end
    -- run_action_list,name=five_target,if=spell_targets.whirlwind>4
    if (Cache.EnemiesCount[8] > 4) then
      return FiveTarget();
    end
    -- run_action_list,name=execute,if=(talent.massacre.enabled&target.health.pct<35)|target.health.pct<20
    if ((S.Massacre:IsAvailable() and Target:HealthPercentage() < 35) or Target:HealthPercentage() < 20) then
      return Execute();
    end
    -- run_action_list,name=single_target
    if (true) then
      return SingleTarget();
    end    
  end
end

RubimRH.Rotation.SetAPL(71, APL);

local function PASSIVE()
    if S.DiebytheSword:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].sk3 then
        return S.DiebytheSword:Cast()
    end

    return RubimRH.Shared()
end


local function PvP()
    if select(2, IsInInstance()) == "arena" then

        for i, arenaTarget in pairs(Arena) do
            if not arenaTarget:IsImmune() and arenaTarget:CastingHealing() and arenaTarget:IsInterruptible() and S.Pummel:IsCastable() and arenaTarget:MinDistanceToPlayer() <= 5 then
                RubimRH.getArenaTarget(arenaTarget)
            end

            if not arenaTarget:IsImmune() and arenaTarget:CastingCC() and arenaTarget:IsInterruptible() and S.Pummel:IsCastable() and arenaTarget:MinDistanceToPlayer() <= 5 then
                RubimRH.getArenaTarget(arenaTarget)
            end

            if not arenaTarget:IsImmune() and arenaTarget:CastingCC() and arenaTarget:IsInterruptible() and S.SpellReflection:IsCastable() and arenaTarget:CastPercentage() >= randomGenerator("Reflect") then
                RubimRH.getArenaTarget(arenaTarget)
            end

            if not arenaTarget:IsImmune() and S.Rend:IsCastable() and arenaTarget:MinDistanceToPlayer(true) <= 5 then
                S.Rend:ArenaCast(arenaTarget)
                return
            end

            if not arenaTarget:IsImmune() and S.Disarm:IsCastable() and arenaTarget:IsBursting() and arenaTarget:IsDisarmable() and arenaTarget:MinDistanceToPlayer(true) <= 5 then
                S.Disarm:ArenaCast(arenaTarget)
                return
            end
        end
    end

    if Target:Exists() then
        if S.Execute:IsReadyMorph() and Target:MinDistanceToPlayer(true) >= 8 and Target:MinDistanceToPlayer(true) <= 15 and S.DeathSentence:IsAvailable() then
            return S.Execute:Cast()
        end

        if not Target:IsImmune() and Target:CastingCC() and Target:IsTargeting(Player) and S.SpellReflection:IsCastable() and Target:CastPercentage() >= randomGenerator("Reflect") then
            return S.SpellReflection:Cast()
        end

        if not Target:IsImmune() and Target:IsBursting() and Target:IsDisarmable() and S.Disarm:IsReady("Melee") then
            return S.Disarm:Cast()
        end

        if not Target:IsImmune() and Target:HealthPercentage() <= 50 and S.SharpenBlade:IsReady("Melee") and Target:IsAPlayer() then
            return S.SharpenBlade:Cast()
        end
    end
end
RubimRH.Rotation.SetPvP(71, PvP);

RubimRH.Rotation.SetPASSIVE(71, PASSIVE);