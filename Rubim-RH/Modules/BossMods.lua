local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
local Focus, MouseOver = Unit.Focus, Unit.MouseOver;
local Arena, Boss, Nameplate = Unit.Arena, Unit.Boss, Unit.Nameplate;
local Party, Raid = Unit.Party, Unit.Raid;


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