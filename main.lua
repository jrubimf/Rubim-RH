if AethysCore == nil then
    message("ERROR: Aethyhs Core is missing. Please download it.")
end
if AethysCache == nil then
    message("ERROR: Aethyhs Cache is missing. Please download it.")
end

devRub = false
--DEFAULTS
useRACIAL = true
useAoE = true
useCD = true
---SKILLS---
useS1 = true
useS2 = true
useS3 = true
---TIER---
t212 = true
t214 = true

--INTERRUPTS---
local int_smart = true

local runonce = 0
classspell = {}
local startUP = function()
    if runonce == 0 then
        print("===================")
        print("|cFF69CCF0R Rotation Assist:")
        print("|cFF00FF96Right-Click on the Main")
        print("|cFF00FF96Icon to more options")
        print("===================")
        runonce = 1
    end
    --Default
    local QuestionMark = 212812
    --DK
    local DeathStrike = 49998
    local RuneTap = 194679
    local BreathOfSindragosa = 152279
    local SindragosasFury = 190778

    --DH
    local FelRush = 195072
    local EyeBeam = 198013

    --Warrior
    local Warbreaker = 209577
    local Ravager = 152277

    --Paladin
    local JusticarVengeance = 215661
    local WordofGlory = 210191

    --Shaman
    local HealingSurge = 188070

    --DK
    if select(2, UnitClass("player")) == "DEATHKNIGHT" then
        --Blood
        if GetSpecialization() == 1 then
            classspell = {}
            table.insert( classspell, DeathStrike )
            table.insert( classspell, RuneTap )
            --Frost
        elseif GetSpecialization() == 2 then
            classspell = {}
            table.insert( classspell, DeathStrike )
            table.insert( classspell, BreathOfSindragosa )
            table.insert( classspell, SindragosasFury )
            --Unholy
        elseif GetSpecialization() == 3 then
            classspell = {}
            table.insert( classspell, DeathStrike )
        end
    end

    --DEMON HUNTER
    if select(3, UnitClass("player")) == 12 then
        if GetSpecialization() == 1 then
            classspell = {}
            table.insert( classspell, FelRush )
            table.insert( classspell, EyeBeam )
        end
    end

    --WARRIOR
    if select(3, UnitClass("player")) == 1 then
        if GetSpecialization() == 1 then
            classspell = {}
            table.insert( classspell, Warbreaker )
            table.insert( classspell, Ravager )
        end
    end

    --PALADIN
    if select(3, UnitClass("player")) == 2 then
        if GetSpecialization() == 3 then
            classspell = {}
            table.insert( classspell, JusticarVengeance )
        end
    end
    --SHAMAN
    if select(3, UnitClass("player")) == 7 then
        classspell = {}
        table.insert( classspell, HealingSurge )
    end


end

local rubStart = CreateFrame("frame")
rubStart:SetScript("OnEvent", startUP)
rubStart:RegisterEvent("PLAYER_LOGIN")
rubStart:RegisterEvent("PLAYER_ENTERING_WORLD")
rubStart:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

-- Create the dropdown, and configure its appearance
local dropDown = CreateFrame("FRAME", "DropDownMenu", UIParent, "UIDropDownMenuTemplate")
dropDown:SetPoint("CENTER")
dropDown:Hide()
UIDropDownMenu_SetWidth(dropDown, 200)
UIDropDownMenu_SetText(dropDown, "Nothing")

-- Create and bind the initialization function to the dropdown menu
UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    if (level or 1) == 1 then
        --
        info.text, info.hasArrow = "Cooldowns", nil
        info.checked = useCD
        info.func = function(self)
            PlaySound(891, "Master");
            if useCD == false then
                useCD = true
            else
                useCD = false
            end
            print("|cFF69CCF0CD".. "|r: |cFF00FF00" .. tostring(useCD))
        end
        UIDropDownMenu_AddButton(info)
        --
        info.text, info.hasArrow = "AoE", nil
        info.checked = useAoE
        info.func = function(self)
            PlaySound(891, "Master");
            if useAoE == false then
                useAoE = true
            else
                useAoE = false
            end
            print("|cFF69CCF0CD".. "|r: |cFF00FF00" .. tostring(useCD))
        end
        UIDropDownMenu_AddButton(info)
        --
        info.text, info.hasArrow, info.menuList = "Interrupts", true, "Interrupts"
        info.checked = false
        info.func = function(self) end
        UIDropDownMenu_AddButton(info)
        --
        info.text, info.hasArrow, info.menuList = "Spells", true, "Spells"
        info.checked = false
        info.func = function(self) end
        UIDropDownMenu_AddButton(info)
        --TIER
        info.text, info.hasArrow, info.menuList = "Tier", true, "Tier"
        info.checked = false
        info.func = function(self) end
        UIDropDownMenu_AddButton(info)
    elseif menuList == "Spells" then
        --SKILL 1
        for i=1, #classspell do
            info.text = GetSpellInfo(classspell[i])

            if i == 1 then
                info.checked = useS1
            end

            if i == 2 then
                info.checked = useS2
            end

            if i == 3 then
                info.checked = useS3
            end
            info.func = function(self)
                PlaySound(891, "Master");

                if i == 1 then
                    if useS1 then
                        useS1 = false
                    else
                        useS1 = true
                    end
                    print("|cFF69CCF0".. GetSpellInfo(classspell[i]) .. "|r: |cFF00FF00" ..  tostring(useS1))
                end

                if i == 2 then
                    if useS2 then
                        useS2 = false
                    else
                        useS2 = true
                    end
                    print("|cFF69CCF0".. GetSpellInfo(classspell[i]) .. "|r: |cFF00FF00" ..  tostring(useS2))
                end

                if i == 3 then
                    if useS3 then
                        useS3 = false
                    else
                        useS3 = true
                    end
                    print("|cFF69CCF0".. GetSpellInfo(classspell[i]) .. "|r: |cFF00FF00" ..  tostring(useS3))
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
        -- Show the "Games" sub-menu
        --        for s in (tostring(GetSpellInfo(ClassSpell1)) .. "; " .. tostring(GetSpellInfo(ClassSpell2))):gmatch("[^;%s][^;]*") do
        --            info.text = s
        --            UIDropDownMenu_AddButton(info, level)
        --        end
    elseif menuList == "Interrupts" then
        --2 PIECES
        info.text = "Smart"
        info.checked = int_smart
        info.func = function(self)
            PlaySound(891, "Master");
            if int_smart then
                int_smart = false
                print("|cFF69CCF0".. "Interrupting" .. "|r: |cFF00FF00" ..  "Everything ")
            else
                int_smart = true
                print("|cFF69CCF0".. "Interrupting" .. "|r: |cFF00FF00" ..  "Only necessary. ")
            end
        end
        UIDropDownMenu_AddButton(info, level)
    elseif menuList == "Tier" then
        --2 PIECES
        info.text = "T21: 2Pcs"
        info.checked = t212
        info.func = function(self)
            PlaySound(891, "Master");
            if t212 then
                t212 = false
            else
                t212 = true
            end
            print("|cFF69CCF0".. "2PCs" .. "|r: |cFF00FF00" ..  tostring(t212))
        end
        UIDropDownMenu_AddButton(info, level)
        --4 PIECES
        info.text = "T21: 4Pcs"
        info.checked = t214
        info.func = function(self)
            PlaySound(891, "Master");
            if t214 then
                t214 = false
            else
                t214 = true
            end
            print("|cFF69CCF0".. "4PCs" .. "|r: |cFF00FF00" ..  tostring(t214))
        end
        UIDropDownMenu_AddButton(info, level)
        --
    end
end)

Sephul = CreateFrame("Frame", nil, UIParent)
Sephul:SetBackdrop(nil)
Sephul:SetFrameStrata("HIGH")
Sephul:SetSize(30, 30)
Sephul:SetScale(1);
Sephul:SetPoint("TOPLEFT", 1, -50)
Sephul.texture = Sephul:CreateTexture(nil, "TOOLTIP")
Sephul.texture:SetAllPoints(true)
Sephul.texture:SetColorTexture(0, 1, 0, 1.0)
Sephul.texture:SetTexture(GetSpellTexture(226262))
Sephul:Hide()

local IconRotation = CreateFrame("Frame", nil, UIParent)
IconRotation:SetBackdrop(nil)
IconRotation:SetFrameStrata("HIGH")
--IconRotation:SetSize(18, 18)
IconRotation:SetSize(50, 50)
--IconRotation:SetPoint("TOPLEFT", 19, 6)
--IconRotation:SetPoint("TOPLEFT", 50, 6)
IconRotation:SetPoint("CENTER", 0, -300)
IconRotation.texture = IconRotation:CreateTexture(nil, "BACKGROUND")
IconRotation.texture:SetAllPoints(true)
IconRotation.texture:SetColorTexture(0, 0, 0, 1.0)
IconRotation:SetMovable(true)
IconRotation:EnableMouse(true)
--IconRotation:DisableDrawLayer("BACKGROUND")
IconRotation:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not self.isMoving then
        self:StartMoving();
        self.isMoving = true;
    end
end)
IconRotation:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and self.isMoving then
        self:StopMovingOrSizing();
        self.isMoving = false;
    end

    if button == "RightButton" then
        ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3)
    end
end)
IconRotation:SetScript("OnHide", function(self)
    if (self.isMoving) then
        self:StopMovingOrSizing();
        self.isMoving = false;
    end
end)

local total = 0
local function onUpdate(self, elapsed)
    total = total + elapsed
    if total >= 0.2 then
        IconRotation.texture:SetTexture(GetSpellTexture(MainRotation()))
        total = 0
    end
end

local updateIcon = CreateFrame("frame")
updateIcon:SetScript("OnUpdate", onUpdate)
--IconRotation.texture:SetTexture(GetSpellTexture(BloodRotation()))

-- Last Update: 05/04/18 02:42
-- Author: Rubim
--if isEqual(thisobj:GetRealSettings().Name) == true then
--return true
--end
--- ============================              ============================
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
        print("ERROR")
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

    if IsMounted() and UnitAura("player", GetSpellInfo(190784)) == nil then
        return 155142
    end

    --    shiftDown = IsShiftKeyDown()
    --    if shiftDown then
    --        return 69042
    --    end

    --    if Player:Level() < 10 then
    --        return 91344
    --    end

    --DK
    if select(3, UnitClass("player")) == 6 then
        if GetSpecialization() == 1 then
            SetNextAbility(BloodRotation())
            --Frost
        elseif GetSpecialization() == 2 then
            SetNextAbility(FrostRotation())
        elseif GetSpecialization() == 3 then
            SetNextAbility(UnholyRotation())
        end
    end

    --Demon HUNTER
    if select(3, UnitClass("player")) == 12 then
        if GetSpecialization() == 1 then
            SetNextAbility(HavocRotation())
        elseif GetSpecialization() == 2 then
            SetNextAbility(VengRotation())
        end
    end

    --Rogue
    if select(3, UnitClass("player")) == 4 then
        if GetSpecialization() == 1 then
            SetNextAbility(AssasinationRotation())
        end
        if GetSpecialization() == 2 then
            SetNextAbility(OutlawRotation())
        end
        if GetSpecialization() == 3 then
            SetNextAbility(SubRotation())
        end
    end

    --Monk
    if select(3, UnitClass("player")) == 10 then
        if GetSpecialization() == 1 then
            SetNextAbility(BrewMasterRotation())
        end
        if GetSpecialization() == 3 then
            SetNextAbility(WindWalkerRotation())
        end
    end

    --Warrior
    if select(3, UnitClass("player")) == 1 then
        if GetSpecialization() == 1 then
            SetNextAbility(WarriorArms())
        end
        if GetSpecialization() == 2 then
            SetNextAbility(WarriorFury())
        end
        if GetSpecialization() == 3 then
            SetNextAbility(WarriorProt())
        end
    end

    --Hunter
    if select(3, UnitClass("player")) == 3 then
        if GetSpecialization() == 3 then
            SetNextAbility(SurvRotation())
        end
    end

    --Shaman
    if select(3, UnitClass("player")) == 7 then
        if GetSpecialization() == 2 then
            SetNextAbility(Enhancement())
        end
    end

    --Paladin
    if select(3, UnitClass("player")) == 2 then
        if GetSpecialization() == 3 then
            SetNextAbility(PaladinRetribution())
        end

        if GetSpecialization() == 2 then
            SetNextAbility(PaladinProt())
        end

        if GetSpecialization() == 1 then
            SetNextAbility(PaladinHoly())
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

function DiyingIn()
    AC.GetEnemies(10, true); -- Blood Boil
    totalmobs = 0
    dyingmobs = 0
    for _, CycleUnit in pairs(Cache.Enemies[10]) do
        totalmobs = totalmobs + 1;
        if CycleUnit:TimeToDie() <= 20 then
            dyingmobs = dyingmobs + 1;
        end
    end
    if dyingmobs == 0 then return 0 else return totalmobs/dyingmobs end
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
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");


frame:SetScript("OnEvent", function(self, event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local unitID = ...
        AddNameplate(unitID)
    end

    if event == "NAME_PLATE_UNIT_REMOVED" then
        local unitID = ...
        RemoveNameplate(unitID)
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit = select(1,...)
        local spellID = select(5,...)
        if spellID == GetQueueSpell() then
            SetQueueSpell(nil)
        end
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

local QueuedSpell = nil
local timeElapsed = 0
function SetQueueSpell(spell)
    timeElapsed = GetTime()
    QueuedSpell = spell
end

function GetQueueSpell()
    if GetTime() - timeElapsed > 3 then
        SetQueueSpell(nil)
    end
    return QueuedSpell
end

local SpellsInterrupt = {
    194610, 198405, 194657, 199514, 199589, 216197, --Maw of Souls
    0
}

function ShouldInterrupt()
    local importantCast = false
    local castName, _, _, _, castStartTime, castEndTime, _, _, notInterruptable, spellID = UnitCastingInfo("target")

    if castName == nil then
        local castName, nameSubtext, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible = UnitChannelInfo("unit")
    end

    if spellID == nil or notInterruptable == true then
        return false
    end

    for i,v in ipairs(SpellsInterrupt) do
        if spellID == v then
            importantCast = true
            break
        end
    end

    if spellID == nil or castInterruptable == false then
        return false
    end

    if int_smart == false then
        importantCast = true
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