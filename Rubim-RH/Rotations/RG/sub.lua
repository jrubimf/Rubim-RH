local addonName, addonTable = ...;
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
-- Lua
local pairs = pairs;
local tableinsert = table.insert;
local mathmin = math.min;

-- Spells
local S = RubimRH.Spell[261]

local Stealth, VanishBuff

local function CPMaxSpend()
	-- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
	return RubimRH.Spell[261].DeeperStratagem:IsAvailable() and 6 or 5;
end

-- "cp_spend"
local function CPSpend()
	return mathmin(Player:ComboPoints(), CPMaxSpend());
end

local function num(val)
	if val then
		return 1
	else
		return 0
	end
end

local function Stealth_Threshold()
	return 60 + num(S.Vigor:IsAvailable()) * 35 + num(S.MasterofShadows:IsAvailable()) * 10;
end

local function IsInMeleeRange()
	return Target:IsInRange("Melee") and true or false;
end

local function ShD_Threshold ()
	return S.ShadowDance:ChargesFractional() >= 1.75
end

S.Eviscerate:RegisterDamage(
-- Eviscerate DMG Formula (Pre-Mitigation):
--- Player Modifier
-- AP * CP * EviscR1_APCoef * EviscR2_M * Aura_M * NS_M * DS_M * DSh_M * SoD_M * ShC_M * Mastery_M * Versa_M
--- Target Modifier
-- NB_M
		function()
			return
			--- Player Modifier
			-- Attack Power
			Player:AttackPowerDamageMod() *
					-- Combo Points
					CPSpend() *
					-- Eviscerate R1 AP Coef
					0.16074 *
					-- Eviscerate R2 Multiplier
					1.5 *
					-- Aura Multiplier (SpellID: 137035)
					1.33 *
					-- Nightstalker Multiplier
					(S.Nightstalker:IsAvailable() and Player:IsStealthed(true) and 1.12 or 1) *
					-- Deeper Stratagem Multiplier
					(S.DeeperStratagem:IsAvailable() and 1.05 or 1) *
					-- Dark Shadow Multiplier
					(S.DarkShadow:IsAvailable() and Player:BuffP(S.ShadowDanceBuff) and 1.25 or 1) *
					-- Symbols of Death Multiplier
					(Player:BuffP(S.SymbolsofDeath) and 1.15 or 1) *
					-- Shuriken Combo Multiplier
					(Player:BuffP(S.ShurikenComboBuff) and (1 + Player:Buff(S.ShurikenComboBuff, 16) / 100) or 1) *
					-- Mastery Finisher Multiplier
					(1 + Player:MasteryPct() / 100) *
					-- Versatility Damage Multiplier
					(1 + Player:VersatilityDmgPct() / 100) *
					--- Target Modifier
					-- Nightblade Multiplier
					(Target:DebuffP(S.Nightblade) and 1.15 or 1);
		end
);
S.Nightblade:RegisterPMultiplier(
		{ function()
			return S.Nightstalker:IsAvailable() and Player:IsStealthed(true, false) and 1.12 or 1;
		end }
);

-- actions.precombat+=/variable,name=stealth_threshold,value=60+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10
local function Stealth_Threshold ()
	return 60 + num(S.Vigor:IsAvailable()) * 35 + num(S.MasterofShadows:IsAvailable()) * 10;
end
-- actions.stealth_cds=variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=1.75
local function ShD_Threshold ()
	return S.ShadowDance:ChargesFractional() >= 1.75
end

-- # Finishers
local function Finish ()
	local ShadowDanceBuff = Player:BuffP(S.ShadowDanceBuff) or (StealthSpell and StealthSpell:ID() == S.ShadowDance:ID())

	if S.Nightblade:IsCastable() then
		local NightbladeThreshold = (6 + CPSpend() * 2) * 0.3;
		-- actions.finish=nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&remains<tick_time*2&(spell_targets.shuriken_storm<4|!buff.symbols_of_death.up)
		if IsInMeleeRange() and (not S.DarkShadow:IsAvailable() or not ShadowDanceBuff)
				and (Target:FilteredTimeToDie(">", 6, -Target:DebuffRemainsP(S.Nightblade)) or Target:TimeToDieIsNotValid())
				and Target:DebuffRemainsP(S.Nightblade) < 4
				and (Cache.EnemiesCount[10] < 4 or not Player:BuffP(S.SymbolsofDeath)) then
			return S.Nightblade:Cast()
		end
		-- actions.finish+=/nightblade,cycle_targets=1,if=spell_targets.shuriken_storm>=2&!buff.shadow_dance.up&target.time_to_die>=(5+(2*combo_points))&refreshable
		if RubimRH.AoEON() and S.Nightblade:IsReady() and Cache.EnemiesCount[10] >= 2 and not ShadowDanceBuff and Target:FilteredTimeToDie("<=", 5 + (2 * Player:ComboPoints())) and Target:DebuffRefreshableP(S.Nightblade) then
			return S.Nightblade:Cast()
		end
		-- actions.finish+=/nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
		if IsInMeleeRange() and Target:DebuffRemainsP(S.Nightblade) < S.SymbolsofDeath:CooldownRemainsP() + 10
				and S.SymbolsofDeath:CooldownRemainsP() <= 5
				and (Target:FilteredTimeToDie(">", 5 + S.SymbolsofDeath:CooldownRemainsP(), -Target:DebuffRemainsP(S.Nightblade)) or Target:TimeToDieIsNotValid()) then
			return S.Nightblade:Cast()
		end
	end
	-- actions.finish+=/secret_technique,if=buff.symbols_of_death.up&(!talent.dark_shadow.enabled|spell_targets.shuriken_storm<2|buff.shadow_dance.up)
	if S.SecretTechnique:IsCastable() and Player:BuffP(S.SymbolsofDeath) and (not S.DarkShadow:IsAvailable() or Cache.EnemiesCount[10] < 2 or Player:BuffP(S.ShadowDanceBuff)) then
		return S.SecretTechnique:Cast()
	end
	-- actions.finish+=/secret_technique,if=spell_targets.shuriken_storm>=2+talent.dark_shadow.enabled+talent.nightstalker.enabled
	if S.SecretTechnique:IsCastable() and Cache.EnemiesCount[10] >= 2 + num(S.DarkShadow:IsAvailable()) + num(S.Nightstalker:IsAvailable()) then
		return S.SecretTechnique:Cast()
	end
	-- actions.finish+=/eviscerate
	if S.Eviscerate:IsCastable() and IsInMeleeRange() then
		return S.Eviscerate:Cast()
	end
end

-- # Stealthed Rotation
-- ReturnSpellOnly and StealthSpell parameters are to Predict Finisher in case of Stealth Macros
local function Stealthed ()
	local StealthBuff = Player:Buff(Stealth) or (StealthSpell and StealthSpell:ID() == Stealth:ID())
	-- # If stealth is up, we really want to use Shadowstrike to benefits from the passive bonus, even if we are at max cp (from the precombat MfD).
	-- actions.stealthed=shadowstrike,if=buff.stealth.up
	if StealthBuff and S.Shadowstrike:IsCastable() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
		return S.Shadowstrike:Cast()
	end
	-- actions.stealthed+=/call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
	if Player:ComboPointsDeficit() <= 1 - num(S.DeeperStratagem:IsAvailable() and Player:BuffP(VanishBuff)) then
		return Finish(ReturnSpellOnly, StealthSpell);
	end
	-- actions.stealthed+=/shadowstrike,cycle_targets=1,if=talent.secret_technique.enabled&talent.find_weakness.enabled&debuff.find_weakness.remains<1&spell_targets.shuriken_storm=2&target.time_to_die-remains>6
	-- !!!NYI!!! (Is this worth it? How do we want to display it in an understandable way?)
	-- actions.stealthed+=/shuriken_storm,if=spell_targets.shuriken_storm>=3
	if RubimRH.AoEON() and S.ShurikenStorm:IsCastable() and Cache.EnemiesCount[10] >= 3 then
		return S.ShurikenStorm:Cast()
	end
	-- actions.stealthed+=/shadowstrike
	if StealthBuff and S.Shadowstrike:IsCastable() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
		return S.Shadowstrike:Cast()
	end
end

local function CDs ()
	if IsInMeleeRange() then
		if RubimRH.CDsON() then
			-- actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
			-- TODO: Add Potion Suggestion

			-- Racials
			if Player:IsStealthed(true, false) then
				-- actions.cds+=/blood_fury,if=stealthed.rogue
				if S.BloodFury:IsCastable() then
					return S.BloodFury:Cast()
				end
				-- actions.cds+=/berserking,if=stealthed.rogue
				if S.Berserking:IsCastable() then
					return S.Berserking:Cast()
				end
			end
		end

		-- actions.cds+=/symbols_of_death
		if S.SymbolsofDeath:IsCastable() then
			return S.SymbolsofDeath:Cast()
		end
		if RubimRH.CDsON() then
			-- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
			-- Note: Done at the start of the Rotation (Rogue Commmon)
			-- actions.cds+=/marked_for_death,if=raid_event.adds.in>30&!stealthed.all&combo_points.deficit>=cp_max_spend
			if S.MarkedforDeath:IsCastable() then
				if Target:FilteredTimeToDie("<", Player:ComboPointsDeficit()) or (not Player:IsStealthed(true, true) and Player:ComboPointsDeficit() >= CPMaxSpend()) then
					return S.MarkedforDeath:Cast()
				elseif Player:ComboPointsDeficit() >= CPMaxSpend() then
					return S.MarkedforDeath:Cast()
				end
			end
			-- actions.cds+=/shadow_blades,if=combo_points.deficit>=2+stealthed.all
			if S.ShadowBlades:IsCastable() and not Player:Buff(S.ShadowBlades)
					and Player:ComboPointsDeficit() >= 2 + num(Player:IsStealthed(true, true)) then
				S.ShadowBlades:Cast()
			end
			-- actions.cds+=/shuriken_tornado,if=spell_targets>=3&dot.nightblade.ticking&buff.symbols_of_death.up&buff.shadow_dance.up
			if S.ShurikenTornado:IsCastableP() and Cache.EnemiesCount[10] >= 3 and Target:DebuffP(S.Nightblade) and Player:BuffP(S.SymbolsofDeath) and Player:BuffP(S.ShadowDanceBuff) then
				return S.ShurikenTornado:Cast()
			end
			-- actions.cds+=/shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=5+talent.subterfuge.enabled
			if S.ShadowDance:IsCastable() and not Player:BuffP(S.ShadowDanceBuff) and Target:FilteredTimeToDie("<=", 5 + num(S.Subterfuge:IsAvailable())) then
				return S.ShadowDance:Cast()
			end
		end
	end
end

-- # Stealth Cooldowns
local function Stealth_CDs ()
	if IsInMeleeRange() then
		-- actions.stealth_cds+=/vanish,if=!variable.shd_threshold&debuff.find_weakness.remains<1
		if RubimRH.CDsON() and S.Vanish:IsCastable() and S.ShadowDance:TimeSinceLastDisplay() > 0.3 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and not Player:IsTanking(Target)
				and not ShD_Threshold() and Target:DebuffRemainsP(S.FindWeaknessDebuff) < 1 then
			return S.Vanish:Cast()
		end
		-- actions.stealth_cds+=/shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1
		-- actions.stealth_cds+=/shadow_dance,if=(!talent.dark_shadow.enabled|dot.nightblade.remains>=5+talent.subterfuge.enabled)&(variable.shd_threshold|buff.symbols_of_death.remains>=1.2|spell_targets>=4&cooldown.symbols_of_death.remains>10)
		if (RubimRH.CDsON() or (S.ShadowDance:ChargesFractional() >= (S.DarkShadow:IsAvailable() and 0.75 or 0)))
				and S.ShadowDance:IsCastable() and S.Vanish:TimeSinceLastDisplay() > 0.3
				and S.ShadowDance:TimeSinceLastDisplay() ~= 0 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and S.ShadowDance:Charges() >= 1
				and (not S.DarkShadow:IsAvailable() or Target:DebuffRemainsP(S.Nightblade) >= 5 + num(S.Subterfuge:IsAvailable()))
				and (ShD_Threshold() or Player:BuffRemainsP(S.SymbolsofDeath) >= 1.2 or (Cache.EnemiesCount[10] >= 4 and S.SymbolsofDeath:CooldownRemainsP() > 10)) then
			return S.ShadowDance:Cast()
		end
		-- actions.stealth_cds+=/shadow_dance,if=target.time_to_die<cooldown.symbols_of_death.remains
		if (RubimRH.CDsON() or (S.ShadowDance:ChargesFractional() >= (S.DarkShadow:IsAvailable() and 0.75 or 0)))
				and S.ShadowDance:IsCastable() and S.Vanish:TimeSinceLastDisplay() > 0.3
				and S.ShadowDance:TimeSinceLastDisplay() ~= 0 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and S.ShadowDance:Charges() >= 1
				and Target:TimeToDie() < S.SymbolsofDeath:CooldownRemainsP() then
			return S.ShadowDance:Cast()
		end
	end
end

-- # Builders
local function Build ()
	-- actions.build=shuriken_storm,if=spell_targets.shuriken_storm>=2
	if RubimRH.AoEON() and S.ShurikenStorm:IsCastableP() and Cache.EnemiesCount[10] >= 2 then
		return S.ShurikenStorm:Cast()
	end
	-- actions.build=shuriken_toss,if=buff.sharpened_blades.stack>=19
	if S.ShurikenToss:IsCastableP() and (Player:BuffStackP(S.SharpenedBladesBuff) >= 19) then
		return S.ShurikenToss:Cast()
	end
	if IsInMeleeRange() then
		-- actions.build+=/gloomblade
		if S.Gloomblade:IsCastable() then
			return S.Gloomblade:Cast()
			-- actions.build+=/backstab
		elseif S.Backstab:IsCastable() then
			return S.Backstab:Cast()
		end
	end
end

local function APL()
	HL.GetEnemies(10, true); -- Shuriken Storm & Death from Above
	HL.GetEnemies("Melee"); -- Melee

	if S.Subterfuge:IsAvailable() then
		Stealth = S.Stealth2;
		VanishBuff = S.VanishBuff2;
	else
		Stealth = S.Stealth;
		VanishBuff = S.VanishBuff;
	end

	local StealthBuff = Player:Buff(Stealth) or (StealthSpell and StealthSpell:ID() == Stealth:ID())
	if not Player:AffectingCombat() then
		if not StealthBuff then
			return Stealth:Cast()
		end

		if RubimRH.TargetIsValid() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
			if Player:IsStealthed(true, true) and Stealthed() ~= nil then
				return Stealthed()
			end
			if Player:EnergyPredicted() < 30 then
				return 0, 462338
			end
		elseif Player:ComboPoints() >= 5 and Finish() ~= nil then
			return Finish()
		end
		if S.Backstab:IsCastable() then
			return S.Backstab:Cast()
		end
		return 0, 462338
	end

	if RubimRH.TargetIsValid() then

		if CDs() ~= nil then
			return CDs()
		end

		-- # Run fully switches to the Stealthed Rotation (by doing so, it forces pooling if nothing is available).
		-- actions+=/run_action_list,name=stealthed,if=stealthed.all
		if Player:IsStealthed(true, true) and Stealthed() ~= nil then
			return Stealthed()
		end
		-- run_action_list forces the return
		if Player:EnergyPredicted() < 30 then
			return 0, 975743
		end

		-- # Apply Nightblade at 2+ CP during the first 10 seconds, after that 4+ CP if it expires within the next GCD or is not up
		-- actions+=/nightblade,if=target.time_to_die>6&remains<gcd.max&combo_points>=4-(time<10)*2
		if S.Nightblade:IsCastableP() and IsInMeleeRange()
				and (Target:FilteredTimeToDie(">", 6) or Target:TimeToDieIsNotValid())
				and Target:DebuffRemainsP(S.Nightblade) < Player:GCD() and Player:ComboPoints() >= 4 - (HL.CombatTime() < 10 and 2 or 0) then
			S.Nightblade:Cast()
		end

		-- # Consider using a Stealth CD when reaching the energy threshold and having space for at least 4 CP
		-- actions+=/call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold&combo_points.deficit>=4
		if (Player:EnergyDeficit() <= Stealth_Threshold() and Player:ComboPointsDeficit() >= 4) and Stealth_CDs() ~= nil then
			return Stealth_CDs()
		end

		-- # Finish at 4+ without DS, 5+ with DS (outside stealth)
		-- actions+=/call_action_list,name=finish,if=combo_points>=4+talent.deeper_stratagem.enabled|target.time_to_die<=1&combo_points>=3
		if Player:ComboPoints() >= 4 + num(S.DeeperStratagem:IsAvailable())
				or (Target:FilteredTimeToDie("<=", 1) and Player:ComboPoints() >= 3) and Finish() ~= nil then
			return Finish()
		end

		-- # Use a builder when reaching the energy threshold
		-- actions+=/call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold-40*!(talent.alacrity.enabled|talent.shadow_focus.enabled|talent.master_of_shadows.enabled)
		if Player:EnergyDeficitPredicted() <= Stealth_Threshold() - 40 * num(not (S.Alacrity:IsAvailable() or S.ShadowFocus:IsAvailable() or S.MasterofShadows:IsAvailable())) and Build() ~= nil then
			return Build()
		end

		-- # Lowest priority in all of the APL because it causes a GCD
		-- actions+=/arcane_torrent,if=energy.deficit>=15+energy.regen
		if S.ArcaneTorrent:IsCastable() and Player:EnergyDeficitPredicted() > 15 + Player:EnergyRegen() then
			return S.ArcaneTorrent:Cast()
		end
		-- actions+=/arcane_pulse
		if S.ArcanePulse:IsCastableP() and IsInMeleeRange() then
			return S.ArcanePulse:Cast()
		end

		-- Shuriken Toss Out of Range
		if S.ShurikenToss:IsCastable(30) and not Target:IsInRange(10) and not Player:IsStealthed(true, true) and not Player:BuffP(S.Sprint)
				and Player:EnergyDeficitPredicted() < 20 and (Player:ComboPointsDeficit() >= 1 or Player:EnergyTimeToMax() <= 1.2) then
			return S.ShurikenToss:Cast()
		end
		-- Trick to take in consideration the Recovery Setting
		local StealthBuff = Player:Buff(Stealth) or (StealthSpell and StealthSpell:ID() == Stealth:ID())
		if StealthBuff and S.Shadowstrike:IsCastable() and IsInMeleeRange() then
			return S.Shadowstrike:Cast()
		end
	end
	return 0, 975743
end

RubimRH.Rotation.SetAPL(261, APL);

local function PASSIVE()
	return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(261, PASSIVE);
--
-- # Cooldowns
-- actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
-- actions.cds+=/blood_fury,if=stealthed.rogue
-- actions.cds+=/berserking,if=stealthed.rogue
-- actions.cds+=/lights_judgment,if=stealthed.rogue
-- actions.cds+=/symbols_of_death,if=dot.nightblade.ticking
-- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
-- actions.cds+=/marked_for_death,if=raid_event.adds.in>30&!stealthed.all&combo_points.deficit>=cp_max_spend
-- actions.cds+=/shadow_blades,if=combo_points.deficit>=2+stealthed.all
-- actions.cds+=/shuriken_tornado,if=spell_targets>=3&dot.nightblade.ticking&buff.symbols_of_death.up&buff.shadow_dance.up
-- actions.cds+=/shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=5+talent.subterfuge.enabled
--
-- # Stealth Cooldowns
-- # Helper Variable
-- actions.stealth_cds=variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=1.75
-- # Vanish unless we are about to cap on Dance charges. Only when Find Weakness is about to run out.
-- actions.stealth_cds+=/vanish,if=!variable.shd_threshold&debuff.find_weakness.remains<1
-- # Pool for Shadowmeld + Shadowstrike unless we are about to cap on Dance charges. Only when Find Weakness is about to run out.
-- actions.stealth_cds+=/pool_resource,for_next=1,extra_amount=40
-- actions.stealth_cds+=/shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1
-- # With Dark Shadow only Dance when Nightblade will stay up. Use during Symbols or above threshold.
-- actions.stealth_cds+=/shadow_dance,if=(!talent.dark_shadow.enabled|dot.nightblade.remains>=5+talent.subterfuge.enabled)&(variable.shd_threshold|buff.symbols_of_death.remains>=1.2|spell_targets>=4&-- cooldown.symbols_of_death.remains>10)
-- actions.stealth_cds+=/shadow_dance,if=target.time_to_die<cooldown.symbols_of_death.remains
--
-- # Stealthed Rotation
-- # If stealth is up, we really want to use Shadowstrike to benefits from the passive bonus, even if we are at max cp (from the precombat MfD).
-- actions.stealthed=shadowstrike,if=buff.stealth.up
-- # Finish at 4+ CP without DS, 5+ with DS, and 6 with DS after Vanish
-- actions.stealthed+=/call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
-- # At 2 targets with Secret Technique keep up Find Weakness by cycling Shadowstrike.
-- actions.stealthed+=/shadowstrike,cycle_targets=1,if=talent.secret_technique.enabled&talent.find_weakness.enabled&debuff.find_weakness.remains<1&spell_targets.shuriken_storm=2&target.time_to_die-remains>6
-- actions.stealthed+=/shuriken_storm,if=spell_targets.shuriken_storm>=3
-- actions.stealthed+=/shadowstrike
--
-- # Finishers
-- # Keep up Nightblade if it is about to run out. Do not use NB during Dance, if talented into Dark Shadow.
-- actions.finish=nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&remains<tick_time*2&(spell_targets.shuriken_storm<4|!buff.symbols_of_death.up)
-- # Multidotting outside Dance on targets that will live for the duration of Nightblade with refresh during pandemic.
-- actions.finish+=/nightblade,cycle_targets=1,if=spell_targets.shuriken_storm>=2&!buff.shadow_dance.up&target.time_to_die>=(5+(2*combo_points))&refreshable
-- # Refresh Nightblade early if it will expire during Symbols. Do that refresh if SoD gets ready in the next 5s.
-- actions.finish+=/nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
-- # Secret Technique during Symbols. With Dark Shadow and multiple targets also only during Shadow Dance (until threshold in next line).
-- actions.finish+=/secret_technique,if=buff.symbols_of_death.up&(!talent.dark_shadow.enabled|spell_targets.shuriken_storm<2|buff.shadow_dance.up)
-- # With enough targets always use SecTec on CD.
-- actions.finish+=/secret_technique,if=spell_targets.shuriken_storm>=2+talent.dark_shadow.enabled+talent.nightstalker.enabled
-- actions.finish+=/eviscerate
--
-- # Builders
-- actions.build=shuriken_storm,if=spell_targets.shuriken_storm>=2
-- #actions.build+=/shuriken_toss,if=buff.sharpened_blades.stack>=39
-- actions.build+=/gloomblade
-- actions.build+=/backstab