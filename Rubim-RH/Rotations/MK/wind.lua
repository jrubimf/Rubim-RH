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

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[269] = {
    ChiBurst = Spell(123986),
    ChiWave = Spell(115098),
	DanceOfChiji = Spell(286585),
	DanceOfChijiBuff = Spell(286587),
    EnergizingElixir = Spell(115288),
    TigerPalm = Spell(100780),
    RisingSunKick = Spell(107428),
    FistOfTheWhiteTiger = Spell(261947),
    ArcaneTorrent = Spell(50613),
    AncestralCall = Spell(274738),
    Fireblood = Spell(265221),
    LightsJudgment = Spell(255647),
    FistsOfFury = Spell(113656),
    Serenity = Spell(152173),
    WhirlingDragonPunch = Spell(152175),
    SpinningCraneKick = Spell(101546),
    BokProcBuff = Spell(116768),
    BlackoutKick = Spell(100784),
    CracklingJadeLightning = Spell(117952),
    TheEmperorsCapacitorBuff = Spell(235054),
    InvokeXuentheWhiteTiger = Spell(123904),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    TouchOfDeath = Spell(115080),
    StormEarthAndFire = Spell(137639),
    StormEarthAndFireBuff = Spell(137639),
    SerenityBuff = Spell(152173),
    RushingJadeWind = Spell(261715),
    RushingJadeWindBuff = Spell(261715),
    SpearHandStrike = Spell(116705),
    TouchofKarma = Spell(122470),
    GoodKarma = Spell(280195),
    DampemHarm = Spell(122278),
    SwiftRoundhouse = Spell(277669),
    SwiftRoundhouseBuff = Spell(277669),
    Disable = Spell(116095),
    GrappleWeapon = Spell(233759),
    FlyingSerpentKick = Spell(101545),
    FlyingSerpentKick2 = Spell(115057),
	HitCombo = Spell(196740),

};
local S = RubimRH.Spell[269];

S.FlyingSerpentKick.TextureSpellID = { 124176 } -- Raptor Strikes
-- Items
if not Item.Monk then
    Item.Monk = {}
end
Item.Monk.Windwalker = {
    DrinkingHornCover                = Item(137097, {9}),
    TheEmperorsCapacitor             = Item(144239, {5}),
    KatsuosEclipse                   = Item(137029, {8}),
};
local I = Item.Monk.Windwalker;


-- Variables

local EnemyRanges = { 5, 8 }
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

local OffensiveCDs = {
    S.StormEarthAndFire,
    S.InvokeXuentheWhiteTiger,
    S.Serenity,
    S.EnergizingElixir,
    S.TouchOfDeath
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

local BaseCost = {
    [S.BlackoutKick] = (Player:Level() < 12 and 3 or (Player:Level() < 22 and 2 or 1)),
    [S.RisingSunKick] = 2,
    [S.FistsOfFury] = ((I.KatsuosEclipse:IsEquipped() and Player:Level() < 116) and 2 or 3),
    [S.SpinningCraneKick] = 2
}


--- ======= ACTION LISTS =======
local function APL()
    local Precombat, Aoe, Cd, Serenity, St
    UpdateCDs()
    UpdateRanges()
    Precombat = function()
--actions.precombat=flask
--actions.precombat+=/food
--actions.precombat+=/augmentation
--# Snapshot raid buffed stats before combat begins and pre-potting is done.
--actions.precombat+=/snapshot_stats
--actions.precombat+=/potion
--actions.precombat+=/chi_burst,if=(!talent.serenity.enabled|!talent.fist_of_the_white_tiger.enabled)
--actions.precombat+=/chi_wave
return 0, 462338
    end
    Cd = function()
	if RubimRH.CDsON() then
--actions.cd=invoke_xuen_the_white_tiger
if S.InvokeXuentheWhiteTiger:IsReady() then
return S.InvokeXuentheWhiteTiger:Cast()
end
--actions.cd+=/use_item,name=lustrous_golden_plumage
--actions.cd+=/blood_fury
if S.BloodFury:IsReady() then
return S.BloodFury:Cast()
end
--actions.cd+=/berserking
if S.Berserking:IsReady() then
return S.Berserking:Cast()
end
--# Use Arcane Torrent if you are missing at least 1 Chi and won't cap energy within 0.5 seconds
--actions.cd+=/arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
if S.ArcaneTorrent:IsReady() and (Player:ChiDeficit() >= 1 and Player:EnergyTimeToMaxPredicted() >= .5) then
return S.ArcaneTorrent:Cast()
end
--actions.cd+=/lights_judgment
if S.LightsJudgment:IsReady() then
return S.LightsJudgment:Cast()
end
--actions.cd+=/fireblood
if S.Fireblood:IsReady() then
return S.Fireblood:Cast()
end
--actions.cd+=/ancestral_call
if S.AncestralCall:IsReady() then
return S.AncestralCall:Cast()
end
--actions.cd+=/touch_of_death,if=target.time_to_die>9
if S.TouchOfDeath:IsReadyP() and Target:TimeToDie() > 9 then
return S.TouchOfDeath:Cast()
end
--actions.cd+=/storm_earth_and_fire,if=cooldown.storm_earth_and_fire.charges=2|(cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=15
if S.StormEarthAndFire:IsReady() and (S.StormEarthAndFire:ChargesP() == 2 or (S.FistsOfFury:CooldownRemainsP() <= 6 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 15) then
return S.StormEarthAndFire:Cast()
end
--actions.cd+=/serenity,if=cooldown.rising_sun_kick.remains<=2|target.time_to_die<=12
if S.Serenity:IsReady() and (S.RisingSunKick:CooldownRemainsP() <= 2 or Target:TimeToDie() <= 12) then
return S.Serenity:Cast()
end
end
end

    -- Serenity --
    Serenity = function()
	--actions.precombat+=/chi_wave
	if S.ChiWave:IsReadyP() then
return S.ChiWave:Cast()
end
--actions.serenity=rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=active_enemies<3|prev_gcd.1.spinning_crane_kick
if S.RisingSunKick:IsReadyP() and (Cache.EnemiesCount[8] < 3 or Player:PrevGCD(1, S.SpinningCraneKick)) then
return S.RisingSunKick:Cast()
end
--actions.serenity+=/fists_of_fury,if=(buff.bloodlust.up&prev_gcd.1.rising_sun_kick&!azerite.swift_roundhouse.enabled)|buff.serenity.remains<1|(active_enemies>1&active_enemies<5)
if S.FistsOfFury:IsReadyP() and ((Player:HasHeroismP() and Player:PrevGCD(1, S.RisingSunKick) and not S.SwiftRoundhouse:AzeriteEnabled()) or Player:BuffRemainsP(S.SerenityBuff) < 1 or (Cache.EnemiesCount[8] > 1 and Cache.EnemiesCount[8] < 5)) then
return S.FistsOfFury:Cast()
end
--actions.serenity+=/spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&(active_enemies>=3|(active_enemies=2&prev_gcd.1.blackout_kick))
if S.SpinningCraneKick:IsReadyP() and (not Player:PrevGCD(1, S.SpinningCraneKick) and (Cache.EnemiesCount[8] >= 3 or (Cache.EnemiesCount[8] == 2 and Player:PrevGCD(1, S.BlackoutKick)))) then
return S.SpinningCraneKick:Cast()
end
--actions.serenity+=/blackout_kick,target_if=min:debuff.mark_of_the_crane.remains
if S.BlackoutKick:IsReadyP() then
return S.BlackoutKick:Cast()
end
    end

    St = function()
	--actions.precombat+=/chi_wave
	if S.ChiWave:IsReadyP() then
return S.ChiWave:Cast()
end
--actions.st+=/whirling_dragon_punch
if S.WhirlingDragonPunch:IsReady() then
return S.WhirlingDragonPunch:Cast()
end
--actions.st+=/rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=chi>=5
if S.RisingSunKick:IsReadyP() and (Player:Chi() >= 5) then
return S.RisingSunKick:Cast()
end
--actions.st+=/fists_of_fury,if=energy.time_to_max>3
if S.FistsOfFury:IsReadyP() and (Player:EnergyTimeToMaxPredicted() > 3) then
return S.FistsOfFury:Cast()
end
--actions.st+=/rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
if S.RisingSunKick:IsReadyP() then
return S.RisingSunKick:Cast()
end
--actions.st+=/spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&buff.dance_of_chiji.up
if S.SpinningCraneKick:IsReadyP() and (not Player:PrevGCD(1, S.SpinningCraneKick) and Player:BuffP(S.DanceOfChijiBuff)) then
return S.SpinningCraneKick:Cast()
end
--actions.st+=/rushing_jade_wind,if=buff.rushing_jade_wind.down&active_enemies>1
if S.RushingJadeWind:IsReadyP() and (Player:BuffDownP(S.RushingJadeWindBuff) and Cache.EnemiesCount[8] > 1) then
return S.RushingJadeWind:Cast()
end
--actions.st+=/fist_of_the_white_tiger,if=chi<=2
if S.FistOfTheWhiteTiger:IsReadyP() and (Player:Chi() <= 2) then
return S.FistOfTheWhiteTiger:Cast()
end
--actions.st+=/energizing_elixir,if=chi<=3&energy<50
if S.EnergizingElixir:IsReadyP() and (Player:Chi() <= 3 and Player:EnergyPredicted() < 50) then
return S.EnergizingElixir:Cast()
end
--actions.st+=/blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&(cooldown.rising_sun_kick.remains>3|chi>=3)&(cooldown.fists_of_fury.remains>4|chi>=4|(chi=2&prev_gcd.1.tiger_palm))&buff.swift_roundhouse.stack<2
--actions.st+=/blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&(cooldown.rising_sun_kick.remains>3|chi>=3)&(cooldown.fists_of_fury.remains>4|chi>=4|(chi=2&prev_gcd.1.tiger_palm))&buff.swift_roundhouse.stack<2
if S.BlackoutKick:IsReadyP() and (not Player:PrevGCD(1, S.BlackoutKick) and (S.RisingSunKick:CooldownRemainsP() > 3 or Player:Chi() >= 3) and (S.FistsOfFury:CooldownRemainsP() > 4 or Player:Chi() >= 4 or (Player:Chi() == 2 and Player:PrevGCD(1, S.TigerPalm)) and Player:BuffStackP(S.SwiftRoundhouseBuff) < 2)) then
return S.BlackoutKick:Cast()
end
--actions.st+=/chi_wave
if S.ChiWave:IsReadyP() then
return S.ChiWave:Cast()
end
--actions.st+=/chi_burst,if=chi.max-chi>=1&active_enemies=1|chi.max-chi>=2
if S.ChiBurst:IsReadyP() and (Player:ChiDeficit() >= 1 and Cache.EnemiesCount[8] == 1 or Player:ChiDeficit() >= 2) then
return S.ChiBurst:Cast()
end
--actions.st+=/tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&chi.max-chi>=2
if S.TigerPalm:IsReadyP() and (not Player:PrevGCD(1, S.TigerPalm)) then
return S.TigerPalm:Cast()
end
--actions.st+=/flying_serpent_kick,if=prev_gcd.1.blackout_kick&chi>3&buff.swift_roundhouse.stack<2,interrupt=1
    end

    Aoe = function()
	--actions.precombat+=/chi_wave
--actions.aoe+=/rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(talent.whirling_dragon_punch.enabled&cooldown.whirling_dragon_punch.remains<5)&cooldown.fists_of_fury.remains>3
--actions.aoe+=/rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(talent.whirling_dragon_punch.enabled&cooldown.whirling_dragon_punch.remains<5)&cooldown.fists_of_fury.remains>3
if S.RisingSunKick:IsReadyP() and ((S.WhirlingDragonPunch:IsAvailable() and S.WhirlingDragonPunch:CooldownRemainsP() < 5) and S.FistsOfFury:CooldownRemainsP() > 3) then
return S.RisingSunKick:Cast()
end
--actions.aoe=whirling_dragon_punch
if S.WhirlingDragonPunch:IsReady() then
return S.WhirlingDragonPunch:Cast()
end
--actions.aoe+=/energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&energy<50
if S.EnergizingElixir:IsReadyP() and (not Player:PrevGCD(1, S.TigerPalm) and Player:Chi() <= 1 and Player:EnergyPredicted() < 50) then
return S.EnergizingElixir:Cast()
end
--actions.aoe+=/fists_of_fury,if=energy.time_to_max>3
if S.FistsOfFury:IsReadyP() and (Player:EnergyTimeToMaxPredicted() > 3) then
return S.FistsOfFury:Cast()
end
--actions.aoe+=/rushing_jade_wind,if=buff.rushing_jade_wind.down
if S.RushingJadeWind:IsReadyP() and (Player:BuffDownP(S.RushingJadeWindBuff)) then
return S.RushingJadeWind:Cast()
end
--actions.aoe+=/spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&(((chi>3|cooldown.fists_of_fury.remains>6)&(chi>=5|cooldown.fists_of_fury.remains>2))|energy.time_to_max<=3)
--actions.aoe+=/spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&(((chi>3|cooldown.fists_of_fury.remains>6)&(chi>=5|cooldown.fists_of_fury.remains>2))|energy.time_to_max<=3)
if S.SpinningCraneKick:IsReadyP() and (not Player:PrevGCD(1, S.SpinningCraneKick) and (((Player:Chi() > 3 or S.FistsOfFury:CooldownRemainsP() > 6) and (Player:Chi() >= 5 or S.FistsOfFury:CooldownRemainsP() > 2)) or Player:EnergyTimeToMaxPredicted() <= 3)) then
return S.SpinningCraneKick:Cast()
end
--actions.aoe+=/chi_burst,if=chi<=3
if S.ChiBurst:IsReadyP() and (Player:Chi() <= 3) then
return S.ChiBurst:Cast()
end
--actions.aoe+=/fist_of_the_white_tiger,if=chi.max-chi>=3
if S.FistOfTheWhiteTiger:IsReadyP() and (Player:ChiDeficit() >= 3) then
return S.FistOfTheWhiteTiger:Cast()
end
--actions.aoe+=/tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=chi.max-chi>=2&(energy>56|buff.rushing_jade_wind.down)&(!talent.hit_combo.enabled|!prev_gcd.1.tiger_palm)
--actions.aoe+=/tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=chi.max-chi>=2&(!talent.hit_combo.enabled|!prev_gcd.1.tiger_palm)
if S.TigerPalm:IsReadyP() and (not Player:PrevGCD(1, S.TigerPalm)) then
return S.TigerPalm:Cast()
end
--actions.aoe+=/chi_wave
if S.ChiWave:IsReadyP() then
return S.ChiWave:Cast()
end
--actions.aoe+=/flying_serpent_kick,if=buff.bok_proc.down,interrupt=1
--actions.aoe+=/blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&(buff.bok_proc.up|(talent.hit_combo.enabled&prev_gcd.1.tiger_palm&chi<4))
if S.BlackoutKick:IsReadyP() and (not Player:PrevGCD(1, S.BlackoutKick) and (Player:BuffP(S.BokProcBuff) or (S.HitCombo:IsAvailable() and Player:PrevGCD(1, S.TigerPalm) and Player:Chi() < 4))) then
return S.BlackoutKick:Cast()
end
    end

    -- call precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
    -- auto_attack
    if Player:IsChanneling() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end

    -- spear_hand_strike,if=target.debuff.casting.react
    if S.SpearHandStrike:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() and (Target:IsCasting()) then
        return S.SpearHandStrike:Cast()
    end
--actions+=/rushing_jade_wind,if=talent.serenity.enabled&cooldown.serenity.remains<3&energy.time_to_max>1&buff.rushing_jade_wind.down
if S.RushingJadeWind:IsReadyP() and S.RushingJadeWind:IsAvailable() and (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <3 and Player:EnergyTimeToMaxPredicted() > 1 and Player:BuffDownP(S.RushingJadeWindBuff)) then
return S.RushingJadeWind:Cast()
end
    -- touch_of_karma,interval=90,pct_health=0.5,if=!talent.Good_Karma.enabled,interval=90,pct_health=0.5
    if S.TouchofKarma:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[269].sk1 then
        return S.TouchofKarma:Cast()
    end
--# Potion if Serenity or Storm, Earth, and Fire are up or you are running serenity and a main stat trinket procs, or you are under the effect of bloodlust, or target time to die is greater or equal to 60
--actions+=/potion,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
--actions+=/call_action_list,name=serenity,if=buff.serenity.up
    if Player:BuffP(S.Serenity) then
        if Serenity() ~= nil then
            return Serenity()
        end
    end
--actions+=/fist_of_the_white_tiger,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=3
if S.FistOfTheWhiteTiger:IsReadyP() and ((Player:EnergyTimeToMaxPredicted() < 1 or (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)) and Player:ChiDeficit() >= 3) then
return S.FistOfTheWhiteTiger:Cast()
end
--actions+=/tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=2&!prev_gcd.1.tiger_palm
if S.TigerPalm:IsReadyP() and ((Player:EnergyTimeToMaxPredicted() < 1 or (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)) and Player:ChiDeficit() >= 2 and not Player:PrevGCD(1, S.TigerPalm)) then
return S.TigerPalm:Cast()
end
--actions+=/call_action_list,name=cd
    if (true) then
        if Cd() ~= nil then
            return Cd();
        end
    end
--# Call the ST action list if there are 2 or less enemies
--actions+=/call_action_list,name=st,if=active_enemies<3
    if active_enemies() < 3 then
        if St() ~= nil then
            return St()
        end
    end
--# Call the AoE action list if there are 3 or more enemies
--actions+=/call_action_list,name=aoe,if=active_enemies>=3
    if active_enemies() >= 3 then
        if Aoe() ~= nil then
            return Aoe()
        end
    end


    return 0, 135328
end

RubimRH.Rotation.SetAPL(269, APL)

local function PASSIVE()

    if S.DampemHarm:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[269].sk2 then
        return S.DampemHarm:Cast()
    end

    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(269, PASSIVE)
