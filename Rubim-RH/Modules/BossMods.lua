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



-- First pass at boss mods supports. 
--
--
-- DBM
local function RubimRH.PullTimer(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
	    local prefix, message = ...
	    if prefix == "D4" and string.find(message, "PT") then
	    	CurrentPullTimer = GetTime() + tonumber(string.sub(message, 4, 5))
	    elseif prefix == "BigWigs" and string.find(message, "Pull") then
	    	CurrentPullTimer = GetTime() + tonumber(string.sub(message, 8, 9))
	    end
    end
	return CurrentPullTimer
end
		
function(self,event,prefix,arg1)
  if prefix=="D4" then
    local _,pt = (arg1 or ""):match("^(PT).(%d+)")
    if pt then
      self.pt = tonumber(pt)
      self:Show()
      PlaySound("RaidWarning","master")
    end
end
  
function hkEvent_CHAT_MSG_ADDON(noidea, prefix, message, channel)
    if prefix == "D4" and string.sub(message,1,2) == "PT" then
        timer = string.sub(message,4,5);
    end
end


local registeredDBMEvents = {}
local bars = {}
local nextExpire -- time of next expiring timer
local recheckTimer -- handle of timer

local function dbmRecheckTimers()
local now = GetTime()
    nextExpire = nil

    for id, bar in pairs(bars) do
      if bar.expirationTime < now then
        bars[id] = nil
        RubimRH.ScanEvents("DBM_TimerStop", id)
		elseif nextExpire == nil then
        nextExpire = bar.expirationTime
		elseif bar.expirationTime < nextExpire then
        nextExpire = bar.expirationTime
		end
	end

    if nextExpire then
      recheckTimer = timer:ScheduleTimerFixed(dbmRecheckTimers, nextExpire - now)
    end
  end

  local function dbmEventCallback(event, ...)
    if event == "DBM_TimerStart" then
      local id, msg, duration, icon, timerType, spellId, colorId = ...
      local now = GetTime()
      local expirationTime = now + duration
      bars[id] = bars[id] or {}
      local bar = bars[id]
      bar.message = msg
      bar.expirationTime = expirationTime
      bar.duration = duration
      bar.icon = icon
      bar.timerType = timerType
      bar.spellId = tostring(spellId)
      bar.colorId = colorId

      RubimRH.ScanEvents("DBM_TimerStart", id)
      if nextExpire == nil then
        recheckTimer = timer:ScheduleTimerFixed(dbmRecheckTimers, expirationTime - now)
        nextExpire = expirationTime
      elseif expirationTime < nextExpire then
        timer:CancelTimer(recheckTimer)
        recheckTimer = timer:ScheduleTimerFixed(dbmRecheckTimers, expirationTime - now)
        nextExpire = expirationTime
      end
    elseif event == "DBM_TimerStop" then
      local id = ...
      bars[id] = nil
      RubimRH.ScanEvents("DBM_TimerStop", id)
    elseif event == "kill" or event == "wipe" then -- Wipe or kill, removing all timers
      local id = ...
      bars = {}
      RubimRH.ScanEvents("DBM_TimerStopAll", id)
    elseif event == "DBM_TimerUpdate" then
      local id, elapsed, duration = ...
      local now = GetTime()
      local expirationTime = now + duration - elapsed
      local bar = bars[id]
      if bar then
        bar.duration = duration
        bar.expirationTime = expirationTime
        if expirationTime < nextExpire then
          timer:CancelTimer(recheckTimer)
          recheckTimer = timer:ScheduleTimerFixed(dbmRecheckTimers, duration - elapsed)
          nextExpire = expirationTime
        end
      end
      RubimRH.ScanEvents("DBM_TimerUpdate", id)
    else -- DBM_Announce
      RubimRH.ScanEvents(event, ...)
    end
  end

  function RubimRH.DBMTimerMatches(id, message, operator, spellId, colorId)
    if not bars[id] then
      return false
    end

    local v = bars[id]
    if spellId and spellId ~= "" and spellId ~= v.spellId then
      return false
    end
    if message and message ~= "" and operator then
      if operator == "==" then
        if v.message ~= message then
          return false
        end
      elseif operator == "find('%s')" then
        if v.message == nil or not v.message:find(message, 1, true) then
          return false
        end
      elseif operator == "match('%s')" then
        if v.message == nil or not v.message:match(message) then
          return false
        end
      end
    end
    if colorId and colorId ~= v.colorId then
      return false
    end
    return true
  end

  function RubimRH.GetDBMTimerById(id)
    return bars[id]
  end

  function RubimRH.GetAllDBMTimers()
    return bars
  end

  function RubimRH.GetDBMTimer(message, operator, spellId, extendTimer, colorId)
    local bestMatch
    for id, bar in pairs(bars) do
      if RubimRH.DBMTimerMatches(id, message, operator, spellId, colorId)
      and (bestMatch == nil or bar.expirationTime < bestMatch.expirationTime)
      and bar.expirationTime + extendTimer > GetTime()
      then
        bestMatch = bar
      end
    end
    return bestMatch
  end

  function RubimRH.CopyBarToState(bar, states, id, extendTimer)
    extendTimer = extendTimer or 0
    if extendTimer + bar.duration < 0 then return end
    states[id] = states[id] or {}
    local state = states[id]
    state.show = true
    state.changed = true
    state.icon = bar.icon
    state.message = bar.message
    state.name = bar.message
    state.expirationTime = bar.expirationTime + extendTimer
    state.progressType = 'timed'
    state.resort = true
    state.duration = bar.duration + extendTimer
    state.timerType = bar.timerType
    state.spellId = bar.spellId
    state.colorId = bar.colorId
    state.extend = extendTimer
    if extendTimer ~= 0 then
      state.autoHide = true
    end
  end

  function RubimRH.RegisterDBMCallback(event)
    if registeredDBMEvents[event] then
      return
    end
    if DBM then
      DBM:RegisterCallback(event, dbmEventCallback)
      registeredDBMEvents[event] = true
    end
  end

  function RubimRH.GetDBMTimers()
    return bars
  end

  local scheduled_scans = {}

  local function doDbmScan(fireTime)
    RubimRH.debug("Performing dbm scan at "..fireTime.." ("..GetTime()..")")
    scheduled_scans[fireTime] = nil
    RubimRH.ScanEvents("DBM_TimerUpdate")
  end
  function RubimRH.ScheduleDbmCheck(fireTime)
    if not scheduled_scans[fireTime] then
      scheduled_scans[fireTime] = timer:ScheduleTimerFixed(doDbmScan, fireTime - GetTime() + 0.1, fireTime)
      RubimRH.debug("Scheduled dbm scan at "..fireTime)
    end
  end
end