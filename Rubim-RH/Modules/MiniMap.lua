---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rubim.
--- DateTime: 12/07/2018 08:08
---

local db; -- File-global handle to the Database
local defaults = {
    profile = {
        LDBIconStorage = {}, -- LibDBIcon storage
    },
};

local ldbObject = {
    type = "launcher",
    icon = "1447599",
    --This is the icon used. Any .blp or .tga file is a valid icon.
    --This path is ALWAYS relative to the World of Warcraft
    --root (ie, "C:\Program Files\World of Warcraft" for
    --Windows and "/Applications/World of Warcraft" for Mac)
    label = "RubimRH",
    OnClick = function(self, button)
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.Profiles)
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.RubimRH)
        InterfaceOptionsFrame:Raise()
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Open Config Panel");
        --Add text here. The first line is ALWAYS a "header" type.
        --It will appear slightly larger than subsequent lines of text
    end,
};

function updateDB(self, event, database)
    db = database.profile;
    LibStub("LibDBIcon-1.0"):Refresh("AddonLDBObjectName", db.LDBIconStorage);
end

local vars = LibStub("AceDB-3.0"):New("AddonSavedVarStorage", defaults);
vars:RegisterCallback("OnProfileChanged", updateDB);
vars:RegisterCallback("OnProfileCopied", updateDB);
vars:RegisterCallback("OnProfileReset", updateDB);
db = vars.profile;

LibStub("LibDataBroker-1.1"):NewDataObject("AddonLDBObjectName", ldbObject);
LibStub("LibDBIcon-1.0"):Register("AddonLDBObjectName", ldbObject, db.LDBIconStorage);