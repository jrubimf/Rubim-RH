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
	

};
local S = RubimRH.Spell[102];

-- Items
if not Item.Druid then
    Item.Druid = {}
end
Item.Druid.Balance = {
  BattlePotionOfIntellect               = Item(163222)
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

local function Precombat ()
    -- moonkin_form
    if S.MoonkinForm:IsReady() and not Player:Buff(S.MoonkinForm) then
        return S.MoonkinForm:Cast()
    end
    -- solar_wrath
    if S.SolarWrath:IsReady() and not Player:IsCasting(S.SolarWrath) then
        return S.SolarWrath:Cast()
    end
    -- sunfire
    if S.Sunfire:IsReady() and (true) then
        return S.Sunfire:Cast()
    end
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

local function CDs ()
	-- actions.cds+=/call_action_list,name=essences

    -- Suggest moonkin form if you're not in it.
    -- potion,if=buff.celestial_alignment.up|buff.incarnation.up
    -- blood_fury,if=buff.celestial_alignment.up|buff.incarnation.up
    if S.BloodFury:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
        return S.BloodFury:Cast()
    end
    -- berserking,if=buff.celestial_alignment.up|buff.incarnation.up
    if S.Berserking:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
        return S.Berserking:Cast()
    end
    -- arcane_torrent,if=buff.celestial_alignment.up|buff.incarnation.up
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
        return S.ArcaneTorrent:Cast()
    end
    -- lights_judgment,if=buff.celestial_alignment.up|buff.incarnation.up
    if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) then
        return S.LightsJudgment:Cast()
    end
    -- warrior_of_elune
    if S.WarriorofElune:IsReady() and not Player:Buff(S.WarriorofElune) then
        return S.WarriorofElune:Cast()
    end
    -- TODO(mrdmnd / synecdoche): INNERVATE here if azerite.lively_spirit and incarn is up or C.A cooldown is < 12 s
    -- incarnation,if=dot.sunfire.remains>8&dot.moonfire.remains>12&(dot.stellar_flare.remains>6|!talent.stellar_flare.enabled)&(buff.memory_of_lucid_dreams.up|ap_check)&!buff.ca_inc.up
    if S.Incarnation:IsCastableP() and (Target:DebuffRemainsP(S.SunfireDebuff) > 8 and Target:DebuffRemainsP(S.MoonfireDebuff) > 12 and (Target:DebuffRemainsP(S.StellarFlareDebuff) > 6 or not S.StellarFlare:IsAvailable()) and (Player:BuffP(S.MemoryOfLucidDreams) or AP_Check(S.Incarnation)) and not Player:BuffP(CaInc())) then
      return S.Incarnation:Cast()
    end
    -- celestial_alignment,if=!buff.ca_inc.up&(buff.memory_of_lucid_dreams.up|(ap_check&astral_power>=40))&(!azerite.lively_spirit.enabled|buff.lively_spirit.up)&(dot.sunfire.remains>2&dot.moonfire.ticking&(dot.stellar_flare.ticking|!talent.stellar_flare.enabled))
    if S.CelestialAlignment:IsCastableP() and (not Player:BuffP(CaInc()) and (Player:BuffP(S.MemoryOfLucidDreams) or (AP_Check(S.CelestialAlignment) and FutureAstralPower() >= 40)) and (not S.LivelySpirit:AzeriteEnabled() or Player:BuffP(S.LivelySpiritBuff)) and (Target:DebuffRemainsP(S.SunfireDebuff) > 2 and Target:DebuffP(S.MoonfireDebuff) and (Target:DebuffP(S.StellarFlareDebuff) or not S.StellarFlare:IsAvailable()))) then
       return S.CelestialAlignment:Cast()
    end
	-- fury_of_elune,if=(buff.celestial_alignment.up|buff.incarnation.up)|(cooldown.celestial_alignment.remains>30|cooldown.incarnation.remains>30)
    if S.FuryofElune:IsReady() and ((Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) or (S.CelestialAlignment:CooldownRemainsP() > 30 or S.Incarnation:CooldownRemainsP() > 30)) then
        return S.FuryofElune:Cast()
    end
    -- force_of_nature,if=(buff.celestial_alignment.up|buff.incarnation.up)|(cooldown.celestial_alignment.remains>30|cooldown.incarnation.remains>30)
    if S.ForceofNature:IsReady() and ((Player:BuffP(S.CelestialAlignmentBuff) or Player:BuffP(S.IncarnationBuff)) or (S.CelestialAlignment:CooldownRemainsP() > 30 or S.Incarnation:CooldownRemainsP() > 30)) then
        return S.ForceofNature:Cast()
    end
	-- call_action_list,name=essences
    local ShouldReturn = Essences(); 
	    if ShouldReturn and (true) then return ShouldReturn; 
	end
end

local function Dot ()
    -- TODO(mrdmnd): add conditions on azerite traits
    -- Code largely lifted from assassination implmentation.
    --actions+=/sunfire,
    --          target_if=refreshable|(variable.az_hn=3&active_enemies<=2&(dot.moonfire.ticking|time_to_die<=6.6)&(!talent.stellar_flare.enabled|dot.stellar_flare.ticking|time_to_die<=7.2)&astral_power<40),
    --          if=astral_power.deficit>=7&target.time_to_die>5.4&(!buff.celestial_alignment.up&!buff.incarnation.up|!variable.az_streak|!prev_gcd.1.sunfire)|variable.az_hn=3
    --actions+=/moonfire,
    --          target_if=refreshable,
    --          if=astral_power.deficit>=7&target.time_to_die>6.6&(!buff.celestial_alignment.up&!buff.incarnation.up|!variable.az_streak|!prev_gcd.1.moonfire)
    --actions+=/stellar_flare,
    --          target_if=refreshable,
    --          if=astral_power.deficit>=12&target.time_to_die>7.2&(!buff.celestial_alignment.up&!buff.incarnation.up|!variable.az_streak|!prev_gcd.1.stellar_flare)
    local function Evaluate_Sunfire_Target(TargetUnit)
        return TargetUnit:DebuffRefreshableCP(S.SunfireDebuff) and Target:TimeToDie() > 5.4
    end
    local function Evaluate_Moonfire_Target(TargetUnit)
        return TargetUnit:DebuffRefreshableCP(S.MoonfireDebuff) and Target:TimeToDie() > 6.6
    end
    local function Evaluate_StellarFlare_Target(TargetUnit)
        return TargetUnit:DebuffRefreshableCP(S.StellarFlare) and Target:TimeToDie() > 7.2
    end

    -- main target refreshes
    if Evaluate_Sunfire_Target(Target) then
        return S.Sunfire:Cast()
    end
    if Evaluate_Moonfire_Target(Target) then
        return S.Moonfire:Cast()
    end
    if S.StellarFlare:IsReady() and not Player:PrevGCDP(1, S.StellarFlare) and Evaluate_StellarFlare_Target(Target) then
        return S.StellarFlare:Cast()
    end
end

local function EmpowermentCapCheck ()
    -- TODO(mrdmnd) - add conditions on azerite traits
    --actions+=/lunar_strike,
    --          if=astral_power.deficit>=16&
    --          (buff.lunar_empowerment.stack=3|(spell_targets<3 & astral_power>=40 & (buff.lunar_empowerment.stack=2&buff.solar_empowerment.stack=2)))&
    --          !(variable.az_hn=3&active_enemies=1)&
    --          !(spell_targets.moonfire>=2&variable.az_potm=3&active_enemies=2)
    --actions+=/solar_wrath,
    --          if=astral_power.deficit>=12&
    --          (buff.solar_empowerment.stack=3|(variable.az_sb>1&spell_targets.starfall<3&astral_power>=32&!buff.sunblaze.up))&
    --          !(variable.az_hn=3&active_enemies=1)&
    --          !(spell_targets.moonfire>=2&active_enemies<=4&variable.az_potm=3)
    if S.LunarStrike:IsReady() and Player:AstralPowerDeficit() >= 16 and (Player:BuffStackP(S.LunarEmpowermentBuff) == 3 or (Cache.EnemiesCount[40] < 3 and Player:AstralPower() >= 40 and Player:BuffStackP(S.LunarEmpowermentBuff) == 2 and Player:BuffStack(S.SolarEmpowermentBuff) == 2)) then
        return S.LunarStrike:Cast()
    end

    if S.SolarWrath:IsReady() and Player:AstralPowerDeficit() >= 12 and (Player:BuffStackP(S.SolarEmpowermentBuff) == 3) then
        return S.SolarWrath:Cast()
    end
end

local function CoreRotation ()
    -- TODO(mrdmnd): Implement conditionals on azerite traits. For now, assume all vairable.az_WHATEVER evaluates to zero.
    -- actions+=/starsurge,if=(spell_targets.starfall<3&(!buff.starlord.up|buff.starlord.remains>=4)|execute_time*(astral_power%40)>target.time_to_die)&(!buff.celestial_alignment.up&!buff.incarnation.up|variable.az_streak<2|!prev_gcd.1.starsurge)
    -- actions+=/starfall,if=spell_targets.starfall>=3&(!buff.starlord.up|buff.starlord.remains>=4)
    -- actions+=/new_moon,if=astral_power.deficit>10+execute_time%1.5
    -- actions+=/half_moon,if=astral_power.deficit>20+execute_time%1.5
    -- actions+=/full_moon,if=astral_power.deficit>40+execute_time%1.5
    -- actions+=/lunar_strike,if=((buff.warrior_of_elune.up|buff.lunar_empowerment.up|spell_targets>=3&!buff.solar_empowerment.up)&(!buff.celestial_alignment.up&!buff.incarnation.up|variable.az_streak<2|!prev_gcd.1.lunar_strike)|(variable.az_ds&!buff.dawning_sun.up))&!(spell_targets.moonfire>=2&active_enemies<=4&(variable.az_potm=3|variable.az_potm=2&active_enemies=2))
    -- actions+=/solar_wrath,if=(!buff.celestial_alignment.up&!buff.incarnation.up|variable.az_streak<2|!prev_gcd.1.solar_wrath)&!(spell_targets.moonfire>=2&active_enemies<=4&(variable.az_potm=3|variable.az_potm=2&active_enemies=2))
    -- actions+=/sunfire,if=(!buff.celestial_alignment.up&!buff.incarnation.up|!variable.az_streak|!prev_gcd.1.sunfire)&!(variable.az_potm>=2&spell_targets.moonfire>=2)
    -- actions+=/moonfire
    if S.Starsurge:IsReady() and Cache.EnemiesCount[40] < 3 and (not Player:BuffP(S.StarlordBuff) or Player:BuffRemainsP(S.StarlordBuff) >= 4 or (Player:GCD() * (FutureAstralPower() / 40)) > Target:TimeToDie()) and FutureAstralPower() >= 40 then
        return S.Starsurge:Cast()
    end
    if S.Starfall:IsReady() and Cache.EnemiesCount[40] >= 3 and (not Player:BuffP(S.StarlordBuff) or Player:BuffRemainsP(S.StarlordBuff) >= 4) and FutureAstralPower() >= 50 and active_enemies() > 7 then
        return S.Starfall:Cast()
    end
    if S.NewMoon:IsReady() and (Player:AstralPowerDeficit() > 10 + (Player:GCD() / 1.5)) then
        return S.NewMoon:Cast()
    end
    if S.HalfMoon:IsReady() and (Player:AstralPowerDeficit() > 20 + (Player:GCD() / 1.5)) then
        return S.HalfMoon:Cast()
    end
    if S.FullMoon:IsReady() and (Player:AstralPowerDeficit() > 40 + (Player:GCD() / 1.5)) then
        return S.FullMoon:Cast()
    end
    -- Lunar strike when warrior of elune or OwlkinFrenzy is up
    if S.LunarStrike:IsReady() and (Player:BuffP(S.WarriorofEluneBuff) or Player:BuffP(S.OwlkinFrenzyBuff)) then
        return S.LunarStrike:Cast()
    end
    -- don't suggest an empowered cast if we're casting the last empowered stack
    -- bad assumption: detects cleave targets based on 20yds from caster, centered. cannot do clump detection, i am not clever enough yet
    if (Cache.EnemiesCount[40] >= 2) then
        -- Cleave situation: prioritize lunar strike empower > solar wrath empower > lunar strike
        if S.LunarStrike:IsReady() and Player:BuffP(S.LunarEmpowermentBuff) and not (Player:BuffStackP(S.LunarEmpowermentBuff) == 1 and Player:IsCasting(S.LunarStrike)) then
            return S.LunarStrike:Cast()
        end
        if S.SolarWrath:IsReady() and Player:BuffP(S.SolarEmpowermentBuff) and not (Player:BuffStackP(S.SolarEmpowermentBuff) == 1 and Player:IsCasting(S.SolarWrath)) then
            return S.SolarWrath:Cast()
        end
        if S.LunarStrike:IsReady() and (true) then
            return S.LunarStrike:Cast()
        end
    else
        -- ST situation: prioritize solar wrath empower > lunar strike empower > solar wrath
        if S.SolarWrath:IsReady() and Player:BuffP(S.SolarEmpowermentBuff) and not (Player:BuffStackP(S.SolarEmpowermentBuff) == 1 and Player:IsCasting(S.SolarWrath)) then
            return S.SolarWrath:Cast()
        end
        if S.LunarStrike:IsReady() and Player:BuffP(S.LunarEmpowermentBuff) and not (Player:BuffStackP(S.LunarEmpowermentBuff) == 1 and Player:IsCasting(S.LunarStrike)) then
            return S.LunarStrike:Cast()
        end
        if S.SolarWrath:IsReady() and (true) then
            return S.SolarWrath:Cast()
        end
    end

    if S.Moonfire:IsReady() and (true) then
        return S.Moonfire:Cast()
    end
end

--- ======= ACTION LISTS =======
local function APL()
    local Precombat, Aoe, Ed, St
    UpdateRanges()
	
	Precombat_DBM = function()
	    DetermineEssenceRanks()
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
	    DetermineEssenceRanks()
        -- flask
        -- food
        -- augmentation
        -- moonkin_form
        if GetShapeshiftForm() ~= 4 and RubimRH.AutoMorphON() then
            return S.MoonkinForm:Cast()
        end
        -- snapshot_stats
        -- potion
        -- solar_wrath
        -- solar_wrath
        if S.SolarWrath:IsReady() and not Player:IsCasting(S.SolarWrath) then
            return S.SolarWrath:Cast()
        end
        -- sunfire
        if S.Sunfire:IsReady() and (true) then
            return S.Sunfire:Cast()
        end
    end
    Aoe = function()
        -- fury_of_elune,if=(buff.celestial_alignment.up|buff.incarnation.up)|(cooldown.celestial_alignment.remains>30|cooldown.incarnation.remains>30)
        if S.FuryofElune:IsReady() and ((Player:Buff(S.CelestialAlignmentBuff) or Player:Buff(S.IncarnationBuff)) or (S.CelestialAlignment:CooldownRemains() > 30 or S.Incarnation:CooldownRemains() > 30)) then
            return S.FuryofElune:Cast()
        end
        -- force_of_nature,if=(buff.celestial_alignment.up|buff.incarnation.up)|(cooldown.celestial_alignment.remains>30|cooldown.incarnation.remains>30)
        if S.ForceofNature:IsReady() and ((Player:Buff(S.CelestialAlignmentBuff) or Player:Buff(S.IncarnationBuff)) or (S.CelestialAlignment:CooldownRemains() > 30 or S.Incarnation:CooldownRemains() > 30)) then
            return S.ForceofNature:Cast()
        end
        -- sunfire,target_if=refreshable,if=astral_power.deficit>7&target.time_to_die>4
        if S.Sunfire:IsReady() and Target:DebuffRemains(S.SunfireDebuff) <= 3 and (Player:AstralPowerDeficit() > 7 and Target:TimeToDie() > 4) then
            return S.Sunfire:Cast()
        end
        -- moonfire,target_if=refreshable,if=astral_power.deficit>7&target.time_to_die>4
        if S.Moonfire:IsReady() and Target:DebuffRemains(S.MoonfireDebuff) <= 3 and (Player:AstralPowerDeficit() > 7 and Target:TimeToDie() > 4) then
            return S.Moonfire:Cast()
        end
        -- stellar_flare,target_if=refreshable,if=target.time_to_die>10
        if S.StellarFlare:IsReady() and not Player:PrevGCDP(1, S.StellarFlare) and Target:DebuffRemains(S.StellarFlare) <= 3 and (Target:TimeToDie() > 10) then
            return S.StellarFlare:Cast()
        end
        -- lunar_strike,if=(buff.lunar_empowerment.stack=3|buff.solar_empowerment.stack=2&buff.lunar_empowerment.stack=2&astral_power>=40)&astral_power.deficit>14
        if S.LunarStrike:IsReady() and ((Player:BuffStack(S.LunarEmpowermentBuff) == 3 or Player:BuffStack(S.SolarEmpowermentBuff) == 2 and Player:BuffStack(S.LunarEmpowermentBuff) == 2 and FutureAstralPower() >= 40) and Player:AstralPowerDeficit() > 14) then
            return S.LunarStrike:Cast()
        end
        -- solar_wrath,if=buff.solar_empowerment.stack=3&astral_power.deficit>10
        if S.SolarWrath:IsReady() and (Player:BuffStack(S.SolarEmpowermentBuff) == 3 and Player:AstralPowerDeficit() > 10) then
            return S.SolarWrath:Cast()
        end
        -- starsurge,if=buff.oneths_intuition.react|target.time_to_die<=4
        if S.Starsurge:IsReady() and (bool(Player:BuffStack(S.OnethsIntuitionBuff)) or Target:TimeToDie() <= 4) then
            return S.Starsurge:Cast()
        end
        -- starfall,if=!buff.starlord.up|buff.starlord.remains>=4
        if S.Starfall:IsReady() and (not Player:Buff(S.StarlordBuff) or Player:BuffRemains(S.StarlordBuff) >= 4) and active_enemies() > 7 then
            return S.Starfall:Cast()
        end
        -- new_moon,if=astral_power.deficit>12
        if S.NewMoon:IsReady() and (Player:AstralPowerDeficit() > 12) then
            return S.NewMoon:Cast()
        end
        -- half_moon,if=astral_power.deficit>22
        if S.HalfMoon:IsReady() and (Player:AstralPowerDeficit() > 22) then
            return S.HalfMoon:Cast()
        end
        -- full_moon,if=astral_power.deficit>42
        if S.FullMoon:IsReady() and (Player:AstralPowerDeficit() > 42) then
            return S.FullMoon:Cast()
        end
        -- solar_wrath,if=(buff.solar_empowerment.up&!buff.warrior_of_elune.up|buff.solar_empowerment.stack>=3)&buff.lunar_empowerment.stack<3
        if S.SolarWrath:IsReady() and ((Player:Buff(S.SolarEmpowermentBuff) and not Player:Buff(S.WarriorofEluneBuff) or Player:BuffStack(S.SolarEmpowermentBuff) >= 3) and Player:BuffStack(S.LunarEmpowermentBuff) < 3) then
            return S.SolarWrath:Cast()
        end
        -- lunar_strike
        if S.LunarStrike:IsReady() and (true) then
            return S.LunarStrike:Cast()
        end
        -- moonfire
        if S.Moonfire:IsReady() and (true) then
            return S.Moonfire:Cast()
        end
    end
    Ed = function()
        -- incarnation,if=astral_power>=30
        if S.Incarnation:IsReady() and (FutureAstralPower() >= 30) then
            return S.Incarnation:Cast()
        end
        -- celestial_alignment,if=astral_power>=30
        if S.CelestialAlignment:IsReady() and (FutureAstralPower() >= 30) then
            return S.CelestialAlignment:Cast()
        end
        -- fury_of_elune,if=(buff.celestial_alignment.up|buff.incarnation.up)|(cooldown.celestial_alignment.remains>30|cooldown.incarnation.remains>30)&(buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up)
        if S.FuryofElune:IsReady() and ((Player:Buff(S.CelestialAlignmentBuff) or Player:Buff(S.IncarnationBuff)) or (S.CelestialAlignment:CooldownRemains() > 30 or S.Incarnation:CooldownRemains() > 30) and (Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > Player:GCD() or not Player:Buff(S.TheEmeraldDreamcatcherBuff))) then
            return S.FuryofElune:Cast()
        end
        -- force_of_nature,if=(buff.celestial_alignment.up|buff.incarnation.up)|(cooldown.celestial_alignment.remains>30|cooldown.incarnation.remains>30)&(buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up)
        if S.ForceofNature:IsReady() and ((Player:Buff(S.CelestialAlignmentBuff) or Player:Buff(S.IncarnationBuff)) or (S.CelestialAlignment:CooldownRemains() > 30 or S.Incarnation:CooldownRemains() > 30) and (Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > Player:GCD() or not Player:Buff(S.TheEmeraldDreamcatcherBuff))) then
            return S.ForceofNature:Cast()
        end
        -- starsurge,if=(gcd.max*astral_power%30)>target.time_to_die
        if S.Starsurge:IsReady() and ((Player:GCD() * FutureAstralPower() / 30) > Target:TimeToDie()) then
            return S.Starsurge:Cast()
        end
        -- moonfire,target_if=refreshable,if=buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up
        if S.Moonfire:IsReady() and Target:DebuffRemains(S.MoonfireDebuff) <= 3 and (Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > Player:GCD() or not Player:Buff(S.TheEmeraldDreamcatcherBuff)) then
            return S.Moonfire:Cast()
        end
        -- sunfire,target_if=refreshable,if=buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up
        if S.Sunfire:IsReady() and Target:DebuffRemains(S.SunfireDebuff) <= 3 and (Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > Player:GCD() or not Player:Buff(S.TheEmeraldDreamcatcherBuff)) then
            return S.Sunfire:Cast()
        end
        -- stellar_flare,target_if=refreshable,if=buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up
        if S.StellarFlare:IsReady() and not Player:PrevGCDP(1, S.StellarFlare) and Target:DebuffRemains(S.StellarFlare) <= 3 and (Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > Player:GCD() or not Player:Buff(S.TheEmeraldDreamcatcherBuff)) then
            return S.StellarFlare:Cast()
        end
        -- starfall,if=buff.oneths_overconfidence.up&(buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up)
        if S.Starfall:IsReady() and (Player:Buff(S.OnethsOverconfidenceBuff) and (Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > Player:GCD() or not Player:Buff(S.TheEmeraldDreamcatcherBuff))) and active_enemies() > 2 and active_enemies() < 7 then
            return S.Starfall:Cast()
        end
        -- new_moon,if=buff.the_emerald_dreamcatcher.remains>execute_time|!buff.the_emerald_dreamcatcher.up
        if S.NewMoon:IsReady() and (Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > S.NewMoon:ExecuteTime() or not Player:Buff(S.TheEmeraldDreamcatcherBuff)) then
            return S.NewMoon:Cast()
        end
        -- half_moon,if=astral_power.deficit>=20&(buff.the_emerald_dreamcatcher.remains>execute_time|!buff.the_emerald_dreamcatcher.up)
        if S.HalfMoon:IsReady() and (Player:AstralPowerDeficit() >= 20 and (Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > S.HalfMoon:ExecuteTime() or not Player:Buff(S.TheEmeraldDreamcatcherBuff))) then
            return S.HalfMoon:Cast()
        end
        -- full_moon,if=astral_power.deficit>=40&(buff.the_emerald_dreamcatcher.remains>execute_time|!buff.the_emerald_dreamcatcher.up)
        if S.FullMoon:IsReady() and (Player:AstralPowerDeficit() >= 40 and (Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > S.FullMoon:ExecuteTime() or not Player:Buff(S.TheEmeraldDreamcatcherBuff))) then
            return S.FullMoon:Cast()
        end
        -- lunar_strike,,if=buff.lunar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time
        if S.LunarStrike:IsReady() and (Player:Buff(S.LunarEmpowermentBuff) and Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > S.LunarStrike:ExecuteTime()) then
            return S.LunarStrike:Cast()
        end
        -- solar_wrath,if=buff.solar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time
        if S.SolarWrath:IsReady() and (Player:Buff(S.SolarEmpowermentBuff) and Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) > S.SolarWrath:ExecuteTime()) then
            return S.SolarWrath:Cast()
        end
        -- starsurge,if=(buff.the_emerald_dreamcatcher.up&buff.the_emerald_dreamcatcher.remains<gcd.max)|astral_power>=50
        if S.Starsurge:IsReady() and ((Player:Buff(S.TheEmeraldDreamcatcherBuff) and Player:BuffRemains(S.TheEmeraldDreamcatcherBuff) < Player:GCD()) or FutureAstralPower() >= 50) then
            return S.Starsurge:Cast()
        end
        -- solar_wrath
        if S.SolarWrath:IsReady() and (true) then
            return S.SolarWrath:Cast()
        end
    end
    St = function()
        -- fury_of_elune,if=(buff.celestial_alignment.up|buff.incarnation.up)|(cooldown.celestial_alignment.remains>30|cooldown.incarnation.remains>30)
        if S.FuryofElune:IsReady() and ((Player:Buff(S.CelestialAlignmentBuff) or Player:Buff(S.IncarnationBuff)) or (S.CelestialAlignment:CooldownRemains() > 30 or S.Incarnation:CooldownRemains() > 30)) then
            return S.FuryofElune:Cast()
        end
        -- force_of_nature,if=(buff.celestial_alignment.up|buff.incarnation.up)|(cooldown.celestial_alignment.remains>30|cooldown.incarnation.remains>30)
        if S.ForceofNature:IsReady() and ((Player:Buff(S.CelestialAlignmentBuff) or Player:Buff(S.IncarnationBuff)) or (S.CelestialAlignment:CooldownRemains() > 30 or S.Incarnation:CooldownRemains() > 30)) then
            return S.ForceofNature:Cast()
        end
        -- moonfire,target_if=refreshable,if=target.time_to_die>8
        if S.Moonfire:IsReady() and Target:DebuffRemains(S.MoonfireDebuff) <= 3 and (Target:TimeToDie() > 8) then
            return S.Moonfire:Cast()
        end
        -- sunfire,target_if=refreshable,if=target.time_to_die>8
        if S.Sunfire:IsReady() and Target:DebuffRemains(S.SunfireDebuff) <= 3 and (Target:TimeToDie() > 8) then
            return S.Sunfire:Cast()
        end
        -- stellar_flare,target_if=refreshable,if=target.time_to_die>10
        if S.StellarFlare:IsReady() and not Player:PrevGCDP(1, S.StellarFlare) and Target:DebuffRemains(S.StellarFlare) <= 3 and (Target:TimeToDie() > 10) then
            return S.StellarFlare:Cast()
        end
        -- solar_wrath,if=(buff.solar_empowerment.stack=3|buff.solar_empowerment.stack=2&buff.lunar_empowerment.stack=2&astral_power>=40)&astral_power.deficit>10
        if S.SolarWrath:IsReady() and ((Player:BuffStack(S.SolarEmpowermentBuff) == 3 or Player:BuffStack(S.SolarEmpowermentBuff) == 2 and Player:BuffStack(S.LunarEmpowermentBuff) == 2 and FutureAstralPower() >= 40) and Player:AstralPowerDeficit() > 10) then
            return S.SolarWrath:Cast()
        end
        -- lunar_strike,if=buff.lunar_empowerment.stack=3&astral_power.deficit>14
        if S.LunarStrike:IsReady() and (Player:BuffStack(S.LunarEmpowermentBuff) == 3 and Player:AstralPowerDeficit() > 14) then
            return S.LunarStrike:Cast()
        end
        -- starfall,if=buff.oneths_overconfidence.react
        --if S.Starfall:IsReady() and (bool(Player:BuffStack(S.OnethsOverconfidenceBuff))) then
        --    return S.Starfall:Cast()
        --end
        -- starsurge,if=!buff.starlord.up|buff.starlord.remains>=4|(gcd.max*(astral_power%40))>target.time_to_die
        if S.Starsurge:IsReady() and (not Player:Buff(S.StarlordBuff) or Player:BuffRemains(S.StarlordBuff) >= 4 or (Player:GCD() * (FutureAstralPower() / 40)) > Target:TimeToDie()) then
            return S.Starsurge:Cast()
        end
        -- lunar_strike,if=(buff.warrior_of_elune.up|!buff.solar_empowerment.up)&buff.lunar_empowerment.up
        if S.LunarStrike:IsReady() and ((Player:Buff(S.WarriorofEluneBuff) or not Player:Buff(S.SolarEmpowermentBuff)) and Player:Buff(S.LunarEmpowermentBuff)) then
            return S.LunarStrike:Cast()
        end
        -- new_moon,if=astral_power.deficit>10
        if S.NewMoon:IsReady() and (Player:AstralPowerDeficit() > 10) then
            return S.NewMoon:Cast()
        end
        -- half_moon,if=astral_power.deficit>20
        if S.HalfMoon:IsReady() and (Player:AstralPowerDeficit() > 20) then
            return S.HalfMoon:Cast()
        end
        -- full_moon,if=astral_power.deficit>40
        if S.FullMoon:IsReady() and (Player:AstralPowerDeficit() > 40) then
            return S.FullMoon:Cast()
        end
        -- solar_wrath
        if S.SolarWrath:IsReady() and (true) then
            return S.SolarWrath:Cast()
        end
        -- moonfire
        if S.Moonfire:IsReady() and (true) then
            return S.Moonfire:Cast()
        end
    end
	
	-- heal on 40%
	if S.Regrowth:IsCastableP() and Player:HealthPercentage() <= RubimRH.db.profile[102].sk1 then
        return S.Regrowth:Cast()
    end
	
    -- call precombat
    if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) then
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
	
	-- combat
    if RubimRH.TargetIsValid() then
	    -- moonkin_form
        if S.MoonkinForm:IsCastableP() and not Player:Buff(S.MoonkinForm) and RubimRH.AutoMorphON() then
           return S.MoonkinForm:Cast()
        end

	    if QueueSkill() ~= nil then
           return QueueSkill()
        end

	     -- Solar Beam
        if S.SolarBeam:IsReady() and Target:IsInterruptible() and RubimRH.InterruptsON() then
            return S.SolarBeam:Cast()
        end
		
        if RubimRH.CDsON() then
            if CDs() ~= nil then
                return CDs()
            end
        end
		
		-- blood_of_the_enemy,if=cooldown.ca_inc.remains>30
        if S.BloodOfTheEnemy:IsCastableP() and (CaInc():CooldownRemainsP() > 30) then
          return S.UnleashHeartOfAzeroth:Cast()
        end
        -- memory_of_lucid_dreams,if=dot.sunfire.remains>10&dot.moonfire.remains>10&(!talent.stellar_flare.enabled|dot.stellar_flare.remains>10)&(astral_power<40|cooldown.ca_inc.remains>30)&!buff.ca_inc.up
        if S.MemoryOfLucidDreams:IsCastableP() and (Target:DebuffRemainsP(S.SunfireDebuff) > 10 and (not S.StellarFlare:IsAvailable() or Target:DebuffRemainsP(S.StellarFlareDebuff) > 10) and (FutureAstralPower() < 40 or CaInc():CooldownRemainsP() > 30) and not Player:BuffP(CaInc())) then
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
        -- guardian_of_azeroth
        if S.GuardianOfAzeroth:IsCastableP() then
          return S.UnleashHeartOfAzeroth:Cast()
        end
        -- thorns
        if S.Thorns:IsCastableP() then
          return S.Thorns:Cast()
        end

        if Dot() ~= nil then
            return Dot()
        end

        if EmpowermentCapCheck() ~= nil then
            return EmpowermentCapCheck()
        end

        if CoreRotation() ~= nil then
            return CoreRotation()
        end
    end
	return 0, 135328
end

RubimRH.Rotation.SetAPL(102, APL)

local function PASSIVE()
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(102, PASSIVE)