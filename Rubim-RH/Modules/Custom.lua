function table.removeKey(t, k)
    local i = 0
    local keys, values = {}, {}
    for k, v in pairs(t) do
        i = i + 1
        keys[i] = k
        values[i] = v
    end

    while i > 0 do
        if keys[i] == k then
            table.remove(keys, i)
            table.remove(values, i)
            break
        end
        i = i - 1
    end

    local a = {}
    for i = 1, #keys do
        a[keys[i]] = values[i]
    end

    return a
end

local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

--- ============================   CUSTOM   ============================
local function round2(num, idp)
    mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function ttd(unit)
    unit = unit or "target";
    if thpcurr == nil then
        thpcurr = 0
    end
    if thpstart == nil then
        thpstart = 0
    end
    if timestart == nil then
        timestart = 0
    end
    if UnitExists(unit) and not UnitIsDeadOrGhost(unit) then
        if currtar ~= UnitGUID(unit) then
            priortar = currtar
            currtar = UnitGUID(unit)
        end
        if thpstart == 0 and timestart == 0 then
            thpstart = UnitHealth(unit)
            timestart = GetTime()
        else
            thpcurr = UnitHealth(unit)
            timecurr = GetTime()
            if thpcurr >= thpstart then
                thpstart = thpcurr
                timeToDie = 999
            else
                if ((timecurr - timestart) == 0) or ((thpstart - thpcurr) == 0) then
                    timeToDie = 999
                else
                    timeToDie = round2(thpcurr / ((thpstart - thpcurr) / (timecurr - timestart)), 2)
                end
            end
        end
    elseif not UnitExists(unit) or currtar ~= UnitGUID(unit) then
        currtar = 0
        priortar = 0
        thpstart = 0
        timestart = 0
        timeToDie = 9999999999999999
    end
    if timeToDie == nil then
        return 99999999
    else
        return timeToDie
    end
end

local activeUnitPlates = {}
local function AddNameplate(unitID)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
    local unitframe = nameplate.UnitFrame

    -- store nameplate and its unitID
    activeUnitPlates[unitframe] = unitID
end

local function RemoveNameplate(unitID)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
    local unitframe = nameplate.UnitFrame
    -- recycle the nameplate
    activeUnitPlates[unitframe] = nil
end

RubimRH.Listener:Add('Rubim_Events', 'NAME_PLATE_UNIT_ADDED', function(...)
    local unitID = ...
    --AddNameplate(unitID)
end)

RubimRH.Listener:Add('Rubim_Events', 'NAME_PLATE_UNIT_REMOVED', function(...)
    local unitID = ...
    --RemoveNameplate(unitID)
end)

function DiyingIn()
    HL.GetEnemies(10, true); -- Blood Boil
    totalmobs = 0
    dyingmobs = 0
    for _, CycleUnit in pairs(Cache.Enemies[10]) do
        totalmobs = totalmobs + 1;
        if CycleUnit:TimeToDie() <= 20 then
            dyingmobs = dyingmobs + 1;
        end
    end
    if dyingmobs == 0 then
        return 0
    else
        return totalmobs / dyingmobs
    end
end

function GetTotalMobs()
    local totalmobs = 0
    for reference, unit in pairs(activeUnitPlates) do
        if CheckInteractDistance(unit, 3) then
            totalmobs = totalmobs + 1
        end
    end
    return totalmobs
end

function GetMobsDying()
    local totalmobs = 0
    local dyingmobs = 0
    for reference, unit in pairs(activeUnitPlates) do
        if CheckInteractDistance(unit, 3) then
            totalmobs = totalmobs + 1
            if ttd(unit) <= 6 then
                dyingmobs = dyingmobs + 1
            end
        end
    end

    if totalmobs == 0 then
        return 0
    end

    return (dyingmobs / totalmobs) * 100
end

function GetMobs(spellId)
    local totalmobs = 0
    for reference, unit in pairs(activeUnitPlates) do
        if IsSpellInRange(GetSpellInfo(spellId), unit) then
            totalmobs = totalmobs + 1
        end
    end
    return totalmobs
end

local SpellsInterrupt = {
    194610, 198405, 194657, 199514, 199589, 216197, --Maw of Souls
    0
}

local function ShouldInterrupt()
    local importantCast = false
    local castName, _, _, _, castStartTime, castEndTime, _, _, notInterruptable, spellID = UnitCastingInfo("target")

    if castName == nil then
        local castName, nameSubtext, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible = UnitChannelInfo("unit")
    end

    if spellID == nil or notInterruptable == true then
        return false
    end

    for i, v in ipairs(SpellsInterrupt) do
        if spellID == v then
            importantCast = true
            break
        end
    end

    if spellID == nil or castInterruptable == false then
        return false
    end

    if int_smart == false then
        importantCast = false
    end

    if importantCast == false then
        return false
    end

    local timeSinceStart = (GetTime() * 1000 - castStartTime) / 1000
    local timeLeft = ((GetTime() * 1000 - castEndTime) * -1) / 1000
    local castTime = castEndTime - castStartTime
    local currentPercent = timeSinceStart / castTime * 100000
    local interruptPercent = math.random(10, 30)
    if currentPercent >= interruptPercent then
        return true
    end
    return false
end

local movedTimer = 0
function RubimRH.lastMoved()
    if Player:IsMoving() then
        movedTimer = GetTime()
    end
    return GetTime() - movedTimer
end

local playerGUID
local damageAmounts, damageTimestamps = {}, {}
damageInLast3Seconds = 0
local lastMeleeHit = 0

local combatLOG = CreateFrame("Frame")
combatLOG:RegisterEvent("PLAYER_LOGIN")
combatLOG:SetScript("OnEvent", function(self, event)
    playerGUID = UnitGUID("player")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:SetScript("OnEvent", function()
        local timestamp, event, arg3, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16 = CombatLogGetCurrentEventInfo()
        if destGUID ~= playerGUID then
            return
        end
        local amount = nil
        if event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" or event == "RANGE_DAMAGE" then
            amount = arg15
            --amount = camount
        elseif event == "SWING_DAMAGE" then
            lastMeleeHit = GetTime()
            amount = arg12
        elseif event == "ENVIRONMENTAL_DAMAGE" then
            amount = arg13
        end
        if amount then
            -- Record new damage at the top of the log:
            tinsert(damageAmounts, 1, amount)
            tinsert(damageTimestamps, 1, timestamp)
            -- Clear out old entries from the bottom, and add up the remaining ones:
            local cutoff = timestamp - 3
            damageInLast3Seconds = 0
            for i = #damageTimestamps, 1, -1 do
                local timestamp = damageTimestamps[i]
                if timestamp < cutoff then
                    damageTimestamps[i] = nil
                    damageAmounts[i] = nil
                else
                    damageInLast3Seconds = damageInLast3Seconds + damageAmounts[i]
                end
            end
        end
    end)
end)

function RubimRH.lastSwing()
    if lastMeleeHit > 0 then
        return GetTime() - lastMeleeHit
    end
    return 0
end

function RubimRH.lastDamage(option)
    if option == nil then
        return damageInLast3Seconds
    else
        return (damageInLast3Seconds * 100) / UnitHealthMax("player")
    end
end

function RubimRH.SetFramePos(frame, x, y, w, h)
    local xOffset0 = 1
    if frame == nil then
        return
    end
    if GetCVar("gxMaximize") == "0" then
        xOffset0 = 0.9411764705882353
    end
    xPixel, yPixel, wPixel, hPixel = x, y, w, h
    xRes, yRes = string.match(({ GetScreenResolutions() })[GetCurrentResolution()], "(%d+)x(%d+)");
    uiscale = UIParent:GetScale();
    XCoord = xPixel * (768.0 / xRes) * GetMonitorAspectRatio() / uiscale / xOffset0
    YCoord = yPixel * (768.0 / yRes) / uiscale;
    Weight = wPixel * (768.0 / xRes) * GetMonitorAspectRatio() / uiscale
    Height = hPixel * (768.0 / yRes) / uiscale;
    if x and y then
        frame:SetPoint("TOPLEFT", XCoord, YCoord)
    end
    if w and h then
        frame:SetSize(Weight, Height)
    end
end

function RubimRH.ColorOnOff(boolean)
    if boolean == true then
        return "|cFF00FF00"
    else
        return "|cFFFF0000"
    end
end

-- Target Valid
function RubimRH.TargetIsValid(override)
    local override = override or false

    local unitReaction = UnitReaction("Player", "Target") or 0
    if not override and unitReaction >= 4 and not Player:AffectingCombat() then
        return false
    end

    local isValid = false

    if Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost() then
        isValid = true
    end

    return isValid
end

-- will be replaced
function RubimRH.azerite(slot, azeriteID)
    local IsArmor = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(ItemLocation:CreateFromEquipmentSlot(slot));
    if IsArmor == true then
        local azeriteLearned = C_AzeriteEmpoweredItem.IsPowerSelected(ItemLocation:CreateFromEquipmentSlot(slot), azeriteID);
        if azeriteLearned == true then
            return true
        else
            return false
        end
    end
    return false
end

function QueueSkill()
    if RubimRH.QueuedSpell() ~= 1 and Player:PrevGCDP(1,RubimRH.QueuedSpell()) then
        RubimRH.queuedSpell = { RubimRH.Spell[1].Empty, 0 }
    end
    if RubimRH.QueuedSpell():IsReadyQueue() then
        return RubimRH.QueuedSpell():Cast()
    end
end

function RubimRH.DebugPrint(Text)
    if RubimRH.db.profile.mainOption.debug  == true then
        print("DEBUG: " .. Text)
    end
end