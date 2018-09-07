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
    FistOfTheWhiteTiger = Spell(261947),
    ArcaneTorrent = Spell(50613),
    AncestralCall = Spell(274738),
    Fireblood = Spell(265221),
    LightsJudgment = Spell(255647),
    FistsofFury = Spell(113656),
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
    Disable = Spell(116095),
    GrappleWeapon = Spell(233759)

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
    S.StormEarthandFire,
    S.InvokeXuentheWhiteTiger,
    S.Serenity,
    S.EnergizingElixir,
    S.TouchofDeath
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
    local Precombat, Cooldowns, SingleTarget, Serenity, Aoe
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

        if Player:Buff(S.RushingJadeWindBuff) then
            return S.RushingJadeWind:Cast()
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
    Cooldowns = function()
        -- actions.cd=invoke_xuen_the_white_tiger
        if S.InvokeXuentheWhiteTiger:IsReady() then
            return S.InvokeXuentheWhiteTiger:Cast()
        end
        -- actions.cd+=/blood_fury
        if S.BloodFury:IsReady() then
            return S.BloodFury:Cast()
        end
        -- actions.cd+=/berserking
        if S.Berserking:IsReady() then
            return S.Berserking:Cast()
        end
        -- actions.cd+=/arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
        if S.ArcaneTorrent:IsReady() and Player:ChiDeficit() >= 1 and Player:EnergyTimeToMaxPredicted() > 0.5 then
            return S.ArcaneTorrent:Cast()
        end
        -- actions.cd+=/fireblood
        if S.Fireblood:IsReady() then
            return S.Fireblood:Cast()
        end
        -- actions.cd+=/ancestral_call
        if S.AncestralCall:IsReady() then
            return S.AncestralCall:Cast()
        end
        -- actions.cd+=/touch_of_death,if=target.time_to_die>9
        if S.TouchofDeath:IsReady() and Target:TimeToDie() > 9 then
            return S.TouchofDeath:Cast()
        end
        -- actions.cd+=/storm_earth_and_fire,if=cooldown.storm_earth_and_fire.charges=2|(cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=15
        if S.StormEarthandFire:IsReady() and not Player:BuffP(S.StormEarthandFire) and
                (S.StormEarthandFire:ChargesP() == 2 or S.FistsofFury:CooldownRemainsP() <= 6) and
                Player:Chi() >= 3 and (S.RisingSunKick:CooldownRemainsP() <= 1 or Target:TimeToDie() <= 15) then
            return S.StormEarthandFire:Cast()
        end
        -- actions.cd+=/serenity,if=cooldown.rising_sun_kick.remains<=2|target.time_to_die<=12
        if S.Serenity:IsReady() and not Player:BuffP(S.Serenity) and
                (S.RisingSunKick:CooldownRemainsP() <= 2 or Target:TimeToDie() <= 12) then
            return S.Serenity:Cast()
        end
    end

    -- Serenity --
    Serenity = function()
        -- actions.serenity=rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
        if S.RisingSunKick:IsReady() then
            return S.RisingSunKick:Cast()
        end
        -- actions.serenity+=/fists_of_fury,if=(buff.bloodlust.up&prev_gcd.1.rising_sun_kick&!azerite.swift_roundhouse.enabled)|buff.serenity.remains<1|active_enemies>1
        if S.FistsofFury:IsReady() and ((Player:HasHeroismP() and Player:PrevGCD(1, S.RisingSunKick) and not S.SwiftRoundhouse:AzeriteEnabled()) or
                Player:BuffRemainsP(S.Serenity) < 1 or Cache.EnemiesCount[8] > 1) then
            return S.FistsofFury:Cast()
        end
        -- actions.serenity+=/spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&(active_enemies>=3|(active_enemies=2&prev_gcd.1.blackout_kick))
        if S.SpinningCraneKick:IsReady() and not Player:PrevGCD(1, S.SpinningCraneKick) and
                (Cache.EnemiesCount[8] >= 3 or (Cache.EnemiesCount[8] == 2 and Player:PrevGCD(1, S.BlackoutKick))) then
            return S.SpinningCraneKick:Cast()
        end
        -- actions.serenity+=/blackout_kick,target_if=min:debuff.mark_of_the_crane.remains
        if S.BlackoutKick:IsReady() then
            return S.BlackoutKick:Cast()
        end
    end

    -- Area of Effect --
    Aoe = function()
        -- actions.aoe=whirling_dragon_punch
        if S.WhirlingDragonPunch:IsReady() then
            return S.WhirlingDragonPunch:Cast()
        end
        -- actions.aoe+=/energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&energy<50
        if S.EnergizingElixir:IsReadyP() and not Player:PrevGCD(1, S.TigerPalm) and Player:Chi() <= 1 and Player:EnergyPredicted() < 50 then
            return S.EnergizingElixir:Cast()
        end
        -- actions.aoe+=/fists_of_fury,if=energy.time_to_max>2.5
        if S.FistsofFury:IsReadyP() and Player:EnergyTimeToMaxPredicted() > 2.5 then
            return S.FistsofFury:Cast()
        end
        -- actions.aoe+=/rushing_jade_wind,if=buff.rushing_jade_wind.down&energy.time_to_max>1
        if S.RushingJadeWind:IsReadyP() and Player:BufBuffDownPfP(S.RushingJadeWind) and Player:EnergyTimeToMaxPredicted() > 1 then
            return S.RushingJadeWind:Cast()
        end
        -- actions.aoe+=/rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(talent.whirling_dragon_punch.enabled&cooldown.whirling_dragon_punch.remains<gcd)&cooldown.fists_of_fury.remains>3
        if S.RisingSunKick:IsReadyP() and (S.WhirlingDragonPunch:IsAvailable() and S.WhirlingDragonPunch:CooldownRemainsP() > Player:GCD()) and
                S.FistsofFury:CooldownRemainsP() > 3 then
            return S.RisingSunKick:Cast()
        end
        -- actions.aoe+=/spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick
        if S.SpinningCraneKick:IsReadyP() and not Player:PrevGCD(1, S.SpinningCraneKick)  then
            return S.SpinningCraneKick:Cast()
        end
        -- actions.aoe+=/chi_burst,if=chi<=3
        if S.ChiBurst:IsReadyP() and Player:ChiDeficit() <= 3 then
            return S.ChiBurst:Cast()
        end
        -- actions.cd+=/arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
        if S.ArcaneTorrent:IsReadyP() and Player:ChiDeficit() >= 1 and Player:EnergyTimeToMaxPredicted() > 0.5 then
            return S.ArcaneTorrent:Cast()
        end
        -- actions.aoe+=/fist_of_the_white_tiger,if=chi.max-chi>=3&(energy>46|buff.rushing_jade_wind.down)
        if S.FistOfTheWhiteTiger:IsReadyP() and Player:ChiDeficit() >= 3 and
                (Player:BuffDownP(S.RushingJadeWind) or Player:EnergyPredicted() > 46) then
            return S.FistOfTheWhiteTiger:Cast()
        end
        -- actions.aoe+=/tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&chi.max-chi>=2&(energy>56|buff.rushing_jade_wind.down)
        if S.TigerPalm:IsReadyP() and not Player:PrevGCD(1, S.TigerPalm) and Player:ChiDeficit() >= 2 and
                (Player:BuffDownP(S.RushingJadeWind) or Player:EnergyPredicted() > 56) then
            return S.TigerPalm:Cast()
        end
        -- actions.st+=/chi_wave
        if S.ChiWave:IsReadyP() then
            return S.ChiWave:Cast()
        end
        -- actions.aoe+=/flying_serpent_kick,if=buff.bok_proc.down,interrupt=1
        -- actions.aoe+=/blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick
        if S.BlackoutKick:IsReadyP() and not Player:PrevGCD(1, S.BlackoutKick) then
            return S.BlackoutKick:Cast()
        end
    end

    -- Single Target --
    SingleTarget = function()
        -- actions.st=cancel_buff,name=rushing_jade_wind,if=active_enemies=1&(!talent.serenity.enabled|cooldown.serenity.remains>3)
        if S.RushingJadeWind:IsReady() and Player:BuffP(S.RushingJadeWind) and Cache.EnemiesCount[8] == 1 and
                (not S.Serenity:IsAvailable() or S.Serenity:CooldownRemainsP() > 3) then
            return S.RushingJadeWind:Cast()
        end
        -- actions.st+=/whirling_dragon_punch
        if S.WhirlingDragonPunch:IsReady() then
            return S.WhirlingDragonPunch:Cast()
        end
        -- actions.st+=/rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(cooldown.fists_of_fury.remains>2|chi>=5|azerite.swift_roundhouse.rank>2)
        if S.RisingSunKick:IsReady() and (S.FistsofFury:CooldownRemainsP() > 2 or Player:Chi() >= 5 or S.SwiftRoundhouse:AzeriteRank() > 2) then
            return S.RisingSunKick:Cast()
        end
        -- actions.st+=/rushing_jade_wind,if=buff.rushing_jade_wind.down&energy.time_to_max>1&active_enemies>1
        if S.RushingJadeWind:IsReady() and Player:BufBuffDownPfP(S.RushingJadeWind) and Player:EnergyTimeToMaxPredicted() > 1 and Cache.EnemiesCount[8] > 1 then
            return S.RushingJadeWind:Cast()
        end
        -- actions.st+=/fists_of_fury,if=energy.time_to_max>2.5&(azerite.swift_roundhouse.rank<3|(cooldown.whirling_dragon_punch.remains<10&talent.whirling_dragon_punch.enabled)|active_enemies>1)
        if S.FistsofFury:IsReady() and Player:EnergyTimeToMaxPredicted() > 2.5 and
                (
                        S.SwiftRoundhouse:AzeriteRank() < 3 or
                                (S.WhirlingDragonPunch:IsAvailable() and S.WhirlingDragonPunch:CooldownRemainsP() < 10) or
                                Cache.EnemiesCount[8] > 1
                ) then
            return S.FistsofFury:Cast()
        end
        -- actions.st+=/fist_of_the_white_tiger,if=chi<=2&(buff.rushing_jade_wind.down|energy>46)
        if S.FistOfTheWhiteTiger:IsReady() and Player:Chi() <= 2 and
                (Player:BuffDownP(S.RushingJadeWind) or Player:EnergyPredicted() > 46) then
            return S.FistOfTheWhiteTiger:Cast()
        end
        -- actions.st+=/energizing_elixir,if=chi<=3&energy<50
        if S.EnergizingElixir:IsReady() and Player:Chi() <= 3 and Player:EnergyPredicted() < 50 then
            return S.EnergizingElixir:Cast()
        end
        -- actions.st+=/blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&(cooldown.rising_sun_kick.remains>2|chi>=3)&(cooldown.fists_of_fury.remains>2|chi>=4|azerite.swift_roundhouse.enabled)&buff.swift_roundhouse.stack<2
        if S.BlackoutKick:IsReady()
                and (
                not Player:PrevGCD(1, S.BlackoutKick)
                        and (S.RisingSunKick:CooldownRemainsP() > 2 or Player:Chi() >= 3)
                        and (S.FistsofFury:CooldownRemainsP() > 2 or Player:Chi() >= 4 or S.SwiftRoundhouse:AzeriteEnabled())
                        and Player:BuffStack(S.SwiftRoundhouseBuff) < 2
        ) then
            return S.BlackoutKick:Cast()
        end
        -- actions.st+=/chi_wave
        if S.ChiWave:IsReady() then
            return S.ChiWave:Cast()
        end
        -- actions.st+=/chi_burst,if=chi.max-chi>=1&active_enemies=1|chi.max-chi>=2
        if S.ChiBurst:IsReady() and ((Player:ChiDeficit() >= 1 and Cache.EnemiesCount[8] == 1) or Player:ChiDeficit() >= 2) then
            return S.ChiBurst:Cast()
        end
        -- actions.st+=/tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&chi.max-chi>=2&(buff.rushing_jade_wind.down|energy>56)
        if S.TigerPalm:IsReady() and not Player:PrevGCD(1, S.TigerPalm) and Player:ChiDeficit() >= 2 and
                (Player:BuffDownP(S.RushingJadeWind) or Player:EnergyPredicted() > 56) then
            return S.TigerPalm:Cast()
        end
        -- actions.st+=/flying_serpent_kick,if=prev_gcd.1.blackout_kick&chi>1&buff.swift_roundhouse.stack<2,interrupt=1
        -- actions.st+=/fists_of_fury,if=energy.time_to_max>2.5&cooldown.rising_sun_kick.remains>2&buff.swift_roundhouse.stack=2
        if S.FistsofFury:IsReady() and Player:EnergyTimeToMaxPredicted() > 2.5 and S.RisingSunKick:CooldownRemainsP() > 2 and
                Player:BuffStack(S.SwiftRoundhouseBuff) == 2 then
            return S.FistsofFury:Cast()
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

    -- In Combat
    -- actions+=/call_action_list,name=serenity,if=buff.serenity.up
    if Player:BuffP(S.Serenity) then
        if Serenity() ~= nil then
            return Serenity()
        end
    end
    -- actions+=/fist_of_the_white_tiger,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=3
    if S.FistOfTheWhiteTiger:IsReadyP() and (Player:EnergyTimeToMaxPredicted() < 1 or
            (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)) and
            Player:ChiDeficit() >= 3 then
        return S.FistOfTheWhiteTiger:Cast()
    end
    -- actions+=/tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=2&!prev_gcd.1.tiger_palm
    if S.TigerPalm:IsReadyP() and
            (
                    Player:EnergyTimeToMaxPredicted() < 1 or
                            (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)
            ) and
            Player:ChiDeficit() >= 2 and not Player:PrevGCD(1, S.TigerPalm) then
        return S.TigerPalm:Cast()
    end
    -- actions.st=call_action_list,name=cd
    if (true) then
        if Cooldowns() ~= nil then
            return Cooldowns()
        end
    end
    -- actions+=/call_action_list,name=st,if=(active_enemies<4&azerite.swift_roundhouse.rank<3)|active_enemies<5
    if ((Cache.EnemiesCount[8] < 4 and S.SwiftRoundhouse:AzeriteRank() < 3) or Cache.EnemiesCount[8] < 5) then
        if SingleTarget() ~= nil then
            return SingleTarget()
        end
    end ;
    -- actions+=/call_action_list,name=st,if=(active_enemies<4&azerite.swift_roundhouse.rank<3)|active_enemies<5
    if ((Cache.EnemiesCount[8] >= 4 and S.SwiftRoundhouse:AzeriteRank() < 3) or Cache.EnemiesCount[8] >= 5) then
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
