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
    smartDStext:SetText("If the DMG Taken is above " .. RubimRH.db.profile.dk.blood.smartds .. " percent, it will suggest an DS.")
    bloodGUI:AddChild(smartDStext)

    local smartDS = AceGUI:Create("Slider")
    smartDS:SetLabel("Smart DS (Percent):")
    smartDS:SetWidth(260)
    smartDS:SetValue(RubimRH.db.profile.dk.blood.smartds)
    smartDS:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile.dk.blood.smartds = value end)
    smartDS:SetSliderValues(5,95,5)
    bloodGUI:AddChild(smartDS)

    local blankLine = AceGUI:Create("Label")
    blankLine:SetText("                                          ")
    bloodGUI:AddChild(blankLine)

    local deficitDStext = AceGUI:Create("Label")
    deficitDStext:SetText("If the RP Max Deficit equals to " .. RubimRH.db.profile.dk.blood.deficitds .. " then it will suggest an DS.")
    bloodGUI:AddChild(deficitDStext)

    local deficitDS = AceGUI:Create("Slider")
    deficitDS:SetLabel("RP Deficit to use DS (Value):")
    deficitDS:SetWidth(260)
    deficitDS:SetValue(RubimRH.db.profile.dk.blood.deficitds)
    deficitDS:SetCallback("OnValueChanged", function(widget, event, value) RubimRH.db.profile.dk.blood.deficitds = value end)
    deficitDS:SetSliderValues(5,95,5)
    bloodGUI:AddChild(deficitDS)

    bloodGUI:Show()
end

local selectedBuff = "Simcraft"
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
    dropdown:SetText(selectedBuff)
    --dropdown:SetLabel("Pick a Buff")
    dropdown:SetCallback("OnValueChanged", function(self, event, pos)
        print("Roll the Bones: " .. rollBones[pos])
        selectedBuff = rollBones[pos]

    end)
    rogueGUI:AddChild(dropdown)
    rogueGUI:Show()
end

function RubimRH.ClassConfig()
    if RubimRH.currentSpec == "blood" then
        BloodMenu()
    elseif RubimRH.currentSpec == "out" then
        OutlawMenu()
    end
end