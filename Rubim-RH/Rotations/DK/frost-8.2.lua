--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL         = HeroLib
local Cache      = HeroCache
local Unit       = HL.Unit
local Player     = Unit.Player
local Target     = Unit.Target
local Pet        = Unit.Pet
local Spell      = HL.Spell
--local MultiSpell = HL.MultiSpell
local Item       = HL.Item

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[251] = {
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
  IcyCitadel                            = Spell(272718),
  IcyCitadelBuff                        = Spell(272719),
  MindFreeze                            = Spell(47528),
  CyclotronicBlast                      = Spell(167672),
  RecklessForceCounter                  = Spell(298409),
  RecklessForceCounter2                 = Spell(302917),
  RecklessForceBuff                     = Spell(302932),
  ConcentratedFlameBurn                 = Spell(295368),
  ChillStreak                           = Spell(305392),	
  DarkSuccor                            = Spell(101568),
  DeathsAdvance                         = Spell(48265),
  DeathGrip                             = Spell(49576),
  DeathPact                             = Spell(48743),
  IceboundFortitude                     = Spell(48792),
  NecroticStrike                        = Spell(223829),
  RaiseAlly                             = Spell(61999),
  DarkSimulacrum                        = Spell(77606),
  Asphyxiate                            = Spell(108194),
  AntiMagicShell                        = Spell(48707),
  --8.2 Essences
  UnleashHeartOfAzeroth                 = Spell(280431),
  BloodOfTheEnemy                       = Spell(297108),
  BloodOfTheEnemy2                      = Spell(298273),
  BloodOfTheEnemy3                      = Spell(298277),
  ConcentratedFlame                     = Spell(295373),
  ConcentratedFlame2                    = Spell(299349),
  ConcentratedFlame3                    = Spell(299353),
  GuardianOfAzeroth                     = Spell(295840),
  GuardianOfAzeroth2                    = Spell(299355),
  GuardianOfAzeroth3                    = Spell(299358),
  FocusedAzeriteBeam                    = Spell(295258),
  FocusedAzeriteBeam2                   = Spell(299336),
  FocusedAzeriteBeam3                   = Spell(299338),
  PurifyingBlast                        = Spell(295337),
  PurifyingBlast2                       = Spell(299345),
  PurifyingBlast3                       = Spell(299347),
  TheUnboundForce                       = Spell(298452),
  TheUnboundForce2                      = Spell(299376),
  TheUnboundForce3                      = Spell(299378),
  RippleInSpace                         = Spell(302731),
  RippleInSpace2                        = Spell(302982),
  RippleInSpace3                        = Spell(302983),
  WorldveinResonance                    = Spell(295186),
  WorldveinResonance2                   = Spell(298628),
  WorldveinResonance3                   = Spell(299334),
  MemoryOfLucidDreams                   = Spell(298357),
  MemoryOfLucidDreams2                  = Spell(299372),
  MemoryOfLucidDreams3                  = Spell(299374),
}

local S = RubimRH.Spell[251]

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Frost = {
  BattlePotionofStrength           = Item(163224),
  RazdunksBigRedButton             = Item(159611),
  MerekthasFang                    = Item(158367),
  KnotofAncientFuryAlliance        = Item(161413),
  KnotofAncientFuryHorde           = Item(166795),
  FirstMatesSpyglass               = Item(158163),
  GrongsPrimalRage                 = Item(165574),
  AzsharasFontofPower              = Item(169314),
  LurkersInsidiousGift             = Item(167866),
  PocketsizedComputationDevice     = Item(167555),
  AshvanesRazorCoral               = Item(169311),
  -- "Other On Use"
  NotoriousGladiatorsBadge         = Item(167380),
  NotoriousGladiatorsMedallion     = Item(167377),
  SinisterGladiatorsBadge          = Item(165058),
  SinisterGladiatorsMedallion      = Item(165055),
  VialofAnimatedBlood              = Item(159625),
  JesHowler                        = Item(159627)
};
local I = Item.DeathKnight.Frost;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- Trinket var
local trinket2 = 1030910
local trinket1 = 1030902

-- Trinket Ready
local function trinketReady(trinketPosition)
    local inventoryPosition
    
	if trinketPosition == 1 then
        inventoryPosition = 13
    end
    
	if trinketPosition == 2 then
        inventoryPosition = 14
    end
    
	local start, duration, enable = GetInventoryItemCooldown("Player", inventoryPosition)
    if enable == 0 then
        return false
    end

    if start + duration - GetTime() > 0 then
        return false
    end
	
	if RubimRH.db.profile.mainOption.useTrinkets[1] == false then
	    return false
	end
	
   	if RubimRH.db.profile.mainOption.useTrinkets[2] == false then
	    return false
	end	
	
    if RubimRH.db.profile.mainOption.trinketsUsage == "Everything" then
        return true
    end
	
	if RubimRH.db.profile.mainOption.trinketsUsage == "Boss Only" then
        if not UnitExists("boss1") then
            return false
        end

        if UnitExists("target") and not (UnitClassification("target") == "worldboss" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "rare") then
            return false
        end
    end	
    return true
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

-- Functions
local EnemyRanges = {10, 8}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i, true);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function DeathStrikeHeal()
  return Player:HealthPercentage() <= RubimRH.db.profile[251].sk1 and true or false;
end

--HL.RegisterNucleusAbility(196770, 8, 6)               -- Remorseless Winter
--HL.RegisterNucleusAbility(207230, 8, 6)               -- Frostscythe
--HL.RegisterNucleusAbility(49184, 10, 6)               -- Howling Blast

--- ======= ACTION LISTS =======
local function APL()
  local Precombat_DBM, Precombat, VarOoUE, Aoe, BosPooling, BosTicking, ColdHeart, Cooldowns, Essences, Obliteration, Standard
  local no_heal = not DeathStrikeHeal()
  UpdateRanges()
  DetermineEssenceRanks()
  
    -- Anti channeling interrupt
	if Player:IsChanneling() or Player:IsCasting() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end	

	Precombat_DBM = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
		--Prepots
        if I.BattlePotionofStrength:IsReady() and RubimRH.DBM_PullTimer() > 0.1 + Player:GCD() and RubimRH.DBM_PullTimer() < 0.5 + Player:GCD() then
            return 967532
        end
        -- opener
		--BreathofSindragosa
        if S.BreathofSindragosa:IsAvailable() and S.Obliterate:IsCastableP("Melee") and RubimRH.DBM_PullTimer() > 0.1 and RubimRH.DBM_PullTimer() < 0.5  then
            return S.Obliterate:Cast()
        end
		--HowlingBlast
        if S.HowlingBlast:IsCastableP(30, true) and not S.BreathofSindragosa:IsAvailable() and (not Target:DebuffP(S.FrostFeverDebuff)) and RubimRH.DBM_PullTimer() > 0.1 and RubimRH.DBM_PullTimer() < 0.5 then
            return S.HowlingBlast:Cast()
        end	
    end 
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- variable,name=other_on_use_equipped,value=(equipped.notorious_gladiators_badge|equipped.sinister_gladiators_badge|equipped.sinister_gladiators_medallion|equipped.vial_of_animated_blood|equipped.first_mates_spyglass|equipped.jes_howler|equipped.notorious_gladiators_medallion)
    if (true) then
      VarOoUE = (I.NotoriousGladiatorsBadge:IsEquipped() or I.SinisterGladiatorsBadge:IsEquipped() or I.SinisterGladiatorsMedallion:IsEquipped() or I.VialofAnimatedBlood:IsEquipped() or I.FirstMatesSpyglass:IsEquipped() or I.JesHowler:IsEquipped() or I.NotoriousGladiatorsMedallion:IsEquipped())
    end
    -- opener
    if S.BreathofSindragosa:IsAvailable() and S.Obliterate:IsCastableP("Melee") then
        return S.Obliterate:Cast()
    end
    if S.HowlingBlast:IsCastableP(30, true) and (not Target:DebuffP(S.FrostFeverDebuff)) then
        return S.HowlingBlast:Cast()
    end
 end
  
  Aoe = function()
    -- remorseless_winter,if=talent.gathering_storm.enabled|(azerite.frozen_tempest.rank&spell_targets.remorseless_winter>=3&!buff.rime.up)
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable() or (bool(S.FrozenTempest:AzeriteRank()) and Cache.EnemiesCount[8] >= 3 and not Player:BuffP(S.RimeBuff))) then
      return S.RemorselessWinter:Cast()
    end
    -- glacial_advance,if=talent.frostscythe.enabled
    if no_heal and S.GlacialAdvance:IsReadyP() and (S.Frostscythe:IsAvailable()) then
      return S.GlacialAdvance:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable() and not S.Frostscythe:IsAvailable()) then
      return S.FrostStrike:Cast()
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
      return S.FrostStrike:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff)) then
      return S.HowlingBlast:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up
    if S.Frostscythe:IsCastableP() and Cache.EnemiesCount[8] >= 1 and (Player:BuffP(S.KillingMachineBuff)) then
      return S.Frostscythe:Cast()
    end
    -- glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if no_heal and S.GlacialAdvance:IsReadyP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      return S.GlacialAdvance:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<(15+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
      return S.FrostStrike:Cast()
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
      return S.FrostStrike:Cast()
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      return S.RemorselessWinter:Cast()
    end
    -- frostscythe
    if S.Frostscythe:IsCastableP() and Cache.EnemiesCount[8] >= 1 then
      return S.Frostscythe:Cast()
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>(25+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
      return S.Obliterate:Cast()
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      return S.Obliterate:Cast()
    end
    -- glacial_advance
    if no_heal and S.GlacialAdvance:IsReadyP() then
      return S.GlacialAdvance:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable()) then
      return S.FrostStrike:Cast()
    end
    -- frost_strike
    if no_heal and S.FrostStrike:IsReadyP("Melee") then
      return S.FrostStrike:Cast()
    end
    -- horn_of_winter
    if S.HornofWinter:IsCastableP() then
      return S.HornofWinter:Cast()
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() then
      return S.ArcaneTorrent:Cast()
    end
  end
  
  BosPooling = function()
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff)) then
      return S.HowlingBlast:Cast()
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>=25&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() >= 25 and not S.Frostscythe:IsAvailable()) then
      return S.Obliterate:Cast()
    end
    -- obliterate,if=runic_power.deficit>=25
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPowerDeficit() >= 25) then
      return S.Obliterate:Cast()
    end
    -- glacial_advance,if=runic_power.deficit<20&spell_targets.glacial_advance>=2&cooldown.pillar_of_frost.remains>5
    if no_heal and S.GlacialAdvance:IsReadyP() and (Player:RunicPowerDeficit() < 20 and Cache.EnemiesCount[10] >= 2 and S.PillarofFrost:CooldownRemainsP() > 5) then
      return S.GlacialAdvance:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<20&!talent.frostscythe.enabled&cooldown.pillar_of_frost.remains>5
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < 20 and not S.Frostscythe:IsAvailable() and S.PillarofFrost:CooldownRemainsP() > 5) then
      return S.FrostStrike:Cast()
    end
    -- frost_strike,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>5
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > 5) then
      return S.FrostStrike:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up&runic_power.deficit>(15+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Player:RunicPowerDeficit() > (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and Cache.EnemiesCount[8] >= 2) then
      return S.Frostscythe:Cast()
    end
    -- frostscythe,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3) and Cache.EnemiesCount[8] >= 2) then
      return S.Frostscythe:Cast()
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
      return S.Obliterate:Cast()
    end
    -- obliterate,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      return S.Obliterate:Cast()
    end
    -- glacial_advance,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&spell_targets.glacial_advance>=2
    if no_heal and S.GlacialAdvance:IsReadyP() and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and Cache.EnemiesCount[10] >= 2) then
      return S.GlacialAdvance:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and not S.Frostscythe:IsAvailable()) then
      return S.FrostStrike:Cast()
    end
    -- frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40) then
      return S.FrostStrike:Cast()
    end
    -- wait for resources
    return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
  end
  
  BosTicking = function()
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power<=30&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPower() <= 30 and not S.Frostscythe:IsAvailable()) then
      return S.Obliterate:Cast()
    end
    -- obliterate,if=runic_power<=30
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPower() <= 32) then
      return S.Obliterate:Cast()
    end
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      return S.RemorselessWinter:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff)) then
      return S.HowlingBlast:Cast()
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&rune.time_to_5<gcd|runic_power<=45&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45 and not S.Frostscythe:IsAvailable()) then
      return S.Obliterate:Cast()
    end
    -- obliterate,if=rune.time_to_5<gcd|runic_power<=45
    if S.Obliterate:IsCastableP("Melee") and (Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45) then
      return S.Obliterate:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Cache.EnemiesCount[8] >= 2) then
      return S.Frostscythe:Cast()
    end
    -- horn_of_winter,if=runic_power.deficit>=32&rune.time_to_3>gcd
    if S.HornofWinter:IsCastableP() and (Player:RunicPowerDeficit() >= 30 and Player:RuneTimeToX(3) > Player:GCD()) then
      return S.HornofWinter:Cast()
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      return S.RemorselessWinter:Cast()
    end
    -- frostscythe,if=spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      return S.Frostscythe:Cast()
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>25|rune>3&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() > 25 or Player:Rune() > 3 and not S.Frostscythe:IsAvailable()) then
      return S.Obliterate:Cast()
    end
    -- obliterate,if=runic_power.deficit>25|rune>3
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPowerDeficit() > 25 or Player:Rune() > 3) then
      return S.Obliterate:Cast()
    end
    -- arcane_torrent,if=runic_power.deficit>20
    if S.ArcaneTorrent:IsCastableP() and (Player:RunicPowerDeficit() > 20) then
      return S.ArcaneTorrent:Cast()
    end
    -- wait for resources
    return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
  end
  
  ColdHeart = function()
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
  
  Cooldowns = function()
    -- use_item,name=azsharas_font_of_power,if=(cooldown.empowered_rune_weapon.ready&!variable.other_on_use_equipped)|(cooldown.pillar_of_frost.remains<=10&variable.other_on_use_equipped)
    if I.AzsharasFontofPower:IsReady() and ((S.EmpowerRuneWeapon:CooldownUpP() and not bool(VarOoUE)) or (S.PillarofFrost:CooldownRemainsP() <= 10 and bool(VarOoUE))) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_item,name=lurkers_insidious_gift,if=talent.breath_of_sindragosa.enabled&((cooldown.pillar_of_frost.remains<=10&variable.other_on_use_equipped)|(buff.pillar_of_frost.up&!variable.other_on_use_equipped))|(buff.pillar_of_frost.up&!talent.breath_of_sindragosa.enabled)
    if I.LurkersInsidiousGift:IsReady() and (S.BreathofSindragosa:IsAvailable() and ((S.PillarofFrost:CooldownRemainsP() <= 10 and bool(VarOoUE)) or (Player:BuffP(S.PillarofFrostBuff) and not bool(VarOoUE))) or (Player:BuffP(S.PillarofFrostBuff) and not S.BreathofSindragosa:IsAvailable())) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_item,name=cyclotronic_blast,if=!buff.pillar_of_frost.up
    if I.PocketsizedComputationDevice and S.CyclotronicBlast:IsAvailable() and (Player:BuffDownP(S.PillarofFrostBuff)) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_item,name=ashvanes_razor_coral,if=cooldown.empower_rune_weapon.remains>110|cooldown.breath_of_sindragosa.remains>90|time<50|target.1.time_to_die<21
    if I.AshvanesRazorCoral:IsReady() and (S.EmpowerRuneWeapon:CooldownRemainsP() > 110 or S.BreathofSindragosa:CooldownRemainsP() > 90 or HL.CombatTime() < 50 or Target:TimeToDie() < 21) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
    end
    -- use_items,if=(cooldown.pillar_of_frost.ready|cooldown.pillar_of_frost.remains>20)&(!talent.breath_of_sindragosa.enabled|cooldown.empower_rune_weapon.remains>95)
    if (S.PillarofFrost:CooldownUpP() or S.PillarofFrost:CooldownRemainsP() > 20) and (not S.BreathofSindragosa:IsAvailable() or S.EmpowerRuneWeaponBuff:CooldownRemainsP() > 95) then
      -- use_item,name=jes_howler,if=(equipped.lurkers_insidious_gift&buff.pillar_of_frost.remains)|(!equipped.lurkers_insidious_gift&buff.pillar_of_frost.remains<12&buff.pillar_of_frost.up)
      if I.JesHowler:IsReady() and ((I.LurkersInsidiousGift:IsEquipped() and Player:BuffP(S.PillarofFrostBuff)) or (not I.LurkersInsidiousGift:IsEquipped() and Player:BuffRemainsP(S.PillarofFrostBuff) < 12 and Player:BuffP(S.PillarofFrostBuff))) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
      end
      -- use_item,name=knot_of_ancient_fury,if=cooldown.empower_rune_weapon.remains>40
      -- Two lines, since Horde and Alliance versions of the trinket have different IDs
      if I.KnotofAncientFuryAlliance:IsReady() and (S.EmpowerRuneWeapon:CooldownRemainsP() > 40) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
      end
      if I.KnotofAncientFuryHorde:IsReady() and (S.EmpowerRuneWeapon:CooldownRemainsP() > 40) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
      end
      -- use_item,name=grongs_primal_rage,if=rune<=3&!buff.pillar_of_frost.up&(!buff.breath_of_sindragosa.up|!talent.breath_of_sindragosa.enabled)
      if I.GrongsPrimalRage:IsReady() and (Player:Rune() <= 3 and Player:BuffDownP(S.PillarofFrostBuff) and (Player:BuffDownP(S.BreathofSindragosa) or not S.BreathofSindragosa:IsAvailable())) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
      end
      -- use_item,name=razdunks_big_red_button
      if I.RazdunksBigRedButton:IsReady() then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
      end
      -- use_item,name=merekthas_fang,if=!dot.breath_of_sindragosa.ticking&!buff.pillar_of_frost.up
      if I.MerekthasFang:IsReady() and (not Player:BuffP(S.BreathofSindragosa) and not Player:BuffP(S.PillarofFrostBuff)) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
      end
      -- use_item,name=first_mates_spyglass,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
      if I.FirstMatesSpyglass:IsReady() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
        if trinketReady(1) then
            return trinket1
        elseif trinketReady(2) then
            return trinket2
        else
            return
        end
      end
    end
    -- potion,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if I.BattlePotionofStrength:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      return 967532
    end
    -- blood_fury,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if S.BloodFury:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      return S.BloodFury:Cast()
    end
    -- berserking,if=buff.pillar_of_frost.up
    if S.Berserking:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff)) then
      return S.Berserking:Cast()
    end
    -- pillar_of_frost,if=cooldown.empower_rune_weapon.remains
    if S.PillarofFrost:IsCastableP() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP())) then
      return S.PillarofFrost:Cast()
    end
    -- breath_of_sindragosa,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
    if S.BreathofSindragosa:IsCastableP() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP()) and bool(S.PillarofFrost:CooldownRemainsP())) then
      return S.BreathofSindragosa:Cast()
    end
    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&!talent.breath_of_sindragosa.enabled&rune.time_to_5>gcd&runic_power.deficit>=10|target.1.time_to_die<20
    if S.EmpowerRuneWeapon:IsCastableP() and (S.PillarofFrost:CooldownUpP() and not S.BreathofSindragosa:IsAvailable() and Player:RuneTimeToX(5) > Player:GCD() and Player:RunicPowerDeficit() >= 10 or Target:TimeToDie() < 20) then
      return S.EmpowerRuneWeapon:Cast()
    end
    -- empower_rune_weapon,if=(cooldown.pillar_of_frost.ready|target.time_to_die<20)&talent.breath_of_sindragosa.enabled&runic_power>60
    if S.EmpowerRuneWeapon:IsCastableP() and ((S.PillarofFrost:CooldownUpP() or Target:TimeToDie() < 20) and S.BreathofSindragosa:IsAvailable() and Player:RunicPower() > 60) then
      return S.EmpowerRuneWeapon:Cast()
    end
    -- call_action_list,name=cold_heart,if=talent.cold_heart.enabled&((buff.cold_heart.stack>=10&debuff.razorice.stack=5)|target.time_to_die<=gcd)
    if (S.ColdHeart:IsAvailable() and ((Player:BuffStackP(S.ColdHeartBuff) >= 10 and Target:DebuffStackP(S.RazoriceDebuff) == 5) or Target:TimeToDie() <= Player:GCD())) then
      local ShouldReturn = ColdHeart(); if ShouldReturn then return ShouldReturn; end
    end
    -- frostwyrms_fury,if=(buff.pillar_of_frost.remains<=gcd|(buff.pillar_of_frost.remains<8&buff.unholy_strength.remains<=gcd&buff.unholy_strength.up))&buff.pillar_of_frost.up&azerite.icy_citadel.rank<=2
    if S.FrostwyrmsFury:IsCastableP() and ((Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() or (Player:BuffRemainsP(S.PillarofFrostBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) <= Player:GCD() and Player:BuffP(S.UnholyStrengthBuff))) and Player:BuffP(S.PillarofFrostBuff) and S.IcyCitadel:AzeriteRank() <= 2) then
      return S.FrostwyrmsFury:Cast()
    end
    -- frostwyrms_fury,if=(buff.icy_citadel.remains<=gcd|(buff.icy_citadel.remains<8&buff.unholy_strength.remains<=gcd&buff.unholy_strength.up))&buff.icy_citadel.up&azerite.icy_citadel.rank>2
    if S.FrostwyrmsFury:IsCastableP() and ((Player:BuffRemainsP(S.IcyCitadelBuff) <= Player:GCD() or (Player:BuffRemainsP(S.IcyCitadelBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) <= Player:GCD() and Player:BuffP(S.UnholyStrengthBuff))) and Player:BuffP(S.IcyCitadelBuff) and S.IcyCitadel:AzeriteRank() > 2) then
      return S.FrostwyrmsFury:Cast()
    end
    -- frostwyrms_fury,if=target.time_to_die<gcd|(target.time_to_die<cooldown.pillar_of_frost.remains&buff.unholy_strength.up)
    if S.FrostwyrmsFury:IsCastableP() and (Target:TimeToDie() < Player:GCD() or (Target:TimeToDie() < S.PillarofFrost:CooldownRemainsP() and Player:BuffP(S.UnholyStrengthBuff))) then
      return S.FrostwyrmsFury:Cast()
    end
  end
  
  Essences = function()
    -- blood_of_the_enemy,if=buff.pillar_of_frost.remains<10&cooldown.breath_of_sindragosa.remains|buff.pillar_of_frost.remains<10&!talent.breath_of_sindragosa.enabled
    if S.BloodoftheEnemy:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 10 and bool(S.BreathofSindragosa:CooldownRemainsP()) or Player:BuffRemainsP(S.PillarofFrostBuff) < 10 and not S.BreathofSindragosa:IsAvailable()) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth
    if S.GuardianOfAzeroth:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- chill_streak,if=buff.pillar_of_frost.remains<5|target.1.time_to_die<5
    if S.ChillStreak:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 5 or Target:TimeToDie() < 5) then
      return S.ChillStreak:Cast()
    end
    -- the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<11
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff) or Player:BuffStackP(S.RecklessForceCounter) < 11) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- focused_azerite_beam,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
    if S.FocusedAzeriteBeam:IsCastableP() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosa)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up&dot.concentrated_flame_burn.remains=0
    if S.ConcentratedFlame:IsCastableP() and (Player:BuffDownP(S.PillarofFrostBuff) and Player:BuffDownP(S.BreathofSindragosa) and Target:DebuffDownP(S.ConcentratedFlameBurn)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
    if S.PurifyingBlast:IsCastableP() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosa)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
    if S.WorldveinResonance:IsCastableP() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosa)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
    if S.RippleInSpace:IsCastableP() and (not Player:BuffP(S.PillarofFrostBuff) and not Player:BuffP(S.BreathofSindragosa)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams,if=buff.empower_rune_weapon.remains<5&buff.breath_of_sindragosa.up|(rune.time_to_2>gcd&runic_power<50)
    if S.MemoryOfLucidDreams:IsCastableP() and (Player:BuffRemainsP(S.EmpowerRuneWeaponBuff) < 5 and Player:BuffP(S.BreathofSindragosa) or (Player:RuneTimeToX(2) > Player:GCD() and Player:RunicPower() < 50)) then
      return S.UnleashHeartOfAzeroth:Cast()
    end
  end
  
  Obliteration = function()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      return S.RemorselessWinter:Cast()
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[10] >= 3) then
      return S.Obliterate:Cast()
    end
    -- obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsCastableP("Melee") and (not S.Frostscythe:IsAvailable() and not Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[10] >= 3) then
      return S.Obliterate:Cast()
    end
    -- frostscythe,if=(buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance)))&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and ((bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) and Cache.EnemiesCount[8] >= 2) then
      return S.Frostscythe:Cast()
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then
      return S.Obliterate:Cast()
    end
    -- obliterate,if=buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsCastableP("Melee") and (bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then
      return S.Obliterate:Cast()
    end
    -- glacial_advance,if=(!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd)&spell_targets.glacial_advance>=2
    if no_heal and S.GlacialAdvance:IsReadyP() and ((not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) and Cache.EnemiesCount[10] >= 2) then
      return S.GlacialAdvance:Cast()
    end
    -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[10] >= 2) then
      return S.HowlingBlast:Cast()
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD() and not S.Frostscythe:IsAvailable()) then
      return S.FrostStrike:Cast()
    end
    -- frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (not Player:BuffP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) then
      return S.FrostStrike:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff)) then
      return S.HowlingBlast:Cast()
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable()) then
      return S.Obliterate:Cast()
    end
    -- obliterate
    if S.Obliterate:IsCastableP("Melee") then
      return S.Obliterate:Cast()
    end
  end
  
  Standard = function()
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      return S.RemorselessWinter:Cast()
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
      return S.FrostStrike:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff)) then
      return S.HowlingBlast:Cast()
    end
    -- obliterate,if=!buff.frozen_pulse.up&talent.frozen_pulse.enabled
    if S.Obliterate:IsCastableP("Melee") and (not Player:BuffP(S.FrozenPulseBuff) and S.FrozenPulse:IsAvailable()) then
      return S.Obliterate:Cast()
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      return S.FrostStrike:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up&rune.time_to_4>=gcd
    if S.Frostscythe:IsCastableP() and Cache.EnemiesCount[8] >= 1 and (Player:BuffP(S.KillingMachineBuff) and Player:RuneTimeToX(4) >= Player:GCD()) then
      return S.Frostscythe:Cast()
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      return S.Obliterate:Cast()
    end
    -- frost_strike
    if no_heal and S.FrostStrike:IsReadyP("Melee") then
      return S.FrostStrike:Cast()
    end
    -- horn_of_winter
    if S.HornofWinter:IsCastableP() then
      return S.HornofWinter:Cast()
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() then
      return S.ArcaneTorrent:Cast()
    end
  end
    
    -- call DBM precombat
	if not Player:AffectingCombat() and RubimRH.PrecombatON() and RubimRH.PerfectPullON() then
        if Precombat_DBM() ~= nil then
            return Precombat_DBM()
        end
	end

    -- call NON DBM precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and not RubimRH.PerfectPullON() then
        if Precombat() ~= nil then
            return Precombat()
        end
    end
  
  -- In Combat
  if RubimRH.TargetIsValid() then
  
    --Mov Speed
    if Player:MovingFor() >= 1 and S.DeathsAdvance:IsReadyMorph() then
        return S.DeathsAdvance:Cast()
    end
    -- Antimagic Shell
	if S.AntiMagicShell:IsAvailable() and S.AntiMagicShell:CooldownRemainsP() < 0.1 and Player:HealthPercentage() <= RubimRH.db.profile[251].sk5 then
        return S.AntiMagicShell:Cast()
    end
    --Queueskill system
    if QueueSkill() ~= nil then
        if RubimRH.QueuedSpell():ID() == S.BreathofSindragosa:ID() then
            if Player:Buff(S.EmpowerRuneWeapon) and Player:Buff(S.PillarofFrost) then
                return QueueSkill()
            end
        else
            return QueueSkill()
        end
    end
    --Death Grip
    if Target:MinDistanceToPlayer(true) >= 15 and Target:MinDistanceToPlayer(true) <= 40 and S.DeathGrip:IsReady() and Target:IsQuestMob() then
        return S.DeathGrip:Cast()
    end
	--icebound Fortitude
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
    --Death Strike old
    if S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[251].sk2 then
        if S.DeathStrike:IsUsable() then
            return S.DeathStrike:Cast()
        else
            S.DeathStrike:Queue()
            return 0, 135328
        end
    end
    --Death Pact
    if S.DeathPact:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[251].sk4 then
        return S.DeathPact:Cast()
    end
    --Interrupt
    if S.MindFreeze:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.MindFreeze:Cast()
    end  
    -- use DeathStrike on low HP in Solo Mode
    if not no_heal and S.DeathStrike:IsReadyP("Melee") then
      return S.DeathStrike:Cast()
    end
    -- use DeathStrike with Proc in Solo Mode
    --if S.DeathStrike:IsReadyP("Melee") and Player:BuffP(S.DeathStrikeBuff) then
   --   return S.DeathStrike:Cast()
   -- end
    -- auto_attack
    -- howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.HowlingBlast:IsCastableP(30, true) and (not Target:DebuffP(S.FrostFeverDebuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      return S.HowlingBlast:Cast()
    end
    -- glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if no_heal and S.GlacialAdvance:IsReadyP() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and Cache.EnemiesCount[10] >= 2 and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      return S.FrostStrike:Cast()
    end
    -- call_action_list,name=essences
    if (true) then
      local ShouldReturn = Essences(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cooldowns
    if (RubimRH.CDsON()) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&((cooldown.breath_of_sindragosa.remains=0&cooldown.pillar_of_frost.remains<10)|(cooldown.breath_of_sindragosa.remains<20&target.time_to_die<35))
    if (RubimRH.CDsON() and S.BreathofSindragosa:IsAvailable() and ((S.BreathofSindragosa:CooldownRemainsP() == 0 and S.PillarofFrost:CooldownRemainsP() < 10) or (S.BreathofSindragosa:CooldownRemainsP() < 20 and Target:TimeToDie() < 35))) then
      return BosPooling();
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
    if RubimRH.AoEON() and Cache.EnemiesCount[10] >= 2 then
      return Aoe();
    end
    -- call_action_list,name=standard
    if (true) then
      local ShouldReturn = Standard(); if ShouldReturn then return ShouldReturn; end
    end
    -- nothing to cast, wait for resouces
    return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
  end
end


RubimRH.Rotation.SetAPL(251, APL)
local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(251, PASSIVE)
