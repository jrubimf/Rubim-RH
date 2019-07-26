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
local mainAddon = RubimRH
--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[72] = {
  RecklessnessBuff                      = Spell(1719),
  Recklessness                          = Spell(1719),
  FuriousSlashBuff                      = Spell(202539),
  FuriousSlash                          = Spell(100130),
  RecklessAbandon                       = Spell(202751),
  HeroicLeap                            = Spell(6544),
  Siegebreaker                          = Spell(280772),
  Rampage                               = Spell(184367),
  FrothingBerserker                     = Spell(215571),
  Carnage                               = Spell(202922),
  EnrageBuff                            = Spell(184362),
  Massacre                              = Spell(206315),
  --Execute                               = MultiSpell(5308, 280735),
  Bloodthirst                           = Spell(23881),
  RagingBlow                            = Spell(85288),
  Bladestorm                            = Spell(46924),
  SiegebreakerDebuff                    = Spell(280773),
  DragonRoar                            = Spell(118000),
  Whirlwind                             = Spell(190411),
  Charge                                = Spell(100),
  FujiedasFuryBuff                      = Spell(207775),
  MeatCleaverBuff                       = Spell(85739),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  Pummel                                = Spell(6552),
  IntimidatingShout                     = Spell(5246),
  ColdSteelHotBlood                     = Spell(288080),
  ConcentratedFlameBurn                 = Spell(295368),
  RecklessForceBuff                     = Spell(302932),
  RazorCoralDebuff                      = Spell(303568),
  ConductiveInkDebuff                   = Spell(302565),
  BattleShout                           = Spell(6673),
  Victorious                            = Spell(32216),
  VictoryRush                           = Spell(34428),
  SuddenDeath                           = Spell(280721),
  SuddenDeathBuff                       = Spell(280776),
  ImpendingVictory                      = Spell(202168),
  -- Defensive
  RallyingCry                           = Spell(97462),
  -- Misc
  UmbralMoonglaives                     = Spell(242553),
  SpellReflection                       = Spell(216890),
  CyclotronicBlast                      = Spell(293491),
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
  CondensedLifeforce                    = Spell(295834),
  CondensedLifeforce2                   = Spell(299354),
  CondensedLifeforce3                   = Spell(299357),
}

local S = RubimRH.Spell[72]

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Fury = {
  PotionofUnbridledFury            = Item(169299),
  AshvanesRazorCoral               = Item(169311)
};
local I = Item.Warrior.Fury;

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

S.ExecuteDefault    = Spell(5308)
S.ExecuteMassacre   = Spell(280735)

local function UpdateExecuteID()
  S.Execute = S.Massacre:IsAvailable() and S.ExecuteMassacre or S.ExecuteDefault
end

--HL.RegisterNucleusAbility(46924, 8, 6)               -- Bladestorm
--HL.RegisterNucleusAbility(118000, 12, 6)             -- Dragon Roar
--HL.RegisterNucleusAbility(190411, 8, 6)              -- Whirlwind

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
  S.CondensedLifeforce = S.CondensedLifeforce2:IsAvailable() and S.CondensedLifeforce2 or S.CondensedLifeforce
  S.CondensedLifeforce = S.CondensedLifeforce3:IsAvailable() and S.CondensedLifeforce3 or S.CondensedLifeforce
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

local function ExecuteRange()
	return S.Massacre:IsAvailable() and 35 or 20;
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat_DBM, Precombat, Movement, SingleTarget
  UpdateRanges()
  DetermineEssenceRanks()
  UpdateExecuteID()
  
  Precombat_DBM = function()
      -- flask
      -- food
      -- augmentation
      -- snapshot_stats
      -- potion
      if S.BattleShout:IsCastable() and not Player:BuffPvP(S.BattleShout) then
          return S.BattleShout:Cast()
      end
	--Prepots
      if I.PotionofUnbridledFury:IsReady() and RubimRH.DBM_PullTimer() > 0.1 + Player:GCD() and RubimRH.DBM_PullTimer() < 0.5 + Player:GCD() then
          return 967532
      end
	  -- memory_of_lucid_dreams
      if S.MemoryOfLucidDreams:IsCastableP() and RubimRH.PerfectPullON() and RubimRH.DBM_PullTimer() > 0.01 and RubimRH.DBM_PullTimer() < 0.1 then
        return S.UnleashHeartOfAzeroth:Cast()
      end
      -- guardian_of_azeroth
      if S.GuardianOfAzeroth:IsCastableP() and RubimRH.PerfectPullON() and RubimRH.DBM_PullTimer() > 0.01 and RubimRH.DBM_PullTimer() < 0.1 then
        return S.UnleashHeartOfAzeroth:Cast()
      end
      -- recklessness,if=!talent.furious_slash.enabled
      if S.Recklessness:IsReady() and (not S.FuriousSlash:IsAvailable()) then
        return S.Recklessness:Cast()
      end
	  -- Charge to pull
	  if S.Charge:IsReady() and Target:MaxDistanceToPlayer(true) >= 8 and RubimRH.DBM_PullTimer() > 0.01 and RubimRH.DBM_PullTimer() < 0.1 then
          return S.Charge:Cast()
      end
	  -- bloodthirst
      if S.Bloodthirst:IsReady("Melee") and Target:MaxDistanceToPlayer(true) < 8 and RubimRH.DBM_PullTimer() > 0.01 and RubimRH.DBM_PullTimer() < 0.1 then
          return S.Bloodthirst:Cast()
      end		
  end
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
      -- potion
      -- memory_of_lucid_dreams
      if S.MemoryOfLucidDreams:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
      end
      -- guardian_of_azeroth
      if S.GuardianOfAzeroth:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
      end
      -- recklessness,if=!talent.furious_slash.enabled
      if S.Recklessness:IsReady() and (not S.FuriousSlash:IsAvailable()) then
        return S.Recklessness:Cast()
      end
  end
  
  Movement = function()
    -- heroic_leap
    if S.HeroicLeap:IsCastableP() then
      return S.HeroicLeap:Cast()
    end
  end
  
  SingleTarget = function()
    -- siegebreaker
    if S.Siegebreaker:IsReady("Melee") and RubimRH.CDsON() then
      return S.Siegebreaker:Cast()
    end
        -- rampage,if=buff.recklessness.up|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
        if S.Rampage:IsReady("Melee") and (Player:BuffP(S.Recklessness) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.Enrage) < Player:GCD() or Player:Rage() > 90))) then
            return S.Rampage:Cast()
        end
    -- execute,if=buff.enrage.upSuddenDeathBuff
    --if S.Execute:CooldownRemainsP() < 0.1 and (Player:BuffP(S.Enrage)) and (Target:HealthPercentage() < ExecuteRange()) then
    --    return S.Execute:Cast()
    --end
    -- bladestorm,if=prev_gcd.1.rampage
    if S.Bladestorm:IsReady() and RubimRH.CDsON() and (Player:PrevGCDP(1, S.Rampage)) then
      return S.Bladestorm:Cast()
    end
    -- bloodthirst,if=buff.enrage.down|azerite.cold_steel_hot_blood.rank>1
    if S.Bloodthirst:IsCastableP("Melee") and (Player:BuffDownP(S.EnrageBuff) or S.ColdSteelHotBlood:AzeriteRank() > 1) then
      return S.Bloodthirst:Cast()
    end
    -- dragon_roar,if=buff.enrage.up
    if S.DragonRoar:IsReady("Melee") and RubimRH.CDsON() and (Player:BuffP(S.EnrageBuff)) then
      return S.DragonRoar:Cast()
    end
    -- raging_blow,if=charges=2
    if S.RagingBlow:IsReady("Melee") and (S.RagingBlow:ChargesP() == 2) then
      return S.RagingBlow:Cast()
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP("Melee") then
      return S.Bloodthirst:Cast()
    end
    -- raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
    if S.RagingBlow:IsReady("Melee") and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
      return S.RagingBlow:Cast()
    end
    -- furious_slash,if=talent.furious_slash.enabled
    if S.FuriousSlash:IsReady("Melee") and (S.FuriousSlash:IsAvailable()) then
      return S.FuriousSlash:Cast()
    end
    -- whirlwind
    if S.Whirlwind:IsReady("Melee") then
      return S.Whirlwind:Cast()
    end
  end
  
    -- Protect against interrupt of channeled spells
    if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) or Player:IsChanneling() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end 
     
	-- Charge if out of range and out of combat
    if Target:MinDistanceToPlayer(true) >= 8 and RubimRH.AutoAttackON() and Target:MinDistanceToPlayer(true) <= 40 and S.Charge:IsReady() and not Target:IsQuestMob() and S.Charge:TimeSinceLastCast() >= Player:GCD() then
        return S.Charge:Cast()
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
  
  -- In Combat
  if RubimRH.TargetIsValid() then
    
	-- QueueSpell system
	if QueueSkill() ~= nil then
        return QueueSkill()
    end
	-- Battleshout in combat refresh
	if S.BattleShout:IsCastable() and not Player:BuffP(S.BattleShout) then
        return S.BattleShout:Cast()
    end
	-- execute,if=buff.enrage.up
    if S.Execute:CooldownRemainsP() < 0.1 and Player:BuffRemainsP(S.SuddenDeathBuff) > 1 then
        return S.Execute:Cast()
    end
	-- Interrupt 
    if S.Pummel:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Pummel:Cast()
    end
    -- Charge if out of range and out of combat
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
    --Rallying Cry
    if S.RallyingCry:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[72].sk3 then
        return S.RallyingCry:Cast()
    end
    -- run_action_list,name=movement,if=movement.distance>5
    -- heroic_leap,if=(raid_event.movement.distance>25&raid_event.movement.in>45)
    if ((not Target:IsInRange("Melee")) and Target:IsInRange(S.HeroicLeap)) then
      return Movement();
    end
    -- potion
    -- furious_slash,if=talent.furious_slash.enabled&(buff.furious_slash.stack<3|buff.furious_slash.remains<3|(cooldown.recklessness.remains<3&buff.furious_slash.remains<9))
    if S.FuriousSlash:IsReady("Melee") and (S.FuriousSlash:IsAvailable() and (Player:BuffStackP(S.FuriousSlashBuff) < 3 or Player:BuffRemainsP(S.FuriousSlashBuff) < 3 or (S.Recklessness:CooldownRemainsP() < 3 and Player:BuffRemainsP(S.FuriousSlashBuff) < 9))) then
      return S.FuriousSlash:Cast()
    end
    -- rampage,if=cooldown.recklessness.remains<3
    if S.Rampage:IsReadyMorph() and (S.Recklessness:CooldownRemainsP() < 3) then
      return S.Rampage:Cast()
    end
    -- blood_of_the_enemy,if=buff.recklessness.up
    if S.BloodOfTheEnemy:IsCastableP() and (Player:BuffP(S.RecklessnessBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.PurifyingBlast:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.RippleInSpace:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.WorldveinResonance:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- focused_azerite_beam,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.FocusedAzeriteBeam:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame,if=!buff.recklessness.up&!buff.siegebreaker.up&dot.concentrated_flame_burn.remains=0
    if S.ConcentratedFlame:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff) and Target:DebuffDownP(S.ConcentratedFlameBurn)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force,if=buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff)) then
       return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth,if=!buff.recklessness.up
    if S.GuardianOfAzeroth:IsCastableP() and (Player:BuffDownP(S.RecklessnessBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams,if=!buff.recklessness.up
    if S.MemoryOfLucidDreams:IsCastableP() and (Player:BuffDownP(S.RecklessnessBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- recklessness,if=!essence.condensed_lifeforce.major&!essence.blood_of_the_enemy.major|cooldown.guardian_of_azeroth.remains>20|buff.guardian_of_azeroth.up|cooldown.blood_of_the_enemy.remains<gcd
    if S.Recklessness:IsReady() and RubimRH.CDsON() and (not S.CondensedLifeforce:IsAvailable() and not S.BloodOfTheEnemy:IsAvailable() or S.GuardianOfAzeroth:CooldownRemainsP() > 20 or Player:BuffP(S.GuardianOfAzeroth) or S.BloodOfTheEnemy:CooldownRemainsP() < Player:GCD()) then
      return S.Recklessness:Cast()
    end
    -- whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
    if S.Whirlwind:IsReady("Melee") and Cache.EnemiesCount[8] > 1 and not Player:BuffP(S.MeatCleaverBuff) then
      return S.Whirlwind:Cast()
    end
    -- use_item,name=ashvanes_razor_coral,if=!debuff.razor_coral_debuff.up|(target.health.pct<30.1&debuff.conductive_ink_debuff.up)|(!debuff.conductive_ink_debuff.up&buff.memory_of_lucid_dreams.up|prev_gcd.2.recklessness&(buff.guardian_of_azeroth.up|!essence.memory_of_lucid_dreams.major&!essence.condensed_lifeforce.major))
    if I.AshvanesRazorCoral:IsReady() and (Target:DebuffDownP(S.RazorCoralDebuff) or (Target:HealthPercentage() < 30 and Target:DebuffP(S.ConductiveInkDebuff)) or (Target:DebuffDownP(S.ConductiveInkDebuff) and Player:BuffP(S.MemoryOfLucidDreams) or Player:PrevGCDP(2, S.Recklessness) and (Player:BuffP(S.GuardianOfAzeroth) or not S.MemoryOfLucidDreams:IsAvailable() and not S.GuardianOfAzeroth:IsAvailable()))) then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- blood_fury,if=buff.recklessness.up
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      return S.BloodFury:Cast()
    end
    -- berserking,if=buff.recklessness.up
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      return S.Berserking:Cast()
    end
    -- lights_judgment,if=buff.recklessness.down
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() and (Player:BuffDownP(S.RecklessnessBuff)) then
      return S.LightsJudgment:Cast()
    end
    -- fireblood,if=buff.recklessness.up
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
      return S.Fireblood:Cast()
    end
    -- ancestral_call,if=buff.recklessness.up
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
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
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(72, PASSIVE);