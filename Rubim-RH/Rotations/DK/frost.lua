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
	
	-- Azerite
	IcyCitadel                            = Spell(272718),
    IcyCitadelBuff                        = Spell(272719),
	
	  --8.2 Essences
  UnleashHeartOfAzeroth = Spell(280431),
  BloodOfTheEnemy       = Spell(297108),
  BloodOfTheEnemy2      = Spell(298273),
  BloodOfTheEnemy3      = Spell(298277),
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
-- Rotation Var
local ShouldReturn; -- Used to get the return string
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
end

-- # Essences
local function Essences()
  -- blood_of_the_enemy
  if S.BloodOfTheEnemy:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- concentrated_flame
  if S.ConcentratedFlame:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- guardian_of_azeroth
  if S.GuardianOfAzeroth:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- focused_azerite_beam
  if S.FocusedAzeriteBeam:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- purifying_blast
  if S.PurifyingBlast:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- the_unbound_force
  if S.TheUnboundForce:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- ripple_in_space
  if S.RippleInSpace:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- worldvein_resonance
  if S.WorldveinResonance:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- memory_of_lucid_dreams,if=fury<40&buff.metamorphosis.up
  if S.MemoryOfLucidDreams:IsCastableP() and Player:Fury() < 40 and bool(Player:BuffP(S.MetamorphosisBuff)) then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  return false
end

local function Aoe()
    -- remorseless_winter,if=talent.gathering_storm.enabled|(azerite.frozen_tempest.rank&spell_targets.remorseless_winter>=3&!buff.rime.up)
    if S.RemorselessWinter:IsReady() and (S.GatheringStorm:IsAvailable() or (bool(S.FrozenTempest:AzeriteRank()) and Cache.EnemiesCount[8] >= 3 and not Player:BuffP(S.RimeBuff))) then
        return S.RemorselessWinter:Cast()
    end
    -- glacial_advance,if=talent.frostscythe.enabled
    if S.GlacialAdvance:IsReadyP() and (S.Frostscythe:IsAvailable()) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled&!talent.frostscythe.enabled
    if S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable() and not S.Frostscythe:IsAvailable()) then
        return S.FrostStrike:Cast()
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsReadyP("Melee") and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
        return S.FrostStrike:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsReady(30, true) and (Player:BuffP(S.RimeBuff)) then
        return S.HowlingBlast:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up
    if S.Frostscythe:IsReady() and Cache.EnemiesCount[8] >= 2 and (Player:BuffP(S.KillingMachineBuff)) then
        return S.Frostscythe:Cast()
    end
    -- glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.GlacialAdvance:IsReadyP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<(15+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
        return S.FrostStrike:Cast()
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.FrostStrike:IsReadyP("Melee") and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
        return S.FrostStrike:Cast()
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsReady() then
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
    if S.GlacialAdvance:IsReadyP() then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
    if S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable()) then
        return S.FrostStrike:Cast()
    end
    -- frost_strike
    if S.FrostStrike:IsReadyP("Melee") then
        return S.FrostStrike:Cast()
    end
    -- horn_of_winter
    if S.HornofWinter:CooldownRemainsP() < 0.1 and S.HornofWinter:IsAvailable() then
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
    if S.HowlingBlast:IsReady(30, true) and (Player:BuffP(S.RimeBuff)) then
        return S.HowlingBlast:Cast()
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&rune.time_to_4<gcd&runic_power.deficit>=25&!talent.frostscythe.enabled
    if S.Obliterate:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RuneTimeToX(4) < Player:GCD() and Player:RunicPowerDeficit() >= 25 and not S.Frostscythe:IsAvailable()) then
        return S.Obliterate:Cast()
    end
    -- obliterate,if=rune.time_to_4<gcd&runic_power.deficit>=25
    if S.Obliterate:IsReady("Melee") and (Player:RuneTimeToX(4) < Player:GCD() and Player:RunicPowerDeficit() >= 25) then
        return S.Obliterate:Cast()
    end
    -- glacial_advance,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsReadyP() and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Cache.EnemiesCount[30] >= 2) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4
    if S.FrostStrike:IsReadyP("Melee") and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4)) then
        return S.FrostStrike:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4&!talent.frostscythe.enabled
    if S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and not S.Frostscythe:IsAvailable()) then
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
    if S.GlacialAdvance:IsReadyP() and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and Cache.EnemiesCount[30] >= 2) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&!talent.frostscythe.enabled
    if S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and not S.Frostscythe:IsAvailable()) then
        return S.FrostStrike:Cast()
    end
    -- frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40
    if S.FrostStrike:IsReadyP("Melee") and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40) then
        return S.FrostStrike:Cast()
    end
    return 0, 135328
end

local function BosTicking()
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power<=30&!talent.frostscythe.enabled
    if S.Obliterate:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPower() <= 30 and not S.Frostscythe:IsAvailable()) then
        return S.Obliterate:Cast()
    end
    -- obliterate,if=runic_power<=30
    if S.Obliterate:IsReady("Melee") and (Player:RunicPower() <= 30) then
        return S.Obliterate:Cast()
    end
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsReady() and (S.GatheringStorm:IsAvailable()) then
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
    -- horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
    if S.HornofWinter:CooldownRemainsP() < 0.1 and S.HornofWinter:IsAvailable() and (Player:RunicPowerDeficit() >= 30 and Player:RuneTimeToX(3) > Player:GCD()) then
        return S.HornofWinter:Cast()
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsReady() then
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

local function ColdHeart()
	-- chains_of_ice,if=buff.cold_heart.stack>5&target.time_to_die<gcd
    if S.ChainsofIce:IsCastableP() and (Player:BuffStackP(S.ColdHeartBuff) > 5 and Target:TimeToDie() < Player:GCD()) then
        return S.ChainsofIce:Cast()
    end
    -- chains_of_ice,if=(buff.pillar_of_frost.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.pillar_of_frost.remains<rune.time_to_3)&buff.pillar_of_frost.up&azerite.icy_citadel.rank<=2
    if S.ChainsofIce:IsCastableP() and ((Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) or Player:BuffRemainsP(S.PillarofFrostBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.PillarofFrostBuff) and S.IcyCitadel:AzeriteRank() <= 2) then
        return S.ChainsofIce:Cast()
    end
    -- chains_of_ice,if=buff.pillar_of_frost.remains<8&buff.unholy_strength.remains<gcd*(1+cooldown.frostwyrms_fury.ready)&buff.unholy_strength.remains&buff.pillar_of_frost.up&azerite.icy_citadel.rank<=2
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) < Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) and Player:BuffP(S.UnholyStrengthBuff) and Player:BuffP(S.PillarofFrostBuff) and S.IcyCitadel:AzeriteRank() <= 2) then
        return S.ChainsofIce:Cast()
    end
    -- chains_of_ice,if=(buff.icy_citadel.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.icy_citadel.remains<rune.time_to_3)&buff.icy_citadel.up&azerite.icy_citadel.enabled&azerite.icy_citadel.rank>2
    if S.ChainsofIce:IsCastableP() and ((Player:BuffRemainsP(S.IcyCitadelBuff) <= Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) or Player:BuffRemainsP(S.IcyCitadelBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.IcyCitadelBuff) and S.IcyCitadel:AzeriteEnabled() and S.IcyCitadel:AzeriteRank() > 2) then
        return S.ChainsofIce:Cast()
    end
    -- chains_of_ice,if=buff.icy_citadel.remains<8&buff.unholy_strength.remains<gcd*(1+cooldown.frostwyrms_fury.ready)&buff.unholy_strength.remains&buff.icy_citadel.up&!azerite.icy_citadel.enabled&azerite.icy_citadel.rank>2
    -- This will always return false based on the last two checks, ignoring the "not enabled" check as that wasn't in the other updates on 1/12
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.IcyCitadelBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) < Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) and Player:BuffP(S.UnholyStrengthBuff) and Player:BuffP(S.IcyCitadelBuff) and S.IcyCitadel:AzeriteRank() > 2) then
        return S.ChainsofIce:Cast()
    end	
end

local function Cooldowns()
	-- actions.cds+=/call_action_list,name=essences
-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn then return ShouldReturn; end
    -- use_items,if=(cooldown.pillar_of_frost.ready|cooldown.pillar_of_frost.remains>20)&(!talent.breath_of_sindragosa.enabled|cooldown.empower_rune_weapon.remains>95)
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
    if S.PillarofFrost:IsCastable() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP())) then
        return S.PillarofFrost:Cast()
    end
    -- breath_of_sindragosa,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
    if S.BreathofSindragosa:IsReady() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP()) and bool(S.PillarofFrost:CooldownRemainsP())) then
        return S.BreathofSindragosa:Cast()
    end
    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&!talent.breath_of_sindragosa.enabled&rune.time_to_5>gcd&runic_power.deficit>=10
    if S.EmpowerRuneWeapon:IsCastable() and (S.PillarofFrost:CooldownUpP() and not S.BreathofSindragosa:IsAvailable() and Player:RuneTimeToX(5) > Player:GCD() and Player:RunicPowerDeficit() >= 10) then
        return S.EmpowerRuneWeapon:Cast()
    end
    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&talent.breath_of_sindragosa.enabled&rune>=3&runic_power>60
    if S.EmpowerRuneWeapon:IsCastable() and (S.PillarofFrost:CooldownUpP() and S.BreathofSindragosa:IsAvailable() and Player:Rune() >= 3 and Player:RunicPower() > 60) then
        return S.EmpowerRuneWeapon:Cast()
    end
    -- call_action_list,name=cold_heart,if=talent.cold_heart.enabled&((buff.cold_heart.stack>=10&debuff.razorice.stack=5)|target.time_to_die<=gcd)
    if (S.ColdHeart:IsAvailable() and ((Player:BuffStackP(S.ColdHeartBuff) >= 10 and Target:DebuffStackP(S.RazoriceDebuff) == 5) or Target:TimeToDie() <= Player:GCD())) then
        if ColdHeart() ~= nil then
            return ColdHeart()
        end
    end
    -- frostwyrms_fury,if=buff.pillar_of_frost.remains<=gcd&buff.pillar_of_frost.up
    if S.FrostwyrmsFury:IsReady() and (Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() and Player:BuffP(S.PillarofFrostBuff)) then
        return S.FrostwyrmsFury:Cast()
    end
end

local function Obliteration()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsReady() and (S.GatheringStorm:IsAvailable()) then
        return S.RemorselessWinter:Cast()
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsReady("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[30] >= 3) then
        return S.Obliterate:Cast()
    end
    -- obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsReady("Melee") and (not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[10] >= 3) then
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
    if S.GlacialAdvance:IsReadyP() and ((not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) and Cache.EnemiesCount[30] >= 2) then
        return S.GlacialAdvance:Cast()
    end
    -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
    if S.HowlingBlast:IsReady(30, true) and (Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[10] >= 2) then
        return S.HowlingBlast:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd&!talent.frostscythe.enabled
    if S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD() and not S.Frostscythe:IsAvailable()) then
        return S.FrostStrike:Cast()
    end
    -- frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
    if S.FrostStrike:IsReadyP("Melee") and (not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) then
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

local function Standard()
    -- remorseless_winter
    if S.RemorselessWinter:IsReady() then
        return S.RemorselessWinter:Cast()
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsReadyP("Melee") and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
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
    if S.FrostStrike:IsReadyP("Melee") and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
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
    if S.FrostStrike:IsReadyP("Melee") then
        return S.FrostStrike:Cast()
    end
    -- horn_of_winter
    if S.HornofWinter:CooldownRemainsP() < 0.1 and S.HornofWinter:IsAvailable() then
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
    -- Antimagic Shell
	if S.AntiMagicShell:IsAvailable() and S.AntiMagicShell:CooldownRemainsP() < 0.1 and Player:HealthPercentage() <= RubimRH.db.profile[251].sk5 then
        return S.AntiMagicShell:Cast()
    end
	
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and not Target:IsQuestMob() then
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
	
	if S.IceboundFortitude:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[251].sk2 then
        return S.IceboundFortitude:Cast()
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
    if S.HowlingBlast:IsReady(30, true) and (not Target:DebuffP(S.FrostFeverDebuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
        return S.HowlingBlast:Cast()
    end
    -- glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.GlacialAdvance:IsReadyP() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and Cache.EnemiesCount[30] >= 2 and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
        return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.FrostStrike:IsReadyP("Melee") and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
        return S.FrostStrike:Cast()
    end
    -- call_action_list,name=cooldowns
    if (RubimRH.CDsON()) then
        if Cooldowns() ~= nil then
            return Cooldowns()
        end
    end
    -- run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<5
    if (RubimRH.CDsON() and S.BreathofSindragosa:IsAvailable() and S.BreathofSindragosa:CooldownRemainsP() < 5) then
        return BosPooling()
    end
    -- run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
    if (Player:BuffP(S.BreathofSindragosa)) then
        return BosTicking();
    end
    -- run_action_list,name=obliteration,if=buff.pillar_of_frost.up&talent.obliteration.enabled
    if (Player:BuffP(S.PillarofFrostBuff) and S.Obliteration:IsAvailable()) then
        return Obliteration();
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if RubimRH.AoEON() and active_enemies() >= 2 then
        return Aoe();
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
