---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rubim.
--- DateTime: 01/06/2018 02:32
---

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
            RubimRH.CDToggle()
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