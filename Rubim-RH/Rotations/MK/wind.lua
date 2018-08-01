
local addonName, addonTable = ...;
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

local S = RubimRH.Spell[269]

if not Item.Monk then Item.Monk = {}; end
Item.Monk.Windwalker = {
DrinkingHornCover                = Item(137097, {9}),
TheEmperorsCapacitor             = Item(144239, {5}),
KatsuosEclipse                   = Item(137029, {8}),
HiddenMastersForbiddenTouch      = Item(137057, {10}),
}
local I = Item.Monk.Windwalker

local BaseCost = {
[S.BlackoutKick] = (Player:Level() < 12 and 3 or (Player:Level() < 22 and 2 or 1)),
[S.RisingSunKick] = 2,
[S.FistsOfFury] = (I.KatsuosEclipse:IsEquipped() and 2 or 3),
[S.SpinningCraneKick] = 3,
[S.RushingJadeWind] = 1
}

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

local function cd()
	if S.InvokeXuentheWhiteTiger:IsReady() and RubimRH.CDsON() then
		return S.InvokeXuentheWhiteTiger:Cast()
	end
    -- blood_fury
    if S.BloodFury:IsReady() and RubimRH.CDsON() then
    	return S.BloodFury:Cast()
    end
    -- berserking
    if S.Berserking:IsReady() and RubimRH.CDsON() then
    	return S.Berserking:Cast()
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and Player:EnergyTimeToMaxPredicted() >= 0.5) then
    	return S.ArcaneTorrent:Cast()
    end
    -- lights_judgment
    if S.LightsJudgment:IsReady() and RubimRH.CDsON() then
    	return S.LightsJudgment:Cast()
    end
    -- touch_of_death,target_if=min:dot.touch_of_death.remains,if=equipped.hidden_masters_forbidden_touch&!prev_gcd.1.touch_of_death
    if S.TouchOfDeath:IsReady() and RubimRH.CDsON() and (I.HiddenMastersForbiddenTouch:IsEquipped() and not Player:PrevGCD(1, S.TouchOfDeath)) then
    	return S.TouchOfDeath:Cast()
    end
    -- touch_of_death,target_if=min:dot.touch_of_death.remains,if=((talent.serenity.enabled&cooldown.serenity.remains<=1)&cooldown.fists_of_fury.remains<=4)&cooldown.rising_sun_kick.remains<7&!prev_gcd.1.touch_of_death
    if S.TouchOfDeath:IsReady() and RubimRH.CDsON() and (((S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <= 1) and S.FistsOfFury:CooldownRemainsP() <= 4) and S.RisingSunKick:CooldownRemainsP() < 7 and not Player:PrevGCD(1, S.TouchOfDeath)) then
    	return S.TouchOfDeath:Cast()
    end
    -- touch_of_death,target_if=min:dot.touch_of_death.remains,if=((!talent.serenity.enabled&cooldown.storm_earth_and_fire.remains<=1)|chi>=2)&cooldown.fists_of_fury.remains<=4&cooldown.rising_sun_kick.remains<7&!prev_gcd.1.touch_of_death
    if S.TouchOfDeath:IsReady() and RubimRH.CDsON() and (((not S.Serenity:IsAvailable() and S.StormEarthAndFire:CooldownRemainsP() <= 1) or Player:Chi() >= 2) and S.FistsOfFury:CooldownRemainsP() <= 4 and S.RisingSunKick:CooldownRemainsP() < 7 and not Player:PrevGCD(1, S.TouchOfDeath)) then
    	return S.TouchOfDeath:Cast()
    end
end

local function aoe()
	-- call_action_list,name=cd
	if cd() ~= nil then
		return cd()
	end
    -- energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&(cooldown.rising_sun_kick.remains=0|(talent.fist_of_the_white_tiger.enabled&cooldown.fist_of_the_white_tiger.remains=0)|energy<50)
    if S.EnergizingElixir:IsReady() and RubimRH.CDsON() and (not Player:PrevGCD(1, S.TigerPalm) and Player:Chi() <= 1 and (S.RisingSunKick:CooldownRemainsP() == 0 or (S.FistOfTheWhiteTiger:IsAvailable() and S.FistOfTheWhiteTiger:CooldownRemainsP() == 0) or Player:Energy() < 50)) then
    	return S.EnergizingElixir:Cast()
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and Player:EnergyTimeToMaxPredicted() >= 0.5) then
    	return S.ArcaneTorrent:Cast()
    end
    -- fists_of_fury,if=talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.serenity.remains>=5&energy.time_to_max>2
    if S.FistsOfFury:IsReady() and (S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and S.Serenity:CooldownRemainsP() >= 5 and Player:EnergyTimeToMaxPredicted() > 2) then
    	return S.FistsOfFury:Cast()
    end
    -- fists_of_fury,if=talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.serenity.remains>=15|cooldown.serenity.remains<=4)&energy.time_to_max>2
    if S.FistsOfFury:IsReady() and (S.Serenity:IsAvailable() and I.DrinkingHornCover:IsEquipped() and (S.Serenity:CooldownRemainsP() >= 15 or S.Serenity:CooldownRemainsP() <= 4) and Player:EnergyTimeToMaxPredicted() > 2) then
    	return S.FistsOfFury:Cast()
    end
    -- fists_of_fury,if=!talent.serenity.enabled&energy.time_to_max>2
    if S.FistsOfFury:IsReady() and (not S.Serenity:IsAvailable() and Player:EnergyTimeToMaxPredicted() > 2) then
    	return S.FistsOfFury:Cast()
    end
    -- fists_of_fury,if=cooldown.rising_sun_kick.remains>=3.5&chi<=5
    if S.FistsOfFury:IsReady() and (S.RisingSunKick:CooldownRemainsP() >= 3.5 and Player:Chi() <= 5) then
    	return S.FistsOfFury:Cast()
    end
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsReady() and (true) then
    	return S.WhirlingDragonPunch:Cast()
    end
    -- rising_sun_kick,target_if=cooldown.whirling_dragon_punch.remains>=gcd&!prev_gcd.1.rising_sun_kick&cooldown.fists_of_fury.remains>gcd
    if S.RisingSunKick:IsReady() and (true) then
    	return S.RisingSunKick:Cast()
    end
    -- chi_burst,if=chi<=3&(cooldown.rising_sun_kick.remains>=5|cooldown.whirling_dragon_punch.remains>=5)&energy.time_to_max>1
    if S.ChiBurst:IsReady() and (Player:Chi() <= 3 and (S.RisingSunKick:CooldownRemainsP() >= 5 or S.WhirlingDragonPunch:CooldownRemainsP() >= 5) and Player:EnergyTimeToMaxPredicted() > 1) then
    	return S.ChiBurst:Cast()
    end
    -- chi_burst
    if S.ChiBurst:IsReady() and (true) then
    	return S.ChiBurst:Cast()
    end
    -- spinning_crane_kick,if=(active_enemies>=3|(buff.bok_proc.up&chi.max-chi>=0))&!prev_gcd.1.spinning_crane_kick&set_bonus.tier21_4pc
    if S.SpinningCraneKick:IsReady() and ((Cache.EnemiesCount[8] >= 3 or (Player:BuffP(S.BlackoutKickBuff) and Player:ChiMax() - Player:Chi() >= 0)) and not Player:PrevGCD(1, S.SpinningCraneKick) and HL.Tier21_4Pc) then
    	return S.SpinningCraneKick:Cast()
    end
    -- spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
    if S.SpinningCraneKick:IsReady() and (Cache.EnemiesCount[8] >= 3 and not Player:PrevGCD(1, S.SpinningCraneKick)) then
    	return S.SpinningCraneKick:Cast()
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&(!set_bonus.tier19_2pc|talent.serenity.enabled)
    if S.BlackoutKick:IsReady() and (not Player:PrevGCD(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1 and HL.Tier21_4Pc and (not HL.Tier19_2Pc or S.Serenity:IsAvailable())) then
    	return S.BlackoutKick:Cast()
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(chi>1|buff.bok_proc.up|(talent.energizing_elixir.enabled&cooldown.energizing_elixir.remains<cooldown.fists_of_fury.remains))&((cooldown.rising_sun_kick.remains>1&(!talent.fist_of_the_white_tiger.enabled|cooldown.fist_of_the_white_tiger.remains>1)|chi>4)&(cooldown.fists_of_fury.remains>1|chi>2)|prev_gcd.1.tiger_palm)&!prev_gcd.1.blackout_kick
    if S.BlackoutKick:IsReady() and ((Player:Chi() > 1 or Player:BuffP(S.BlackoutKickBuff) or (S.EnergizingElixir:IsAvailable() and S.EnergizingElixir:CooldownRemainsP() < S.FistsOfFury:CooldownRemainsP())) and ((S.RisingSunKick:CooldownRemainsP() > 1 and (not S.FistOfTheWhiteTiger:IsAvailable() or S.FistOfTheWhiteTiger:CooldownRemainsP() > 1) or Player:Chi() > 4) and (S.FistsOfFury:CooldownRemainsP() > 1 or Player:Chi() > 2) or Player:PrevGCD(1, S.TigerPalm)) and not Player:PrevGCD(1, S.BlackoutKick)) then
    	return S.BlackoutKick:Cast()
    end
    -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
    if S.CracklingJadeLightning:IsReady() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitor) >= 19 and Player:EnergyTimeToMaxPredicted() > 3) then
    	return S.CracklingJadeLightning:Cast()
    end
    -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
    if S.CracklingJadeLightning:IsReady() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitor) >= 14 and S.Serenity:CooldownRemainsP() < 13 and S.Serenity:IsAvailable() and Player:EnergyTimeToMaxPredicted() > 3) then
    	return S.CracklingJadeLightning:Cast()
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&buff.bok_proc.up
    if S.BlackoutKick:IsReady() and (not Player:PrevGCD(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1 and HL.Tier21_4Pc and Player:BuffP(S.BlackoutKickBuff)) then
    	return S.BlackoutKick:Cast()
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&(chi.max-chi>=2|energy.time_to_max<3)
    if S.TigerPalm:IsReady() and (not Player:PrevGCD(1, S.TigerPalm) and not Player:PrevGCD(1, S.EnergizingElixir) and (Player:ChiMax() - Player:Chi() >= 2 or Player:EnergyTimeToMaxPredicted() < 3)) then
    	return S.TigerPalm:Cast()
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy.time_to_max<=1&chi.max-chi>=2
    if S.TigerPalm:IsReady() and (not Player:PrevGCD(1, S.TigerPalm) and not Player:PrevGCD(1, S.EnergizingElixir) and Player:EnergyTimeToMaxPredicted() <= 1 and Player:ChiMax() - Player:Chi() >= 2) then
    	return S.TigerPalm:Cast()
    end
    -- chi_wave,if=chi<=3&(cooldown.rising_sun_kick.remains>=5|cooldown.whirling_dragon_punch.remains>=5)&energy.time_to_max>1
    if S.ChiWave:IsReady() and (Player:Chi() <= 3 and (S.RisingSunKick:CooldownRemainsP() >= 5 or S.WhirlingDragonPunch:CooldownRemainsP() >= 5) and Player:EnergyTimeToMaxPredicted() > 1) then
    	return S.ChiWave:Cast()
    end
    -- chi_wave
    if S.ChiWave:IsReady() and (true) then
    	return S.ChiWave:Cast()
    end
end

local function st()
    -- invoke_xuen_the_white_tiger
    if S.InvokeXuentheWhiteTiger:IsReady() and RubimRH.CDsON() then
    	return S.InvokeXuentheWhiteTiger:Cast()
    end
    -- storm_earth_and_fire,if=!buff.storm_earth_and_fire.up
    if S.StormEarthAndFire:IsReady() and RubimRH.CDsON() and (not Player:BuffP(S.StormEarthAndFire)) then
    	return S.StormEarthAndFire:Cast()
    end
    -- rushing_jade_wind,if=buff.rushing_jade_wind.down&!prev_gcd.1.rushing_jade_wind
    if S.RushingJadeWind:IsReady() and (Player:BuffDownP(S.RushingJadeWind) and not Player:PrevGCD(1, S.RushingJadeWind)) then
    	return S.RushingJadeWind:Cast()
    end
    -- energizing_elixir,if=!prev_gcd.1.tiger_palm
    if S.EnergizingElixir:IsReady() and RubimRH.CDsON() and (not Player:PrevGCD(1, S.TigerPalm)) then
    	return S.EnergizingElixir:Cast()
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&buff.bok_proc.up
    if S.BlackoutKick:IsReady() and (not Player:PrevGCD(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1 and HL.Tier21_4Pc and Player:BuffP(S.BlackoutKickBuff)) then
    	return S.BlackoutKick:Cast()
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy.time_to_max<=1&chi.max-chi>=2&!buff.serenity.up
    if S.TigerPalm:IsReady() and (not Player:PrevGCD(1, S.TigerPalm) and not Player:PrevGCD(1, S.EnergizingElixir) and Player:EnergyTimeToMaxPredicted() <= 1 and Player:ChiMax() - Player:Chi() >= 2 and not Player:BuffP(S.Serenity)) then
    	return S.TigerPalm:Cast()
    end
    -- fist_of_the_white_tiger,if=chi.max-chi>=3
    if S.FistOfTheWhiteTiger:IsReady() and (Player:ChiMax() - Player:Chi() >= 3) then
    	return S.FistOfTheWhiteTiger:Cast()
    end
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsReady() then
    	return S.WhirlingDragonPunch:Cast()
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=((chi>=3&energy>=40)|chi>=5)&(talent.serenity.enabled|cooldown.serenity.remains>=6)
    if S.RisingSunKick:IsReady() and (((Player:Chi() >= 3 and Player:Energy() >= 40) or Player:Chi() >= 5) and (S.Serenity:IsAvailable() or S.Serenity:CooldownRemainsP() >= 6)) then
    	return S.RisingSunKick:Cast()
    end
    -- fists_of_fury,if=talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.serenity.remains>=5&energy.time_to_max>2
    if S.FistsOfFury:IsReady() and (S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and S.Serenity:CooldownRemainsP() >= 5 and Player:EnergyTimeToMaxPredicted() > 2) then
    	return S.FistsOfFury:Cast()
    end
    -- fists_of_fury,if=talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.serenity.remains>=15|cooldown.serenity.remains<=4)&energy.time_to_max>2
    if S.FistsOfFury:IsReady() and (S.Serenity:IsAvailable() and I.DrinkingHornCover:IsEquipped() and (S.Serenity:CooldownRemainsP() >= 15 or S.Serenity:CooldownRemainsP() <= 4) and Player:EnergyTimeToMaxPredicted() > 2) then
    	return S.FistsOfFury:Cast()
    end
    -- fists_of_fury,if=!talent.serenity.enabled
    if S.FistsOfFury:IsReady() and (not S.Serenity:IsAvailable()) then
    	return S.FistsOfFury:Cast()
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=cooldown.serenity.remains>=5|(!talent.serenity.enabled)
    if S.RisingSunKick:IsReady() and (S.Serenity:CooldownRemainsP() >= 5 or (not S.Serenity:IsAvailable())) then
    	return S.RisingSunKick:Cast()
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1
    if S.BlackoutKick:IsReady() and (not Player:PrevGCD(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1) then
    	return S.BlackoutKick:Cast()
    end
    -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
    if S.CracklingJadeLightning:IsReady() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitor) >= 19 and Player:EnergyTimeToMaxPredicted() > 3) then
    	return S.CracklingJadeLightning:Cast()
    end
    -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
    if S.CracklingJadeLightning:IsReady() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitor) >= 14 and S.Serenity:CooldownRemainsP() < 13 and S.Serenity:IsAvailable() and Player:EnergyTimeToMaxPredicted() > 3) then
    	return S.CracklingJadeLightning:Cast()
    end
    -- blackout_kick
    if S.BlackoutKick:IsReady() then
    	return S.BlackoutKick:Cast()
    end
    -- chi_wave
    if S.ChiWave:IsReady() then
    	return S.ChiWave:Cast()
    end
    -- chi_burst,if=energy.time_to_max>1&talent.serenity.enabled
    if S.ChiBurst:IsReady() and (Player:EnergyTimeToMaxPredicted() > 1 and S.Serenity:IsAvailable()) then
    	return S.ChiBurst:Cast()
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&(chi.max-chi>=2|energy.time_to_max<3)&!buff.serenity.up
    if S.TigerPalm:IsReady() and (not Player:PrevGCD(1, S.TigerPalm) and not Player:PrevGCD(1, S.EnergizingElixir) and (Player:ChiMax() - Player:Chi() >= 2 or Player:EnergyTimeToMaxPredicted() < 3) and not Player:BuffP(S.Serenity)) then
    	return S.TigerPalm:Cast()
    end
    -- chi_burst,if=chi.max-chi>=3&energy.time_to_max>1&!talent.serenity.enabled
    if S.ChiBurst:IsReady() and (Player:ChiMax() - Player:Chi() >= 3 and Player:EnergyTimeToMaxPredicted() > 1 and not S.Serenity:IsAvailable()) then
    	return S.ChiBurst:Cast()
    end
end

local function sef()
  	-- tiger_palm,target_if=debuff.mark_of_the_crane.down,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy=energy.max&chi<1
  	if S.TigerPalm:IsReady() and (not Player:PrevGCD(1, S.TigerPalm) and not Player:PrevGCD(1, S.EnergizingElixir) and Player:Energy() == Player:EnergyMax() and Player:Chi() < 1) then
  		return S.TigerPalm:Cast()
  	end
    -- call_action_list,name=cd
    if cd() ~= nil then
    	return cd()
    end
    -- storm_earth_and_fire,if=!buff.storm_earth_and_fire.up
    if S.StormEarthAndFire:IsReady() and RubimRH.CDsON() and (not Player:BuffP(S.StormEarthAndFire)) then
    	return S.StormEarthAndFire:Cast()
    end
    -- call_action_list,name=aoe,if=active_enemies>3
    if aoe() ~= nil and  RubimRH.AoEON() and (Cache.EnemiesCount[8] > 3) then
    	return aoe()
    end
    -- call_action_list,name=st,if=active_enemies<=3
    if st() ~= nil and (Cache.EnemiesCount[8] <= 3) then
    	return st()
    end
end

local function serenity()
	if S.FistOfTheWhiteTiger:IsReady() and (Player:HasHeroism() and not Player:BuffP(S.Serenity)) then
		return S.FistOfTheWhiteTiger:Cast()
	end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy=energy.max&chi<1&!buff.serenity.up
    if S.TigerPalm:IsReady() and (not Player:PrevGCD(1, S.TigerPalm) and not Player:PrevGCD(1, S.EnergizingElixir) and Player:Energy() == Player:EnergyMax() and Player:Chi() < 1 and not Player:BuffP(S.Serenity)) then
    	return S.TigerPalm:Cast()
    end
    -- call_action_list,name=cd
    if cd() ~= nil then
    	return cd()
    end
    -- rushing_jade_wind,if=talent.rushing_jade_wind.enabled&!prev_gcd.1.rushing_jade_wind&buff.rushing_jade_wind.down
    if S.RushingJadeWind:IsReady() and (S.RushingJadeWind:IsAvailable() and not Player:PrevGCD(1, S.RushingJadeWind) and Player:BuffDownP(S.RushingJadeWind)) then
    	return S.RushingJadeWind:Cast()
    end
    -- serenity
    if S.Serenity:IsReady() and RubimRH.CDsON() then
    	return S.Serenity:Cast()
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
    if S.RisingSunKick:IsReady() then
    	return S.RisingSunKick:Cast()
    end
    -- fists_of_fury,if=prev_gcd.1.rising_sun_kick&prev_gcd.2.serenity
    if S.FistsOfFury:IsReady() and (Player:PrevGCD(1, S.RisingSunKick) and Player:PrevGCD(2, S.Serenity)) then
    	return S.FistsOfFury:Cast()
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
    if S.RisingSunKick:IsReady() then
    	return S.RisingSunKick:Cast()
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&cooldown.rising_sun_kick.remains>=2&cooldown.fists_of_fury.remains>=2
    if S.BlackoutKick:IsReady() and (not Player:PrevGCD(1, S.BlackoutKick) and S.RisingSunKick:CooldownRemainsP() >= 2 and S.FistsOfFury:CooldownRemainsP() >= 2) then
    	return S.BlackoutKick:Cast()
    end
    -- fists_of_fury,if=((!equipped.drinking_horn_cover|buff.bloodlust.up|buff.serenity.remains<1)&(cooldown.rising_sun_kick.remains>1|active_enemies>1)),interrupt=1
    if S.FistsOfFury:IsReady() and (((not I.DrinkingHornCover:IsEquipped() or Player:HasHeroism() or Player:BuffRemainsP(S.Serenity) < 1) and (S.RisingSunKick:CooldownRemainsP() > 1 or Cache.EnemiesCount[8] > 1))) then
    	return S.FistsOfFury:Cast()
    end
    -- spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
    if S.SpinningCraneKick:IsReady() and (Cache.EnemiesCount[8] >= 3 and not Player:PrevGCD(1, S.SpinningCraneKick)) then
    	return S.SpinningCraneKick:Cast()
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=active_enemies>=3
    if S.RisingSunKick:IsReady() and (Cache.EnemiesCount[8] >= 3) then
    	return S.RisingSunKick:Cast()
    end
    -- spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick
    if S.SpinningCraneKick:IsReady() and (not Player:PrevGCD(1, S.SpinningCraneKick)) then
    	return S.SpinningCraneKick:Cast()
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick
    if S.BlackoutKick:IsReady() and (not Player:PrevGCD(1, S.BlackoutKick)) then
    	return S.BlackoutKick:Cast()
    end
end

local function APL()
	if not Player:AffectingCombat() then
		return 0, 462338
	end
	HL.GetEnemies("Melee");
	HL.GetEnemies(8,true);
	HL.GetEnemies(10,true); 
	HL.GetEnemies(30,true);

	if Player:IsChanneling(S.SpinningCraneKick) or Player:IsChanneling(S.FistsOfFury) then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end

	--actions.precombat=flask
	--actions.precombat+=/food
	--actions.precombat+=/augmentation
	--actions.precombat+=/snapshot_stats
	--actions.precombat+=/potion
	--actions.precombat+=/chi_burst
	--actions.precombat+=/chi_wave

	--actions=auto_attack
	--actions+=/spear_hand_strike,if=target.debuff.casting.react
	--actions+=/touch_of_karma,interval=90,pct_health=0.5,if=!talent.Good_Karma.enabled,interval=90,pct_health=0.5
	--actions+=/touch_of_karma,interval=90,pct_health=1.0
	--actions+=/potion,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
	--actions+=/touch_of_death,if=target.time_to_die<=9
	if S.TouchOfDeath:IsReady() and Target:TimeToDie() <= 9 then
		S.TouchOfDeath:Cast()
	end

	--actions+=/call_action_list,name=serenity,if=(talent.serenity.enabled&cooldown.serenity.remains<=0)|buff.serenity.up
	if serenity() ~= nil and ((S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <= 0) or Player:BuffP(S.Serenity)) then
		return serenity()
	end

	--actions+=/call_action_list,name=sef,if=!talent.serenity.enabled&(buff.storm_earth_and_fire.up|cooldown.storm_earth_and_fire.charges=2)
	if sef() ~= nil and ((not S.Serenity:IsAvailable() and S.FistsOfFury:CooldownRemainsP() <= 12 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 25 or S.TouchOfDeath:CooldownRemainsP() > 112) then
		return sef()
	end

	--actions+=/call_action_list,name=sef,if=(!talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=15|cooldown.touch_of_death.remains>112&cooldown.storm_earth_and_fire.charges=1
	if sef() ~= nil and ((not S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and S.FistsOfFury:CooldownRemainsP() <= 6 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 15 or S.TouchOfDeath:CooldownRemainsP() > 112 and S.StormEarthAndFire:ChargesP() == 1) then
		return sef()
	end

	--actions+=/call_action_list,name=sef,if=(!talent.serenity.enabled&cooldown.fists_of_fury.remains<=12&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=25|cooldown.touch_of_death.remains>112&cooldown.storm_earth_and_fire.charges=1
	if sef() ~= nil and ((not S.Serenity:IsAvailable() and S.FistsOfFury:CooldownRemainsP() <= 12 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 25 or S.TouchOfDeath:CooldownRemainsP() > 112 and S.StormEarthAndFire:ChargesP() == 1) then
		return sef()
	end

	--actions+=/call_action_list,name=aoe,if=active_enemies>3
	if aoe() ~= nil and RubimRH.AoEON() and (Cache.EnemiesCount[8] > 3) then
		return aoe()
	end

	--actions+=/call_action_list,name=st,if=active_enemies<=3
	if st() ~= nil and (Cache.EnemiesCount[8] <= 3) then
		return st()
	end

	return 0, 135328
end

RubimRH.Rotation.SetAPL(269, APL);

local function PASSIVE()
	return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(269, PASSIVE);

