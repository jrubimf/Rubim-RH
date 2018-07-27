	--- Last Update: Bishop 7/21/18

	local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")

	local addonName, addonTable = ...;
	local HL = HeroLib;
	local Cache = HeroCache;
	local Unit = HL.Unit;
	local Player = Unit.Player;
	local Target = Unit.Target;
	local Party = Unit.Party;
	local Spell = HL.Spell;
	local Item = HL.Item;

	local ISpell = RubimRH.Spell[66]

	local T202PC, T204PC = HL.HasTier("T20");
	local T212PC, T214PC = HL.HasTier("T21");

	local function APL()

	--- Unit update
	HL.GetEnemies(30, true);

	if not Player:AffectingCombat() then
		return 0, 462338
	end

	--- Determine if we're tanking
	local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);
	LeftCtrl = IsLeftControlKeyDown();
	LeftShift = IsLeftShiftKeyDown();

	--- Kick
	if ISpell.Rebuke:IsReady("Melee")
		and Target:IsInterruptible()
		and ((Target:IsCasting() and Target:CastRemains() <= 0.7) or Target:IsChanneling()) then
		return ISpell.Rebuke:Cast()
	end

	--- Defensives / Healing
	local IncomingDamage = select(1, RubimRH.getDMG("player"))
	local NeedMinorHealing = (IncomingDamage >= (Player:MaxHealth() * 0.01)) and true or false -- Taking 5% max HP in DPS or <= 50% HP
	local NeedBigHealing = ((IncomingDamage >= (Player:MaxHealth() * 0.03)) or Player:HealthPercentage() <= 50) and true or false -- Taking 10% max HP in DPS
	local PanicHeals = (Player:HealthPercentage() <= 40) and true or false

	-- Lay on Hands
	-- if ISpell.LayOnHands:IsReady()
	-- 	and Player:HealthPercentage() <= 20 then
	-- 	return ISpell.LayOnHands:Cast()
	-- end

	-- Guardian of Ancient Kings -> Use on Panic Heals, should be proactively cast by user
	-- if ISpell.GuardianOfAncientKings:IsReady()
	-- 	and PanicHeals 
	-- 	and NeedBigHealing then
	-- 	return ISpell.GuardianOfAncientKings:Cast()
	-- end

	-- Shield of the Righteous
	if (not Player:Buff(ISpell.ShieldOfTheRighteousBuff) or (Player:Buff(ISpell.ShieldOfTheRighteousBuff) and Player:BuffRemains(ISpell.ShieldOfTheRighteousBuff) <= Player:GCD()))
		and ISpell.ShieldOfTheRighteous:IsReady("Melee")
		and (ISpell.ShieldOfTheRighteous:ChargesFractional() >= 2 or Player:ActiveMitigationNeeded())
		and (Player:Buff(ISpell.AvengersValor) or (not Player:Buff(ISpell.AvengersValor) and ISpell.AvengersShield:CooldownRemains() >= Player:GCD() * 2)) then
		return ISpell.ShieldOfTheRighteous:Cast()
	end

	-- Ardent Defender -> Ardent defender @ NeedMinorHealing <= 90% HP, should be proactively cast by the user
	-- if ISpell.ArdentDefender:IsReady()
	-- 	and NeedMinorHealing 
	-- 	and Player:HealthPercentage() <= 90 then
	-- 	return ISpell.ArdentDefender:Cast()
	-- end

	-- Light of the Protector / Hand of the Protector -> Player
	local VersatilityHealIncrease = (GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100
	local SpellPower = GetSpellBonusDamage(2) -- Same result for all schools
	local LotPHeal = (SpellPower * 2.8) + ((SpellPower * 2.8) * VersatilityHealIncrease)
	LotPHeal = (LotPHeal * ((100 - Player:HealthPercentage()) / 100)) + LotPHeal
	local ShouldLotP = (((NeedMinorHealing or NeedBigHealing) and Player:HealthPercentage() <= 80) or Player:HealthPercentage() <= 75) and true or false
	if (ISpell.LightOfTheProtector:IsReady() or ISpell.HandOfTheProtector:IsReady())
		and ShouldLotP then
		if ISpell.HandOfTheProtector:IsAvailable() then
			return ISpell.HandOfTheProtector:Cast()
		else
			return ISpell.LightOfTheProtector:Cast()
		end
	end

	-- Hand of the Protector -> Mouseover
	local MouseoverUnitValid = (Unit("mouseover"):Exists() and UnitIsFriend("player", "mouseover") and (Unit("mouseover") ~= Unit("player"))) and true or false
	local MouseoverUnit = (MouseoverUnitValid) and Unit("mouseover") or nil
	local MouseoverUnitNeedsHelp = (MouseoverUnitValid and (LotPHeal <= (MouseoverUnit:MaxHealth() - MouseoverUnit:Health()))) and true or false
	if ISpell.HandOfTheProtector:IsReady()
		and (MouseoverUnitNeedsHelp or ShouldLotP) then
		return ISpell.HandOfTheProtector:Cast()
	end

	-- Blessing of Protection -> Mousover
	local MouseoverUnitNeedsBoP = (MouseoverUnitValid and (MouseoverUnit:HealthPercentage() <= 40)) and true or false
	if ISpell.BlessingOfProtection:IsReady(40, false, MouseoverUnit)
		and MouseoverUnitNeedsBoP then
		return ISpell.BlessingOfProtection:Cast()
	end

	-- TODO: Waiting for GGLoader to add spell texture for Blessing of Sacrifice
	--    Blessing Of Sacrifice
	--        local MouseoverUnitNeedsBlessingOfSacrifice = (MouseoverUnitValid and Player:HealthPercentage() <= 80) and true or false
	--        if MouseoverUnitNeedsBlessingOfSacrifice
	--                and ISpell.BlessingOfSacrifice:IsReady(40, false, MouseoverUnit) then
	--            return ISpell.BlessingOfSacrifice:Cast()
	--        end

	local MovementSpeed = select(1, GetUnitSpeed("player"))
	if MovementSpeed < 7 -- Standard base run speed is 7 yards per second
		and MovementSpeed ~= 0 -- 0 move speed = not moving
		and ISpell.BlessingOfFreedom:IsReady() then
		return ISpell.BlessingOfFreedom:Cast()
	end

	if Target:Exists()
		and ISpell.HammerOfJustice:IsReady(10)
		and LeftCtrl
		and LeftShift then
		return ISpell.HammerOfJustice:Cast()
	end

	--- Offensive CDs
	--print(Target:TimeToDie())
	if RubimRH.CDsON()
		and (Target:TimeToDie() >= 20 or (Player:Health() <= 50 and ISpell.LightOfTheProtector:CooldownRemains() <= Player:GCD() * 2)) -- Use as offensive or big defensive reactive CD
		and ISpell.AvengingWrath:IsReady() then
		return ISpell.AvengingWrath:Cast()
	end

	--- Main damage rotation: all executed as soon as they're available

	-- Avenger's Shield -> High priority with Crusader's Judgment and < 1 Judgment Charge
	if ISpell.AvengersShield:IsReady(30) 
		and ISpell.CrusadersJudgment:IsAvailable()
		and ISpell.Judgment:ChargesFractional() < 1 then
		return ISpell.AvengersShield:Cast()
	end

	if ISpell.Judgment:IsReady(30) then
		return ISpell.Judgment:Cast()
	end

	-- 
	if not Player:Buff(ISpell.Consecration)
		and (Target:Exists() and Target:IsInRange("Melee"))
		and ISpell.Consecration:IsReady() then
		return ISpell.Consecration:Cast()
	end

	-- Avenger's Shield -> Lower priority
	if ISpell.AvengersShield:IsReady(30) then
		return ISpell.AvengersShield:Cast()
	end

	if ISpell.BlessedHammer:IsReady()
		and Target:Exists()
		and Target:IsInRange("Melee") then
		return ISpell.BlessedHammer:Cast()
	end

	if ISpell.HammerOfTheRighteous:IsReady("Melee") then
		return ISpell.HammerOfTheRighteous:Cast()
	end

	if ISpell.Consecration:IsReady()
		and (Target:Exists() and Target:IsInRange("Melee")) then
		return ISpell.Consecration:Cast()
	end

		return 0, 975743
	end

	RubimRH.Rotation.SetAPL(66, APL);

	local function PASSIVE()
		return RubimRH.Shared()
	end

	RubimRH.Rotation.SetPASSIVE(66, PASSIVE);