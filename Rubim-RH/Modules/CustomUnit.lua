local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Pet = Unit.Pet;
local Target = Unit.Target;
local Arena = Unit.Arena;
local Spell = HL.Spell;
local Item = HL.Item;
local debug = RubimRH.DebugPrint;
local mainAddon = RubimRH;

local pairs, next = pairs, next

local UnitIsPlayer, UnitExists, UnitGUID = UnitIsPlayer, UnitExists, UnitGUID

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

    local spellId = self:CastingInfo(9) or self:ChannelingInfo(8)

    if spellId ~= nil then

        if RubimRH.db.profile.mainOption.whitelist then
            if RubimRH.db.profile.mainOption.interruptList[spellId] then
                if self:CastPercentage() >= randomGenerator("Interrupt") then
                    return true
                end
            end
        else
            if RubimRH.db.profile.mainOption.interruptList[spellId] then
                return false
            end
        end
    end

    if not RubimRH.InterruptsON() then
        return false
    end

    for i, v in pairs(RubimRH.db.profile.mainOption.interruptList) do
        if RubimRH.db.profile.mainOption.whitelist then
            return false
        end
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

local timer = HL.GetTime()
local totalEnemies = 0

function Unit:EnemiesAround(distance, ignoreCombat)
    return Cache.EnemiesCount[distance] or 0
end

-- Dispellables PvE Spells
local DispellablesPvE = {
        -- Venomfang Strike
        [252687] = {dur = 0, stack = 0, dispelType = "Poison"},
        -- Hidden Blade
        [270865] = {dur = 0, stack = 0, dispelType = "Poison"},
        -- Embalming Fluid 
        [271563] = {dur = 0, stack = 3, dispelType = "Poison"},
        -- Poison Barrage 
        [270507] = {dur = 0, stack = 0, dispelType = "Poison"},
        -- Stinging Venom Coating
        [275835] = {dur = 0, stack = 4, dispelType = "Poison"},
        -- Neurotoxin 
        [273563] = {dur = 1.49, stack = 0, dispelType = "Poison"},
        -- Cytotoxin 
        [267027] = {dur = 0, stack = 2, dispelType = "Poison"},
        -- Venomous Spit
        [272699] = {dur = 0, stack = 0, dispelType = "Poison"},
        -- Widowmaker Toxin
        [269298] = {dur = 0, stack = 2, dispelType = "Poison"}, 
        -- Stinging Venom
        [275836] = {dur = 0, stack = 5, dispelType = "Poison"},  
		
        -- Infected Wound
        [258323] = {dur = 0, stack = 1, dispelType = "Disease"},
        -- Plague Step
        [257775] = {dur = 0, stack = 0, dispelType = "Disease"},
        -- Wretched Discharge
        [267763] = {dur = 0, stack = 0, dispelType = "Disease"},
        -- Plague 
        [269686] = {dur = 0, stack = 0, dispelType = "Disease"},
        -- Festering Bite
        [263074] = {dur = 0, stack = 0, dispelType = "Disease"},
        -- Decaying Mind
        [278961] = {dur = 0, stack = 0, dispelType = "Disease"},
        -- Decaying Spores
        [259714] = {dur = 0, stack = 1, dispelType = "Disease"},
        -- Festering Bite
        [263074] = {dur = 0, stack = 0, dispelType = "Disease"},
		
        -- Wracking Pain
        [250096] = {dur = 0, stack = 0, dispelType = "Curse"},
        -- Pit of Despair
        [276031] = {dur = 0, stack = 0, dispelType = "Curse"},
        -- Hex 
        [270492] = {dur = 0, stack = 0, dispelType = "Curse"},
        -- Cursed Slash
        [257168] = {dur = 0, stack = 2, dispelType = "Curse"},
        -- Withering Curse
        [252687] = {dur = 0, stack = 2, dispelType = "Curse"},
		
        -- Molten Gold
        [255582] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Terrifying Screech
        [255041] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Terrifying Visage
        [255371] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Oiled Blade
        [257908] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Choking Brine
        [264560] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Electrifying Shock
        [268233] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Touch of the Drowned (if no party member is afflicted by Mental Assault (268391))
        [268322] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Mental Assault 
        [268391] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Explosive Void
        [269104] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Choking Waters
        [272571] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Putrid Waters
        [274991] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Flame Shock (if no party member is afflicted by Snake Charm (268008)))
        [268013] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Snake Charm
        [268008] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Brain Freeze
        [280605] = {dur = 1.49, stack = 0, dispelType = "Magic"},
        -- Transmute: Enemy to Goo
        [268797] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Chemical Burn
        [259856] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Debilitating Shout
        [258128] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Torch Strike 
        [265889] = {dur = 0, stack = 1, dispelType = "Magic"},
        -- Fuselighter 
        [257028] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Death Bolt 
        [272180] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Putrid Blood
        [269301] = {dur = 0, stack = 2, dispelType = "Magic"},
        -- Grasping Thorns
        [263891] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Fragment Soul
        [264378] = {dur = 0, stack = 0, dispelType = "Magic"},
        -- Reap Soul
        [288388] = {dur = 0, stack = 20, dispelType = "Magic"},
        -- Putrid Waters
        [275014] = {dur = 0, stack = 0, dispelType = "Magic"},
}
-- Dispellables PvP Spells
local DispellablesPvP = {
 
}


-- Dispell function
function Unit:IsDispellable()
	
	-- checking target
    if target == nil then
        return false
    end
    
	if target == "target" and not UnitExists("target") then
        return false
    end
	
	-- return boolean true if the player knows a spell to dispel the aura. &number The spell ID of the spell to dispel, or nil.
    for p = 1, #DispellablesPvE do
		-- if we can dispell our target and buff is matching Dispellables List and Dispell type to do is doable for the current specialisation
	    if LibDispellable:CanDispel("target", false, DispellablesPvE[p].dispelType, Spell(DispellablesPvE[p])) then
    --  if target:Buff(Spell(DispellablesPvE[p])) then
            return true
			--for index, spellID, name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff in LibDispellable:IterateDispellableAuras("target", true) do
            --    print("Can dispel", name, "on target using", GetSpellInfo(spellID))
            --end
        end
    end
    
    return false
end

-- Units 
-- AutoTarget 
function CombatUnits(stop, range, upttd)
    local totalmobs = 0   
    if activeUnitPlates then
        for reference, unit in pairs(activeUnitPlates["enemy"]) do
            if 
            CombatTime(unit) > 0 and 
            ( not range or SpellInteract(unit, range) ) and 
            ( not upttd or TimeToDie(unit) >= upttd ) then 
                totalmobs = totalmobs + 1            
                
                if stop and totalmobs >= stop then                  
                    break
                end    
            end
        end   
    end    
    -- True/False or Number
    return (stop and totalmobs >= stop) or (not stop and totalmobs) 
end

-- Round function
function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

-- Range enemies count by Ayni
local logUnits, activeUnits = {}, {}

RubimRH.Listener:Add('Rubim_Events', 'PLAYER_REGEN_ENABLED', function()
        if not InCombatLockdown() and not Player:AffectingCombat() then
            wipe(logUnits)
            wipe(activeUnits)            
        end        
end)

RubimRH.Listener:Add('Rubim_Events', 'PLAYER_REGEN_DISABLED', function()
    wipe(logUnits)
	wipe(activeUnits)
end)

RubimRH.Listener:Add('Rubim_Events', "COMBAT_LOG_EVENT_UNFILTERED", function(...)
        local ts, event, _, SourceGUID, SourceName,_,_, DestGUID, DestName,_,_, spellID, spellName,_, auraType, Amount = CombatLogGetCurrentEventInfo()
        if 
        (
            (
                event == "SWING_DAMAGE" or
                event == "RANGE_DAMAGE" or
                event == "SPELL_DAMAGE" or
                (
                    (
                        event == "SPELL_AURA_APPLIED" or
                        event == "SPELL_AURA_REFRESH"
                    ) and
                    auraType == "DEBUFF" and
                    UnitGUID("player") == SourceGUID                    
                )
            ) and                     
            DestGUID and    
            SourceGUID
        ) then   
            ts = round(ts, 0)  

			if not logUnits[SourceGUID] then 
				logUnits[SourceGUID] = {
					TS = ts, 					
					Count = 0,
					Units = {},
				}
			end 
			
			if logUnits[SourceGUID] then 	
				if not logUnits[SourceGUID].Units[DestGUID] then 
					logUnits[SourceGUID].TS = ts
					logUnits[SourceGUID].Count = logUnits[SourceGUID].Count + 1	
					logUnits[SourceGUID].Units[DestGUID] = HL.GetTime()
				end 
				
				if logUnits[SourceGUID].TS == ts then 
					logUnits[SourceGUID].Units[DestGUID] = HL.GetTime()
				end 
			end         
        end  
        
        -- Remove dead units
        if event == "UNIT_DIED" and next(logUnits) then
            for GUID in pairs(logUnits) do
				if logUnits[GUID].Units[DestGUID] then 
					logUnits[GUID].Count = logUnits[GUID].Count - 1
					logUnits[GUID].Units[DestGUID] = nil
				end 
            end                    
        end                                       
end)    

function active_enemies()   
    local total = 1   
    -- CombatLogs 
    if next(logUnits) and UnitExists("target") then 
        wipe(activeUnits)        
        -- Check units  
        local needRemove = true 
        for GUID in pairs(logUnits) do                
            for UNIT, TIME in pairs(logUnits[GUID].Units) do 
                -- Remove old units 
                if HL.GetTime() - TIME > 4.5 then 
                    logUnits[GUID].Count = logUnits[GUID].Count - 1
                    logUnits[GUID].Units[UNIT] = nil                     
                end 
                -- Check if Source caster has same target as your then we don't will delete 
                if needRemove and UnitGUID("target") == UNIT then 
                    needRemove = false  
                end 
            end 
            if not needRemove then 
                -- Added actual active units count
                table.insert(activeUnits, logUnits[GUID].Count)
                needRemove = true 
            end 
        end 
        -- Sort my highest units count 
        table.sort(activeUnits, function (a, b) return (a > b) end)
        -- Result 
        local sortedUnits = activeUnits[1] or 0
        total = (sortedUnits > 0 and sortedUnits) or 1
    end 
    
    -- If CombatLogs corrupted then query nameplates by units into combat
    -- Note: Worn method since it can't keep in mind position 
    if total == 1 then 
        total = CombatUnits(nil, 40)              
    end
    
    return total
end


-- Test 
--PetBasicAttacks = {	
--Hunter
--17253, -- Bite
--16827, -- Claw
--49966, -- Smack

-- Warlock
--30213, --Legion Strike
--}

--function IsPetInRange(unit)
 --   if UnitExists(unit) and UnitExists("pet") then
  --      for i = 1, #PetBasicAttacks do 
--		    if IsSpellInRange(GetSpellInfo(PetBasicAttacks[i]),unit) == 1 then 
--			    return true 
--			end 
--		end
 --   end
--end

-- Pet range 
local pairs = pairs
local oPetSlots = {
    -- Unholy 
    [252] = {
        [47482] = 0, -- Jump
        [47481] = 0, -- Gnaw
    }, 
	-- Demonology
	[266] = {
        [30213] = 0, -- Legion Strike
    }, 
}
function RubimRH.PetSpellInRange(id, unit)
    if not unit then 
	    unit = "target" 
	end 
    local slot = oPetSlots[RubimRH.playerSpec] and oPetSlots[RubimRH.playerSpec][id]
    return (slot and slot > 0 and IsActionInRange(slot, unit)) or false
end 

function RubimRH.PetAoE(spellID, stop)
    local UnitPlates = GetActiveUnitPlates("enemy")
    local total = 0 
    if UnitPlates then 
        for reference, unit in pairs(UnitPlates) do
            if type(spellID) == "table" then
                for k, v in pairs(spellID) do
                    if RubimRH.PetSpellInRange(v, unit) then
                        total = total + 1  
                        break
                    end
                end
            elseif RubimRH.PetSpellInRange(spellID, unit) then 
                total = total + 1                                            
            end  
            
            if stop and total >= stop then
                break                        
            end     
        end
    end 
    return total 
end 

-- ================= CORE =================
local PetEvent_timestamp = HL.GetTime() 

local function UpdatePetSlots()
    PetEvent_timestamp = HL.GetTime() 
    local display_error = false    
    for k, v in pairs(oPetSlots[RubimRH.playerSpec]) do            
        if v == 0 then 
            for i = 1, 120 do 
                actionType, id, subType = GetActionInfo(i)
                if subType == "pet" and k == id then 
                    oPetSlots[RubimRH.playerSpec][k] = i 
                    break 
                end 
                if i == 120 then 
                    display_error = true
                end 
            end
        end
    end        
    -- Display errors 
    if display_error then 
        print(HL.GetTime() .. ": The following spells missed on your action bars:")
        print("Note: PetActionBar doesn't work, you need place following pet spells to normal any slot on any action bar")
        for k, v in pairs(oPetSlots[RubimRH.playerSpec]) do
            if v == 0 then
                print(GetSpellInfo(k) .. " is not found on your action bar")
            end                
        end 
    end       
end 

RubimRH.Listener:Add('PetSlots_Events', "UNIT_PET", function(...)
        if oPetSlots[RubimRH.playerSpec] and  ... == "player" and (PetHasActionBar() or GetPetActionsUsable()) and HL.GetTime() ~= PetEvent_timestamp then     
            for k, v in pairs(oPetSlots[RubimRH.playerSpec]) do
                if v == 0 then 
                    UpdatePetSlots()
                    break
                end
            end                 
        end 
end)

RubimRH.Listener:Add('PetSlots_Events', "ACTIONBAR_SLOT_CHANGED", function(...)
        if oPetSlots[RubimRH.playerSpec] and (PetHasActionBar() or GetPetActionsUsable()) and HL.GetTime() ~= PetEvent_timestamp then
            for k, v in pairs(oPetSlots[RubimRH.playerSpec]) do
                if v == 0 or v == ... then 
                    oPetSlots[RubimRH.playerSpec][k] = 0
                    UseUpdate = true 
                end
            end         
            if UseUpdate then 
                UpdatePetSlots()
            end
        end 
end)

-- Enter game 
if RubimRH.playerSpec and oPetSlots[RubimRH.playerSpec] then 
    UpdatePetSlots()
end 

--- =========================== Listener ===========================
Listener, listeners = {}, {}
local frame = CreateFrame('Frame', 'Listener_Events')
frame:SetScript('OnEvent', function(_, event, ...)
        if not listeners[event] then return end
        for k in pairs(listeners[event]) do
            if k == "Stuff_Events" then 
                listeners[event][k](event, ...)
            else 
                listeners[event][k](...)
            end
        end
end)

function Listener.Add(_, name, event, callback)
    if not listeners[event] then
        frame:RegisterEvent(event)
        listeners[event] = {}
    end
    if not listeners[event][name] then 
        listeners[event][name] = callback
    end 
end

function Listener.Remove(_, name, event)
    if listeners[event] then
        listeners[event][name] = nil
    end
end

function Listener.Trigger(_, event, ...)
    onEvent(nil, event, ...)
end
RubimRH.Listener:Add('Rubim_Events', "CHAT_MSG_ADDON", RubimRH.CurrentPullTimer)

C_ChatInfo.RegisterAddonMessagePrefix("BigWigs")
C_ChatInfo.RegisterAddonMessagePrefix("D4") -- DBM

-- DBM & BW Pull Timer
--local CurrentPullTimer = 0
--local f = CreateFrame("FRAME");
--    f:RegisterEvent("CHAT_MSG_ADDON");
--    f:SetScript("OnEvent", function(self, event, ...)
--    if event == "CHAT_MSG_ADDON" then
     -- Handling code here
--  	    local prefix, message = ...
--	    if prefix == "D4" and string.find(message, "PT") then
--  	        CurrentPullTimer = GetTime() + tonumber(string.sub(message, 4, 5))
--	    elseif prefix == "BigWigs" and string.find(message, "Pull") then
--	    	CurrentPullTimer = GetTime() + tonumber(string.sub(message, 8, 9))
--	    end
--    end
--end)
-- Returning result
--function RubimRH.GetCurrentPT()
--    if CurrentPullTimer ~= nil then
--        return GetTime() - CurrentPullTimer
--    end
--    return 0
--end


--- 16.03.2019
--- DBM Functions
--- ============================= CORE ==============================
local function DBM_timer_init()
    if not DBM then
        function RubimRH.DBM_GetTimeRemaining()
            return 0, 0
        end
        
        return
    end
    
    local Timers = {}
    DBM:RegisterCallback("DBM_TimerStart", function(_, id, text, timerRaw)
            -- Older versions of DBM return this value as a string:
            local duration
            if type(timerRaw) == "string" then
                duration = tonumber(timerRaw:match("%d+"))
            else
                duration = timerRaw
            end
            
            Timers[id] = {text = text:lower(), start = HL.GetTime(), duration = duration}          
    end)
    DBM:RegisterCallback("DBM_TimerStop", function(_, id) Timers[id] = nil end)
    
    
    function RubimRH.DBM_GetTimeRemaining(text)        
        for id, t in pairs(Timers) do            
            if t.text:match(text) then
                local expirationTime = t.start + t.duration
                local remaining = (expirationTime) - HL.GetTime()
                if remaining < 0 then remaining = 0 end
                
                return remaining, expirationTime
            end
        end

        return 0, 0
    end
end
 
local function DBM_engaged_init()
    if not DBM then
        function RubimRH.DBM_IsBossEngaged()
            return false
        end
        
        return
    end
    
    local EngagedBosses = {}
    hooksecurefunc(DBM, "StartCombat", function(DBM, mod, delay, event)
            if event ~= "TIMER_RECOVERY" then
                EngagedBosses[mod] = true            
            end
    end)
    hooksecurefunc(DBM, "EndCombat", function(DBM, mod)
            EngagedBosses[mod] = nil            
    end)
    
    
    function RubimRH.DBM_IsBossEngaged(bossName)
        for mod in pairs(EngagedBosses) do
            
            if mod.localization.general.name:lower():match(bossName) or mod.id:lower():match(bossName) then
                return mod.inCombat and true or false
            end
        end
        
        return false
    end
end

if not RubimRH.DBM_GetTimeRemaining then 
	DBM_timer_init()
end 

if not RubimRH.DBM_IsBossEngaged then
	DBM_engaged_init()
end 

--- ========================== FUNCTIONAL ===========================
-- Note: /dbm pull <5>
-- Note: /dbm timer <10> <Name>
function RubimRH.DBM_PullTimer()
    local name = DBM_CORE_TIMER_PULL:lower()   
    return RubimRH.DBM_GetTimeRemaining(name)
end 

function RubimRH.DBM_GetTimer(name)
    --local timername = format("%q", name:gsub("([%(%)%%%[%]%-%+%*%.%^%$])", "%%%1"):lower())        
    local timername = name:lower()
    return RubimRH.DBM_GetTimeRemaining(timername)
end 

function RubimRH.DBM_IsEngage()
    -- Not tested  
    local BossName = UnitName("boss1")
    local name = BossName and format("%q", BossName:gsub("%%", "%%%%"):lower())
    return name and RubimRH.DBM_IsBossEngaged(name) or false
end 