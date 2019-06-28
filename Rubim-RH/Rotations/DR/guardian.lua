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
local MouseOver = Unit.MouseOver;

-- Spell Localization
RubimRH.Spell[104] = {
    -- Racials
    WarStomp                                = Spell(20549),
    Berserking                              = Spell(26297),
	BloodFury                               = Spell(20572),
    ArcaneTorrent                           = Spell(50613),
    LightsJudgment                          = Spell(255647),
    Fireblood                               = Spell(265221),
	AncestralCall                         = Spell(274738),
    -- Abilities
    FrenziedRegeneration                    = Spell(22842),
    Gore                                    = Spell(210706),
    GoreBuff                                = Spell(93622),
    GoryFur                                 = Spell(201671),
    Ironfur                                 = Spell(192081),
    Mangle                                  = Spell(33917),
    Maul                                    = Spell(6807),
    Moonfire                                = Spell(8921),
    MoonfireDebuff                          = Spell(164812),
    Sunfire                                 = Spell(197630),
    SunfireDebuff                           = Spell(164815),
    Starsurge                               = Spell(197626),
    LunarEmpowerment                        = Spell(164547),
    SolarEmpowerment                        = Spell(164545),
    LunarStrike                             = Spell(197628),
    Wrath                                   = Spell(197629),
    Regrowth                                = Spell(8936),
    Swipe                                   = Spell(213771),
    Thrash                                  = Spell(77758),
    ThrashDebuff                            = Spell(192090),
    ThrashCat                               = Spell(106830),
	ThrashBearDebuff                        = Spell(192090),
    Prowl                                   = Spell(5215),
	LayeredMane                           = Spell(279552),
    -- Talents
    BalanceAffinity                         = Spell(197488),
    BloodFrenzy                             = Spell(203962),
    Brambles                                = Spell(203953),
    BristlingFur                            = Spell(155835),
    Earthwarden                             = Spell(203974),
    EarthwardenBuff                         = Spell(203975),
    FeralAffinity                           = Spell(202155),
    GalacticGuardian                        = Spell(203964),
    GalacticGuardianBuff                    = Spell(213708),
    GuardianOfElune                         = Spell(155578),
    GuardianOfEluneBuff                     = Spell(213680),
    Incarnation                             = Spell(102558),
    LunarBeam                               = Spell(204066),
    Pulverize                               = Spell(80313),
    PulverizeBuff                           = Spell(158792),
    RestorationAffinity                     = Spell(197492),
    SouloftheForest                         = Spell(158477),
    MightyBash                              = Spell(5211),
    Typhoon                                 = Spell(132469),
    Entanglement                            = Spell(102359),
	IncarnationBuff                       = Spell(102558),
    -- Artifact
    RageoftheSleeper                        = Spell(200851),
    -- Defensive
    SurvivalInstincts                       = Spell(61336),
    Barkskin                                = Spell(22812),
    -- Utility
    Growl                                   = Spell(6795),
    SkullBash                               = Spell(106839),
	RemoveCorruption                        = Spell(2782),
	IncapacitatingRoar                      = Spell(99),
    -- Affinity
    FerociousBite                           = Spell(22568),
    HealingTouch                            = Spell(5185),
    Rake                                    = Spell(1822),
    RakeDebuff                              = Spell(155722),
    Rejuvenation                            = Spell(774),
    Rip                                     = Spell(1079),
    Shred                                   = Spell(5221),
    Swiftmend                               = Spell(18562),
	WildChargeTalent                      = Spell(102401),
    WildChargeBear                        = Spell(16979),
    -- Shapeshift
    BearForm                                = Spell(5487),
    CatForm                                 = Spell(768),
    MoonkinForm                             = Spell(197625),
    TravelForm                              = Spell(783),
	HeartEssence                            = Spell(298554),
    SharpenedClawsBuff                      = Spell(279943),
	--8.2 Essences
    UnleashHeartOfAzeroth                   = Spell(280431),
    BloodOfTheEnemy                         = Spell(297108),
    BloodOfTheEnemy2                        = Spell(298273),
    BloodOfTheEnemy3                        = Spell(298277),
    ConcentratedFlame                       = Spell(295373),
    ConcentratedFlame2                      = Spell(299349),
    ConcentratedFlame3                      = Spell(299353),
    GuardianOfAzeroth                       = Spell(295840),
    GuardianOfAzeroth2                      = Spell(299355),
    GuardianOfAzeroth3                      = Spell(299358),
    FocusedAzeriteBeam                      = Spell(295258),
    FocusedAzeriteBeam2                     = Spell(299336),
    FocusedAzeriteBeam3                     = Spell(299338),
    PurifyingBlast                          = Spell(295337),
    PurifyingBlast2                         = Spell(299345),
    PurifyingBlast3                         = Spell(299347),
    TheUnboundForce                         = Spell(298452),
    TheUnboundForce2                        = Spell(299376),
    TheUnboundForce3                        = Spell(299378),
    RippleInSpace                           = Spell(302731),
    RippleInSpace2                          = Spell(302982),
    RippleInSpace3                          = Spell(302983),
    WorldveinResonance                      = Spell(295186),
    WorldveinResonance2                     = Spell(298628),
    WorldveinResonance3                     = Spell(299334),
    MemoryOfLucidDreams                     = Spell(298357),
    MemoryOfLucidDreams2                    = Spell(299372),
    MemoryOfLucidDreams3                    = Spell(299374),
	Conflict1                               = Spell(303823),
	Conflict2                               = Spell(304088),
	Conflict3                               = Spell(304121),
}

local S = RubimRH.Spell[104]

-- Items
if not Item.Druid then Item.Druid = {} end
Item.Druid.Guardian = {
  BattlePotionofAgility            = Item(163223)
};
local I = Item.Druid.Guardian;

-- Rotation Var
local ShouldReturn; -- Used to get the return string
local IsTanking;
local AoERadius; -- Range variables
local EnemiesCount;

local EnemyRanges = {11, 8, 5}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end
local RangeMod = S.BalanceAffinity:IsAvailable() and true or false
local R = {
	Moonfire = (RangeMod) and 43 or 40,
	Mangle = (RangeMod) and 8 or "Melee",
	Thrash = (RangeMod) and 11 or 8,
	Swipe = (RangeMod) and 11 or 8,
	Maul = (RangeMod) and 8 or "Melee",
	Pulverize = (RangeMod) and 8 or "Melee",
	SkullBash = (RangeMod) and 13 or 10 }

local function num(val)
  if val then return 1 else return 0 end
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
  S.Conflict = S.Conflict2:IsAvailable() and S.Conflict2 or S.Conflict1
  S.Conflict = S.Conflict3:IsAvailable() and S.Conflict3 or S.Conflict1
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

--[[local function Swipe()
  if Player:Buff(S.CatForm) then
    return S.SwipeCat;
  else
    return S.SwipeBear;
  end
end
local function Thrash()
  if Player:Buff(S.CatForm) then
    return S.ThrashCat;
  else
    return S.ThrashBear;
  end
end]]

--HL.RegisterNucleusAbility(77758, 8, 6)               -- Thrash (Bear)
--HL.RegisterNucleusAbility(213771, 8, 6)              -- Swipe (Bear)


--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Cooldowns
  -- Determine ranges
  if S.BalanceAffinity:IsAvailable() then
    AoERadius = 11
  else
    AoERadius = 8
  end
  UpdateRanges()
  DetermineEssenceRanks()
  EnemiesCount = Cache.EnemiesCount[AoERadius]
  IsTanking = Player:IsTankingAoE(AoERadius) or Player:IsTanking(Target)
  
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- memory_of_lucid_dreams
    if S.MemoryOfLucidDreams:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- bear_form
    if S.BearForm:IsCastableP() and Player:BuffDownP(S.BearForm) then
      return S.BearForm:Cast()
    end
    -- snapshot_stats
    -- potion

  end
  
  Cooldowns = function()
    -- potion

    -- heart_essence
    if S.HeartEssence:IsCastableP() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
      return S.BloodFury:Cast()
    end
    -- berserking
    if S.Berserking:IsCastableP() and RubimRH.CDsON() then
      return S.Berserking:Cast()
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and RubimRH.CDsON() then
      return S.ArcaneTorrent:Cast()
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() then
      return S.LightsJudgment:Cast()
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
      return S.Fireblood:Cast()
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() then
      return S.AncestralCall:Cast()
    end
	
    -- Defensives and Bristling Fur
    if IsTanking and Player:BuffP(S.BearForm) then	
	
	  --Frenzied Regeneration
      if Player:HealthPercentage() < RubimRH.db.profile[104].sk3 and S.FrenziedRegeneration:IsCastableP() and Player:Rage() > 10
        and not Player:Buff(S.FrenziedRegeneration) and not Player:HealingAbsorbed() then
        return S.FrenziedRegeneration:Cast()
      end
      if S.Ironfur:IsCastableP() and Player:Rage() >= S.Ironfur:Cost() + 1 and IsTanking and (not Player:Buff(S.Ironfur) 
        or (Player:BuffStack(S.Ironfur) < 2 and Player:BuffRefreshableP(S.Ironfur, 2.4))) then
        return S.Ironfur:Cast()
      end
      -- barkskin,if=buff.bear_form.up
      if S.Barkskin:IsCastableP() and Player:HealthPercentage() < RubimRH.db.profile[104].sk1 then
        return S.Barkskin:Cast()
      end
      -- lunar_beam,if=buff.bear_form.up
      if S.LunarBeam:IsCastableP() and Player:HealthPercentage() < RubimRH.db.profile[104].sk4 then
        return S.LunarBeam:Cast()
      end
      -- Survival Instincts
      if S.SurvivalInstincts:IsCastableP() and Player:HealthPercentage() < RubimRH.db.profile[104].sk2 then
        return S.SurvivalInstincts:Cast()
      end
      -- bristling_fur,if=buff.bear_form.up
      if S.BristlingFur:IsCastableP() and Player:Rage() < RubimRH.db.profile[104].sk5 then
        return S.BristlingFur:Cast()
      end
	  
    end
	
    -- incarnation,if=(dot.moonfire.ticking|active_enemies>1)&dot.thrash_bear.ticking
    if S.Incarnation:IsReadyP() and ((Target:DebuffP(S.MoonfireDebuff) or EnemiesCount > 1) and Target:DebuffP(S.ThrashBearDebuff)) then
      return S.Incarnation:Cast()
    end
    
	-- use_items	
  end
  
  -- call precombat
  if not Player:AffectingCombat() and RubimRH.PrecombatON() then
    local ShouldReturn = Precombat(); 
	if ShouldReturn then 
	    return ShouldReturn; 
	end
  end
  
  --if RubimRH.TargetIsValid() then
    -- Charge if out of range
    if S.WildChargeTalent:IsAvailable() and S.WildChargeBear:IsCastableP() and not Target:IsInRange(AoERadius) and Target:IsInRange(25) then
      return S.WildChargeBear:Cast()
    end
	

	-- Auto spread Moonfireand RubimRH.AssaAutoAoEON() 
		if RubimRH.AoEON() and Target:DebuffRemainsP(S.MoonfireDebuff) >= S.MoonfireDebuff:BaseDuration() * 0.90 and EnemiesCount >= 2 and EnemiesCount < 6 and CombatTime("player") > 0 and 
( -- ThrashBearDebuff
    not IsSpellInRange(192090, "target") or   
    (
        CombatTime("target") == 0 and
        not Player:InPvP()
    ) 
) and
(
    -- Moonfire
    MultiDots(5, S.MoonfireDebuff, 10, 1) >= 1 or
    (
        CombatTime("target") == 0 and
        not Player:InPvP()
    ) 
) then 
      return 133015 
   end
	
	
    -- Mouseover Dispell handler
    local MouseoverUnit = UnitExists("mouseover") and UnitIsFriend("player", "mouseover")
    if MouseoverUnit then
        -- RemoveCorruption
	    if S.RemoveCorruption:IsReady() and MouseOver:HasDispelableDebuff("Curse","Poison") then
            return S.RemoveCorruption:Cast()
        end
    end
	--Essences Temp
	local ShouldReturn = Essences(); 
	if ShouldReturn and (true) then 
	    return ShouldReturn; 
	end	
	-- interrupt IncapacitatingRoar
    if S.IncapacitatingRoar:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() and active_enemies() > 2 then
        return S.IncapacitatingRoar:Cast()
    end
	
    -- interrupt SkullBash
    if S.SkullBash:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.SkullBash:Cast()
    end	
    -- auto_attack
	
    -- call_action_list,name=cooldowns
    if (true) and RubimRH.CDsON() then
      local ShouldReturn = Cooldowns(); 
	  if ShouldReturn then 
	      return ShouldReturn; 
	  end
    end
	-- Thrash
	if S.Thrash:IsReadyMorph(R.Thrash, true)
			and Target:DebuffStack(S.ThrashDebuff) < 3 then
		return S.Thrash:Cast()
	end
    -- maul,if=rage.deficit<10&active_enemies<4
    if S.Maul:IsReadyP() and (Player:RageDeficit() < 10 and EnemiesCount < 4) then
      return S.Maul:Cast()
    end
    -- maul,if=essence.conflict_and_strife.major&!buff.sharpened_claws.up
    if S.Maul:IsReadyP() and (S.Conflict:IsAvailable() and Player:BuffDownP(S.SharpenedClawsBuff)) then
      return S.Maul:Cast()
    end
    -- ironfur,if=cost=0|(rage>cost&azerite.layered_mane.enabled&active_enemies>2)
    if S.Ironfur:IsCastableP() and (S.Ironfur:Cost() == 0 or (Player:Rage() > S.Ironfur:Cost() and S.LayeredMane:AzeriteEnabled() and EnemiesCount > 2)) then
      return S.Ironfur:Cast()
    end
    -- pulverize,target_if=dot.thrash_bear.stack=dot.thrash_bear.max_stacks
    if S.Pulverize:IsReadyMorph(R.Pulverize) and Target:DebuffStackP(S.ThrashBearDebuff) == 3 and not Player:BuffP(S.PulverizeBuff) then
      return S.Pulverize:Cast()
    end
    if S.Pulverize:IsReadyMorph(R.Pulverize) and Target:DebuffStackP(S.ThrashBearDebuff) == 3 then
      return S.Pulverize:Cast()
    end
    -- moonfire,target_if=dot.moonfire.refreshable&active_enemies<2
	if Target:DebuffRemainsP(S.MoonfireDebuff) <= Player:GCD()
			and S.Moonfire:IsReadyMorph(R.Moonfire) then
		return S.Moonfire:Cast()
	end
    -- thrash,if=(buff.incarnation.down&active_enemies>1)|(buff.incarnation.up&active_enemies>4)
    if S.Thrash:IsReadyMorph(R.Thrash, true) and ((Player:BuffDownP(S.IncarnationBuff) and EnemiesCount > 1) or (Player:BuffP(S.IncarnationBuff) and EnemiesCount > 4)) then
      return S.Thrash:Cast()
    end
    -- swipe,if=buff.incarnation.down&active_enemies>4
    if S.Swipe:IsReadyMorph(R.Swipe, true) and (Player:BuffDownP(S.IncarnationBuff) and EnemiesCount > 4) then
      return S.Swipe:Cast()
    end
    -- mangle,if=dot.thrash_bear.ticking
    if S.Mangle:IsReadyMorph(R.Mangle) and (Target:DebuffP(S.ThrashBearDebuff)) then
      return S.Mangle:Cast()
    end
    -- moonfire,target_if=buff.galactic_guardian.up&active_enemies<2
    if S.Moonfire:IsReadyMorph(R.Moonfire) and Player:BuffP(S.GalacticGuardianBuff) and EnemiesCount < 2 then
      return S.Moonfire:Cast()
    end
    -- thrash
    if S.Thrash:IsReadyMorph(R.Thrash, true) then
      return S.Thrash:Cast()
    end
    -- maul
    if S.Maul:IsReadyP() and (not IsTanking or (Player:HealthPercentage() >= 80 and Player:Rage() > 85)) then
      return S.Maul:Cast()
    end
    -- swipe
    if S.Swipe:IsReadyMorph(R.Swipe, true) then
      return S.Swipe:Cast()
    end	
	
  --end
  return 0, 135328
end


RubimRH.Rotation.SetAPL(104, APL);

local function PASSIVE()
	return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(104, PASSIVE);