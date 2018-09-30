--- ============================ HEADER ============================
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

RubimRH.Spell[251] = {
    -- Racials
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    GiftoftheNaaru = Spell(59547),

    -- Utility
    ControlUndead = Spell(45524),
    DeathGrip = Spell(49576),
    MindFreeze = Spell(47528),
    PathOfFrost = Spell(3714),
    WraithWalk = Spell(212552),
    ChillStreak = Spell(204160),

    -- Defensive
    AntiMagicShell = Spell(48707),
    DeathStrike = Spell(49998),
    IceboundFortitude = Spell(48792),
    DarkSuccor = Spell(101568),

    -- Everything
    RemorselessWinter = Spell(196770),
    GatheringStorm = Spell(194912),
    GlacialAdvance = Spell(194913),
    Frostscythe = Spell(207230),
    FrostStrike = Spell(49143),
    HowlingBlast = Spell(49184),
    RimeBuff = Spell(59052),
    KillingMachineBuff = Spell(51124),
    RunicAttenuation = Spell(207104),
    Obliterate = Spell(49020),
    HornofWinter = Spell(57330),
    ArcaneTorrent = Spell(50613),
    PillarofFrost = Spell(51271),
    ChainsofIce = Spell(45524),
    ColdHeartItemBuff = Spell(235599),
    ColdHeartTalentBuff = Spell(281209),
    FrostwyrmsFury = Spell(279302),
    BreathofSindragosa = Spell(152279),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    EmpowerRuneWeapon = Spell(47568),
    ColdHeart = Spell(281208),
    RazoriceDebuff = Spell(51714),
    FrozenPulse = Spell(194909),
    MindFreeze = Spell(47528),
    FrostFeverDebuff = Spell(55095),
    IcyTalonsBuff = Spell(194879),
    BreathofSindragosaDebuff = Spell(155166),
    Obliteration = Spell(281238),
    DeathGrip = Spell(49576),
    DeathsAdvance = Spell(48265),
    DeathPact = Spell(48743),
}

local S = RubimRH.Spell[251]

if not Item.DeathKnight then
    Item.DeathKnight = { }
end
Item.DeathKnight.Frost = {
    ProlongedPower = Item(142117),
    HornofValor = Item(133642),
    ColdHeart = Item(151796)
}

local I = Item.DeathKnight.Frost;
local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

local EnemyRanges = { "Melee", 8, 10, 30 }
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

local function Precombat()

end

local function Aoe()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsReady() and (S.GatheringStorm:IsAvailable()) then
        return S.RemorselessWinter:Cast()
    end
    -- glacial_advance,if=talent.frostscythe.enabled
    if S.GlacialAdvance:IsReady() and (S.Frostscythe:IsAvailable()) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsReady() and (S.RemorselessWinter:CooldownRemains() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
        return S.FrostStrike:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsReady(30) and (Player:BuffP(S.RimeBuff)) then
        return S.HowlingBlast:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up
    if S.Frostscythe:IsReady() and Cache.EnemiesCount["Melee"] >= 1 and (Player:BuffP(S.KillingMachineBuff)) then
        return S.Frostscythe:Cast()
    end
    -- glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.GlacialAdvance:IsReady() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.FrostStrike:IsReady() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
        return S.FrostStrike:Cast()
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsReady() then
        return S.RemorselessWinter:Cast()
    end
    -- frostscythe
    if S.Frostscythe:IsReady() and Cache.EnemiesCount["Melee"] >= 1 then
        return S.Frostscythe:Cast()
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsReady() and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
        return S.Obliterate:Cast()
    end
    -- glacial_advance
    if S.GlacialAdvance:IsReady() then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike
    if S.FrostStrike:IsReady() then
        return S.FrostStrike:Cast()
    end
    -- horn_of_winter
    if S.HornofWinter:IsReady() then
        return S.HornofWinter:Cast()
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsReady() then
        return S.ArcaneTorrent:Cast()
    end
    return 0, 135328
end

local function BosPooling()
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsReady(30) and (Player:BuffP(S.RimeBuff)) then
        return S.HowlingBlast:Cast()
    end
    -- obliterate,if=rune.time_to_4<gcd&runic_power.deficit>=25
    if S.Obliterate:IsReady() and (Player:RuneTimeToX(4) < Player:GCD() and Player:RunicPowerDeficit() >= 25) then
        return S.Obliterate:Cast()
    end
    -- glacial_advance,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4
    if S.GlacialAdvance:IsReady() and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemains() > Player:RuneTimeToX(4)) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4
    if S.FrostStrike:IsReady() and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemains() > Player:RuneTimeToX(4)) then
        return S.FrostStrike:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up&runic_power.deficit>(15+talent.runic_attenuation.enabled*3)
    if S.Frostscythe:IsReady() and Cache.EnemiesCount["Melee"] >= 1 and (Player:BuffP(S.KillingMachineBuff) and Player:RunicPowerDeficit() > (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
        return S.Frostscythe:Cast()
    end
    -- obliterate,if=runic_power.deficit>=(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsReady() and (Player:RunicPowerDeficit() >= (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
        return S.Obliterate:Cast()
    end
    -- glacial_advance,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsReady() and (S.PillarofFrost:CooldownRemains() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and Cache.EnemiesCount[30] >= 2) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40
    if S.FrostStrike:IsReady() and (S.PillarofFrost:CooldownRemains() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40) then
        return S.FrostStrike:Cast()
    end
    return 0, 135328
end

local function BosTicking()
    -- obliterate,if=runic_power<=30
    if S.Obliterate:IsReady() and (Player:RunicPower() <= 30) then
        return S.Obliterate:Cast()
    end
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsReady() and (S.GatheringStorm:IsAvailable()) then
        return S.RemorselessWinter:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsReady(30) and (Player:BuffP(S.RimeBuff)) then
        return S.HowlingBlast:Cast()
    end
    -- obliterate,if=rune.time_to_5<gcd|runic_power<=45
    if S.Obliterate:IsReady() and (Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45) then
        return S.Obliterate:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up
    if S.Frostscythe:IsReady() and Cache.EnemiesCount["Melee"] >= 1 and (Player:BuffP(S.KillingMachineBuff)) then
        return S.Frostscythe:Cast()
    end
    -- horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
    if S.HornofWinter:IsReady() and (Player:RunicPowerDeficit() >= 30 and Player:RuneTimeToX(3) > Player:GCD()) then
        return S.HornofWinter:Cast()
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsReady() then
        return S.RemorselessWinter:Cast()
    end
    -- frostscythe,if=spell_targets.frostscythe>=2
    if S.Frostscythe:IsReady() and Cache.EnemiesCount["Melee"] >= 1 and (Cache.EnemiesCount[8] >= 2) then
        return S.Frostscythe:Cast()
    end
    -- obliterate,if=runic_power.deficit>25|rune>3
    if S.Obliterate:IsReady() and (Player:RunicPowerDeficit() > 25 or Player:Runes() > 3) then
        return S.Obliterate:Cast()
    end
    -- arcane_torrent,if=runic_power.deficit>20
    if S.ArcaneTorrent:IsReady() and (Player:RunicPowerDeficit() > 20) then
        return S.ArcaneTorrent:Cast()
    end
    return 0, 135328
end

local function ColdHeart()
    --actions.cold_heart=chains_of_ice,if=buff.cold_heart.stack>5&target.time_to_die<gcd
    if S.ChainsofIce:IsReady() and ((Player:BuffStackP(S.ColdHeartItemBuff) > 5 or Player:BuffStackP(S.ColdHeartTalentBuff) > 5) and Target:TimeToDie() < Player:GCD()) then
        return S.ChainsofIce:Cast()
    end
    --actions.cold_heart+=/chains_of_ice,if=(buff.pillar_of_frost.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.pillar_of_frost.remains<rune.time_to_3)&buff.pillar_of_frost.up
    if S.ChainsofIce:IsReady() and ((Player:BuffRemainsP(S.PillarofFrost) <= Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) or Player:BuffRemainsP(S.PillarofFrost) < Player:RuneTimeToX(3)) and Player:BuffP(S.PillarofFrost)) then
        return S.ChainsofIce:Cast()
    end
end

local function Cooldowns()
    -- use_items
    -- use_item,name=horn_of_valor,if=buff.pillar_of_frost.up&(!talent.breath_of_sindragosa.enabled|!cooldown.breath_of_sindragosa.remains)
    -- potion,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    -- if I.ProlongedPower:IsReady() and RubimRH.PotionON() and (Player:BuffP(S.PillarofFrost) and Player:BuffP(S.EmpowerRuneWeapon)) then
    --return I.ProlongedPower:Cast()
    --end
    -- blood_fury,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if RubimRH.CDsON() and S.BloodFury:IsReady() and (Player:BuffP(S.PillarofFrost) and Player:BuffP(S.EmpowerRuneWeapon)) then
        return S.BloodFury:Cast()
    end
    -- berserking,if=buff.pillar_of_frost.up
    if RubimRH.CDsON() and S.Berserking:IsReady() and (Player:BuffP(S.PillarofFrost)) then
        return S.Berserking:Cast()
    end
    -- pillar_of_frost,if=cooldown.empower_rune_weapon.remains
    if S.PillarofFrost:IsCastable() and (bool(S.EmpowerRuneWeapon:CooldownRemains())) then
        return S.PillarofFrost:Cast()
    end
    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&!talent.breath_of_sindragosa.enabled&rune.time_to_5>gcd&runic_power.deficit>=10
    if RubimRH.CDsON() and S.EmpowerRuneWeapon:IsCastable() and (S.PillarofFrost:CooldownUpP() and (not S.BreathofSindragosa:IsAvailable() or not RubimRH.config.Spells[2].isActive) and Player:RuneTimeToX(5) > Player:GCD() and Player:RunicPowerDeficit() >= 10) then
        return S.EmpowerRuneWeapon:Cast()
    end
    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&talent.breath_of_sindragosa.enabled&rune>=3&runic_power>60
    if RubimRH.CDsON() and S.EmpowerRuneWeapon:IsCastable() and (S.PillarofFrost:CooldownUpP() and (S.BreathofSindragosa:IsAvailable() or not RubimRH.config.Spells[2].isActive) and Player:Runes() >= 3 and Player:RunicPower() > 60) then
        return S.EmpowerRuneWeapon:Cast()
    end
    -- call_action_list,name=cold_heart,if=(equipped.cold_heart|talent.cold_heart.enabled)&(((buff.cold_heart_item.stack>=10|buff.cold_heart_talent.stack>=10)&debuff.razorice.stack=5)|target.time_to_die<=gcd)
    if ((I.ColdHeart:IsEquipped() or S.ColdHeart:IsAvailable()) and (((Player:BuffStackP(S.ColdHeartItemBuff) >= 10 or Player:BuffStackP(S.ColdHeartTalentBuff) >= 10) and Target:DebuffStackP(S.RazoriceDebuff) == 5) or Target:TimeToDie() <= Player:GCD())) then
        if ColdHeart() ~= nil then
            return ColdHeart()
        end
    end
    -- frostwyrms_fury,if=(buff.pillar_of_frost.remains<=gcd&buff.pillar_of_frost.up)
    if RubimRH.CDsON() and S.FrostwyrmsFury:IsReady() and RubimRH.config.Spells[3].isActive and ((Player:BuffRemainsP(S.PillarofFrost) <= Player:GCD() and Player:BuffP(S.PillarofFrost))) then
        return S.FrostwyrmsFury:Cast()
    end
end

local function Obliteration()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsReady() and Cache.EnemiesCount[8] >= 1 and (S.GatheringStorm:IsAvailable()) then
        return S.RemorselessWinter:Cast()
    end
    -- obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsReady() and (not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 3) then
        return S.Obliterate:Cast()
    end
    -- frostscythe,if=(buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance)))&(rune.time_to_4>gcd|spell_targets.frostscythe>=2)
    if S.Frostscythe:IsReady() and Cache.EnemiesCount["Melee"] >= 1 and ((bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) and (Player:RuneTimeToX(4) > Player:GCD() or Cache.EnemiesCount[8] >= 2)) then
        return S.Frostscythe:Cast()
    end
    -- obliterate,if=buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsReady() and (bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then
        return S.Obliterate:Cast()
    end
    -- glacial_advance,if=(!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd)&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsReady() and ((not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) and Cache.EnemiesCount[30] >= 2) then
        return S.GlacialAdvance:Cast()
    end
    -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
    if S.HowlingBlast:IsReady(30) and (Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 2) then
        return S.HowlingBlast:Cast()
    end
    -- frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
    if S.FrostStrike:IsReady() and (not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) then
        return S.FrostStrike:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsReady(30) and (Player:BuffP(S.RimeBuff)) then
        return S.HowlingBlast:Cast()
    end
    -- obliterate
    if S.Obliterate:IsReady() then
        return S.Obliterate:Cast()
    end
    return 0, 135328
end

local function Standard()
    -- remorseless_winter
    if S.RemorselessWinter:IsReady() and Cache.EnemiesCount[8] >= 1 then
        return S.RemorselessWinter:Cast()
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsReady() and (S.RemorselessWinter:CooldownRemains() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
        return S.FrostStrike:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsReady(30) and (Player:BuffP(S.RimeBuff)) then
        return S.HowlingBlast:Cast()
    end
    -- obliterate,if=!buff.frozen_pulse.up&talent.frozen_pulse.enabled
    if S.Obliterate:IsReady() and (not Player:BuffP(S.FrozenPulse) and S.FrozenPulse:IsAvailable()) then
        return S.Obliterate:Cast()
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.FrostStrike:IsReady() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
        return S.FrostStrike:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up&rune.time_to_4>=gcd
    if S.Frostscythe:IsReady() and Cache.EnemiesCount["Melee"] >= 1 and (Player:BuffP(S.KillingMachineBuff) and Player:RuneTimeToX(4) >= Player:GCD()) then
        return S.Frostscythe:Cast()
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsReady() and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
        return S.Obliterate:Cast()
    end
    -- frost_strike
    if S.FrostStrike:IsReady() then
        return S.FrostStrike:Cast()
    end
    -- horn_of_winter
    if S.HornofWinter:IsReady() then
        return S.HornofWinter:Cast()
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsReady() then
        return S.ArcaneTorrent:Cast()
    end
end

local function APL()
    UpdateRanges()
    --Mov Speed
    if Player:MovingFor() >= 1 and S.DeathsAdvance:IsReadyMorph() then
        return S.DeathsAdvance:Cast()
    end

    if not Player:AffectingCombat() and not Target:IsQuestMob() then
        return 0, 462338
    end

    if QueueSkill() ~= nil then
        if RubimRH.QueuedSpell():ID() == S.BreathofSindragosa:ID() then
            if Player:Buff(S.EmpowerRuneWeapon) and Player:Buff(S.PillarofFrost) then
                return QueueSkill()
            end
        else
            return QueueSkill()
        end
    end

    if Target:MinDistanceToPlayer(true) >= 15 and Target:MinDistanceToPlayer(true) <= 40 and S.DeathGrip:IsReady() and Target:IsQuestMob() then
        return S.DeathGrip:Cast()
    end

    --CUSTOM
    if Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[251].sk1 then
        return S.DeathStrike:Cast()
    end

    if Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 95 and Player:BuffRemains(S.DarkSuccor) <= 2 then
        return S.DeathStrike:Cast()
    end

    if S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[251].sk2 then
        if S.DeathStrike:IsUsable() then
            return S.DeathStrike:Cast()
        else
            S.DeathStrike:Queue()
            return 0, 135328
        end
    end

    if S.DeathPact:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[251].sk4 then
        return S.DeathPact:Cast()
    end

    --END OF CUSTOM
    if S.MindFreeze:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.MindFreeze:Cast()
    end
    -- howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.HowlingBlast:IsReady(30) and (not Target:DebuffP(S.FrostFeverDebuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemains() > 15 or not RubimRH.config.Spells[2].isActive)) then
        return S.HowlingBlast:Cast()
    end
    -- glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.GlacialAdvance:IsReady() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and Cache.EnemiesCount[30] >= 2 and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemains() > 15 or not RubimRH.config.Spells[2].isActive)) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.FrostStrike:IsReady() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemains() > 15 or not RubimRH.config.Spells[2].isActive)) then
        return S.FrostStrike:Cast()
    end
    -- breath_of_sindragosa,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
    if RubimRH.CDsON() and S.BreathofSindragosa:IsCastable() and RubimRH.config.Spells[2].isActive and (bool(S.EmpowerRuneWeapon:CooldownRemains()) and bool(S.PillarofFrost:CooldownRemains())) then
        return S.BreathofSindragosa:Cast()
    end
    -- call_action_list,name=cooldowns
    if Cooldowns() ~= nil then
        return Cooldowns()
    end
    -- run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<5
    if (S.BreathofSindragosa:IsAvailable() and S.BreathofSindragosa:CooldownRemains() < 5 and RubimRH.config.Spells[2].isActive) and RubimRH.CDsON() then
        return BosPooling()
    end
    -- run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
    if (Player:Buff(S.BreathofSindragosa)) then
        return BosTicking()
    end
    -- run_action_list,name=obliteration,if=buff.pillar_of_frost.up&talent.obliteration.enabled
    if (Player:BuffP(S.PillarofFrost) and S.Obliteration:IsAvailable()) then
        return Obliteration();
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if (Cache.EnemiesCount[10] >= 2) then
       return Aoe();
    end
    -- call_action_list,name=standard
    if Standard() ~= nil then
       return Standard()
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(251, APL)
local function PASSIVE()
    if S.IceboundFortitude:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[251].sk2 then
        return S.IceboundFortitude:Cast()
    end
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(251, PASSIVE)
