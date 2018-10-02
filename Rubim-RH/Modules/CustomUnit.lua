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

    function Unit:HasStealableBuff()
        local GUID = self:GUID()
        if GUID then
            UnitID = self.UnitID
            local Buffs = Cache.Get("UnitInfo", GUID, "Buffs", _UnitBuff)
            for i = 1, #Buffs do
                local Buff = Buffs[i]
                if Buff[8] == true then
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

    function Unit:HasDispelableDebuff(debuffType1, debuffType2, debuffType3, debuffType4)
        local GUID = self:GUID()
        if GUID then
            UnitID = self.UnitID
            local Debuffs = Cache.Get("UnitInfo", GUID, "Debuffs", _UnitDebuff)
            for i = 1, #Debuffs do
                local Debuffs = Debuffs[i]
                if debuffType1 ~= nil and Debuffs[4] == debuffType1 then
                    return true
                end

                if debuffType2 ~= nil and Debuffs[4] == debuffType2 then
                    return true
                end

                if debuffType3 ~= nil and Debuffs[4] == debuffType3 then
                    return true
                end

                if debuffType4 ~= nil and Debuffs[4] == debuffType4 then
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

    if not self:Exists() then
        return 0
    end
    local guid, name = UnitGUID("target"), UnitName("target")
    local type, zero, server_id, instance_id, zone_uid, NPCID, spawn_uid = strsplit("-", guid);
    return PvPDummyUnits[tonumber(NPCID)] == true
end

--- Unit Health Functions

-- Incoming damage as percentage of Unit's max health
function Unit:LastDamage3Seconds()
    local IncomingDPS = (RubimRH.getLastDamage() / UnitHealthMax("player")) * 100
    return (math.floor((IncomingDPS * ((100) + 0.5)) / (100)))
end

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
    if self:BuffPvP(Spell(1044)) or self:BuffPvP(Spell(66115)) or self:BuffPvP(Spell(48265)) or self:BuffPvP(Spell(227847)) or self:BuffPvP(Spell(46924)) then
        return true
    end

    local engName, standardName, classNumber = self:Class()
    if classNumber == 6 and self:MaxSpeed() <= 99 then
        return true
    end

    if classNumber == 11 and self:MaxSpeed() <= 135 then
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

local randomChannel = math.random(20, 30)
local randomInterrupt = math.random(40, 70)
local randomTimer = GetTime()
local function randomGenerator(option)
    if GetTime() - randomTimer >= 1 then
        randomInterrupt = math.random(40, 70)
        randomChannel = math.random(20, 30)
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

local otherTank = Player
function Unit:IsTank()
    local unitRole = UnitGroupRolesAssigned(self:ID())
    if unitRole == "TANK" then
        return true
    end
    return false
end

local function CacheOtherTank()
    for i, CycleUnit in pairs(Unit.Raid) do
        if CycleUnit:IsTank() and CycleUnit:GUID() ~= Player:GUID() then
            otherTank = CycleUnit
        end
    end
end

RubimRH.Listener:Add('Rubim_Events', 'GROUP_ROSTER_UPDATE', function(...)
    CacheOtherTank()
end)

function Unit:NeedThreat()
    CacheOtherTank()
    if not otherTank:Exists() then
        otherTank = Player
    end

    HL.GetEnemies(10, true);
    local mobsnoAggro = 0
    local mobsonOtherTank = 0
    local totalMobs = 0

    for _, CycleUnit in pairs(Cache.Enemies[10]) do
        totalMobs = totalMobs + 1
        local threat
        if otherTank:Exists() and otherTank:IsTank() and otherTank:GUID() ~= Player:GUID() then
            threat = UnitThreatSituation(otherTank:ID(), CycleUnit.UnitID) or 3
            if threat >= 2 then
                mobsonOtherTank = mobsonOtherTank + 1
            end
        end
        threat = UnitThreatSituation("player", CycleUnit.UnitID) or 3

        if otherTank:GUID() == Player:GUID() then
            if threat <= 2 then
                return true
            end
        end

        if threat <= 2 then
            mobsnoAggro = mobsnoAggro + 1
        end
    end

    if mobsonOtherTank == totalMobs then
        return false
    end

    if mobsonOtherTank >= totalMobs - 1 then
        return false
    end

    if mobsnoAggro >= totalMobs - 2 then
        return true
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

local PvEImmunity = {
    275129, -- Corpulent Mass
    263217, -- BloodShield
    271965, -- Powered Down
    260189, -- Config Drill
}

function Unit:IsPvEImmunity()
    if not self:Exists() then
        return false
    end
    for p = 1, #PvEImmunity do
        if self:BuffPvP(Spell(PvEImmunity[p])) then
            return true
        end

        if self:DebuffPvP(Spell(PvEImmunity[p])) then
            return true
        end
    end
    return false
end

local MeleeSpecs = {
    [0] = false,
    [250] = true, -- Blood
    [251] = true, -- Frost
    [252] = true, -- Unholy
    [577] = true, -- Havoc
    [581] = true, -- Vengeance
    [103] = true, -- Feral
    [104] = true, -- Guardian
    [255] = true, -- Survival
    [268] = true, -- Brewmaster
    [269] = true, -- Windwalker
    [66] = true, -- Protection
    [70] = true, -- Retribution
    [71] = true, -- Arms
    [72] = true, -- Fury
    [73] = true, -- Protection
    [263] = true, -- Enhancement
    [259] = true, -- Assassination
    [260] = true, -- Icon Legion 18x18 Outlaw
    [261] = true, -- Subtlety
}
function Unit:IsMelee(ID)
    if ID ~= nil then
        if MeleeSpecs[ID] == true then
            return true
        end
        return false
    end
    local specID = GetSpecialization() or 0
    if MeleeSpecs[GetSpecializationInfo(specID)] == true then
        return true
    end
    return false
end

local RangedSpecs = {
    [102] = true, -- Balance
    [104] = true, -- Guardian
    [105] = true, -- Restoration
    [253] = true, -- Beast Mastery
    [254] = true, -- Marksmanship
    [62] = true, -- Arcane
    [63] = true, -- Fire
    [64] = true, -- Frost
    [270] = true, -- Mistweaver
    [65] = true, -- Holy
    [256] = true, -- Discipline
    [257] = true, -- Holy
    [258] = true, -- Shadow
    [262] = true, -- Elemental
    [264] = true, -- Restoration
    [265] = true, -- Affliction
    [266] = true, -- Demonology
    [267] = true, -- Destruction
}

function Unit:IsRanged(ID)
    if ID ~= nil then
        if RangedSpecs[ID] == true then
            return true
        end
        return false
    end
    local specID = GetSpecialization() or 0
    if RangedSpecs[GetSpecializationInfo(specID)] == true then
        return true
    end
    return false
end