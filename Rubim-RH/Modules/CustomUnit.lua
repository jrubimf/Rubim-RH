local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;


local PvPDummyUnits = {
	-- City (SW, Orgri, ...)
	[114840] = true, -- Raider's Training Dummy
}

-- Unit = PvP Dummy
function Unit:IsPvPDummy()
	local NPCID = self:NPCID()
	return NPCID >= 0 and PvPDummyUnits[NPCID] == true
end

--- Unit Health Functions

-- Incoming damage as percentage of Unit's max health
function Unit:IncDmgPercentage()
	unit = self.UnitID
	local IncomingDPS = (RubimRH.getDMG(unit) / UnitHealthMax(unit)) * 100
	return (math.floor((IncomingDPS * ((100) + 0.5)) / (100)))
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

-- Unit Slowed
function Unit:IsSnared()
	if self:Class() == 6 and self:MaxSpeed() < 99 then
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

function Unit:IsInterruptable()
	local channeling = false
	local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId
	if UnitCastingInfo(self.UnitID) ~= nil then
		name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo(self.UnitID)
	end	

	if UnitChannelInfo(self.UnitID) ~= nil then
		name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitChannelInfo(self.UnitID)
		channeling = true
	end

	
	if name == nil or notInterruptable == true then
		return false
	end

	local timeSinceStart = (GetTime() * 1000 - startTimeMS) / 1000
	local timeLeft = ((GetTime() * 1000 - endTimeMS) * -1) / 1000
	local castTime = endTimeMS - startTimeMS
	local currentPercent = timeSinceStart / castTime * 100000
	local interruptPercent = randomGenerator("Interrupt")
	if channeling == true then 
		interruptPercent = randomGenerator("Channel")
	end
	
	if currentPercent >= interruptPercent then
		return true
	end
	return false
end

function Unit:NeedThreat()
	if UnitThreatSituation(self.UnitID) == 2 then
		return true
	end
	return false
end
