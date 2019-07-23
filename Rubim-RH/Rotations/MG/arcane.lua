local mainAddon = RubimRH
--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet = Unit.Pet
local Spell = HL.Spell
local Item = HL.Item
local mainAddon = RubimRH

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[62] = {
    ArcaneIntellectBuff   = Spell(1459),
    ArcaneIntellect       = Spell(1459),
    ArcaneFamiliarBuff    = Spell(210126),
    ArcaneFamiliar        = Spell(205022),
    Equipoise             = Spell(286027),
    MirrorImage           = Spell(55342),
    ArcaneBlast           = Spell(30451),
    Evocation             = Spell(12051),
    ChargedUp             = Spell(205032),
    ArcaneChargeBuff      = Spell(36032),
    NetherTempest         = Spell(114923),
    NetherTempestDebuff   = Spell(114923),
    RuneofPowerBuff       = Spell(116014),
    ArcanePowerBuff       = Spell(12042),
    RuleofThreesBuff      = Spell(264774),
    Overpowered           = Spell(155147),
    LightsJudgment        = Spell(255647),
    RuneofPower           = Spell(116011),
    ArcanePower           = Spell(12042),
    Berserking            = Spell(26297),
    BloodFury             = Spell(20572),
    Fireblood             = Spell(265221),
    AncestralCall         = Spell(274738),
    PresenceofMind        = Spell(205025),
    PresenceofMindBuff    = Spell(205025),
    BerserkingBuff        = Spell(26297),
    BloodFuryBuff         = Spell(20572),
    ArcaneOrb             = Spell(153626),
    Resonance             = Spell(205028),
    ArcaneBarrage         = Spell(44425),
    ArcaneExplosion       = Spell(1449),
    ArcaneMissiles        = Spell(5143),
    ClearcastingBuff      = Spell(263725),
    Amplification         = Spell(236628),
    ArcanePummeling       = Spell(270669),
    Supernova             = Spell(157980),
    Blink                 = Spell(1953),
    Shimmer               = Spell(212653),
    IceBlock              = Spell(45438),
    PrismaticBarrier      = Spell(235450),		
    Spellsteal            = Spell(30449),			 
    Counterspell          = Spell(2139),
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
local S = RubimRH.Spell[62];

-- Items
if not Item.Mage then Item.Mage = {} end
Item.Mage.Arcane = {
  BattlePotionOfIntellect          = Item(163222),
  TidestormCodex         = Item(165576)
};
local I = Item.Mage.Arcane;

-- Rotation Var
local ShouldReturn; -- Used to get the return string
-- Variables
local VarConserveMana = 0;
local VarTotalBurns = 0;
local VarAverageBurnLength = 0;

HL:RegisterForEvent(function()
       VarConserveMana = 0
       VarTotalBurns = 0
       VarAverageBurnLength = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {40, 10}
local function UpdateRanges()
       for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
       end
end

local function GetEnemiesCount(range)
    if range == nil then range = 10 end
	 -- Unit Update - Update differently depending on if splash data is being used
	if RubimRH.AoEON() then       
	        if RubimRH.db.profile[62].useSplashData == "Enabled" then	
      RubimRH.UpdateSplashCount(Target, range)
      return RubimRH.GetSplashCount(Target, range)
            else
      UpdateRanges()
      if range == 10 then
          return Cache.EnemiesCount[range]
      else
          return active_enemies()
      end
            end
    else
        return 1
    end
end

local function num(val)
       if val then return 1 else return 0 end
end

local function bool(val)
       return val ~= 0
end

Player.ArcaneBurnPhase = {}
local BurnPhase = Player.ArcaneBurnPhase

function BurnPhase:Reset()
       self.state = false
       self.last_start = HL.GetTime()
       self.last_stop = HL.GetTime()
end
BurnPhase:Reset()

function BurnPhase:Start()
       if Player:AffectingCombat() then
    self.state = true
    self.last_start = HL.GetTime()
       end
end

function BurnPhase:Stop()
       self.state = false
       self.last_stop = HL.GetTime()
end

function BurnPhase:On()
       return self.state or (not Player:AffectingCombat() and Player:IsCasting() and ((S.ArcanePower:CooldownRemainsP() == 0 and S.Evocation:CooldownRemainsP() <= VarAverageBurnLength and (Player:ArcaneChargesP() == Player:ArcaneChargesMax() or (S.ChargedUp:IsAvailable() and S.ChargedUp:CooldownRemainsP() == 0)))))
end

function BurnPhase:Duration()
       return self.state and (HL.GetTime() - self.last_start) or 0
end

HL:RegisterForEvent(function()
       BurnPhase:Reset()
end, "PLAYER_REGEN_DISABLED")

local function PresenceOfMindMax ()
       return 2
end

local function ArcaneMissilesProcMax ()
       return 3
end

function Player:ArcaneChargesP()
       return math.min(self:ArcaneCharges() + num(self:IsCasting(S.ArcaneBlast)),4)
end
local Healthstone = 5512

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
  local Precombat_DBM, Precombat, Burn, Conserve, Movement
  local BlinkAny = S.Shimmer:IsAvailable() and S.Shimmer or S.Blink
  UpdateRanges()
  RubimRH.UpdateSplashCount(Target, 10)
  DetermineEssenceRanks()
  
  Precombat_DBM = function()
    -- flask
    -- food
    -- augmentation
    -- arcane_intellect
    if S.ArcaneIntellect:IsCastableP() and Player:BuffDownP(S.ArcaneIntellectBuff, true) then
      return S.ArcaneIntellect:Cast()
    end
    -- arcane_familiar
    if S.ArcaneFamiliar:IsCastableP() and Player:BuffDownP(S.ArcaneFamiliarBuff) then
      return S.ArcaneFamiliar:Cast()
    end
	-- pre potion
    if I.BattlePotionOfIntellect:IsReady() and RubimRH.DBM_PullTimer() > S.ArcaneBlast:CastTime() + 1 and RubimRH.DBM_PullTimer() <= S.ArcaneBlast:CastTime() + 2 then
         return 967532
    end
    -- arcane_blast
    if S.ArcaneBlast:IsReadyP() and RubimRH.DBM_PullTimer() > 0.1 and RubimRH.DBM_PullTimer() <= S.ArcaneBlast:CastTime() then
      return S.ArcaneBlast:Cast()
    end
  end
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- arcane_intellect
    if S.ArcaneIntellect:IsCastableP() and Player:BuffDownP(S.ArcaneIntellectBuff, true) then
      return S.ArcaneIntellect:Cast()
    end
    -- arcane_familiar
    if S.ArcaneFamiliar:IsCastableP() and Player:BuffDownP(S.ArcaneFamiliarBuff) then
      return S.ArcaneFamiliar:Cast()
    end
    -- variable,name=conserve_mana,op=set,value=60+20*azerite.equipoise.enabled
    if (true) then
      VarConserveMana = 60 + 20 * num(S.Equipoise:AzeriteEnabled())
    end
    -- snapshot_stats
    -- mirror_image
    if S.MirrorImage:IsCastableP() and RubimRH.CDsON() then
      return S.MirrorImage:Cast()
    end
    -- potion
    --if I.BattlePotionofIntellect:IsReady() and RubimRH.PrecombatON() then
    --  return I.BattlePotionofIntellect:Cast()
    --end
    -- arcane_blast
    if S.ArcaneBlast:IsReadyP() then
      return S.ArcaneBlast:Cast()
    end
  end
  
  Burn = function()
    -- variable,name=total_burns,op=add,value=1,if=!burn_phase
    if (not BurnPhase:On()) then
      VarTotalBurns = VarTotalBurns + 1
    end
    -- start_burn_phase,if=!burn_phase
    if (not BurnPhase:On()) then
      BurnPhase:Start()
    end
    -- stop_burn_phase,if=burn_phase&prev_gcd.1.evocation&target.time_to_die>variable.average_burn_length&burn_phase_duration>0
    if (BurnPhase:On() and Player:PrevGCDP(1, S.Evocation) and Target:TimeToDie() > VarAverageBurnLength and BurnPhase:Duration() > 0) then
      BurnPhase:Stop()
    end
    -- charged_up,if=buff.arcane_charge.stack<=1
    if S.ChargedUp:IsCastableP() and (Player:ArcaneChargesP() <= 1) then
      return S.ChargedUp:Cast()
    end
    -- mirror_image
    if S.MirrorImage:IsCastableP() and RubimRH.CDsON() then
      return S.MirrorImage:Cast()
    end
    -- nether_tempest,if=(refreshable|!ticking)&buff.arcane_charge.stack=buff.arcane_charge.max_stack&buff.rune_of_power.down&buff.arcane_power.down
    if S.NetherTempest:IsCastableP() and ((Target:DebuffRefreshableCP(S.NetherTempestDebuff) or not Target:DebuffP(S.NetherTempestDebuff)) and Player:ArcaneChargesP() == Player:ArcaneChargesMax() and Player:BuffDownP(S.RuneofPowerBuff) and Player:BuffDownP(S.ArcanePowerBuff)) then
      return S.NetherTempest:Cast()
    end
    -- arcane_blast,if=buff.rule_of_threes.up&talent.overpowered.enabled&active_enemies<3
    if S.ArcaneBlast:IsReadyP() and (Player:BuffP(S.RuleofThreesBuff) and S.Overpowered:IsAvailable() and GetEnemiesCount(10) < 3) then
      return S.ArcaneBlast:Cast()
    end
    -- lights_judgment,if=buff.arcane_power.down
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() and (Player:BuffDownP(S.ArcanePowerBuff)) then
      return S.LightsJudgment:Cast()
    end
    -- rune_of_power,if=!buff.arcane_power.up&(mana.pct>=50|cooldown.arcane_power.remains=0)&(buff.arcane_charge.stack=buff.arcane_charge.max_stack)
    if S.RuneofPower:IsCastableP() and (not Player:BuffP(S.ArcanePowerBuff) and (Player:ManaPercentageP() >= 50 or S.ArcanePower:CooldownRemainsP() == 0) and (Player:ArcaneChargesP() == Player:ArcaneChargesMax())) then
      return S.RuneofPower:Cast()
    end
    -- berserking
    if S.Berserking:IsCastableP() and RubimRH.CDsON() then
      return S.Berserking:Cast()
    end
    -- arcane_power
    if S.ArcanePower:IsCastableP() and RubimRH.CDsON() then
      return S.ArcanePower:Cast()
    end
    -- use_items,if=buff.arcane_power.up|target.time_to_die<cooldown.arcane_power.remains
    -- blood_fury
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
      return S.BloodFury:Cast()
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
      return S.Fireblood:Cast()
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() then
      return S.AncestralCall:Cast()
    end
    -- presence_of_mind,if=(talent.rune_of_power.enabled&buff.rune_of_power.remains<=buff.presence_of_mind.max_stack*action.arcane_blast.execute_time)|buff.arcane_power.remains<=buff.presence_of_mind.max_stack*action.arcane_blast.execute_time
    if S.PresenceofMind:IsCastableP() and RubimRH.CDsON() and ((S.RuneofPower:IsAvailable() and Player:BuffRemainsP(S.RuneofPowerBuff) <= PresenceOfMindMax() * S.ArcaneBlast:ExecuteTime()) or Player:BuffRemainsP(S.ArcanePowerBuff) <= PresenceOfMindMax() * S.ArcaneBlast:ExecuteTime()) then
      return S.PresenceofMind:Cast()
    end
    -- potion,if=buff.arcane_power.up&(buff.berserking.up|buff.blood_fury.up|!(race.troll|race.orc))
    --if I.BattlePotionofIntellect:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.ArcanePowerBuff) and (Player:BuffP(S.BerserkingBuff) or Player:BuffP(S.BloodFuryBuff) or not (Player:IsRace("Troll") or Player:IsRace("Orc")))) then
    --  return I.BattlePotionofIntellect:Cast()
    --end
    -- arcane_orb,if=buff.arcane_charge.stack=0|(active_enemies<3|(active_enemies<2&talent.resonance.enabled))
    if S.ArcaneOrb:IsCastableP() and (Player:ArcaneChargesP() == 0 or (GetEnemiesCount(10) < 3 or (GetEnemiesCount(10) < 2 and S.Resonance:IsAvailable()))) then
      return S.ArcaneOrb:Cast()
    end
    -- arcane_barrage,if=active_enemies>=3&(buff.arcane_charge.stack=buff.arcane_charge.max_stack)
    if S.ArcaneBarrage:IsCastableP() and (active_enemies() >= 3 and (Player:ArcaneChargesP() == Player:ArcaneChargesMax())) then
      return S.ArcaneBarrage:Cast()
    end
    -- arcane_explosion,if=active_enemies>=3
    if S.ArcaneExplosion:IsReadyP() and (GetEnemiesCount(10) >= 3) then
      return S.ArcaneExplosion:Cast()
    end
    -- arcane_missiles,if=buff.clearcasting.react&active_enemies<3&(talent.amplification.enabled|(!talent.overpowered.enabled&azerite.arcane_pummeling.rank>=2)|buff.arcane_power.down),chain=1
    if S.ArcaneMissiles:IsCastableP() and (bool(Player:BuffStackP(S.ClearcastingBuff)) and GetEnemiesCount(10) < 3 and (S.Amplification:IsAvailable() or (not S.Overpowered:IsAvailable() and S.ArcanePummeling:AzeriteRank() >= 2) or Player:BuffDownP(S.ArcanePowerBuff))) then
      return S.ArcaneMissiles:Cast()
    end
    -- arcane_blast,if=active_enemies<3
    if S.ArcaneBlast:IsReadyP() and (GetEnemiesCount(10) < 3) then
      return S.ArcaneBlast:Cast()
    end
    -- variable,name=average_burn_length,op=set,value=(variable.average_burn_length*variable.total_burns-variable.average_burn_length+(burn_phase_duration))%variable.total_burns
    if (true) then
      VarAverageBurnLength = (VarAverageBurnLength * VarTotalBurns - VarAverageBurnLength + (BurnPhase:Duration())) / VarTotalBurns
    end
    -- evocation,interrupt_if=mana.pct>=85,interrupt_immediate=1
    if S.Evocation:IsCastableP() then
      return S.Evocation:Cast()
    end
    -- arcane_barrage
    if S.ArcaneBarrage:IsCastableP() then
      return S.ArcaneBarrage:Cast()
    end
  end
  
  Conserve = function()
    -- mirror_image
    if S.MirrorImage:IsCastableP() and RubimRH.CDsON() then
      return S.MirrorImage:Cast()
    end
    -- charged_up,if=buff.arcane_charge.stack=0
    if S.ChargedUp:IsCastableP() and (Player:ArcaneChargesP() == 0) then
      return S.ChargedUp:Cast()
    end
    -- nether_tempest,if=(refreshable|!ticking)&buff.arcane_charge.stack=buff.arcane_charge.max_stack&buff.rune_of_power.down&buff.arcane_power.down
    if S.NetherTempest:IsCastableP() and ((Target:DebuffRefreshableCP(S.NetherTempestDebuff) or not Target:DebuffP(S.NetherTempestDebuff)) and Player:ArcaneChargesP() == Player:ArcaneChargesMax() and Player:BuffDownP(S.RuneofPowerBuff) and Player:BuffDownP(S.ArcanePowerBuff)) then
      return S.NetherTempest:Cast()
    end
    -- arcane_orb,if=buff.arcane_charge.stack<=2&(cooldown.arcane_power.remains>10|active_enemies<=2)
    if S.ArcaneOrb:IsCastableP() and (Player:ArcaneChargesP() <= 2 and (S.ArcanePower:CooldownRemainsP() > 10 or GetEnemiesCount(10) <= 2)) then
      return S.ArcaneOrb:Cast()
    end
    -- arcane_blast,if=buff.rule_of_threes.up&buff.arcane_charge.stack>3
    if S.ArcaneBlast:IsReadyP() and (Player:BuffP(S.RuleofThreesBuff) and Player:ArcaneChargesP() > 3) then
      return S.ArcaneBlast:Cast()
    end
    -- use_item,name=tidestorm_codex,if=buff.rune_of_power.down&!buff.arcane_power.react&cooldown.arcane_power.remains>20
    --if I.TidestormCodex:IsReady() and (Player:BuffDownP(S.RuneofPowerBuff) and not bool(Player:BuffStackP(S.ArcanePowerBuff)) and S.ArcanePower:CooldownRemainsP() > 20) then
    --  return I.TidestormCodex:Cast()
    --end
    -- rune_of_power,if=buff.arcane_charge.stack=buff.arcane_charge.max_stack&(full_recharge_time<=execute_time|full_recharge_time<=cooldown.arcane_power.remains|target.time_to_die<=cooldown.arcane_power.remains)
    if S.RuneofPower:IsCastableP() and (Player:ArcaneChargesP() == Player:ArcaneChargesMax() and (S.RuneofPower:FullRechargeTimeP() <= S.RuneofPower:ExecuteTime() or S.RuneofPower:FullRechargeTimeP() <= S.ArcanePower:CooldownRemainsP() or Target:TimeToDie() <= S.ArcanePower:CooldownRemainsP())) then
      return S.RuneofPower:Cast()
    end
    -- arcane_missiles,if=mana.pct<=95&buff.clearcasting.react&active_enemies<3,chain=1
    if S.ArcaneMissiles:IsCastableP() and (Player:ManaPercentageP() <= 95 and bool(Player:BuffStackP(S.ClearcastingBuff)) and GetEnemiesCount(10) < 3) then
      return S.ArcaneMissiles:Cast()
    end
    -- arcane_barrage,if=((buff.arcane_charge.stack=buff.arcane_charge.max_stack)&((mana.pct<=variable.conserve_mana)|(talent.rune_of_power.enabled&cooldown.arcane_power.remains>cooldown.rune_of_power.full_recharge_time&mana.pct<=variable.conserve_mana+25))|(talent.arcane_orb.enabled&cooldown.arcane_orb.remains<=gcd&cooldown.arcane_power.remains>10))|mana.pct<=(variable.conserve_mana-10)
    if S.ArcaneBarrage:IsCastableP() and (((Player:ArcaneChargesP() == Player:ArcaneChargesMax()) and ((Player:ManaPercentageP() <= VarConserveMana) or (S.RuneofPower:IsAvailable() and S.ArcanePower:CooldownRemainsP() > S.RuneofPower:FullRechargeTimeP() and Player:ManaPercentageP() <= VarConserveMana + 25)) or (S.ArcaneOrb:IsAvailable() and S.ArcaneOrb:CooldownRemainsP() <= Player:GCD() and S.ArcanePower:CooldownRemainsP() > 10)) or Player:ManaPercentageP() <= (VarConserveMana - 10)) then
      return S.ArcaneBarrage:Cast()
    end
    -- supernova,if=mana.pct<=95
    if S.Supernova:IsCastableP() and (Player:ManaPercentageP() <= 95) then
      return S.Supernova:Cast()
    end
    -- arcane_explosion,if=active_enemies>=3&(mana.pct>=variable.conserve_mana|buff.arcane_charge.stack=3)
    if S.ArcaneExplosion:IsReadyP() and (GetEnemiesCount(10) >= 3 and (Player:ManaPercentageP() >= VarConserveMana or Player:ArcaneChargesP() == 3)) then
      return S.ArcaneExplosion:Cast()
    end
    -- arcane_blast
    if S.ArcaneBlast:IsReadyP() then
      return S.ArcaneBlast:Cast()
    end
    -- arcane_barrage
    if S.ArcaneBarrage:IsCastableP() then
      return S.ArcaneBarrage:Cast()
    end
  end
  
  Movement = function()
    -- blink_any,if=movement.distance>=10
    if BlinkAny:IsCastableP() and (not Target:IsInRange(S.ArcaneBlast:MaximumRange())) then
      return S.BlinkAny:Cast()
    end
    -- presence_of_mind
    if S.PresenceofMind:IsCastableP() and RubimRH.CDsON() then
      return S.PresenceofMind:Cast()
    end
    -- arcane_missiles
    if S.ArcaneMissiles:IsCastableP() then
      return S.ArcaneMissiles:Cast()
    end
    -- arcane_orb
    if S.ArcaneOrb:IsCastableP() then
      return S.ArcaneOrb:Cast()
    end
    -- supernova
    if S.Supernova:IsCastableP() then
      return S.Supernova:Cast()
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
  
  -- protect against channeling interrupt
  if Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) then
     return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
  end
  
  -- combat
  if RubimRH.TargetIsValid() then
    -- Healthstone
	if Item(Healthstone):IsReady() and Player:HealthPercentage() <= RubimRH.db.profile.mainOption.healthstoneper then
        return 538745
    end
    -- Queue sys
	if QueueSkill() ~= nil then
        return QueueSkill()
    end
-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn and (true) then return ShouldReturn; end
    -- counterspell
	if S.Counterspell:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Counterspell:Cast()
    end
	-- spell steal
	if S.Spellsteal:IsReady() and RubimRH.InterruptsON() and Target:HasStealableBuff() then
        return S.Spellsteal:Cast()
    end
    -- call_action_list,name=burn,if=burn_phase|target.time_to_die<variable.average_burn_length
    if RubimRH.CDsON() and (BurnPhase:On() or Target:TimeToDie() < VarAverageBurnLength) then
      local ShouldReturn = Burn(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=burn,if=(cooldown.arcane_power.remains=0&cooldown.evocation.remains<=variable.average_burn_length&(buff.arcane_charge.stack=buff.arcane_charge.max_stack|(talent.charged_up.enabled&cooldown.charged_up.remains=0&buff.arcane_charge.stack<=1)))
    if RubimRH.CDsON() and ((S.ArcanePower:CooldownRemainsP() == 0 and S.Evocation:CooldownRemainsP() <= VarAverageBurnLength and (Player:ArcaneChargesP() == Player:ArcaneChargesMax() or (S.ChargedUp:IsAvailable() and S.ChargedUp:CooldownRemainsP() == 0 and Player:ArcaneChargesP() <= 1)))) then
      local ShouldReturn = Burn(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=conserve,if=!burn_phase
    if (not BurnPhase:On()) then
      local ShouldReturn = Conserve(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=movement
    if (true) then
      local ShouldReturn = Movement(); if ShouldReturn then return ShouldReturn; end
    end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(62, APL)

local function PASSIVE()
    if S.IceBlock:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[62].sk1 then
        return S.IceBlock:Cast()
    end
    if S.PrismaticBarrier:IsCastableP() and not Player:Buff(S.PrismaticBarrier) and Player:HealthPercentage() <= RubimRH.db.profile[62].sk2 then
        return S.PrismaticBarrier:Cast()
    end
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(62, PASSIVE)