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
RubimRH.Spell[66] = {
    BastionOfLight = Spell(204035),
    Seraphim = Spell(152262),
    ShieldoftheRighteous = Spell(53600),
    AvengingWrath = Spell(31884),
    SeraphimBuff = Spell(152262),
    AvengingWrathBuff = Spell(31884),
    AvengersValorBuff = Spell(197561),
    LightsJudgment = Spell(255647),
    AvengersShield = Spell(31935),
    Judgment = Spell(275779),
    CrusadersJudgment = Spell(204023),
    Consecration = Spell(26573),
    BlessedHammer = Spell(204019),
    HammeroftheRighteous = Spell(53595),
    ArdentDefender = Spell(31850),
    GuardianOfAncientKings = Spell(86659),
    HandOfTheProtector = Spell(213652),
    BlessingOfProtection = Spell(1022),
    BlessingOfSacrifice = Spell(6940),
    BlessingOfFreedom = Spell(1044),
    Forbearance = Spell(25771),
    LayOnHands = Spell(633),
    ConsecrationBuff = Spell(188370),
    LightofTheProtector = Spell(184092),
    ShieldoftheRighteousBuff = Spell(132403),

    InqusitionDebuff = Spell(206891),
    Inqusition = Spell(207028),
    HammerofJustice = Spell(853),
    Rebuke = Spell(96231),
	
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

};

local S = RubimRH.Spell[66];
local G = RubimRH.Spell[1]; -- General Skills

-- Items
if not Item.Paladin then
    Item.Paladin = {}
end
Item.Paladin.Protection = {
    ProlongedPower = Item(142117)
};
local I = Item.Paladin.Protection;


-- Variables

local EnemyRanges = { 8 }
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

local OffensiveCDs = {
    S.AvengingWrath
}

local function ConcerationTime()
    for i = 1, 5 do
        local active, totemName, startTime, duration, textureId = GetTotemInfo(i)
        if active == true then
            return startTime + duration - GetTime()
        end
    end
    return 0
end

local function UpdateCDs()
    if RubimRH.config.cooldown then
        for i, spell in pairs(OffensiveCDs) do
            if not spell:IsEnabledCD() then
                RubimRH.delSpellDisabledCD(spell:ID())
            end
        end

    end
    if not RubimRH.config.cooldown then
        for i, spell in pairs(OffensiveCDs) do
            if spell:IsEnabledCD() then
                RubimRH.addSpellDisabledCD(spell:ID())
            end
        end
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
  if S.MemoryOfLucidDreams:IsCastableP() and Player:Fury() < 40 and bool(Player:BuffP(S.MetamorphosisBuff)) then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  return false
end

--- ======= ACTION LISTS =======
local function APL()
    local Precombat
    UpdateRanges()
    UpdateCDs()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- potion
    end
    -- call precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end

    if S.AvengersShield:IsReady() and Target:IsInterruptible() and RubimRH.ASInterruptON() then
        return S.AvengersShield:Cast()
    end
    if S.Rebuke:IsReady() and RubimRH.db.profile.mainOption.useInterrupts and Target:IsInterruptible() then
        return S.Rebuke:Cast()
    end

    if (S.LightofTheProtector:IsReady() or S.HandOfTheProtector:IsReady()) and Player:HealthPercentage() <= RubimRH.db.profile[66].sk1 and not Player:HealingAbsorbed() then
        return S.LightofTheProtector:Cast()
    end

    if S.ShieldoftheRighteous:IsReady() and not Player:BuffP(S.ShieldoftheRighteousBuff) and not Player:BuffP(S.AvengingWrathBuff) and Player:HealthPercentage() < 75 and RubimRH.ASInterruptON() then
        return S.ShieldoftheRighteous:Cast()
    end

	-- actions.cds+=/call_action_list,name=essences
    if (RubimRH.CDsON()) then
        if Essences() ~= nil then
            return Essences()
        end
    end
	
    -- auto_attack
    -- seraphim,if=cooldown.shield_of_the_righteous.charges_fractional>=2
    if S.Seraphim:IsReady() and (S.ShieldoftheRighteous:ChargesFractional() >= 2) then
        return S.Seraphim:Cast()
    end
    -- avenging_wrath,if=buff.seraphim.up|cooldown.seraphim.remains<2|!talent.seraphim.enabled
    if S.AvengingWrath:IsReady() and (Player:Buff(S.SeraphimBuff) or S.Seraphim:CooldownRemains() < 2 or not S.Seraphim:IsAvailable()) then
        return S.AvengingWrath:Cast()
    end
    -- bastion_of_light,if=cooldown.shield_of_the_righteous.charges_fractional<=0.5
    if S.BastionOfLight:IsReady() and S.ShieldoftheRighteous:ChargesFractional() <= 0.5 then
        return S.BastionOfLight:Cast()
    end
    -- Mouseover Functionality
    local MouseoverUnit = (UnitExists("mouseover") and UnitIsFriend("player", "mouseover") and (UnitGUID("mouseover") ~= UnitGUID("player"))) and Unit("mouseover") or nil
    if MouseoverUnit then
        -- Hand of the Protector -> Mouseover
        if S.HandOfTheProtector:IsReady()
                and MouseoverUnit:NeedMajorHealing() then
            return S.HandOfTheProtector:Cast()
        end

        -- Blessing of Protection -> Mousover
        if S.BlessingOfProtection:IsReady()
                and MouseoverUnitNeedsBoP then
            return S.BlessingOfProtection:Cast()
        end
    end

    --    Blessing Of Sacrifice
    local MouseoverUnitNeedsBlessingOfSacrifice = (MouseoverUnitValid and Player:HealthPercentage() <= 80) and true or false
    if MouseoverUnitNeedsBlessingOfSacrifice and S.BlessingOfSacrifice:IsReady(40, false, MouseoverUnit) then
        return S.BlessingOfSacrifice:Cast()
    end

    -- Blessing of Freedom -> if snared
    if Player:IsSnared()
            and S.BlessingOfFreedom:IsReady() then
        return S.BlessingOfFreedom:Cast()
    end

    -- TODO: Restore these when GGLoader texture updates are complete
    -- Lay on Hands
    if S.LayOnHands:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[66].sk4 and not Player:Debuff(S.Forbearance) and not Player:Buff(S.ArdentDefender) and not Player:Buff(S.GuardianOfAncientKings) then
        return S.LayOnHands:Cast()
    end

    -- Guardian of Ancient Kings -> Use on Panic Heals, should be proactively cast by user
    if S.GuardianOfAncientKings:IsReady() and Player:HealthPercentage() < RubimRH.db.profile[66].sk3 and not Player:Buff(S.ArdentDefender) then
        return S.GuardianOfAncientKings:Cast()
    end

    -- Ardent Defender -> Ardent defender @ Player:NeedPanicHealing() <= 90% HP, should be proactively cast by the
    if S.ArdentDefender:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[66].sk2 and not Player:Buff(S.GuardianOfAncientKings) then
        return S.ArdentDefender:Cast()
    end

    -- shield_of_the_righteous,if=(buff.avengers_valor.up&cooldown.shield_of_the_righteous.charges_fractional>=2.5)&(cooldown.seraphim.remains>gcd|!talent.seraphim.enabled)
    if S.ShieldoftheRighteous:IsReady() and ((Player:Buff(S.AvengersValorBuff) and S.ShieldoftheRighteous:ChargesFractional() >= 2.5) and (S.Seraphim:CooldownRemains() > Player:GCD() or not S.Seraphim:IsAvailable())) then
        return S.ShieldoftheRighteous:Cast()
    end
    
    -- shield_of_the_righteous,if=(buff.avenging_wrath.up&!talent.seraphim.enabled)|buff.seraphim.up&buff.avengers_valor.up
    if S.ShieldoftheRighteous:IsReady() and ((Player:Buff(S.AvengingWrathBuff) and not S.Seraphim:IsAvailable()) or Player:Buff(S.SeraphimBuff) and Player:Buff(S.AvengersValorBuff)) then
        return S.ShieldoftheRighteous:Cast()
    end
    -- shield_of_the_righteous,if=(buff.avenging_wrath.up&buff.avenging_wrath.remains<4&!talent.seraphim.enabled)|(buff.seraphim.remains<4&buff.seraphim.up)
    if S.ShieldoftheRighteous:IsReady() and ((Player:Buff(S.AvengingWrathBuff) and Player:BuffRemains(S.AvengingWrathBuff) < 4 and not S.Seraphim:IsAvailable()) or (Player:BuffRemains(S.SeraphimBuff) < 4 and Player:Buff(S.SeraphimBuff))) then
        return S.ShieldoftheRighteous:Cast()
    end
    -- lights_judgment,if=buff.seraphim.up&buff.seraphim.remains<3
    if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (Player:Buff(S.SeraphimBuff) and Player:BuffPRemains(S.SeraphimBuff) < 3) then
        return S.LightsJudgment:Cast()
    end

    -- consecration,if=!consecration.up
    if S.Consecration:IsReady() and not Player:BuffP(S.ConsecrationBuff)   then
        return S.Consecration:Cast()
    end

    -- avengers_shield,if=(cooldown.shield_of_the_righteous.charges_fractional>2.5&!buff.avengers_valor.up)|active_enemies>=2
    if S.AvengersShield:IsReady() and ((S.ShieldoftheRighteous:ChargesFractional() > 2.5 and not Player:Buff(S.AvengersValorBuff)) or Cache.EnemiesCount[8] >= 2) and not RubimRH.ASInterruptON() then
        return S.AvengersShield:Cast()
    end
    -- judgment,if=(cooldown.judgment.remains<gcd&cooldown.judgment.charges_fractional>1&cooldown_react)|!talent.crusaders_judgment.enabled
    if S.Judgment:IsReady() and ((S.Judgment:CooldownRemains() < Player:GCD() and S.Judgment:ChargesFractional() > 1 and S.Judgment:CooldownUpP()) or not S.CrusadersJudgment:IsAvailable()) then
        return S.Judgment:Cast()
    end

    -- avengers_shield,if=cooldown_react
    if S.AvengersShield:IsReady() and S.AvengersShield:CooldownUpP() and not RubimRH.ASInterruptON() then
        return S.AvengersShield:Cast()
    end

    -- judgment,if=cooldown_react|!talent.crusaders_judgment.enabled
    if S.Judgment:IsReady() and (S.Judgment:CooldownUpP() or not S.CrusadersJudgment:IsAvailable()) then
        return S.Judgment:Cast()
    end

    -- lights_judgment,if=!talent.seraphim.enabled|buff.seraphim.up
    if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (S.Seraphim:IsAvailable() or Player:Buff(S.SeraphimBuff)) then
        return S.LightsJudgment:Cast()
    end
    
    -- actions+=/blessed_hammer,strikes=3
    if S.BlessedHammer:IsReady() then
        return S.BlessedHammer:Cast()
    end
    -- hammer_of_the_righteous
    if S.HammeroftheRighteous:IsReady() then
        return S.HammeroftheRighteous:Cast()
    end

    -- consecration
    if S.Consecration:IsReady()  then
        return S.Consecration:Cast()
    end

    return 0, 135328
end

RubimRH.Rotation.SetAPL(66, APL)

local function PASSIVE()
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(66, PASSIVE)
