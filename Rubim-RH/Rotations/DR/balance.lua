--- ============================ HEADER ============================
--- ======= LOCALIZE =======
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
local MouseOver = Unit.MouseOver;

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[102] = {
    MoonkinForm                           = Spell(24858),
    SolarWrath                            = Spell(190984),
    FuryofElune                           = Spell(202770),
    CelestialAlignmentBuff                = Spell(194223),
    IncarnationBuff                       = Spell(102560),
    CelestialAlignment                    = Spell(194223),
    Incarnation                           = Spell(102560),
    ForceofNature                         = Spell(205636),
    Sunfire                               = Spell(93402),
    SunfireDebuff                         = Spell(164815),
    Moonfire                              = Spell(8921),
    Regrowth                              = Spell(8936),
    MoonfireDebuff                        = Spell(164812),
    StellarFlare                          = Spell(202347),
	StellarFlareDebuff                    = Spell(202347),
    LunarStrike                           = Spell(194153),
    LunarEmpowermentBuff                  = Spell(164547),
    SolarEmpowermentBuff                  = Spell(164545),
    Starsurge                             = Spell(78674),
    OnethsIntuitionBuff                   = Spell(209406),
    Starfall                              = Spell(191034),
    StarlordBuff                          = Spell(279709),
    NewMoon                               = Spell(274281),
    HalfMoon                              = Spell(274282),
    FullMoon                              = Spell(274283),
    WarriorofEluneBuff                    = Spell(202425),
    BloodFury                             = Spell(20572),
    Berserking                            = Spell(26297),
    ArcaneTorrent                         = Spell(50613),
    LightsJudgment                        = Spell(255647),
    WarriorofElune                        = Spell(202425),
    SunblazeBuff                          = Spell(274399),
    OwlkinFrenzyBuff                      = Spell(157228),
    SolarBeam                             = Spell(78675),
	LivelySpirit                          = Spell(279642),
	LivelySpiritBuff                      = Spell(279646),
	StreakingStars                        = Spell(272871),
	ShootingStars                         = Spell(202342),
    NaturesBalance                        = Spell(202430),
	Barkskin                              = Spell(22812),
	Soothe                                = Spell(2908),
	Innervate                             = Spell(29166),
	Renewal                               = Spell(108238),
    Typhoon                               = Spell(132469),
	MightyBash                            = Spell(5211),
	ArcanicPulsarBuff                     = Spell(287790),
    ArcanicPulsar                         = Spell(287773),
	StarlordBuff                          = Spell(279709),
    Starlord                              = Spell(202345),
	-- 8.2 Essences
    SolarBeam                             = Spell(78675),
	UnleashHeartOfAzeroth                 = Spell(280431),
    BloodOfTheEnemy                       = Spell(297108),
    BloodOfTheEnemy2                      = Spell(298273),
    BloodOfTheEnemy3                      = Spell(298277),
    MemoryOfLucidDreams                   = Spell(298357),
    MemoryOfLucidDreams2                  = Spell(299372),
    MemoryOfLucidDreams3                  = Spell(299374),
    PurifyingBlast                        = Spell(295337),
    PurifyingBlast2                       = Spell(299345),
    PurifyingBlast3                       = Spell(299347),
    RippleInSpace                         = Spell(302731),
    RippleInSpace2                        = Spell(302982),
    RippleInSpace3                        = Spell(302983),
    ConcentratedFlame                     = Spell(295373),
    ConcentratedFlame2                    = Spell(299349),
    ConcentratedFlame3                    = Spell(299353),
    TheUnboundForce                       = Spell(298452),
    TheUnboundForce2                      = Spell(299376),
    TheUnboundForce3                      = Spell(299378),
    RecklessForce                         = Spell(302932),
    WorldveinResonance                    = Spell(295186),
    WorldveinResonance2                   = Spell(298628),
    WorldveinResonance3                   = Spell(299334),
    FocusedAzeriteBeam                    = Spell(295258),
    FocusedAzeriteBeam2                   = Spell(299336),
    FocusedAzeriteBeam3                   = Spell(299338),
    GuardianOfAzeroth                     = Spell(295840),
    GuardianOfAzeroth2                    = Spell(299355),
    GuardianOfAzeroth3                    = Spell(299358),
    Thorns                                = Spell(236696),
	  StreakingStars                        = Spell(272871),
  ArcanicPulsarBuff                     = Spell(287790),
  ArcanicPulsar                         = Spell(287773),
  StarlordBuff                          = Spell(279709),
  Starlord                              = Spell(202345),
  TwinMoons                             = Spell(279620),
	

};
local S = RubimRH.Spell[102];

-- Items
if not Item.Druid then
    Item.Druid = {}
end
Item.Druid.Balance = {
    BattlePotionOfIntellect          = Item(163222),
	TidestormCodex                   = Item(165576),
	AzsharasFontofPower              = Item(169314),
    PocketsizedComputationDevice     = Item(167555),
    ShiverVenomRelic                 = Item(168905),
};
local I = Item.Druid.Balance;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- Variables

local EnemyRanges = { 40 }
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
    return val
end

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

        return true
end

local function FutureAstralPower()
    local AstralPower = Player:AstralPower()
    if not Player:IsCasting() then
        return AstralPower
    else
        if Player:IsCasting(S.NewnMoon) then
            return AstralPower + 10
        elseif Player:IsCasting(S.HalfMoon) then
            return AstralPower + 20
        elseif Player:IsCasting(S.FullMoon) then
            return AstralPower + 40
        elseif Player:IsCasting(S.StellarFlare) then
            return AstralPower + 8
        elseif Player:IsCasting(S.SolarWrath) then
            return AstralPower + 8
        elseif Player:IsCasting(S.LunarStrike) then
            return AstralPower + 12
        else
            return AstralPower
        end
    end
end

local function CaInc()
  return S.Incarnation:IsAvailable() and S.Incarnation or S.CelestialAlignment
end

local function AP_Check(spell)
  local APGen = 0
  local CurAP = Player:AstralPower()
  if spell == S.Sunfire or spell == S.Moonfire then 
    APGen = 3
  elseif spell == S.StellarFlare or spell == S.SolarWrath then
    APGen = 8
  elseif spell == S.Incarnation or spell == S.CelestialAlignment then
    APGen = 40
  elseif spell == S.ForceofNature then
    APGen = 20
  elseif spell == S.LunarStrike then
    APGen = 12
  end
  
  if S.ShootingStars:IsAvailable() then 
    APGen = APGen + 4
  end
  if S.NaturesBalance:IsAvailable() then
    APGen = APGen + 2
  end
  
  if CurAP + APGen < Player:AstralPowerMax() then
    return true
  else
    return false
  end
end

-- Variables
local VarAzSs = 0;
local VarAzAp = 0;
local VarSfTargets = 0;

HL:RegisterForEvent(function()
  VarAzSs = 0
  VarAzAp = 0
  VarSfTargets = 0
end, "PLAYER_REGEN_ENABLED")

-- Enrage debuff function
local function HasDispellableEnrage()
    if Target:HasBuffList(RubimRH.List.PvEEnragePurge) then
        return true
	else 
	    return false
    end
end

local function GetEnemiesCount(range)
    if range == nil then range = 10 end
	 -- Unit Update - Update differently depending on if splash data is being used
	if RubimRH.AoEON() then       
	        if RubimRH.db.profile[62].useSplashData == "Enabled" then	
                RubimRH.UpdateSplashCount(Target, range)
                return RubimRH.GetSplashCount(Target, range)
            else
                UpdateRanges()
                if range == 10 then
                    return Cache.EnemiesCount[range]
                else
                    return active_enemies()
                end
            end
    else
        return 1
    end
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
  S.GuardianOfAzeroth = S.GuardianOfAzeroth2:IsAvailable() and S.GuardianOfAzeroth2 or S.GuardianOfAzeroth
  S.GuardianOfAzeroth = S.GuardianOfAzeroth3:IsAvailable() and S.GuardianOfAzeroth3 or S.GuardianOfAzeroth
end

local function EvaluateCycleSunfire(TargetUnit)
  return (TargetUnit:DebuffRefreshableCP(S.SunfireDebuff)) and (AP_Check(S.Sunfire) and math.floor (TargetUnit:TimeToDie() / (2 * Player:SpellHaste())) * EnemiesCount >= math.ceil (math.floor (2 / EnemiesCount) * 1.5) + 2 * EnemiesCount and (EnemiesCount > 1 + num(S.TwinMoons:IsAvailable()) or TargetUnit:DebuffP(S.MoonfireDebuff)) and (not bool(VarAzSs) or not Player:BuffP(CaInc()) or not Player:PrevGCDP(1, S.Sunfire)) and (Player:BuffRemainsP(CaInc()) > TargetUnit:DebuffRemainsP(S.SunfireDebuff) or not Player:BuffP(CaInc())))
end

local function EvaluateCycleMoonfire(TargetUnit)
  return (TargetUnit:DebuffRefreshableCP(S.MoonfireDebuff)) and (AP_Check(S.Moonfire) and math.floor (TargetUnit:TimeToDie() / (2 * Player:SpellHaste())) * EnemiesCount >= 6 and (not bool(VarAzSs) or not Player:BuffP(CaInc()) or not Player:PrevGCDP(1, S.Moonfire)) and (Player:BuffRemainsP(CaInc()) > TargetUnit:DebuffRemainsP(S.MoonfireDebuff) or not Player:BuffP(CaInc())))
end

local function EvaluateCycleStellarFlare(TargetUnit)
  return (TargetUnit:DebuffRefreshableCP(S.StellarFlareDebuff)) and (AP_Check(S.StellarFlare) and math.floor (TargetUnit:TimeToDie() / (2 * Player:SpellHaste())) >= 5 and (not bool(VarAzSs) or not Player:BuffP(CaInc()) or not Player:PrevGCDP(1, S.StellarFlare)) and not Player:IsCasting(S.StellarFlare))
end

local function APL()
    local Precombat, Precombat_DBM
    EnemiesCount = GetEnemiesCount(15)
    HL.GetEnemies(40) -- To populate Cache.Enemies[40] for CastCycles
    DetermineEssenceRanks()
  
  	Precombat_DBM = function()	    
        -- flask
        -- food
        -- augmentation
        -- moonkin_form
        if GetShapeshiftForm() ~= 4 and RubimRH.AutoMorphON() then
            return S.MoonkinForm:Cast()
        end
        -- snapshot_stats
	    -- potion
        if I.BattlePotionOfIntellect:IsReady() and RubimRH.DBM_PullTimer() > (S.SolarWrath:CastTime() + S.SolarWrath:TravelTime()) and RubimRH.DBM_PullTimer() <= (S.SolarWrath:CastTime() + S.SolarWrath:TravelTime() + 1) then
            return 967532
        end
        -- solar_wrath
        if S.SolarWrath:IsReady() and not Player:IsCasting(S.SolarWrath) and RubimRH.DBM_PullTimer() <= (S.SolarWrath:CastTime() + S.SolarWrath:TravelTime()) and RubimRH.DBM_PullTimer() >= 0.1 then
            return S.SolarWrath:Cast()
        end
    end
  
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- variable,name=az_ss,value=azerite.streaking_stars.rank
        if (true) then
            VarAzSs = S.StreakingStars:AzeriteRank()
        end
        -- variable,name=az_ap,value=azerite.arcanic_pulsar.rank
        if (true) then
           VarAzAp = S.ArcanicPulsar:AzeriteRank()
        end
        -- variable,name=sf_targets,value=4
        if (true) then
          VarSfTargets = 4
        end
        -- variable,name=sf_targets,op=add,value=1,if=azerite.arcanic_pulsar.enabled
        if (S.ArcanicPulsar:AzeriteEnabled()) then
            VarSfTargets = VarSfTargets + 1
        end
        -- variable,name=sf_targets,op=add,value=1,if=talent.starlord.enabled
        if (S.Starlord:IsAvailable()) then
            VarSfTargets = VarSfTargets + 1
        end
        -- variable,name=sf_targets,op=add,value=1,if=azerite.streaking_stars.rank>2&azerite.arcanic_pulsar.enabled
        if (S.StreakingStars:AzeriteRank() > 2 and S.ArcanicPulsar:AzeriteEnabled()) then
           VarSfTargets = VarSfTargets + 1
        end
        -- variable,name=sf_targets,op=sub,value=1,if=!talent.twin_moons.enabled
        if (not S.TwinMoons:IsAvailable()) then
            VarSfTargets = VarSfTargets - 1
        end
        -- moonkin_form
        if GetShapeshiftForm() ~= 4 and RubimRH.AutoMorphON() then
            return S.MoonkinForm:Cast()
        end
        -- snapshot_stats
        -- solar_wrath
        if S.SolarWrath:IsCastableP() and not Player:IsCasting(S.SolarWrath) then
            return S.SolarWrath:Cast()
        end
    end
    -- Moonkin Form OOC, if setting is true
    if GetShapeshiftForm() ~= 4 and RubimRH.AutoMorphON() then
        return S.MoonkinForm:Cast()
    end
	-- Regrowth
	if S.Regrowth:IsCastableP() and Player:HealthPercentage() <= RubimRH.db.profile[102].sk1 then
        return S.Regrowth:Cast()
    end	
	-- Renewal
	if S.Renewal:IsCastableP() and S.Renewal:IsAvailable() and Player:HealthPercentage() <= RubimRH.db.profile[102].sk3 then
        return S.Renewal:Cast()
    end	
	-- barkskin,if=buff.bear_form.up
    if S.Barkskin:IsCastableP() and Player:HealthPercentage() < RubimRH.db.profile[102].sk2 then
        return S.Barkskin:Cast()
    end	
  -- call precombat
  if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) or Player:IsChanneling() then
      return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
  end
    -- precombat DBM
	if not Player:AffectingCombat() and RubimRH.PrecombatON() and RubimRH.PerfectPullON() and not Player:IsCasting() then
        if Precombat_DBM() ~= nil then
            return Precombat_DBM()
        end
        return 0, 462338
    end
	-- precombat no dbm
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and not RubimRH.PerfectPullON() and not Player:IsCasting() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
  
  if RubimRH.TargetIsValid() then
    -- Interrupt
	-- moonkin_form
    if S.MoonkinForm:IsReadyP() and not Player:Buff(S.MoonkinForm) and RubimRH.AutoMorphON() then
        return S.MoonkinForm:Cast()
    end
    --Queue system 
	if QueueSkill() ~= nil then
        return QueueSkill()
    end
    --Soothe Enrage target
	if S.Soothe:IsReadyP() and HasDispellableEnrage() then 
		return S.Soothe:Cast()
	end
	-- interrupt.talent.typhoon
    if S.Typhoon:IsAvailable() and S.Typhoon:CooldownRemainsP() < 0.1 and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Typhoon:Cast()
    end
    -- interrupt.talent.mightybash
    if S.MightyBash:IsAvailable() and S.MightyBash:CooldownRemainsP() < 0.1 and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.MightyBash:Cast()
    end
	-- Mouseover Soothe
    local MouseoverEnemy = UnitExists("mouseover") and not UnitIsFriend("target", "mouseover")
    if MouseoverEnemy then
        -- Soothe
	    if S.Soothe:IsReadyP() and HasDispellableEnrage() then
            return S.Soothe:Cast()
        end
    end
	
	--[[-- Mouseover Innervate handler
    local MouseoverUnit = UnitExists("mouseover") and UnitIsFriend("player", "mouseover")
    if MouseoverUnit then
        -- Innervate
	    if S.Innervate:CooldownRemainsP() < 0.1 and RubimRH.CDsON() and (S.LivelySpirit:AzeriteEnabled() and (S.Incarnation:CooldownRemainsP() < 2 or S.CelestialAlignment:CooldownRemainsP() < 12)) then
            return S.Innervate:Cast()			
		elseif S.Innervate:CooldownRemainsP() < 0.1 and RubimRH.CDsON() and MouseOver:ManaPercentageP() < RubimRH.db.profile[102].sk3 then
		    return S.Innervate:Cast()
		else
		    return            
		end
    end	]]--

	-- Solar Beam
    if S.SolarBeam:IsReady() and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.SolarBeam:Cast()
    end
    -- potion,if=buff.ca_inc.remains>6
    -- berserking,if=buff.ca_inc.up
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(CaInc())) then
        return S.Berserking:Cast()
    end
    -- use_item,name=azsharas_font_of_power,if=equipped.169314&dot.moonfire.ticking&dot.sunfire.ticking&(!talent.stellar_flare.enabled|dot.stellar_flare.ticking)
    -- guardian_of_azeroth,if=(!talent.starlord.enabled|buff.starlord.up)&dot.moonfire.ticking&dot.sunfire.ticking&(!talent.stellar_flare.enabled|dot.stellar_flare.ticking)
    if S.GuardianOfAzeroth:IsCastableP() and ((not S.Starlord:IsAvailable() or Player:BuffP(S.StarlordBuff)) and Target:DebuffP(S.MoonfireDebuff) and Target:DebuffP(S.SunfireDebuff) and (not S.StellarFlare:IsAvailable() or Target:DebuffP(S.StellarFlareDebuff))) then
        return S.UnleashHeartOfAzeroth:Cast()
    end
    -- use_item,name=tidestorm_codex,if=equipped.165576
    -- use_item,name=pocketsized_computation_device,if=equipped.167555&dot.moonfire.ticking&dot.sunfire.ticking&(!talent.stellar_flare.enabled|dot.stellar_flare.ticking)
    if trinketReady(1) and (Target:DebuffP(S.MoonfireDebuff) and Target:DebuffP(S.SunfireDebuff) and (not S.StellarFlare:IsAvailable() or Target:DebuffP(S.StellarFlareDebuff))) then
        return trinket1
    end
	-- use_item,name=pocketsized_computation_device,if=equipped.167555&dot.moonfire.ticking&dot.sunfire.ticking&(!talent.stellar_flare.enabled|dot.stellar_flare.ticking)
    if trinketReady(2) and (Target:DebuffP(S.MoonfireDebuff) and Target:DebuffP(S.SunfireDebuff) and (not S.StellarFlare:IsAvailable() or Target:DebuffP(S.StellarFlareDebuff))) then
        return trinket2
    end
    -- use_item,name=shiver_venom_relic,if=equipped.168905&cooldown.ca_inc.remains>30&!buff.ca_inc.up
    -- use_items,if=cooldown.ca_inc.remains>30
    -- blood_of_the_enemy,if=cooldown.ca_inc.remains>30
    if S.BloodOfTheEnemy:IsCastableP() and (CaInc():CooldownRemainsP() > 30) then
        return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams,if=dot.sunfire.remains>10&dot.moonfire.remains>10&(!talent.stellar_flare.enabled|dot.stellar_flare.remains>10)&!buff.ca_inc.up&(astral_power<25|cooldown.ca_inc.remains>30)
    if S.MemoryOfLucidDreams:IsCastableP() and (Target:DebuffRemainsP(S.SunfireDebuff) > 10 and (not S.StellarFlare:IsAvailable() or Target:DebuffRemainsP(S.StellarFlareDebuff) > 10) and not Player:BuffP(CaInc()) and (FutureAstralPower() < 25 or CaInc():CooldownRemainsP() > 30)) then
        return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force,if=buff.reckless_force.up|time<5
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForce) or HL.CombatTime() < 5) then
        return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
        return S.UnleashHeartOfAzeroth:Cast()
    end
    -- thorns
    if S.Thorns:IsCastableP() then
        return S.Thorns:Cast()
    end
    -- warrior_of_elune
    if S.WarriorofElune:IsCastableP() then
        return S.WarriorofElune:Cast()
    end
    -- innervate,if=azerite.lively_spirit.enabled&(cooldown.incarnation.remains<2|cooldown.celestial_alignment.remains<12)
    if S.Innervate:IsCastableP() and RubimRH.CDsON() and (S.LivelySpirit:AzeriteEnabled() and (S.Incarnation:CooldownRemainsP() < 2 or S.CelestialAlignment:CooldownRemainsP() < 12)) then
        return S.Innervate:Cast()
    end
    -- incarnation,if=!buff.ca_inc.up&(buff.memory_of_lucid_dreams.up|((cooldown.memory_of_lucid_dreams.remains>20|!essence.memory_of_lucid_dreams.major)&ap_check&astral_power>=40))&(buff.memory_of_lucid_dreams.up|ap_check)&dot.sunfire.remains>8&dot.moonfire.remains>12&(dot.stellar_flare.remains>6|!talent.stellar_flare.enabled)
    if S.Incarnation:IsCastableP() and RubimRH.CDsON() and (not Player:BuffP(CaInc()) and (Player:BuffP(S.MemoryOfLucidDreams) or ((S.MemoryOfLucidDreams:CooldownRemainsP() > 20 or not S.MemoryOfLucidDreams:IsAvailable()) and AP_Check(S.Incarnation) and FutureAstralPower() >= 40)) and (Player:BuffP(S.MemoryOfLucidDreams) or AP_Check(S.Incarnation)) and Target:DebuffRemainsP(S.SunfireDebuff) > 8 and Target:DebuffRemainsP(S.MoonfireDebuff) > 12 and (Target:DebuffRemainsP(S.StellarFlareDebuff) > 6 or not S.StellarFlare:IsAvailable())) then
        return S.Incarnation:Cast()
    end
    -- celestial_alignment,if=!buff.ca_inc.up&(buff.memory_of_lucid_dreams.up|((cooldown.memory_of_lucid_dreams.remains>20|!essence.memory_of_lucid_dreams.major)&ap_check&astral_power>=40))&(!azerite.lively_spirit.enabled|buff.lively_spirit.up)&(dot.sunfire.remains>2&dot.moonfire.ticking&(dot.stellar_flare.ticking|!talent.stellar_flare.enabled)) and (not S.LivelySpirit:AzeriteEnabled() or Player:BuffP(S.LivelySpiritBuff))
    if S.CelestialAlignment:IsCastableP() and RubimRH.CDsON() and (not Player:BuffP(CaInc()) and (Player:BuffP(S.MemoryOfLucidDreams) or ((S.MemoryOfLucidDreams:CooldownRemainsP() > 20 or not S.MemoryOfLucidDreams:IsAvailable()) and AP_Check(S.CelestialAlignment) and FutureAstralPower() >= 40)) and (Target:DebuffRemainsP(S.SunfireDebuff) > 2 and Target:DebuffP(S.MoonfireDebuff) and (Target:DebuffP(S.StellarFlareDebuff) or not S.StellarFlare:IsAvailable()))) then
        return S.CelestialAlignment:Cast()
    end
    -- fury_of_elune,if=(buff.ca_inc.up|cooldown.ca_inc.remains>30)&solar_wrath.ap_check
    if S.FuryofElune:IsCastableP() and ((Player:BuffP(CaInc()) or CaInc():CooldownRemainsP() > 30) and AP_Check(S.SolarWrath)) then
        return S.FuryofElune:Cast()
    end
    -- force_of_nature,if=(buff.ca_inc.up|cooldown.ca_inc.remains>30)&ap_check
    if S.ForceofNature:IsCastableP() and ((Player:BuffP(CaInc()) or CaInc():CooldownRemainsP() > 30) and AP_Check(S.ForceofNature)) then
        return S.ForceofNature:Cast()
    end
    -- cancel_buff,name=starlord,if=buff.starlord.remains<3&!solar_wrath.ap_check
    -- if (Player:BuffRemainsP(S.StarlordBuff) < 3 and not bool(solar_wrath.ap_check)) then
      -- if RubimRH.Cancel(S.StarlordBuff) then return ""; end
    -- end
    -- starfall,if=(buff.starlord.stack<3|buff.starlord.remains>=8)&spell_targets>=variable.sf_targets&(target.time_to_die+1)*spell_targets>cost%2.5
    if S.Starfall:IsReadyP() and active_enemies() >= 6 and RubimRH.AoEON() and ((Player:BuffStackP(S.StarlordBuff) < 3 or Player:BuffRemainsP(S.StarlordBuff) >= 8) and EnemiesCount >= VarSfTargets and (Target:TimeToDie() + 1) * EnemiesCount > S.Starfall:Cost() / 2.5) then
        return S.Starfall:Cast()
    end
    -- starsurge,if=(talent.starlord.enabled&(buff.starlord.stack<3|buff.starlord.remains>=5&buff.arcanic_pulsar.stack<8)|!talent.starlord.enabled&(buff.arcanic_pulsar.stack<8|buff.ca_inc.up))&spell_targets.starfall<variable.sf_targets&buff.lunar_empowerment.stack+buff.solar_empowerment.stack<4&buff.solar_empowerment.stack<3&buff.lunar_empowerment.stack<3&(!variable.az_ss|!buff.ca_inc.up|!prev.starsurge)|target.time_to_die<=execute_time*astral_power%40|!solar_wrath.ap_check
    if S.Starsurge:IsReadyP() and ((S.Starlord:IsAvailable() and (Player:BuffStackP(S.StarlordBuff) < 3 or Player:BuffRemainsP(S.StarlordBuff) >= 5 and Player:BuffStackP(S.ArcanicPulsarBuff) < 8) or not S.Starlord:IsAvailable() and (Player:BuffStackP(S.ArcanicPulsarBuff) < 8 or Player:BuffP(CaInc()))) and EnemiesCount < VarSfTargets and Player:BuffStackP(S.LunarEmpowermentBuff) + Player:BuffStackP(S.SolarEmpowermentBuff) < 4 and Player:BuffStackP(S.SolarEmpowermentBuff) < 3 and Player:BuffStackP(S.LunarEmpowermentBuff) < 3 and (not bool(VarAzSs) or not Player:BuffP(CaInc()) or not Player:PrevGCDP(1, S.Starsurge)) or Target:TimeToDie() <= S.Starsurge:ExecuteTime() * FutureAstralPower() / 40 or not AP_Check(S.SolarWrath)) then
        return S.Starsurge:Cast()
    end
    -- sunfire,if=buff.ca_inc.up&buff.ca_inc.remains<gcd.max&variable.az_ss&dot.moonfire.remains>remains
    if S.Sunfire:IsCastableP() and (Player:BuffP(CaInc()) and Player:BuffRemainsP(CaInc()) < Player:GCD() and bool(VarAzSs) and Target:DebuffRemainsP(S.MoonfireDebuff) > Target:DebuffRemainsP(S.SunfireDebuff)) then
        return S.Sunfire:Cast()
    end
    -- moonfire,if=buff.ca_inc.up&buff.ca_inc.remains<gcd.max&variable.az_ss
    if S.Moonfire:IsCastableP() and (Player:BuffP(CaInc()) and Player:BuffRemainsP(CaInc()) < Player:GCD() and bool(VarAzSs)) then
        return S.Moonfire:Cast()
    end
    -- sunfire,target_if=refreshable,if=ap_check&floor(target.time_to_die%(2*spell_haste))*spell_targets>=ceil(floor(2%spell_targets)*1.5)+2*spell_targets&(spell_targets>1+talent.twin_moons.enabled|dot.moonfire.ticking)&(!variable.az_ss|!buff.ca_inc.up|!prev.sunfire)&(buff.ca_inc.remains>remains|!buff.ca_inc.up)
    if S.Sunfire:IsCastableP() and EvaluateCycleSunfire(Target) then
        return S.Sunfire:Cast()
    end
    -- moonfire,target_if=refreshable,if=ap_check&floor(target.time_to_die%(2*spell_haste))*spell_targets>=6&(!variable.az_ss|!buff.ca_inc.up|!prev.moonfire)&(buff.ca_inc.remains>remains|!buff.ca_inc.up)
    if S.Moonfire:IsCastableP() and EvaluateCycleMoonfire(Target) then
      return S.Moonfire:Cast()
    end
    -- stellar_flare,target_if=refreshable,if=ap_check&floor(target.time_to_die%(2*spell_haste))>=5&(!variable.az_ss|!buff.ca_inc.up|!prev.stellar_flare)
    if S.StellarFlare:IsCastableP() and EvaluateCycleStellarFlare(Target) then
        return S.StellarFlare:Cast()
    end
    -- new_moon,if=ap_check
    if S.NewMoon:IsCastableP() and (AP_Check(S.NewMoon)) then
        return S.NewMoon:Cast()
    end
    -- half_moon,if=ap_check
    if S.HalfMoon:IsCastableP() and (AP_Check(S.HalfMoon)) then
        return S.HalfMoon:Cast()
    end
    -- full_moon,if=ap_check
    if S.FullMoon:IsCastableP() and (AP_Check(S.FullMoon)) then
        return S.FullMoon:Cast()
    end
    -- lunar_strike,if=buff.solar_empowerment.stack<3&(ap_check|buff.lunar_empowerment.stack=3)&((buff.warrior_of_elune.up|buff.lunar_empowerment.up|spell_targets>=2&!buff.solar_empowerment.up)&(!variable.az_ss|!buff.ca_inc.up)|variable.az_ss&buff.ca_inc.up&prev.solar_wrath)
    if S.LunarStrike:IsCastableP() and not Player:IsCasting(S.LunarStrike) and (Player:BuffStackP(S.SolarEmpowermentBuff) < 3 and (AP_Check(S.LunarStrike) or Player:BuffStackP(S.LunarEmpowermentBuff) == 3) and ((Player:BuffP(S.WarriorofEluneBuff) or Player:BuffP(S.LunarEmpowermentBuff) or EnemiesCount >= 2 and not Player:BuffP(S.SolarEmpowermentBuff)) and (not bool(VarAzSs) or not Player:BuffP(CaInc())) or bool(VarAzSs) and Player:BuffP(CaInc()) and Player:PrevGCDP(1, S.SolarWrath))) then
        return S.LunarStrike:Cast()
    end
    -- solar_wrath,if=variable.az_ss<3|!buff.ca_inc.up|!prev.solar_wrath
    if S.SolarWrath:IsCastableP() and not Player:IsCasting(S.SolarWrath) and (VarAzSs < 3 or not Player:BuffP(CaInc()) or not Player:PrevGCDP(1, S.SolarWrath)) then
        return S.SolarWrath:Cast()
    end
    -- sunfire
    if S.Sunfire:IsCastableP() then
        return S.Sunfire:Cast()
    end
	
    end
	return 0, 135328
end

RubimRH.Rotation.SetAPL(102, APL)

local function PASSIVE()
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(102, PASSIVE)