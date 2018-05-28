local IconRotation = CreateFrame("Frame", nil, UIParent)
IconRotation:SetSize(50, 50)
IconRotation:SetPoint("CENTER", -600, 0)
IconRotation.texture = IconRotation:CreateTexture(nil, "BACKGROUND")
IconRotation.texture:SetAllPoints(true)
IconRotation.texture:SetColorTexture(1.0, 1.0, 0.0, 1.0)
print("icon rotation")

-- Last Update: 05/04/18 02:42
-- Author: Rubim
--if isEqual(thisobj:GetRealSettings().Name) == true then
--return true
--end
--- ============================              ============================
local error = 0
if AethysCore == nil then
    message("ERROR: Aethyhs Core is missing. Please download it.")
    error = 1
end
if AethysCache == nil then
    message("ERROR: Aethyhs Cache is missing. Please download it.")
    error = 1
end
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
function CDsON()
    if Player:Level() < 109 then
        return true
    end

    if useCD == true then
        if UnitExists("boss1") == true or UnitClassification("target") == "worldboss" then
            return true
        end

        if UnitExists("target") and UnitHealthMax("target") >= UnitHealthMax("player") then
            return true
        end

        if Target:IsDummy() then
            return true
        end
    end

    if useCD == false then
        return false
    end

    return false
end

function AoEON()
    if useAoE == true then
        return true
    else
        return false
    end
end


function TargetIsValid()
    return Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost();
end
--- ============================              ============================
local nextAbility
function GetNextAbility()
    return nextAbility
end

function SetNextAbility(skill)
    if skill == nil then
        print("ERROR, NIL SKILL")
        return 0
    else
        nextAbility = skill
    end
end

--- ============================   MAIN_ROT   ============================
function MainRotation()
    if error == 1 then
        return "ERROR: Missing an addon"
    end

    if IsMounted() then
        return 155142
    end

    --    if Player:Level() < 10 then
    --        return 91344
    --    end

    --DK
    if select(3, UnitClass("player")) == 6 then
        if GetSpecialization() == 1 then
            BloodRotation()
            --Frost
        elseif GetSpecialization() == 2 then
            FrostRotation()
        elseif GetSpecialization() == 3 then
            UnholyRotation()
        end
    end

    --Demon HUNTER
    if select(3, UnitClass("player")) == 12 then
        if GetSpecialization() == 1 then
            HavocRotation()
        elseif GetSpecialization() == 2 then
            VengRotation()
        end
    end

    --Rougue
    if select(3, UnitClass("player")) == 4 then
        if GetSpecialization() == 1 then
            AssasinationRotation()
        end
        if GetSpecialization() == 2 then
            OutlawRotation()
        end
    end

    --Monk
    if select(3, UnitClass("player")) == 10 then
        if GetSpecialization() == 3 then
            WindWalkerRotation()
        end
    end

    --Warrior
    if select(3, UnitClass("player")) == 1 then
        if GetSpecialization() == 2 then
            WarriorRotation()
        end
    end

    return GetNextAbility()
end

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

local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local unitID = ...
        AddNameplate(unitID)
    end

    if event == "NAME_PLATE_UNIT_REMOVED" then
        local unitID = ...
        RemoveNameplate(unitID)
    end
end)

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

local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local unitID = ...
        AddNameplate(unitID)
    end

    if event == "NAME_PLATE_UNIT_REMOVED" then
        local unitID = ...
        RemoveNameplate(unitID)
    end
end)

function GetMobs(spellId)
    local totalmobs = 0
    for reference, unit in pairs(activeUnitPlates) do
        if IsSpellInRange(GetSpellInfo(spellId), unit) then
            totalmobs = totalmobs + 1
        end
    end
    return totalmobs
end