local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item
local mainAddon = RubimRH;
---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by
--- DateTime: 19/06/2018 09:18
---
local pairs = pairs

local UnitHealthMax, UnitHealth, UnitGUID, UnitAffectingCombat, UnitExists, UnitGetTotalAbsorbs = 
UnitHealthMax, UnitHealth, UnitGUID, UnitAffectingCombat, UnitExists, UnitGetTotalAbsorbs

local GetSpellInfo = GetSpellInfo

local InCombatLockdown, CombatLogGetCurrentEventInfo = InCombatLockdown, CombatLogGetCurrentEventInfo

--- Imported
Data = {}

-- Thse are Mixed Damage types (magic and pysichal)
local Doubles = {
    [3]   = 'Holy + Physical',
    [5]   = 'Fire + Physical',
    [9]   = 'Nature + Physical',
    [17]  = 'Frost + Physical',
    [33]  = 'Shadow + Physical',
    [65]  = 'Arcane + Physical',
    [127] = 'Arcane + Shadow + Frost + Nature + Fire + Holy + Physical',
}

local function addToData(GUID)
    if not Data[GUID] then
        Data[GUID] = {
            -- Real Damage 
            RealDMG = { 
                -- Damage Taken  
                LastHit_Taken = 0,                             
                dmgTaken = 0,
                dmgTaken_S = 0,
                dmgTaken_P = 0,
                dmgTaken_M = 0,
                hits_taken = 0,                
                -- Damage Done
                LastHit_Done = 0,  
                dmgDone = 0,
                dmgDone_S = 0,
                dmgDone_P = 0,
                dmgDone_M = 0,
                hits_done = 0,
            },  
            -- Sustain Damage 
            DMG = {
                -- Damage Taken
                dmgTaken = 0,
                dmgTaken_S = 0,
                dmgTaken_P = 0,
                dmgTaken_M = 0,
                hits_taken = 0,
                lastHit_taken = 0,
                -- Damage Done
                dmgDone = 0,
                dmgDone_S = 0,
                dmgDone_P = 0,
                dmgDone_M = 0,
                hits_done = 0,
                lastHit_done = 0,
            },
            -- Sustain Healing 
            HPS = {
                -- Healing taken
                heal_taken = 0,
                heal_hits_taken = 0,
                heal_lasttime = 0,
                -- Healing Done
                heal_done = 0,
                heal_hits_done = 0,
                heal_lasttime_done = 0,
            },
            -- DS: Last N sec (Only Taken) 
            DS = {},
            -- Absorb (Only Taken)       
            absorb_spells = dynamic_array(2),
            -- Shared 
            combat_time = GetTime(),
            spell_value = {},
			lastSwing = GetTime(),
            spell_lastcast_time = {},
            spell_counter = {},
        }
    end
end

--[[ This Logs the damage for every unit ]]
local logDamage = function(...)
    local _,_,_, SourceGUID, _,_,_, DestGUID, _,_,_, spellID, _, school, Amount, a, b, c = CombatLogGetCurrentEventInfo()
    -- Update last hit time
    -- Taken 
    Data[DestGUID].DMG.lastHit_taken = GetTime()
    -- Done 
    Data[SourceGUID].DMG.lastHit_done = GetTime()
    -- Filter by School   
    if Doubles[school] then
        -- Taken 
        Data[DestGUID].DMG.dmgTaken_P = Data[DestGUID].DMG.dmgTaken_P + Amount
        Data[DestGUID].DMG.dmgTaken_M = Data[DestGUID].DMG.dmgTaken_M + Amount
        -- Done 
        Data[SourceGUID].DMG.dmgDone_P = Data[SourceGUID].DMG.dmgDone_P + Amount
        Data[SourceGUID].DMG.dmgDone_M = Data[SourceGUID].DMG.dmgDone_M + Amount
        -- Real Time Damage 
        Data[DestGUID].RealDMG.dmgTaken_P = Data[DestGUID].RealDMG.dmgTaken_P + Amount
        Data[DestGUID].RealDMG.dmgTaken_M = Data[DestGUID].RealDMG.dmgTaken_M + Amount
        Data[SourceGUID].DMG.dmgDone_P = Data[SourceGUID].DMG.dmgDone_P + Amount
        Data[SourceGUID].DMG.dmgDone_M = Data[SourceGUID].DMG.dmgDone_M + Amount        
    elseif school == 1  then
        -- Pysichal
        -- Taken 
        Data[DestGUID].DMG.dmgTaken_P = Data[DestGUID].DMG.dmgTaken_P + Amount
        -- Done 
        Data[SourceGUID].DMG.dmgDone_P = Data[SourceGUID].DMG.dmgDone_P + Amount
        -- Real Time Damage 
        Data[DestGUID].RealDMG.dmgTaken_P = Data[DestGUID].RealDMG.dmgTaken_P + Amount        
        Data[SourceGUID].DMG.dmgDone_P = Data[SourceGUID].DMG.dmgDone_P + Amount        
    else
        -- Magic
        -- Taken
        Data[DestGUID].DMG.dmgTaken_M = Data[DestGUID].DMG.dmgTaken_M + Amount
        -- Done 
        Data[SourceGUID].DMG.dmgDone_M = Data[SourceGUID].DMG.dmgDone_M + Amount
        -- Real Time Damage        
        Data[DestGUID].RealDMG.dmgTaken_M = Data[DestGUID].RealDMG.dmgTaken_M + Amount        
        Data[SourceGUID].DMG.dmgDone_M = Data[SourceGUID].DMG.dmgDone_M + Amount
    end
    -- Totals
    -- Taken 
    Data[DestGUID].DMG.dmgTaken = Data[DestGUID].DMG.dmgTaken + Amount
    Data[DestGUID].DMG.hits_taken = Data[DestGUID].DMG.hits_taken + 1   
    -- Done 
    Data[SourceGUID].DMG.hits_done = Data[SourceGUID].DMG.hits_done + 1
    Data[SourceGUID].DMG.dmgDone = Data[SourceGUID].DMG.dmgDone + Amount
    -- Spells (Only Taken)
    local prev = (Data[DestGUID].spell_value[spellID] and Data[DestGUID].spell_value[spellID].Amount) or 0
    Data[DestGUID].spell_value[spellID] = {Amount = prev + Amount, TIME = GetTime()}
    -- Real Time Damage 
    -- Taken
    Data[DestGUID].RealDMG.LastHit_Taken = GetTime()     
    Data[DestGUID].RealDMG.dmgTaken = Data[DestGUID].RealDMG.dmgTaken + Amount
    Data[DestGUID].RealDMG.hits_taken = Data[DestGUID].RealDMG.hits_taken + 1 
    -- Done 
    Data[SourceGUID].RealDMG.LastHit_Done = GetTime()     
    Data[SourceGUID].RealDMG.dmgDone = Data[SourceGUID].RealDMG.dmgDone + Amount
    Data[SourceGUID].RealDMG.hits_done = Data[SourceGUID].RealDMG.hits_done + 1 
    -- DS (Only Taken)
    table.insert(Data[DestGUID].DS, {TIME = GetTime(), Amount = Amount})
end

--[[ This Logs the swings (damage) for every unit ]]
local logSwing = function(...)
    local _,_,_, SourceGUID, _,_,_, DestGUID, _,_,_, Amount = CombatLogGetCurrentEventInfo()
    -- Update last  hit time
    Data[DestGUID].DMG.lastHit_taken = GetTime()
    Data[SourceGUID].DMG.lastHit_done = GetTime()
    -- Damage 
    Data[DestGUID].DMG.dmgTaken_P = Data[DestGUID].DMG.dmgTaken_P + Amount
    Data[DestGUID].DMG.dmgTaken = Data[DestGUID].DMG.dmgTaken + Amount
    Data[DestGUID].DMG.hits_taken = Data[DestGUID].DMG.hits_taken + 1
    Data[SourceGUID].DMG.dmgDone_P = Data[SourceGUID].DMG.dmgDone_P + Amount
    Data[SourceGUID].DMG.dmgDone = Data[SourceGUID].DMG.dmgDone + Amount
    Data[SourceGUID].DMG.hits_done = Data[SourceGUID].DMG.hits_done + 1
    -- Real Time Damage 
    -- Taken
    Data[DestGUID].RealDMG.LastHit_Taken = GetTime() 
    Data[DestGUID].RealDMG.dmgTaken_S = Data[DestGUID].RealDMG.dmgTaken_S + Amount
    Data[DestGUID].RealDMG.dmgTaken_P = Data[DestGUID].RealDMG.dmgTaken_P + Amount
    Data[DestGUID].RealDMG.dmgTaken = Data[DestGUID].RealDMG.dmgTaken + Amount
    Data[DestGUID].RealDMG.hits_taken = Data[DestGUID].RealDMG.hits_taken + 1  
    -- Done 
    Data[SourceGUID].RealDMG.LastHit_Done = GetTime()     
    Data[SourceGUID].RealDMG.dmgDone_S = Data[SourceGUID].RealDMG.dmgDone_S + Amount
    Data[SourceGUID].RealDMG.dmgDone_P = Data[SourceGUID].RealDMG.dmgDone_P + Amount   
    Data[SourceGUID].RealDMG.dmgDone = Data[SourceGUID].RealDMG.dmgDone + Amount
    Data[SourceGUID].RealDMG.hits_done = Data[SourceGUID].RealDMG.hits_done + 1 
    -- DS (Only Taken)
    table.insert(Data[DestGUID].DS, {TIME = GetTime(), Amount = Amount})
end

--[[ This Logs the healing for every unit ]]
local logHealing = function(...)
    local _,_,_, SourceGUID, _,_,_, DestGUID, _,_,_, spellID, _,_, Amount = CombatLogGetCurrentEventInfo()
    -- Update last  hit time
    -- Taken 
    Data[DestGUID].HPS.heal_lasttime = GetTime()
    -- Done 
    Data[SourceGUID].HPS.heal_lasttime_done = GetTime()
    -- Totals    
    -- Taken 
    Data[DestGUID].HPS.heal_taken = Data[DestGUID].HPS.heal_taken + Amount
    Data[DestGUID].HPS.heal_hits_taken = Data[DestGUID].HPS.heal_hits_taken + 1
    -- Done   
    Data[SourceGUID].HPS.heal_done = Data[SourceGUID].HPS.heal_done + Amount
    Data[SourceGUID].HPS.heal_hits_done = Data[SourceGUID].HPS.heal_hits_done + 1   
    -- Spells (Only Taken)
    local prev = (Data[DestGUID].spell_value[spellID] and Data[DestGUID].spell_value[spellID].Amount) or 0
    Data[DestGUID].spell_value[spellID] = {Amount = prev + Amount, TIME = GetTime()} 
end

--[[ This Logs the shields for every unit ]]
local logAbsorb = function(...)
    local _,_,_, SourceGUID, _,_,_, DestGUID, DestName,_,_, spellID, spellName,_, auraType, Amount = CombatLogGetCurrentEventInfo()    
    if auraType == "BUFF" and Amount then
        Data[DestGUID].absorb_spells[spellName]["Amount"] = Amount      
    end    
end

local remove_logAbsorb = function(...)
    local _,_,_, SourceGUID, _,_,_, DestGUID, DestName,_,_, spellID, spellName,_, auraType, Amount = CombatLogGetCurrentEventInfo()
    if auraType == "BUFF" and Amount then
        Data[DestGUID].absorb_spells[spellName]["Amount"] = nil               
    end
end

--[[ This Logs the last cast and amount for every unit ]]
local logLastCast = function(...)
    local _,_,_, SourceGUID, _,_,_, DestGUID, DestName,_,_, spellID, spellName = CombatLogGetCurrentEventInfo()
    -- LastCast time
    Data[SourceGUID].spell_lastcast_time[spellID] = GetTime() 
    Data[SourceGUID].spell_lastcast_time[spellName] = GetTime() 
    -- Counter 
    Data[SourceGUID].spell_counter[spellID] = (not Data[SourceGUID].spell_counter[spellID] and 1) or (Data[SourceGUID].spell_counter[spellID] + 1)
    Data[SourceGUID].spell_counter[spellName] = (not Data[SourceGUID].spell_counter[spellName] and 1) or (Data[SourceGUID].spell_counter[spellName] + 1)
end 

--[[ These are the events we're looking for and its respective action ]]
local EVENTS = {
    ['SPELL_DAMAGE'] = logDamage,
    ['DAMAGE_SHIELD'] = logDamage,
    ['SPELL_PERIODIC_DAMAGE'] = logDamage,
    ['SPELL_BUILDING_DAMAGE'] = logDamage,
    ['RANGE_DAMAGE'] = logDamage,
    ['SWING_DAMAGE'] = logSwing,
    ['SPELL_HEAL'] = logHealing,
    ['SPELL_PERIODIC_HEAL'] = logHealing,
    ['SPELL_AURA_APPLIED'] = logAbsorb,   
    ['SPELL_AURA_REFRESH'] = logAbsorb,  
    ['SPELL_AURA_REMOVED'] = remove_logAbsorb,  
    ['SPELL_CAST_SUCCESS'] = logLastCast,
    ['UNIT_DIED'] = function(...) Data[select(8, CombatLogGetCurrentEventInfo())] = nil end,
}

--[[ Returns the total ammount of time a unit is in-combat for ]]
function RubimRH.CombatTime(UNIT)
    if not UNIT then UNIT = "player" end;    
    local GUID = UnitGUID(UNIT)     
    if Data[GUID] and InCombatLockdown() then
        local combatTime = (GetTime() - Data[GUID].combat_time)      
        return combatTime              
    end
    return 0
end

--[[ Get RealTime DMG Taken ]]
function RubimRH.getRealTimeDMG(UNIT)
    local total, Hits, phys, magic, swing = 0, 0, 0, 0, 0
    local combatTime = RubimRH.CombatTime(UNIT)
    local GUID = UnitGUID(UNIT)
    if Data[GUID] and combatTime > 0 and Data[GUID].RealDMG.LastHit_Taken > 0 then 
        local realtime = GetTime() - Data[GUID].RealDMG.LastHit_Taken
        local Hits = Data[GUID].RealDMG.hits_taken        
        -- Remove a unit if it hasnt recived dmg for more then our gcd
        if realtime > Player:GCD() + 1 then 
            -- Damage Taken 
            Data[GUID].RealDMG.dmgTaken = 0
            Data[GUID].RealDMG.dmgTaken_S = 0
            Data[GUID].RealDMG.dmgTaken_P = 0
            Data[GUID].RealDMG.dmgTaken_M = 0
            Data[GUID].RealDMG.hits_taken = 0
            Data[GUID].RealDMG.lastHit_taken = 0  
        elseif Hits > 0 then                     
            total = Data[GUID].RealDMG.dmgTaken / Hits
            phys = Data[GUID].RealDMG.dmgTaken_P / Hits
            magic = Data[GUID].RealDMG.dmgTaken_M / Hits     
            swing = Data[GUID].RealDMG.dmgTaken_S / Hits 
        end
    end
    return total, Hits, phys, magic, swing
end

--[[ Get RealTime DMG Done ]]
function RubimRH.getRealTimeDPS(UNIT)
    local total, Hits, phys, magic, swing = 0, 0, 0, 0, 0
    local combatTime = RubimRH.CombatTime(UNIT)
    local GUID = UnitGUID(UNIT)
    if Data[GUID] and combatTime > 0 and Data[GUID].RealDMG.LastHit_Done > 0 then   
        local realtime = GetTime() - Data[GUID].RealDMG.LastHit_Done
        local Hits = Data[GUID].RealDMG.hits_done
        -- Remove a unit if it hasnt done dmg for more then our gcd
        if realtime > Player:GCD() + 1 then 
            -- Damage Done
            Data[GUID].RealDMG.dmgDone = 0
            Data[GUID].RealDMG.dmgDone_S = 0
            Data[GUID].RealDMG.dmgDone_P = 0
            Data[GUID].RealDMG.dmgDone_M = 0
            Data[GUID].RealDMG.hits_done = 0
            Data[GUID].RealDMG.LastHit_Done = 0 
        elseif Hits > 0 then                         
            total = Data[GUID].RealDMG.dmgDone / Hits
            phys = Data[GUID].RealDMG.dmgDone_P / Hits
            magic = Data[GUID].RealDMG.dmgDone_M / Hits  
            swing = Data[GUID].RealDMG.dmgDone_S / Hits 
        end
    end
    return total, Hits, phys, magic, swing
end

--[[ Get DMG Taken ]]
function RubimRH.getDMG(UNIT)
    local total, Hits, phys, magic = 0, 0, 0, 0
    local GUID = UnitGUID(UNIT)
    if Data[GUID] then
        local combatTime = RubimRH.CombatTime(UNIT)
        -- Remove a unit if it hasn't recived dmg for more then 5 sec
        if GetTime() - Data[GUID].DMG.lastHit_taken > 5 then   
            -- Damage Taken 
            Data[GUID].DMG.dmgTaken = 0
            Data[GUID].DMG.dmgTaken_S = 0
            Data[GUID].DMG.dmgTaken_P = 0
            Data[GUID].DMG.dmgTaken_M = 0
            Data[GUID].DMG.hits_taken = 0
            Data[GUID].DMG.lastHit_taken = 0            
        elseif combatTime > 0 then
            total = Data[GUID].DMG.dmgTaken / combatTime
            phys = Data[GUID].DMG.dmgTaken_P / combatTime
            magic = Data[GUID].DMG.dmgTaken_M / combatTime
            Hits = Data[GUID].DMG.hits_taken or 0
        end
    end
    return total, Hits, phys, magic 
end

--[[ Get DMG Done ]]
function RubimRH.getDPS(UNIT)
    local total, Hits, phys, magic = 0, 0, 0, 0
    local GUID = UnitGUID(UNIT)
    if Data[GUID] then
        local Hits = Data[GUID].DMG.hits_done
        --local combatTime = RubimRH.CombatTime(UNIT)
        -- Remove a unit if it hasn't done dmg for more then 5 sec
        if GetTime() - Data[GUID].DMG.lastHit_done > 5 then                    
            -- Damage Done
            Data[GUID].DMG.dmgDone = 0
            Data[GUID].DMG.dmgDone_S = 0
            Data[GUID].DMG.dmgDone_P = 0
            Data[GUID].DMG.dmgDone_M = 0
            Data[GUID].DMG.hits_done = 0
            Data[GUID].DMG.lastHit_done = 0            
        elseif Hits > 0 then
            total = Data[GUID].DMG.dmgDone / Hits
            phys = Data[GUID].DMG.dmgDone_P / Hits
            magic = Data[GUID].DMG.dmgDone_M / Hits            
        end
    end
    return total, Hits, phys, magic
end

--[[ Get Heal Taken ]]
function RubimRH.getHEAL(UNIT)
    local total, Hits = 0, 0
    local GUID = UnitGUID(UNIT)   
    if Data[GUID] then
        local combatTime = RubimRH.CombatTime(UNIT)
        -- Remove a unit if it hasn't recived heal for more then 5 sec
        if GetTime() - Data[GUID].HPS.heal_lasttime > 5 then            
            -- Heal Taken 
            Data[GUID].HPS.heal_taken = 0
            Data[GUID].HPS.heal_hits_taken = 0
            Data[GUID].HPS.heal_lasttime = 0            
        elseif combatTime > 0 then
            Hits = Data[GUID].HPS.heal_hits_taken
            total = Data[GUID].HPS.heal_taken / Hits                              
        end
    end
    return total, Hits      
end

--[[ Get Heal Done ]]
function RubimRH.getHPS(UNIT) 
    local total, Hits = 0, 0
    local GUID = UnitGUID(UNIT)   
    if Data[GUID] then
        local Hits = Data[GUID].HPS.heal_hits_done
        --local combatTime = RubimRH.CombatTime(UNIT)
        -- Remove a unit if it hasn't done heal for more then 5 sec
        if GetTime() - Data[GUID].HPS.heal_lasttime_done > 5 then            
            -- Healing Done
            Data[GUID].HPS.heal_done = 0
            Data[GUID].HPS.heal_hits_done = 0
            Data[GUID].HPS.heal_lasttime_done = 0
        elseif Hits > 0 then             
            total = Data[GUID].HPS.heal_done / Hits 
        end
    end
    return total, Hits      
end 

--[[ Get Spell Amount Taken with time ]]
function RubimRH.getHealSpellAmount(UNIT, SPELL, timer)
    if not timer then timer = 5 end;
    local total = 0
    local GUID = UnitGUID(UNIT)   
    if Data[GUID] and Data[GUID].spell_value[SPELL] then
        if GetTime() - Data[GUID].spell_value[SPELL].TIME <= timer then 
            total = Data[GUID].spell_value[SPELL].Amount
        else
            Data[GUID].spell_value[SPELL] = nil
        end 
    end
    return total  
end

--[[ Get Heal Taken ]]
function RubimRH.getAbsorb(unit, spellID)
    local GUID = UnitGUID(unit)
    return (not spellID and UnitGetTotalAbsorbs(unit)) or (spellID and Data[GUID] and Data[GUID].absorb_spells[GetSpellInfo(spellID)]["Amount"]) or 0
end 

function RubimRH.TimeToDie(unit)
    local ttd = 0
    local DMG, Hits = RubimRH.getDMG(unit)
    if DMG >= 1 and Hits > 1 then
        ttd = UnitHealth(unit) / DMG
    end
    return ttd or 8675309
end

function RubimRH.LastCast(_, unit)
    local GUID = UnitGUID(unit)
    if Data[GUID] then
        return Data[GUID].lastcast
    end
end

function RubimRH.SpellDamage(_, unit, spellID)
    local GUID = UnitGUID(unit)
    return Data[GUID] and Data[GUID][spellID] or 0
end

RubimRH.Listener:Add('Rubim_Events', 'COMBAT_LOG_EVENT_UNFILTERED', function(...)
        local _, EVENT, _, SourceGUID, _,_,_, DestGUID = CombatLogGetCurrentEventInfo()
    -- Add the unit to our data if we dont have it
    addToData(SourceGUID)
    addToData(DestGUID)
    -- Update last  hit time
    Data[DestGUID].lastHit_taken = GetTime()
    Data[SourceGUID].lastHit_done = GetTime()
    -- Add the amount of dmg/heak
    if EVENTS[EVENT] then EVENTS[EVENT](...) end
end)

RubimRH.Listener:Add('Rubim_Events', 'PLAYER_REGEN_ENABLED', function()
    wipe(Data)
end)

RubimRH.Listener:Add('Rubim_Events', 'PLAYER_REGEN_DISABLED', function()
    wipe(Data)
end)

--- ========================== INCOMING ============================
-- DS 
function RubimRH.LastIncDMG(unit, seconds)
    if not seconds then seconds = 5 end;
    local GUID, Amount = UnitGUID(unit), 0    
    if Data[GUID] then        
        for i in pairs(Data[GUID].DS) do
            -- Remove old trash values to clear table 
            if Data[GUID].DS[i].TIME < GetTime() - 20 then 
                Data[GUID].DS[i] = nil 
            elseif Data[GUID].DS[i].TIME >= GetTime() - seconds then
                Amount = Amount + Data[GUID].DS[i].Amount 
            end
        end    
    end
    return Amount
end

RubimRH.last5secs = 0
function RubimRH.incdmg5secs(unit)
    if UnitExists(unit) then
        local pDMG = select(1, RubimRH.getDMG(unit))
        RubimRH.last5secs = pMDG
    end
    return 0
end    

function RubimRH.incdmg(unit)
    if UnitExists(unit) then
        local pDMG = select(1, RubimRH.getDMG(unit))
        return pDMG or 0
    end
    return 0
end

function RubimRH.incdmgphys(unit)
    if UnitExists(unit) then
        local pDMG = select(3, RubimRH.getDMG(unit))
        return pDMG
    end
    return 0
end

function RubimRH.incdmgswing(unit)
    if UnitExists(unit) then
        local mDMG = select(5, RubimRH.getDMG(unit))
        return mDMG
    end
    return 0
end

function RubimRH.lastSwing(unit)
    if not Player:AffectingCombat() then
        return 10000000000
    end
    if UnitExists(unit) then
        local sDMG = (GetTime() - Data[UnitGUID(unit)].lastSwing) or 10000000000
        return sDMG
    end
    return 10000000000
end

function RubimRH.incdmgmagic(unit)
    if UnitExists(unit) then
        local mDMG = select(4, RubimRH.getDMG(unit))
        return mDMG
    end
    return 0
end

function RubimRH.lastDmg5()
    if UnitExists("player") then
        local pDMG = (select(6, RubimRH.getDMG("player")) * 100) / UnitHealthMax("Player")
        return pDMG
    end
    return 0
end


--- ========================== LOS OF CONTROL ============================
local GetEventInfo = C_LossOfControl.GetEventInfo
local GetNumEvents = C_LossOfControl.GetNumEvents
local LossOfControl = {} 
--[[ 
Hex Schools:
0x1 Physical
0x2 Holy
0x4 Fire
0x8 Nature
0x10 Frost
0x20 Shadow
0x40 Arcane

locType:
BANISH
CHARM
CYCLONE
DAZE
DISARM
DISORIENT
DISTRACT
FREEZE
HORROR
INCAPACITATE
INTERRUPT
INVULNERABILITY
MAGICAL_IMMUNITY
PACIFY
PACIFYSILENCE -- "Disabled"
POLYMORPH
POSSESS
SAP
SHACKLE_UNDEAD
SLEEP
SNARE -- "Snared" slow usually example Concussive Shot
TURN_UNDEAD -- "Feared Undead" currently not usable in BFA PvP 
LOSECONTROL_TYPE_SCHOOLLOCK -- HAS SPECIAL HANDLING (per spell school) as "SCHOOL_INTERRUPT"
ROOT -- "Rooted"
CONFUSE -- "Confused" 
STUN -- "Stunned"
SILENCE -- "Silenced"
FEAR -- "Feared"
Usage: (string [required], string [only for "SCHOOL_INTERRUPT"], hex-number|table-hex-number [only for "SCHOOL_INTERRUPT"]
]]
function RubimRH.LossOfControlCreate(locType, name, ...)
    if locType == "SCHOOL_INTERRUPT" then 
        if not name then 
            print("[Debug Error] Can't create LossOfControl SCHOOL_INTERRUPT without name")
            return 
        elseif not ... then 
            print("[Debug Error] Can't create LossOfControl SCHOOL_INTERRUPT without hex values for school")
            return 
        end 
        
        if not LossOfControl[locType] then 
            LossOfControl[locType] = {}
        end         
        if not LossOfControl[locType][name] then 
            LossOfControl[locType][name] = {}
        end 
        
        LossOfControl[locType][name].hex = type(...) == "table" and bit.bxor(unpack(...)) or ...
        LossOfControl[locType][name].result = 0
    else 
        if LossOfControl[locType] then 
            print("[Debug Error] Attemp to create LossOfControl with already existed locType: " .. locType)
            return         
        end 
        LossOfControl[locType] = 0 
    end     
end 

function RubimRH.LossOfControlRemove(locType, name)
    if name then 
        LossOfControl[locType][name] = nil 
    else
        LossOfControl[locType] = nil 
    end 
end 

function RubimRH.LossOfControlGet(locType, name)
    local result = 0
    if not LossOfControl[locType] then
        print("[Debug Error] Trying get LossOfControl which is not exist: " .. locType)
        return result
    end
    
    if name then 
        result = LossOfControl[locType][name] and LossOfControl[locType][name].result or 0
    else 
        result = LossOfControl[locType]        
    end 
    
    return (GetTime() >= result and 0) or result - GetTime() 
end 

local LossOfControlUpdateElipse = 0
function RubimRH.LossOfControlUpdate()
    if GetTime() == LossOfControlUpdateElipse then
        return
    end
    LossOfControlUpdateElipse = GetTime()
    
    local isValidType = false
    for eventIndex = 1, GetNumEvents() do 
        local locType, spellID, text, _, start, timeRemaining, duration, lockoutSchool = GetEventInfo(eventIndex)      
        
        if locType == "SCHOOL_INTERRUPT" then
            -- Check that the user has requested the schools that are locked out.
            if LossOfControl[locType] and lockoutSchool and lockoutSchool ~= 0 then 
                for name in pairs(LossOfControl[locType]) do
                    local hex = LossOfControl[locType][name].hex -- v.hex                    
                    if hex and bit.band(lockoutSchool, hex) ~= 0 then
                        isValidType = true
                        LossOfControl[locType][name].result = (start or 0) + (duration or 0)
                    end
                end 
            end 
        else
            for name in pairs(LossOfControl) do 
                if _G["LOSS_OF_CONTROL_DISPLAY_" .. name] == text then 
                    -- Check that the user has requested the category that is active on the player.
                    isValidType = true
                    LossOfControl[locType] = (start or 0) + (duration or 0)
                    break 
                end 
            end 
        end
    end 
    
    -- Reset running durations.
    if not isValidType then 
        for name in pairs(LossOfControl) do 
            if type(name) ~= "table" and RubimRH.LossOfControlGet(name) > 0 then
                LossOfControl[name] = 0
            end            
        end
    end
end

--- PvP trinket and racials creating defaults 
do 
    --- PvP Trinket:
    RubimRH.LossOfControlCreate("DISARM")
    RubimRH.LossOfControlCreate("INCAPACITATE")
    RubimRH.LossOfControlCreate("DISORIENT")
    RubimRH.LossOfControlCreate("FREEZE")        
    RubimRH.LossOfControlCreate("SILENCE")
    RubimRH.LossOfControlCreate("POSSESS")    
    RubimRH.LossOfControlCreate("SAP")    
    RubimRH.LossOfControlCreate("CYCLONE")
    RubimRH.LossOfControlCreate("BANISH")
    RubimRH.LossOfControlCreate("PACIFYSILENCE")
    --- Dworf|DarkIronDwarf
    RubimRH.LossOfControlCreate("POLYMORPH")    
    RubimRH.LossOfControlCreate("SLEEP")
    RubimRH.LossOfControlCreate("SHACKLE_UNDEAD")
    --- Scourge + WR Berserk Rage + DK Lichborne
    RubimRH.LossOfControlCreate("FEAR")    
    RubimRH.LossOfControlCreate("HORROR")    
    --- Scourge
    RubimRH.LossOfControlCreate("CHARM")        
    --- Gnome and any freedom effects 
    RubimRH.LossOfControlCreate("ROOT")        
    RubimRH.LossOfControlCreate("SNARE")
    --- Human + DK Icebound|Lichborne
    RubimRH.LossOfControlCreate("STUN")
end 

RubimRH.Listener:Add('Rubim_Events', "LOSS_OF_CONTROL_UPDATE", RubimRH.LossOfControlUpdate)
RubimRH.Listener:Add('Rubim_Events', "LOSS_OF_CONTROL_ADDED", RubimRH.LossOfControlUpdate)
