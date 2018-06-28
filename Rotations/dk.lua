--
-- Created by IntelliJ IDEA.
-- User: Rubim
-- Date: 05/04/2018
-- Time: 02:05
-- To change this template use File | Settings | File Templates.
--

if select(3, UnitClass("player")) == 6 then
    --- CUSTOM CONFIG--
    --- Frost/Unholy
    local RubimRH.useCDs = false --Long CDs
    local bossOnly = true --Check if target is a BOSS to use long CDs
    local hotkey = false --Use if holding CTRL + SHIFT

    --- Blood
    local drw = false
    local bonestorm = true
    local taunt = false
    local dnd = true --This should always be true.

    --- ============================ HEADER ============================
    local addonName, addonTable = ...;
    -- AethysCore3
    if AethysCore == nil then
        print("ERROR: Aethyhs Core is missing. Please download it.")
    end
    if AethysCache == nil then
        print("ERROR: Aethyhs Cache is missing. Please download it.")
    end
    local AC = AethysCore;
    local Cache = AethysCache;
    local Unit = AC.Unit;
    local Player = Unit.Player;
    local Target = Unit.Target;
    local Spell = AC.Spell;
    local Item = AC.Item;

    --- Checking what to Cast
    local nextAbility
    local function getNextAbility()
        return nextAbility
    end

    local function setNextAbility(skill)
        nextAbility = skill
    end

    --- -
    function mainRotation()
        if UnitAffectingCombat("player") == false or UnitCanAttack("player", "target") == false then
            return "No Combat/Target"
        end
        if GetSpecialization() == 1 then
            bloodRotation()
            --Frost
        elseif GetSpecialization() == 2 then
            frostRotation()
        end
        return getNextAbility()
    end

    if not Spell.DeathKnight then Spell.DeathKnight = {};
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
        HungeringRuneWeapon = Spell(207127),
        IcyTalons = Spell(194878),
        IcyTalonsBuff = Spell(194879),
        MurderousEfficiency = Spell(207061),
        Obliteration = Spell(207256),
        RunicAttenuation = Spell(207104),
        ShatteringStrikes = Spell(207057),
        Icecap = Spell(207126),
        -- Artifact
        SindragosasFury = Spell(190778),
        -- Defensive
        AntiMagicShell = Spell(48707),
        DeathStrike = Spell(49998),
        IceboundFortitude = Spell(48792),
        -- Utility
        ControlUndead = Spell(45524),
        DeathGrip = Spell(49576),
        MindFreeze = Spell(47528),
        PathOfFrost = Spell(3714),
        WraithWalk = Spell(212552),
        -- Legendaries
        ChilledHearth = Spell(235599),
        ConsortsColdCore = Spell(235605),
        KiljaedensBurningWish = Spell(144259),
        KoltirasNewfoundWill = Spell(208782),
        PerseveranceOfTheEbonMartyre = Spell(216059),
        SealOfNecrofantasia = Spell(212216),
        ToravonsWhiteoutBindings = Spell(205628),

        -- Misc
        PoolRange = Spell(9999000010)
        -- Macros
    };

    Spell.DeathKnight.Blood = {
        -- Racials
        ArcaneTorrent = Spell(50613),
        Berserking = Spell(26297),
        BloodFury = Spell(20572),
        -- Abilities
        BloodBoil = Spell(50842),
        Blooddrinker = Spell(206931),
        BloodMirror = Spell(206977),
        BloodPlague = Spell(55078),
        BloodShield = Spell(77535),
        BoneShield = Spell(195181),
        Bonestorm = Spell(194844),
        Consumption = Spell(205223),
        CrimsonScourge = Spell(81141),
        DancingRuneWeapon = Spell(49028),
        DancingRuneWeaponBuff = Spell(81256),
        DeathandDecay = Spell(43265),
        DeathsCaress = Spell(195292),
        DeathStrike = Spell(49998),
        HeartBreaker = Spell(221536),
        HeartStrike = Spell(206930),
        Marrowrend = Spell(195182),
        MindFreeze = Spell(47528),
        Ossuary = Spell(219786),
        RapidDecomposition = Spell(194662),
        RuneTap = Spell(194679),
        UmbilicusEternus = Spell(193249),
        VampiricBlood = Spell(55233),
        -- Legendaries
        HaemostasisBuff = Spell(235558),
        -- Misc
        Pool = Spell(9999000010)
    };

    -- Items
    if not Item.DeathKnight then Item.DeathKnight = {};
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

    Item.DeathKnight.Blood = {
        --Legendaries
        --Potion
        ProlongedPower = Item(142117)
    };

    local SpellFrost = Spell.DeathKnight.Frost;
    local ItemFrost = Item.DeathKnight.Frost;
    local SpellBlood = Spell.DeathKnight.Blood;
    local ItemBlood = Item.DeathKnight.Blood;
    -- Rotation Var
    local T192P, T194P = false
    local T202P, T204P = false
    local T212P, T214P = false

    function CooldownsCheck()
        if Target:Exists() == false or Player:AffectingCombat() == false then
            return false
        end

        if Player:Level() < 109 then
            return true
        end

        if Target:IsDummy() then
            return true
        end
        if RubimRH.useCDs == true then
            return true
        end
        if hotkey == true and IsShiftKeyDown() and IsControlKeyDown() then
            return true
        end

        if bossOnly == true and (UnitExists("boss1") or UnitClassification("target") == "worldboss") then
            return true
        end

        if isInRaid() then
            if UnitExists("boss1") then
                return true
            end
        end
        return false
    end

    local function coldHeart()
        --actions.cold_heart=chains_of_ice,if=buff.cold_heart.stack=20&buff.unholy_strength.react&cooldown.pillar_of_frost.remains>6
        if SpellFrost.ChainsOfIce:IsCastableP() and Player:BuffStack(SpellFrost.ChilledHearth) == 20 and Player:Buff(SpellFrost.UnholyStrength) and SpellFrost.PillarOfFrost:CooldownRemains() > 6 then
            setNextAbility(SpellFrost.ChainsOfIce:ID())
            return
        end

        --actions.cold_heart+=/chains_of_ice,if=buff.cold_heart.stack>=16&(cooldown.obliteration.ready&talent.obliteration.enabled)&buff.pillar_of_frost.up
        if SpellFrost.ChainsOfIce:IsCastableP() and Player:BuffStack(SpellFrost.ChilledHearth) >= 16 and (SpellFrost.Obliteration:IsReady() and SpellFrost.Obliteration:IsAvailable() and Player:Buff(SpellFrost.PillarOfFrost)) then
            setNextAbility(SpellFrost.ChainsOfIce:ID())
            return
        end
        --actions.cold_heart+=/chains_of_ice,if=buff.pillar_of_frost.up&buff.pillar_of_frost.remains<gcd&(buff.cold_heart.stack>=11|(buff.cold_heart.stack>=10&set_bonus.tier20_4pc))
        if SpellFrost.ChainsOfIce:IsCastableP() and Player:Buff(SpellFrost.PillarOfFrost) and Player:BuffRemains(SpellFrost.PillarOfFrost) <= Player:GCD() and (Player:BuffStack(SpellFrost.ChilledHearth) > 11) then
            setNextAbility(SpellFrost.ChainsOfIce:ID())
            return
        end

        --actions.cold_heart+=/chains_of_ice,if=buff.cold_heart.stack>=17&buff.unholy_strength.react&buff.unholy_strength.remains<gcd&cooldown.pillar_of_frost.remains>6
        if SpellFrost.ChainsOfIce:IsCastableP() and Player:BuffStack(SpellFrost.ChilledHearth) >= 17 and Player:Buff(SpellFrost.UnholyStrength) and Player:BuffRemains(SpellFrost.UnholyStrength) < Player:GCD() and Player:BuffRemains(SpellFrost.PillarOfFrost) > 6 then
            setNextAbility(SpellFrost.ChainsOfIce:ID())
            return
        end

        --actions.cold_heart+=/chains_of_ice,if=buff.cold_heart.stack>=13&buff.unholy_strength.react&talent.shattering_strikes.enabled
        if SpellFrost.ChainsOfIce:IsCastableP() and Player:BuffStack(SpellFrost.ChilledHearth) >= 13 and Player:Buff(SpellFrost.UnholyStrength) and SpellFrost.ShatteringStrikes:IsAvailable() then
            setNextAbility(SpellFrost.ChainsOfIce:ID())
            return
        end
        --actions.cold_heart+=/chains_of_ice,if=buff.cold_heart.stack>=4&target.time_to_die<=gcd
        if SpellFrost.ChainsOfIce:IsCastableP() and Player:BuffStack(SpellFrost.ChilledHearth) >= 4 and Target:TimeToDie() <= Player:GCD() then
            setNextAbility(SpellFrost.ChainsOfIce:ID())
            return
        end
    end

    local function frostCD()
        --actions.cds=arcane_torrent,if=runic_power.deficit>=20&!talent.breath_of_sindragosa.enabled
        --actions.cds+=/blood_fury,if=buff.pillar_of_frost.up
        --actions.cds+=/berserking,if=buff.pillar_of_frost.up
        --actions.cds+=/use_item,name=feloiled_infernal_machine,if=!talent.obliteration.enabled|buff.obliteration.up
        --TRINKET
        --if I.FelOiledInfernalMachine:IsEquipped() and (not S.Obliteration:IsAvailable() or Player:Buff(S.Obliteration)) then
        --return "DONT KNOW"
        --end
        --actions.cds+=/potion,if=buff.pillar_of_frost.up&(dot.breath_of_sindragosa.ticking|buff.obliteration.up|talent.hungering_rune_weapon.enabled)
        --AUTO USE PREPOT
        --        if IF.ProlongedPower:IsReady() and Player:Buff(S.PillarOfFrost) and (Player:Buff(S.BreathofSindragosa) or Player:Buff(S.Obliteration) or S.HungeringRuneWeapon:IsAvailable()) then
        --            --    if AR.CastLeft(I.ProlongedPower) then return ""; end
        --        end
        --actions.cds+=/pillar_of_frost,if=talent.obliteration.enabled&(cooldown.obliteration.remains>20|cooldown.obliteration.remains<10|!talent.icecap.enabled)
        if SpellFrost.PillarOfFrost:IsCastable() and SpellFrost.Obliteration:IsAvailable() and (SpellFrost.Obliteration:CooldownRemains() > 20 or SpellFrost.Obliteration:CooldownRemains() < 10 or not SpellFrost.Icecap:IsAvailable()) then
            setNextAbility(SpellFrost.PillarOfFrost:ID())
            return
        end
        --actions.cds+=/pillar_of_frost,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.ready&runic_power>50
        if SpellFrost.PillarOfFrost:IsCastable() and SpellFrost.BreathofSindragosa:IsAvailable() and SpellFrost.BreathofSindragosa:IsReady() and Player:RunicPower() > 50 then
            setNextAbility(SpellFrost.PillarOfFrost:ID())
            return
        end
        --actions.cds+=/pillar_of_frost,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>40
        if SpellFrost.PillarOfFrost:IsCastable() and SpellFrost.BreathofSindragosa:IsAvailable() and SpellFrost.BreathofSindragosa:CooldownRemains() > 40 then
            setNextAbility(SpellFrost.PillarOfFrost:ID())
            return
        end
        --actions.cds+=/pillar_of_frost,if=talent.hungering_rune_weapon.enabled
        if SpellFrost.PillarOfFrost:IsCastable() and SpellFrost.HungeringRuneWeapon:IsAvailable() then
            setNextAbility(SpellFrost.PillarOfFrost:ID())
            return
        end
        --actions.cds+=/breath_of_sindragosa,if=buff.pillar_of_frost.up
        if SpellFrost.BreathofSindragosa:IsCastable() and Player:Buff(SpellFrost.PillarOfFrost) then
            setNextAbility(SpellFrost.BreathofSindragosa:ID())
            return
        end
        --actions.cooldowns+=/call_action_list,name=cold_heart,if=equipped.cold_heart&((buff.cold_heart.stack>=10&!buff.obliteration.up&debuff.razorice.stack=5)|target.time_to_die<=gcd)
        if ItemFrost.ColdHeart:IsEquipped() and ((Player:BuffStack(SpellFrost.ChilledHearth) >= 10 and not Player:Buff(SpellFrost.Obliteration) and Target:DebuffStack(SpellFrost.RazorIce) == 5) or Target:TimeToDie() <= Player:GCD()) then
            coldHeart()
            if getNextAbility() ~= "Waiting" then
                return
            end
        end
        --actions.cds+=/obliteration,if=rune>=1&runic_power>=20&(!talent.frozen_pulse.enabled|rune<2|buff.pillar_of_frost.remains<=12)&(!talent.gathering_storm.enabled|!cooldown.remorseless_winter.ready)&(buff.pillar_of_frost.up|!talent.icecap.enabled)

        if CooldownsCheck() and SpellFrost.Obliteration:IsCastable() and Player:Runes() >= 1 and Player:RunicPower() >= 20 and (not SpellFrost.FrozenPulse:IsAvailable() or Player:Runes() < 2 or Player:BuffRemains(SpellFrost.PillarOfFrost) <= 12) and (not SpellFrost.GatheringStorm:IsAvailable() or not SpellFrost.RemorselessWinter:IsReady()) and (Player:Buff(SpellFrost.PillarOfFrost) or not SpellFrost.Icecap:IsAvailable()) then
            setNextAbility(SpellFrost.Obliteration:ID())
            return
        end
        --actions.cds+=/hungering_rune_weapon,if=!buff.hungering_rune_weapon.up&rune.time_to_2>gcd&runic_power<40
        if CooldownsCheck() and SpellFrost.HungeringRuneWeapon:IsCastable() and SpellFrost.HungeringRuneWeapon:Charges() >= 1 and not Player:Buff(SpellFrost.HungeringRuneWeapon) and Player:RuneTimeToX(2) > Player:GCD() and Player:RunicPower() < 40 then
            setNextAbility(SpellFrost.EmpowerRuneWeapon:ID())
            return
        end
    end

    local function frostOBLITERATION()
        --actions.obliteration=remorseless_winter,if=talent.gathering_storm.enabled
        if SpellFrost.RemorselessWinter:IsCastable() and SpellFrost.GatheringStorm:IsAvailable() and Cache.EnemiesCount[8] >= 1 then
            setNextAbility(SpellFrost.RemorselessWinter:ID())
            return
        end
        --actions.obliteration+=/frostscythe,if=(buff.killing_machine.up&(buff.killing_machine.react|prev_gcd.1.frost_strike|prev_gcd.1.howling_blast))&spell_targets.frostscythe>1
        if SpellFrost.FrostScythe:IsCastable() and (Player:Buff(SpellFrost.KillingMachine) and (Player:Buff(SpellFrost.KillingMachine) or Player:PrevGCD(1, SpellFrost.FrostStrike) or Player:PrevGCD(1, SpellFrost.HowlingBlast))) and Cache.EnemiesCount[8] > 1 then
            setNextAbility(SpellFrost.FrostScythe:ID())
            return
        end
        --actions.obliteration+=/obliterate,if=(buff.killing_machine.up&(buff.killing_machine.react|prev_gcd.1.frost_strike|prev_gcd.1.howling_blast))|(spell_targets.howling_blast>=3&!buff.rime.up&!talent.frostscythe.enabled)
        if SpellFrost.Obliterate:IsCastable() and ((Player:Buff(SpellFrost.KillingMachine) and (Player:Buff(SpellFrost.KillingMachine) or Player:PrevGCD(1, SpellFrost.FrostStrike) or Player:PrevGCD(1, SpellFrost.HowlingBlast))) or (Cache.EnemiesCount[10] >= 3 and not Player:Buff(SpellFrost.Rime) and not SpellFrost.FrostScythe:IsAvailable())) then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.obliteration+=/howling_blast,if=buff.rime.up&spell_targets.howling_blast>1
        if SpellFrost.HowlingBlast:IsCastable() and Player:Buff(SpellFrost.Rime) and Cache.EnemiesCount[10] > 1 then
            setNextAbility(SpellFrost.HowlingBlast:ID())
            return
        end
        --actions.obliteration+=/howling_blast,if=!buff.rime.up&spell_targets.howling_blast>2&rune>3&talent.freezing_fog.enabled&talent.gathering_storm.enabled
        if SpellFrost.HowlingBlast:IsCastable() and not Player:Buff(SpellFrost.Rime) and Cache.EnemiesCount[10] > 2 and Player:Runes() > 3 and SpellFrost.FreezingFog:IsAvailable() and SpellFrost.GatheringStorm:IsAvailable() then
            setNextAbility(SpellFrost.HowlingBlast:ID())
            return
        end
        --actions.obliteration+=/frost_strike,if=!buff.rime.up|rune.time_to_1>=gcd|runic_power.deficit<20
        if SpellFrost.FrostStrike:IsUsable() and (not Player:Buff(SpellFrost.Rime) or Player:RuneTimeToX(1) >= Player:GCD() or Player:RunicPowerDeficit() < 20) then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.obliteration+=/howling_blast,if=buff.rime.up
        if SpellFrost.HowlingBlast:IsCastable() and Player:Buff(SpellFrost.Rime) then
            setNextAbility(SpellFrost.HowlingBlast:ID())
            return
        end
        --actions.obliteration+=/obliterate
        if SpellFrost.Obliterate:IsCastable() then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
    end

    local function frostBOSPool()
        --actions.bos_pooling=remorseless_winter,if=talent.gathering_storm.enabled
        if SpellFrost.RemorselessWinter:IsCastable() and SpellFrost.GatheringStorm:IsAvailable() and Cache.EnemiesCount[8] >= 1 then
            setNextAbility(SpellFrost.RemorselessWinter:ID())
            return
        end
        --actions.bos_pooling+=/howling_blast,if=buff.rime.react&rune.time_to_4<(gcd*2)
        if SpellFrost.HowlingBlast:IsCastable() and Player:Buff(SpellFrost.Rime) and Player:RuneTimeToX(4) < (Player:GCD() * 2) then
            setNextAbility(SpellFrost.HowlingBlast:ID())
            return
        end
        --actions.bos_pooling+=/obliterate,if=rune.time_to_6<gcd&!talent.gathering_storm.enabled
        if SpellFrost.Obliterate:IsCastable() and Player:RuneTimeToX(6) < Player:GCD() and not SpellFrost.GatheringStorm:IsAvailable() then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.bos_pooling+=/obliterate,if=rune.time_to_4<gcd&(cooldown.breath_of_sindragosa.remains|runic_power.deficit>=30)
        if SpellFrost.Obliterate:IsCastable() and Player:RuneTimeToX(4) < Player:GCD() and (SpellFrost.BreathofSindragosa:CooldownRemains() or Player:RunicPowerDeficit() >= 30) then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.bos_pooling+=/frost_strike,if=runic_power>=95&set_bonus.tier19_4pc&cooldown.breath_of_sindragosa.remains&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
        if SpellFrost.FrostStrike:IsUsable() and Player:RunicPowerDeficit() < 5 and T194P and SpellFrost.BreathofSindragosa:CooldownRemains() and (not SpellFrost.ShatteringStrikes:IsAvailable() or Target:DebuffStack(SpellFrost.RazorIce) < 5 or SpellFrost.BreathofSindragosa:CooldownRemains() > 6) then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.bos_pooling+=/remorseless_winter,if=buff.rime.react&equipped.perseverance_of_the_ebon_martyr
        if SpellFrost.RemorselessWinter:IsCastable() and Player:Buff(SpellFrost.Rime) and ItemFrost.PerseveranceOfTheEbonMartyre:IsEquipped() and Cache.EnemiesCount[8] >= 1 then
            setNextAbility(SpellFrost.RemorselessWinter:ID())
            return
        end
        --actions.bos_pooling+=/howling_blast,if=buff.rime.react&(buff.remorseless_winter.up|cooldown.remorseless_winter.remains>gcd|(!equipped.perseverance_of_the_ebon_martyr&!talent.gathering_storm.enabled))
        if SpellFrost.HowlingBlast:IsCastable() and Player:Buff(SpellFrost.Rime) and (Player:Buff(SpellFrost.RemorselessWinter) or SpellFrost.RemorselessWinter:CooldownRemains() > Player:GCD() or (not ItemFrost.PerseveranceOfTheEbonMartyre:IsEquipped() and not SpellFrost.GatheringStorm:IsAvailable())) then
            setNextAbility(SpellFrost.HowlingBlast:ID())
            return
        end
        --actions.bos_pooling+=/obliterate,if=!buff.rime.react&!(talent.gathering_storm.enabled&!(cooldown.remorseless_winter.remains>(gcd*2)|rune>4))&rune>3
        if SpellFrost.Obliterate:IsCastable() and not Player:Buff(SpellFrost.Rime) and not (SpellFrost.GatheringStorm:IsAvailable() and not (SpellFrost.RemorselessWinter:CooldownRemains() > (Player:GCD() * 2) or Player:Runes() > 4)) and Player:Runes() > 3 then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.bos_pooling+=/sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.up&debuff.razorice.stack=5
        if CooldownsCheck() and SpellFrost.SindragosasFury:IsCastable() and (ItemFrost.ConsortsColdCore:IsEquipped() or Player:Buff(SpellFrost.PillarOfFrost)) and Player:Buff(SpellFrost.UnholyStrength) and Target:DebuffStack(SpellFrost.RazorIce) == 5 then
            setNextAbility(SpellFrost.SindragosasFury:ID())
            return
        end
        --actions.bos_pooling+=/frost_strike,if=runic_power.deficit<=30&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>rune.time_to_4)
        if SpellFrost.FrostStrike:IsUsable() and Player:RunicPowerDeficit() <= 30 and (not SpellFrost.ShatteringStrikes:IsAvailable() or Target:DebuffStack(SpellFrost.RazorIce) < 5 or SpellFrost.BreathofSindragosa:CooldownRemains() > Player:RuneTimeToX(4)) then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.bos_pooling+=/frostscythe,if=buff.killing_machine.up&(!equipped.koltiras_newfound_will|spell_targets.frostscythe>=2)
        if SpellFrost.FrostScythe:IsCastable() and Player:Buff(SpellFrost.KillingMachine) and (not ItemFrost.KoltirasNewfoundWill:IsEquipped() or Cache.EnemiesCount[8] >= 2) then
            setNextAbility(SpellFrost.FrostScythe:ID())
            return
        end
        --actions.bos_pooling+=/glacial_advance,if=spell_targets.glacial_advance>=2
        if SpellFrost.GlacialAdvance:IsCastable() and Cache.EnemiesCount[8] >= 2 then
            setNextAbility(SpellFrost.GlacialAdvance:ID())
            return
        end
        --actions.bos_pooling+=/remorseless_winter,if=spell_targets.remorseless_winter>=2
        if SpellFrost.RemorselessWinter:IsCastable() and Cache.EnemiesCount[8] >= 2 then
            setNextAbility(SpellFrost.RemorselessWinter:ID())
            return
        end
        --actions.bos_pooling+=/frostscythe,if=spell_targets.frostscythe>=3
        if SpellFrost.FrostScythe:IsCastable() and Cache.EnemiesCount[8] >= 2 then
            setNextAbility(SpellFrost.FrostScythe:ID())
            return
        end
        --actions.bos_pooling+=/frost_strike,if=(cooldown.remorseless_winter.remains<(gcd*2)|buff.gathering_storm.stack=10)&cooldown.breath_of_sindragosa.remains>rune.time_to_4&talent.gathering_storm.enabled&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
        if SpellFrost.FrostStrike:IsUsable() and (SpellFrost.RemorselessWinter:CooldownRemains() < (Player:GCD() * 2) or Player:BuffStack(SpellFrost.GatheringStormBuff) == 10) and SpellFrost.BreathofSindragosa:CooldownRemains() > Player:RuneTimeToX(4) and SpellFrost.GatheringStorm:IsAvailable() and (not SpellFrost.ShatteringStrikes:IsAvailable() or Target:DebuffStack(SpellFrost.RazorIce) < 5 or SpellFrost.BreathofSindragosa:CooldownRemains() > 6) then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.bos_pooling+=/obliterate,if=!buff.rime.react&(!talent.gathering_storm.enabled|cooldown.remorseless_winter.remains>gcd)
        if SpellFrost.Obliterate:IsCastable() and not Player:Buff(SpellFrost.Rime) and (not SpellFrost.GatheringStorm:IsAvailable() or SpellFrost.RemorselessWinter:CooldownRemains() > Player:GCD()) then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.bos_pooling+=/frost_strike,if=cooldown.breath_of_sindragosa.remains>rune.time_to_4&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
        if SpellFrost.FrostStrike:IsUsable() and SpellFrost.BreathofSindragosa:CooldownRemains() > Player:RuneTimeToX(4) and (not SpellFrost.ShatteringStrikes:IsAvailable() or Target:DebuffStack(SpellFrost.RazorIce) < 5 or SpellFrost.BreathofSindragosa:CooldownRemains() > 6) then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
    end

    local function frostBOSTick()
        --actions.bos_ticking=frost_strike,if=talent.shattering_strikes.enabled&runic_power<40&rune.time_to_2>2&cooldown.empower_rune_weapon.remains&debuff.razorice.stack=5&(cooldown.horn_of_winter.remains|!talent.horn_of_winter.enabled)
        if SpellFrost.FrostStrike:IsUsable() and SpellFrost.ShatteringStrikes:IsAvailable() and Player:RunicPower() < 40 and Player:RuneTimeToX(2) > 2 and SpellFrost.EmpowerRuneWeapon:CooldownRemains() and Target:DebuffStack(SpellFrost.RazorIce) == 5 and (SpellFrost.HornOfWinter:CooldownRemains() or not SpellFrost.HornOfWinter:IsAvailable()) then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.bos_ticking+=/remorseless_winter,if=(runic_power>=30|buff.hungering_rune_weapon.up)&((buff.rime.react&equipped.perseverance_of_the_ebon_martyr)|(talent.gathering_storm.enabled&(buff.remorseless_winter.remains<=gcd|!buff.remorseless_winter.remains)))
        if SpellFrost.RemorselessWinter:IsCastable() and (Player:RunicPower() >= 30 or Player:Buff(SpellFrost.HungeringRuneWeapon)) and ((Player:Buff(SpellFrost.Rime) and ItemFrost.PerseveranceOfTheEbonMartyre:IsEquipped()) or (SpellFrost.GatheringStorm:IsAvailable() and (Player:BuffRemains(SpellFrost.RemorselessWinter) <= Player:GCD() or not Player:BuffRemainsP(SpellFrost.RemorselessWinter)))) then
            setNextAbility(SpellFrost.RemorselessWinter:ID())
            return
        end
        --actions.bos_ticking+=/howling_blast,if=((runic_power>=20&set_bonus.tier19_4pc)|runic_power>=30|buff.hungering_rune_weapon.up)&buff.rime.react
        if SpellFrost.HowlingBlast:IsCastable() and ((Player:RunicPower() >= 20 and T192P) or Player:RunicPower() >= 30 or Player:Buff(SpellFrost.HungeringRuneWeapon)) and Player:Buff(SpellFrost.Rime) then
            setNextAbility(SpellFrost.HowlingBlast:ID())
            return
        end
        --actions.bos_ticking+=/frost_strike,if=set_bonus.tier20_2pc&runic_power.deficit<=15&rune<=3&buff.pillar_of_frost.up&!talent.shattering_strikes.enabled
        if SpellFrost.FrostStrike:IsUsable() and T202P and Player:RunicPowerDeficit() <= 15 and Player:Runes() <= 3 and Player:Buff(SpellFrost.PillarOfFrost) and not SpellFrost.ShatteringStrikes:IsAvailable() then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.bos_ticking+=/obliterate,if=runic_power<=45|rune.time_to_5<gcd|buff.hungering_rune_weapon.remains>=2
        if SpellFrost.Obliterate:IsCastable() and (Player:RunicPower() <= 45 or Player:RuneTimeToX(5) < Player:GCD() or Player:BuffRemains(SpellFrost.HungeringRuneWeapon) >= 2) then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.bos_ticking+=/sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.up&debuff.razorice.stack=5
        if CooldownsCheck() and SpellFrost.SindragosasFury:IsCastable() and (ItemFrost.ConsortsColdCore:IsEquipped() or Player:Buff(SpellFrost.PillarOfFrost)) and Player:Buff(SpellFrost.UnholyStrength) and Target:DebuffStack(SpellFrost.RazorIce) == 5 then
            setNextAbility(SpellFrost.SindragosasFury:ID())
            return
        end
        --actions.bos_ticking+=/horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
        if SpellFrost.HornOfWinter:IsCastable() and Player:RunicPowerDeficit() >= 30 and Player:RuneTimeToX(3) > Player:GCD() then
            setNextAbility(SpellFrost.HornOfWinter:ID())
            return
        end
        --actions.bos_ticking+=/frostscythe,if=buff.killing_machine.up&(!equipped.koltiras_newfound_will|talent.gathering_storm.enabled|spell_targets.frostscythe>=2)
        if SpellFrost.FrostScythe:IsCastable() and Player:Buff(SpellFrost.KillingMachine) and (not ItemFrost.KoltirasNewfoundWill:IsEquipped() or SpellFrost.GatheringStorm:IsAvailable() or Cache.EnemiesCount[8] >= 2) then
            setNextAbility(SpellFrost.FrostScythe:ID())
            return
        end
        --actions.bos_ticking+=/glacial_advance,if=spell_targets.remorseless_winter>=2
        if SpellFrost.GlacialAdvance:IsCastable() and Cache.EnemiesCount[8] >= 2 then
            setNextAbility(SpellFrost.GlacialAdvance:ID())
            return
        end
        --actions.bos_ticking+=/remorseless_winter,if=spell_targets.remorseless_winter>=2
        if SpellFrost.RemorselessWinter:IsCastable() and Cache.EnemiesCount[8] >= 2 then
            setNextAbility(SpellFrost.RemorselessWinter:ID())
            return
        end
        --actions.bos_ticking+=/obliterate,if=runic_power>25|rune>3
        if SpellFrost.Obliterate:IsCastable() and (Player:RunicPowerDeficit() > 25 or Player:Runes() > 3) then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.bos_ticking+=/empower_rune_weapon,if=runic_power<30&rune.time_to_2>gcd
        if CooldownsCheck() and SpellFrost.EmpowerRuneWeapon:IsCastable() and Player:RunicPower() < 30 and Player:RuneTimeToX(2) > Player:GCD() then
            setNextAbility(SpellFrost.EmpowerRuneWeapon:ID())
            return
        end
    end

    local function frostSTANDARD()
        if SpellFrost.FrostStrike:IsUsable() and SpellFrost.IcyTalons:IsAvailable() and Player:BuffRemains(SpellFrost.IcyTalonsBuff) <= Player:GCD() then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.standard+=/frost_strike,if=talent.shattering_strikes.enabled&debuff.razorice.stack=5&buff.gathering_storm.stack<2&!buff.rime.up
        if SpellFrost.FrostStrike:IsUsable() and SpellFrost.ShatteringStrikes:IsAvailable() and Target:DebuffStack(SpellFrost.RazorIce) == 5 and Player:BuffStack(SpellFrost.GatheringStormBuff) < 2 and not Player:Buff(SpellFrost.Rime) then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.standard+=/remorseless_winter,if=(buff.rime.react&equipped.perseverance_of_the_ebon_martyr)|talent.gathering_storm.enabled
        if SpellFrost.RemorselessWinter:IsCastable() and (Player:Buff(SpellFrost.Rime) and ItemFrost.PerseveranceOfTheEbonMartyre:IsEquipped() or (SpellFrost.GatheringStorm:IsAvailable() and Cache.EnemiesCount[8] >= 1)) then
            setNextAbility(SpellFrost.RemorselessWinter:ID())
            return
        end
        --actions.standard+=/obliterate,if=(equipped.koltiras_newfound_will&talent.frozen_pulse.enabled&set_bonus.tier19_2pc=1)|rune.time_to_4<gcd&buff.hungering_rune_weapon.up
        if SpellFrost.Obliterate:IsCastable() and ((ItemFrost.KoltirasNewfoundWill:IsEquipped() and SpellFrost.FrozenPulse:IsAvailable() and T192P) or Player:RuneTimeToX(4) < Player:GCD() and Player:Buff(SpellFrost.HungeringRuneWeapon)) then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.standard+=/frost_strike,if=(!talent.shattering_strikes.enabled|debuff.razorice.stack<5)&runic_power.deficit<10
        if SpellFrost.FrostStrike:IsUsable() and (not SpellFrost.ShatteringStrikes:IsAvailable() or Target:DebuffStack(SpellFrost.RazorIce) < 5) and Player:RunicPowerDeficit() < 10 then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.standard+=/howling_blast,if=buff.rime.react
        if SpellFrost.HowlingBlast:IsCastable() and Player:Buff(SpellFrost.Rime) then
            setNextAbility(SpellFrost.HowlingBlast:ID())
            return
        end
        --actions.standard+=/obliterate,if=(equipped.koltiras_newfound_will&talent.frozen_pulse.enabled&set_bonus.tier19_2pc=1)|rune.time_to_5<gcd
        if SpellFrost.Obliterate:IsCastable() and ((ItemFrost.KoltirasNewfoundWill:IsEquipped() and SpellFrost.FrozenPulse:IsAvailable() and T192P) or Player:RuneTimeToX(5) < Player:GCD()) then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.standard+=/sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.up&debuff.razorice.stack=5
        if CooldownsCheck() and SpellFrost.SindragosasFury:IsCastable() and (ItemFrost.ConsortsColdCore:IsEquipped() or Player:Buff(SpellFrost.PillarOfFrost)) and Player:Buff(SpellFrost.UnholyStrength) and Target:DebuffStack(SpellFrost.RazorIce) == 5 then
            setNextAbility(SpellFrost.SindragosasFury:ID())
            return
        end

        --actions.standard+=/frost_strike,if=runic_power.deficit<10&!buff.hungering_rune_weapon.up
        if SpellFrost.FrostStrike:IsUsable() and Player:RunicPowerDeficit() < 10 and not Player:Buff(SpellFrost.HungeringRuneWeapon) then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.standard+=/frostscythe,if=buff.killing_machine.up&(!equipped.koltiras_newfound_will|spell_targets.frostscythe>=2)
        if SpellFrost.FrostScythe:IsCastable() and Player:Buff(SpellFrost.KillingMachine) and (not ItemFrost.KoltirasNewfoundWill:IsEquipped() or Cache.EnemiesCount[8] >= 2) then
            setNextAbility(SpellFrost.FrostScythe:ID())
            return
        end
        --actions.standard+=/obliterate,if=buff.killing_machine.react
        if SpellFrost.Obliterate:IsCastable() and Player:Buff(SpellFrost.KillingMachine) then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.standard+=/frost_strike,if=runic_power.deficit<20
        if SpellFrost.FrostStrike:IsUsable() and Player:RunicPowerDeficit() < 20 then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.standard+=/remorseless_winter,if=spell_targets.remorseless_winter>=2
        if SpellFrost.RemorselessWinter:IsCastable() and Cache.EnemiesCount[8] >= 2 then
            setNextAbility(SpellFrost.RemorselessWinter:ID())
            return
        end
        --actions.standard+=/glacial_advance,if=spell_targets.glacial_advance>=2
        if SpellFrost.GlacialAdvance:IsCastable() and Cache.EnemiesCount[8] >= 2 then
            setNextAbility(SpellFrost.GlacialAdvance:ID())
            return
        end
        --actions.standard+=/frostscythe,if=spell_targets.frostscythe>=3
        if SpellFrost.FrostScythe:IsCastable() and Cache.EnemiesCount[8] >= 3 then
            setNextAbility(SpellFrost.FrostScythe:ID())
            return
        end
        --actions.standard+=/obliterate
        if SpellFrost.Obliterate:IsCastable() then
            setNextAbility(SpellFrost.Obliterate:ID())
            return
        end
        --actions.standard+=/horn_of_winter,if=!buff.hungering_rune_weapon.up&(rune.time_to_2>gcd|!talent.frozen_pulse.enabled)
        if SpellFrost.HornOfWinter:IsCastable() and not Player:Buff(SpellFrost.HungeringRuneWeapon) and (Player:RuneTimeToX(2) > Player:GCD() or not SpellFrost.FrozenPulse:IsAvailable()) then
            setNextAbility(SpellFrost.HornOfWinter:ID())
            return
        end
        --actions.standard+=/frost_strike,if=!(runic_power<50&talent.obliteration.enabled&cooldown.obliteration.remains<=gcd)
        if SpellFrost.FrostStrike:IsUsable() and not (Player:RunicPower() < 50 and SpellFrost.Obliteration:IsAvailable() and SpellFrost.Obliteration:CooldownRemains() <= Player:GCD()) then
            setNextAbility(SpellFrost.FrostStrike:ID())
            return
        end
        --actions.standard+=/empower_rune_weapon,if=!talent.breath_of_sindragosa.enabled|target.time_to_die<cooldown.breath_of_sindragosa.remains
        if CooldownsCheck() and SpellFrost.EmpowerRuneWeapon:IsCastable() and (SpellFrost.EmpowerRuneWeapon:Charges() >= 1 and not SpellFrost.BreathofSindragosa:IsAvailable() or Target:TimeToDie() < SpellFrost.BreathofSindragosa:CooldownRemains()) then
            setNextAbility(SpellFrost.EmpowerRuneWeapon:ID())
            return
        end
    end


    function frostRotation()
        setNextAbility("Waiting")
        AC.GetEnemies("Melee");
        AC.GetEnemies(8, true);
        AC.GetEnemies(10, true);
        if Target:IsInRange(30) and not Target:Debuff(SpellFrost.FrostFever) then
            setNextAbility(SpellFrost.HowlingBlast:ID())
            return
        end

        if Target:IsInRange("Melee") then
            frostCD()
            if getNextAbility() ~= "Waiting" then
                return
            end
        end

        if SpellFrost.BreathofSindragosa:IsAvailable() and SpellFrost.BreathofSindragosa:CooldownRemains() < 15 then
            frostBOSPool()
            if getNextAbility() ~= "Waiting" then
                return
            end
        end

        --actions+=/run_action_list,name=bos_ticking,if=talent.breath_of_sindragosa.enabled&dot.breath_of_sindragosa.ticking
        if Player:Buff(SpellFrost.BreathofSindragosa) then
            frostBOSTick()
            if getNextAbility() ~= "Waiting" then
                return
            end
        end

        --actions+=/run_action_list,name=obliteration,if=buff.obliteration.up
        if Player:Buff(SpellFrost.Obliteration) then
            frostOBLITERATION()
            if getNextAbility() ~= "Waiting" then
                return
            end
        end

        --actions+=/call_action_list,name=standard
        if SpellFrost.BreathofSindragosa:IsAvailable() or SpellFrost.Obliteration:IsAvailable() or SpellFrost.HungeringRuneWeapon:IsAvailable() then
            frostSTANDARD()
            if getNextAbility() ~= "Waiting" then
                return
            end
        end
    end

    local function bloodBurst()
        if SpellBlood.HeartStrike:IsCastableP("Melee") and Player:RunicPower() <= 100 then
            setNextAbility(SpellBlood.HeartStrike:ID())
            return
        end

        if SpellBlood.DeathStrike:IsReady("Melee") then
            setNextAbility(SpellBlood.DeathStrike:ID())
            return
        end

        if SpellBlood.BloodBoil:IsCastableP() and Cache.EnemiesCount[10] >= 1 then
            setNextAbility(SpellBlood.BloodBoil:ID())
            return
        end
    end

    function bloodRotation()
        setNextAbility("Waiting")
        AC.GetEnemies("Melee");
        AC.GetEnemies(8, true); -- Death and Decay & Bonestorm
        AC.GetEnemies(10, true); -- Blood Boil
        AC.GetEnemies(20, true);

        -- Units without Blood Plague
        local UnitsWithoutBloodPlague = 0;
        for _, CycleUnit in pairs(Cache.Enemies[10]) do
            if not CycleUnit:Debuff(SpellBlood.BloodPlague) then
                UnitsWithoutBloodPlague = UnitsWithoutBloodPlague + 1;
            end
        end

        if SpellBlood.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 90 then
            setNextAbility(SpellBlood.DeathStrike:ID())
            return
        end

        if SpellBlood.Marrowrend:IsCastableP("Melee") and not Player:Buff(SpellBlood.BoneShield) then
            setNextAbility(SpellBlood.Marrowrend:ID())
            return
        end

        if SpellBlood.DeathStrike:IsReady("Melee") and (Player:RunicPower() + (5 + math.min(Cache.EnemiesCount["Melee"], 5) * 2)) >= 125 then
            setNextAbility(SpellBlood.DeathStrike:ID())
            return
        end

        if SpellBlood.DeathStrike:IsReady("Melee") and Player:RunicPowerDeficit() < 20 then
            setNextAbility(SpellBlood.DeathStrike:ID())
            return
        end

        if SpellBlood.BloodBoil:IsCastableP() and Cache.EnemiesCount[10] >= 1 and UnitsWithoutBloodPlague >= 1 then
            setNextAbility(SpellBlood.BloodBoil:ID())
            return
        end

        if SpellBlood.BloodBoil:IsCastable() and Cache.EnemiesCount[10] >= 1 and SpellBlood.BloodBoil:ChargesFractional() >= 1.8 then
            setNextAbility(SpellBlood.BloodBoil:ID())
            return
        end

        if dnd and SpellBlood.DeathandDecay:IsReady("Melee") and Cache.EnemiesCount[8] >= 1 and Player:Buff(SpellBlood.CrimsonScourge) then
            setNextAbility(SpellBlood.DeathandDecay:ID())
            return
        end

        if SpellBlood.Marrowrend:IsCastableP("Melee") and Player:BuffRemainsP(SpellBlood.BoneShield) <= Player:GCD() * 2 then
            setNextAbility(SpellBlood.Marrowrend:ID())
            return
        end

        -- actions.standard+=/blood_boil,if=charges_fractional>=1.8&buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
        if SpellBlood.BloodBoil:IsCastable() and Cache.EnemiesCount[10] >= 1 and SpellBlood.BloodBoil:ChargesFractional() >= 1.8 then
            setNextAbility(SpellBlood.BloodBoil:ID())
            return
        end
        -- actions.standard+=/marrowrend,if=(buff.bone_shield.stack<5&talent.ossuary.enabled)|buff.bone_shield.remains<gcd*3
        if SpellBlood.Marrowrend:IsCastableP("Melee") and ((Player:BuffStack(SpellBlood.BoneShield) < 5 and SpellBlood.Ossuary:IsAvailable()) or (Player:BuffRemainsP(SpellBlood.BoneShield) <= Player:GCD() * 3)) then
            setNextAbility(SpellBlood.Marrowrend:ID())
            return
        end

        if dnd and SpellBlood.DeathandDecay:IsReady("Melee") and Cache.EnemiesCount[8] >= 1 and ((Player:RuneTimeToX(3) <= Player:GCD()) or Player:Runes() >= 3) then
            setNextAbility(SpellBlood.DeathandDecay:ID())
            return
        end
        -- actions.standard+=/bonestorm,if=runic_power>=100&spell_targets.bonestorm>=3
        if bonestorm and SpellBlood.DeathandDecay:IsCastableP() and Cache.EnemiesCount[8] >= 3 and Player:RunicPower() >= 90 then
            setNextAbility(SpellBlood.Bonestorm:ID())
            return
        end

        if SpellBlood.Consumption:IsCastableP("Melee") and Cache.EnemiesCount[8] > 1 then
            setNextAbility(SpellBlood.Consumption:ID())
            return
        end

        if SpellBlood.Marrowrend:IsCastableP("Melee") and Player:BuffStack(SpellBlood.BoneShield) <= 6 then
            setNextAbility(SpellBlood.Marrowrend:ID())
            return
        end

        if SpellBlood.HeartStrike:IsCastableP("Melee") and ((Player:RuneTimeToX(3) <= Player:GCD()) or Player:Runes() >= 3) then
            setNextAbility(SpellBlood.HeartStrike:ID())
            return
        end

        if SpellBlood.BloodBoil:IsCastableP() and Cache.EnemiesCount[10] >= 1 then
            setNextAbility(SpellBlood.BloodBoil:ID())
            return
        end
        -- actions.standard+=/blood_boil,if=buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
        -- actions.standard+=/death_and_decay
        if dnd and SpellBlood.DeathandDecay:IsReady("Melee") and Cache.EnemiesCount[8] >= 1 and ((Player:RuneTimeToX(3) <= Player:GCD()) or Player:Runes() >= 3) then
            setNextAbility(SpellBlood.DeathandDecay:ID())
            return
        end

        if SpellBlood.HeartStrike:IsCastableP("Melee") and ((Player:RuneTimeToX(2) <= Player:GCD()) or Player:BuffStack(SpellBlood.BoneShield) >= 7) then
            setNextAbility(SpellBlood.HeartStrike:ID())
            return
        end
    end

    --- =================================
end