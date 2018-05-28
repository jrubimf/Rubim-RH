--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- AethysCore
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;
-- Lua
local pairs = pairs;


--- APL Local Vars
-- Spells
if not Spell.Paladin then Spell.Paladin = {}; end
Spell.Paladin.Retribution = {
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
    ExecutionSentence = Spell(213757),
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
    -- Offensive
    AvengingWrath = Spell(31884),
    Crusade = Spell(231895),
    WakeofAshes = Spell(205273),
    -- Defensive
    -- Utility
    HammerofJustice = Spell(853),
    Rebuke = Spell(96231),
    DivineSteed = Spell(190784),
    WorldofGlory = Spell(210191),
    -- Legendaries
    LiadrinsFuryUnleashed = Spell(208408),
    ScarletInquisitorsExpurgation = Spell(248289);
    WhisperoftheNathrezim = Spell(207635)
};
local S = Spell.Paladin.Retribution;
-- Items
if not Item.Paladin then Item.Paladin = {}; end
Item.Paladin.Retribution = {
    -- Legendaries
    JusticeGaze = Item(137065, { 1 }),
    LiadrinsFuryUnleashed = Item(137048, { 11, 12 }),
    WhisperoftheNathrezim = Item(137020, { 15 }),
    AshesToDust = Item(144358, { 3 })
}
local I = Item.Paladin.Retribution;
-- Rotation Var

-- APL Action Lists (and Variables)
local function Judged()
    return Target:Debuff(S.JudgmentDebuff) or S.Judgment:CooldownRemains() > Player:GCD() * 2;
end

local function Cooldowns()
    --actions.cooldowns=potion,if=(buff.bloodlust.react|buff.avenging_wrath.up|buff.crusade.up&buff.crusade.remains<25|target.time_to_die<=40)
    --actions.cooldowns+=/blood_fury
    --actions.cooldowns+=/berserking
    --actions.cooldowns+=/arcane_torrent,if=(buff.crusade.up|buff.avenging_wrath.up)&holy_power=2&(cooldown.blade_of_justice.remains>gcd|cooldown.divine_hammer.remains>gcd)	--actions.cooldowns+=/lights_judgment,if=spell_targets.lights_judgment>=2|(!raid_event.adds.exists|raid_event.adds.in>15)&cooldown.judgment.remains>gcd&(cooldown.divine_hammer.remains>gcd|cooldown.blade_of_justice.remains>gcd)&(buff.avenging_wrath.up|buff.crusade.stack>=15)
    --actions.cooldowns+=/holy_wrath
    if CDsON() and S.HolyWrath:IsCastable() then
        return S.HolyWrath:ID()
    end
    --actions.cooldowns+=/shield_of_vengeance
    --actions.cooldowns+=/avenging_wrath
    if CDsON() and S.AvengingWrath:IsCastable() then
        return 55748
    end
    --actions.cooldowns+=/crusade,if=holy_power>=3|((equipped.137048|race.blood_elf)&holy_power>=2)
	 if CDsON() and S.Crusade:IsCastable() and ((Player:HolyPower() >= 3 and not I.LiadrinsFuryUnleashed:IsEquipped()) or ((I.LiadrinsFuryUnleashed:IsEquipped() or Player:Race() == "BloodElf") and Player:HolyPower() >= 2)) then
        return 55748
    end
end

local function Finishers()
    --actions.finishers=execution_sentence,if=spell_targets.divine_storm<=3&(cooldown.judgment.remains<gcd*4.25|debuff.judgment.remains>gcd*4.25)
    if S.ExecutionSentence:IsReady() and Target:IsInRange(20) and Cache.EnemiesCount[8] <= 3 and (S.Judgment:CooldownRemains() < Player:GCD() * 4.25 or Target:DebuffRemains(S.JudgmentDebuff) > Player:GCD() * 4.25) then
        return S.ExecutionSentence:ID()
    end
    --actions.finishers+=/divine_storm,if=debuff.judgment.up&variable.ds_castable&buff.divine_purpose.react
    if S.DivineStorm:IsReady() and Target:Debuff(S.JudgmentDebuff) and Var_DS_Castable and Player:Buff(S.DivinePurposeBuff) then
        return S.DivineStorm:ID()
    end
    --actions.finishers+=/divine_storm,if=debuff.judgment.up&variable.ds_castable&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)

    print(S.DivineStorm:IsReady() )
    print(Target:Debuff(S.JudgmentDebuff))
    print(Var_DS_Castable)
    print(S.Crusade:IsAvailable())
    print(S.Crusade:CooldownRemains())
    print(Player:GCD() * 2)
    if S.DivineStorm:IsReady() and Target:Debuff(S.JudgmentDebuff) and Var_DS_Castable and (not S.Crusade:IsAvailable() or S.Crusade:CooldownRemains() > Player:GCD() * 2) then
        return S.DivineStorm:ID()
    end

    --actions.finishers+=/justicars_vengeance,if=debuff.judgment.up&buff.divine_purpose.react&!equipped.137020&!talent.final_verdict.enabled
    if S.JusticarsVengeance:IsReady() and Target:Debuff(S.JudgmentDebuff) and Player:Buff(S.DivinePurposeBuff) and not I.WhisperoftheNathrezim:IsEquipped() or not S.FinalVerdict:IsAvailable() then
        return S.JusticarsVengeance:ID()
    end

    --actions.finishers+=/templars_verdict,if=debuff.judgment.up&buff.divine_purpose.react
    if S.TemplarsVerdict:IsReady() and Target:Debuff(S.JudgmentDebuff) and Player:Buff(S.DivinePurposeBuff) then
        return S.TemplarsVerdict:ID()
    end

    --actions.finishers+=/templars_verdict,if=debuff.judgment.up&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)&(!talent.execution_sentence.enabled|cooldown.execution_sentence.remains>gcd)
    if S.TemplarsVerdict:IsReady("Melee") and Target:Debuff(S.JudgmentDebuff) and (not S.Crusade:IsAvailable() or S.Crusade:CooldownRemains() > Player:GCD() * 2) and (not S.ExecutionSentence:IsAvailable() or S.ExecutionSentence:CooldownRemains() > Player:GCD()) then
        return S.TemplarsVerdict:ID()
    end
end

local function Generators()
    --actions.generators=variable,name=ds_castable,value=spell_targets.divine_storm>=2|(buff.scarlet_inquisitors_expurgation.stack>=29&(equipped.144358&(dot.wake_of_ashes.ticking&time>10|dot.wake_of_ashes.remains<gcd))|(buff.scarlet_inquisitors_expurgation.stack>=29&(buff.avenging_wrath.up|buff.crusade.up&buff.crusade.stack>=15|cooldown.crusade.remains>15&!buff.crusade.up)|cooldown.avenging_wrath.remains>15)&!equipped.144358)
    --Var_DS_Castable = (Cache.EnemiesCount[8] >= 2 or (Player:BuffStack(S.ScarletInquisitorsExpurgation) >= 29 and (Player:Buff(S.AvengingWrath) or Player:BuffStack(S.Crusade) >= 15 or not CDsON() or (S.Crusade:IsAvailable() and S.Crusade:CooldownRemains() > 15 and not Player:Buff(S.Crusade)) or (not S.Crusade:IsAvailable() and S.AvengingWrath:CooldownRemains() > 15)))) and AoEON()
    Var_DS_Castable = Cache.EnemiesCount[8] >= 2 or (Player:BuffStack(S.ScarletInquisitorsExpurgation) >= 29 and (I.AshesToDust:IsEquipped() and (Target:Debuff(S.WakeofAshes) and AC.CombatTime() > 10 or Target:DebuffRemains(S.WakeofAshes) < Player:GCD())) or (Player:BuffStack(S.ScarletInquisitorsExpurgation) >= 29 and (Player:Buff(S.AvengingWrath) or Player:Buff(S.Crusade) and Player:BuffStack(S.Crusade) >= 15 or S.Crusade:CooldownRemains() > 15 and not Player:Buff(S.Crusade)) or  S.AvengingWrath:CooldownRemains() > 15) and not I.AshesToDust:IsEquipped())
    --actions.generators+=/judgment,if=set_bonus.tier21_4pc
    if S.Judgment:IsReady(30) and T214 then
        return S.Judgement:ID()
    end

    --actions.generators+=/call_action_list,name=finishers,if=(buff.crusade.up&buff.crusade.stack<15|buff.liadrins_fury_unleashed.up)|(talent.wake_of_ashes.enabled&cooldown.wake_of_ashes.remains<gcd*2)
    if (Player:Buff(S.Crusade) and Player:BuffStack(S.Crusade) < 15 or Player:Buff(S.LiadrinsFuryUnleashed) or (S.WakeofAshes:IsAvailable() and S.WakeofAshes:CooldownRemains() < Player:GCD() * 2)) and Finishers() ~= nil then
        return Finishers()
    end
    --actions.generators+=/call_action_list,name=finishers,if=talent.execution_sentence.enabled&(cooldown.judgment.remains<gcd*4.25|debuff.judgment.remains>gcd*4.25)&cooldown.execution_sentence.up|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd*1.5
    if (S.ExecutionSentence:IsAvailable() and (S.Judgement:CooldownRemains() < Player:GCD() * 4.25 or Target:DebuffRemains(S.JudgmentDebuff) > Player:GCD() * 4.25) and S.ExecutionSentence:IsReady() or Player:Buff(S.WhisperoftheNathrezim) and Player:BuffRemains(S.WhisperoftheNathrezim) < Player:GCD() * 1.5) and Finishers() ~= nil then
        return Finishers()
    end

    --actions.generators+=/judgment,if=dot.execution_sentence.ticking&dot.execution_sentence.remains<gcd*2&debuff.judgment.remains<gcd*2
    if S.Judgment:IsReady(30) and Target:Debuff(S.ExecutionSentence) and Target:DebuffRemains(S.ExecutionSentence) < Player:GCD() * 2 and Target:DebuffRemains(S.JudgmentDebuff) < Player:GCD() * 2 then
        return S.Judgment:ID()
    end

    --actions.generators+=/blade_of_justice,if=holy_power<=2&(set_bonus.tier20_2pc|set_bonus.tier20_4pc)
    if S.BladeofJustice:IsReady("Melee") and Player:HolyPower() <= 2 and (T202 or T204) then
        return 231843
    end

    --actions.generators+=/divine_hammer,if=holy_power<=2&(set_bonus.tier20_2pc|set_bonus.tier20_4pc)
    if S.DivineHammer:IsCastable(8, true) and Player:HolyPower() <= 2 and (T202 or T204) then
        return 231843
    end
    --actions.generators+=/wake_of_ashes,if=(!raid_event.adds.exists|raid_event.adds.in>15)&(holy_power<=0|holy_power=1&(cooldown.blade_of_justice.remains>gcd|cooldown.divine_hammer.remains>gcd)|holy_power=2&((cooldown.zeal.charges_fractional<=0.65|cooldown.crusader_strike.charges_fractional<=0.65)))
    if S.WakeofAshes:IsReady(10) and (Player:HolyPower() == 0 or (Player:HolyPower() == 1 and (S.BladeofJustice:CooldownRemains() > Player:GCD() or S.DivineHammer:CooldownRemains() > Player:GCD())) or (Player:HolyPower() == 2 and (S.Zeal:ChargesFractional() <= 0.65 or S.CrusaderStrike:ChargesFractional() <= 0.65))) then
        return S.WakeofAshes:ID()
    end

    --actions.generators+=/blade_of_justice,if=holy_power<=3&!set_bonus.tier20_4pc
    if S.BladeofJustice:IsReady("Melee") and Player:HolyPower() <= 3 and not T204 then
        return 231843
    end

    --actions.generators+=/divine_hammer,if=holy_power<=3&!set_bonus.tier20_4pc
    if S.DivineHammer:IsReady() and Player:HolyPower() <= 3 and not T204 then
        return 231843
    end

    --actions.generators+=/judgment
    if S.Judgment:IsReady(30) then
        return S.Judgment:ID()
    end

    --actions.generators+=/call_action_list,name=finishers,if=buff.divine_purpose.up
    if Player:Buff(S.DivinePurposeBuff) and Finishers() ~= nil then
        return Finishers()
    end

    --actions.generators+=/zeal,if=cooldown.zeal.charges_fractional>=1.65&holy_power<=4&(cooldown.blade_of_justice.remains>gcd*2|cooldown.divine_hammer.remains>gcd*2)&debuff.judgment.remains>gcd
    if S.Zeal:IsReady() and S.Zeal:ChargesFractional() >= 1.65 and Player:HolyPower() <= 4 and (S.BladeofJustice:CooldownRemains() > Player:GCD() * 2 or S.DivineHammer:CooldownRemains() > Player:GCD() * 2) and Target:DebuffRemains(S.JudgmentDebuff) > Player:GCD() then
        return 166844
    end
    --actions.generators+=/crusader_strike,if=cooldown.crusader_strike.charges_fractional>=1.65&holy_power<=4&(cooldown.blade_of_justice.remains>gcd*2|cooldown.divine_hammer.remains>gcd*2)&debuff.judgment.remains>gcd&(talent.greater_judgment.enabled|!set_bonus.tier20_4pc&talent.the_fires_of_justice.enabled)
    if S.CrusaderStrike:IsReady("Melee") and S.CrusaderStrike:ChargesFractional() >= 1.65 and Player:HolyPower() <= 4 and (S.BladeofJustice:CooldownRemains() > Player:GCD() * 2 or S.DivineHammer:CooldownRemains() > Player:GCD() * 2) and Target:DebuffRemains(S.JudgmentDebuff) > Player:GCD() and (S.GreaterJudgment:IsAvailable() or not T204 and S.TheFiresofJustice:IsAvailable()) then
        return 166844
    end

    --actions.generators+=/consecration
    if S.Consecration:IsReady(10, true) and Cache.EnemiesCount[8] >= 1 then
        return S.Consecration:ID()
    end

    --actions.generators+=/hammer_of_justice,if=equipped.137065&target.health.pct>=75&holy_power<=4
    if S.HammerofJustice:IsReady(10) and I.JusticeGaze:IsEquipped() and Target:HealthPercentage() >= 75 and Player:HolyPower() <= 4 then
        return S.HammerofJustice:ID()
    end

    --actions.generators+=/call_action_list,name=finishers
    if Finishers() ~= nil then
        return Finishers()
    end

    --actions.generators+=/zeal
    if S.Zeal:IsReady() then
        return 166844
    end

    --actions.generators+=/crusader_strike
    if S.CrusaderStrike:IsReady("Melee") then
        return 166844
    end
end

local function Opener()
    --actions.opener=blood_fury
    --actions.opener+=/berserking
    --actions.opener+=/arcane_torrent,if=!set_bonus.tier20_2pc
    --actions.opener+=/judgment
    if S.Judgment:IsReady(30) then
        return S.Judgment:ID()
    end
    --actions.opener+=/blade_of_justice,if=equipped.137048|race.blood_elf|!cooldown.wake_of_ashes.up
    if S.BladeofJustice:IsReady("Melee") and (I.LiadrinsFuryUnleashed:IsEquipped() or Player:Race() == "BloodElf" or not S.WakeofAshes:IsReady()) then
        return 231843
    end
    --actions.opener+=/divine_hammer,if=equipped.137048|race.blood_elf|!cooldown.wake_of_ashes.up
    if S.DivineHammer:IsCastable(8, true) and (I.LiadrinsFuryUnleashed:IsEquipped() or Player:Race() == "BloodElf" or not S.WakeofAshes:IsReady()) then
        return 231843
    end

    --actions.opener+=/wake_of_ashes
    if S.WakeofAshes:IsCastable(10) then
        return S.WakeofAshes:ID()
    end
end

function PaladinRetribution()
    --Area Enemies
    AC.GetEnemies("Melee");
    AC.GetEnemies(8, true);
    AC.GetEnemies(10, true);
    AC.GetEnemies(20, true);

    --Out of Combat
    if not Player:AffectingCombat() then
        return "146250"
    end

    if useS1 and S.JusticarsVengeance:IsReady() and Target:IsInRange("Melee") then
        -- Divine Purpose 
        if Player:HealthPercentage() <= 90 and Player:Buff(S.DivinePurposeBuff) then
            return S.JusticarsVengeance:ID()
        end
        -- Regular
        if Player:HealthPercentage() <= 85 and Player:HolyPower() >= 5 then
            return S.JusticarsVengeance:ID()
        end
    end

    if useS1 and S.WorldofGlory:IsReady() then
        -- Divine Purpose 
        if Player:HealthPercentage() <= 90 and Player:Buff(S.DivinePurposeBuff) then
            return S.JusticarsVengeance:ID()
        end
        -- Regular
        if Player:HealthPercentage() <= 85 and Player:HolyPower() >= 3 then
            return S.JusticarsVengeance:ID()
        end
    end

    --# Executed every time the actor is available.
    --actions=auto_attack
    --actions+=/rebuke
    --actions+=/call_action_list,name=opener,if=time<2
    if Opener() ~= nil and AC.CombatTime() < 2 then
        return Opener()
    end
    --actions+=/call_action_list,name=cooldowns
    if Cooldowns() ~= nil then
        return Cooldowns()
    end
    --actions+=/call_action_list,name=generators
    if Generators() ~= nil then
        return Generators()
    end
    --Nothing to CAST
    return 233159
end