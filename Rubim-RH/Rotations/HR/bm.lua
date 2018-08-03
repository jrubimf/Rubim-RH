--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Pet = Unit.Pet;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
-- Spells

local S = RubimRH.Spell[253]

-- Items
if not Item.Hunter then Item.Hunter = {}; end
Item.Hunter.BeastMastery = {
	-- Legendaries
	CalloftheWild                 = Item(137101, {9}),
	TheMantleofCommand            = Item(144326, {3}),
	ParselsTongue                 = Item(151805, {5}),
	QaplaEredunWarOrder           = Item(137227, {8}),
	SephuzSecret                  = Item(132452, {11,12}),
	-- Trinkets
	ConvergenceofFates            = Item(140806, {13, 14}),
	-- Potions
	PotionOfProlongedPower        = Item(142117),
};
local I = Item.Hunter.BeastMastery;

--- APL Main
local function APL ()
	-- Unit Update
	HL.GetEnemies(40);
	-- Defensives
	-- Exhilaration
	--if S.Exhilaration:IsCastable() and Player:HealthPercentage() <= HPCONFIG then
--        return S.Exhilaration:Cast()
--    end
	-- Out of Combat
	if not Player:AffectingCombat() then
		-- Flask
		-- Food
		-- Rune
		-- PrePot w/ Bossmod Countdown
		-- Opener
		if RubimRH.TargetIsValid() and Target:IsInRange(40) then
			if RubimRH.CDsON() then
				if S.AMurderofCrows:IsCastable() then
					return S.AMurderofCrows:Cast()
				end
			end
			if RubimRH.CDsON() and S.BestialWrath:IsCastable() and not Player:Buff(S.BestialWrath) then
				return S.BestialWrath:Cast()
			end
			-- if S.BardedShot:IsCastable() then

			-- end
			if S.KillCommand:IsCastable() then
				return S.KillCommand:Cast()
			end
			if S.CobraShot:IsCastable() then
				return S.CobraShot:Cast()
			end
		end
		return 0, 462338
	end
	-- In Combat
	if RubimRH.TargetIsValid() then

		-- Counter Shot -> User request
		if S.CounterShot:IsReady(40)
			and ((Target:IsCasting()
			and Target:IsInterruptible()
			and Target:CastRemains() <= 0.7)
			or Target:IsChanneling()) then
			return S.CounterShot:Cast()
		end

		-- actions+=/counter_shot,if=target.debuff.casting.react // Sephuz Specific
		if RubimRH.CDsON() then
			-- actions+=/arcane_torrent,if=focus.deficit>=30
			--if S.ArcaneTorrent:IsCastable() and Player:FocusDeficit() >= 30 then

			--end
			-- actions+=/berserking,if=cooldown.bestial_wrath.remains>30
			if S.Berserking:IsCastable() and S.BestialWrath:CooldownRemains() > 30 then
				return S.Berserking:Cast()
			end
			-- actions+=/blood_fury,if=buff.bestial_wrath.remains>7
			if S.BloodFury:IsCastable() and S.BestialWrath:CooldownRemains() > 30 then
				return S.BloodFury:Cast()
			end
			-- actions+=/ancestral_call,if=cooldown.bestial_wrath.remains>30
			if S.AncestralCall:IsCastable() and S.BestialWrath:CooldownRemains() > 30 then
				return S.AncestralCall:Cast()
			end
			-- actions+=/fireblood,if=cooldown.bestial_wrath.remains>30
			if S.Fireblood:IsCastable() and S.BestialWrath:CooldownRemains() > 30 then
				return S.Fireblood:Cast()
			end
			-- actions+=/lights_judgment
			if S.LightsJudgment:IsCastable() then
				return S.LightsJudgment:Cast()
			end
		end
		-- actions+=/potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
		-- actions+=/barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
		if S.BardedShot:IsCastable() and Pet:BuffRemains(S.Frenzy) and (Pet:BuffRemains(S.Frenzy) < Player:GCD() * 1.5) then
			return S.BardedShot:Cast()
		end
		-- actions+=/a_murder_of_crows
		if RubimRH.CDsON() and Target:IsInRange(40) and S.AMurderofCrows:IsCastable() then
			return S.AMurderofCrows:Cast()
		end
		-- actions+=/spitting_cobra
		if RubimRH.CDsON() and Target:IsInRange(40) and S.SpittingCobra:IsCastable() then
			return S.SpittingCobra:Cast()
		end
		-- actions+=/stampede,if=buff.bestial_wrath.up|cooldown.bestial_wrath.remains<gcd|target.time_to_die<15
		if RubimRH.CDsON() and S.Stampede:IsCastable() and (Player:Buff(S.BestialWrath) or ((S.BestialWrath:CooldownRemains() <= 2 or not AR.CDsON()) or (Target:TimeToDie() <= 15))) then
			return S.Stampede:Cast()
		end
		-- actions+=/aspect_of_the_wild
		if RubimRH.CDsON() and S.AspectoftheWild:IsCastable() then
			return S.AspectoftheWild:Cast()
		end
		-- actions+=/bestial_wrath,if=!buff.bestial_wrath.up
		if RubimRH.CDsON() and S.BestialWrath:IsCastable() and not Player:Buff(S.BestialWrath) then
			return S.BestialWrath:Cast()
		end
		-- actions+=/multishot,if=spell_targets>2&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
		if RubimRH.AoEON() and S.MultiShot:IsCastable() and Cache.EnemiesCount[40] > 2 and (Pet:BuffRemains(S.BeastCleaveBuff) < Player:GCD() or not Pet:Buff(S.BeastCleaveBuff)) then
			return S.MultiShot:Cast()
		end
		-- actions+=/chimaera_shot
		if S.ChimaeraShot:IsCastable() then
			return S.ChimaeraShot:Cast()
		end
		-- actions+=/kill_command
		if S.KillCommand:IsCastable() then
			return S.KillCommand:Cast()
		end
		-- actions+=/dire_beast
		if S.DireBeast:IsCastable() then
			return S.DireBeast:Cast()
		end
		-- actions+=/barbed_shot,if=pet.cat.buff.frenzy.down&charges_fractional>1.4|full_recharge_time<gcd.max|target.time_to_die<9
		if S.BardedShot:IsCastable() and (not Pet:Buff(S.Frenzy) and S.BardedShot:ChargesFractional() > 1.4 or S.BardedShot:FullRechargeTime() < Player:GCD() or Target:TimeToDie() < 9) then
			return S.BardedShot:Cast()
		end
		-- actions+=/barrage
		if RubimRH.AoEON() and S.Barrage:IsCastable() then
			return S.Barrage:Cast()
		end
		-- actions+=/multishot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
		if RubimRH.AoEON() and S.MultiShot:IsCastable() and Cache.EnemiesCount[40] > 1 and (Pet:BuffRemains(S.BeastCleaveBuff) < Player:GCD() or not Pet:Buff(S.BeastCleaveBuff)) then
			return S.MultiShot:Cast()
		end
		-- actions+=/cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(buff.bestial_wrath.up&active_enemies>1|cooldown.kill_command.remains>1+gcd&cooldown.bestial_wrath.remains>focus.time_to_max|focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost)
		if S.CobraShot:IsCastable() and Target:IsInRange(40) and ((Cache.EnemiesCount[40] < 2 or S.KillCommand:CooldownRemains() > Player:FocusTimeToMax()) and (Player:Buff(S.BestialWrath) and Cache.EnemiesCount[40] > 1 or S.KillCommand:CooldownRemains() > 1 + Player:GCD() and S.BestialWrath:CooldownRemains() > Player:FocusTimeToMax() or S.CobraShot:Cost() + Player:FocusRegen() * (S.KillCommand:CooldownRemains() - 1) > S.KillCommand:Cost())) then
			return S.CobraShot:Cast()
		end
	end
	return 0, 135328
end

RubimRH.Rotation.SetAPL(253, APL);

local function PASSIVE()
	return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(253, PASSIVE);
--- Last Update: 07/17/2018

-- # Executed before combat begins. Accepts non-harmful actions only.
-- actions.precombat=flask
-- actions.precombat+=/augmentation
-- actions.precombat+=/food
-- actions.precombat+=/summon_pet
-- # Snapshot raid buffed stats before combat begins and pre-potting is done.
-- actions.precombat+=/snapshot_stats
-- actions.precombat+=/potion
-- actions.precombat+=/aspect_of_the_wild

-- # Executed every time the actor is available.
-- actions=auto_shot
-- actions+=/counter_shot,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
-- actions+=/use_items
-- actions+=/berserking,if=cooldown.bestial_wrath.remains>30
-- actions+=/blood_fury,if=cooldown.bestial_wrath.remains>30
-- actions+=/ancestral_call,if=cooldown.bestial_wrath.remains>30
-- actions+=/fireblood,if=cooldown.bestial_wrath.remains>30
-- actions+=/lights_judgment
-- actions+=/potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
-- actions+=/barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
-- actions+=/a_murder_of_crows
-- actions+=/spitting_cobra
-- actions+=/stampede,if=buff.bestial_wrath.up|cooldown.bestial_wrath.remains<gcd|target.time_to_die<15
-- actions+=/aspect_of_the_wild
-- actions+=/bestial_wrath,if=!buff.bestial_wrath.up
-- actions+=/multishot,if=spell_targets>2&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
-- actions+=/chimaera_shot
-- actions+=/kill_command
-- actions+=/dire_beast
-- actions+=/barbed_shot,if=pet.cat.buff.frenzy.down&charges_fractional>1.4|full_recharge_time<gcd.max|target.time_to_die<9
-- actions+=/barrage
-- actions+=/multishot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
-- actions+=/cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(buff.bestial_wrath.up&active_enemies>1|cooldown.kill_command.remains>1+gcd&cooldown.bestial_wrath.remains>focus.time_to_max|focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost)
