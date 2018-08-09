--- Last Update: Bishop 7/21/18

local addonName, addonTable = ...;
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Party = Unit.Party;
local Spell = HL.Spell;
local Item = HL.Item;

----PALADIN
--Protection
RubimRH.Spell[66] = {
    -- Racials
    ArcaneTorrent = Spell(155145),
    -- Primary rotation abilities
    AvengersShield = Spell(31935),
    AvengersValor = Spell(197561),
    AvengingWrath = Spell(31884),
    Consecration = Spell(26573),
    HammerOfTheRighteous = Spell(53595),
    Judgment = Spell(275779),
    ShieldOfTheRighteous = Spell(53600),
    ShieldOfTheRighteousBuff = Spell(132403),
    GrandCrusader = Spell(85043),
    -- Talents
    BlessedHammer = Spell(204019),
    ConsecratedHammer = Spell(203785),
    CrusadersJudgment = Spell(204023),
    Seraphim = Spell(152262),
    -- Defensive / Utility
    LightOfTheProtector = Spell(184092),
    HandOfTheProtector = Spell(213652),
    LayOnHands = Spell(633),
    GuardianOfAncientKings = Spell(86659),
    ArdentDefender = Spell(31850),
    BlessingOfFreedom = Spell(1044),
    HammerOfJustice = Spell(853),
    BlessingOfProtection = Spell(1022),
    BlessingOfSacrifice = Spell(6940),
    DivineShield = Spell(642),
    -- Utility
    Rebuke = Spell(96231)
}



local S = RubimRH.Spell[66]

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

local IsTanking = false

local function UpdateVars()
	-- Check if we're tanking
	IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target)
	
	-- Update enemies within ability ranges
	HL.GetEnemies("Melee") -- 5 Yards
	HL.GetEnemies(8) -- 40-43 Yards
	HL.GetEnemies(8, true) -- 10-13 Yards
	HL.GetEnemies(10) -- 5-8 Yards
	HL.GetEnemies(30) -- 8-11 Yards
end    

local function APL()
	UpdateVars()

	if not Player:AffectingCombat() then return 0, 462338 end


	-- TODO: Restore these when GGLoader texture updates are complete
	-- Lay on Hands
	-- if S.LayOnHands:IsReady()
	-- 	and Player:HealthPercentage() <= 20 then
	-- 	return S.LayOnHands:Cast()
	-- end

	-- Guardian of Ancient Kings -> Use on Panic Heals, should be proactively cast by user
	-- if S.GuardianOfAncientKings:IsReady()
	-- 	and Player:NeedPanicHealing() then
	-- 	return S.GuardianOfAncientKings:Cast()
	-- end

	-- Shield of the Righteous
	if S.ShieldOfTheRighteous:IsReady()
		and Player:BuffRemains(S.ShieldOfTheRighteousBuff) <= Player:GCD()
		and (S.ShieldOfTheRighteous:ChargesFractional() >= 2 or Player:ActiveMitigationNeeded() or Player:NeedMinorHealing())
		and (Player:Buff(S.AvengersValor) or (not Player:Buff(S.AvengersValor) and S.AvengersShield:CooldownRemains() >= Player:GCD() * 2)) then
		return S.ShieldOfTheRighteous:Cast()
	end

	-- Ardent Defender -> Ardent defender @ Player:NeedPanicHealing() <= 90% HP, should be proactively cast by the user
	-- if S.ArdentDefender:IsReady()
	-- 	and Player:NeedPanicHealing() 
	-- 	and Player:HealthPercentage() <= 90 then
	-- 	return S.ArdentDefender:Cast()
	-- end

	-- Light of the Protector / Hand of the Protector -> Player
	if (S.LightOfTheProtector:IsReady() or S.HandOfTheProtector:IsReady())
		and Player:NeedMinorHealing() then
		if S.HandOfTheProtector:IsAvailable() then
			return S.HandOfTheProtector:Cast()
		else
			return S.LightOfTheProtector:Cast()
		end
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

	-- TODO: Waiting for GGLoader to add spell texture for Blessing of Sacrifice
	--    Blessing Of Sacrifice
	--        local MouseoverUnitNeedsBlessingOfSacrifice = (MouseoverUnitValid and Player:HealthPercentage() <= 80) and true or false
	--        if MouseoverUnitNeedsBlessingOfSacrifice
	--                and S.BlessingOfSacrifice:IsReady(40, false, MouseoverUnit) then
	--            return S.BlessingOfSacrifice:Cast()
	--        end

	-- Blessing of Freedom -> if snared
	if Player:IsSnared()
		and S.BlessingOfFreedom:IsReady() then
		return S.BlessingOfFreedom:Cast()
	end

	--- Offensive CDs

	-- Avenging Wrath
	if RubimRH.CDsON()
		and (Target:TimeToDie() >= 20 or (Player:Health() <= 50 and S.LightOfTheProtector:CooldownRemains() <= Player:GCD() * 2)) -- Use as offensive or big defensive reactive CD
		and S.AvengingWrath:IsReady() then
		return S.AvengingWrath:Cast()
	end

	-- Seraphim
	if RubimRH.CDsON()
		and ((Target:TimeToDie() >= 8 and S.ShieldOfTheRighteous:ChargesFractional() == 1) or (Target:TimeToDie() >= 16 and S.ShieldOfTheRighteous:ChargesFractional() >= 2))
		and S.Seraphim:IsReady() then
		return S.Seraphim:Cast()
	end

	--- Primary Damage Rotation

	-- Avenger's Shield -> High priority with Crusader's Judgment and < 1 Judgment Charge
	if S.AvengersShield:IsReady() 
		and S.CrusadersJudgment:IsAvailable()
		and S.Judgment:ChargesFractional() < 1 then
		return S.AvengersShield:Cast()
	end

	-- Judgment
	if S.Judgment:IsReady() then
		return S.Judgment:Cast()
	end

	-- Consecration
	if S.Consecration:IsReady()
		and not Player:Buff(S.Consecration) then
		return S.Consecration:Cast()
	end

	-- Avenger's Shield -> Lower priority
	if S.AvengersShield:IsReady() then
		return S.AvengersShield:Cast()
	end

	-- Blessed Hammer
	if S.BlessedHammer:IsReady() then
		return S.BlessedHammer:Cast()
	end

	-- Hammer of the Righteous
	if S.HammerOfTheRighteous:IsReady() then
		return S.HammerOfTheRighteous:Cast()
	end

	-- Consecration -> Cast as filler
--	if S.Consecration:IsReady() and Cache.EnemiesCount[8] >= 1 and S.Consecration:TimeSinceLastCast() >= 13 then
	--	return S.Consecration:Cast()
	--end

	return 0, 135328
end

RubimRH.Rotation.SetAPL(66, APL);

local function PASSIVE()
	return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(66, PASSIVE);