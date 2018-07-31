local HL = HeroLib;
local Cache = HeroCache;

local AceGUI = LibStub("AceGUI-3.0")
local function BloodMenu()
    local mainWindow = AceGUI:Create("Frame")
    mainWindow:SetTitle("Blood Config")
    mainWindow:SetStatusText("Rubim")
    mainWindow:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
    -- Fill Layout - the TabGroup widget will fill the whole frame
    mainWindow:SetLayout("Flow")
    --mainWindow:SetLayout("Fill")
    mainWindow:SetWidth(260)
    --mainWindow:SetHeight(240)

    local defensiveText = AceGUI:Create("Label")
    defensiveText:SetText("Setting any of this to 0, will disable it.")
    mainWindow:AddChild(defensiveText)

    local icebound = AceGUI:Create("Slider")
    icebound:SetLabel("Icebound Fortitude (Percent):")
    icebound:SetWidth(260)
    icebound:SetValue(RubimRH.db.profile[250].icebound)
    icebound:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].icebound = value end)
    icebound:SetSliderValues(0,95,5)
    mainWindow:AddChild(icebound)

    local runetap = AceGUI:Create("Slider")
    runetap:SetLabel("Rune Tap (Percent):")
    runetap:SetWidth(260)
    runetap:SetValue(RubimRH.db.profile[250].runetap)
    runetap:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].runetap = value end)
    runetap:SetSliderValues(0,95,5)
    mainWindow:AddChild(runetap)

    local vampiricblood = AceGUI:Create("Slider")
    vampiricblood:SetLabel("Vampiric Blood (Percent):")
    vampiricblood:SetWidth(260)
    vampiricblood:SetValue(RubimRH.db.profile[250].vampiricblood)
    vampiricblood:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].vampiricblood = value end)
    vampiricblood:SetSliderValues(0,95,5)    
    mainWindow:AddChild(vampiricblood)

    local blankLine = AceGUI:Create("Label")
    blankLine:SetText("                                          ")
    mainWindow:AddChild(blankLine)

    local smartDStext = AceGUI:Create("Label")
    smartDStext:SetText("If the DMG Taken is above " .. RubimRH.db.profile[250].smartds .. " percent, it will suggest an DS.")
    mainWindow:AddChild(smartDStext)

    local smartDS = AceGUI:Create("Slider")
    smartDS:SetLabel("Smart DS (Percent):")
    smartDS:SetWidth(260)
    smartDS:SetValue(RubimRH.db.profile[250].smartds)
    smartDS:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].smartds = value end)
    smartDS:SetSliderValues(5,95,5)
    mainWindow:AddChild(smartDS)

    local blankLine2 = AceGUI:Create("Label")
    blankLine2:SetText("                                          ")
    mainWindow:AddChild(blankLine2)

    local deficitDStext = AceGUI:Create("Label")
    deficitDStext:SetText("If the RP Max Deficit equals to " .. RubimRH.db.profile[250].deficitds .. " then it will suggest an DS.")
    mainWindow:AddChild(deficitDStext)

    local deficitDS = AceGUI:Create("Slider")
    deficitDS:SetLabel("RP Deficit to use DS (Value):")
    deficitDS:SetWidth(260)
    deficitDS:SetValue(RubimRH.db.profile[250].deficitds)
    deficitDS:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].deficitds = value end)
    deficitDS:SetSliderValues(5,95,5)
    mainWindow:AddChild(deficitDS)

    mainWindow:Show()
end

local function BloodMenu()
    local mainWindow = AceGUI:Create("Frame")
    mainWindow:SetTitle("Blood Config")
    mainWindow:SetStatusText("Rubim")
    mainWindow:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
    -- Fill Layout - the TabGroup widget will fill the whole frame
    mainWindow:SetLayout("Flow")
    --mainWindow:SetLayout("Fill")
    mainWindow:SetWidth(260)
    --mainWindow:SetHeight(240)

    local defensiveText = AceGUI:Create("Label")
    defensiveText:SetText("Setting any of this to 0, will disable it.")
    mainWindow:AddChild(defensiveText)

    local icebound = AceGUI:Create("Slider")
    icebound:SetLabel("Icebound Fortitude (Percent):")
    icebound:SetWidth(260)
    icebound:SetValue(RubimRH.db.profile[250].icebound)
    icebound:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].icebound = value end)
    icebound:SetSliderValues(0,95,5)
    mainWindow:AddChild(icebound)

    local runetap = AceGUI:Create("Slider")
    runetap:SetLabel("Rune Tap (Percent):")
    runetap:SetWidth(260)
    runetap:SetValue(RubimRH.db.profile[250].runetap)
    runetap:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].runetap = value end)
    runetap:SetSliderValues(0,95,5)
    mainWindow:AddChild(runetap)

    local vampiricblood = AceGUI:Create("Slider")
    vampiricblood:SetLabel("Vampiric Blood (Percent):")
    vampiricblood:SetWidth(260)
    vampiricblood:SetValue(RubimRH.db.profile[250].vampiricblood)
    vampiricblood:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].vampiricblood = value end)
    vampiricblood:SetSliderValues(0,95,5)    
    mainWindow:AddChild(vampiricblood)

    local blankLine = AceGUI:Create("Label")
    blankLine:SetText("                                          ")
    mainWindow:AddChild(blankLine)

    local smartDStext = AceGUI:Create("Label")
    smartDStext:SetText("If the DMG Taken is above " .. RubimRH.db.profile[250].smartds .. " percent, it will suggest an DS.")
    mainWindow:AddChild(smartDStext)

    local smartDS = AceGUI:Create("Slider")
    smartDS:SetLabel("Smart DS (Percent):")
    smartDS:SetWidth(260)
    smartDS:SetValue(RubimRH.db.profile[250].smartds)
    smartDS:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].smartds = value end)
    smartDS:SetSliderValues(5,95,5)
    mainWindow:AddChild(smartDS)

    local blankLine2 = AceGUI:Create("Label")
    blankLine2:SetText("                                          ")
    mainWindow:AddChild(blankLine2)

    local deficitDStext = AceGUI:Create("Label")
    deficitDStext:SetText("If the RP Max Deficit equals to " .. RubimRH.db.profile[250].deficitds .. " then it will suggest an DS.")
    mainWindow:AddChild(deficitDStext)

    local deficitDS = AceGUI:Create("Slider")
    deficitDS:SetLabel("RP Deficit to use DS (Value):")
    deficitDS:SetWidth(260)
    deficitDS:SetValue(RubimRH.db.profile[250].deficitds)
    deficitDS:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile[250].deficitds = value end)
    deficitDS:SetSliderValues(5,95,5)
    mainWindow:AddChild(deficitDS)

    mainWindow:Show()
end


local function OutlawMenu()
    local mainWindow = AceGUI:Create("Frame")
    mainWindow:SetTitle("Rogue - Roll the Boness")
    mainWindow:SetStatusText("Rubim")
    mainWindow:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
    -- Fill Layout - the TabGroup widget will fill the whole frame
    mainWindow:SetLayout("Flow")
    --mainWindow:SetLayout("Fill")
    mainWindow:SetWidth(260)
    mainWindow:SetHeight(140)

    local label = AceGUI:Create("Label")
    label:SetText("Choose a buff from the list.")
    mainWindow:AddChild(label)

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
    mainWindow:AddChild(dropdown)
    mainWindow:Show()
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
    --mainWindow:SetLayout("Fill")
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
        --BloodMenu()
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.dkBlood)
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.dkBlood)
    end        
    if specID == 251 then
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.dkFrost)
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.dkFrost)
    end

    if specID == 252 then
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.dkUnholy)
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.dkUnholy)
    end


    if specID == 66 then
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.plProt)
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.plProt)
    end


    if specID == 70 then
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.plRet)
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.plRet)
    end

    if specID == 260 then
        OutlawMenu()
    end
end