local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")

local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

-- Spell Localization
RubimRH.Spell[104] = {
    -- Racials
    WarStomp = Spell(20549),
    Berserking = Spell(26297),
    -- Abilities
    FrenziedRegeneration = Spell(22842),
    Gore = Spell(210706),
    GoreBuff = Spell(93622),
    GoryFur = Spell(201671),
    Ironfur = Spell(192081),
    Mangle = Spell(33917),
    Maul = Spell(6807),
    Moonfire = Spell(8921),
    MoonfireDebuff = Spell(164812),
    Sunfire = Spell(197630),
    SunfireDebuff = Spell(164815),
    Starsurge = Spell(197626),
    LunarEmpowerment = Spell(164547),
    SolarEmpowerment = Spell(164545),
    LunarStrike = Spell(197628),
    Wrath = Spell(197629),
    Regrowth = Spell(8936),
    Swipe = Spell(213771),
    Thrash = Spell(77758),
    ThrashDebuff = Spell(192090),
    ThrashCat = Spell(106830),
    Prowl = Spell(5215),
    -- Talents
    BalanceAffinity = Spell(197488),
    BloodFrenzy = Spell(203962),
    Brambles = Spell(203953),
    BristlingFur = Spell(155835),
    Earthwarden = Spell(203974),
    EarthwardenBuff = Spell(203975),
    FeralAffinity = Spell(202155),
    GalacticGuardian = Spell(203964),
    GalacticGuardianBuff = Spell(213708),
    GuardianOfElune = Spell(155578),
    GuardianOfEluneBuff = Spell(213680),
    Incarnation = Spell(102558),
    LunarBeam = Spell(204066),
    Pulverize = Spell(80313),
    PulverizeBuff = Spell(158792),
    RestorationAffinity = Spell(197492),
    SouloftheForest = Spell(158477),
    MightyBash = Spell(5211),
    Typhoon = Spell(132469),
    Entanglement = Spell(102359),
    -- Artifact
    RageoftheSleeper = Spell(200851),
    -- Defensive
    SurvivalInstincts = Spell(61336),
    Barkskin = Spell(22812),
    -- Utility
    Growl = Spell(6795),
    SkullBash = Spell(106839),
    -- Affinity
    FerociousBite = Spell(22568),
    HealingTouch = Spell(5185),
    Rake = Spell(1822),
    RakeDebuff = Spell(155722),
    Rejuvenation = Spell(774),
    Rip = Spell(1079),
    Shred = Spell(5221),
    Swiftmend = Spell(18562),
    -- Shapeshift
    BearForm = Spell(5487),
    CatForm = Spell(768),
    MoonkinForm = Spell(197625),
    TravelForm = Spell(783),
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

local S = RubimRH.Spell[104]
-- Optional debug to chat window
local PrintDebug = false
-- Item localization // Declaration
if not Item.Druid then Item.Druid = {} end
Item.Druid.Guardian = { EkowraithCreatorofWorlds = Item(137015, {5}), LuffaWrappings = Item(137056, {9}) }
local I = Item.Druid.Guardian
-- Rotation Var
local ShouldReturn; -- Used to get the return string
-- Range array declaration
local RangeMod = S.BalanceAffinity:IsAvailable() and true or false
local R = {
	Moonfire = (RangeMod) and 43 or 40,
	Mangle = (RangeMod) and 8 or "Melee",
	Thrash = (RangeMod) and 11 or 8,
	Swipe = (RangeMod) and 11 or 8,
	Maul = (RangeMod) and 8 or "Melee",
	Pulverize = (RangeMod) and 8 or "Melee",
	SkullBash = (RangeMod) and 13 or 10 }
-- Keep track of whether or not we're tanking
local IsTanking = false

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
  if S.MemoryOfLucidDreams:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  return false
end

local function Bear()
	--- Defensives / Healing

	-- Bristling Fur
	if S.BristlingFur:IsReady()
			and (Player:NeedMinorHealing() or Player:NeedMajorHealing()) then
		return S.BristlingFur:Cast()
	end

	-- Survival Instincts
	if S.SurvivalInstincts:ChargesFractional() >= 1
			and not Player:BuffP(S.Barkskin)
			and not Player:BuffP(S.SurvivalInstincts)
			and Player:NeedPanicHealing() then
		return S.SurvivalInstincts:Cast()
	end

	-- TODO: Fix texture after GGLoader properly updates the Barkskin pixels
	-- Barkskin
	if S.Barkskin:IsReady()
			and not Player:BuffP(S.SurvivalInstincts)
			and not Player:BuffP(S.Barkskin)
			and Player:NeedMajorHealing() then
		return S.Barkskin:Cast()
	end

	-- Ironfur
	if S.Ironfur:IsReady()
			and Player:BuffRemainsP(S.Ironfur) <= Player:GCD()
			and (IsTanking or Player:NeedMinorHealing()) then
		return S.Ironfur:Cast()
	end

	-- Frenzied Regeneration
	local FrenziedRegenerationHeal = (Player:BuffP(S.GuardianOfEluneBuff)) and 21 or 18
	local FrenziedOverHeal = (FrenziedRegenerationHeal + Player:HealthPercentage() >= 100) and true or false
	if S.FrenziedRegeneration:IsReady()
		and not FrenziedOverHeal
		and (Player:NeedMinorHealing() or Player:NeedMajorHealing() or Player:NeedPanicHealing()) then
		return S.FrenziedRegeneration:Cast()
	end

	--- Main Damage Rotation

	-- Moonfire
	if Target:DebuffRemainsP(S.MoonfireDebuff) <= Player:GCD()
			and S.Moonfire:IsReadyMorph(R.Moonfire) then
		return S.Moonfire:Cast()
	end

	-- Thrash
	if S.Thrash:IsReadyMorph(R.Thrash, true)
			and Target:DebuffStack(S.ThrashDebuff) < 3 then
		return S.Thrash:Cast()
	end

	-- Pulverize
	if Target:DebuffStack(S.ThrashDebuff) == 3
			and S.Pulverize:IsReadyMorph(R.Pulverize) then
		return S.Pulverize:Cast()
	end

	-- Mangle
	if S.Mangle:IsReadyMorph(R.Mangle) then
		return S.Mangle:Cast()
	end

	-- Thrash
	if S.Thrash:IsReadyMorph(R.Thrash, true) then
		return S.Thrash:Cast()
	end

	-- Moonfire
	if S.Moonfire:IsReadyMorph(R.Moonfire)
			and Player:BuffP(S.GalacticGuardianBuff) then
		return S.Moonfire:Cast()
	end

	-- Maul
	if S.Maul:IsReady(R.Maul)
			and Player:Rage() >= 90 then
		return S.Maul:Cast()
	end

	-- Swipe -> Requires IsReadyMorph
	if S.Swipe:IsReadyMorph(R.Swipe, true) then
		return S.Swipe:Cast()
	end
end

-- TODO: Cat AoE
local function Cat()
	local CatWeave = S.FeralAffinity:IsAvailable()
	if CatWeave then
		if Player:ComboPoints() == 5
				and Target:DebuffRemainsP(S.Rip) <= Player:GCD() * 5
				and S.Rip:IsReadyMorph("Melee") then
			return S.Rip:Cast()
		end

		if Player:ComboPoints() == 5
				and Target:DebuffRemainsP(S.Rip) >= Player:GCD() * 5
				and S.FerociousBite:IsReadyMorph("Melee") then
			return S.FerociousBite:Cast()
		end

		if Player:ComboPoints() <= 5
				and Target:DebuffRemainsP(S.RakeDebuff) <= Player:GCD() then
			return S.Rake:Cast()
		end
	end

	if S.ThrashCat:IsReadyMorph("Melee")
			and Target:DebuffRemainsP(S.ThrashCat) <= Player:GCD() then
		return S.ThrashCat:Cast()
	end

	return S.Shred:Cast()
end

local function Moonkin()
	-- Base cast range for Balance Affinity is 43 yards on all abilities
	local R = 43

	-- Moonfire
	if S.Moonfire:IsReadyMorph(R.Moonfire)
			and (Target:DebuffRemainsP(S.MoonfireDebuff) <= Player:GCD() or Player:BuffP(S.GalacticGuardianBuff)) then
		return S.Moonfire:Cast()
	end

	-- Sunfire
	if S.Sunfire:IsReadyMorph(R.Moonfire)
			and Target:DebuffRemainsP(S.SunfireDebuff) <= Player:GCD() then
		return S.Sunfire:Cast()
	end

	-- Stationary damage rotation
	if not Player:IsMoving() then

		-- Starsurge
		if S.Starsurge:IsReadyMorph(R.Moonfire)
				and not Player:BuffP(S.LunarEmpowerment)
				and not Player:BuffP(S.SolarEmpowerment) then
			return S.Starsurge:Cast()
		end

		-- Lunar Strike
		if S.LunarStrike:IsReadyMorph(R.Moonfire) and
				Player:BuffP(S.LunarEmpowerment) then
			return S.LunarStrike:Cast()
		end

		-- Wrath spam
		if S.Wrath:IsReadyMorph(R.Moonfire) then return S.Wrath:Cast() end
	else
		-- Moonfire spam on the move
		if S.Moonfire:IsReadyMorph(R.Moonfire) then return S.Moonfire:Cast() end
	end

	return nil
end

local function UpdateVars()
	-- Check if we're tanking
	IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target)
	-- Determine if the player is using the Balance affinity
	RangeMod = S.BalanceAffinity:IsAvailable() and true or false
	-- Reevaluate ranges -> If player's spec has changed to Balance Affinity
	R.Moonfire = (RangeMod) and 43 or 40
	R.Mangle = (RangeMod) and 8 or "Melee"
	R.Thrash = (RangeMod) and 11 or 8
	R.Swipe = (RangeMod) and 11 or 8
	R.Maul = (RangeMod) and 8 or "Melee"
	R.Pulverize = (RangeMod) and 8 or "Melee"
	R.SkullBash = (RangeMod) and 13 or 10
	-- Adjust Thrash range if player has Luffa Wrappings equipped 
	R.Thrash = (I.LuffaWrappings:IsEquipped()) and R.Thrash * 1.25 or R.Thrash
	-- Update enemies within ability ranges
	HL.GetEnemies("Melee") -- 5 Yards
	HL.GetEnemies(R.Moonfire) -- 40-43 Yards
	HL.GetEnemies(R.Mangle) -- 5-8 Yards
	HL.GetEnemies(R.Thrash, true) -- 8-11 Yards
	HL.GetEnemies(R.SkullBash) -- 10-13 Yards
end    

local function APL()
	UpdateVars()

	if not Player:AffectingCombat() and RubimRH.PrecombatON() then return 0, 462338 end

	-- TODO: Mighty Bash, Typhoon, Entanglement -> GGLoader textures not working

	local Form = GetShapeshiftForm("player")
	if Form == 1 and Bear() ~= nil then 
		return Bear() 
	elseif Form == 2 and Cat() ~= nil 
		then return Cat()
	elseif Form == 4 and Moonkin() ~= nil then 
		return Moonkin() 
	end
	
	-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn and (true) then return ShouldReturn; end
	
    -- interrupt
    if S.SkullBash:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.SkullBash:Cast()
    end
	
	return 0, 135328
end

RubimRH.Rotation.SetAPL(104, APL);

local function PASSIVE()
	return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(104, PASSIVE);