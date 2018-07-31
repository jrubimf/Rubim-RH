--- ============================ HEADER ============================
local addonName, addonTable = ...;
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

local activeUnitPlates = {}



-- Items
if not Item.DeathKnight then
	Item.DeathKnight = {};
end
Item.DeathKnight.Frost = {
	-- Legendaries
	ConvergenceofFates = Item(140806, { 13, 14 }),
	ColdHeart = Item(151796, { 5 }),
	ConsortsColdCore = Item(144293, { 8 }),
	KiljaedensBurningWish = Item(144259, { 13, 14 }),
	KoltirasNewfoundWill = Item(132366, { 6 }),
	PerseveranceOfTheEbonMartyre = Item(132459, { 1 }),
	SealOfNecrofantasia = Item(137223, { 11, 12 }),
	ToravonsWhiteoutBindings = Item(132458, { 9 }),
	--Trinkets
	FelOiledInfernalMachine = Item(144482, { 13, 14 }),
	--Potion
	ProlongedPower = Item(142117)

}

local S = RubimRH.Spell[251]
local I = Item.DeathKnight.Frost;

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

local function standard()
    -- howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.HowlingBlast:IsReady(30, true) and (not Target:DebuffP(S.FrostFever) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
    	return S.HowlingBlast:Cast()
    end
    -- glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.GlacialAdvance:IsReady() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and Cache.EnemiesCount[30] >= 2 and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
    	return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.FrostStrike:IsReady(13) and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
    	return S.FrostStrike:Cast()
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsReady() then
    	return S.RemorselessWinter:Cast()
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if S.FrostStrike:IsReady(13) and (S.RemorselessWinter:CooldownRemainsP() <= (2 * Player:GCD()) and S.GatheringStorm:IsAvailable()) then
    	return S.FrostStrike:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsReady(30, true) and (Player:Buff(S.Rime)) then
    	return S.HowlingBlast:Cast()
    end
    -- obliterate,if=!buff.frozen_pulse.up&talent.frozen_pulse.enabled
    if S.Obliterate:IsReady("Melee") and Player:Runes() > 3 and S.FrozenPulse:IsAvailable() then
    	return S.Obliterate:Cast()
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if S.FrostStrike:IsReady(13) and (Player:RunicPowerDeficit() < (15 + (S.RunicAttenuation:IsAvailable() and 1 or 0) * 3)) then
    	return S.FrostStrike:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up&rune.time_to_4>=gcd
    if S.FrostScythe:IsReady() and Cache.EnemiesCount[8] >= 1 and (Player:BuffP(S.KillingMachine) and Player:RuneTimeToX(4) >= Player:GCD()) then
    	return S.FrostScythe:Cast()
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsReady("Melee") and (Player:RunicPowerDeficit() > (25 + (S.RunicAttenuation:IsAvailable() and 1 or 0) * 3)) then
    	return S.Obliterate:Cast()
    end
    -- frost_strike
    if S.FrostStrike:IsReady(13) then
    	return S.FrostStrike:Cast()
    end
    -- horn_of_winter
    if S.HornOfWinter:IsReady() then
    	return S.HornOfWinter:Cast()
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() then
    	return S.ArcaneTorrent:Cast()
    end
end

local function cold_heart()
	--[[COLD HEART LEGENDARY APL]] --
	-- actions.cold_heart=chains_of_ice,if=(buff.cold_heart_item.stack>5|buff.cold_heart_talent.stack>5)&target.time_to_die<gcd
	if S.ChainsOfIce:IsReady(30) and (Player:BuffStack(S.ColdHeartItemBuff) > 5 or Player:BuffStack(S.ColdHeartBuff) > 5) and Target:TimeToDie() <= Player:GCD() then
		return S.ChainsOfIce:Cast()
	end
	-- actions.cold_heart+=/chains_of_ice,if=(buff.pillar_of_frost.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.pillar_of_frost.remains<rune.time_to_3)&buff.pillar_of_frost.up
	if S.ChainsOfIce:IsReady(30) and (Player:BuffRemainsP(S.PillarOfFrost) <= Player:GCD() * (1 + (S.FrostwyrmsFury:CooldownUp() and 1 or 0)) or Player:BuffRemainsP(S.PillarOfFrost) < Player:RuneTimeToX(3)) and Player:BuffP(S.PillarOfFrost) then
		return S.ChainsOfIce:Cast()
	end
	--[[END OF COLD HEART APL]] --
end

local function cooldowns()
	if RubimRH.CDsON() then
		--actions.cooldowns=use_items
		--actions.cooldowns+=/use_item,name=horn_of_valor,if=buff.pillar_of_frost.up&(!talent.breath_of_sindragosa.enabled|!cooldown.breath_of_sindragosa.remains)
		--actions.cooldowns+=/potion,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
	  	--actions.cooldowns+=/blood_fury,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
	  	if S.BloodFury:IsReady("Melee") and Player:Buff(S.PillarOfFrost) and Player:Buff(S.EmpowerRuneWeapon) then
	  		return S.BloodFury:Cast()
	  	end

	  	--actions.cooldowns+=/berserking,if=buff.pillar_of_frost.up
	  	if S.Berserking:IsReady("Melee") and Player:Buff(S.PillarOfFrost) then
	  		return S.Berserking:Cast()
	  	end

	  	--# Frost cooldowns
	  	--actions.cooldowns+=/pillar_of_frost,if=cooldown.empower_rune_weapon.remains
	  	if RubimRH.config.Spells[4].isActive and S.PillarOfFrost:IsReady() and S.EmpowerRuneWeapon:CooldownDown() then
	  		return S.PillarOfFrost:Cast()
	  	end

	  	-- actions.cooldowns+=/empower_rune_weapon,if=cooldown.pillar_of_frost.ready&!talent.breath_of_sindragosa.enabled&rune.time_to_5>gcd&runic_power.deficit>=10
	  	if S.EmpowerRuneWeapon:IsReady() and S.PillarOfFrost:CooldownUp() and not S.BreathofSindragosa:IsAvailable() and Player:RuneTimeToX(5) < Player:GCD() and Player:RunicPowerDeficit() >= 40 then
	  		return S.EmpowerRuneWeapon:Cast()
	  	end

	  	-- actions.cooldowns+=/empower_rune_weapon,if=cooldown.pillar_of_frost.ready&talent.breath_of_sindragosa.enabled&rune>=3&runic_power>60
	  	if S.EmpowerRuneWeapon:IsReady() and S.PillarOfFrost:CooldownUp() and S.BreathofSindragosa:IsAvailable() and Player:Runes() >= 3 and Player:RunicPower() > 60 then
	  		return S.EmpowerRuneWeapon:Cast()
	  	end
	  	-- actions.cooldowns+=/call_action_list,name=cold_heart,if=(equipped.cold_heart|talent.cold_heart.enabled)&(((buff.cold_heart_item.stack>=10|buff.cold_heart_talent.stack>=10)&debuff.razorice.stack=5)|target.time_to_die<=gcd)
	  	if (S.ColdHeartTalent:IsAvailable() or I.ColdHeart:IsEquipped()) and (((Player:BuffStack(S.ColdHeartBuff) >= 10 or Player:BuffStack(S.ColdHeartItemBuff) >= 10) and Target:DebuffStack(S.RazorIce) == 5) or Target:TimeToDie() <= Player:GCD()) and cold_heart() ~= nil then
	  		return cold_heart()
	  	end
		-- actions.cooldowns+=/frostwyrms_fury,if=(buff.pillar_of_frost.remains<=gcd&buff.pillar_of_frost.up)
		if S.FrostwyrmsFury:IsReady() and Player:BuffRemains(S.PillarOfFrost) <= Player:GCD() * 2 and Player:Buff(S.PillarOfFrost) then
			return S.FrostwyrmsFury:Cast()
		end
	end
end	

local function aoe()
	--actions.aoe=remorseless_winter,if=talent.gathering_storm.enabled
	if S.RemorselessWinter:IsReady() and (S.GatheringStorm:IsAvailable()) and Cache.EnemiesCount[8] >= 1 then
		return S.RemorselessWinter:Cast()
	end

	--actions.aoe+=/glacial_advance,if=talent.frostscythe.enabled
	if S.GlacialAdvance:IsReady() and (S.FrostScythe:IsAvailable()) then
		return S.GlacialAdvance:Cast()
	end

	--actions.aoe+=/frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
	if S.FrostStrike:IsReady(13) and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
		return S.FrostStrike:Cast()
	end

	--actions.aoe+=/howling_blast,if=buff.rime.up
	if S.HowlingBlast:IsReady(30, true) and (Player:Buff(S.Rime)) then
		return S.HowlingBlast:Cast()
	end

	--actions.aoe+=/frostscythe,if=buff.killing_machine.up
	if S.HowlingBlast:IsReady(30, true) and (Player:Buff(S.Rime)) then
		return S.HowlingBlast:Cast()
	end

	--actions.aoe+=/glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
	if S.GlacialAdvance:IsReady() and (Player:RunicPowerDeficit() < (15 + (S.RunicAttenuation:IsAvailable() and 1 or 0) * 3)) then
		return S.GlacialAdvance:Cast() 
	end

	--actions.aoe+=/frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
	if S.FrostStrike:IsReady(13) and (Player:RunicPowerDeficit() < (15 + (S.RunicAttenuation:IsAvailable() and 1 or 0) * 3)) then
		return S.FrostStrike:Cast()
	end

	--actions.aoe+=/remorseless_winter
	if S.RemorselessWinter:IsReady() and Cache.EnemiesCount[8] >= 1 then
		return S.RemorselessWinter:Cast()
	end

	--actions.aoe+=/frostscythe
	if S.FrostScythe:IsReady() and Cache.EnemiesCount[8] >= 1 then
		return S.FrostScythe:Cast()
	end

	--actions.aoe+=/obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
	if S.Obliterate:IsReady("Melee") and (Player:RunicPowerDeficit() > (25 + (S.RunicAttenuation:IsAvailable() and 1 or 0) * 3)) then
		return S.Obliterate:Cast()
	end

	--actions.aoe+=/glacial_advance
	if S.GlacialAdvance:IsReady() then
		return S.GlacialAdvance:Cast()
	end

	--actions.aoe+=/frost_strike
	if S.FrostStrike:IsReady(13) then
		return S.FrostStrike:Cast()
	end

	--actions.aoe+=/horn_of_winter
	if S.HornOfWinter:IsReady() then
		return S.HornOfWinter:Cast()
	end

	--actions.aoe+=/arcane_torrent
	if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() then
		return S.ArcaneTorrent:CasT()
	end
end


local function bos_pooling()
	-- howling_blast,if=buff.rime.up
	if S.HowlingBlast:IsReady(30, true) and Player:Buff(S.Rime) then
		return S.HowlingBlast:Cast()
	end
    -- obliterate,if=rune.time_to_4<gcd&runic_power.deficit>=25
    if S.Obliterate:IsReady("Melee") and (Player:RuneTimeToX(4) < Player:GCD() and Player:RunicPowerDeficit() >= 25) then
    	return S.Obliterate:Cast()
    end
    -- glacial_advance,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>rune.time_to_4
    if S.GlacialAdvance:IsReady() and (Player:RunicPowerDeficit() < 20 and S.PillarOfFrost:CooldownRemainsP() > Player:RuneTimeToX(4)) then
    	return S.GlacialAdvance:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up&runic_power.deficit>(15+talent.runic_attenuation.enabled*3)
    if S.FrostScythe:IsReady() and Cache.EnemiesCount[8] >= 1 and (Player:Buff(S.KillingMachine) and Player:RunicPowerDeficit() > (15 + (S.RunicAttenuation:IsAvailable() and 1 or 0) * 3)) then
    	return S.FrostScythe:Cast()
    end
    -- obliterate,if=runic_power.deficit>=(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsReady("Melee") and (Player:RunicPowerDeficit() >= (25 + (S.RunicAttenuation:IsAvailable() and 1 or 0) * 3)) then
    	return S.Obliterate:Cast()
    end
    -- glacial_advance,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsReady() and (S.PillarOfFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and Cache.EnemiesCount[30] >= 2) then
    	return S.GlacialAdvance:Cast()
    end
    -- frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40
    if S.FrostStrike:IsReady(13) and (S.PillarOfFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40) then
    	return S.FrostStrike:Cast()
    end
end


local function bos_ticking()
    -- obliterate,if=runic_power<=30
    if S.Obliterate:IsReady("Melee") and (Player:RunicPower() <= 30) then
    	return S.Obliterate:Cast()
    end
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsReady() and (S.GatheringStorm:IsAvailable()) then
    	return S.RemorselessWinter:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsReady(30, true) and (Player:Buff(S.Rime)) then
    	return S.HowlingBlast:Cast()
    end
    -- obliterate,if=rune.time_to_5<gcd|runic_power<=45
    if S.Obliterate:IsReady("Melee") and (Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45) then
    	return S.Obliterate:Cast()
    end
    -- frostscythe,if=buff.killing_machine.up
    if S.FrostScythe:IsReady() and Cache.EnemiesCount[8] >= 1 and (Player:BuffP(S.KillingMachine)) then
    	return S.FrostScythe:Cast()
    end
    -- horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
    if S.HornOfWinter:IsReady() and (Player:RunicPowerDeficit() >= 30 and Player:RuneTimeToX(3) > Player:GCD()) then
    	return S.HornOfWinter:Cast()
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsReady() then
    	return S.RemorselessWinter:Cast()
    end
    -- frostscythe,if=spell_targetS.FrostScythe:>=2
    if S.FrostScythe:IsReady() and (Cache.EnemiesCount[8] >= 2) then
    	return S.FrostScythe:Cast()
    end
    -- obliterate,if=runic_power.deficit>25|rune>3
    if S.Obliterate:IsReady("Melee") and (Player:RunicPowerDeficit() > 25 or Player:Runes() > 3) then
    	return S.Obliterate:Cast()
    end
    -- arcane_torrent,if=runic_power.deficit>20
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Player:RunicPowerDeficit() > 20) then
    	return S.ArcaneTorrent:Cast()
    end
end

local function obliteration()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsReady() and (S.GatheringStorm:IsAvailable()) then
    	return S.RemorselessWinter:Cast()
    end
    -- obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsReady("Melee") and (not S.FrostScythe:IsAvailable() and not Player:Buff(S.Rime) and Cache.EnemiesCount[10] >= 3) then
    	return S.Obliterate:Cast()
    end
    -- frostscythe,if=(buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance)))&(rune.time_to_4>gcd|spell_targets.frostscythe>=2)
    if S.FrostScythe:IsReady() and Cache.EnemiesCount[8] >= 1 and ((Player:BuffP(S.KillingMachine) or (Player:BuffP(S.KillingMachine) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) and (Player:RuneTimeToX(4) > Player:GCD() or Cache.EnemiesCount[8] >= 2)) then
    	return S.FrostScythe:Cast()
    end
    -- obliterate,if=buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsReady("Melee") and Player:BuffP(S.KillingMachine) or (Player:BuffP(S.KillingMachine) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance))) then
    	return S.Obliterate:Cast()
    end
    -- glacial_advance,if=(!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd)&spell_targets.glacial_advance>=2
    if S.GlacialAdvance:IsReady() and ((not Player:Buff(S.Rime) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) and Cache.EnemiesCount[30] >= 2) then
    	return S.GlacialAdvance:Cast()
    end
    -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
    if S.HowlingBlast:IsReady(30, true) and (Player:Buff(S.Rime) and Cache.EnemiesCount[10] >= 2) then
    	return S.HowlingBlast:Cast()
    end
    -- frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
    if S.FrostStrike:IsReady(13) and not Player:Buff(S.Rime) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD() then
    	return S.FrostStrike:Cast()
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsReady(30, true) and (Player:Buff(S.Rime)) then
    	return S.HowlingBlast:Cast()
    end
    -- frostscythe, if=spell_targets.frostscythe>=2
    if S.FrostScythe:IsReady() and Cache.EnemiesCount[8] >= 2 then
    	return S.FrostScythe:Cast()
    end
    -- obliterate
    if S.Obliterate:IsReady("Melee") then
    	return S.Obliterate:Cast()
    end
end


local function APL()
	if not Player:AffectingCombat() then
		return 0, 462338
	end
	HL.GetEnemies("Melee");
	HL.GetEnemies(8,true);
	HL.GetEnemies(10,true); 
	HL.GetEnemies(30,true);

	if RubimRH.config.Spells[1].isActive and Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[251].deathstrike then
		S.DeathStrike:Queue()
		return S.DeathStrike:Cast()
	end

	if RubimRH.config.Spells[1].isActive and Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 95 and Player:BuffRemains(S.DarkSuccor) <= 2 then
		S.DeathStrike:Queue()
		return S.DeathStrike:Cast()
	end

	  --actions+=/howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
	  if S.HowlingBlast:IsReady(30, true) and not Target:Debuff(S.FrostFever) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15 or not RubimRH.config.Spells[2].isActive) then
	  	return S.HowlingBlast:Cast()
	  end
	--actions+=/glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
	if S.GlacialAdvance:IsReady() and Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (Cache.EnemiesCount[10] >= 2) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15 or not RubimRH.config.Spells[2].isActive) then
		return S.GlacialAdvance:Cast()
	end

	--actions+=/frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
	if S.FrostStrike:IsReady(13) and Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15) then
		return S.FrostStrike:Cast()
	end
	--actions+=/breath_of_sindragosa,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
	if RubimRH.config.Spells[2].isActive and S.BreathofSindragosa:IsReady() and S.EmpowerRuneWeapon:CooldownRemainsP() > 0 and S.PillarOfFrost:CooldownRemainsP() > 0 then
		return S.BreathofSindragosa:Cast()
	end

	--actions+=/call_action_list,name=cooldowns
	if cooldowns() ~= nil then
		return cooldowns()
	end

	--actions+=/run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<5
	if RubimRH.config.Spells[2].isActive and S.BreathofSindragosa:IsAvailable() and S.BreathofSindragosa:CooldownRemains() < 5 and RubimRH.CDsON() then
		if bos_pooling() ~= nil then
			return bos_pooling()
		end
		return 0, 975743
	end

	--actions+=/run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
	if Player:Buff(S.BreathofSindragosa) then
		if bos_ticking() ~= nil then
			return bos_ticking()
		end
		return 0, 975743
	end

	--actions+=/run_action_list,name=obliteration,if=buff.pillar_of_frost.up&talent.obliteration.enabled
	if Player:Buff(S.PillarOfFrost) and S.Obliteration:IsAvailable() and obliteration() ~= nil then
		return obliteration()
	end

	--actions+=/run_action_list,name=aoe,if=active_enemies>=2
	if RubimRH.AoEON() and Cache.EnemiesCount[8] >= 2 and aoe() ~= nil then
		return aoe()
	end

	--actions+=/call_action_list,name=standard
	if standard() ~= nil then
		return standard()
	end

	return 0, 975743
end
RubimRH.Rotation.SetAPL(251, APL);

local function PASSIVE()
    if S.IceboundFortitude:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[251].icebound then
        return S.IceboundFortitude:Cast()
    end    
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(251, PASSIVE);

