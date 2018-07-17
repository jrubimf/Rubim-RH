--- ============================ HEADER ============================
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
local addonName, addonTable = ...;
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;

local activeUnitPlates = {}

if not Spell.DeathKnight then
    Spell.DeathKnight = {};
end

Spell.DeathKnight.Frost = {
    -- Racials
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    GiftoftheNaaru = Spell(59547),

    -- Abilities
    ChainsOfIce = Spell(45524),
    EmpowerRuneWeapon = Spell(47568),
    FrostFever = Spell(55095),
    FrostStrike = Spell(49143),
    HowlingBlast = Spell(49184),
    Obliterate = Spell(49020),
    PillarOfFrost = Spell(51271),
    RazorIce = Spell(51714),
    RemorselessWinter = Spell(196770),
    KillingMachine = Spell(51124),
    Rime = Spell(59052),
    UnholyStrength = Spell(53365),
    -- Talents
    BreathofSindragosa = Spell(152279),
    BreathofSindragosaTicking = Spell(155166),
    FrostScythe = Spell(207230),
    FrozenPulse = Spell(194909),
    FreezingFog = Spell(207060),
    GatheringStorm = Spell(194912),
    GatheringStormBuff = Spell(211805),
    GlacialAdvance = Spell(194913),
    HornOfWinter = Spell(57330),
    IcyTalons = Spell(194878),
    IcyTalonsBuff = Spell(194879),
    MurderousEfficiency = Spell(207061),
    Obliteration = Spell(281238),
    RunicAttenuation = Spell(207104),
    ShatteringStrikes = Spell(207057),
    Icecap = Spell(207126),
    ColdHeartTalent = Spell(281208),
    ColdHeartBuff = Spell(281209),
    ColdHeartItemBuff = Spell(235599),
    FrostwyrmsFury = Spell(279302),
    -- Defensive
    AntiMagicShell = Spell(48707),
    DeathStrike = Spell(49998),
    IceboundFortitude = Spell(48792),
    DarkSuccor = Spell(101568),
    -- Utility
    ControlUndead = Spell(45524),
    DeathGrip = Spell(49576),
    MindFreeze = Spell(47528),
    PathOfFrost = Spell(3714),
    WraithWalk = Spell(212552),
};

-- Items
if not Item.DeathKnight then
    Item.DeathKnight = {};
end
Item.DeathKnight.Frost = {
    -- Legendaries
    ConvergenceofFates = Item(140806, { 13, 14 }),
    ColdHeart = Item(151796, { 5 }),
    ConsortsColdCore = Item(144293, { 8 }),
    KiljaedensBurningWish = Item(144259, { 13, 14 }),
    KoltirasNewfoundWill = Item(132366, { 6 }),
    PerseveranceOfTheEbonMartyre = Item(132459, { 1 }),
    SealOfNecrofantasia = Item(137223, { 11, 12 }),
    ToravonsWhiteoutBindings = Item(132458, { 9 }),
    --Trinkets
    FelOiledInfernalMachine = Item(144482, { 13, 14 }),
    --Potion
    ProlongedPower = Item(142117)
};

local S = Spell.DeathKnight.Frost;
local I = Item.DeathKnight.Frost;

local T202PC, T204PC = AC.HasTier("T20");
local T212PC, T214PC = AC.HasTier("T21");

local function ColdHeart()
    --actions.cold_heart=chains_of_ice,if=buff.cold_heart.stack=20&buff.unholy_strength.up&cooldown.pillar_of_frost.remains>6
    if S.ChainsOfIce:IsCastable() and Player:BuffStack(S.ColdHeartBuff) == 20 and Player:Buff(S.UnholyStrength) and S.PillarOfFrost:CooldownRemainsP() > 6 then
        return S.ChainsOfIce:ID()
    end
    --actions.cold_heart+=/chains_of_ice,if=buff.pillar_of_frost.up&buff.pillar_of_frost.remains<gcd&(buff.cold_heart.stack>=11|(buff.cold_heart.stack>=10&set_bonus.tier20_4pc))
    if S.ChainsOfIce:IsCastable() and Player:Buff(S.PillarOfFrost) and Player:BuffRemainsP(S.PillarOfFrost) < Player:GCD() and (Player:BuffStack(S.ColdHeartBuff) >= 11 or (Player:BuffStack(S.ColdHeartBuff) >= 10 and T204P)) then
        return S.ChainsOfIce:ID()
    end
    --actions.cold_heart+=/chains_of_ice,if=buff.cold_heart.stack>16&buff.unholy_strength.react&buff.unholy_strength.remains<gcd&cooldown.pillar_of_frost.remains>6
    if S.ChainsOfIce:IsCastable() and Player:BuffStack(S.ColdHeartBuff) > 16 and Player:Buff(S.UnholyStrength) and Player:BuffRemainsP(S.UnholyStrength) < Player:GCD() and S.PillarOfFrost:CooldownRemainsP() > 6 then
        return S.ChainsOfIce:ID()
    end
    --actions.cold_heart+=/chains_of_ice,if=buff.cold_heart.stack>12&buff.unholy_strength.react&talent.shattering_strikes.enabled
    if S.ChainsOfIce:IsCastable() and Player:BuffStack(S.ColdHeartBuff) > 12 and Player:Buff(S.UnholyStrength) and S.ShatteringStrikes:IsAvailable() then
        return S.ChainsOfIce:ID()
    end
    --actions.cold_heart+=/chains_of_ice,if=buff.cold_heart.stack>=4&target.time_to_die<=gcd
    if S.ChainsOfIce:IsCastable() and Player:BuffStack(S.ColdHeartBuff) >= 4 and Target:TimeToDie() <= Player:GCD() then
        return S.ChainsOfIce:ID()
    end
end

local function Cooldowns()
    --actions.cds=arcane_torrent,if=runic_power.deficit>=20&!talent.breath_of_sindragosa.enabled
    if RubimRH.CDsON() and  S.ArcaneTorrent:IsReady() and Player:RunicPowerDeficit() >= 20 and not S.BreathofSindragosa:IsAvailable() then
        return S.ArcaneTorrent:ID()
    end

    --actions.cooldowns+=/blood_fury,if=buff.pillar_of_frost.up
    if RubimRH.CDsON() and S.BloodFury:IsReady("Melee") and Player:Buff(S.PillarOfFrost) then
        return S.BloodFury
    end

    --actions.cooldowns+=/berserking,if=buff.pillar_of_frost.up
    if RubimRH.CDsON() and  S.Berserking:IsReady("Melee") and Player:Buff(S.PillarOfFrost) then
        return S.Berserking
    end

    --actions.cooldowns+=/use_items
    --actions.cooldowns+=/use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
    --actions.cooldowns+=/use_item,name=horn_of_valor,if=buff.pillar_of_frost.up&(!talent.breath_of_sindragosa.enabled|!cooldown.breath_of_sindragosa.remains)
    --actions.cooldowns+=/use_item,name=draught_of_souls,if=rune.time_to_5<3&(!dot.breath_of_sindragosa.ticking|runic_power>60)
    --actions.cooldowns+=/potion,if=buff.pillar_of_frost.up&(!talent.breath_of_sindragosa.enabled|dot.breath_of_sindragosa.ticking)

    --# Pillar of frost conditions
    -- pillar_of_frost,if=!talent.breath_of_sindragosa.enabled
    if RubimRH.config.Spells[4].isActive and S.PillarOfFrost:IsReady() and (not S.BreathofSindragosa:IsAvailable()) then
        return S.PillarOfFrost:ID()
    end
    -- pillar_of_frost,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.ready&runic_power>50
    if RubimRH.config.Spells[4].isActive and S.PillarOfFrost:IsReady() and (S.BreathofSindragosa:IsAvailable() and S.BreathofSindragosa:CooldownUpP() and Player:RunicPower() > 50) then
        return S.PillarOfFrost:ID()
    end
    -- pillar_of_frost,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>40
    if RubimRH.config.Spells[4].isActive and S.PillarOfFrost:IsReady() and (S.BreathofSindragosa:IsAvailable() and S.BreathofSindragosa:CooldownRemainsP() > 40) then
        return S.PillarOfFrost:ID()
    end
    --actions.cds+=/breath_of_sindragosa,if=buff.pillar_of_frost.up
    if RubimRH.config.Spells[2].isActive and S.BreathofSindragosa:IsReady() and Player:Buff(S.PillarOfFrost) then
        return S.BreathofSindragosa:ID()
    end
    --actions.cooldowns+=/call_action_list,name=cold_heart,if=equipped.cold_heart&((buff.cold_heart.stack>=10&!buff.obliteration.up&debuff.razorice.stack=5)|target.time_to_die<=gcd)
    if ColdHeart() ~= nil and S.ColdHeartTalent:IsAvailable() and ((Player:BuffStack(S.ColdHeartBuff) >= 10 and not Player:Buff(S.Obliteration) and Target:DebuffStack(S.RazorIce) == 5) or Target:TimeToDie() <= Player:GCD()) then
        return ColdHeart()
    end
end

local function Obliteration()
    --actions.obliteration=remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsReady() and S.GatheringStorm:IsAvailable() and Cache.EnemiesCount[8] >= 1 then
        return S.RemorselessWinter:ID()
    end
    --actions.obliteration+=/frostscythe,if=(buff.killing_machine.up&(buff.killing_machine.react|prev_gcd.1.frost_strike|prev_gcd.1.howling_blast))&spell_targets.frostscythe>1
    if S.FrostScythe:IsAvailable() and S.FrostScythe:IsReady() and (Player:Buff(S.KillingMachine) and (Player:Buff(S.KillingMachine) or Player:PrevGCD(1, S.FrostStrike) or Player:PrevGCD(1, S.HowlingBlast))) and Cache.EnemiesCount[8] > 1 then
        return S.FrostScythe:ID()
    end
    --actions.obliteration+=/obliterate,if=(buff.killing_machine.up&(buff.killing_machine.react|prev_gcd.1.frost_strike|prev_gcd.1.howling_blast))|(spell_targets.howling_blast>=3&!buff.rime.up&!talent.frostscythe.enabled)
    if S.Obliterate:IsReady("Melee") and ((Player:Buff(S.KillingMachine) and (Player:Buff(S.KillingMachine) or Player:PrevGCD(1, S.FrostStrike) or Player:PrevGCD(1, S.HowlingBlast))) or (Cache.EnemiesCount[10] >= 3 and not Player:Buff(S.Rime) and not S.FrostScythe:IsAvailable())) then
        return S.Obliterate:ID()
    end
    --actions.obliteration+=/howling_blast,if=buff.rime.up&spell_targets.howling_blast>1
    if S.HowlingBlast:IsReady() and Player:Buff(S.Rime) and Cache.EnemiesCount[10] > 1 then
        return S.HowlingBlast:ID()
    end
    --actions.obliteration+=/howling_blast,if=!buff.rime.up&spell_targets.howling_blast>2&rune>3&talent.freezing_fog.enabled&talent.gathering_storm.enabled
    if S.HowlingBlast:IsReady() and not Player:Buff(S.Rime) and Cache.EnemiesCount[10] > 2 and Player:Runes() > 3 and S.FreezingFog:IsAvailable() and S.GatheringStorm:IsAvailable() then
        return S.HowlingBlast:ID()
    end
    --actions.obliteration+=/frost_strike,if=!buff.rime.up|rune.time_to_1>=gcd|runic_power.deficit<20
    if S.FrostStrike:IsReady("Melee") and (not Player:Buff(S.Rime) or Player:RuneTimeToX(1) >= Player:GCD() or Player:RunicPowerDeficit() < 20) then
        return S.FrostStrike:ID()
    end
    --actions.obliteration+=/howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsReady() and Player:Buff(S.Rime) then
        return S.HowlingBlast:ID()
    end
    --actions.obliteration+=/obliterate
    if S.Obliterate:IsReady("Melee") then
        return S.Obliterate:ID()
    end
end

local function BoSPool()
    --actions.bos_pooling=remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastable() and S.GatheringStorm:IsAvailable() then
        return S.RemorselessWinter:ID()
    end
    --actions.bos_pooling+=/howling_blast,if=buff.rime.react&rune.time_to_4<(gcd*2)
    if S.HowlingBlast:IsCastable() and Player:Buff(S.Rime) and Player:RuneTimeToX(4) < (Player:GCD() * 2) then
        return S.HowlingBlast:ID()
    end
    --actions.bos_pooling+=/obliterate,if=rune.time_to_6<gcd&!talent.gathering_storm.enabled
    if S.Obliterate:IsCastable() and Player:RuneTimeToX(6) < Player:GCD() and not S.GatheringStorm:IsAvailable() then
        return S.Obliterate:ID()
    end
    --actions.bos_pooling+=/obliterate,if=rune.time_to_4<gcd&(cooldown.breath_of_sindragosa.remains|runic_power.deficit>=30)
    if S.Obliterate:IsCastable() and Player:RuneTimeToX(4) < Player:GCD() and (S.BreathofSindragosa:CooldownRemainsP() or Player:RunicPowerDeficit() >= 30) then
        return S.Obliterate:ID()
    end
    --actions.bos_pooling+=/frost_strike,if=runic_power>=95&set_bonus.tier19_4pc&cooldown.breath_of_sindragosa.remains&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
    if S.FrostStrike:IsReady("Melee") and Player:RunicPowerDeficit() < 5 and T194P and S.BreathofSindragosa:CooldownRemainsP() and (not S.ShatteringStrikes:IsAvailable() or Target:DebuffStack(S.RazorIce) < 5 or S.BreathofSindragosa:CooldownRemainsP() > 6) then
        return S.FrostStrike:ID()
    end
    --actions.bos_pooling+=/remorseless_winter,if=buff.rime.react&equipped.perseverance_of_the_ebon_martyr
    if S.RemorselessWinter:IsCastable() and Player:Buff(S.Rime) and I.PerseveranceOfTheEbonMartyre:IsEquipped() then
        return S.RemorselessWinter:ID()
    end
    --actions.bos_pooling+=/howling_blast,if=buff.rime.react&(buff.remorseless_winter.up|cooldown.remorseless_winter.remains>gcd|(!equipped.perseverance_of_the_ebon_martyr&!talent.gathering_storm.enabled))
    if S.HowlingBlast:IsCastable() and Player:Buff(S.Rime) and (Player:Buff(S.RemorselessWinter) or S.RemorselessWinter:CooldownRemainsP() > Player:GCD() or (not I.PerseveranceOfTheEbonMartyre:IsEquipped() and not S.GatheringStorm:IsAvailable())) then
        return S.HowlingBlast:ID()
    end
    --actions.bos_pooling+=/obliterate,if=!buff.rime.react&!(talent.gathering_storm.enabled&!(cooldown.remorseless_winter.remains>(gcd*2)|rune>4))&rune>3
    if S.Obliterate:IsCastable() and not Player:Buff(S.Rime) and not (S.GatheringStorm:IsAvailable() and not (S.RemorselessWinter:CooldownRemainsP() > (Player:GCD() * 2) or Player:Runes() > 4)) and Player:Runes() > 3 then
        return S.Obliterate:ID()
    end
    --actions.bos_pooling+=/sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.up&debuff.razorice.stack=5
    if RubimRH.config.Spells[3].isActive and S.FrostwyrmsFury:IsAvailable() and S.FrostwyrmsFury:IsCastable() and (I.ConsortsColdCore:IsEquipped() or Player:Buff(S.PillarOfFrost)) and Player:Buff(S.UnholyStrength) and Target:DebuffStack(S.RazorIce) == 5 then
        return S.FrostwyrmsFury:ID()
    end
    --actions.bos_pooling+=/frost_strike,if=runic_power.deficit<=30&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>rune.time_to_4)
    if S.FrostStrike:IsReady("Melee") and Player:RunicPowerDeficit() <= 30 and (not S.ShatteringStrikes:IsAvailable() or Target:DebuffStack(S.RazorIce) < 5 or S.BreathofSindragosa:CooldownRemainsP() > Player:RuneTimeToX(4)) then
        return S.FrostStrike:ID()
    end
    --actions.bos_pooling+=/frostscythe,if=buff.killing_machine.up&(!equipped.koltiras_newfound_will|spell_targets.FrostScythe>=2)
    if S.FrostScythe:IsAvailable() and S.FrostScythe:IsCastable() and Player:Buff(S.KillingMachine) and (not I.KoltirasNewfoundWill:IsEquipped() or Cache.EnemiesCount[8] >= 2) then
        return S.FrostScythe:ID()
    end
    --actions.bos_pooling+=/glacial_advance,if=spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsAvailable() and S.GlacialAdvance:IsCastable() and Cache.EnemiesCount[8] >= 2 then
        return S.GlacialAdvance:ID()
    end
    --actions.bos_pooling+=/remorseless_winter,if=spell_targets.remorseless_winter>=2
    if S.RemorselessWinter:IsCastable() and Cache.EnemiesCount[8] >= 2 then
        return S.RemorselessWinter:ID()
    end
    --actions.bos_pooling+=/frostscythe,if=spell_targets.frostscythe>=3
    if S.FrostScythe:IsAvailable() and S.FrostScythe:IsCastable() and Cache.EnemiesCount[8] >= 2 then
        return S.FrostScythe:ID()
    end
    --actions.bos_pooling+=/frost_strike,if=(cooldown.remorseless_winter.remains<(gcd*2)|buff.gathering_storm.stack=10)&cooldown.breath_of_sindragosa.remains>rune.time_to_4&talent.gathering_storm.enabled&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
    if S.FrostStrike:IsReady("Melee") and (S.RemorselessWinter:CooldownRemainsP() < (Player:GCD() * 2) or Player:BuffStack(S.GatheringStormBuff) == 10) and S.BreathofSindragosa:CooldownRemainsP() > Player:RuneTimeToX(4) and S.GatheringStorm:IsAvailable() and (not S.ShatteringStrikes:IsAvailable() or Target:DebuffStack(S.RazorIce) < 5 or S.BreathofSindragosa:CooldownRemainsP() > 6) then
        return S.FrostStrike:ID()
    end
    --actions.bos_pooling+=/obliterate,if=!buff.rime.react&(!talent.gathering_storm.enabled|cooldown.remorseless_winter.remains>gcd)
    if S.Obliterate:IsCastable() and not Player:Buff(S.Rime) and (not S.GatheringStorm:IsAvailable() or S.RemorselessWinter:CooldownRemainsP() > Player:GCD()) then
        return S.Obliterate:ID()
    end
    --actions.bos_pooling+=/frost_strike,if=cooldown.breath_of_sindragosa.remains>rune.time_to_4&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
    if S.FrostStrike:IsReady("Melee") and S.BreathofSindragosa:CooldownRemainsP() > Player:RuneTimeToX(4) and (not S.ShatteringStrikes:IsAvailable() or Target:DebuffStack(S.RazorIce) < 5 or S.BreathofSindragosa:CooldownRemainsP() > 6) then
        return S.FrostStrike:ID()
    end
end

local function BoSTick()
    --actions.bos_ticking=frost_strike,if=talent.shattering_strikes.enabled&runic_power<40&rune.time_to_2>2&cooldown.empower_rune_weapon.remains&debuff.razorice.stack=5&(cooldown.horn_of_winter.remains|!talent.horn_of_winter.enabled)
    if S.FrostStrike:IsReady("Melee") and S.ShatteringStrikes:IsAvailable() and Player:RunicPower() < 40 and Player:RuneTimeToX(2) > 2 and S.EmpowerRuneWeapon:CooldownRemainsP() and Target:DebuffStack(S.RazorIce) == 5 and (S.HornOfWinter:CooldownRemainsP() or not S.HornOfWinter:IsAvailable()) then
        return S.FrostStrike:ID()
    end
    --actions.bos_ticking+=/remorseless_winter,if=(runic_power>=30|buff.hungering_rune_weapon.up)&((buff.rime.react&equipped.perseverance_of_the_ebon_martyr)|(talent.gathering_storm.enabled&(buff.remorseless_winter.remains<=gcd|!buff.remorseless_winter.remains)))
    if S.RemorselessWinter:IsCastable() and (Player:RunicPower() >= 30 or Player:Buff(S.EmpowerRuneWeapon)) and ((Player:Buff(S.Rime) and I.PerseveranceOfTheEbonMartyre:IsEquipped()) or (S.GatheringStorm:IsAvailable() and (Player:BuffRemainsP(S.RemorselessWinter) <= Player:GCD() or not Player:BuffRemainsP(S.RemorselessWinter)))) then
        return S.RemorselessWinter:ID()
    end
    --actions.bos_ticking+=/howling_blast,if=((runic_power>=20&set_bonus.tier19_4pc)|runic_power>=30|buff.hungering_rune_weapon.up)&buff.rime.react
    if S.HowlingBlast:IsCastable() and ((Player:RunicPower() >= 20 and T192P) or Player:RunicPower() >= 30 or Player:Buff(S.EmpowerRuneWeapon)) and Player:Buff(S.Rime) then
        return S.HowlingBlast:ID()
    end
    --actions.bos_ticking+=/frost_strike,if=set_bonus.tier20_2pc&runic_power.deficit<=15&rune<=3&buff.pillar_of_frost.up&!talent.shattering_strikes.enabled
    if S.FrostStrike:IsReady("Melee") and T202P and Player:RunicPowerDeficit() <= 15 and Player:Runes() <= 3 and Player:Buff(S.PillarOfFrost) and not S.ShatteringStrikes:IsAvailable() then
        return S.FrostStrike:ID()
    end
    --actions.bos_ticking+=/obliterate,if=runic_power<=45|rune.time_to_5<gcd|buff.hungering_rune_weapon.remains>=2
    if S.Obliterate:IsCastable() and (Player:RunicPower() <= 45 or Player:RuneTimeToX(5) < Player:GCD() or Player:BuffRemainsP(S.EmpowerRuneWeapon) >= 2) then
        return S.Obliterate:ID()
    end
    --actions.bos_ticking+=/sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.up&debuff.razorice.stack=5
    if RubimRH.config.Spells[3].isActive and S.FrostwyrmsFury:IsAvailable() and S.FrostwyrmsFury:IsCastable() and (I.ConsortsColdCore:IsEquipped() or Player:Buff(S.PillarOfFrost)) and Player:Buff(S.UnholyStrength) and Target:DebuffStack(S.RazorIce) == 5 then
        return S.FrostwyrmsFury:ID()
    end
    --actions.bos_ticking+=/horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
    if S.HornOfWinter:IsCastable() and Player:RunicPowerDeficit() >= 30 and Player:RuneTimeToX(3) > Player:GCD() then
        return S.HornOfWinter:ID()
    end
    --actions.bos_ticking+=/frostscythe,if=buff.killing_machine.up&(!equipped.koltiras_newfound_will|talent.gathering_storm.enabled|spell_targets.FrostScythe>=2)
    if FrostScythe:IsAvailable() and S.FrostScythe:IsCastable() and Player:Buff(S.KillingMachine) and (not I.KoltirasNewfoundWill:IsEquipped() or S.GatheringStorm:IsAvailable() or Cache.EnemiesCount[8] >= 2) then
        return S.FrostScythe:ID()
    end
    --actions.bos_ticking+=/glacial_advance,if=spell_targets.remorseless_winter>=2
    if S.GlacialAdvance:IsAvailable() and S.GlacialAdvance:IsCastable() and Cache.EnemiesCount[8] >= 2 then
        return S.GlacialAdvance:ID()
    end
    --actions.bos_ticking+=/remorseless_winter,if=spell_targets.remorseless_winter>=2
    if S.RemorselessWinter:IsCastable() and Cache.EnemiesCount[8] >= 2 then
        return S.RemorselessWinter:ID()
    end
    --actions.bos_ticking+=/obliterate,if=runic_power>25|rune>3
    if S.Obliterate:IsCastable() and (Player:RunicPowerDeficit() > 25 or Player:Runes() > 3) then
        return S.Obliterate:ID()
    end
    --actions.bos_ticking+=/empower_rune_weapon,if=runic_power<30&rune.time_to_2>gcd
    if S.EmpowerRuneWeapon:IsCastable() and Player:RunicPower() < 30 and Player:RuneTimeToX(2) > Player:GCD() then
        return S.EmpowerRuneWeapon:ID()
    end
end

local function Standard()
    if S.FrostStrike:IsReady("Melee") and S.IcyTalons:IsAvailable() and Player:BuffRemains(S.IcyTalonsBuff) <= Player:GCD() then
        return S.FrostStrike:ID()
    end
    --actions.standard+=/frost_strike,if=talent.shattering_strikes.enabled&debuff.razorice.stack=5&buff.gathering_storm.stack<2&!buff.rime.up
    if S.FrostStrike:IsReady("Melee") and S.ShatteringStrikes:IsAvailable() and Target:DebuffStack(S.RazorIce) == 5 and Player:BuffStack(S.GatheringStormBuff) < 2 and not Player:Buff(S.Rime) then
        return S.FrostStrike:ID()
    end
    --actions.standard+=/remorseless_winter,if=(buff.rime.react&equipped.perseverance_of_the_ebon_martyr)|talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastable() and (Player:Buff(S.Rime) and I.PerseveranceOfTheEbonMartyre:IsEquipped() or (S.GatheringStorm:IsAvailable() and Cache.EnemiesCount[8] >= 1)) then
        return S.RemorselessWinter:ID()
    end
    --actions.standard+=/obliterate,if=(equipped.koltiras_newfound_will&talent.frozen_pulse.enabled&set_bonus.tier19_2pc=1)
    if S.Obliterate:IsCastable("Melee") and ((I.KoltirasNewfoundWill:IsEquipped() and S.FrozenPulse:IsAvailable() and T192)) then
        return S.Obliterate:ID()
    end
    --actions.standard+=/frost_strike,if=(!talent.shattering_strikes.enabled|debuff.razorice.stack<5)&runic_power.deficit<10
    if S.FrostStrike:IsReady("Melee") and (not S.ShatteringStrikes:IsAvailable() or Target:DebuffStack(S.RazorIce) < 5) and Player:RunicPowerDeficit() < 10 then
        return S.FrostStrike:ID()
    end
    --actions.standard+=/howling_blast,if=buff.rime.react
    if S.HowlingBlast:IsCastable() and Player:Buff(S.Rime) then
        return S.HowlingBlast:ID()
    end
    --actions.standard+=/obliterate,if=(equipped.koltiras_newfound_will&talent.frozen_pulse.enabled&set_bonus.tier19_2pc=1)|rune.time_to_5<gcd
    if S.Obliterate:IsCastable("Melee") and ((I.KoltirasNewfoundWill:IsEquipped() and S.FrozenPulse:IsAvailable() and T192) or Player:RuneTimeToX(5) < Player:GCD()) then
        return S.Obliterate:ID()
    end
    --actions.standard+=/frost_strike,if=runic_power.deficit<10&!buff.hungering_rune_weapon.up
    if S.FrostStrike:IsReady("Melee") and Player:RunicPowerDeficit() < 10 then
        return S.FrostStrike:ID()
    end
    --actions.standard+=/frostscythe,if=buff.killing_machine.up&(!equipped.koltiras_newfound_will|spell_targets.frostscythe>=2)
    if S.FrostScythe:IsAvailable() and S.FrostScythe:IsCastable() and Player:Buff(S.KillingMachine) and (not I.KoltirasNewfoundWill:IsEquipped() or Cache.EnemiesCount[8] >= 2) then
        return S.FrostScythe:ID()
    end
    --actions.standard+=/obliterate,if=buff.killing_machine.react
    if S.Obliterate:IsCastable("Melee") and Player:Buff(S.KillingMachine) then
        return S.Obliterate:ID()
    end
    --actions.standard+=/frost_strike,if=runic_power.deficit<20
    if S.FrostStrike:IsReady("Melee") and Player:RunicPowerDeficit() < 20 then
        return S.FrostScythe:ID()
    end
    --actions.standard+=/remorseless_winter,if=spell_targets.remorseless_winter>=2
    if S.RemorselessWinter:IsCastable() and Cache.EnemiesCount[8] >= 2 then
        return S.RemorselessWinter:ID()
    end
    --actions.standard+=/glacial_advance,if=spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsAvailable() and S.GlacialAdvance:IsCastable() and Cache.EnemiesCount[8] >= 2 then
        return S.GlacialAdvance:ID()
    end
    --actions.standard+=/frostscythe,if=spell_targets.frostscythe>=3
    if S.FrostScythe:IsAvailable() and S.FrostScythe:IsCastable() and Cache.EnemiesCount[8] >= 3 then
        return S.FrostScythe:ID()
    end
    --actions.standard+=/obliterate
    if S.Obliterate:IsCastable("Melee") then
        return S.Obliterate:ID()
    end
    --actions.standard+=/horn_of_winter,if=!buff.hungering_rune_weapon.up&(rune.time_to_2>gcd|!talent.frozen_pulse.enabled)
    if S.HornOfWinter:IsAvailable() and S.HornOfWinter:IsCastable() and (Player:RuneTimeToX(2) > Player:GCD() or not S.FrozenPulse:IsAvailable()) then
        return S.HornOfWinter:ID()
    end
    --actions.standard+=/frost_strike,if=!(runic_power<50&talent.obliteration.enabled&cooldown.obliteration.remains<=gcd)
    if S.FrostStrike:IsReady("Melee") and not (Player:RunicPower() < 50 and S.Obliteration:IsAvailable() and S.Obliteration:CooldownRemains() <= Player:GCD()) then
        return S.FrostSrike:ID()
    end
    --actions.standard+=/empower_rune_weapon,if=!talent.breath_of_sindragosa.enabled|target.time_to_die<cooldown.breath_of_sindragosa.remains
    if RubimRH.CDsON() and Target:IsInRange("Melee") and S.EmpowerRuneWeapon:IsCastable() and (S.EmpowerRuneWeapon:Charges() >= 1 and not S.BreathofSindragosa:IsAvailable() or Target:TimeToDie() < S.BreathofSindragosa:CooldownRemains()) then
        return S.EmpowerRuneWeapon:ID()
    end
end

local function APL()
    if not Player:AffectingCombat() then
        return 0, 462338
    end
    AC.GetEnemies("Melee");
    AC.GetEnemies(8, true);
    AC.GetEnemies(10, true);

    if Target:IsInRange(30) and not Target:Debuff(S.FrostFever) then
        return S.HowlingBlast:ID()
    end

    if RubimRH.config.Spells[1].isActive and Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile.DeathKnight.Frost.deathstrike then
        S.DeathStrike:Queue()
        return S.DeathStrike:ID()
    end

    if RubimRH.config.Spells[1].isActive and Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 95 and Player:BuffRemains(S.DarkSuccor) <= 2 then
        S.DeathStrike:Queue()
        return S.DeathStrike:ID()
    end

    --actions+=/call_action_list,name=cooldowns
    if Cooldowns() ~= nil then
        return Cooldowns()
    end

    --actions+=/run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<15
    if RubimRH.config.Spells[2].isActive and S.BreathofSindragosa:IsAvailable() and S.BreathofSindragosa:CooldownRemains() < 15 then
        if BoSPool() ~= nil then
            return BoSPool()
        end
    end

    --actions+=/run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
    if Player:Buff(S.BreathofSindragosa) then
        if BoSTick() ~= nil then
            return BoSTick()
        end
    end

    --actions+=/run_action_list,name=obliteration,if=buff.pillar_of_frost.up&talent.obliteration.enabled
    if Player:Buff(S.PillarOfFrost) and S.Obliteration:IsAvailable() then
        if Obliteration() ~= nil then
            return Obliteration()
        end
    end

    --actions+=/call_action_list,name=standard
    if Standard() ~= nil then
        return Standard()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(251, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(251, PASSIVE);

