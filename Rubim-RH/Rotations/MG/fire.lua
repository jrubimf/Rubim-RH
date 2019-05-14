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
local mainAddon = RubimRH

-- 14.05.19 
-- Still in work, should expect bugs with fireball or pyro 

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[63] = {
    ArcaneIntellectBuff                   = Spell(1459),
    ArcaneIntellect                       = Spell(1459),
    MirrorImage                           = Spell(55342),
    Pyroblast                             = Spell(11366),
    BlastWave                             = Spell(157981),
    CombustionBuff                        = Spell(190319),
    FireBlast                             = Spell(108853),
    Meteor                                = Spell(153561),
    Combustion                            = Spell(190319),
    RuneOfPowerBuff                       = Spell(116014),
    DragonsBreath                         = Spell(31661),
    AlexstraszasFury                      = Spell(235870),
    HotStreakBuff                         = Spell(48108),
    LivingBomb                            = Spell(44457),
    LightsJudgment                        = Spell(255647),
    RuneOfPower                           = Spell(116011),
    BloodFury                             = Spell(20572),
    Berserking                            = Spell(26297),
    Flamestrike                           = Spell(2120),
    FlamePatch                            = Spell(205037),
    KaelthasUltimateAbilityBuff           = Spell(209455),
    PyroclasmBuff                         = Spell(269651),
    HeatingUpBuff                         = Spell(48107),
    PhoenixFlames                         = Spell(257541),
    Scorch                                = Spell(2948),
    SearingTouch                          = Spell(269644),
    Fireball                              = Spell(133),
	Fireblood                             = Spell(265221),
    Kindling                              = Spell(155148),
    IncantersFlowBuff                     = Spell(1463),
    Counterspell                          = Spell(2139),
    EruptingInfernalCoreBuff              = Spell(248147),
    Firestarter                           = Spell(205026),
	BlasterMasterBuff                     = Spell(274598),
	BlasterMaster                         = Spell(274597),
	AncestralCall                         = Spell(274738),
};
local S = RubimRH.Spell[63];

-- Items
--if not Item.Mage then Item.Mage = {} end
--Item.Mage.Fire = {
--    ProlongedPower                   = Item(142117),
--    Item132863                       = Item(132863),
 --   Item132454                       = Item(132454)
--};
--local I = Item.Mage.Fire;


-- Variables
local VarCombustionRopCutoff = 0;
local VarFireBlastPooling = 0;
local VarPhoenixPooling = 0;

HL:RegisterForEvent(function()
  VarCombustionRopCutoff = 0
  VarFireBlastPooling = 0
  VarPhoenixPooling = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {12, 40}
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

local function RemainingTimeToCast(spell)
    local spell, _, _, _, endTime = UnitCastingInfo("player")
    if spell then 
        local finish = endTimeMS/1000 - GetTime()
        return finish
    end
end


local function num(val)
    if val then return 1 else return 0 end
end

local function bool(val)
    return val ~= 0
end

S.PhoenixFlames:RegisterInFlight();
S.Pyroblast:RegisterInFlight(S.CombustionBuff);
S.Fireball:RegisterInFlight(S.CombustionBuff);

function S.Firestarter:ActiveStatus()
    return S.Firestarter:IsAvailable() and (Target:HealthPercentage() > 90) and 1 or 0
end

function S.Firestarter:ActiveRemains()
    return S.Firestarter:IsAvailable() and ((Target:HealthPercentage() > 90) and Target:TimeToX(90, 3) or 0)
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, ActiveTalents, BmCombustionPhase, CombustionPhase, RopPhase, StandardRotation, Trinkets
  UpdateRanges()
  --Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- arcane_intellect
    if S.ArcaneIntellect:IsCastableP() and Player:BuffDownP(S.ArcaneIntellectBuff, true) then
    return S.ArcaneIntellect:Cast()
    end
    -- variable,name=combustion_rop_cutoff,op=set,value=60
    if (true) then
      VarCombustionRopCutoff = 60
    end
    -- snapshot_stats
    -- mirror_image
    if S.MirrorImage:IsCastableP() then
    return S.MirrorImage:Cast()
    end
    -- potion

    -- pyroblast
    if S.Pyroblast:IsCastableP() and not Player:IsCasting(S.Pyroblast) then
       return S.Pyroblast:Cast()
    end
  end
  ActiveTalents = function()
    -- living_bomb,if=active_enemies>1&buff.combustion.down&(cooldown.combustion.remains>cooldown.living_bomb.duration|cooldown.combustion.ready)
    if S.LivingBomb:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Player:BuffDownP(S.CombustionBuff) and S.Combustion:CooldownRemainsP() > S.LivingBomb:BaseDuration() or S.Combustion:CooldownUpP()) then
    return S.LivingBomb:Cast()
    end
    -- meteor,if=buff.rune_of_power.up&(firestarter.remains>cooldown.meteor.duration|!firestarter.active)|cooldown.rune_of_power.remains>target.time_to_die&action.rune_of_power.charges<1|(cooldown.meteor.duration<cooldown.combustion.remains|cooldown.combustion.ready)&!talent.rune_of_power.enabled&(cooldown.meteor.duration<firestarter.remains|!talent.firestarter.enabled|!firestarter.active)
    if S.Meteor:IsCastableP() and (Player:BuffP(S.RuneOfPowerBuff) and S.Firestarter:ActiveRemains() > S.Meteor:BaseDuration() or not bool(S.Firestarter:ActiveStatus()) or S.RuneOfPower:CooldownRemainsP() > Target:TimeToDie() and S.RuneOfPower:ChargesP() < 1 or S.Meteor:BaseDuration() < S.Combustion:CooldownRemainsP() or S.Combustion:CooldownUpP() and not S.RuneOfPower:IsAvailable() and S.Meteor:BaseDuration() < S.Firestarter:ActiveRemains() or not S.Firestarter:IsAvailable() or not bool(S.Firestarter:ActiveStatus())) then
    return S.Meteor:Cast()
    end
  end
  BmCombustionPhase = function()
    -- lights_judgment,if=buff.combustion.down
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() and (Player:BuffDownP(S.CombustionBuff)) then
    return S.LightsJudgment:Cast()
    end
    -- living_bomb,if=buff.combustion.down&active_enemies>1
    if S.LivingBomb:IsCastableP() and (Player:BuffDownP(S.CombustionBuff) and Cache.EnemiesCount[40] > 1) then
    return S.LivingBomb:Cast()
    end
    -- rune_of_power,if=buff.combustion.down
    if S.RuneOfPower:IsCastableP() and (Player:BuffDownP(S.CombustionBuff)) then
    return S.RuneOfPower:Cast()
    end
    -- fire_blast,use_while_casting=1,if=buff.blaster_master.down&(talent.rune_of_power.enabled&action.rune_of_power.executing&action.rune_of_power.execute_remains<0.6|(cooldown.combustion.ready|buff.combustion.up)&!talent.rune_of_power.enabled&!action.pyroblast.in_flight&!action.fireball.in_flight)
    if S.FireBlast:IsCastableP() and (Player:BuffDownP(S.BlasterMasterBuff) and S.RuneOfPower:IsAvailable() and RemainingTimeToCast(S.FireBlast) < 0.6 or S.Combustion:CooldownUpP() or Player:BuffP(S.CombustionBuff) and not S.RuneOfPower:IsAvailable() and not S.Pyroblast:InFlight() and not S.Fireball:InFlight()) then
    return S.FireBlast:Cast()
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- combustion,use_off_gcd=1,use_while_casting=1,if=azerite.blaster_master.enabled&((action.meteor.in_flight&action.meteor.in_flight_remains<0.2)|!talent.meteor.enabled|prev_gcd.1.meteor)&(buff.rune_of_power.up|!talent.rune_of_power.enabled)
    if S.Combustion:IsCastableP() and RubimRH.CDsON() and S.BlasterMaster:AzeriteEnabled() and S.Meteor:InFlight() or not S.Meteor:IsAvailable() or Player:PrevGCDP(1, S.Meteor) and Player:BuffP(S.RuneOfPowerBuff) or not S.RuneOfPower:IsAvailable() then
    return S.Combustion:Cast()
    end
    -- potion

    -- blood_fury
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
    return S.BloodFury:Cast()
    end
    -- berserking
    if S.Berserking:IsCastableP() and RubimRH.CDsON() then
    return S.Berserking:Cast()
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
    return S.Fireblood:Cast()
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() then
    return S.AncestralCall:Cast()
    end
    -- call_action_list,name=trinkets
    if (true) then
      local ShouldReturn = Trinkets(); if ShouldReturn then return ShouldReturn; end
    end
    -- pyroblast,if=prev_gcd.1.scorch&buff.heating_up.up
    if S.Pyroblast:IsCastableP() and (Player:PrevGCDP(1, S.Scorch) and Player:BuffP(S.HeatingUpBuff)) then
        return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.hot_streak.up
    if S.Pyroblast:IsCastableP() and (Player:BuffP(S.HotStreakBuff)) then
    return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.pyroclasm.react&cast_time<buff.combustion.remains
    if S.Pyroblast:IsCastableP() and Player:BuffP(S.PyroclasmBuff) and S.Pyroblast:CastTime() < Player:BuffRemainsP(S.CombustionBuff) then
      return S.Pyroblast:Cast()
    end
    -- phoenix_flames
    if S.PhoenixFlames:IsCastableP() then
    return S.PhoenixFlames:Cast()
    end
    -- fire_blast,use_off_gcd=1,if=buff.blaster_master.stack=1&buff.hot_streak.down&!buff.pyroclasm.react&prev_gcd.1.pyroblast&(buff.blaster_master.remains<0.15|gcd.remains<0.15)
    if S.FireBlast:IsCastableP() and (Player:BuffStackP(S.BlasterMasterBuff) == 1 and Player:BuffDownP(S.HotStreakBuff) and not bool(Player:BuffStackP(S.PyroclasmBuff)) and Player:PrevGCDP(1, S.Pyroblast) and Player:BuffRemainsP(S.BlasterMasterBuff) < 0.15 or Player:GCDRemains() < 0.15) then
    return S.FireBlast:Cast()
    end
    -- fire_blast,use_while_casting=1,if=buff.blaster_master.stack=1&(action.scorch.executing&action.scorch.execute_remains<0.15|buff.blaster_master.remains<0.15)
    if S.FireBlast:IsCastableP() and (Player:BuffStackP(S.BlasterMasterBuff) == 1 and RemainingTimeToCast(S.Scorch) < 0.15 or Player:BuffRemainsP(S.BlasterMasterBuff) < 0.15) then
    return S.FireBlast:Cast()
    end
    -- scorch,if=buff.hot_streak.down&(cooldown.fire_blast.remains<cast_time|action.fire_blast.charges>0)
    if S.Scorch:IsCastableP() and (Player:BuffDownP(S.HotStreakBuff) and S.FireBlast:CooldownRemainsP() < S.Scorch:CastTime() or S.FireBlast:ChargesP() > 0) then
    return S.Scorch:Cast()
    end
    -- fire_blast,use_while_casting=1,use_off_gcd=1,if=buff.blaster_master.stack>1&(prev_gcd.1.scorch&!buff.hot_streak.up&!action.scorch.executing|buff.blaster_master.remains<0.15)
    if S.FireBlast:IsCastableP() and (Player:BuffStackP(S.BlasterMasterBuff) > 1 and Player:PrevGCDP(1, S.Scorch) and not Player:BuffP(S.HotStreakBuff) and not Player:IsCasting(S.Scorch) or Player:BuffRemainsP(S.BlasterMasterBuff) < 0.15) then
    return S.FireBlast:Cast()
    end
    -- living_bomb,if=buff.combustion.remains<gcd.max&active_enemies>1
    if S.LivingBomb:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) < Player:GCD() and Cache.EnemiesCount[40] > 1) then
    return S.LivingBomb:Cast()
    end
    -- dragons_breath,if=buff.combustion.remains<gcd.max
    if S.DragonsBreath:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) < Player:GCD()) then
    return S.DragonsBreath:Cast()
    end
    -- scorch
    if S.Scorch:IsCastableP() then
    return S.Scorch:Cast()
    end
  end
  CombustionPhase = function()
    -- lights_judgment,if=buff.combustion.down
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() and (Player:BuffDownP(S.CombustionBuff)) then
    return S.LightsJudgment:Cast()
    end
    -- call_action_list,name=bm_combustion_phase,if=azerite.blaster_master.enabled&talent.flame_on.enabled
    if S.BlasterMaster:AzeriteEnabled() and S.FlameOn:IsAvailable() then
      local ShouldReturn = BmCombustionPhase(); if ShouldReturn then return ShouldReturn; end
    end
    -- rune_of_power,if=buff.combustion.down
    if S.RuneOfPower:IsCastableP() and (Player:BuffDownP(S.CombustionBuff)) then
    return S.RuneOfPower:Cast()
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- combustion,use_off_gcd=1,use_while_casting=1,if=(!azerite.blaster_master.enabled|!talent.flame_on.enabled)&((action.meteor.in_flight&action.meteor.in_flight_remains<=0.5)|!talent.meteor.enabled)&(buff.rune_of_power.up|!talent.rune_of_power.enabled)
    if S.Combustion:IsCastableP() and RubimRH.CDsON() and (not S.BlasterMaster:AzeriteEnabled() or not S.FlameOn:IsAvailable() and S.Meteor:InFlight() or not S.Meteor:IsAvailable() and Player:BuffP(S.RuneOfPowerBuff) or not S.RuneOfPower:IsAvailable()) then
    return S.Combustion:Cast()
    end
    -- potion

    -- blood_fury
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
    return S.BloodFury:Cast()
    end
    -- berserking
    if S.Berserking:IsCastableP() and RubimRH.CDsON() then
    return S.Berserking:Cast()
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
    return S.Fireblood:Cast()
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() then
    return S.AncestralCall:Cast()
    end
    -- call_action_list,name=trinkets
    if (true) then
      local ShouldReturn = Trinkets(); if ShouldReturn then return ShouldReturn; end
    end
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>2)|active_enemies>6)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 2 or Cache.EnemiesCount[40] > 6 and bool(Player:BuffStackP(S.HotStreakBuff)) then
    return S.Flamestrike:Cast()
    end
    -- pyroblast,if=buff.pyroclasm.react&buff.combustion.remains>cast_time
    if S.Pyroblast:IsCastableP() and Player:BuffP(S.PyroclasmBuff) and Player:BuffRemainsP(S.CombustionBuff) > S.Pyroblast:CastTime() then
    return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.hot_streak.react
    if S.Pyroblast:IsCastableP() and Player:BuffP(S.HotStreakBuff) then
    return S.Pyroblast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=(!azerite.blaster_master.enabled|!talent.flame_on.enabled)&((buff.combustion.up&(buff.heating_up.react&!action.pyroblast.in_flight&!action.scorch.executing)|(action.scorch.execute_remains&buff.heating_up.down&buff.hot_streak.down&!action.pyroblast.in_flight)))
    if S.FireBlast:IsCastableP() and (not S.BlasterMaster:AzeriteEnabled() or not S.FlameOn:IsAvailable() and Player:BuffP(S.CombustionBuff) and bool(Player:BuffStackP(S.HeatingUpBuff)) and not S.Pyroblast:InFlight() and not Player:IsCasting(S.Scorch) or RemainingTimeToCast(S.Scorch) > 0.1 and Player:BuffDownP(S.HeatingUpBuff) and Player:BuffDownP(S.HotStreakBuff) and not S.Pyroblast:InFlight()) then
    return S.FireBlast:Cast()
    end
    -- pyroblast,if=prev_gcd.1.scorch&buff.heating_up.up
    if S.Pyroblast:IsCastableP() and Player:PrevGCDP(1, S.Scorch) and Player:BuffP(S.HeatingUpBuff) then
    return S.Pyroblast:Cast()
    end
    -- phoenix_flames
    if S.PhoenixFlames:IsCastableP() then
    return S.PhoenixFlames:Cast()
    end
    -- scorch,if=buff.combustion.remains>cast_time&buff.combustion.up|buff.combustion.down
    if S.Scorch:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) > S.Scorch:CastTime() and Player:BuffP(S.CombustionBuff) or Player:BuffDownP(S.CombustionBuff)) then
    return S.Scorch:Cast()
    end
    -- living_bomb,if=buff.combustion.remains<gcd.max&active_enemies>1
    if S.LivingBomb:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) < Player:GCD() and Cache.EnemiesCount[40] > 1) then
    return S.LivingBomb:Cast()
    end
    -- dragons_breath,if=buff.combustion.remains<gcd.max&buff.combustion.up
    if S.DragonsBreath:IsCastableP() and (Player:BuffRemainsP(S.CombustionBuff) < Player:GCD() and Player:BuffP(S.CombustionBuff)) then
    return S.DragonsBreath:Cast()
    end
    -- scorch,if=target.health.pct<=30&talent.searing_touch.enabled
    if S.Scorch:IsCastableP() and (Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) then
    return S.Scorch:Cast()
    end
  end
  RopPhase = function()
    -- rune_of_power
    if S.RuneOfPower:IsCastableP() and S.RuneOfPower:CooldownRemainsP() < 0.1 then
    return S.RuneOfPower:Cast()
    end
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|active_enemies>4)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 1 or Cache.EnemiesCount[40] > 4 and bool(Player:BuffStackP(S.HotStreakBuff)) then
    return S.Flamestrike:Cast()
    end
    -- pyroblast,if=buff.hot_streak.react
    if S.Pyroblast:IsCastableP() and Player:BuffP(S.HotStreakBuff) then
    return S.Pyroblast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=(cooldown.combustion.remains>0|firestarter.active&buff.rune_of_power.up)&(!buff.heating_up.react&!buff.hot_streak.react&!prev_off_gcd.fire_blast&(action.fire_blast.charges>=2|(action.phoenix_flames.charges>=1&talent.phoenix_flames.enabled)|(talent.alexstraszas_fury.enabled&cooldown.dragons_breath.ready)|(talent.searing_touch.enabled&target.health.pct<=30)|(talent.firestarter.enabled&firestarter.active)))
    if S.FireBlast:IsCastableP() and S.Combustion:CooldownRemainsP() > 0 or bool(S.Firestarter:ActiveStatus()) and Player:BuffP(S.RuneOfPowerBuff) and not bool(Player:BuffStackP(S.HeatingUpBuff)) and not bool(Player:BuffStackP(S.HotStreakBuff)) and not Player:PrevOffGCDP(1, S.FireBlast) and S.FireBlast:ChargesP() >= 2 or S.PhoenixFlames:ChargesP() >= 1 and S.PhoenixFlames:IsAvailable() or S.AlexstraszasFury:IsAvailable() and S.DragonsBreath:CooldownUpP() or S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 or S.Firestarter:IsAvailable() and bool(S.Firestarter:ActiveStatus()) then
    return S.FireBlast:Cast()
    end
    -- call_action_list,name=active_talents
    if (true) then
      local ShouldReturn = ActiveTalents(); if ShouldReturn then return ShouldReturn; end
    end
    -- pyroblast,if=buff.pyroclasm.react&cast_time<buff.pyroclasm.remains&buff.rune_of_power.remains>cast_time
    if S.Pyroblast:IsCastableP() and Player:BuffP(S.PyroclasmBuff) and S.Pyroblast:CastTime() < Player:BuffRemainsP(S.PyroclasmBuff) and Player:BuffRemainsP(S.RuneOfPowerBuff) > S.Pyroblast:CastTime() then
    return S.Pyroblast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=(cooldown.combustion.remains>0|firestarter.active&buff.rune_of_power.up)&(buff.heating_up.react&(target.health.pct>=30|!talent.searing_touch.enabled))
    if S.FireBlast:IsCastableP() and S.Combustion:CooldownRemainsP() > 0 or bool(S.Firestarter:ActiveStatus()) and Player:BuffP(S.RuneOfPowerBuff) and bool(Player:BuffStackP(S.HeatingUpBuff)) and Target:HealthPercentage() >= 30 or not S.SearingTouch:IsAvailable() then
    return S.FireBlast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=(cooldown.combustion.remains>0|firestarter.active&buff.rune_of_power.up)&talent.searing_touch.enabled&target.health.pct<=30&(buff.heating_up.react&!action.scorch.executing|!buff.heating_up.react&!buff.hot_streak.react)
    if S.FireBlast:IsCastableP() and S.Combustion:CooldownRemainsP() > 0 or bool(S.Firestarter:ActiveStatus()) and Player:BuffP(S.RuneOfPowerBuff) and S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 and bool(Player:BuffStackP(S.HeatingUpBuff)) and not Player:IsCasting(S.Scorch) or not bool(Player:BuffStackP(S.HeatingUpBuff)) and not bool(Player:BuffStackP(S.HotStreakBuff)) then
    return S.FireBlast:Cast()
    end
    -- pyroblast,if=prev_gcd.1.scorch&buff.heating_up.up&talent.searing_touch.enabled&target.health.pct<=30&(!talent.flame_patch.enabled|active_enemies=1)
    if S.Pyroblast:IsCastableP() and (Player:PrevGCDP(1, S.Scorch) and Player:BuffP(S.HeatingUpBuff) and S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 and not S.FlamePatch:IsAvailable() or Cache.EnemiesCount[40] == 1) then
    return S.Pyroblast:Cast()
    end
    -- phoenix_flames,if=!prev_gcd.1.phoenix_flames&buff.heating_up.react
    if S.PhoenixFlames:IsCastableP() and (not Player:PrevGCDP(1, S.PhoenixFlames) and bool(Player:BuffStackP(S.HeatingUpBuff))) then
    return S.PhoenixFlames:Cast()
    end
    -- scorch,if=target.health.pct<=30&talent.searing_touch.enabled
    if S.Scorch:IsCastableP() and (Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) then
    return S.Scorch:Cast()
    end
    -- dragons_breath,if=active_enemies>2
    if S.DragonsBreath:IsCastableP() and (Cache.EnemiesCount[40] > 2) then
    return S.DragonsBreath:Cast()
    end
    -- flamestrike,if=(talent.flame_patch.enabled&active_enemies>2)|active_enemies>5
    if S.Flamestrike:IsCastableP() and S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 2 or Cache.EnemiesCount[40] > 5 then
    return S.Flamestrike:Cast()
    end
    -- fireball
    if S.Fireball:IsCastableP() then
    return S.Fireball:Cast()
    end
  end
  StandardRotation = function()
    -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>1&!firestarter.active)|active_enemies>4)&buff.hot_streak.react
    if S.Flamestrike:IsCastableP() and S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 1 and not bool(S.Firestarter:ActiveStatus()) or Cache.EnemiesCount[40] > 4 and Player:BuffP(S.HotStreakBuff) then
      return S.Flamestrike:Cast()
    end
    -- pyroblast,if=buff.hot_streak.react&buff.hot_streak.remains<action.fireball.execute_time
    if S.Pyroblast:IsCastableP() and Player:BuffP(S.HotStreakBuff) and Player:BuffRemainsP(S.HotStreakBuff) < S.Fireball:ExecuteTime() then
      return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.hot_streak.react&(prev_gcd.1.fireball|firestarter.active|action.pyroblast.in_flight)
    if S.Pyroblast:IsCastableP() and Player:BuffP(S.HotStreakBuff) and Player:PrevGCDP(1, S.Fireball) or bool(S.Firestarter:ActiveStatus()) or S.Pyroblast:InFlight() then
      return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.hot_streak.react&target.health.pct<=30&talent.searing_touch.enabled
    if S.Pyroblast:IsCastableP() and Player:BuffP(S.HotStreakBuff) and Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable() then
      return S.Pyroblast:Cast()
    end
    -- pyroblast,if=buff.pyroclasm.react&cast_time<buff.pyroclasm.remains
    if S.Pyroblast:IsCastableP() and (bool(Player:BuffStackP(S.PyroclasmBuff)) and S.Pyroblast:CastTime() < Player:BuffRemainsP(S.PyroclasmBuff)) then
      return S.Pyroblast:Cast()
    end
    -- fire_blast,use_off_gcd=1,use_while_casting=1,if=(cooldown.combustion.remains>0&buff.rune_of_power.down|firestarter.active)&!talent.kindling.enabled&!variable.fire_blast_pooling&(((action.fireball.executing|action.pyroblast.executing)&(buff.heating_up.react|firestarter.active&!buff.hot_streak.react&!buff.heating_up.react))|(talent.searing_touch.enabled&target.health.pct<=30&(buff.heating_up.react&!action.scorch.executing|!buff.hot_streak.react&!buff.heating_up.react&action.scorch.executing&!action.pyroblast.in_flight&!action.fireball.in_flight))|(firestarter.active&(action.pyroblast.in_flight|action.fireball.in_flight)&!buff.heating_up.react&!buff.hot_streak.react))
    if S.FireBlast:IsCastableP() and S.Combustion:CooldownRemainsP() > 0 and Player:BuffDownP(S.RuneOfPowerBuff) or bool(S.Firestarter:ActiveStatus()) and not S.Kindling:IsAvailable() and not bool(VarFireBlastPooling) and Player:IsCasting(S.Fireball) or Player:IsCasting(S.Pyroblast) and bool(Player:BuffStackP(S.HeatingUpBuff)) or bool(S.Firestarter:ActiveStatus()) and not bool(Player:BuffStackP(S.HotStreakBuff)) and not bool(Player:BuffStackP(S.HeatingUpBuff)) or S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 and bool(Player:BuffStackP(S.HeatingUpBuff)) and not Player:IsCasting(S.Scorch) or not bool(Player:BuffStackP(S.HotStreakBuff)) and not bool(Player:BuffStackP(S.HeatingUpBuff)) and Player:IsCasting(S.Scorch) and not S.Pyroblast:InFlight() and not S.Fireball:InFlight() or bool(S.Firestarter:ActiveStatus()) and S.Pyroblast:InFlight() or S.Fireball:InFlight() and not bool(Player:BuffStackP(S.HeatingUpBuff)) and not bool(Player:BuffStackP(S.HotStreakBuff)) then
      return S.FireBlast:Cast()
    end
    -- fire_blast,if=talent.kindling.enabled&buff.heating_up.react&(cooldown.combustion.remains>full_recharge_time+2+talent.kindling.enabled|firestarter.remains>full_recharge_time|(!talent.rune_of_power.enabled|cooldown.rune_of_power.remains>target.time_to_die&action.rune_of_power.charges<1)&cooldown.combustion.remains>target.time_to_die)
  --  if S.FireBlast:IsCastableP() and S.Kindling:IsAvailable() and Player:BuffP(S.HeatingUpBuff) and S.Combustion:CooldownRemainsP() > S.FireBlast:FullRechargeTimeP() + 2 + num(S.Kindling:IsAvailable()) or S.Firestarter:ActiveRemains() > S.FireBlast:FullRechargeTimeP() or not S.RuneOfPower:IsAvailable() or S.RuneOfPower:CooldownRemainsP() > Target:TimeToDie() and S.RuneOfPower:ChargesP() < 1 and S.Combustion:CooldownRemainsP() > Target:TimeToDie() then
  --  return S.FireBlast:Cast()
  --  end
    -- pyroblast,if=prev_gcd.1.scorch&buff.heating_up.up&talent.searing_touch.enabled&target.health.pct<=30&((talent.flame_patch.enabled&active_enemies=1&!firestarter.active)|(active_enemies<4&!talent.flame_patch.enabled))
    if S.Pyroblast:IsCastableP() and (Player:PrevGCDP(1, S.Scorch) and Player:BuffP(S.HeatingUpBuff) and S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 and S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] == 1 and not bool(S.Firestarter:ActiveStatus()) or Cache.EnemiesCount[40] < 4 and not S.FlamePatch:IsAvailable()) then
      return S.Pyroblast:Cast()
    end
    -- phoenix_flames,if=(buff.heating_up.react|(!buff.hot_streak.react&(action.fire_blast.charges>0|talent.searing_touch.enabled&target.health.pct<=30)))&!variable.phoenix_pooling
    if S.PhoenixFlames:IsCastableP() and (bool(Player:BuffStackP(S.HeatingUpBuff)) or not bool(Player:BuffStackP(S.HotStreakBuff)) and S.FireBlast:ChargesP() > 0 or S.SearingTouch:IsAvailable() and Target:HealthPercentage() <= 30 and not bool(VarPhoenixPooling)) then
      return S.PhoenixFlames:Cast()
    end
    -- call_action_list,name=active_talents
    if (true) then
      return ActiveTalents()
    end
    -- dragons_breath,if=active_enemies>1
    if S.DragonsBreath:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      return S.DragonsBreath:Cast()
    end
    -- use_item,name=tidestorm_codex,if=cooldown.combustion.remains>20|talent.firestarter.enabled&firestarter.remains>20
    --if I.TidestormCodex:IsReady() and S.Combustion:CooldownRemainsP() > 20 or S.Firestarter:IsAvailable() and S.Firestarter:ActiveRemains() > 20) then
    --  (I.TidestormCodex:Cast()
   -- end
    -- scorch,if=target.health.pct<=30&talent.searing_touch.enabled
    if S.Scorch:IsCastableP() and (Target:HealthPercentage() <= 30 and S.SearingTouch:IsAvailable()) then
    return S.Scorch:Cast()
    end
    -- fireball
    if S.Fireball:IsCastableP() then
    return S.Fireball:Cast()
    end
    -- scorch
    if S.Scorch:IsCastableP() then
    return S.Scorch:Cast()
    end
  end
  Trinkets = function()
    -- use_items
  end
  
  -- call precombat
  if not Player:AffectingCombat() and not Player:IsCasting() then
    return Precombat()
  end
 
 if RubimRH.TargetIsValid() then
   	  if QueueSkill() ~= nil then
        return QueueSkill()
      end
    -- counterspell
    -- mirror_image,if=buff.combustion.down
    if S.MirrorImage:IsCastableP() and (Player:BuffDownP(S.CombustionBuff)) then
    return S.MirrorImage:Cast()
    end
    -- rune_of_power,if=talent.firestarter.enabled&firestarter.remains>full_recharge_time|cooldown.combustion.remains>variable.combustion_rop_cutoff&buff.combustion.down|target.time_to_die<cooldown.combustion.remains&buff.combustion.down
    if S.RuneOfPower:IsCastableP() and S.Firestarter:IsAvailable() and S.Firestarter:ActiveRemains() > S.RuneOfPower:FullRechargeTimeP() or S.Combustion:CooldownRemainsP() > VarCombustionRopCutoff and Player:BuffDownP(S.CombustionBuff) or Target:TimeToDie() < S.Combustion:CooldownRemainsP() and Player:BuffDownP(S.CombustionBuff) then
    return S.RuneOfPower:Cast()
    end
    -- call_action_list,name=combustion_phase,if=(talent.rune_of_power.enabled&cooldown.combustion.remains<=action.rune_of_power.cast_time|cooldown.combustion.ready)&!firestarter.active|buff.combustion.up
    if RubimRH.CDsON() and S.RuneOfPower:IsAvailable() and S.Combustion:CooldownRemainsP() <= S.RuneOfPower:CastTime() or S.Combustion:CooldownUpP() and not bool(S.Firestarter:ActiveStatus()) or Player:BuffP(S.CombustionBuff) then
      return CombustionPhase()
    end
    -- call_action_list,name=rop_phase,if=buff.rune_of_power.up&buff.combustion.down
    if (Player:BuffP(S.RuneOfPowerBuff) and Player:BuffDownP(S.CombustionBuff)) then
      return RopPhase()
    end
    -- variable,name=fire_blast_pooling,value=talent.rune_of_power.enabled&cooldown.rune_of_power.remains<cooldown.fire_blast.full_recharge_time&(cooldown.combustion.remains>variable.combustion_rop_cutoff|firestarter.active)&(cooldown.rune_of_power.remains<target.time_to_die|action.rune_of_power.charges>0)|cooldown.combustion.remains<action.fire_blast.full_recharge_time+cooldown.fire_blast.duration*azerite.blaster_master.enabled&!firestarter.active&cooldown.combustion.remains<target.time_to_die|talent.firestarter.enabled&firestarter.active&firestarter.remains<cooldown.fire_blast.full_recharge_time+cooldown.fire_blast.duration*azerite.blaster_master.enabled
    if (true) then
      VarFireBlastPooling = num(S.RuneOfPower:IsAvailable()) and S.RuneOfPower:CooldownRemainsP() < S.FireBlast:FullRechargeTimeP() and S.Combustion:CooldownRemainsP() > VarCombustionRopCutoff or bool(S.Firestarter:ActiveStatus()) and S.RuneOfPower:CooldownRemainsP() < Target:TimeToDie() or S.RuneOfPower:ChargesP() > 0 or S.Combustion:CooldownRemainsP() < S.FireBlast:FullRechargeTimeP() + S.FireBlast:BaseDuration() * num(S.BlasterMaster:AzeriteEnabled()) and not bool(S.Firestarter:ActiveStatus()) and S.Combustion:CooldownRemainsP() < Target:TimeToDie() or S.Firestarter:IsAvailable() and bool(S.Firestarter:ActiveStatus()) and S.Firestarter:ActiveRemains() < S.FireBlast:FullRechargeTimeP() + S.FireBlast:BaseDuration() * num(S.BlasterMaster:AzeriteEnabled())
    end
    -- variable,name=phoenix_pooling,value=talent.rune_of_power.enabled&cooldown.rune_of_power.remains<cooldown.phoenix_flames.full_recharge_time&cooldown.combustion.remains>variable.combustion_rop_cutoff&(cooldown.rune_of_power.remains<target.time_to_die|action.rune_of_power.charges>0)|cooldown.combustion.remains<action.phoenix_flames.full_recharge_time&cooldown.combustion.remains<target.time_to_die
    if (true) then
      VarPhoenixPooling = num(S.RuneOfPower:IsAvailable()) and S.RuneOfPower:CooldownRemainsP() < S.PhoenixFlames:FullRechargeTimeP() and S.Combustion:CooldownRemainsP() > VarCombustionRopCutoff and S.RuneOfPower:CooldownRemainsP() < Target:TimeToDie() or S.RuneOfPower:ChargesP() > 0 or S.Combustion:CooldownRemainsP() < S.PhoenixFlames:FullRechargeTimeP() and S.Combustion:CooldownRemainsP() < Target:TimeToDie()
    end
    -- call_action_list,name=standard_rotation
    if (true) then
      return StandardRotation()
    end

    end
	return 0, 135328
end

RubimRH.Rotation.SetAPL(63, APL)

local function PASSIVE()
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(63, PASSIVE)