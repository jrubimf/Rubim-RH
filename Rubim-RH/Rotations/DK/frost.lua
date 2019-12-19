local mainAddon = RubimRH
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
    DeathGrip = Spell(49576),
    DeathsAdvance = Spell(48265),
    DeathPact = Spell(48743),

    -- Everything
    BreathofSindragosaBuff                = Spell(152279),
    RemorselessWinter                     = Spell(196770),
    GatheringStorm                        = Spell(194912),
    GlacialAdvance                        = Spell(194913),
    Frostscythe                           = Spell(207230),
    FrostStrike                           = Spell(49143),
    HowlingBlast                          = Spell(49184),
    RimeBuff                              = Spell(59052),
    KillingMachineBuff                    = Spell(51124),
    RunicAttenuation                      = Spell(207104),
    Obliterate                            = Spell(49020),
    HornofWinter                          = Spell(57330),
    ArcaneTorrent                         = Spell(50613),
    PillarofFrost                         = Spell(51271),
    ChainsofIce                           = Spell(45524),
    ColdHeartBuff                         = Spell(281209),
    PillarofFrostBuff                     = Spell(51271),
    FrostwyrmsFury                        = Spell(279302),
    EmpowerRuneWeaponBuff                 = Spell(47568),
    BloodFury                             = Spell(20572),
    Berserking                            = Spell(26297),
    EmpowerRuneWeapon                     = Spell(47568),
    BreathofSindragosa                    = Spell(152279),
    ColdHeart                             = Spell(281208),
    RazoriceDebuff                        = Spell(51714),
    FrozenPulseBuff                       = Spell(194909),
    FrozenPulse                           = Spell(194909),
    FrostFeverDebuff                      = Spell(55095),
    IcyTalonsBuff                         = Spell(194879),
    Obliteration                          = Spell(281238),
    DeathStrike                           = Spell(49998),
    DeathStrikeBuff                       = Spell(101568),
    FrozenTempest                         = Spell(278487),
    UnholyStrengthBuff                    = Spell(53365),
    


    -- PVP

    Transfusion = Spell(288977),
	
	-- Azerite
	IcyCitadel                            = Spell(272718),
    IcyCitadelBuff                        = Spell(272719),
	
	  --8.2 Essences
  UnleashHeartOfAzeroth = Spell(280431),
  BloodOfTheEnemy       = Spell(297108),
  BloodOfTheEnemy2      = Spell(298273),
  BloodOfTheEnemy3      = Spell(298277),
  ConcentratedFlameDebuff= Spell(295368),
  ConcentratedFlame     = Spell(295373),
  ConcentratedFlame2    = Spell(299349),
  ConcentratedFlame3    = Spell(299353),
  GuardianOfAzeroth     = Spell(295840),
  GuardianOfAzeroth2    = Spell(299355),
  GuardianOfAzeroth3    = Spell(299358),
  FocusedAzeriteBeam    = Spell(295258),
  FocusedAzeriteBeam2   = Spell(299336),
  FocusedAzeriteBeam3   = Spell(299338),
  PurifyingBlast        = Spell(295337),
  PurifyingBlast2       = Spell(299345),
  PurifyingBlast3       = Spell(299347),
  RecklessForceBuff     = Spell(302932),
  TheUnboundForce       = Spell(298452),
  TheUnboundForce2      = Spell(299376),
  TheUnboundForce3      = Spell(299378),
  RippleInSpace         = Spell(302731),
  RippleInSpace2        = Spell(302982),
  RippleInSpace3        = Spell(302983),
  WorldveinResonance    = Spell(295186),
  WorldveinResonance2   = Spell(298628),
  WorldveinResonance3   = Spell(299334),
  MemoryOfLucidDreams   = Spell(298357),
  MemoryOfLucidDreams2  = Spell(299372),
  MemoryOfLucidDreams3  = Spell(299374),
  RecklessForceCounter  = Spell(298409),
  RecklessForceCounter2 = Spell(302917)
  
}

local S = RubimRH.Spell[251]

if not Item.DeathKnight then
    Item.DeathKnight = { }
end
Item.DeathKnight.Frost = {
    ProlongedPower = Item(142117),
    HornofValor = Item(133642),
    ColdHeart = Item(151796),
    VialofAnimatedBlood = Item(159625)
}
-- Rotation Var
local ShouldReturn; -- Used to get the return string
local I = Item.DeathKnight.Frost;
local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

local OffensiveCDs = {
    S.BloodFury,
    S.Berserking,
    S.PillarofFrost,
    S.BreathofSindragosa,
    S.EmpowerRuneWeapon,
    S.FrostwyrmsFury
    
    

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

local EnemyRanges = { "Melee", 5, 8, 10, 30 }
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
  S.RecklessForceCounter = S.RecklessForceCounter2:IsAvailable() and S.RecklessForceCounter2 or S.RecklessForceCounter
end

local function APL()
    local Precombat, Aoe, BosPooling, BosTicking, ColdHeart, Cooldowns, Essences, Obliteration, Standard
    UpdateRanges()
    UpdateCDs()
    if QueueSkill() ~= nil then
        if RubimRH.QueuedSpell():ID() == S.BreathofSindragosa:ID() then
            if Player:Buff(S.EmpowerRuneWeapon) and Player:Buff(S.PillarofFrost) then
                return QueueSkill()
            end
        else
            return QueueSkill()
        end
    end

    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- potion
        -- variable,name=other_on_use_equipped,value=(equipped.dread_gladiators_badge|equipped.sinister_gladiators_badge|equipped.sinister_gladiators_medallion|equipped.vial_of_animated_blood|equipped.first_mates_spyglass|equipped.jes_howler|equipped.dread_aspirants_medallion)
        return 0, 462338
    end

    Aoe = function()
        -- remorseless_winter,if=talent.gathering_storm.enabled
        if S.RemorselessWinter:IsReady() and Cache.EnemiesCount[5] > 0 and (S.GatheringStorm:IsAvailable()) then
            return S.RemorselessWinter:Cast()
        end
        -- glacial_advance,if=talent.frostscythe.enabled
        if S.GlacialAdvance:IsReady() and (S.Frostscythe:IsAvailable()) then
            return S.GlacialAdvance:Cast()
        end
        -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled&!talent.frostscythe.enabled
        if S.FrostStrike:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable() and not S.Frostscythe:IsAvailable()) then
            return S.FrostStrike:Cast()
        end
        -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
        if S.FrostStrike:IsReady("Melee") and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
            return S.FrostStrike:Cast()
        end
        -- howling_blast,if=buff.rime.up
        if S.HowlingBlast:IsReady() and (Player:BuffP(S.RimeBuff)) then
            return S.HowlingBlast:Cast()
        end
        -- frostscythe,if=buff.killing_machine.up
        if S.Frostscythe:IsReady() and Cache.EnemiesCount[8] >= 2 and (Player:BuffP(S.KillingMachineBuff)) then
            return S.Frostscythe:Cast()
        end
        -- glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
        if S.GlacialAdvance:IsReady(5) and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
            return S.GlacialAdvance:Cast()
        end
        -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<(15+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
        if S.FrostStrike:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
            return S.FrostStrike:Cast()
        end
        -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
        if S.FrostStrike:IsUsableP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
            return S.FrostStrike:Cast()
        end
        -- remorseless_winter
        if S.RemorselessWinter:IsReady() and Cache.EnemiesCount[5] > 0 then
            return S.RemorselessWinter:Cast()
        end
        -- frostscythe
        if S.Frostscythe:IsReady() and Cache.EnemiesCount[8] >= 2 then
            return S.Frostscythe:Cast()
        end
        -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>(25+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
        if S.Obliterate:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
            return S.Obliterate:Cast()
        end
        -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
        if S.Obliterate:IsReady("Melee") and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
            return S.Obliterate:Cast()
        end
        -- glacial_advance
        if S.GlacialAdvance:IsReady(5) then
            return S.GlacialAdvance:Cast()
        end
        -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
        if S.FrostStrike:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable()) then
            return S.FrostStrike:Cast()
        end
        -- frost_strike
        if S.FrostStrike:IsReady("Melee") then
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

    BosPooling = function()
        -- howling_blast,if=buff.rime.up
        if S.HowlingBlast:IsReady(30, true) and (Player:BuffP(S.RimeBuff)) then
            return S.HowlingBlast:Cast()
        end
        -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&&runic_power.deficit>=25&!talent.frostscythe.enabled
        if S.Obliterate:IsReady("Melee") and (Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and true and Player:RunicPowerDeficit() >= 25 and not S.Frostscythe:IsAvailable() then
            return S.Obliterate:Cast()
        end
        -- obliterate,if=runic_power.deficit>=25
        if S.Obliterate:IsReady("Melee") and Player:RunicPowerDeficit() >= 25 then
            return S.Obliterate:Cast()
        end
        -- glacial_advance,if=runic_power.deficit<20&spell_targets.glacial_advance>=2&cooldown.pillar_of_frost.remains>5
        if S.GlacialAdvance:IsReady() and (Player:RunicPowerDeficit() < 20 and Cache.EnemiesCount[30] >= 2 and S.PillarofFrost:CooldownRemainsP() > 5) then
            return S.GlacialAdvance:Cast()
        end
        -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<20&!talent.frostscythe.enabled&cooldown.pillar_of_frost.remains>5
        if S.FrostStrike:IsReady("Melee") and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4)) then
            return S.FrostStrike:Cast()
        end
        -- frost_strike,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>5
        if S.FrostStrike:IsReady("Melee") and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > 5) then
            return S.FrostStrike:Cast()
        end
        -- frostscythe,if=buff.killing_machine.up&runic_power.deficit>(15+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
        if S.Frostscythe:IsReady() and (Player:BuffP(S.KillingMachineBuff) and Player:RunicPowerDeficit() > (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and Cache.EnemiesCount[8] >= 2) then
            return S.Frostscythe:Cast()
        end
        -- frostscythe,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
        if S.Frostscythe:IsReady() and (Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3) and Cache.EnemiesCount[8] >= 2) then
            return S.Frostscythe:Cast()
        end
        -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
        if S.Obliterate:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
            return S.Obliterate:Cast()
        end
        -- obliterate,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)
        if S.Obliterate:IsReady("Melee") and (Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
            return S.Obliterate:Cast()
        end
        -- glacial_advance,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&spell_targets.glacial_advance>=2
        if S.GlacialAdvance:IsReady() and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and Cache.EnemiesCount[30] >= 2) then
            return S.GlacialAdvance:Cast()
        end
        -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&!talent.frostscythe.enabled
        if S.FrostStrike:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and not S.Frostscythe:IsAvailable()) then
            return S.FrostStrike:Cast()
        end
        -- frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40
        if S.FrostStrike:IsReady("Melee") and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40) then
            return S.FrostStrike:Cast()
        end
        return 0, 135328
    end

    BosTicking = function()
        -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power<=30&!talent.frostscythe.enabled
        if S.Obliterate:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPower() <= 30 and not S.Frostscythe:IsAvailable()) then
            return S.Obliterate:Cast()
        end
        -- obliterate,if=runic_power<=32
        if S.Obliterate:IsReady("Melee") and (Player:RunicPower() <= 32) then
            return S.Obliterate:Cast()
        end
        -- remorseless_winter,if=talent.gathering_storm.enabled
        if S.RemorselessWinter:IsReady() and Cache.EnemiesCount[5] > 0 and (S.GatheringStorm:IsAvailable()) then
            return S.RemorselessWinter:Cast()
        end
        -- howling_blast,if=buff.rime.up
        if S.HowlingBlast:IsReady(30, true) and (Player:BuffP(S.RimeBuff)) then
            return S.HowlingBlast:Cast()
        end
        -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&rune.time_to_5<gcd|runic_power<=45&!talent.frostscythe.enabled
        if S.Obliterate:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45 and not S.Frostscythe:IsAvailable()) then
            return S.Obliterate:Cast()
        end
        -- obliterate,if=rune.time_to_5<gcd|runic_power<=45
        if S.Obliterate:IsReady("Melee") and (Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45) then
            return S.Obliterate:Cast()
        end
        -- frostscythe,if=buff.killing_machine.up&spell_targets.frostscythe>=2
        if S.Frostscythe:IsReady() and (Player:BuffP(S.KillingMachineBuff) and Cache.EnemiesCount[8] >= 2) then
            return S.Frostscythe:Cast()
        end
        -- horn_of_winter,if=runic_power.deficit>=32&rune.time_to_3>gcd
        if S.HornofWinter:IsReady() and (Player:RunicPowerDeficit() >= 32 and Player:RuneTimeToX(3) > Player:GCD()) then
            return S.HornofWinter:Cast()
        end
        -- remorseless_winter
        if S.RemorselessWinter:IsReady() and Cache.EnemiesCount[5] > 0 then
            return S.RemorselessWinter:Cast()
        end
        -- frostscythe,if=spell_targets.frostscythe>=2
        if S.Frostscythe:IsReady() and (Cache.EnemiesCount[8] >= 2) then
            return S.Frostscythe:Cast()
        end
        -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>25|rune>3&!talent.frostscythe.enabled
        if S.Obliterate:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() > 25 or Player:Rune() > 3 and not S.Frostscythe:IsAvailable()) then
            return S.Obliterate:Cast()
        end
        -- obliterate,if=runic_power.deficit>25|rune>3
        if S.Obliterate:IsReady("Melee") and (Player:RunicPowerDeficit() > 25 or Player:Rune() > 3) then
            return S.Obliterate:Cast()
        end
        -- arcane_torrent,if=runic_power.deficit>20
        if S.ArcaneTorrent:IsReady() and (Player:RunicPowerDeficit() > 20) then
            return S.ArcaneTorrent:Cast()
        end
        return 0, 135328
    end

    ColdHeart = function()
        -- chains_of_ice,if=buff.cold_heart.stack>5&target.1.time_to_die<gcd
        if S.ChainsofIce:IsReady() and (Player:BuffStackP(S.ColdHeartBuff) > 5 and (Target:TimeToDie() < 0 and Target:IsInBossList())) then
            return S.ChainsofIce:Cast()
        end
        -- chains_of_ice,if=(buff.pillar_of_frost.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.pillar_of_frost.remains<rune.time_to_3)&buff.pillar_of_frost.up&azerite.icy_citadel.rank<=2
        if S.ChainsofIce:IsReady() and ((Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) or Player:BuffRemainsP(S.PillarofFrostBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.PillarofFrostBuff) and S.IcyCitadel:AzeriteRank() <= 2) then
            return S.ChainsofIce:Cast()
        end
        -- chains_of_ice,if=buff.pillar_of_frost.remains<8&buff.unholy_strength.remains<gcd*(1+cooldown.frostwyrms_fury.ready)&buff.unholy_strength.remains&buff.pillar_of_frost.up&azerite.icy_citadel.rank<=2
        if S.ChainsofIce:IsReady() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) < Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) and Player:BuffP(S.UnholyStrengthBuff) and Player:BuffP(S.PillarofFrostBuff) and S.IcyCitadel:AzeriteRank() <= 2) then
            return S.ChainsofIce:Cast()
        end
        -- chains_of_ice,if=(buff.icy_citadel.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.icy_citadel.remains<rune.time_to_3)&buff.icy_citadel.up&azerite.icy_citadel.enabled&azerite.icy_citadel.rank>2
        if S.ChainsofIce:IsReady() and ((Player:BuffRemainsP(S.IcyCitadelBuff) <= Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) or Player:BuffRemainsP(S.IcyCitadelBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.IcyCitadelBuff) and S.IcyCitadel:AzeriteEnabled() and S.IcyCitadel:AzeriteRank() > 2) then
            return S.ChainsofIce:Cast()
        end
        -- chains_of_ice,if=(buff.icy_citadel.remains<4|buff.icy_citadel.remains<rune.time_to_3)&buff.icy_citadel.up&azerite.icy_citadel.rank>2
        -- This will always return false based on the last two checks, ignoring the "not enabled" check as that wasn't in the other updates on 1/12
        if S.ChainsofIce:IsReady() and ((Player:BuffRemainsP(S.IcyCitadelBuff) < 4 or Player:BuffRemainsP(S.IcyCitadelBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.IcyCitadelBuff) and S.IcyCitadel:AzeriteRank() > 2) then
            return S.ChainsofIce:Cast()
        end	
        -- chains_of_ice,if=buff.icy_citadel.up&buff.unholy_strength.up&azerite.icy_citadel.rank>2
        if S.ChainsofIce:IsReady() and (Player:BuffP(S.IcyCitadelBuff) and Player:BuffP(S.UnholyStrengthBuff) and S.IcyCitadel:AzeriteRank() > 2) then
            return S.ChainsofIce:Cast()
        end	
    end

    Cooldowns = function()
        -- use_item,name=lurkers_insidious_gift,if=talent.breath_of_sindragosa.enabled&((cooldown.pillar_of_frost.remains<=10&variable.other_on_use_equipped)|(buff.pillar_of_frost.up&!variable.other_on_use_equipped))|(buff.pillar_of_frost.up&!talent.breath_of_sindragosa.enabled)
        -- name=azsharas_font_of_power,if=(cooldown.empowered_rune_weapon.ready&!variable.other_on_use_equipped)|(cooldown.pillar_of_frost.remains<=10&variable.other_on_use_equipped)
        -- lurkers_insidious_gift,if=talent.breath_of_sindragosa.enabled&((cooldown.pillar_of_frost.remains<=10&variable.other_on_use_equipped)|(buff.pillar_of_frost.up&!variable.other_on_use_equipped))|(buff.pillar_of_frost.up&!talent.breath_of_sindragosa.enabled)
        -- cyclotronic_blast,if=!buff.pillar_of_frost.up
        -- ashvanes_razor_coral,if=cooldown.empower_rune_weapon.remains>110|cooldown.breath_of_sindragosa.remains>90|time<50|target.1.time_to_die<21
        -- (cooldown.pillar_of_frost.ready|cooldown.pillar_of_frost.remains>20)&(!talent.breath_of_sindragosa.enabled|cooldown.empower_rune_weapon.remains>95)
        -- use_item,name=jes_howler,if=(equipped.lurkers_insidious_gift&buff.pillar_of_frost.remains)|(!equipped.lurkers_insidious_gift&buff.pillar_of_frost.remains<12&buff.pillar_of_frost.up)
        -- use_item,name=knot_of_ancient_fury,if=cooldown.empower_rune_weapon.remains>40
        -- use_item,name=grongs_primal_rage,if=rune<=3&!buff.pillar_of_frost.up&(!buff.breath_of_sindragosa.up|!talent.breath_of_sindragosa.enabled)
        -- use_item,name=razdunks_big_red_button
        -- use_item,name=merekthas_fang,if=!buff.breath_of_sindragosa.up&!buff.pillar_of_frost.up
        -- potion,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
        -- potion,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
        -- blood_fury,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
        if S.BloodFury:IsReady() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
            return S.BloodFury:Cast()
        end
        -- berserking,if=buff.pillar_of_frost.up
        if S.Berserking:IsReady() and (Player:BuffP(S.PillarofFrostBuff)) then
            return S.Berserking:Cast()
        end
        -- pillar_of_frost,if=cooldown.empower_rune_weapon.remains
        if S.PillarofFrost:IsReady() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP())) then
            return S.PillarofFrost:Cast()
        end
        -- breath_of_sindragosa,use_off_gcd=1,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
        if S.BreathofSindragosa:IsReady(5) and (bool(S.EmpowerRuneWeapon:CooldownRemainsP()) and bool(S.PillarofFrost:CooldownRemainsP())) then
            return S.BreathofSindragosa:Cast()
        end
        -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&!talent.breath_of_sindragosa.enabled&rune.time_to_5>gcd&runic_power.deficit>=10|target.1.time_to_die<20
        if S.EmpowerRuneWeapon:IsReady('Melee') and (S.PillarofFrost:CooldownUpP() and not S.BreathofSindragosa:IsAvailable() and Player:RuneTimeToX(5) > Player:GCD() and Player:RunicPowerDeficit() >= 10 or (Target:TimeToDie() < 20 and Target:IsInBossList())) then
            return S.EmpowerRuneWeapon:Cast()
        end
        --  empower_rune_weapon,if=(cooldown.pillar_of_frost.ready|target.1.time_to_die<20)&talent.breath_of_sindragosa.enabled&runic_power>60
        if S.EmpowerRuneWeapon:IsReady() and ((S.PillarofFrost:CooldownUpP() or (Target:TimeToDie() < 0 and Target:IsInBossList())) and S.BreathofSindragosa:IsAvailable() and Player:RunicPower() > 60) then
            return S.EmpowerRuneWeapon:Cast()
        end
        -- call_action_list,name=cold_heart,if=talent.cold_heart.enabled&((buff.cold_heart.stack>=10&debuff.razorice.stack=5)|target.1.time_to_die<=gcd)
        if (S.ColdHeart:IsAvailable() and ((Player:BuffStackP(S.ColdHeartBuff) >= 10 and Target:DebuffStackP(S.RazoriceDebuff) == 5) or (Target:TimeToDie() <= 0 and Target:IsInBossList()))) then
            if ColdHeart() ~= nil then
                return ColdHeart()
            end
        end
        -- frostwyrms_fury,if=(buff.pillar_of_frost.remains<=gcd|(buff.pillar_of_frost.remains<8&buff.unholy_strength.remains<=gcd&buff.unholy_strength.up))&buff.pillar_of_frost.up&azerite.icy_citadel.rank<=2
        if S.FrostwyrmsFury:IsReady() and ((Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() or (Player:BuffRemainsP(S.PillarofFrostBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) <= Player:GCD() and Player:BuffP(S.UnholyStrengthBuff))) and Player:BuffP(S.PillarofFrostBuff) and S.IcyCitadel:AzeriteRank() <= 2) then
            return S.FrostwyrmsFury:Cast()
        end
        -- frostwyrms_fury,if=(buff.icy_citadel.remains<=gcd|(buff.icy_citadel.remains<8&buff.unholy_strength.remains<=gcd&buff.unholy_strength.up))&buff.icy_citadel.up&azerite.icy_citadel.rank>2
        if S.FrostwyrmsFury:IsReady() and ((Player:BuffRemainsP(S.IcyCitadelBuff) <= Player:GCD() or (Player:BuffRemainsP(S.IcyCitadelBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) <= Player:GCD() and Player:BuffP(S.UnholyStrengthBuff))) and Player:BuffP(S.IcyCitadelBuff) and S.IcyCitadel:AzeriteRank() > 2) then
            return S.FrostwyrmsFury:Cast()
        end
        -- frostwyrms_fury,if=target.1.time_to_die<gcd|(target.1.time_to_die<cooldown.pillar_of_frost.remains&buff.unholy_strength.up)
        if S.FrostwyrmsFury:IsReady() and ((Target:TimeToDie() < 0 and Target:IsInBossList()) or ((Target:IsInBossList() and Target:TimeToDie() < 0) and Player:BuffP(S.UnholyStrengthBuff))) then
            return S.FrostwyrmsFury:Cast()
        end
    end

    Essences = function()
        -- blood_of_the_enemy,if=buff.pillar_of_frost.remains<10&cooldown.breath_of_sindragosa.remains|buff.pillar_of_frost.remains<10&!talent.breath_of_sindragosa.enabled
        if S.BloodOfTheEnemy:IsReady() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 10 and bool(S.BreathofSindragosa:CooldownRemainsP()) or Player:BuffRemainsP(S.PillarofFrostBuff) < 10 and not S.BreathofSindragosa:IsAvailable()) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- guardian_of_azeroth
        if S.GuardianOfAzeroth:IsReady() then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- chill_streak,if=buff.pillar_of_frost.remains<5|target.1.time_to_die<5
        if S.ChillStreak:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 5 or (Target:TimeToDie() < 0 and Target:IsInBossList())) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<11
        -- focused_azerite_beam,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
        if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff) or Player:BuffStackP(S.RecklessForceCounterBuff) < 11) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        if S.FocusedAzeriteBeam:IsReady() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosaBuff)) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- concentrated_flame,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up&dot.concentrated_flame_burn.remains=0
        if S.ConcentratedFlame:IsReady() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosaBuff) and Target:DebuffRemainsP(S.ConcentratedFlameDebuff) == 0) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- purifying_blast,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
        if S.PurifyingBlast:IsReady() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.r)) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- worldvein_resonance,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
        if S.WorldveinResonance:IsReady() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosaBuff)) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- ripple_in_space,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
        if S.RippleInSpace:IsReady() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosaBuff)) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- memory_of_lucid_dreams,if=buff.empower_rune_weapon.remains<5&buff.breath_of_sindragosa.up|(rune.time_to_2>gcd&runic_power<50)
        if S.MemoryOfLucidDreams:IsReady() and (Player:BuffRemainsP(S.EmpowerRuneWeaponBuff) < 5 and Player:BuffP(S.BreathofSindragosaBuff) or (Player:RuneTimeToX(2) > Player:GCD() and Player:RunicPower() < 50) and not S.BreathofSindragosa:IsAvailable()) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
    end

    Obliteration = function()
        -- remorseless_winter,if=talent.gathering_storm.enabled
        if S.RemorselessWinter:IsReady() and Cache.EnemiesCount[5] > 0 and (S.GatheringStorm:IsAvailable()) then
            return S.RemorselessWinter:Cast()
        end
        -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
        if S.Obliterate:IsReady("Melee") and (Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 3 then
            return S.Obliterate:Cast()
        end
        -- obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
        if S.Obliterate:IsReady("Melee") and (not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 3) then
            return S.Obliterate:Cast()
        end
        -- frostscythe,if=(buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance)))&spell_targets.frostscythe>=2
        if S.Frostscythe:IsReady() and ((bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) and Cache.EnemiesCount[8] >= 2) then
            return S.Frostscythe:Cast()
        end
        -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
        if S.Obliterate:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then
            return S.Obliterate:Cast()
        end
        -- obliterate,if=buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
        if S.Obliterate:IsReady("Melee") and (bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then
            return S.Obliterate:Cast()
        end
        -- glacial_advance,if=(!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd)&spell_targets.glacial_advance>=2
        if S.GlacialAdvance:IsReady() and ((not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) and Cache.EnemiesCount[30] >= 2) then
            return S.GlacialAdvance:Cast()
        end
        -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
        if S.HowlingBlast:IsReady(30, true) and (Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[10] >= 2) then
            return S.HowlingBlast:Cast()
        end
        -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd&!talent.frostscythe.enabled
        if S.FrostStrike:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD() and not S.Frostscythe:IsAvailable()) then
            return S.FrostStrike:Cast()
        end
        -- frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
        if S.FrostStrike:IsReady("Melee") and (not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) then
            return S.FrostStrike:Cast()
        end
        -- howling_blast,if=buff.rime.up
        if S.HowlingBlast:IsReady(30, true) and (Player:BuffP(S.RimeBuff)) then
            return S.HowlingBlast:Cast()
        end
        -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
        if S.Obliterate:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable()) then
            return S.Obliterate:Cast()
        end
        -- obliterate
        if S.Obliterate:IsReady("Melee") then
            return S.Obliterate:Cast()
        end
        return 0, 135328
    end

    Standard = function()
        -- remorseless_winter
        if S.RemorselessWinter:IsReady() and Cache.EnemiesCount[5] > 0 then
            return S.RemorselessWinter:Cast()
        end
        -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
        if S.FrostStrike:IsReady("Melee") and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
            return S.FrostStrike:Cast()
        end
        -- howling_blast,if=buff.rime.up
        if S.HowlingBlast:IsReady(30, true) and (Player:BuffP(S.RimeBuff)) then
            return S.HowlingBlast:Cast()
        end
        -- obliterate,if=!buff.frozen_pulse.up&talent.frozen_pulse.enabled
        if S.Obliterate:IsReady("Melee") and (not Player:BuffP(S.FrozenPulseBuff) and S.FrozenPulse:IsAvailable()) then
            return S.Obliterate:Cast()
        end
        -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
        if S.FrostStrike:IsReady("Melee") and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
            return S.FrostStrike:Cast()
        end
        -- frostscythe,if=buff.killing_machine.up&rune.time_to_4>=gcd
        if S.Frostscythe:IsReady() and Cache.EnemiesCount[8] >= 1 and (Player:BuffP(S.KillingMachineBuff) and Player:RuneTimeToX(4) >= Player:GCD()) then
            return S.Frostscythe:Cast()
        end
        -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
        if S.Obliterate:IsReady("Melee") and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
            return S.Obliterate:Cast()
        end
        -- frost_strike
        if S.FrostStrike:IsReady("Melee") then
            return S.FrostStrike:Cast()
        end
        -- horn_of_winter
        if S.HornofWinter:IsReady() and S.HornofWinter:IsAvailable() then
            return S.HornofWinter:Cast()
        end
        -- arcane_torrent
        if S.ArcaneTorrent:IsReady() then
            return S.ArcaneTorrent:Cast()
        end
    end
    if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) or Player:IsChanneling() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end 
    if not Player:AffectingCombat() then
        if Precombat() ~= nil then
            return Precombat()
        end
    end

    if Target:MinDistanceToPlayer(true) >= 15 and Target:MinDistanceToPlayer(true) <= 40 and S.DeathGrip:IsReady() and Target:IsQuestMob() then
        return S.DeathGrip:Cast()
    end
	
	if S.IceboundFortitude:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[251].sk2 then
        return S.IceboundFortitude:Cast()
    end

    --CUSTOM
    if (Player:Buff(S.DarkSuccor) or Player:BuffP(S.Transfusion)) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[251].sk1 then
        return S.DeathStrike:Cast()
    end

    if S.Transfusion:IsReady() and Player:HealthPercentage() < 40 then
        return S.Transfusion:Cast()
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
    if S.HowlingBlast:IsReady(30, true) and (not Target:DebuffP(S.FrostFeverDebuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
        return S.HowlingBlast:Cast()
    end
    -- glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.GlacialAdvance:IsReady() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and Cache.EnemiesCount[30] >= 2 and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.FrostStrike:IsReady("Melee") and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
        return S.FrostStrike:Cast()
    end
    -- call_action_list,name=essences
    if (RubimRH.CDsON()) then
        if Essences() ~= nil then
            return Essences()
        end
    end
    -- call_action_list,name=cooldowns
    if (true) then
        if Cooldowns() ~= nil then
            return Cooldowns()
        end
    end
    -- run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&((cooldown.breath_of_sindragosa.remains=0&cooldown.pillar_of_frost.remains<10)|(cooldown.breath_of_sindragosa.remains<20&target.1.time_to_die<35))
    if (RubimRH.CDsON() and S.BreathofSindragosa:IsAvailable() and ((S.BreathofSindragosa:CooldownRemainsP() == 0 and S.PillarofFrost:CooldownRemainsP() < 10) or (S.BreathofSindragosa:CooldownRemainsP() < 20 and (Target:TimeToDie() < 0 and Target:IsInBossList())))) then
        return BosPooling()
    end
    -- run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
    if (Player:BuffP(S.BreathofSindragosa)) then
        return BosTicking()
    end
    -- run_action_list,name=obliteration,if=buff.pillar_of_frost.up&talent.obliteration.enabled
    if (Player:BuffP(S.PillarofFrostBuff) and S.Obliteration:IsAvailable()) then
        return Obliteration()
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if Cache.EnemiesCount[10] >= 2 then
        return Aoe()
    end
    -- call_action_list,name=standard
    if (true) then
        if Standard() ~= nil then
            return Standard()
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(251, APL)
local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(251, PASSIVE)
