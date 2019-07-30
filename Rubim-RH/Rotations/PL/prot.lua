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
    CleanseToxins = Spell(213644),
    Fireblood = Spell(265221),
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
    PotionofUnbridledFury            = Item(169299),
    AzsharasFontofPower              = Item(169314),
    GrongsPrimalRage                 = Item(165574),
    MerekthasFang                    = Item(158367),
    RazdunksBigRedButton             = Item(159611)
};
local I = Item.Paladin.Protection;

-- Rotation Var
local ShouldReturn; -- Used to get the return string
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


--- ======= ACTION LISTS =======
local function APL()
    local Precombat, Cooldowns
    UpdateRanges()
    if QueueSkill() ~= nil then
        return QueueSkill()
    end
	DetermineEssenceRanks()
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
    
    Cooldowns = function()
        -- fireblood,if=buff.avenging_wrath.up
        if S.Fireblood:IsReadyP() and (Player:BuffP(S.AvengingWrathBuff)) then
            return S.Fireblood:Cast()
        end
        -- use_item,name=azsharas_font_of_power,if=cooldown.seraphim.remains<=10|!talent.seraphim.enabled
        --if I.AzsharasFontofPower:IsUsable() and (S.Seraphim:CooldownRemainsP() <= 10 or not S.Seraphim:IsAvailable()) then
            --return S.UnleashHeartOfAzeroth:Cast()
        --end
        -- seraphim,if=cooldown.shield_of_the_righteous.charges_fractional>=2
        if S.Seraphim:IsReadyP() and (S.ShieldoftheRighteous:ChargesFractionalP() >= 2) then
            return S.Seraphim:Cast()
        end
        -- avenging_wrath,if=buff.seraphim.up|cooldown.seraphim.remains<2|!talent.seraphim.enabled
        if S.AvengingWrath:IsReadyP('Melee') and (Player:Buff(S.SeraphimBuff) or S.Seraphim:CooldownRemains() < 2 or not S.Seraphim:IsAvailable()) then
            return S.AvengingWrath:Cast()
        end
        -- bastion_of_light,if=cooldown.shield_of_the_righteous.charges_fractional<=0.5
        if S.BastionOfLight:IsReadyP() and S.ShieldoftheRighteous:ChargesFractional() <= 0.5 then
            return S.BastionOfLight:Cast()
        end
        -- potion,if=buff.avenging_wrath.up
        --if I.PotionofUnbridledFury:IsReady() and (Player:BuffP(S.AvengingWrathBuff)) then
            --return 967532
        --end
        -- use_item,name=grongs_primal_rage,if=((cooldown.judgment.full_recharge_time>4|(!talent.crusaders_judgment.enabled&prev_gcd.1.judgment))&cooldown.avengers_shield.remains>4&buff.seraphim.remains>4)|(buff.seraphim.remains<4)
        --if I.GrongsPrimalRage:IsUsable() and (((S.Judgment:FullRechargeTimeP() > 4 or (not S.CrusadersJudgment:IsAvailable() and Player:PrevGCDP(1, S.Judgment))) and S.AvengersShield:CooldownRemainsP() > 4 and Player:BuffRemainsP(S.SeraphimBuff) > 4) or (Player:BuffRemainsP(S.SeraphimBuff) < 4)) then
            --return 1030902
        --end
        -- use_item,name=merekthas_fang,if=!buff.avenging_wrath.up&(buff.seraphim.up|!talent.seraphim.enabled)
        --if I.MerekthasFang:IsUsable() and (not Player:BuffP(S.AvengingWrathBuff) and (Player:BuffP(S.SeraphimBuff) or not S.Seraphim:IsAvailable())) then
            --return 1030902
        --end
        -- use_item,name=razdunks_big_red_button
        --if I.RazdunksBigRedButton:IsUsable() then
            --return 1030902
        --end
        -- blood_of_the_enemy
        if S.BloodOfTheEnemy:IsReadyP('Melee') then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- concentrated_flame
        if S.ConcentratedFlame:IsReadyP('Melee') then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- guardian_of_azeroth
        if S.GuardianOfAzeroth:IsReadyP('Melee') then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- focused_azerite_beam
        if S.FocusedAzeriteBeam:IsReadyP('Melee') then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- purifying_blast
        if S.PurifyingBlast:IsReadyP('Melee') then
            return S.UnleashHeartOfAzeroth:Cast('Melee')
        end
        -- the_unbound_force
        if S.TheUnboundForce:IsReadyP('Melee') then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- ripple_in_space
        if S.RippleInSpace:IsReadyP('Melee') then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- worldvein_resonance
        if S.WorldveinResonance:IsReadyP('Melee') then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- memory_of_lucid_dreams,if=fury<40&buff.metamorphosis.up
        if S.MemoryOfLucidDreams:IsReadyP('Melee') then
            return S.UnleashHeartOfAzeroth:Cast()
        end
    end

    -- avengers_shield,if=cooldown_react
    if S.AvengersShield:IsReadyP(30) and (S.AvengersShield:CooldownUpP()) then
      return S.AvengersShield:Cast()
    end
   -- if S.AvengersShield:IsReadyP(30) and Target:IsInterruptible() and RubimRH.ASInterruptON() then
   --     return S.AvengersShield:Cast()
   -- end
    if S.Rebuke:IsReadyP('Melee') and RubimRH.db.profile.mainOption.useInterrupts and Target:IsInterruptible() then
        return S.Rebuke:Cast()
    end

    if (S.LightofTheProtector:IsReadyP() or S.HandOfTheProtector:IsReady()) and Player:HealthPercentage() <= RubimRH.db.profile[66].sk1 and not Player:HealingAbsorbed() then
        return S.LightofTheProtector:Cast()
    end

    if S.ShieldoftheRighteous:IsReadyP('Melee') and not Player:BuffP(S.ShieldoftheRighteousBuff) and not Player:BuffP(S.AvengingWrathBuff) and Player:HealthPercentage() < 75 and RubimRH.ASInterruptON() then
        return S.ShieldoftheRighteous:Cast()
    end
    -- Mouseover Functionality
    local MouseoverUnit = (UnitExists("mouseover") and UnitIsFriend("player", "mouseover") and (UnitGUID("mouseover") ~= UnitGUID("player"))) and Unit("mouseover") or nil
    if MouseoverUnit then
        -- Hand of the Protector -> Mouseover
        if S.HandOfTheProtector:IsReadyP()
                and MouseoverUnit:NeedMajorHealing() then
            return S.HandOfTheProtector:Cast()
        end

        -- Blessing of Protection -> Mousover
        if S.BlessingOfProtection:IsReadyP()
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
            and S.BlessingOfFreedom:IsReadyP() then
        return S.BlessingOfFreedom:Cast()
    end

    -- TODO: Restore these when GGLoader texture updates are complete
    -- Lay on Hands
    if S.LayOnHands:IsReadyP() and Player:HealthPercentage() <= RubimRH.db.profile[66].sk4 and not Player:Debuff(S.Forbearance) and not Player:Buff(S.ArdentDefender) and not Player:Buff(S.GuardianOfAncientKings) then
        return S.LayOnHands:Cast()
    end

    -- Guardian of Ancient Kings -> Use on Panic Heals, should be proactively cast by user
    if S.GuardianOfAncientKings:IsReadyP() and Player:HealthPercentage() < RubimRH.db.profile[66].sk3 and not Player:Buff(S.ArdentDefender) then
        return S.GuardianOfAncientKings:Cast()
    end

    -- Ardent Defender -> Ardent defender @ Player:NeedPanicHealing() <= 90% HP, should be proactively cast by the
    if S.ArdentDefender:IsReadyP() and Player:HealthPercentage() <= RubimRH.db.profile[66].sk2 and not Player:Buff(S.GuardianOfAncientKings) then
        return S.ArdentDefender:Cast()
    end

    if S.CleanseToxins:IsReady() and Player:HasDispelableDebuff( "Poison", "Disease") then
        return S.CleanseToxins:Cast()
    end    
    --actions+=/call_action_list,name=cooldowns
    if Cooldowns() ~= nil and RubimRH.CDsON() then
        return Cooldowns()
    end

    -- shield_of_the_righteous,if=(buff.avengers_valor.up&cooldown.shield_of_the_righteous.charges_fractional>=2.5)&(cooldown.seraphim.remains>gcd|!talent.seraphim.enabled)
    if S.ShieldoftheRighteous:IsReadyP('Melee') and ((Player:Buff(S.AvengersValorBuff) and S.ShieldoftheRighteous:ChargesFractional() >= 2.5) and (S.Seraphim:CooldownRemains() > Player:GCD() or not S.Seraphim:IsAvailable())) then
        return S.ShieldoftheRighteous:Cast()
    end
    
    -- shield_of_the_righteous,if=(buff.avenging_wrath.up&!talent.seraphim.enabled)|buff.seraphim.up&buff.avengers_valor.up
    if S.ShieldoftheRighteous:IsReadyP('Melee') and ((Player:Buff(S.AvengingWrathBuff) and not S.Seraphim:IsAvailable()) or Player:Buff(S.SeraphimBuff) and Player:Buff(S.AvengersValorBuff)) then
        return S.ShieldoftheRighteous:Cast()
    end
    -- shield_of_the_righteous,if=(buff.avenging_wrath.up&buff.avenging_wrath.remains<4&!talent.seraphim.enabled)|(buff.seraphim.remains<4&buff.seraphim.up)
    if S.ShieldoftheRighteous:IsReadyP('Melee') and ((Player:Buff(S.AvengingWrathBuff) and Player:BuffRemains(S.AvengingWrathBuff) < 4 and not S.Seraphim:IsAvailable()) or (Player:BuffRemains(S.SeraphimBuff) < 4 and Player:Buff(S.SeraphimBuff))) then
        return S.ShieldoftheRighteous:Cast()
    end
    -- lights_judgment,if=buff.seraphim.up&buff.seraphim.remains<3
    if S.LightsJudgment:IsReadyP(30) and RubimRH.CDsON() and (Player:Buff(S.SeraphimBuff) and Player:BuffPRemains(S.SeraphimBuff) < 3) then
        return S.LightsJudgment:Cast()
    end

    -- consecration,if=!consecration.up
    if S.Consecration:IsReadyP() and not Player:BuffP(S.ConsecrationBuff)   then
        return S.Consecration:Cast()
    end

    -- judgment,if=(cooldown.judgment.remains<gcd&cooldown.judgment.charges_fractional>1&cooldown_react)|!talent.crusaders_judgment.enabled
    if S.Judgment:IsReadyP(30) and Target:AffectingCombat() and ((S.Judgment:CooldownRemains() < Player:GCD() and S.Judgment:ChargesFractional() > 1 and S.Judgment:CooldownUpP()) or not S.CrusadersJudgment:IsAvailable()) then
        return S.Judgment:Cast()
    end

    -- judgment,if=cooldown_react|!talent.crusaders_judgment.enabled
    if S.Judgment:IsReadyP(30) and Target:AffectingCombat() and (S.Judgment:CooldownUpP() or not S.CrusadersJudgment:IsAvailable()) then
        return S.Judgment:Cast()
    end

    -- lights_judgment,if=!talent.seraphim.enabled|buff.seraphim.up
    if S.LightsJudgment:IsReadyP() and RubimRH.CDsON() and (S.Seraphim:IsAvailable() or Player:Buff(S.SeraphimBuff)) then
        return S.LightsJudgment:Cast()
    end
    -- blessed_hammer,strikes=3judgment,if=(cooldown.judgment.remains<gcd&cooldown.judgment.charges_fractional>1&cooldown_react)|!talent.crusaders_judgment.enabled
    -- blessed_hammer,strikes=3
    if S.BlessedHammer:IsReadyP('Melee') then
        return S.BlessedHammer:Cast()
    end
    -- hammer_of_the_righteous
    if S.HammeroftheRighteous:IsReadyP('Melee') then
        return S.HammeroftheRighteous:Cast()
    end

    -- consecration
    if S.Consecration:IsReadyP()  then
        return S.Consecration:Cast()
    end

    return 0, 135328
end

RubimRH.Rotation.SetAPL(66, APL)

local function PASSIVE()
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(66, PASSIVE)
