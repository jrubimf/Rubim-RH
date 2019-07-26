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

RubimRH.Spell[73] = {
  ThunderClap                           = Spell(6343),
  DemoralizingShout                     = Spell(1160),
  BoomingVoice                          = Spell(202743),
  DragonRoar                            = Spell(118000),
  Revenge                               = Spell(6572),
  FreeRevenge                           = Spell(5302),
  Ravager                               = Spell(228920),
  ShieldBlock                           = Spell(2565),
  ShieldSlam                            = Spell(23922),
  ShieldBlockBuff                       = Spell(132404),
  UnstoppableForce                      = Spell(275336),
  AvatarBuff                            = Spell(107574),
  BraceForImpact                        = Spell(277636),
  DeafeningCrash                        = Spell(272824),
  Devastate                             = Spell(20243),
  Intercept                             = Spell(198304),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  IgnorePain                            = Spell(190456),
  Avatar                                = Spell(107574),
  LastStand                             = Spell(12975),
  LastStandBuff                         = Spell(12975),
  VictoryRush                           = Spell(34428),
  ImpendingVictory                      = Spell(202168),
  Pummel                                = Spell(6552),
  IntimidatingShout                     = Spell(5246),
  RazorCoralDebuff                      = Spell(303568),
  ConcentratedFlameBurn                 = Spell(295368),
  RecklessForceBuff                     = Spell(302932),
  -- Stuns
  Stormbolt                             = Spell(107570),
  Shockwave                             = Spell(46968),	
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
  AnimaofDeath                          = Spell(294926),
  AnimaofDeath2                         = Spell(300002),
  AnimaofDeath3                         = Spell(300003),
  AnimaofLife                           = Spell(294964),
  AnimaofLife2                          = Spell(300004),
  AnimaofLife3                          = Spell(300005),
	
}
local S = RubimRH.Spell[73]

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Protection = {
  SuperiorBattlePotionofStrength   = Item(168500),
  GrongsPrimalRage                 = Item(165574),
  AshvanesRazorCoral               = Item(169311)
};
local I = Item.Warrior.Protection;

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

local function isCurrentlyTanking()
  -- is player currently tanking any enemies within 16 yard radius
  local IsTanking = Player:IsTankingAoE(16) or Player:IsTanking(Target);
  return IsTanking;
end

local function shouldCastIp()
  if Player:Buff(S.IgnorePain) then 
    local castIP = tonumber((GetSpellDescription(190456):match("%d+%S+%d"):gsub("%D","")))
    local IPCap = math.floor(castIP * 1.3);
    local currentIp = Player:Buff(S.IgnorePain, 16, true)

    -- Dont cast IP if we are currently at 50% of IP Cap remaining
    if currentIp  < (0.5 * IPCap) then
      return true
    else
      return false
    end
  else
    -- No IP buff currently
    return true
  end
end

local function offensiveShieldBlock()
  if RubimRH.db.profile[73].UseShieldBlockDefensively == false then  
    return true
  else
    return false
  end
end

local function offensiveRage()
  if RubimRH.db.profile[73].UseRageDefensively == false then  
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
  S.AnimaofDeath = S.AnimaofDeath2:IsAvailable() and S.AnimaofDeath2 or S.AnimaofDeath
  S.AnimaofDeath = S.AnimaofDeath3:IsAvailable() and S.AnimaofDeath3 or S.AnimaofDeath
  S.AnimaofLife = S.AnimaofLife2:IsAvailable() and S.AnimaofLife2 or S.AnimaofLife
  S.AnimaofLife = S.AnimaofLife3:IsAvailable() and S.AnimaofLife3 or S.AnimaofLife
end

--HL.RegisterNucleusAbility(6343, 8, 6)               -- Thunder Clap
--HL.RegisterNucleusAbility(118000, 12, 6)            -- Dragon Roar
--HL.RegisterNucleusAbility(6572, 8, 6)               -- Revenge
--HL.RegisterNucleusAbility(228920, 8, 6)             -- Ravager

--- ======= ACTION LISTS =======
local function APL()
  local Precombat_DBM, Precombat, Aoe, St, Defensive
  local gcdTime = Player:GCD()
  UpdateRanges()
  DetermineEssenceRanks()
  
  Precombat_DBM = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    --if RubimRH.TargetIsValid() then
      -- potion
      if I.SuperiorBattlePotionofStrength:IsReady() and RubimRH.DBM_PullTimer() > 0.01 + Player:GCD() and RubimRH.DBM_PullTimer() < 0.1 + Player:GCD() then
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
    --end
  end
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    --if RubimRH.TargetIsValid() then
      -- potion
      -- memory_of_lucid_dreams
      if S.MemoryOfLucidDreams:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
      end
      -- guardian_of_azeroth
      if S.GuardianOfAzeroth:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
      end
    --end
  end
  
  Defensive = function()
    -- Shield Wall
    if S.ShieldWall:IsCastableP() and Player:HealthPercentage() <= RubimRH.db.profile[73].sk1 then
        return S.ShieldWall:Cast()
    end
	-- Shield Block
    if S.ShieldBlock:IsReadyP() and ((not Player:Buff(S.ShieldBlockBuff)) or Player:BuffRemains(S.ShieldBlockBuff) <= gcdTime + (gcdTime * 0.5)) and (not Player:Buff(S.LastStandBuff)) and Player:Rage() >= 30 then
        return S.ShieldBlock:Cast()
    end
	-- Last Stand
    if S.LastStand:IsCastableP() and not Player:Buff(S.ShieldBlockBuff) and RubimRH.UseLastStandToFillON() and S.ShieldBlock:RechargeP() > (gcdTime * 2) then
        return S.LastStand:Cast()
    end
    -- Last Stand Emergency
    if S.LastStand:IsCastableP() and not Player:Buff(S.ShieldBlockBuff) and Player:HealthPercentage() <= RubimRH.db.profile[73].sk2 and S.ShieldBlock:RechargeP() > (gcdTime * 2) then
        return S.LastStand:Cast()
    end
  end
  
  Aoe = function()
    -- thunder_clap
    if S.ThunderClap:IsCastableP() then
      return S.ThunderClap:Cast()
    end
    -- memory_of_lucid_dreams,if=buff.avatar.down
    if S.MemoryOfLucidDreams:IsCastableP() and (Player:BuffDownP(S.AvatarBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- demoralizing_shout,if=talent.booming_voice.enabled
    if S.DemoralizingShout:IsCastableP() and S.BoomingVoice:IsAvailable() and Player:RageDeficit() >= 40 then
      return S.DemoralizingShout:Cast()
    end
    -- anima_of_death,if=buff.last_stand.up
    if S.AnimaofDeath:IsCastableP() and (Player:BuffP(S.LastStandBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- dragon_roar
    if S.DragonRoar:IsCastableP() and RubimRH.CDsON() then
      return S.DragonRoar:Cast()
    end
    -- revenge
    if S.Revenge:IsReadyP() and Player:Buff(S.FreeRevenge) or offensiveRage() or Player:Rage() >= 75 or ((not isCurrentlyTanking()) and Player:Rage() >= 50) then
      return S.Revenge:Cast()
    end
    -- ravager
    if S.Ravager:IsCastableP() then
      return S.Ravager:Cast()
    end
    -- shield_block,if=cooldown.shield_slam.ready&buff.shield_block.down
    if S.ShieldBlock:IsReadyP() and S.ShieldSlam:CooldownUpP() and Player:BuffDownP(S.ShieldBlockBuff) and offensiveShieldBlock() then
      return S.ShieldBlock:Cast()
    end
    -- shield_slam
    if S.ShieldSlam:IsCastableP() then
      return S.ShieldSlam:Cast()
    end
	-- devastate
    if S.Devastate:IsCastableP() then
      return S.Devastate:Cast()
    end
  end
  
  St = function()
    -- thunder_clap,if=spell_targets.thunder_clap=2&talent.unstoppable_force.enabled&buff.avatar.up
    if S.ThunderClap:IsCastableP() and Cache.EnemiesCount[8] == 2 and S.UnstoppableForce:IsAvailable() and Player:BuffP(S.AvatarBuff) then
      return S.ThunderClap:Cast()
    end
    -- shield_block,if=cooldown.shield_slam.ready&buff.shield_block.down
    if S.ShieldBlock:IsReadyP() and S.ShieldSlam:CooldownUpP() and Player:BuffDownP(S.ShieldBlockBuff) then
      return S.ShieldBlock:Cast()
    end
    -- shield_slam,if=buff.shield_block.up
    if S.ShieldSlam:IsCastableP() and Player:BuffP(S.ShieldBlockBuff) then
      return S.ShieldSlam:Cast()
    end
    -- thunder_clap,if=(talent.unstoppable_force.enabled&buff.avatar.up)
    if S.ThunderClap:IsCastableP() and (S.UnstoppableForce:IsAvailable() and Player:BuffP(S.AvatarBuff)) then
      return S.ThunderClap:Cast()
    end
    -- demoralizing_shout,if=talent.booming_voice.enabled
    if S.DemoralizingShout:IsCastableP() and S.BoomingVoice:IsAvailable() and Player:RageDeficit() >= 40 then
      return S.DemoralizingShout:Cast()
    end
    -- anima_of_death,if=buff.last_stand.up
    if S.AnimaofDeath:IsCastableP() and (Player:BuffP(S.LastStandBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- shield_slam
    if S.ShieldSlam:IsCastableP() then
      return S.ShieldSlam:Cast()
    end
    -- use_item,name=ashvanes_razor_coral,target_if=debuff.razor_coral_debuff.stack=0
    if I.AshvanesRazorCoral:IsCastableP() and (Target:DebuffStackP(S.RazorCoralDebuff) == 0) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.stack>7&(cooldown.avatar.remains<5|buff.avatar.up)
    if I.AshvanesRazorCoral:IsCastableP() and Target:DebuffStackP(S.RazorCoralDebuff) > 7 and (S.Avatar:CooldownRemainsP() < 5 or Player:BuffP(S.AvatarBuff)) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- dragon_roar
    if S.DragonRoar:IsCastableP() and RubimRH.CDsON() then
      return S.DragonRoar:Cast()d
    end
    -- thunder_clap
    if S.ThunderClap:IsCastableP() then
      return S.ThunderClap:Cast()
    end
    -- revenge
    if S.Revenge:IsReadyP() and Player:Buff(S.FreeRevenge) or offensiveRage() or Player:Rage() >= 75 or ((not isCurrentlyTanking()) and Player:Rage() >= 50) then
      return S.Revenge:Cast()
    end
    -- ravager
    if S.Ravager:IsCastableP() then
      return S.Ravager:Cast()
    end
    -- devastate
    if S.Devastate:IsCastableP() then
      return S.Devastate:Cast()
    end
  end
  
  	-- Protect against interrupt of channeled spells
    if (Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2)) or Player:IsChanneling() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
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
  
  --In Combat
  if RubimRH.TargetIsValid() then
    -- Check defensives if tanking
    if isCurrentlyTanking() then
      local ShouldReturn = Defensive(); if ShouldReturn then return ShouldReturn; end
    end
    -- Interrupt    
    -- auto_attack
    -- intercept,if=time=0
    if S.Intercept:IsCastableP() and HL.CombatTime() == 0 and not Target:IsInRange(8) then
      return S.Intercept:Cast()
    end
	-- QueueSkill
	if QueueSkill() ~= nil then
		return QueueSkill()
    end
	-- Shockwave
    if S.Shockwave:IsCastableP() and Target:IsInRange(10) and Cache.EnemiesCount[10] >= 3 and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.Shockwave:Cast()
    end
    -- Stormbolt
    if S.Stormbolt:IsAvailable() and S.Stormbolt:CooldownRemainsP() < 0.1 and S.Pummel:CooldownRemainsP() > 0 and Target:IsInRange(20) and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.Stormbolt:Cast()
    end
	-- Pummel
    if S.Pummel:IsReady() and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.Pummel:Cast()
    end
    -- use_items,if=cooldown.avatar.remains>20
    -- use_item,name=grongs_primal_rage,if=buff.avatar.down
    if I.GrongsPrimalRage:IsReady() and (Player:BuffDownP(S.AvatarBuff)) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
      return S.BloodFury:Cast()
    end
    -- berserking
    if S.Berserking:IsCastableP() and RubimRH.CDsON() then
      return S.Berserking:Cast()
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and RubimRH.CDsON() then
      return S.ArcaneTorrent:Cast()
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() then
      return S.LightsJudgment:Cast()
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
      return S.Fireblood:Cast()
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() then
      return S.AncestralCall:Cast()
    end
    -- potion,if=buff.avatar.up|target.time_to_die<25
    if I.SuperiorBattlePotionofStrength:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.AvatarBuff) or Target:TimeToDie() < 25) then
      return 967532
    end
    if Player:HealthPercentage() < 30 and S.VictoryRush:IsReady() then
      return S.VictoryRush:Cast()
    end
    if Player:HealthPercentage() < 30 and S.ImpendingVictory:IsReadyP() then
      return S.ImpendingVictory:Cast()
    end
    -- ignore_pain,if=rage.deficit<25+20*talent.booming_voice.enabled*cooldown.demoralizing_shout.ready
    if S.IgnorePain:IsReadyP() and (Player:RageDeficit() < 25 + 20 * num(S.BoomingVoice:IsAvailable()) * num(S.DemoralizingShout:CooldownUpP()) and shouldCastIp() and isCurrentlyTanking()) then
      return S.IgnorePain:Cast()
    end
    -- worldvein_resonance,if=cooldown.avatar.remains<=2
    if S.WorldveinResonance:IsCastableP() and (S.Avatar:CooldownRemainsP() <= 2) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams
    if S.MemoryOfLucidDreams:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame,if=buff.avatar.down
    if S.ConcentratedFlame:IsCastableP() and (Player:BuffDownP(S.AvatarBuff)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- last_stand,if=cooldown.anima_of_death.remains<=2
    if S.LastStand:IsCastableP() and (S.AnimaofDeath:CooldownRemainsP() <= 2) then
      return S.LastStand:Cast()
    end
    -- avatar
    if S.Avatar:IsCastableP() and RubimRH.CDsON() then
      return S.Avatar:Cast()
    end
    -- run_action_list,name=aoe,if=spell_targets.thunder_clap>=3
    if (Cache.EnemiesCount[8] >= 3) then
      return Aoe();
    end
    -- call_action_list,name=st
    if (true) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(73, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(73, PASSIVE);