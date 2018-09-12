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

--Retribution
RubimRH.Spell[70] = {
    -- Racials
    ArcaneTorrent = Spell(25046),
    GiftoftheNaaru = Spell(59547),
    -- Abilities
    BladeofJustice = Spell(184575),
    Consecration = Spell(205228),
    CrusaderStrike = Spell(35395),
    DivineHammer = Spell(198034),
    DivinePurpose = Spell(223817),
    DivinePurposeBuff = Spell(223819),
    DivineStorm = Spell(53385),
    ExecutionSentence = Spell(267798),
    GreaterJudgment = Spell(218718),
    HolyWrath = Spell(210220),
    Judgment = Spell(20271),
    JudgmentDebuff = Spell(197277),
    JusticarsVengeance = Spell(215661),
    TemplarsVerdict = Spell(85256),
    TheFiresofJustice = Spell(203316),
    TheFiresofJusticeBuff = Spell(209785),
    Zeal = Spell(217020),
    FinalVerdict = Spell(198038),
    ShieldOfVengance = Spell(184662),
    Forbearance = Spell(25771),
    -- Offensive
    AvengingWrath = Spell(31884),
    Crusade = Spell(231895),
    --Talent
    Inquisition = Spell(84963),
    DivineJudgement = Spell(271580),
    HammerofWrath = Spell(24275),
    WakeofAshes = Spell(255937),
    RighteousVerdict = Spell(267610),


    -- Azerite Power
    DivineStormBuffAzerite = Spell(278523),
    DivineRight = Spell(277678),

    -- Defensive
    FlashOfLight = Spell(19750),
    SelfLessHealerBuff = Spell(114250),
    DivineShield = Spell(642),
    LayOnHands = Spell(633),
    WordofGlory = Spell(210191),

    -- Utility
    HammerofJustice = Spell(853),
    Rebuke = Spell(96231),
    DivineSteed = Spell(190784),


    -- Legendaries
    LiadrinsFuryUnleashed = Spell(208408),
    ScarletInquisitorsExpurgation = Spell(248289),
    WhisperoftheNathrezim = Spell(207635),

    -- PvP Talent
    HammerOfReckoning = Spell(247675),
    HammerOfReckoningBuff = Spell(247677),
    HandOfHidrance = Spell(183218),
}

local S = RubimRH.Spell[70]
local G = RubimRH.Spell[1] -- General Skills

S.AvengingWrath.TextureSpellID = { 55748 }
S.Crusade.TextureSpellID = { 55748 }


-- Items
if not Item.Paladin then
    Item.Paladin = {};
end
Item.Paladin.Retribution = {
    -- Legendaries
    JusticeGaze = Item(137065, { 1 }),
    LiadrinsFuryUnleashed = Item(137048, { 11, 12 }),
    WhisperoftheNathrezim = Item(137020, { 15 }),
    AshesToDust = Item(144358, { 3 })
}
local I = Item.Paladin.Retribution;

local EnemyRanges = { "Melee", 8, 12, 30 }
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

function ConcerationTime()
    for i = 1, 5 do
        local active, totemName, startTime, duration, textureId = GetTotemInfo(i)
        if active == true then
            return startTime + duration - GetTime()
        end
    end
    return 0
end

local VarDsCastable
local function APL()
    local Precombat, Cooldowns, Finishers, Generators, Opener
    UpdateRanges()
    Precombat = function()

    end

    if not Player:AffectingCombat() then

        if Precombat() ~= nil then
            return Precombat()
        end

        return 0, 462338
    end

    if S.Rebuke:IsReady(30) and RubimRH.db.profile.mainOption.useInterrupts and Target:IsInterruptible() then
        return S.Rebuke:Cast()
    end

    Cooldowns = function()
        -- lights_judgment,if=spell_targets.lights_judgment>=2|(!raid_event.adds.exists|raid_event.adds.in>75)
        if S.LightsJudgment:IsReady() and HR.CDsON() and (Cache.EnemiesCount[5] >= 2 or (not (Cache.EnemiesCount[30] > 1) or 10000000000 > 75)) then
            return S.LightsJudgment:Cast()
        end
        -- fireblood,if=buff.avenging_wrath.up|buff.crusade.up&buff.crusade.stack=10
        if S.Fireblood:IsReady() and HR.CDsON() and (Player:BuffP(S.AvengingWrathBuff) or Player:BuffP(S.Crusade) and Player:BuffStackP(S.Crusade) == 10) then
            return S.Fireblood:Cast()
        end
        -- shield_of_vengeance
        if S.ShieldofVengeance:IsReady() then
            return S.ShieldofVengeance:Cast()
        end
        -- avenging_wrath,if=buff.inquisition.up|!talent.inquisition.enabled
        if S.AvengingWrath:IsReady() and (Player:BuffP(S.Inquisition) or not S.Inquisition:IsAvailable()) then
            return S.AvengingWrath:Cast()
        end
        -- crusade,if=holy_power>=4
        if S.Crusade:IsReady() and (Player:HolyPower() >= 4) then
            return S.Crusade:Cast()
        end
    end
    --varDSCastable = RubimRH.AoEON() and (Cache.EnemiesCount[8] >= 3 or (not S.RighteousVerdict:IsAvailable() and S.DivineJudgement:IsAvailable() and Cache.EnemiesCount[8] >= 2) or (S.DivineRight:AzeriteEnabled() and Target:HealthPercentage() <= 20 and not Player:Buff(S.DivineStormBuffAzerite)))
    Finishers = function()
        -- variable,name=ds_castable,value=spell_targets.divine_storm>=3|!talent.righteous_verdict.enabled&talent.divine_judgment.enabled&spell_targets.divine_storm>=2|azerite.divine_right.enabled&azerite.divine_right.rank>=2&target.health.pct<=20&buff.divine_right.down
        local VarDsCastable = num(Cache.EnemiesCount[8] >= 3 or not S.RighteousVerdict:IsAvailable() and S.DivineJudgment:IsAvailable() and Cache.EnemiesCount[8] >= 2 or S.DivineRight:AzeriteEnabled() and S.DivineRight:AzeriteRank() >= 2 and Target:HealthPercentage() <= 20 and Player:BuffDownP(S.DivineRight))
        -- inquisition,if=buff.inquisition.down|buff.inquisition.remains<5&holy_power>=3|talent.execution_sentence.enabled&cooldown.execution_sentence.remains<10&buff.inquisition.remains<15|cooldown.avenging_wrath.remains<15&buff.inquisition.remains<20&holy_power>=3
        if S.Inquisition:IsReady() and (Player:BuffDownP(S.Inquisition) or Player:BuffRemainsP(S.Inquisition) < 5 and Player:HolyPower() >= 3 or S.ExecutionSentence:IsAvailable() and S.ExecutionSentence:CooldownRemainsP() < 10 and Player:BuffRemainsP(S.Inquisition) < 15 or S.AvengingWrath:CooldownRemainsP() < 15 and Player:BuffRemainsP(S.Inquisition) < 20 and Player:HolyPower() >= 3) then
            return S.Inquisition:Cast()
        end
        -- execution_sentence,if=spell_targets.divine_storm<=3&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)
        if S.ExecutionSentence:IsReady() and (Cache.EnemiesCount[8] <= 3 and (not S.Crusade:IsAvailable() or S.Crusade:CooldownRemainsP() > Player:GCD() * 2)) then
            return S.ExecutionSentence:Cast()
        end
        -- divine_storm,if=variable.ds_castable&buff.divine_purpose.react
        if S.DivineStorm:IsReady() and (bool(VarDsCastable) and bool(Player:BuffStackP(S.DivinePurposeBuff))) then
            return S.DivineStorm:Cast()
        end
        -- divine_storm,if=variable.ds_castable&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)
        if S.DivineStorm:IsReady() and (bool(VarDsCastable) and (not S.Crusade:IsAvailable() or S.Crusade:CooldownRemainsP() > Player:GCD() * 2)) then
            return S.DivineStorm:Cast()
        end
        -- templars_verdict,if=buff.divine_purpose.react&(!talent.execution_sentence.enabled|cooldown.execution_sentence.remains>gcd)
        if S.TemplarsVerdict:IsReady() and (bool(Player:BuffStackP(S.DivinePurposeBuff)) and (not S.ExecutionSentence:IsAvailable() or S.ExecutionSentence:CooldownRemainsP() > Player:GCD())) then
            return S.TemplarsVerdict:Cast()
        end
        -- templars_verdict,if=(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)&(!talent.execution_sentence.enabled|buff.crusade.up&buff.crusade.stack<10|cooldown.execution_sentence.remains>gcd*2)
        if S.TemplarsVerdict:IsReady() and ((not S.Crusade:IsAvailable() or S.Crusade:CooldownRemainsP() > Player:GCD() * 2) and (not S.ExecutionSentence:IsAvailable() or Player:BuffP(S.Crusade) and Player:BuffStackP(S.Crusade) < 10 or S.ExecutionSentence:CooldownRemainsP() > Player:GCD() * 2)) then
            return S.TemplarsVerdict:Cast()
        end
    end
    finishers = function()


        --- Azerite should work
        -- actions.finishers=variable,name=ds_castable,      value=spell_targets.divine_storm>=3|!talent.righteous_verdict.enabled&talent.divine_judgment.enabled&spell_targets.divine_storm>=2|azerite.divine_right.enabled&target.health.pct<=20&buff.divine_right.down
        varDSCastable = RubimRH.AoEON() and (Cache.EnemiesCount[8] >= 3 or (not S.RighteousVerdict:IsAvailable() and S.DivineJudgement:IsAvailable() and Cache.EnemiesCount[8] >= 2) or (S.DivineRight:AzeriteEnabled() and Target:HealthPercentage() <= 20 and not Player:Buff(S.DivineStormBuffAzerite)))

        --actions.finishers+=/inquisition,if=buff.inquisition.down|buff.inquisition.remains<5&holy_power>=3|talent.execution_sentence.enabled&cooldown.execution_sentence.remains<10&buff.inquisition.remains<15|
        --cooldown.avenging_wrath.remains<15&buff.inquisition.remains<20&holy_power>=3
        if (S.Inquisition:IsAvailable() and S.Inquisition:IsReady()) and (not Player:Buff(S.Inquisition)
                or Player:BuffRemains(S.Inquisition) < 5 and Player:HolyPower() >= 3
                or S.ExecutionSentence:IsAvailable() and S.ExecutionSentence:CooldownRemains() < 10 and Player:BuffRemains(S.Inquisition) < 15 or S.AvengingWrath:CooldownRemains() < 15 and Player:BuffRemains(S.Inquisition) < 20 and Player:HolyPower() >= 3) then
            return S.Inquisition:Cast()
        end

        --actions.finishers+=/execution_sentence,if=spell_targets.divine_storm<=3&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)
        if S.ExecutionSentence:IsReady("Melee") and (Target:IsInRange(20) and Cache.EnemiesCount[8] <= 3 and ((not S.Crusade:IsAvailable() or S.Crusade:CooldownRemains() > Player:GCD() * 2) or not RubimRH.CDsON())) then
            return S.ExecutionSentence:Cast()
        end

        --actions.finishers+=/divine_storm,if=variable.ds_castable&buff.divine_purpose.react
        if S.DivineStorm:IsReady("Melee") and varDSCastable and Player:Buff(S.DivinePurposeBuff) then
            return S.DivineStorm:Cast()
        end

        --actions.finishers+=/divine_storm,if=variable.ds_castable&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)
        if S.DivineStorm:IsReady("Melee") and (varDSCastable and ((not S.Crusade:IsAvailable() or S.Crusade:CooldownRemains() > Player:GCD() * 2) or not RubimRH.CDsON())) then
            return S.DivineStorm:Cast()
        end

        --actions.finishers+=/templars_verdict,if=buff.divine_purpose.react&(!talent.execution_sentence.enabled|cooldown.execution_sentence.remains>gcd)
        if S.TemplarsVerdict:IsReady("Melee") and (Player:Buff(S.DivinePurposeBuff) and (not S.ExecutionSentence:IsAvailable() or S.ExecutionSentence:CooldownRemains() > Player:GCD())) then
            return S.TemplarsVerdict:Cast()
        end

        --actions.finishers+=/templars_verdict,if=(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)&(!talent.execution_sentence.enabled|buff.crusade.up&buff.crusade.stack<10|cooldown.execution_sentence.remains>gcd*2)
        if S.TemplarsVerdict:IsReady("Melee") and ((not S.Crusade:IsAvailable() or S.Crusade:CooldownRemains() >= Player:GCD() * 2)
                and (not S.ExecutionSentence:IsAvailable() or Player:Buff(S.Crusade) and Player:BuffStack(S.Crusade) < 10 or S.ExecutionSentence:CooldownRemains() > Player:GCD() * 2)) then
            return S.TemplarsVerdict:Cast()
        end
    end

    local HoW
    generators = function()


        --actions.generators = variable, name=HoW, value = (!talent.hammer_of_wrath.enabled|target.health.pct>=20&(buff.avenging_wrath.down|buff.crusade.down))
        HoW = (not S.HammerofWrath:IsAvailable() or (Target:Exists() and Target:HealthPercentage() >= 20) and (not Player:Buff(S.AvengingWrath) or not Player:Buff(S.Crusade)))

        --actions.generators+ = /call_action_list, name = finishers, if = holy_power>=5
        if Player:HolyPower() >= 5 and finishers() ~= nil then
            return finishers()
        end

        --actions.generators+ = /wake_of_ashes, if= (holy_power<=0|holy_power = 1&cooldown.blade_of_justice.remains>gcd)
        if S.WakeofAshes:IsReady() and Cache.EnemiesCount["Melee"] >= 1 and (Player:HolyPower() <= 0 or Player:HolyPower() == 1 and S.BladeofJustice:CooldownRemains() > Player:GCD()) then
            return S.WakeofAshes:Cast()
        end

        --actions.generators+ =/blade_of_justice, if = holy_power<=2|(holy_power = 3&(cooldown.hammer_of_wrath.remains>gcd*2|variable.HoW))
        if S.BladeofJustice:IsReady(12) and (Player:HolyPower() <= 2 or (Player:HolyPower() == 3 and (S.HammerofWrath:CooldownRemains() > Player:GCD() * 2 or HoW))) then
            return S.BladeofJustice:Cast()
        end

        --actions.generators+ = /judgment, if =holy_power<=2|(holy_power<=4&(cooldown.blade_of_justice.remains>gcd*2|variable.HoW))
        if S.Judgment:IsReady(30) and (Player:HolyPower() <= 2 or (Player:HolyPower() <= 4 and (S.BladeofJustice:CooldownRemains() > Player:GCD() * 2 or HoW))) then
            return S.Judgment:Cast()
        end

        --actions.generators+ =/hammer_of_wrath, if = holy_power<=4
        if S.HammerofWrath:IsReady(30) and Player:HolyPower() <= 4 then
            return S.HammerofWrath:Cast()
        end

        --actions.generators+ = /consecration, if = holy_power<=2|holy_power<=3&cooldown.blade_of_justice.remains>gcd*2|holy_power = 4&cooldown.blade_of_justice.remains>gcd*2&cooldown.judgment.remains>gcd*2
        if (S.Consecration:IsAvailable() and S.Consecration:IsReady() and RubimRH.lastMoved() > 0.2) and (Player:HolyPower() <= 2 or Player:HolyPower() <= 3 and S.BladeofJustice:CooldownRemains() > Player:GCD() * 2 or Player:HolyPower() == 4 and S.BladeofJustice:CooldownRemains() > Player:GCD() * 2 and S.Judgment:CooldownRemains() > Player:GCD() * 2) then
            return S.Consecration:Cast()
        end

        --actions.generators+ = /call_action_list, name = finishers, if = talent.hammer_of_wrath.enabled&(target.health.pct<=20|buff.avenging_wrath.up|buff.crusade.up)&(buff.divine_purpose.up|buff.crusade.stack<10)
        if finishers() ~= nil and (S.HammerofWrath:IsAvailable() and (((Target:Exists() and Target:HealthPercentage() <= 20) or Player:Buff(S.AvengingWrath) or Player:Buff(S.Crusade)) and (Player:Buff(S.DivinePurposeBuff) or Player:BuffStack(S.Crusade) < 10))) then
            return finishers()
        end

        --actions.generators+= /crusader_strike, if = cooldown.crusader_strike.charges_fractional>=1.75&(holy_power<=2|holy_power<=3&cooldown.blade_of_justice.remains>gcd*2|holy_power = 4&cooldown.blade_of_justice.remains>gcd*2&
        --cooldown.judgment.remains>gcd*2&cooldown.consecration.remains>gcd*2)
        if S.CrusaderStrike:IsReady("Melee") and (S.CrusaderStrike:ChargesFractional() >= 1.75 and (Player:HolyPower() <= 2 or Player:HolyPower() <= 3 and S.BladeofJustice:CooldownRemains() > Player:GCD() * 2 or Player:HolyPower() == 4 and S.BladeofJustice:CooldownRemains() > Player:GCD() * 2)) then
            return S.CrusaderStrike:Cast()
        end

        --actions.generators+ = /call_action_list, name = finishers
        if finishers() ~= nil then
            return finishers()
        end

        --actions.generators+ = /crusader_strike, if = holy_power<=4
        if S.CrusaderStrike:IsReady("Melee") and Player:HolyPower() <= 4 then
            return S.CrusaderStrike:Cast()
        end
    end

    opener = function()
        --actions.opener =  /sequence, if = talent.wake_of_ashes.enabled&talent.crusade.enabled&talent.execution_sentence.enabled&!talent.hammer_of_wrath.enabled,
        --name = wake_opener_ES_CS:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:crusader_strike:execution_sentence
        if S.WakeofAshes:IsAvailable() and S.Crusade:IsAvailable() and S.ExecutionSentence:IsAvailable() and not S.HammerofWrath:IsAvailable() then
            RubimRH.castSpellSequence = {
                S.BladeofJustice,
                S.n,
                S.Crusade,
                S.TemplarsVerdict,
                S.WakeofAshes,
                S.TemplarsVerdict,
                S.CrusaderStrike,
                S.ExecutionSentence,
            }
        end

        --actions.opener+ = /sequence, if = talent.wake_of_ashes.enabled&talent.crusade.enabled&!talent.execution_sentence.enabled&!talent.hammer_of_wrath.enabled,
        --name = wake_opener_CS:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:crusader_strike:templars_verdict
        if S.WakeofAshes:IsAvailable() and S.Crusade:IsAvailable() and not S.ExecutionSentence:IsAvailable() and not S.HammerofWrath:IsAvailable() then
            RubimRH.castSpellSequence = {
                S.BladeofJustice,
                S.Judgment,
                S.Crusade,
                S.TemplarsVerdict,
                S.WakeofAshes,
                S.TemplarsVerdict,
                S.CrusaderStrike,
                S.TemplarsVerdict,
            }
        end

        --actions.opener+ = /sequence, if = talent.wake_of_ashes.enabled&talent.crusade.enabled&talent.execution_sentence.enabled&talent.hammer_of_wrath.enabled,
        --name = wake_opener_ES_HoW:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:hammer_of_wrath:execution_sentence
        if S.WakeofAshes:IsAvailable() and S.Crusade:IsAvailable() and S.ExecutionSentence:IsAvailable() and S.HammerofWrath:IsAvailable() then
            RubimRH.castSpellSequence = {
                S.BladeofJustice,
                S.Judgment,
                S.Crusade,
                S.TemplarsVerdict,
                S.WakeofAshes,
                S.TemplarsVerdict,
                S.HammerofWrath,
                S.ExecutionSentence,
            }
        end
        --actions.opener+ = /sequence, if = talent.wake_of_ashes.enabled&talent.crusade.enabled&!talent.execution_sentence.enabled&talent.hammer_of_wrath.enabled,
        --name = wake_opener_HoW:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:hammer_of_wrath:templars_verdict
        if S.WakeofAshes:IsAvailable() and S.Crusade:IsAvailable() and not S.ExecutionSentence:IsAvailable() and S.HammerofWrath:IsAvailable() then
            RubimRH.castSpellSequence = {
                S.BladeofJustice,
                S.Judgment,
                S.Crusade,
                S.TemplarsVerdict,
                S.WakeofAshes,
                S.TemplarsVerdict,
                S.HammerofWrath,
                S.TemplarsVerdict,
            }
        end
        --actions.opener+ = /sequence, if = talent.wake_of_ashes.enabled&talent.inquisition.enabled, n
        --ame = wake_opener_Inq:shield_of_vengeance:blade_of_justice:judgment:inquisition:avenging_wrath:wake_of_ashes
        if S.WakeofAshes:IsAvailable() and S.Inquisition:IsAvailable() then
            RubimRH.castSpellSequence = {
                S.BladeofJustice,
                S.Judgment,
                S.Inquisition,
                S.AvengingWrath,
                S.WakeofAshes,
            }
        end

        if RubimRH.CastSequence() ~= nil and RubimRH.CastSequence():IsReady() then
            return RubimRH.CastSequence():Cast()
        end
    end

    if HL.CombatTime() < 2 and opener ~= nil and RubimRH.CDsON() and Target:IsInRange("Melee") then
        return opener()
    end

    if S.FlashOfLight:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[70].sk2 and Player:StoppedFor() >= 0.5 then
        return S.FlashOfLight:Cast()
    end

    --actions+=/call_action_list,name=cooldowns
    if cooldowns() ~= nil then
        return cooldowns()
    end

    --actions+=/call_action_list,name=generators
    if generators() ~= nil then
        return generators()
    end
    --Nothing to CAST

    if S.JusticarsVengeance:IsReady() and Target:IsInRange("Melee") then
        -- Regular
        if Player:HealthPercentage() <= RubimRH.db.profile[70].sk3 and not Player:Buff(S.DivinePurposeBuff) and Player:HolyPower() >= 5 then
            return S.JusticarsVengeance:Cast()
        end
        -- Divine Purpose
        if Player:HealthPercentage() <= RubimRH.db.profile[70].sk3 - 5 and Player:Buff(S.DivinePurposeBuff) then
            return S.JusticarsVengeance:Cast()
        end

    end

    if S.WordofGlory:IsReady() then
        -- Regular
        if Player:HealthPercentage() <= RubimRH.db.profile[70].sk6 and not Player:Buff(S.DivinePurposeBuff) and Player:HolyPower() >= 3 then
            return S.WordofGlory:Cast()
        end
        -- Divine Purpose
        if Player:HealthPercentage() <= RubimRH.db.profile[70].sk6 - 5 and Player:Buff(S.DivinePurposeBuff) then
            return S.WordofGlory:Cast()
        end

    end

    return 0, 135328
end

RubimRH.Rotation.SetAPL(70, APL);

local function PASSIVE()

    if S.ShieldOfVengance:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[70].sk1 then
        return S.ShieldOfVengance:Cast()
    end

    if S.DivineShield:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[70].sk4 and not Player:Debuff(S.Forbearance) then
        return S.DivineShield:Cast()
    end

    if S.LayOnHands:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[70].sk5 and not Player:Debuff(S.Forbearance) then
        return S.LayOnHands:Cast()
    end

    return RubimRH.Shared()


end

RubimRH.Rotation.SetPASSIVE(70, PASSIVE);



--actions.finishers=variable,name=ds_castable,value=spell_targets.divine_storm>=3|talent.divine_judgment.enabled&spell_targets.divine_storm>=2|azerite.divine_right.enabled&target.health.pct<=20&buff.divine_right.down
--actions.finishers+=/inquisition,if=buff.inquisition.down|buff.inquisition.remains<5&holy_power>=3|talent.execution_sentence.enabled&cooldown.execution_sentence.remains<10&buff.inquisition.remains<15|cooldown.avenging_wrath.remains<15&buff.inquisition.remains<20&holy_power>=3
--actions.finishers+=/execution_sentence,if=spell_targets.divine_storm<=3&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)
--actions.finishers+=/divine_storm,if=variable.ds_castable&buff.divine_purpose.react
--actions.finishers+=/divine_storm,if=variable.ds_castable&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)
--actions.finishers+=/templars_verdict,if=buff.divine_purpose.react&(!talent.execution_sentence.enabled|cooldown.execution_sentence.remains>gcd)
--actions.finishers+=/templars_verdict,if=(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)&(!talent.execution_sentence.enabled|buff.crusade.up&buff.crusade.stack<10|cooldown.execution_sentence.remains>gcd*2)

--actions.generators = variable, name=HoW, value = (!talent.hammer_of_wrath.enabled|target.health.pct>=20&(buff.avenging_wrath.down|buff.crusade.down))
--actions.generators+ = /call_action_list, name = finishers, if = holy_power>=5
--actions.generators+ = /wake_of_ashes, if= (!raid_event.adds.exists|raid_event.adds. in >20)&(holy_power<=0|holy_power = 1&cooldown.blade_of_justice.remains>gcd)
--actions.generators+ =/blade_of_justice, if = holy_power<=2|(holy_power = 3&(cooldown.hammer_of_wrath.remains>gcd*2|variable.HoW))
--actions.generators+ = /judgment, if =holy_power<=2|(holy_power<=4&(cooldown.blade_of_justice.remains>gcd*2|variable.HoW))
--actions.generators+ =/hammer_of_wrath, if = holy_power<=4
--actions.generators+ = /consecration, if = holy_power<=2|holy_power<=3&cooldown.blade_of_justice.remains>gcd*2|holy_power = 4&cooldown.blade_of_justice.remains>gcd*2&cooldown.judgment.remains>gcd*2
--actions.generators+ = /call_action_list, name = finishers, if = talent.hammer_of_wrath.enabled&(target.health.pct<=20|buff.avenging_wrath.up|buff.crusade.up)&(buff.divine_purpose.up|buff.crusade.stack<10)
--actions.generators+= /crusader_strike, if = cooldown.crusader_strike.charges_fractional>=1.75&(holy_power<=2|holy_power<=3&cooldown.blade_of_justice.remains>gcd*2|holy_power = 4&cooldown.blade_of_justice.remains>gcd*2&cooldown.judgment.remains>gcd*2&cooldown.consecration.remains>gcd*2)
--actions.generators+ = /call_action_list, name = finishers
--actions.generators+ = /crusader_strike, if = holy_power<=4
--actions.generators+ = /arcane_torrent, if= (debuff.execution_sentence.up|(talent.hammer_of_wrath.enabled&(target.health.pct>=20|buff.avenging_wrath.down|buff.crusade.down))|!talent.execution_sentence.enabled|!talent.hammer_of_wrath.enabled)&holy_power<=4

--actions.opener =  /sequence,   if = talent.wake_of_ashes.enabled&talent.crusade.enabled&talent.execution_sentence.enabled&!talent.hammer_of_wrath.enabled, name = wake_opener_ES_CS:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:crusader_strike:execution_sentence
--actions.opener+ = /sequence, if = talent.wake_of_ashes.enabled&talent.crusade.enabled&!talent.execution_sentence.enabled&!talent.hammer_of_wrath.enabled, name = wake_opener_CS:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:crusader_strike:templars_verdict
--actions.opener+ = /sequence, if = talent.wake_of_ashes.enabled&talent.crusade.enabled&talent.execution_sentence.enabled&talent.hammer_of_wrath.enabled, name = wake_opener_ES_HoW:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:hammer_of_wrath:execution_sentence
--actions.opener+ = /sequence, if = talent.wake_of_ashes.enabled&talent.crusade.enabled&!talent.execution_sentence.enabled&talent.hammer_of_wrath.enabled, name = wake_opener_HoW:shield_of_vengeance:blade_of_justice:judgment:crusade:templars_verdict:wake_of_ashes:templars_verdict:hammer_of_wrath:templars_verdict
--actions.opener+ = /sequence, if = talent.wake_of_ashes.enabled&talent.inquisition.enabled, name = wake_opener_Inq:shield_of_vengeance:blade_of_justice:judgment:inquisition:avenging_wrath:wake_of_ashes


