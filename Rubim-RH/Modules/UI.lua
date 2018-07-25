local HL = HeroLib;
local Cache = HeroCache;

local AceGUI = LibStub("AceGUI-3.0")
local function BloodMenu()
    local bloodGUI = AceGUI:Create("Frame")
    bloodGUI:SetTitle("Blood Config")
    bloodGUI:SetStatusText("Rubim")
    bloodGUI:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
    -- Fill Layout - the TabGroup widget will fill the whole frame
    bloodGUI:SetLayout("Flow")
    --rogueGUI:SetLayout("Fill")
    bloodGUI:SetWidth(260)
    bloodGUI:SetHeight(240)

    local smartDStext = AceGUI:Create("Label")
    smartDStext:SetText("If the DMG Taken is above " .. RubimRH.db.profile[250].smartds .. " percent, it will suggest an DS.")
    bloodGUI:AddChild(smartDStext)

    local smartDS = AceGUI:Create("Slider")
    smartDS:SetLabel("Smart DS (Percent):")
    smartDS:SetWidth(260)
    smartDS:SetValue(RubimRH.db.profile[250].smartds)
    smartDS:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].smartds = value end)
    smartDS:SetSliderValues(5,95,5)
    bloodGUI:AddChild(smartDS)

    local blankLine = AceGUI:Create("Label")
    blankLine:SetText("                                          ")
    bloodGUI:AddChild(blankLine)

    local deficitDStext = AceGUI:Create("Label")
    deficitDStext:SetText("If the RP Max Deficit equals to " .. RubimRH.db.profile[250].deficitds .. " then it will suggest an DS.")
    bloodGUI:AddChild(deficitDStext)

    local deficitDS = AceGUI:Create("Slider")
    deficitDS:SetLabel("RP Deficit to use DS (Value):")
    deficitDS:SetWidth(260)
    deficitDS:SetValue(RubimRH.db.profile[250].deficitds)
    deficitDS:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].deficitds = value end)
    deficitDS:SetSliderValues(5,95,5)
    bloodGUI:AddChild(deficitDS)

    bloodGUI:Show()
end

local function OutlawMenu()
    local rogueGUI = AceGUI:Create("Frame")
    rogueGUI:SetTitle("Rogue - Roll the Boness")
    rogueGUI:SetStatusText("Rubim")
    rogueGUI:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
    -- Fill Layout - the TabGroup widget will fill the whole frame
    rogueGUI:SetLayout("Flow")
    --rogueGUI:SetLayout("Fill")
    rogueGUI:SetWidth(260)
    rogueGUI:SetHeight(140)

    local label = AceGUI:Create("Label")
    label:SetText("Choose a buff from the list.")
    rogueGUI:AddChild(label)

    local rollBones = {
        "Simcraft",
        "SoloMode",
        "1+ Buff",
        "Broadsides",
        "Buried Treasure",
        "Grand Melee",
        "Jolly Roger",
        "Shark Infested Waters",
        "Ture Bearing"
    }
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetValue("Choose a Buff")
    dropdown:SetList(rollBones)
    dropdown:SetText(RubimRH.db.profile[250].dice)
    --dropdown:SetLabel("Pick a Buff")
    dropdown:SetCallback("OnValueChanged", function(self, event, pos)
        print("Roll the Bones: " .. rollBones[pos])
        RubimRH.db.profile[250].dice = rollBones[pos]

    end)
    rogueGUI:AddChild(dropdown)
    rogueGUI:Show()
end

function RubimRH.spellDisabler()
    local currentSpells = {}
    local currentSpellsNum = {}

    for _, Spell in pairs(RubimRH.allSpells) do
        if GetSpellInfo(Spell:ID()) ~= nil then
            table.insert(currentSpells, tostring("" .. tostring(RubimRH.ColorOnOff(RubimRH.isSpellEnabled(Spell:ID())) .. GetSpellInfo(Spell:ID()) .. " (" .. Spell:ID() .. ")")))
            table.insert(currentSpellsNum, Spell:ID())
        end
    end

    local spellDisablerGUI = AceGUI:Create("Frame")
    spellDisablerGUI:SetTitle("Spell Disabler")
    spellDisablerGUI:SetStatusText("Rubim")
    spellDisablerGUI:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
    -- Fill Layout - the TabGroup widget will fill the whole frame
    spellDisablerGUI:SetLayout("Flow")
    --rogueGUI:SetLayout("Fill")
    spellDisablerGUI:SetWidth(300)
    spellDisablerGUI:SetHeight(300)

    local blankLine = AceGUI:Create("Label")
    blankLine:SetText("         ")
    --.\n|cFFFF0000RED|r - Will never suggest that skill. (Deactived/Blocked)
    blankLine:SetFont("Fonts\\FRIZQT__.TTF", 14)
    local blankLine2 = AceGUI:Create("Label")
    blankLine2:SetText("         ")
    --.\n|cFFFF0000RED|r - Will never suggest that skill. (Deactived/Blocked)
    blankLine2:SetFont("Fonts\\FRIZQT__.TTF", 14)

    local warningTEXT = AceGUI:Create("Label")
    warningTEXT:SetText("|cFF00FF00GREEN|r - Enabled")
    warningTEXT:SetFont("Fonts\\FRIZQT__.TTF", 14)
    spellDisablerGUI:AddChild(warningTEXT)

    spellDisablerGUI:AddChild(blankLine)

    local warningTEXT2 = AceGUI:Create("Label")
    warningTEXT2:SetText("|cFFFF0000RED|r - Disabled")
    --.\n|cFFFF0000RED|r - Disabled)
    warningTEXT2:SetFont("Fonts\\FRIZQT__.TTF", 14)
    spellDisablerGUI:AddChild(warningTEXT2)

    spellDisablerGUI:AddChild(blankLine2)

    local allSpells = AceGUI:Create("Dropdown")
    allSpells:SetMultiselect(true)
    allSpells:SetValue("Select an Spell")
    allSpells:SetList(currentSpells)
    allSpells:SetText("Spells")
    --dropdown:SetLabel("Pick a Buff")
    allSpells:SetCallback("OnValueChanged", function(self, event, pos)
        RubimRH.addSpellDisabled(currentSpellsNum[pos])

        local currentSpells = {}
        for _, Spell in pairs(RubimRH.allSpells) do
            if GetSpellInfo(Spell:ID()) ~= nil then
                table.insert(currentSpells, tostring("" .. tostring(RubimRH.ColorOnOff(RubimRH.isSpellDisabled(Spell:ID())) .. GetSpellInfo(Spell:ID()) .. " (" .. Spell:ID() .. ")")))
            end
        end
        allSpells:SetList(currentSpells)
        self.pullout:Close()
        allSpells:SetValue("Select an Spell")

    end)
    allSpells:SetCallback("OnEnter", function(self, event, pos)
        for i = 1, #currentSpellsNum do
--             allSpells:SetItemDisabled(i, RubimRH.isSpellDisabled(Spell:ID()))
            allSpells:SetItemDisabled(i, false)
        end
    end)
    spellDisablerGUI:AddChild(allSpells)

    local warningTEXT3 = AceGUI:Create("Label")
    warningTEXT3:SetText("|cFFFF0000Be aware of what you're doing. Try to disable only the CORRECT SpellID.")
    --.\n|cFFFF0000RED|r - Disabled)
    warningTEXT3:SetFont("Fonts\\FRIZQT__.TTF", 14)
    spellDisablerGUI:AddChild(warningTEXT3)

end

function RubimRH.ClassConfig(specID)
    if specID == 250 then
        BloodMenu()
    elseif specID == 260 then
        OutlawMenu()
    end
end