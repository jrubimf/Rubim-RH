local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")

local addonName, addonTable = ...

-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell = HL.Spell
local Item = HL.Item

local CombatStartTime = nil
local CombatTimeLapsed = nil

local S = RubimRH.Spell[263]

local function ResetCombatTime()
	CombatStartTime = nil
	CombatTimeLapsed = nil
end

--- SimC APL Vars
-- actions+=/variable,name=hailstormCheck,value=((talent.hailstorm.enabled&!buff.frostbrand.up)|!talent.hailstorm.enabled)
local function HailstormCheck()
	return ((S.Hailstorm:IsAvailable() and not Player:Buff(S.Frostbrand)) or (not S.Hailstorm:IsAvailable()))
end

-- actions+=/variable,name=furyCheck80,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&((maelstrom>35&cooldown.lightning_bolt.remains>=3*gcd)|maelstrom>80)))
local function FuryCheck80()
	return (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and ((Player:Maelstrom() > 35 and S.LightningBolt:CooldownRemains() >= 3 * Player:GCD()) or Player:Maelstrom() > 80)))
end

-- actions+=/variable,name=furyCheck70,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>70))
local function FuryCheck70()
	return (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 70))
end

-- actions+=/variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
local function FuryCheck45()
	return (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 45))
end

-- actions+=/variable,name=furyCheck35,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>35))
local function FuryCheck35()
	return (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 35))
end

-- actions+=/variable,name=furyCheck25,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>25))
local function FuryCheck25()
	return (not S.FuryOfAir:IsAvailable() or (S.FuryOfAir:IsAvailable() and Player:Maelstrom() > 25))
end

-- actions+=/variable,name=OCPool70,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>70))
local function OCPool70()
	return (not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and Player:Maelstrom() > 70))
end

-- actions+=/variable,name=OCPool60,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>60))
local function OCPool60()
	return (not S.Overcharge:IsAvailable() or (S.Overcharge:IsAvailable() and Player:Maelstrom() > 60))
end

local function UpdateCombatTime()
	if CombatStartTime == nil then CombatStartTime = GetTime() end
	CombatTimeLapsed = CombatStartTime - GetTime()
end

local function BurstRotation()
	-- actions.asc=earthen_spike
	if S.EarthenSpike:IsReady() then return S.EarthenSpike:Cast() end

	-- actions.asc+=/crash_lightning,if=!buff.crash_lightning.up&active_enemies>=2
	if S.CrashLightning:IsReady() 
		and not Player:Buff(S.CrashLightning)
		and Cache.EnemiesCount[8] >= 2 then
		return S.CrashLightning:Cast()
	end

	-- actions.asc+=/rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
	if S.Rockbiter:IsReady()
		and S.Landslide:IsAvailable()
		and not Player:Buff(S.LandslideBuff)
		and S.Rockbiter:ChargesFractional() > 1.7 then
		return S.Rockbiter:Cast()
	end

	-- actions.asc+=/windstrike
	if S.Windstrike:IsReadyMorph() then
		return S.Windstrike:Cast()
	end

	return nil
end

local function Buffs()
	-- actions.buffs=rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
	if S.Rockbiter:IsReady()
		and S.Landslide:IsAvailable()
		and not Player:Buff(S.LandslideBuff)
		and S.Rockbiter:ChargesFractional() > 1.7 then
		return S.Rockbiter:Cast()
	end

	-- actions.buffs+=/fury_of_air,if=!ticking&maelstrom>22
	if S.FuryOfAir:IsReady()
		and not Player:Buff(S.FuryOfAir)
		and Player:Maelstrom() > 22 then
		return S.FuryOfAir:Cast()
	end

	-- actions.buffs+=/flametongue,if=!buff.flametongue.up
	if S.Flametongue:IsReady()
		and not Player:Buff(S.Flametongue) then
		return S.Flametongue:Cast()
	end

	-- actions.buffs+=/frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck45
	if S.Frostbrand:IsReady()
		and S.Hailstorm:IsAvailable()
		and not Player:Buff(S.Frostbrand)
		and FuryCheck45() then
		return S.Frostbrand:Cast()
	end

	-- actions.buffs+=/flametongue,if=buff.flametongue.remains<6+gcd
	if S.Flametongue:IsReady()
		and Player:BuffRemains(S.Flametongue) < 6 + Player:GCD() then
		return S.Flametongue:Cast()
	end

	-- actions.buffs+=/frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<6+gcd
	if S.Frostbrand:IsReady()
		and S.Hailstorm:IsAvailable()
		and Player:BuffRemains(S.Frostbrand) < 6 + Player:GCD() then
		return S.Frostbrand:Cast()
	end

	-- actions.buffs+=/totem_mastery,if=buff.resonance_totem.remains<2
	if S.TotemMastery:IsReady()
		and not Player:Buff(S.ResonanceTotemBuff) then
		return S.TotemMastery:Cast()
	end

	return nil
end

local function Cooldowns()

	-- TODO: Enabled when GGLoader includes keybind setting for Bloodlust
	-- Bloodlust
	-- if Target:HealthPercentage() < 40 
	-- 	and Target:TimeToDie() > 20 
	-- 	and S.Bloodlust:IsReady() then
	-- 	return S.Bloodlust:Cast()
	-- end

	-- actions.cds+=/berserking,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
	if S.Berserking:IsReady()
		and (Player:Buff(S.Ascendance) or Player:BuffRemains(S.FeralSpirit) > 5) then
		return S.Berserking:Cast()
	end

	-- actions.cds+=/blood_fury,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
	if S.BloodFury:IsReady()
		and (Player:Buff(S.Ascendance) or Player:BuffRemains(S.FeralSpirit) > 5) then
		return S.BloodFury:Cast()
	end

	-- actions.cds+=/potion,if=buff.ascendance.up|!talent.ascendance.enabled&feral_spirit.remains>5|target.time_to_die<=60

	-- actions.cds+=/feral_spirit
	if S.FeralSpirit:IsReady() then
		return S.FeralSpirit:Cast()
	end

	-- actions.cds+=/ascendance,if=(cooldown.strike.remains>0)&buff.ascendance.down
	if S.Ascendance:IsReady()
		and S.Stormstrike:IsReady()
		and not Player:Buff(S.Ascendance) then
		return S.Ascendance:Cast()
	end

	-- TODO: Disabled -> Currently GGLoader has no keybind for Earth Elemental
	-- actions.cds+=/earth_elemental
	-- if S.EarthElemental:IsReady() then
	-- 	return S.EarthElemental:Cast()
	-- end
end

local function APL()

    if not Player:AffectingCombat() then
    	ResetCombatTime()
    	return 0, 462338 
    end
    
    UpdateCombatTime()

    -- Update Surrounding Enemies
    HL.GetEnemies("Melee");
	HL.GetEnemies(8, true);
	HL.GetEnemies(10, true);

    -- Kick

	-- actions.opener=rockbiter,if=maelstrom<15&time<gcd
	if S.Rockbiter:IsReady()
		and Player:Maelstrom() < 15
		and CombatTimeLapsed < Player:GCD() then
		return S.Rockbiter:Cast()
	end

	-- actions.precombat+=/lightning_shield
	if S.LightningShield:IsReady()
		and not Player:Buff(S.LightningShield) then
		return S.LightningShield:Cast()
	end

	-- actions+=/call_action_list,name=asc,if=buff.ascendance.up
	if Player:Buff(S.Ascendance) and BurstRotation() ~= nil then return BurstRotation() end

	-- actions+=/call_action_list,name=buffs
	if Buffs() ~= nil then return Buffs() end
	
	-- actions+=/call_action_list,name=cds
	if (RubimRH.CDsON() and Cooldowns() ~= nil) then return Cooldowns() end

	-- Primary Rotation

	-- actions.core=earthen_spike,if=variable.furyCheck25
	if S.EarthenSpike:IsReady() 
		and FuryCheck25() then 
		return S.EarthenSpike:Cast() 
	end

	-- actions.core+=/crash_lightning,if=!buff.crash_lightning.up&active_enemies>=2
	if S.CrashLightning:IsReady() 
		and Cache.EnemiesCount[8] >= 2 
		and (not Player:Buff(S.CrashLightning)) then 
		return S.CrashLightning:Cast() 
	end

	-- actions.core+=/crash_lightning,if=active_enemies>=8|(active_enemies>=6&talent.crashing_storm.enabled)
	if S.CrashLightning:IsReady() 
		and (Cache.EnemiesCount[8] >= 8 or (Cache.EnemiesCount[8] >= 6 and S.CrashingStorm:IsAvailable())) then
		return S.CrashLightning:Cast()
	end

	-- actions.core+=/stormstrike,if=buff.stormbringer.up
	if S.Stormstrike:IsReady() 
		and Player:Buff(S.Stormbringer) then
		return S.Stormstrike:Cast()
	end

	-- actions.core+=/crash_lightning,if=active_enemies>=4|(active_enemies>=2&talent.crashing_storm.enabled)
	if S.CrashLightning:IsReady() 
		and (Cache.EnemiesCount[8] >= 4 or (Cache.EnemiesCount[8] >= 2 and S.CrashingStorm:IsAvailable())) then
		return S.CrashLightning:Cast()
	end

	-- actions.core+=/lightning_bolt,if=talent.overcharge.enabled&variable.furyCheck45&maelstrom>=40
	if S.LightningBolt:IsReady()
		and S.Overcharge:IsAvailable()
		and FuryCheck45()
		and Player:Maelstrom() >= 40 then
		return S.LightningBolt:Cast()
	end

	-- actions.core+=/stormstrike,if=(!talent.overcharge.enabled&variable.furyCheck35)|(talent.overcharge.enabled&variable.furyCheck80)
	if S.Stormstrike:IsReady()
		and ((not S.Overcharge:IsAvailable() and FuryCheck35())
			or (S.Overcharge:IsAvailable() and FuryCheck80())) then
		return S.Stormstrike:Cast()
	end

	-- actions.core+=/sundering
	if S.Sundering:IsReady() then
		return S.Sundering:Cast()
	end

	-- actions.core+=/flametongue,if=talent.searing_assault.enabled
	if S.Flametongue:IsReady()
		and S.SearingAssault:IsAvailable() then
		return S.Flametongue:Cast()
	end

	-- actions.core+=/lava_lash,if=buff.hot_hand.react
	if S.LavaLash:IsReady()
		and Player:Buff(S.HotHand) then
		return S.LavaLash:Cast()
	end

	-- actions.core+=/crash_lightning,if=active_enemies>=3
	if S.CrashLightning:IsReady()
		and Cache.EnemiesCount[8] >= 3 then
		return S.CrashLightning:Cast()
	end

	-- actions.filler=rockbiter,if=maelstrom<70
	if S.Rockbiter:IsReady()
		and Player:Maelstrom() < 70 then
		return S.Rockbiter:Cast()
	end

	-- actions.filler+=/flametongue,if=talent.searing_assault.enabled|buff.flametongue.remains<4.8
	if S.Flametongue:IsReady()
		and (S.SearingAssault:IsAvailable() or Player:BuffRemains(S.Flametongue) < 4.8) then
		return S.Flametongue:Cast()
	end

	-- actions.filler+=/crash_lightning,if=(talent.crashing_storm.enabled|active_enemies>=2)&debuff.earthen_spike.up&maelstrom>=40&variable.OCPool60
	if S.CrashLightning:IsReady()
		and ((S.CrashingStorm:IsAvailable() or Cache.EnemiesCount[8] >= 2) and Target:Debuff(S.EarthenSpike) and Player:Maelstrom() >= 40 and OCPool60()) then
		return S.CrashLightning:Cast()
	end

	-- actions.filler+=/frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8&maelstrom>40
	if S.Frostbrand:IsReady()
		and S.Hailstorm:IsAvailable()
		and Player:BuffRemains(S.Frostbrand) < 4.8
		and Player:Maelstrom() > 40 then
		return S.Frostbrand:Cast()
	end

	-- actions.filler+=/lava_lash,if=maelstrom>=50&variable.OCPool70&variable.furyCheck80
	if S.LavaLash:IsReady()
		and Player:Maelstrom() >= 50
		and OCPool70
		and FuryCheck80() then
		return S.LavaLash:Cast()
	end

	-- actions.filler+=/rockbiter
	if S.Rockbiter:IsReady() then return S.Rockbiter:Cast() end

	-- actions.filler+=/crash_lightning,if=(maelstrom>=65|talent.crashing_storm.enabled|active_enemies>=2)&variable.OCPool60&variable.furyCheck45
	if S.CrashLightning:IsReady()
		and (Player:Maelstrom() >= 65 or S.CrashingStorm:IsAvailable() or Cache.EnemiesCount[8] >= 2)
		and OCPool60()
		and FuryCheck45 then
		return S.CrashLightning:Cast()
	end

	-- actions.filler+=/flametongue
	if S.Flametongue:IsReady() then return S.Flametongue:Cast() end

    return 0, 975743
end

RubimRH.Rotation.SetAPL(263, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(263, PASSIVE);