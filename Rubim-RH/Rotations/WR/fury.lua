--- Localize Vars
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
local mainAddon = RubimRH

-- Spells
RubimRH.Spell[72] = {
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
    BerserkerRage = Spell(18499),
    Bloodthirst = Spell(23881),
    Charge = Spell(100),
    --Execute = Spell(5308),
    HeroicLeap = Spell(6544),
    HeroicThrow = Spell(57755),
    RagingBlow = Spell(85288),
    Rampage = Spell(184367),
    Recklessness = Spell(1719),
    VictoryRush = Spell(34428),
    Whirlwind = Spell(190411),
    WhirlwindPassive = Spell(12950),
    WhirlwindBuff = Spell(85739),
    EnragedRegeneration = Spell(184364),
    Enrage = Spell(184362),
    -- Talents
    WarMachine = Spell(262231),
    EndlessRage = Spell(202296),
    FreshMeat = Spell(215568),
    DoubleTime = Spell(103827),
    ImpendingVictory = Spell(202168),
    StormBolt = Spell(107570),
    InnerRage = Spell(215573),
    FuriousSlash = Spell(100130),
    FuriousSlashBuff = Spell(202539),
    Carnage = Spell(202922),
    Massacre = Spell(206315),
    FrothingBerserker = Spell(215571),
    MeatCleaver = Spell(280392),
    MeatCleaverBuff = Spell(280392),
    DragonRoar = Spell(118000),
    Bladestorm = Spell(46924),
    RecklessAbandon = Spell(202751),
    AngerManagement = Spell(152278),
    Siegebreaker = Spell(280772),
    SiegebreakerTalent = Spell(16037),
    SiegebreakerDebuff = Spell(280773),
    SuddenDeath = Spell(280721),
    SuddenDeathBuff = Spell(280776),
    SuddenDeathBuffLeg = Spell(225947),
    Victorious = Spell(32216),
    VictoryRush = Spell(34428),
    -- Defensive
    RallyingCry = Spell(97462),
    -- Utility
    Pummel = Spell(6552),
    PiercingHowl = Spell(12323),
    -- Legendaries
    FujiedasFury = Spell(207776),
    StoneHeart = Spell(225947),
    -- Misc
    UmbralMoonglaives = Spell(242553),
    SpellReflection = Spell(216890),
    -- Azerite
    AzeriteColdSteelHotBlood = Spell(288080),
	
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
}

local S = RubimRH.Spell[72]

if not Item.Warrior then
    Item.Warrior = {}
end
Item.Warrior.Fury = {
    OldWar = Item(127844),
    KazzalaxFujiedasFury = Item(137053)
};

local I = Item.Warrior.Fury;
-- Rotation Var
local ShouldReturn; -- Used to get the return string
local EnemyRanges = { "Melee", 5, 12 }
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

local function num(val)
    if val then
        return 1
    else
        return 0
    end
end

local function bool(val)
    return val ~= 0
end

S.ExecuteDefault = Spell(5308)
S.ExecuteMassacre = Spell(280735)
local function UpdateExecuteID()
    S.Execute = S.Massacre:IsAvailable() and S.ExecuteMassacre or S.ExecuteDefault
end

local OffensiveCDs = {
   
    S.Recklessness,
    S.Siegebreaker,
    S.Bladestorm,
    
    
}

local function UpdateCDs()
    if RubimRH.CDsON() then
        for i, spell in pairs(OffensiveCDs) do
            if not spell:IsEnabledCD() then
                RubimRH.delSpellDisabledCD(spell:ID())
            end
        end

    end
    if not RubimRH.CDsON() then
        for i, spell in pairs(OffensiveCDs) do
            if spell:IsEnabledCD() then
                RubimRH.addSpellDisabledCD(spell:ID())
            end
        end
    end
end

local function ExecuteRange ()
	return S.Massacre:IsAvailable() and 35 or 20;
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

local function APL()
    local Precombat, Movement, SingleTarget, AoE
    UpdateRanges()
    UpdateCDs()
    UpdateExecuteID()
    
	Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- potion
        if S.BattleShout:IsCastable() and not Player:BuffPvP(S.BattleShout) then
            return S.BattleShout:Cast()
        end
    end

    SingleTarget = function()
         --siegebreaker
        if S.Siegebreaker:IsReady("Melee") then
            return S.Siegebreaker:Cast()
        end
        -- rampage,if=buff.recklessness.up|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
        if S.Rampage:IsReady("Melee") and (Player:BuffP(S.Recklessness) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.Enrage) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.Enrage) < Player:GCD() or Player:Rage() > 90))) then
            return S.Rampage:Cast()
        end
        -- execute,if=buff.enrage.upSuddenDeathBuff
        if S.Execute:CooldownRemainsP() < 0.1 and (Player:BuffP(S.Enrage)) and (Target:HealthPercentage() < ExecuteRange ()) then
            return S.Execute:Cast()
        end
        -- bladestorm,if=prev_gcd.1.rampage
        if S.Bladestorm:IsReady() and (Player:PrevGCDP(1, S.Rampage)) then
            return S.Bladestorm:Cast()
        end
        -- bloodthirst,if=buff.enrage.down|azerite.cold_steel_hot_blood.rank>1
        if S.Bloodthirst:IsReady("Melee") and Player:BuffDownP(S.Enrage) then
            return S.Bloodthirst:Cast()
        end
        -- raging_blow,if=charges=2
        if S.RagingBlow:IsReady("Melee") and (S.RagingBlow:ChargesP() == 2) then
            return S.RagingBlow:Cast()
        end
        -- bloodthirst
        if S.Bloodthirst:IsReady("Melee") then
            return S.Bloodthirst:Cast()
        end
		-- dragon_roar,if=buff.enrage.up - fix
	    if S.DragonRoar:IsReady("Melee") and S.DragonRoar:IsAvailable() and Player:BuffP(S.Enrage) and S.DragonRoar:CooldownRemainsP() < 1 then
            return S.DragonRoar:Cast()
        end
        -- dragon_roar,if=buff.enrage.up
      --  if S.DragonRoar:IsCastableP() and S.DragonRoar:IsAvailable() and Player:BuffRemainsP(S.Enrage) > Player:GCD() then
      --      return S.DragonRoar:Cast()
      --  end
        -- raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
        if S.RagingBlow:IsReady("Melee") and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
            return S.RagingBlow:Cast()
        end
        -- furious_slash,if=talent.furious_slash.enabled
        if S.FuriousSlash:IsReady("Melee") and (S.FuriousSlash:IsAvailable()) then
            return S.FuriousSlash:Cast()
        end
        -- whirlwind
        if S.Whirlwind:IsReady("Melee")  then
            return S.Whirlwind:Cast()
        end
        return 0, 135328
    end


    if Target:MinDistanceToPlayer(true) >= 8 and Target:MinDistanceToPlayer(true) <= 40 and S.Charge:IsReady() and not Target:IsQuestMob() and S.Charge:TimeSinceLastCast() >= Player:GCD() then
        return S.Charge:Cast()
    end

    -- call precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end

  -- combat
  if RubimRH.TargetIsValid() then
	
    if QueueSkill() ~= nil then
        return QueueSkill()
    end
	
-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn and (true) then return ShouldReturn; end
	-- Battleshout in combat refresh
	if S.BattleShout:IsCastable() and not Player:BuffP(S.BattleShout) then
        return S.BattleShout:Cast()
    end
	-- execute,if=buff.enrage.up
    if S.Execute:CooldownRemainsP() < 0.1 and Player:BuffRemainsP(S.SuddenDeathBuff) > 1 then
        return S.Execute:Cast()
    end
	
    if S.Pummel:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Pummel:Cast()
    end

    if S.Charge:IsReady() and Target:MaxDistanceToPlayer(true) >= 8 then
        return S.Charge:Cast()
    end

    if S.VictoryRush:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[72].sk1 then
        return S.VictoryRush:Cast()
    end
	-- Victory Rush -> Buff about to expire
    if Player:Buff(S.Victorious) and Player:BuffRemains(S.Victorious) <= 2 and S.VictoryRush:IsReady("Melee") then
        return S.VictoryRush:Cast()
    end
    if S.ImpendingVictory:IsReadyMorph() and Player:HealthPercentage() <= RubimRH.db.profile[72].sk2 then
        return S.VictoryRush:Cast()
    end

    if S.RallyingCry:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[72].sk3 then
        return S.RallyingCry:Cast()
    end

    if S.Bloodthirst:IsReady("Melee") and Player:HealthPercentage() <= 80 and Player:Buff(S.EnragedRegeneration) then
        return S.Bloodthirst:Cast()
    end
    -- furious_slash,if=talent.furious_slash.enabled&(buff.furious_slash.stack<3|buff.furious_slash.remains<3|(cooldown.recklessness.remains<3&buff.furious_slash.remains<9))
    if S.FuriousSlash:IsReady() and (S.FuriousSlash:IsAvailable() and (Player:BuffStackP(S.FuriousSlashBuff) < 3 or Player:BuffRemainsP(S.FuriousSlashBuff) < 3 or (S.Recklessness:CooldownRemainsP() < 3 and Player:BuffRemainsP(S.FuriousSlashBuff) < 9))) then
        return S.FuriousSlash:Cast()
    end
    -- rampage,if=cooldown.recklessness.remains<3
    if S.Rampage:IsReady("Melee") and (S.Recklessness:CooldownRemainsP() < 3) then
        return S.Rampage:Cast()
    end
    -- recklessness,if=!talent.siegebreaker.enabled|(cooldown.siegebreaker.remains<1|cooldown.siegebreaker.remains>5)
    if S.Recklessness:IsReady() and ((not S.Siegebreaker:IsAvailable()) or (S.Siegebreaker:CooldownRemainsP() < 1 or S.Siegebreaker:CooldownRemainsP() > 5)) then
        return S.Recklessness:Cast()
    end
    -- whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
    if S.Whirlwind:IsReady("Melee") and Cache.EnemiesCount[5] > 1 and not Player:BuffP(S.WhirlwindBuff) and S.WhirlwindPassive:IsAvailable() then
        return S.Whirlwind:Cast()
    end
    -- use_item,name=ramping_amplitude_gigavolt_engine
    -- blood_fury,if=buff.recklessness.up
    if S.BloodFury:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.Recklessness)) then
        return S.BloodFury:Cast()
    end
    -- berserking,if=buff.recklessness.up
    if S.Berserking:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.Recklessness)) then
        return S.Berserking:Cast()
    end
    -- lights_judgment,if=buff.recklessness.down
    if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (Player:BuffDownP(S.Recklessness)) then
        return S.LightsJudgment:Cast()
    end
    -- fireblood,if=buff.recklessness.up
    if S.Fireblood:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.Recklessness)) then
        return S.Fireblood:Cast()
    end
    -- ancestral_call,if=buff.recklessness.up
    if S.AncestralCall:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.Recklessness)) then
        return S.AncestralCall:Cast()
    end

    -- run_action_list,name=single_target
    if (true) then
        return SingleTarget();
    end
	
  end
  return 0, 135328
end


RubimRH.Rotation.SetAPL(72, APL);

local function PASSIVE()
   -- print(active_enemies());
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(72, PASSIVE);
