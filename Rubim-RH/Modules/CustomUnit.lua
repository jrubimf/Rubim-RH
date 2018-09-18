local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

do
	--  1      2     3      4            5           6             7           8           9                      10          11          12            13                14            15       16     17      18
	-- name, icon, count, dispelType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll, timeMod, value1, value2, value3
	local UnitBuff = UnitBuff
	local UnitID
	local function _UnitBuff()
		local Buffs = {}
		for i = 1, HL.MAXIMUM do
			local Infos = { UnitBuff(UnitID, i) }
			if not Infos[10] then
				break
			end
			Buffs[i] = Infos
		end
		return Buffs
	end

	function Unit:BuffPvP(Spell, Index, AnyCaster)
		local GUID = self:GUID()
		if GUID then
			UnitID = self.UnitID
			local Buffs = Cache.Get("UnitInfo", GUID, "Buffs", _UnitBuff)
			for i = 1, #Buffs do
				local Buff = Buffs[i]
				if Spell:ID() == Buff[10] then
					return true
				end
			end
		end
		return false
	end
end

do
	--  1     2      3         4          5           6           7           8                   9              10         11            12           13               14            15       16      17      18
	-- name, icon, count, dispelType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll, timeMod, value1, value2, value3
	local UnitDebuff = UnitDebuff
	local UnitID
	local function _UnitDebuff()
		local Debuffs = {}
		for i = 1, HL.MAXIMUM do
			local Infos = { UnitDebuff(UnitID, i) }
			if not Infos[10] then
				break
			end
			Debuffs[i] = Infos
		end
		return Debuffs
	end

	function Unit:DebuffPvP(Spell, Index, AnyCaster)
		local GUID = self:GUID()
		if GUID then
			UnitID = self.UnitID
			local Debuffs = Cache.Get("UnitInfo", GUID, "Debuffs", _UnitDebuff)
			for i = 1, #Debuffs do
				local Debuff = Debuffs[i]
				if Spell:ID() == Debuff[10] then
					return true
				end
			end
		end
		return false
	end
end

local PvPDummyUnits = {
	-- City (SW, Orgri, ...)
	[114840] = true, -- Raider's Training Dummy
	[114832] = true,
}

-- Unit = PvP Dummy
function Unit:IsAPvPDummy()
	local NPCID = self:NPCID()
	return NPCID >= 0 and PvPDummyUnits[NPCID] == true
end

--- Unit Health Functions

-- Incoming damage as percentage of Unit's max health
function Unit:IncDmgPercentage()
	local unit = self.UnitID
	local IncomingDPS = (RubimRH.getDMG(unit) / UnitHealthMax(unit)) * 100
	return (math.floor((IncomingDPS * ((100) + 0.5)) / (100)))
end

function Unit:IncDmgSwing()
	local unit = self.UnitID
	local IncomingDPS = (RubimRH.incdmgswing(unit) / UnitHealthMax(unit)) * 100
	return (math.floor((IncomingDPS * ((100) + 0.5)) / (100)))
end

function Unit:LastSwinged()
	local unit = self.UnitID
	return RubimRH.lastSwing(unit)
end

-- Minor Defensive Usage (<= 1 Min CDs)
RubimRH.MinorHealingThreshold = 2
function Unit:NeedMinorHealing()
	return (self:IncDmgPercentage() > RubimRH.MinorHealingThreshold or self:HealthPercentage() <= 85)
end

-- Major Defensive Usage (<= 3 Min CDs)
RubimRH.MajorHealingThreshold = 5
function Unit:NeedMajorHealing()
	return (self:IncDmgPercentage() > RubimRH.MajorHealingThreshold or self:HealthPercentage() <= 60)
end

-- Panic Defensive Usage (> 3 Min CDs)
RubimRH.PanicHealingThreshold = 10
function Unit:NeedPanicHealing()
	return (self:IncDmgPercentage() > RubimRH.PanicHealingThreshold or self:HealthPercentage() <= 40)
end


function Unit:Class()
	return UnitClass(self.UnitID)
end

--- Unit Speed Functions

function Unit:IsSnared()
	if self:BuffPvP(Spell(1044)) or self:BuffPvP(Spell(66115)) or self:BuffPvP(Spell(48265)) or self:BuffPvP(Spell(227847)) or self:BuffPvP(Spell(46924))  then
		return true
	end

	local engName, standardName, classNumber = self:Class()
	if (classNumber == 6  or classNumber == 11) and self:MaxSpeed() <= 99 then
		return true
	end
	return (self:MaxSpeed() < 70)	
end

-- Unit's Speed
function Unit:Speed()
	return math.floor(GetUnitSpeed(self.UnitID) / 7 * 100)
end

-- Unit's Maximum Speed
function Unit:MaxSpeed()
	return math.floor(select(2, GetUnitSpeed(self.UnitID)) / 7 * 100)
end

local randomChannel = math.random(10, 20)
local randomInterrupt = math.random(40, 70)
local randomTimer = GetTime()
local function randomGenerator(option)
	if GetTime() - randomTimer >= 1 then
		randomInterrupt = math.random(40, 70)
		randomChannel = math.random(10, 20)
		randomTimer = GetTime()
	end

	if option == "Interrupt" then
		return randomInterrupt
	end	
	if option == "Channel" then
		return randomChannel
	end     
end

function Unit:IsInterruptible()
	if self:CastingInfo(8) == true or self:ChannelingInfo(7) == true then
		return false
	end


	if self:CastPercentage() >= randomGenerator("Interrupt") then
		return true
	end
	return false
end

function Unit:NeedThreat()
	local threat = UnitThreatSituation("player") or 3
	HL.GetEnemies(10, true);
	for _, CycleUnit in pairs(Cache.Enemies[10]) do
		local threat = UnitThreatSituation("player", CycleUnit.UnitID) or 3
		if threat <= 2 then
			return true
		end
	end
	return false
end

function Unit:IsInWarMode()
	if self:Buff(Spell(269083)) then
		return true
	end
	return false
end

local stoppedtime = 9999999
function Unit:StoppedFor()
	if self:IsMoving() then
		stoppedtime = GetTime()
	end
	return GetTime() - stoppedtime
end

local movedTimer = 0
function Unit:MovingFor()
	if not self:IsMoving() then
		movedTimer = GetTime()
	end
	return GetTime() - movedTimer
end

function Unit:IsTargeting(otherUnit)
	local oGUID = UnitGUID(otherUnit.UnitID)
	local tGUID = UnitGUID(self.UnitID .. "target")

	if tGUID == oGUID then
		return true
	end
	return false
end

function Unit:StackUp(min, max)
	local min = min or 8
	local max = max or 25

	HL.GetEnemies(min, true);
	HL.GetEnemies(max, true);

	if Cache.EnemiesCount[min] == 0 then
		return false
	end

	if Cache.EnemiesCount[min] == Cache.EnemiesCount[max] then
		return true
	end
	return false
end

function Unit:AreaTTD()
	HL.GetEnemies(10, true);
	local ttdtotal = 0
	local totalunits = 0
	for _, CycleUnit in pairs(Cache.Enemies[10]) do
		local ttd = CycleUnit:TimeToDie()
		totalunits = totalunits + 1
		ttdtotal = ttd + ttdtotal
	end
	if totalunits == 0 then
		return 0
	end

	return ttdtotal / totalunits
end