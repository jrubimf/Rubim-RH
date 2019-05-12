--- 2.0
--- DateTime: 02.04.2019
---
--- ============================ HEADER ============================
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
local LibRangeCheck = LibStub("LibRangeCheck-2.0")
local IsSpellInRange = LibStub("SpellRange-1.0").IsSpellInRange


local pairs, next = pairs, next
local UnitIsPlayer, UnitExists, UnitGUID = UnitIsPlayer, UnitExists, UnitGUID
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

--- ============================ CONTENT ============================
function dynamic_array(dimension)
    local metatable = {}
    for i=1, dimension do
        metatable[i] = {__index = function(tbl, key)
                if i < dimension then
                    tbl[key] = setmetatable({}, metatable[i+1])
                    return tbl[key]
                end
            end
        }
    end
    return setmetatable({}, metatable[1]);
end

local activeUnitPlates = dynamic_array(2)

local function AddNameplate(unitID)
    local nameplate = GetNamePlateForUnit(unitID)
    local unitframe = nameplate.UnitFrame  
    local reaction = "enemy" or "friendly"
    if unitframe and unitID then 
        activeUnitPlates[reaction][unitframe] = unitID
    end
end

local function RemoveNameplate(unitID)
    local nameplate = GetNamePlateForUnit(unitID)
    local unitframe = nameplate.UnitFrame
    if unitframe then
        activeUnitPlates["enemy"][unitframe] = nil  
        activeUnitPlates["friendly"][unitframe] = nil 
    end     
end

-- For refference 
function GetActiveUnitPlates(reaction)
    return activeUnitPlates[reaction] or nil
end 

--- ========================== FUNCTIONAL ===========================
-- For Tank 
function PvPMassTaunt(stop, range, outrange)
    local totalmobs = 0
    if not range then range = 40 end;   
    if not outrange then outrange = 8 end; 
    if activeUnitPlates["enemy"] then        
        for reference, unit in pairs(activeUnitPlates["enemy"]) do
            if 
            UnitIsPlayer(unit) and 
            RubimRH.UNITRange(unit) >= outrange and         
            RubimRH.SpellInteract(unit, range) then 
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

function MassTaunt(stop, range, ttd)
    local totalmobs = 0 
    if not range then range = 40 end;   
    if not ttd then ttd = 10 end; 
    if activeUnitPlates["enemy"] then
        for reference, unit in pairs(activeUnitPlates["enemy"]) do
            if 
            CombatTime(unit) > 0 and 
            Target:TimeToDie() >= ttd and 
            RubimRH.UNITLevel(unit) ~= -1 and 
            RubimRH.SpellInteract(unit, range) and 
            UnitExists(unit .. "target") and
            not RubimRH.UNITRole(unit .. "target", "TANK") then 
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

--[[ Returns the total ammount of time a unit is in-combat for ]]
function CombatTime(UNIT)
    if not UNIT then UNIT = "player" end;    
    local GUID = UnitGUID(UNIT)     
    if Data[GUID] and InCombatLockdown() then
        local combatTime = HL.GetTime() - Data[GUID].combat_time       
        return combatTime              
    end
    return 0
end

RubimRH.ModifiedUnitSpecs = {}

function RubimRH.UNITSpec(unitID, specs)  
    local found
    local name, server = UnitName(unitID)
    if name then
        name = name .. (server and "-" .. server or "")
    else 
        return false 
    end       
    
    if type(specs) == "table" then        
        for i = 1, #specs do
            if unitID == "player" then
                found = specs[i] == RubimRH.PlayerSpec
            else
                found = RubimRH.ModifiedUnitSpecs and RubimRH.ModifiedUnitSpecs[name] and specs[i] == RubimRH.ModifiedUnitSpecs[name]
            end
            
            if found then
                break
            end
        end       
    else
        if unitID == "player" then
            found = specs == RubimRH.PlayerSpec 
        else 
            found = RubimRH.ModifiedUnitSpecs and RubimRH.ModifiedUnitSpecs[name] and specs == RubimRH.ModifiedUnitSpecs[name] 
        end       
    end
    
    return found or false
end

function RubimRH.UNITRange(unitID)
    local _, range = LibRangeCheck:GetRange(unitID)
    if not range then range = 0 end;
    return range
end

function RubimRH.SpellInteract(unit, range)  
    if not Unit then 
        return false 
    end    
    local cur_range = RubimRH.UNITRange(unit)
    -- Holy Paladin Talent Range buff +50%
    if RubimRH.UNITSpec("player", 65) and RubimRH.Buffs("player", 214202, "player") > 0 then range = range * 1.5 end;
    -- Moonkin and Restor +5 yards
    if RubimRH.UNITSpec("player", 102) or (RubimRH.UNITSpec("player", 105) and RubimRH.TalentLearn(197488)) then range = range + 5 end;  
    -- Feral and Guardian +3 yards
    if (RubimRH.UNITSpec("player", 103) or RubimRH.UNITSpec("player", 104)) and RubimRH.TalentLearn(197488) then range = range + 3 end;
    return cur_range and cur_range > 0 and cur_range <= range
end

function RubimRH.SpellExists(spell)   
    local id = GetSpellInfo(spell)           
    return GetSpellBookItemInfo(id) or IsPlayerSpell(spell)    
end

function RubimRH.AuraDur(unit, name, filter)
	local buffName, _, duration, expirationTime, id 
	for i = 1, huge do
		buffName, _, _, _, duration, expirationTime, _, _, _, id = UnitAura(unit, i, filter)
		if not id or id == name or strlowerCache[buffName] == name then
			break
		end
	end
	
	if not buffName then
		return 0, 0, 0
	else
		return expirationTime == 0 and huge or expirationTime - HL.GetTime(), duration, expirationTime
	end
end

function RubimRH.SortDeBuffs(unitID, spell, source, byID)
    local dur, duration
    local filter = "HARMFUL" .. (source and " PLAYER" or "")    
    
    if type(spell) == "table" then
        local SortTable = {} 
        
        for i = 1, #spell do            
            dur, duration = RubimRH.AuraDur(unitID, not byID and not IDexception[i] and strlowerCache[GetSpellInfo(spell[i])] or spell[i], filter)                       
            if dur > 0 then
                table.insert(SortTable, {dur, duration})
            end
        end    
        
        if #SortTable > 0 then 
            ArraySortByColl(SortTable, 1)   
            return SortTable[1][1], SortTable[1][2]   
        end 
    else
        dur, duration = RubimRH.AuraDur(unitID, not byID and not IDexception[spell] and strlowerCache[GetSpellInfo(spell)] or spell, filter)
    end   
    
    return dur, duration       
end

-- return nil, need to fix, using DebuffRemains instead
function RubimRH.HasDeBuffs(self, key, caster)
    local value, duration = 0, 0
     -- Cyclone behavior
	-- if Env.Unit(self.UnitID):DeBuffCyclone() > 0 then 
    --     value, duration = -1, -1
    -- else
        value, duration = RubimRH.SortDeBuffs(self.UnitID, ((type(key) == "string" and AuraList[key]) or key), caster) 
   
    return value, duration   
end

-- Multi DoTs
-- Missed dots on valid targets (only NUMERIC returns!!)
function MultiDots(range, dots, ttd, stop)
    local totalmobs = 0 
    if activeUnitPlates["enemy"] then
        for reference, unit in pairs(activeUnitPlates["enemy"]) do
            if 
            CombatTime(unit) > 0 and 
            UnitLevel(unit) ~= -1 and 
            --( not RubimRH.InPvP() or UnitIsPlayer(unit)) and
            ( not ttd or Target:TimeToDie() >= ttd ) and 
            ( not range or RubimRH.SpellInteract(unit, range)) and 
            --Unit(unit):HasDeBuffs(dots, "player") == 0 then  
            Unit(unit):DebuffRemains(dots) < 1 then  			
                totalmobs = totalmobs + 1            
                
                if stop and totalmobs >= stop then
                    break
                end    
            end
        end   
    end    
    return totalmobs
end

-- Applied dots on valid targets 
function UnitsDots(stop, dots, range, ttd)
    local totalmobs = 0   
    if activeUnitPlates["enemy"] then
        for reference, unit in pairs(activeUnitPlates["enemy"]) do
            if 
            CombatTime(unit) > 0 and 
            ( not ttd or Target:TimeToDie() >= ttd ) and 
            UnitLevel(unit) ~= -1 and 
            Unit(unit):HasDeBuffs(dots, "player") > 0 and 
            ( not range or RubimRH.SpellInteract(unit, range) ) then                 
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

-- Units 
-- AutoTarget 
function CombatUnits(stop, range, upttd)
    local totalmobs = 0   
    if activeUnitPlates["enemy"] then
        for reference, unit in pairs(activeUnitPlates["enemy"]) do
            if 
            CombatTime(unit) > 0 and 
            ( not range or RubimRH.SpellInteract(unit, range) ) and 
            ( not upttd or Target:TimeToDie() >= upttd ) then 
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

function CastingUnits(stop, range, kickAble)
    local totalmobs = 0
    if not range then range = 40 end;   
    if activeUnitPlates["enemy"] then
        for reference, unit in pairs(activeUnitPlates["enemy"]) do
            local current, _, _, _, notInterruptable = select(2, RubimRH.CastTime(nil, unit))
            if 
            current > 0 and
            ( not kickAble or not notInterruptable ) and 
            CombatTime(unit) > 0 and 
            UnitLevel(unit) ~= -1 and             
            RubimRH.SpellInteract(unit, range) then 
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

-- Checking by spell
local function GetMobsBySpell(count, spellId, reaction)
    local totalmobs = 0
    for reference, unit in pairs(activeUnitPlates[reaction]) do
        if RubimRH.SpellInRange(unit, spellId) then
            totalmobs = totalmobs + 1            
            if count and type(count) == "number" and totalmobs >= count then                
                break                
            end              
        end
    end    
    return totalmobs
end

-- Checking by range
local function GetMobsByRange(count, range, reaction)
    local totalmobs = 0
    for reference, unit in pairs(activeUnitPlates[reaction]) do
        if RubimRH.SpellInteract(unit, range) then
            totalmobs = totalmobs + 1            
            if count and type(count) == "number" and totalmobs >= count then                
                break            
            end        
        end
    end   
    return totalmobs
end

-- General result (usually melee usage / or range if active_enemies is empty)
-- TODO: Make another cache
local mobs = { ["friendly"] = {}, ["enemy"] = {} }
function AoE(count, num, type) 
    if not type then type = "enemy" end  
    if not num then num = 40 end 
    if not count then count = "" end
    -- If last refresh for these arguments wasn't early than 0.2 (global) timer then update it 
    if fLastCall("AoE" .. count .. num .. type) then  
        -- FPS saver, prevent refresh with same arguments by preset time       
        oLastCall["AoE" .. count .. num .. type] = HL.GetTime() + oLastCall["global"]               
        
        if num < 100 then
            mobs[type][count .. num] = GetMobsByRange(count, num, type)
        else 
            mobs[type][count .. num] = GetMobsBySpell(count, num, type)
        end                         
    end       
    
    if not count or count == "" then
        return mobs[type][count .. num] or 0
    else
        return mobs[type][count .. num] and mobs[type][count .. num] >= count
    end    
end

-- Range
local logUnits, activeUnits = {}, {}
local function ActiveEnemiesCLEU(...)
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
end 

local function ActiveEnemiesUpdate()
    if RubimRH.PlayerSpec then 
        local RangeSpec = {102, 253, 254, 62, 63, 64, 258, 262, 265, 266, 267}
        
        for i = 1, #RangeSpec do 
            if RubimRH.PlayerSpec == RangeSpec[i] then 
                RubimRH.Listener:Add('Active_Enemies', "COMBAT_LOG_EVENT_UNFILTERED", ActiveEnemiesCLEU)
                RubimRH.Listener:Add('Active_Enemies', 'PLAYER_REGEN_ENABLED', function()
                        if not InCombatLockdown() and not UnitAffectingCombat("player") then
                            wipe(logUnits)
                            wipe(activeUnits)            
                        end        
                end)
                RubimRH.Listener:Add('Active_Enemies', 'PLAYER_REGEN_DISABLED', function()
                        if HL.GetTime() - SpellLastCast("player", RubimRH.LastPlayerCastID) > 0.5 then 
                            wipe(logUnits)
                            wipe(activeUnits)
                        end 
                end)
                return 
            end 
        end 
        
        wipe(logUnits)
        wipe(activeUnits)
        RubimRH.Listener:Remove('Active_Enemies', "COMBAT_LOG_EVENT_UNFILTERED")
        RubimRH.Listener:Remove('PLAYER_REGEN_ENABLED', "COMBAT_LOG_EVENT_UNFILTERED")
        RubimRH.Listener:Remove('PLAYER_REGEN_DISABLED', "COMBAT_LOG_EVENT_UNFILTERED")
    end 
end 

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

RubimRH.Listener:Add('Active_Enemies', "PLAYER_ENTERING_WORLD", ActiveEnemiesUpdate)
RubimRH.Listener:Add('Active_Enemies', "UPDATE_INSTANCE_INFO", ActiveEnemiesUpdate)
RubimRH.Listener:Add('Active_Enemies', "PLAYER_SPECIALIZATION_CHANGED", ActiveEnemiesUpdate)
RubimRH.Listener:Add('Active_Enemies', "PLAYER_TALENT_UPDATE", ActiveEnemiesUpdate)

RubimRH.Listener:Add('Rubim_Events', 'PLAYER_ENTERING_WORLD', function()
        wipe(activeUnitPlates)  
        -- TODO: Make another cache
        mobs = { ["friendly"] = {}, ["enemy"] = {} }
        oLastCall = { ["global"] = 0.2 }
end) 
RubimRH.Listener:Add('Rubim_Events', 'UPDATE_INSTANCE_INFO', function()
        wipe(activeUnitPlates)
        -- TODO: Make another cache
        mobs = { ["friendly"] = {}, ["enemy"] = {} }
        oLastCall = { ["global"] = 0.2 }
end) 
RubimRH.Listener:Add('Rubim_Events', 'PLAYER_REGEN_DISABLED', function()
        -- TODO: Make another cache
        mobs = { ["friendly"] = {}, ["enemy"] = {} }
        oLastCall = { ["global"] = 0.2 }
end)
RubimRH.Listener:Add('Rubim_Events', 'NAME_PLATE_UNIT_ADDED', AddNameplate)
RubimRH.Listener:Add('Rubim_Events', 'NAME_PLATE_UNIT_REMOVED', RemoveNameplate)

