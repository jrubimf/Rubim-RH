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
    EnergizingElixir = Spell(115288),
    TigerPalm = Spell(100780),
    RisingSunKick = Spell(107428),
    FistoftheWhiteTiger = Spell(261947),
    ArcaneTorrent = Spell(50613),
    AncestralCall = Spell(274738),
    Fireblood = Spell(265221),
    LightsJudgment = Spell(255647),
    FistsofFury = Spell(113656),
    Serenity = Spell(152173),
    WhirlingDragonPunch = Spell(152175),
    SpinningCraneKick = Spell(107270),
    BokProcBuff = Spell(116768),
    BlackoutKick = Spell(100784),
    CracklingJadeLightning = Spell(117952),
    TheEmperorsCapacitorBuff = Spell(235054),
    InvokeXuentheWhiteTiger = Spell(123904),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    LightsJudgment = Spell(255647),
    TouchofDeath = Spell(115080),
    StormEarthandFire = Spell(137639),
    StormEarthandFireBuff = Spell(137639),
    SerenityBuff = Spell(152173),
    RushingJadeWind = Spell(261715),
    RushingJadeWindBuff = Spell(261715),
    SpearHandStrike = Spell(116705),
    TouchofKarma = Spell(122470),
    GoodKarma = Spell(280195),
    DampemHarm = Spell(122278),
    SwiftRoundhouse = Spell(277669),
    SwiftRoundhouseBuff = Spell(277669),

};
local S = RubimRH.Spell[269];

-- Items
if not Item.Monk then
    Item.Monk = {}
end
Item.Monk.Windwalker = {
    ProlongedPower = Item(142117),
    DrinkingHornCover = Item(137097),
    TheEmperorsCapacitor = Item(144239),
    LustrousGoldenPlumage = Item(159617),
    HiddenMastersForbiddenTouch = Item(137057)
};
local I = Item.Monk.Windwalker;


-- Variables

local EnemyRanges = { 8 }
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
    S.StormEarthandFire,
    S.InvokeXuentheWhiteTiger,
    S.Serenity,
    S.EnergizingElixir,
    S.TouchofDeath,
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

--- ======= ACTION LISTS =======
local function APL()
    local Precombat, Aoe, Cd, Sef, Serenity, Serenitysr, SerenityOpener, SerenityOpenersr, St
    UpdateCDs()
    UpdateRanges()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- potion
        if I.ProlongedPower:IsReady() and RubimRH.PotionON() and (true) then
            return I.ProlongedPower:Cast()
        end
        -- chi_burst
        --        if S.ChiBurst:IsReady() and (true) then
        --            return S.ChiBurst:Cast()
        --      end
        -- chi_wave
        --        if S.ChiWave:IsReady() and (true) then
        --            return S.ChiWave:Cast()
        --end
    end
    Aoe = function()
        -- call_action_list,name=cd
        if (true) then
            if Cd() ~= nil then
                return Cd()
            end
        end
        -- energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&(cooldown.rising_sun_kick.remains=0|(talent.fist_of_the_white_tiger.enabled&cooldown.fist_of_the_white_tiger.remains=0)|energy<50)
        if S.EnergizingElixir:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:Chi() <= 1 and (S.RisingSunKick:CooldownRemainsP() == 0 or (S.FistoftheWhiteTiger:IsAvailable() and S.FistoftheWhiteTiger:CooldownRemainsP() == 0) or Player:EnergyPredicted() < 50)) then
            return S.EnergizingElixir:Cast()
        end
        -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
        if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and Player:EnergyTimeToMaxPredicted() >= 0.5) then
            return S.ArcaneTorrent:Cast()
        end
        -- fists_of_fury,if=talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.serenity.remains>=5&energy.time_to_max>2
        if S.FistsofFury:IsReady() and (S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and S.Serenity:CooldownRemainsP() >= 5 and Player:EnergyTimeToMaxPredicted() > 2) then
            return S.FistsofFury:Cast()
        end
        -- fists_of_fury,if=talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.serenity.remains>=15|cooldown.serenity.remains<=4)&energy.time_to_max>2
        if S.FistsofFury:IsReady() and (S.Serenity:IsAvailable() and I.DrinkingHornCover:IsEquipped() and (S.Serenity:CooldownRemainsP() >= 15 or S.Serenity:CooldownRemainsP() <= 4) and Player:EnergyTimeToMaxPredicted() > 2) then
            return S.FistsofFury:Cast()
        end
        -- fists_of_fury,if=!talent.serenity.enabled&energy.time_to_max>2
        if S.FistsofFury:IsReady() and (not S.Serenity:IsAvailable() and Player:EnergyTimeToMaxPredicted() > 2) then
            return S.FistsofFury:Cast()
        end
        -- fists_of_fury,if=cooldown.rising_sun_kick.remains>=3.5&chi<=5
        if S.FistsofFury:IsReady() and (S.RisingSunKick:CooldownRemainsP() >= 3.5 and Player:Chi() <= 5) then
            return S.FistsofFury:Cast()
        end
        -- whirling_dragon_punch
        if S.WhirlingDragonPunch:IsReady() and Cache.EnemiesCount[5] >= 1 then
            return S.WhirlingDragonPunch:Cast()
        end
        -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(talent.whirling_dragon_punch.enabled&cooldown.whirling_dragon_punch.remains<gcd)&!prev_gcd.1.rising_sun_kick&cooldown.fists_of_fury.remains>gcd
        if S.RisingSunKick:IsReady() and ((S.WhirlingDragonPunch:IsAvailable() and S.WhirlingDragonPunch:CooldownRemainsP() < Player:GCD()) and not Player:PrevGCDP(1, S.RisingSunKick) and S.FistsofFury:CooldownRemainsP() > Player:GCD()) then
            return S.RisingSunKick:Cast()
        end
        -- chi_burst,if=chi<=3&(cooldown.rising_sun_kick.remains>=5|cooldown.whirling_dragon_punch.remains>=5)&energy.time_to_max>1
        if S.ChiBurst:IsReady() and (Player:Chi() <= 3 and (S.RisingSunKick:CooldownRemainsP() >= 5 or S.WhirlingDragonPunch:CooldownRemainsP() >= 5) and Player:EnergyTimeToMaxPredicted() > 1) then
            return S.ChiBurst:Cast()
        end
        -- chi_burst
        if S.ChiBurst:IsReady() then
            return S.ChiBurst:Cast()
        end
        -- spinning_crane_kick,if=(active_enemies>=3|(buff.bok_proc.up&chi.max-chi>=0))&!prev_gcd.1.spinning_crane_kick&set_bonus.tier21_4pc
        if S.SpinningCraneKick:IsReady() and ((Cache.EnemiesCount[8] >= 3 or (Player:BuffP(S.BokProcBuff) and Player:ChiMax() - Player:Chi() >= 0)) and not Player:PrevGCDP(1, S.SpinningCraneKick) and HL.Tier21_4Pc) then
            return S.SpinningCraneKick:Cast()
        end
        -- spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick&cooldown.fists_of_fury.remains>gcd
        if S.SpinningCraneKick:IsReady() and (Cache.EnemiesCount[8] >= 3 and not Player:PrevGCDP(1, S.SpinningCraneKick) and S.FistsofFury:CooldownRemainsP() > Player:GCD()) then
            return S.SpinningCraneKick:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&(!set_bonus.tier19_2pc|talent.serenity.enabled)
        if S.BlackoutKick:IsReady() and (not Player:PrevGCDP(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1 and HL.Tier21_4Pc and (not HL.Tier19_2Pc or S.Serenity:IsAvailable())) then
            return S.BlackoutKick:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(chi>1|buff.bok_proc.up|(talent.energizing_elixir.enabled&cooldown.energizing_elixir.remains<cooldown.fists_of_fury.remains))&((cooldown.rising_sun_kick.remains>1&(!talent.fist_of_the_white_tiger.enabled|cooldown.fist_of_the_white_tiger.remains>1)|chi>4)&(cooldown.fists_of_fury.remains>1|chi>2)|prev_gcd.1.tiger_palm)&!prev_gcd.1.blackout_kick
        if S.BlackoutKick:IsReady() and ((Player:Chi() > 1 or Player:BuffP(S.BokProcBuff) or (S.EnergizingElixir:IsAvailable() and S.EnergizingElixir:CooldownRemainsP() < S.FistsofFury:CooldownRemainsP())) and ((S.RisingSunKick:CooldownRemainsP() > 1 and (not S.FistoftheWhiteTiger:IsAvailable() or S.FistoftheWhiteTiger:CooldownRemainsP() > 1) or Player:Chi() > 4) and (S.FistsofFury:CooldownRemainsP() > 1 or Player:Chi() > 2) or Player:PrevGCDP(1, S.TigerPalm)) and not Player:PrevGCDP(1, S.BlackoutKick)) then
            return S.BlackoutKick:Cast()
        end
        -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
        if S.CracklingJadeLightning:IsReady() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitorBuff) >= 19 and Player:EnergyTimeToMaxPredicted() > 3) then
            return S.CracklingJadeLightning:Cast()
        end
        -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
        if S.CracklingJadeLightning:IsReady() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitorBuff) >= 14 and S.Serenity:CooldownRemainsP() < 13 and S.Serenity:IsAvailable() and Player:EnergyTimeToMaxPredicted() > 3) then
            return S.CracklingJadeLightning:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&buff.bok_proc.up
        if S.BlackoutKick:IsReady() and (not Player:PrevGCDP(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1 and HL.Tier21_4Pc and Player:BuffP(S.BokProcBuff)) then
            return S.BlackoutKick:Cast()
        end
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&(chi.max-chi>=2|energy.time_to_max<3)
        if S.TigerPalm:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and (Player:ChiMax() - Player:Chi() >= 2 or Player:EnergyTimeToMaxPredicted() < 3)) then
            return S.TigerPalm:Cast()
        end
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy.time_to_max<=1&chi.max-chi>=2
        if S.TigerPalm:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and Player:EnergyTimeToMaxPredicted() <= 1 and Player:ChiMax() - Player:Chi() >= 2) then
            return S.TigerPalm:Cast()
        end
        -- chi_wave,if=chi<=3&(cooldown.rising_sun_kick.remains>=5|cooldown.whirling_dragon_punch.remains>=5)&energy.time_to_max>1
        if S.ChiWave:IsReady() and Cache.EnemiesCount[8] >= 1 and (Player:Chi() <= 3 and (S.RisingSunKick:CooldownRemainsP() >= 5 or S.WhirlingDragonPunch:CooldownRemainsP() >= 5) and Player:EnergyTimeToMaxPredicted() > 1) then
            return S.ChiWave:Cast()
        end
        -- chi_wave
        if S.ChiWave:IsReady() and Cache.EnemiesCount[8] >= 1 then
            return S.ChiWave:Cast()
        end
    end
    Cd = function()
        -- invoke_xuen_the_white_tiger
        if S.InvokeXuentheWhiteTiger:IsReady() then
            return S.InvokeXuentheWhiteTiger:Cast()
        end
        -- use_item,name=lustrous_golden_plumage
        --if I.LustrousGoldenPlumage:IsReady() then
            --return S.LustrousGoldenPlumage:Cast()
        --end
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
        -- fireblood
        if S.Fireblood:IsReady() and RubimRH.CDsON() then
            return S.Fireblood:Cast()
        end
        -- ancestral_call
        if S.AncestralCall:IsReady() and RubimRH.CDsON() then
            return S.AncestralCall:Cast()
        end
        -- touch_of_death
        if S.TouchofDeath:IsReady() and RubimRH.CDsON() then
            return S.TouchofDeath:Cast()
        end
    end
    Sef = function()
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy=energy.max&chi<1
        if S.TigerPalm:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and Player:EnergyPredicted() == Player:EnergyMax() and Player:Chi() < 1) then
            return S.TigerPalm:Cast()
        end
        -- call_action_list,name=cd
        if (true) then
            if Cd() ~= nil then
                return Cd()
            end
        end
        -- storm_earth_and_fire,if=!buff.storm_earth_and_fire.up
        if S.StormEarthandFire:IsReady() and (not Player:BuffP(S.StormEarthandFireBuff)) then
            return S.StormEarthandFire:Cast()
        end
        -- call_action_list,name=aoe,if=active_enemies>3
        if (Cache.EnemiesCount[8] > 3) then
            if Aoe() ~= nil then
                return Aoe()
            end
        end
        -- call_action_list,name=st,if=active_enemies<=3
        if (Cache.EnemiesCount[8] <= 3) then
            if St() ~= nil then
                return St()
            end
        end
    end
    Serenity = function()
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy=energy.max&chi<1&!buff.serenity.up
        if S.TigerPalm:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and Player:EnergyPredicted() == Player:EnergyMax() and Player:Chi() < 1 and not Player:BuffP(S.SerenityBuff)) then
            return S.TigerPalm:Cast()
        end
        -- call_action_list,name=cd
        if (true) then
            if Cd() ~= nil then
                return Cd()
            end
        end
        -- rushing_jade_wind,if=talent.rushing_jade_wind.enabled&!prev_gcd.1.rushing_jade_wind&buff.rushing_jade_wind.down
        if S.RushingJadeWind:IsReady() and Cache.EnemiesCount[8] >= 1 and (S.RushingJadeWind:IsAvailable() and not Player:PrevGCDP(1, S.RushingJadeWind) and Player:BuffDownP(S.RushingJadeWindBuff)) then
            return S.RushingJadeWind:Cast()
        end
        -- serenity,if=cooldown.rising_sun_kick.remains<=2&cooldown.fists_of_fury.remains<=4
        if S.Serenity:IsReady() and (S.RisingSunKick:CooldownRemainsP() <= 2 and S.FistsofFury:CooldownRemainsP() <= 4) then
            return S.Serenity:Cast()
        end
        -- fists_of_fury,if=prev_gcd.1.rising_sun_kick&prev_gcd.2.serenity
        if S.FistsofFury:IsReady() and (Player:PrevGCDP(1, S.RisingSunKick) and Player:PrevGCDP(2, S.Serenity)) then
            return S.FistsofFury:Cast()
        end
        -- fists_of_fury,if=buff.serenity.remains<=1.05
        if S.FistsofFury:IsReady() and (Player:BuffRemainsP(S.SerenityBuff) <= 1.05) then
            return S.FistsofFury:Cast()
        end
        -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
        if S.RisingSunKick:IsReady() then
            return S.RisingSunKick:Cast()
        end
        -- fist_of_the_white_tiger,if=prev_gcd.1.blackout_kick&prev_gcd.2.rising_sun_kick&chi.max-chi>2
        if S.FistoftheWhiteTiger:IsReady() and (Player:PrevGCDP(1, S.BlackoutKick) and Player:PrevGCDP(2, S.RisingSunKick) and Player:ChiMax() - Player:Chi() > 2) then
            return S.FistoftheWhiteTiger:Cast()
        end
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=prev_gcd.1.blackout_kick&prev_gcd.2.rising_sun_kick&chi.max-chi>1
        if S.TigerPalm:IsReady() and (Player:PrevGCDP(1, S.BlackoutKick) and Player:PrevGCDP(2, S.RisingSunKick) and Player:ChiMax() - Player:Chi() > 1) then
            return S.TigerPalm:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&cooldown.rising_sun_kick.remains>=2&cooldown.fists_of_fury.remains>=2
        if S.BlackoutKick:IsReady() and (not Player:PrevGCDP(1, S.BlackoutKick) and S.RisingSunKick:CooldownRemainsP() >= 2 and S.FistsofFury:CooldownRemainsP() >= 2) then
            return S.BlackoutKick:Cast()
        end
        -- spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
        if S.SpinningCraneKick:IsReady() and (Cache.EnemiesCount[8] >= 3 and not Player:PrevGCDP(1, S.SpinningCraneKick)) then
            return S.SpinningCraneKick:Cast()
        end
        -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
        if S.RisingSunKick:IsReady() then
            return S.RisingSunKick:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick
        if S.BlackoutKick:IsReady() and (not Player:PrevGCDP(1, S.BlackoutKick)) then
            return S.BlackoutKick:Cast()
        end
    end
    Serenitysr = function()
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy=energy.max&chi<1&!buff.serenity.up
        if S.TigerPalm:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and Player:EnergyPredicted() == Player:EnergyMax() and Player:Chi() < 1 and not Player:BuffP(S.SerenityBuff)) then
            return S.TigerPalm:Cast()
        end
        -- call_action_list,name=cd
        if (true) then
            if Cd() ~= nil then
                return Cd()
            end
        end
        -- serenity,if=cooldown.rising_sun_kick.remains<=2
        if S.Serenity:IsReady() and (S.RisingSunKick:CooldownRemainsP() <= 2) then
            return S.Serenity:Cast()
        end
        -- fists_of_fury,if=buff.serenity.remains<=1.05
        if S.FistsofFury:IsReady() and (Player:BuffRemainsP(S.SerenityBuff) <= 1.05) then
            return S.FistsofFury:Cast()
        end
        -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
        if S.RisingSunKick:IsReady() then
            return S.RisingSunKick:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&cooldown.rising_sun_kick.remains>=2&cooldown.fists_of_fury.remains>=2
        if S.BlackoutKick:IsReady() and (not Player:PrevGCDP(1, S.BlackoutKick) and S.RisingSunKick:CooldownRemainsP() >= 2 and S.FistsofFury:CooldownRemainsP() >= 2) then
            return S.BlackoutKick:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains
        if S.BlackoutKick:IsReady() then
            return S.BlackoutKick:Cast()
        end
    end
    SerenityOpener = function()
        -- fist_of_the_white_tiger,if=buff.serenity.down
        if S.FistoftheWhiteTiger:IsReady() and (Player:BuffDownP(S.SerenityBuff)) then
            return S.FistoftheWhiteTiger:Cast()
        end
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&buff.serenity.down&chi<4
        if S.TigerPalm:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:BuffDownP(S.SerenityBuff) and Player:Chi() < 4) then
            return S.TigerPalm:Cast()
        end
        -- call_action_list,name=cd,if=buff.serenity.down
        if (Player:BuffDownP(S.SerenityBuff)) then
            if Cd() ~= nil then
                return Cd()
            end
        end
        -- call_action_list,name=serenity,if=buff.bloodlust.down
        if (Player:HasNotHeroism()) then
            if Serenity() ~= nil then
                return Serenity()
            end
        end
        -- serenity
        if S.Serenity:IsReady() then
            return S.Serenity:Cast()
        end
        -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
        if S.RisingSunKick:IsReady() then
            return S.RisingSunKick:Cast()
        end
        -- fists_of_fury,if=prev_gcd.1.rising_sun_kick&prev_gcd.2.serenity
        if S.FistsofFury:IsReady() and (Player:PrevGCDP(1, S.RisingSunKick) and Player:PrevGCDP(2, S.Serenity)) then
            return S.FistsofFury:Cast()
        end
        -- fists_of_fury,if=prev_gcd.1.rising_sun_kick&prev_gcd.2.blackout_kick
        if S.FistsofFury:IsReady() and (Player:PrevGCDP(1, S.RisingSunKick) and Player:PrevGCDP(2, S.BlackoutKick)) then
            return S.FistsofFury:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&cooldown.rising_sun_kick.remains>=2&cooldown.fists_of_fury.remains>=2
        if S.BlackoutKick:IsReady() and (not Player:PrevGCDP(1, S.BlackoutKick) and S.RisingSunKick:CooldownRemainsP() >= 2 and S.FistsofFury:CooldownRemainsP() >= 2) then
            return S.BlackoutKick:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick
        if S.BlackoutKick:IsReady() and (not Player:PrevGCDP(1, S.BlackoutKick)) then
            return S.BlackoutKick:Cast()
        end
    end
    SerenityOpenersr = function()
        -- fist_of_the_white_tiger,if=buff.serenity.down
        if S.FistoftheWhiteTiger:IsReady() and (Player:BuffDownP(S.SerenityBuff)) then
            return S.FistoftheWhiteTiger:Cast()
        end
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=buff.serenity.down&chi<4
        if S.TigerPalm:IsReady() and (Player:BuffDownP(S.SerenityBuff) and Player:Chi() < 4) then
            return S.TigerPalm:Cast()
        end
        -- call_action_list,name=cd,if=buff.serenity.down
        if (Player:BuffDownP(S.SerenityBuff)) then
            if Cd() ~= nil then
                return Cd()
            end
        end
        -- call_action_list,name=serenity,if=buff.bloodlust.down
        if (Player:HasNotHeroism()) then
            if Serenity() ~= nil then
                return Serenity()
            end
        end
        -- serenity
        if S.Serenity:IsReady() then
            return S.Serenity:Cast()
        end
        -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
        if S.RisingSunKick:IsReady() then
            return S.RisingSunKick:Cast()
        end
        -- fists_of_fury,if=buff.serenity.remains<1
        if S.FistsofFury:IsReady() and (Player:BuffRemainsP(S.SerenityBuff) < 1) then
            return S.FistsofFury:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&cooldown.rising_sun_kick.remains>=2&cooldown.fists_of_fury.remains>=2
        if S.BlackoutKick:IsReady() and (not Player:PrevGCDP(1, S.BlackoutKick) and S.RisingSunKick:CooldownRemainsP() >= 2 and S.FistsofFury:CooldownRemainsP() >= 2) then
            return S.BlackoutKick:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains
        if S.BlackoutKick:IsReady() then
            return S.BlackoutKick:Cast()
        end
    end
    St = function()
        -- invoke_xuen_the_white_tiger
        if S.InvokeXuentheWhiteTiger:IsReady() then
            return S.InvokeXuentheWhiteTiger:Cast()
        end
        -- touch_of_death
        if S.TouchofDeath:IsReady() then
            return S.TouchofDeath:Cast()
        end
        -- storm_earth_and_fire,if=!buff.storm_earth_and_fire.up
        if S.StormEarthandFire:IsReady() and (not Player:BuffP(S.StormEarthandFireBuff)) then
            return S.StormEarthandFire:Cast()
        end
        -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=azerite.swift_roundhouse.enabled&buff.swift_roundhouse.stack=2
        if S.RisingSunKick:IsReady() and (S.SwiftRoundhouse:AzeriteEnabled() and Player:BuffStackP(S.SwiftRoundhouseBuff) == 2) then
            return S.RisingSunKick:Cast()
        end
        -- rushing_jade_wind,if=buff.rushing_jade_wind.down&!prev_gcd.1.rushing_jade_wind
        if S.RushingJadeWind:IsReady() and Cache.EnemiesCount[8] >= 1 and (Player:BuffDownP(S.RushingJadeWindBuff) and not Player:PrevGCDP(1, S.RushingJadeWind)) then
            return S.RushingJadeWind:Cast()
        end
        -- energizing_elixir,if=!prev_gcd.1.tiger_palm
        if S.EnergizingElixir:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm)) then
            return S.EnergizingElixir:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&buff.bok_proc.up
        if S.BlackoutKick:IsReady() and (not Player:PrevGCDP(1, S.BlackoutKick) and Player:ChiMax() - Player:Chi() >= 1 and HL.Tier21_4Pc and Player:BuffP(S.BokProcBuff)) then
            return S.BlackoutKick:Cast()
        end
        -- fist_of_the_white_tiger,if=(chi<=2)
        if S.FistoftheWhiteTiger:IsReady() and ((Player:Chi() <= 2)) then
            return S.FistoftheWhiteTiger:Cast()
        end
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&chi<=3&energy.time_to_max<2
        if S.TigerPalm:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:Chi() <= 3 and Player:EnergyTimeToMaxPredicted() < 2) then
            return S.TigerPalm:Cast()
        end
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&chi.max-chi>=2&buff.serenity.down&cooldown.fist_of_the_white_tiger.remains>energy.time_to_max
        if S.TigerPalm:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:ChiMax() - Player:Chi() >= 2 and Player:BuffDownP(S.SerenityBuff) and S.FistoftheWhiteTiger:CooldownRemainsP() > Player:EnergyTimeToMaxPredicted()) then
            return S.TigerPalm:Cast()
        end
        -- whirling_dragon_punch
        if S.WhirlingDragonPunch:IsReady() and Cache.EnemiesCount[5] >= 1 then
            return S.WhirlingDragonPunch:Cast()
        end
        -- fists_of_fury,if=chi>=3&energy.time_to_max>2.5&azerite.swift_roundhouse.rank<3
        if S.FistsofFury:IsReady() and (Player:Chi() >= 3 and Player:EnergyTimeToMaxPredicted() > 2.5 and S.SwiftRoundhouse:AzeriteRank() < 3) then
            return S.FistsofFury:Cast()
        end
        -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=((chi>=3&energy>=40)|chi>=5)&(talent.serenity.enabled|cooldown.serenity.remains>=6)&!azerite.swift_roundhouse.enabled
        if S.RisingSunKick:IsReady() and (((Player:Chi() >= 3 and Player:EnergyPredicted() >= 40) or Player:Chi() >= 5) and (S.Serenity:IsAvailable() or S.Serenity:CooldownRemainsP() >= 6) and not S.SwiftRoundhouse:AzeriteEnabled()) then
            return S.RisingSunKick:Cast()
        end
        -- fists_of_fury,if=!talent.serenity.enabled&(azerite.swift_roundhouse.rank<3|cooldown.whirling_dragon_punch.remains<13)
        if S.FistsofFury:IsReady() and (not S.Serenity:IsAvailable() and (S.SwiftRoundhouse:AzeriteRank() < 3 or S.WhirlingDragonPunch:CooldownRemainsP() < 13)) then
            return S.FistsofFury:Cast()
        end
        -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=cooldown.serenity.remains>=5|(!talent.serenity.enabled)&!azerite.swift_roundhouse.enabled
        if S.RisingSunKick:IsReady() and (S.Serenity:CooldownRemainsP() >= 5 or (not S.Serenity:IsAvailable()) and not S.SwiftRoundhouse:AzeriteEnabled()) then
            return S.RisingSunKick:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=cooldown.fists_of_fury.remains>2&!prev_gcd.1.blackout_kick&energy.time_to_max>1&azerite.swift_roundhouse.rank>2
        if S.BlackoutKick:IsReady() and (S.FistsofFury:CooldownRemainsP() > 2 and not Player:PrevGCDP(1, S.BlackoutKick) and Player:EnergyTimeToMaxPredicted() > 1 and S.SwiftRoundhouse:AzeriteRank() > 2) then
            return S.BlackoutKick:Cast()
        end
        -- flying_serpent_kick,if=prev_gcd.1.blackout_kick&energy.time_to_max>2&chi>1,interrupt=1
        --if S.FlyingSerpentKick:IsReady() and (Player:PrevGCDP(1, S.BlackoutKick) and Player:EnergyTimeToMaxPredicted() > 2 and Player:Chi() > 1) then
          --  return S.FlyingSerpentKick:Cast()
        --end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=buff.swift_roundhouse.stack<2&!prev_gcd.1.blackout_kick
        if S.BlackoutKick:IsReady() and (Player:BuffStackP(S.SwiftRoundhouseBuff) < 2 and not Player:PrevGCDP(1, S.BlackoutKick)) then
            return S.BlackoutKick:Cast()
        end
        -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
        if S.CracklingJadeLightning:IsReady() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitorBuff) >= 19 and Player:EnergyTimeToMaxPredicted() > 3) then
            return S.CracklingJadeLightning:Cast()
        end
        -- crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
        if S.CracklingJadeLightning:IsReady() and (I.TheEmperorsCapacitor:IsEquipped() and Player:BuffStackP(S.TheEmperorsCapacitorBuff) >= 14 and S.Serenity:CooldownRemainsP() < 13 and S.Serenity:IsAvailable() and Player:EnergyTimeToMaxPredicted() > 3) then
            return S.CracklingJadeLightning:Cast()
        end
        -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick
        if S.BlackoutKick:IsReady() and (not Player:PrevGCDP(1, S.BlackoutKick)) then
            return S.BlackoutKick:Cast()
        end
        -- chi_wave
        if S.ChiWave:IsReady() and Cache.EnemiesCount[8] >= 1 then
            return S.ChiWave:Cast()
        end
        -- chi_burst,if=energy.time_to_max>1&talent.serenity.enabled
        if S.ChiBurst:IsReady() and (Player:EnergyTimeToMaxPredicted() > 1 and S.Serenity:IsAvailable()) then
            return S.ChiBurst:Cast()
        end
        -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&(chi.max-chi>=2|energy.time_to_max<3)&!buff.serenity.up
        if S.TigerPalm:IsReady() and (not Player:PrevGCDP(1, S.TigerPalm) and not Player:PrevGCDP(1, S.EnergizingElixir) and (Player:ChiMax() - Player:Chi() >= 2 or Player:EnergyTimeToMaxPredicted() < 3) and not Player:BuffP(S.SerenityBuff)) then
            return S.TigerPalm:Cast()
        end
        -- chi_burst,if=chi.max-chi>=3&energy.time_to_max>1&!talent.serenity.enabled
        if S.ChiBurst:IsReady() and (Player:ChiMax() - Player:Chi() >= 3 and Player:EnergyTimeToMaxPredicted() > 1 and not S.Serenity:IsAvailable()) then
            return S.ChiBurst:Cast()
        end
    end
    -- call precombat
    if not Player:AffectingCombat() then
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
    -- touch_of_karma,interval=90,pct_health=0.5,if=!talent.Good_Karma.enabled,interval=90,pct_health=0.5
    if S.TouchofKarma:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[269].sk1 then
        return S.TouchofKarma:Cast()
    end

    -- potion,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
    if I.ProlongedPower:IsReady() and RubimRH.PotionON() and (Player:Buff(S.SerenityBuff) or Player:Buff(S.StormEarthandFireBuff) or (not S.Serenity:IsAvailable()) or Player:HasHeroism() or Target:TimeToDie() <= 60) then
        return I.ProlongedPower:Cast()
    end
    -- touch_of_death,if=target.time_to_die<=9
    if S.TouchofDeath:IsReady() and (Target:TimeToDie() <= 9) then
        return S.TouchofDeath:Cast()
    end

    -- call_action_list,name=serenitySR,if=((talent.serenity.enabled&cooldown.serenity.remains<=0)|buff.serenity.up)&azerite.swift_roundhouse.enabled&time>30
    if (((S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <= 0) or Player:BuffP(S.SerenityBuff)) and S.SwiftRoundhouse:AzeriteEnabled() and HL.CombatTime() > 30) then
        if Serenitysr() ~= nil then
            return Serenitysr()
        end
    end
    -- call_action_list,name=serenity,if=((!azerite.swift_roundhouse.enabled&talent.serenity.enabled&cooldown.serenity.remains<=0)|buff.serenity.up)&time>30
    if (((not S.SwiftRoundhouse:AzeriteEnabled() and S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <= 0) or Player:BuffP(S.SerenityBuff)) and HL.CombatTime() > 30) then
        if Serenity() ~= nil then
            return Serenity()
        end
    end
    -- call_action_list,name=serenity_openerSR,if=(talent.serenity.enabled&cooldown.serenity.remains<=0|buff.serenity.up)&time<30&azerite.swift_roundhouse.enabled
    if ((S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <= 0 or Player:BuffP(S.SerenityBuff)) and HL.CombatTime() < 30 and S.SwiftRoundhouse:AzeriteEnabled()) then
        if SerenityOpenersr() ~= nil then
            return SerenityOpenersr()
        end
    end
    -- call_action_list,name=serenity_opener,if=(!azerite.swift_roundhouse.enabled&talent.serenity.enabled&cooldown.serenity.remains<=0|buff.serenity.up)&time<30
    if ((not S.SwiftRoundhouse:AzeriteEnabled() and S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() <= 0 or Player:BuffP(S.SerenityBuff)) and HL.CombatTime() < 30) then
        if SerenityOpener() ~= nil then
            return SerenityOpener()
        end
    end
    -- call_action_list,name=sef,if=!talent.serenity.enabled&(buff.storm_earth_and_fire.up|cooldown.storm_earth_and_fire.charges=2)
    if (not S.Serenity:IsAvailable() and (Player:BuffP(S.StormEarthandFireBuff) or S.StormEarthandFire:ChargesP() == 2)) then
        if Sef() ~= nil then
            return Sef()
        end
    end
    -- call_action_list,name=sef,if=(!talent.serenity.enabled&cooldown.fists_of_fury.remains<=12&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=25|cooldown.touch_of_death.remains>112
    if ((not S.Serenity:IsAvailable() and S.FistsofFury:CooldownRemainsP() <= 12 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 25 or S.TouchofDeath:CooldownRemainsP() > 112) then
        if Sef() ~= nil then
            return Sef()
        end
    end
    -- call_action_list,name=sef,if=(!talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=15|cooldown.touch_of_death.remains>112&cooldown.storm_earth_and_fire.charges=1
    if ((not S.Serenity:IsAvailable() and not I.DrinkingHornCover:IsEquipped() and S.FistsofFury:CooldownRemainsP() <= 6 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 15 or S.TouchofDeath:CooldownRemainsP() > 112 and S.StormEarthandFire:ChargesP() == 1) then
        if Sef() ~= nil then
            return Sef()
        end
    end
    -- call_action_list,name=sef,if=(!talent.serenity.enabled&cooldown.fists_of_fury.remains<=12&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=25|cooldown.touch_of_death.remains>112&cooldown.storm_earth_and_fire.charges=1
    if ((not S.Serenity:IsAvailable() and S.FistsofFury:CooldownRemainsP() <= 12 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 25 or S.TouchofDeath:CooldownRemainsP() > 112 and S.StormEarthandFire:ChargesP() == 1) then
        if Sef() ~= nil then
            return Sef()
        end
    end
    -- call_action_list,name=aoe,if=active_enemies>3
    if (Cache.EnemiesCount[8] > 3) then
        if Aoe() ~= nil then
            return Aoe()
        end
    end
    -- call_action_list,name=st,if=active_enemies<=3
    if (Cache.EnemiesCount[8] <= 3) then
        if St() ~= nil then
            return St()
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
