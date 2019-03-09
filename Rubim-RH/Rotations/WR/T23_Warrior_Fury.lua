--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item
-- HeroRotation
local HR     = HeroRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Warrior then Spell.Warrior = {} end
Spell.Warrior.Fury = {
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
  Execute                               = Spell(5308),
  Bladestorm                            = Spell(46924),
  Bloodthirst                           = Spell(23881),
  ColdSteelHotBlood                     = Spell(),
  RagingBlow                            = Spell(85288),
  DragonRoar                            = Spell(118000),
  Whirlwind                             = Spell(190411),
  Charge                                = Spell(100),
  MeatCleaverBuff                       = Spell(280392),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738)
};
local S = Spell.Warrior.Fury;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Fury = {
  BattlePotionofStrength           = Item(163224),
  RampingAmplitudeGigavoltEngine   = Item()
};
local I = Item.Warrior.Fury;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Warrior.Commons,
  Fury = HR.GUISettings.APL.Warrior.Fury
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

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Movement, SingleTarget
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 4"; end
    end
    -- recklessness,if=!talent.furious_slash.enabled&!talent.reckless_abandon.enabled
    if S.Recklessness:IsCastableP() and Player:BuffDownP(S.RecklessnessBuff) and HR.CDsON() and (not S.FuriousSlash:IsAvailable() and not S.RecklessAbandon:IsAvailable()) then
      if HR.Cast(S.Recklessness, Settings.Fury.GCDasOffGCD.Recklessness) then return "recklessness 6"; end
    end
  end
  Movement = function()
    -- heroic_leap
    if S.HeroicLeap:IsCastableP() then
      if HR.Cast(S.HeroicLeap) then return "heroic_leap 16"; end
    end
  end
  SingleTarget = function()
    -- siegebreaker
    if S.Siegebreaker:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Siegebreaker, Settings.Fury.GCDasOffGCD.Siegebreaker) then return "siegebreaker 18"; end
    end
    -- rampage,if=buff.recklessness.up|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
    if S.Rampage:IsReadyP() and (Player:BuffP(S.RecklessnessBuff) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90))) then
      if HR.Cast(S.Rampage) then return "rampage 20"; end
    end
    -- execute
    if S.Execute:IsCastableP() then
      if HR.Cast(S.Execute) then return "execute 34"; end
    end
    -- bladestorm,if=prev_gcd.1.rampage
    if S.Bladestorm:IsCastableP() and HR.CDsON() and (Player:PrevGCDP(1, S.Rampage)) then
      if HR.Cast(S.Bladestorm, Settings.Fury.GCDasOffGCD.Bladestorm) then return "bladestorm 36"; end
    end
    -- bloodthirst,if=buff.enrage.down|azerite.cold_steel_hot_blood.rank>1
    if S.Bloodthirst:IsCastableP() and (Player:BuffDownP(S.EnrageBuff) or S.ColdSteelHotBlood:AzeriteRank() > 1) then
      if HR.Cast(S.Bloodthirst) then return "bloodthirst 40"; end
    end
    -- raging_blow,if=charges=2
    if S.RagingBlow:IsCastableP() and (S.RagingBlow:ChargesP() == 2) then
      if HR.Cast(S.RagingBlow) then return "raging_blow 46"; end
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP() then
      if HR.Cast(S.Bloodthirst) then return "bloodthirst 52"; end
    end
    -- dragon_roar,if=buff.enrage.up
    if S.DragonRoar:IsCastableP() and HR.CDsON() and (Player:BuffP(S.EnrageBuff)) then
      if HR.Cast(S.DragonRoar, Settings.Fury.GCDasOffGCD.DragonRoar) then return "dragon_roar 54"; end
    end
    -- raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
    if S.RagingBlow:IsCastableP() and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
      if HR.Cast(S.RagingBlow) then return "raging_blow 58"; end
    end
    -- furious_slash,if=talent.furious_slash.enabled
    if S.FuriousSlash:IsCastableP() and (S.FuriousSlash:IsAvailable()) then
      if HR.Cast(S.FuriousSlash) then return "furious_slash 66"; end
    end
    -- whirlwind
    if S.Whirlwind:IsCastableP() then
      if HR.Cast(S.Whirlwind) then return "whirlwind 70"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and Everyone.TargetIsValid() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- charge
    if S.Charge:IsCastableP() then
      if HR.Cast(S.Charge, Settings.Fury.GCDasOffGCD.Charge) then return "charge 74"; end
    end
    -- run_action_list,name=movement,if=movement.distance>5
    if (movement.distance > 5) then
      return Movement();
    end
    -- heroic_leap,if=(raid_event.movement.distance>25&raid_event.movement.in>45)|!raid_event.movement.exists
    if S.HeroicLeap:IsCastableP() and ((raid_event.movement.distance > 25 and 10000000000 > 45) or not false) then
      if HR.Cast(S.HeroicLeap) then return "heroic_leap 78"; end
    end
    -- potion
    if I.BattlePotionofStrength:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofStrength) then return "battle_potion_of_strength 80"; end
    end
    -- furious_slash,if=talent.furious_slash.enabled&(buff.furious_slash.stack<3|buff.furious_slash.remains<3|(cooldown.recklessness.remains<3&buff.furious_slash.remains<9))
    if S.FuriousSlash:IsCastableP() and (S.FuriousSlash:IsAvailable() and (Player:BuffStackP(S.FuriousSlashBuff) < 3 or Player:BuffRemainsP(S.FuriousSlashBuff) < 3 or (S.Recklessness:CooldownRemainsP() < 3 and Player:BuffRemainsP(S.FuriousSlashBuff) < 9))) then
      if HR.Cast(S.FuriousSlash) then return "furious_slash 82"; end
    end
    -- rampage,if=cooldown.recklessness.remains<3
    if S.Rampage:IsReadyP() and (S.Recklessness:CooldownRemainsP() < 3) then
      if HR.Cast(S.Rampage) then return "rampage 94"; end
    end
    -- recklessness,if=!talent.siegebreaker.enabled|(cooldown.siegebreaker.remains<1|cooldown.siegebreaker.remains>5)
    if S.Recklessness:IsCastableP() and HR.CDsON() and (not S.Siegebreaker:IsAvailable() or (S.Siegebreaker:CooldownRemainsP() < 1 or S.Siegebreaker:CooldownRemainsP() > 5)) then
      if HR.Cast(S.Recklessness, Settings.Fury.GCDasOffGCD.Recklessness) then return "recklessness 98"; end
    end
    -- whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
    if S.Whirlwind:IsCastableP() and (Cache.EnemiesCount[8] > 1 and not Player:BuffP(S.MeatCleaverBuff)) then
      if HR.Cast(S.Whirlwind) then return "whirlwind 106"; end
    end
    -- use_item,name=ramping_amplitude_gigavolt_engine
    if I.RampingAmplitudeGigavoltEngine:IsReady() then
      if HR.CastSuggested(I.RampingAmplitudeGigavoltEngine) then return "ramping_amplitude_gigavolt_engine 110"; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 112"; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 114"; end
    end
    -- lights_judgment,if=buff.recklessness.down
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Player:BuffDownP(S.RecklessnessBuff)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 116"; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 120"; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 122"; end
    end
    -- run_action_list,name=single_target
    if (true) then
      return SingleTarget();
    end
  end
end

HR.SetAPL(72, APL)
