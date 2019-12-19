-- ----- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...;
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
-- Lua
local pairs      = pairs;

--- ============================ CONTENT ============================
--- ======= APL LOCALS =======
-- Spells
RubimRH.Spell[269] = {
  -- Racials
  Bloodlust                             = Spell(2825),
  ArcaneTorrent                         = Spell(25046),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  GiftoftheNaaru                        = Spell(59547),
  Shadowmeld                            = Spell(58984),
  QuakingPalm                           = Spell(107079),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),

  -- Abilities
  TigerPalm                             = Spell(100780),
  RisingSunKick                         = Spell(107428),
  FistsOfFury                           = Spell(113656),
  SpinningCraneKick                     = Spell(101546),
  StormEarthAndFire                     = Spell(137639),
  FlyingSerpentKick                     = Spell(101545),
  FlyingSerpentKick2                    = Spell(115057),
  TouchOfDeath                          = Spell(115080),
  CracklingJadeLightning                = Spell(117952),
  BlackoutKick                          = Spell(100784),
  BlackoutKickBuff                      = Spell(116768),
  DanceOfChijiBuff                      = Spell(286587),

  -- Talents
  ChiWave                               = Spell(115098),
  ChiBurst                              = Spell(123986),
  FistOfTheWhiteTiger                   = Spell(261947),
  HitCombo                              = Spell(196741),
  InvokeXuentheWhiteTiger               = Spell(123904),
  RushingJadeWind                       = Spell(261715),
  WhirlingDragonPunch                   = Spell(152175),
  Serenity                              = Spell(152173),

  -- Artifact
  StrikeOfTheWindlord                   = Spell(205320),

  -- Defensive
  TouchOfKarma                          = Spell(122470),
  DiffuseMagic                          = Spell(122783), --Talent
  DampenHarm                            = Spell(122278), --Talent

  -- Utility
  Detox                                 = Spell(218164),
  Effuse                                = Spell(116694),
  EnergizingElixir                      = Spell(115288), --Talent
  TigersLust                            = Spell(116841), --Talent
  LegSweep                              = Spell(119381), --Talent
  Disable                               = Spell(116095),
  HealingElixir                         = Spell(122281), --Talent
  Paralysis                             = Spell(115078),
  SpearHandStrike                       = Spell(116705),

  -- Legendaries
  TheEmperorsCapacitor                  = Spell(235054),

  -- Tier Set
  PressurePoint                         = Spell(247255),

  -- Azerite Traits
  SwiftRoundhouse                       = Spell(277669),
  SwiftRoundhouseBuff                   = Spell(278710),
  
  -- PvP Abilities
  ReverseHarm                           = Spell(287771),
  
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

  -- Misc
  --PoolEnergy                            = Spell(9999000010)
};
local S = RubimRH.Spell[269];

S.FlyingSerpentKick.TextureSpellID = { 124176 } -- Raptor Strikes

-- Items
if not Item.Monk then Item.Monk = {}; end
Item.Monk.Windwalker = {
  PotionofUnbridledFury                = Item(169299)
};
local I = Item.Monk.Windwalker;

local EnemyRanges = {8, 5}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
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
end

--HL.RegisterNucleusAbility(113656, 8, 6)               -- Fists of Fury
--HL.RegisterNucleusAbility(101546, 8, 6)               -- Spinning Crane Kick
--HL.RegisterNucleusAbility(261715, 8, 6)               -- Rushing Jade Wind
--HL.RegisterNucleusAbility(152175, 8, 6)               -- Whirling Dragon Punch

-- Action Lists --
--- ======= MAIN =======
-- APL Main
local function APL ()
  local Precombat_DBM, Precombat, Essences, Cooldowns, SingleTarget, Serenity, Aoe
  -- Unit Update
  UpdateRanges()
  DetermineEssenceRanks()
  
  
  -- Pre Combat --
  Precombat_DBM = function()
    -- potion
    if I.PotionofUnbridledFury:IsReady() and RubimRH.DBM_PullTimer() > 0.01 + Player:GCD() and RubimRH.DBM_PullTimer() < 0.1 + Player:GCD() then
        return 967532
    end
    -- actions.precombat+=/chi_burst,if=(!talent.serenity.enabled|!talent.fist_of_the_white_tiger.enabled)
    if S.ChiBurst:IsReadyP() and RubimRH.PerfectPullON() and RubimRH.DBM_PullTimer() > 0.01 and RubimRH.DBM_PullTimer() < 0.1 and (not S.Serenity:IsAvailable() or not S.FistOfTheWhiteTiger:IsAvailable()) then
      return S.ChiBurst:Cast()
    end
    -- actions.precombat+=/chi_wave
    if S.ChiWave:IsReadyP() and RubimRH.PerfectPullON() and RubimRH.DBM_PullTimer() > 0.01 and RubimRH.DBM_PullTimer() < 0.1 then
      return S.ChiWave:Cast()
    end
  end
  
  -- Pre Combat --
  Precombat = function()
    -- potion
    -- actions.precombat+=/chi_burst,if=(!talent.serenity.enabled|!talent.fist_of_the_white_tiger.enabled)
    if S.ChiBurst:IsReadyP() and (not S.Serenity:IsAvailable() or not S.FistOfTheWhiteTiger:IsAvailable()) then
      return S.ChiBurst:Cast()
    end
    -- actions.precombat+=/chi_wave
    if S.ChiWave:IsReadyP() then
      return S.ChiWave:Cast()
    end
  end
  
  -- Essences --
  Essences = function()
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- blood_of_the_enemy
    if S.BloodOfTheEnemy:IsCastableP() then
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
    -- memory_of_lucid_dreams,if=energy<40&buff.storm_earth_and_fire.up
    if S.MemoryOfLucidDreams:IsCastableP() and (Player:Energy() < 40 and Player:BuffP(S.StormEarthAndFire)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
  end

  -- Cooldowns --
  Cooldowns = function()
    -- actions.cd=invoke_xuen_the_white_tiger
    if RubimRH.CDsON() and S.InvokeXuentheWhiteTiger:IsReadyP() then
      return S.InvokeXuentheWhiteTiger:Cast()
    end
    -- actions.cd+=/blood_fury
    if RubimRH.CDsON() and S.BloodFury:IsReadyP() then
      return S.BloodFury:Cast()
    end
    -- actions.cd+=/berserking
    if RubimRH.CDsON() and S.Berserking:IsReadyP() then
      return S.Berserking:Cast()
    end
    -- actions.cd+=/arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsReadyP() and (Player:ChiDeficit() >= 1 and Player:EnergyTimeToMaxPredicted() > 0.5) then
      return S.ArcaneTorrent:Cast()
    end
    -- actions.cd+=/fireblood
    if RubimRH.CDsON() and S.Fireblood:IsReadyP() then
      return S.Fireblood:Cast()
    end
    -- actions.cd+=/ancestral_call
    if RubimRH.CDsON() and S.AncestralCall:IsReadyP() then
      return S.AncestralCall:Cast()
    end
    -- actions.cd+=/touch_of_death,if=target.time_to_die>9
    if RubimRH.CDsON() and S.TouchOfDeath:IsReadyP() and (Target:TimeToDie() > 9) then
      return S.TouchOfDeath:Cast()
    end
    -- actions.cd+=/storm_earth_and_fire,if=cooldown.storm_earth_and_fire.charges=2|(cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=15
    if RubimRH.CDsON() and S.StormEarthAndFire:IsReadyP() and (not Player:BuffP(S.StormEarthAndFire) and (S.StormEarthAndFire:ChargesP() == 2 or S.FistsOfFury:CooldownRemainsP() <= 6) and Player:Chi() >= 3 and (S.RisingSunKick:CooldownRemainsP() <= 1 or Target:TimeToDie() <= 15)) then
      return S.StormEarthAndFire:Cast()
    end
	-- use_item,name=trinkets.if=player.buff.storm_earth_and_fire
    if Player:BuffP(S.StormEarthAndFire) and RubimRH.CDsON() then
	    if trinketReady(1) then
            return trinket1
		elseif trinketReady(2) then
		    return trinket2
		else
		    return
		end
    end
    -- actions.cd+=/serenity,if=cooldown.rising_sun_kick.remains<=2|target.time_to_die<=12
    if RubimRH.CDsON() and S.Serenity:IsReadyP() and (not Player:BuffP(S.Serenity) and (S.RisingSunKick:CooldownRemainsP() <= 2 or Target:TimeToDie() <= 12)) then
      return S.Serenity:Cast()
    end
    -- call_action_list,name=essences
    if (true) then
      local ShouldReturn = Essences(); if ShouldReturn then return ShouldReturn; end
    end
  end

  -- Serenity --
  Serenity = function()
    -- actions.serenity=rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=active_enemies<3|prev_gcd.1.spinning_crane_kick
    if S.RisingSunKick:IsReadyP() and (Cache.EnemiesCount[5] < 3 or Player:PrevGCD(1,S.SpinningCraneKick)) then
      return S.RisingSunKick:Cast()
    end
    -- actions.serenity+=/fists_of_fury,if=(buff.bloodlust.up&prev_gcd.1.rising_sun_kick&!azerite.swift_roundhouse.enabled)|buff.serenity.remains<1|(active_enemies>1&active_enemies<5)
    if S.FistsOfFury:IsReadyP() and ((Player:HasHeroismP() and Player:PrevGCD(1,S.RisingSunKick) and not S.SwiftRoundhouse:AzeriteEnabled()) or Player:BuffRemainsP(S.Serenity) < 1 or (Cache.EnemiesCount[8] > 1 and Cache.EnemiesCount[8] < 5)) then
      return S.FistsOfFury:Cast()
    end
    -- actions.serenity+=/spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&(active_enemies>=3|(active_enemies=2&prev_gcd.1.blackout_kick))
    if S.SpinningCraneKick:IsReadyP() and (not Player:PrevGCD(1, S.SpinningCraneKick) and (Cache.EnemiesCount[8] >= 3 or (Cache.EnemiesCount[8] == 2 and Player:PrevGCD(1, S.BlackoutKick)))) then
      return S.SpinningCraneKick:Cast()
    end
    -- actions.serenity+=/blackout_kick,target_if=min:debuff.mark_of_the_crane.remains
    if S.BlackoutKick:IsReadyP() then
      return S.BlackoutKick:Cast()
    end
  end

  -- Area of Effect --
  Aoe = function()
    -- actions.aoe=rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(talent.whirling_dragon_punch.enabled&cooldown.whirling_dragon_punch.remains<5)&cooldown.fists_of_fury.remains>3
    if S.RisingSunKick:IsReadyP() and ((S.WhirlingDragonPunch:IsAvailable() and S.WhirlingDragonPunch:CooldownRemainsP() < 5) and S.FistsOfFury:CooldownRemainsP() > 3) then
      return S.RisingSunKick:Cast()
    end
    -- actions.aoe=whirling_dragon_punch
    if S.WhirlingDragonPunch:IsReady() then
      return S.WhirlingDragonPunch:Cast()
    end
    -- actions.aoe+=/energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&energy<50
    if S.EnergizingElixir:IsReadyP() and (not Player:PrevGCD(1, S.TigerPalm) and Player:Chi() <= 1 and Player:EnergyPredicted() < 50) then
      return S.EnergizingElixir:Cast()
    end
    -- actions.aoe+=/fists_of_fury,if=energy.time_to_max>3
    if S.FistsOfFury:IsReadyP() and (Player:EnergyTimeToMaxPredicted() > 3) then
      return S.FistsOfFury:Cast()
    end
    -- actions.aoe+=/rushing_jade_wind,if=buff.rushing_jade_wind.down
     if S.RushingJadeWind:IsReadyP() and (Player:BuffDownP(S.RushingJadeWind)) then
      return S.RushingJadeWind:Cast()
    end
    -- actions.aoe+=/spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&((chi>3|cooldown.fists_of_fury.remains>6)&(chi>=5|cooldown.fists_of_fury.remains>2)|energy.time_to_max<=3)
    if S.SpinningCraneKick:IsReadyP() and (not Player:PrevGCD(1, S.SpinningCraneKick) and (((Player:Chi() > 3 or S.FistsOfFury:CooldownRemainsP() > 6) and (Player:Chi() >= 5 or S.FistsOfFury:CooldownRemainsP() > 2)) or Player:EnergyTimeToMaxPredicted() <= 3)) then
      return S.SpinningCraneKick:Cast()
    end
    -- actions.aoe+=/reverse_harm,if=chi.max-chi>=2
    if S.ReverseHarm:IsReady() and (Player:ChiDeficit() >= 2) then
      return S.ReverseHarm:Cast()
    end
    -- actions.aoe+=/chi_burst,if=chi<=3
    if S.ChiBurst:IsReadyP() and (Player:ChiDeficit() <= 3) then
      return S.ChiBurst:Cast()
    end  
    -- actions.aoe+=/fist_of_the_white_tiger,if=chi.max-chi>=3
    if S.FistOfTheWhiteTiger:IsReadyP() and (Player:ChiDeficit() >= 3) then
      return S.FistOfTheWhiteTiger:Cast()
    end
    -- actions.aoe+=/tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=chi.max-chi>=2&(!talent.hit_combo.enabled|!prev_gcd.1.tiger_palm)
    if S.TigerPalm:IsReadyP() and (Player:ChiDeficit() >= 2 and (not S.HitCombo:IsAvailable() or not Player:PrevGCD(1, S.TigerPalm))) then
      return S.TigerPalm:Cast()
    end
    -- actions.st+=/chi_wave
    if S.ChiWave:IsReadyP() then
      return S.ChiWave:Cast()
    end
    -- actions.aoe+=/flying_serpent_kick,if=buff.bok_proc.down,interrupt=1
    -- actions.aoe+=/blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&(buff.bok_proc.up|(talent.hit_combo.enabled&prev_gcd.1.tiger_palm&chi<4))
    if S.BlackoutKick:IsReadyP() and (not Player:PrevGCD(1, S.BlackoutKick) and (Player:BuffP(S.BlackoutKickBuff) or (S.HitCombo:IsAvailable() and Player:PrevGCD(1, S.TigerPalm) and Player:Chi() < 4))) then
      return S.BlackoutKick:Cast()
    end
  end

  -- Single Target --
  SingleTarget = function()
    -- actions.st+=/whirling_dragon_punch
    if S.WhirlingDragonPunch:IsReady() then
      return S.WhirlingDragonPunch:Cast()
    end
    -- actions.st+=/rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=chi>=5
    if S.RisingSunKick:IsReadyP() and (Player:Chi() >= 5) then
      return S.RisingSunKick:Cast()
    end
    -- actions.st+=/fists_of_fury,if=energy.time_to_max>3
    if S.FistsOfFury:IsReadyP() and (Player:EnergyTimeToMaxPredicted() > 3) then
      return S.FistsOfFury:Cast()
    end
    -- actions.st+=/rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
    if S.RisingSunKick:IsReadyP() then
      return S.RisingSunKick:Cast()
    end
    -- actions.st+=/rushing_jade_wind,if=buff.rushing_jade_wind.down&active_enemies>1
    if S.RushingJadeWind:IsReadyP() and (Player:BuffDownP(S.RushingJadeWind) and Cache.EnemiesCount[8] > 1) then
      return S.RushingJadeWind:Cast()
    end
    -- actions.st+=/reverse_harm,if=chi.max-chi>=2
    if S.ReverseHarm:IsReady() and (Player:ChiDeficit() >= 2) then
      return S.ReverseHarm:Cast()
    end
    -- actions.st+=/fist_of_the_white_tiger,if=chi<=2
    if S.FistOfTheWhiteTiger:IsReadyP() and (Player:Chi() <= 2) then
      return S.FistOfTheWhiteTiger:Cast()
    end
    -- actions.st+=/energizing_elixir,if=chi<=3&energy<50
    if S.EnergizingElixir:IsReadyP() and (Player:Chi() <= 3 and Player:EnergyPredicted() < 50) then
      return S.EnergizingElixir:Cast()
    end
    -- actions.st+=/spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&buff.dance_of_chiji.up
    if S.SpinningCraneKick:IsReadyP() and (not Player:PrevGCD(1, S.SpinningCraneKick) and Player:BuffP(S.DanceOfChijiBuff)) then 
      return S.SpinningCraneKick:Cast()
    end
    -- actions.st+=/blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&(cooldown.rising_sun_kick.remains>3|chi>=3)&(cooldown.fists_of_fury.remains>4|chi>=4|(chi=2&prev_gcd.1.tiger_palm)|(azerite.swift_roundhouse.rank>=2&active_enemies=1))&buff.swift_roundhouse.stack<2
    if S.BlackoutKick:IsReadyP() and (not Player:PrevGCD(1, S.BlackoutKick) and (S.RisingSunKick:CooldownRemainsP() > 3 or Player:Chi() >= 3) and (S.FistsOfFury:CooldownRemainsP() > 4 or Player:Chi() >= 4 or (Player:Chi() == 2 and Player:PrevGCD(1, S.TigerPalm)) or (S.SwiftRoundhouse:AzeriteRank() >= 2 and Cache.EnemiesCount[5] == 1)) and Player:BuffStack(S.SwiftRoundhouseBuff) < 2) then
      return S.BlackoutKick:Cast()
    end
    -- actions.st+=/chi_wave
    if S.ChiWave:IsReadyP() then
      return S.ChiWave:Cast()
    end
    -- actions.st+=/chi_burst,if=chi.max-chi>=1&active_enemies=1|chi.max-chi>=2
    if S.ChiBurst:IsReadyP() and ((Player:ChiDeficit() >= 1 and Cache.EnemiesCount[8] == 1) or Player:ChiDeficit() >= 2) then
      return S.ChiBurst:Cast()
    end  
    -- actions.st+=/tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&chi.max-chi>=2&(buff.rushing_jade_wind.down|energy>56)
    if S.TigerPalm:IsReadyP() and (not Player:PrevGCD(1, S.TigerPalm) and Player:ChiDeficit() >= 2 and (Player:BuffDownP(S.RushingJadeWind) or Player:EnergyPredicted() > 56)) then
      return S.TigerPalm:Cast()
    end
    -- actions.st+=/flying_serpent_kick,if=prev_gcd.1.blackout_kick&chi>3&buff.swift_roundhouse.stack<2,interrupt=1
  end
  
    -- Protect against interrupt of channeled spells
  if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) or Player:IsChanneling() then
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

  -- In Combat
  if RubimRH.TargetIsValid() then
    -- QueueSkill
    if QueueSkill() ~= nil then
		return QueueSkill()
    end
    -- spear_hand_strike,if=target.debuff.casting.react
    if S.SpearHandStrike:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.SpearHandStrike:Cast()
    end
    -- potion,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
    -- actions+=/call_action_list,name=serenity,if=buff.serenity.up
    if Player:BuffP(S.Serenity) then
      local ShouldReturn = Serenity(); if ShouldReturn then return ShouldReturn; end
    end
    -- reverse_harm,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=2
    if S.ReverseHarm:IsReadyP() and ((Player:EnergyTimeToMaxPredicted() < 1 or (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)) and Player:ChiDeficit() >= 2) then
      return S.ReverseHarm:Cast()
    end
    -- actions+=/fist_of_the_white_tiger,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=3
    if S.FistOfTheWhiteTiger:IsReadyP() and ((Player:EnergyTimeToMaxPredicted() < 1 or (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)) and Player:ChiDeficit() >= 3) then
      return S.FistOfTheWhiteTiger:Cast()
    end
    -- actions+=/tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=2&!prev_gcd.1.tiger_palm
    if S.TigerPalm:IsReadyP() and ((Player:EnergyTimeToMaxPredicted() < 1 or (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)) and Player:ChiDeficit() >= 2 and not Player:PrevGCD(1, S.TigerPalm)) then
      return S.TigerPalm:Cast() 
    end
    -- actions.st=call_action_list,name=cd
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- actions+=/call_action_list,name=st,if=active_enemies<3
    if Cache.EnemiesCount[8] < 3 then
      local ShouldReturn = SingleTarget(); if ShouldReturn then return ShouldReturn; end
    end
    -- actions+=/call_action_list,name=aoe,if=active_enemies>=3
    if Cache.EnemiesCount[8] >= 3 then
      local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
    end
    --return S.PoolEnergy:Cast() end
  end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(269, APL)

local function PASSIVE()

    if S.DampenHarm:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[269].sk2 then
        return S.DampenHarm:Cast()
    end

    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(269, PASSIVE)