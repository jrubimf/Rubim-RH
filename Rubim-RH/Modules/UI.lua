local HL = HeroLib;
local Cache = HeroCache;
local StdUi = LibStub('StdUi')
local AceGUI = LibStub("AceGUI-3.0")

testTable = {}
function RubimRH.SpellBlocker()
    local currentSpellsNum = {}
    local numCount = 1
    local currentSpells = {}
    local disabledSpells = {}

    for _, Spell in pairs(RubimRH.allSpells) do
        if GetSpellInfo(Spell:ID()) ~= nil then
            table.insert(currentSpells, { text = GetSpellInfo(Spell:ID()) , value = Spell:ID(), true})
            numCount = numCount + 1
            --table.insert(currentSpellsNum, Spell:ID())
        end
    end


    local window = StdUi:Window(UIParent, 'Spell Blocker', 300, 200);
    window:SetPoint('CENTER');


    local general = StdUi:FontString(window, 'Spells List');
    StdUi:GlueTop(general, window, 0, -40);
    local generalSep = StdUi:FontString(window, '============');
    StdUi:GlueTop(generalSep, general, 0, -12);

    if #RubimRH.db.profile.mainOption.disabledSpells > 0 then
        disabledSpells = RubimRH.db.profile.mainOption.disabledSpells
    end    


    -- multi select dropdown
    local spellList = StdUi:Dropdown(window, 200, 20, currentSpells, nil, true);
    spellList:SetPlaceholder('-- Spell List --');
    StdUi:GlueBelow(spellList, generalSep, 0, -20);
    spellList.OnValueChanged = function(self, value)
    RubimRH.db.profile.mainOption.disabledSpells = {}
    for i = 1, #value do
            --table.insert(disabledSpells, value)
            table.insert(RubimRH.db.profile.mainOption.disabledSpells, { text = GetSpellInfo(value[i]) , value = value[i]})
        end
        print('Dropdown Text: ', self:GetText());
    end

    local extra1 = StdUi:Button(window, 100, 20 , 'Clear');
    StdUi:GlueBelow(extra1, spellList, 0, -34, 'CENTER');
    extra1:SetScript('OnClick', function()
        print("RubimRH: Disabled spells cleared.")
        RubimRH.db.profile.mainOption.disabledSpells = {}
        end);
end

local function BloodMenu()
    local window = StdUi:Window(UIParent, 'Death Knight - Blood', 350, 500);
    window:SetPoint('CENTER');


    local general = StdUi:FontString(window, 'General');
    StdUi:GlueTop(general, window, 0, -40);
    local generalSep = StdUi:FontString(window, '=======');
    StdUi:GlueTop(generalSep, general, 0, -12);

    local general1 = StdUi:Checkbox(window, 'Cooldown');
    general1:SetChecked(RubimRH.config.cooldown)
    StdUi:GlueBelow(general1, generalSep, -100, -34, 'LEFT');
    function general1:OnValueChanged(value)
        RubimRH.CDToggle()
    end

    local general12 = StdUi:Checkbox(window, 'Auto Attack');
    general12:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(general12, generalSep, 100, -34, 'RIGHT');
    function general12:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local general2 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    general2:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(general2, general1, 0, -34, 'LEFT');
    StdUi:AddLabel(window, general2, 'Healthstone', 'TOP');
    function general2:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    local defensiveCDs = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(defensiveCDs, window, 0, -200);
    local defensiveCDsSep = StdUi:FontString(window, '===================');
    StdUi:GlueTop(defensiveCDsSep, defensiveCDs, 0, -12);

    local skill1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].icebound);
    skill1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill1, defensiveCDsSep, -50, -34, 'LEFT');
    StdUi:AddLabel(window, skill1, 'Icebound', 'TOP');
    function skill1:OnValueChanged(value)
        RubimRH.db.profile[250].icebound = value
    end

    local skill12 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].runetap);
    skill12:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill12, defensiveCDsSep, 50, -34, 'RIGHT');
    StdUi:AddLabel(window, skill12, 'Runetap', 'TOP');
    function skill12:OnValueChanged(value)
        RubimRH.db.profile[250].runetap = value
    end

    local skill2 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].vampiricblood);
    skill2:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill2, skill1, 0, -34, 'LEFT');
    StdUi:AddLabel(window, skill2, 'Vampiric Blood', 'TOP');
    function skill2:OnValueChanged(value)
        RubimRH.db.profile[250].vampiricblood = value
    end

    local skill22 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].drw);
    skill22:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill22, skill12, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, skill22, 'DRW', 'TOP');
    function skill22:OnValueChanged(value)
        RubimRH.db.profile[250].drw = value
    end

    local skill3 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].smartds);
    skill3:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill3, skill2, 0, -34, 'LEFT');
    StdUi:AddLabel(window, skill3, 'DS (HP Percent)', 'TOP');
    function skill3:OnValueChanged(value)
        RubimRH.db.profile[250].smartds = value
    end

    local skill32 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].deficitds);
    skill32:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill32, skill22, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, skill32, 'DS (Rune Deficit)', 'TOP');
    function skill32:OnValueChanged(value)
        RubimRH.db.profile[250].deficitds = value
    end
    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -410);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20 , 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -34, 'LEFT');
    extra1:SetScript('OnClick', function()
        RubimRH.SpellBlocker()
        end);

    local extra2 = StdUi:Checkbox(window, 'Auto Attack');
    StdUi:GlueBelow(extra2, extraSep, 100, -34, 'RIGHT');
    function extra2:OnValueChanged(value)
        RubimRH.AttackToggle()
    end
    extra2:Hide()
end

local function FrostMenu()
    local window = StdUi:Window(UIParent, 'Death Knight - Frost', 350, 500);
    window:SetPoint('CENTER');


    local general = StdUi:FontString(window, 'General');
    StdUi:GlueTop(general, window, 0, -40);
    local generalSep = StdUi:FontString(window, '=======');
    StdUi:GlueTop(generalSep, general, 0, -12);

    local general1 = StdUi:Checkbox(window, 'Cooldown');
    general1:SetChecked(RubimRH.config.cooldown)
    StdUi:GlueBelow(general1, generalSep, -100, -34, 'LEFT');
    function general1:OnValueChanged(value)
        RubimRH.CDToggle()
    end

    local general12 = StdUi:Checkbox(window, 'Auto Attack');
    general12:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(general12, generalSep, 100, -34, 'RIGHT');
    function general12:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local general2 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    general2:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(general2, general1, 0, -34, 'LEFT');
    function general2:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end
    StdUi:AddLabel(window, general2, 'Healthstone', 'TOP');

    local defensiveCDs = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(defensiveCDs, window, 0, -200);
    local defensiveCDsSep = StdUi:FontString(window, '===================');
    StdUi:GlueTop(defensiveCDsSep, defensiveCDs, 0, -12);

    local skill1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[251].icebound);
    skill1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill1, defensiveCDsSep, -50, -34, 'LEFT')
    function skill1:OnValueChanged(value)
        RubimRH.db.profile[250].icebound = value
    end
    StdUi:AddLabel(window, skill1, 'Icebound', 'TOP');

    local skill12 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].runetap);
    skill12:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill12, defensiveCDsSep, 50, -34, 'RIGHT');
    function skill12:OnValueChanged(value)
        RubimRH.db.profile[250].runetap = value
    end
    --StdUi:AddLabel(window, skill12, 'Runetap', 'TOP');
    skill12:Hide()

    local skill2 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].vampiricblood);
    skill2:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill2, skill1, 0, -34, 'LEFT');
    function skill2:OnValueChanged(value)
        RubimRH.db.profile[250].vampiricblood = value
    end
    --StdUi:AddLabel(window, skill2, 'Vampiric Blood', 'TOP');
    skill2:Hide()

    local skill22 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].drw);
    skill22:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill22, skill12, 0, -34, 'RIGHT');
    function skill22:OnValueChanged(value)
        RubimRH.db.profile[250].drw = value
    end
    --StdUi:AddLabel(window, skill22, 'DRW', 'TOP');
    skill22:Hide()

    local skill3 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].smartds);
    skill3:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill3, skill2, 0, -34, 'LEFT')
    function skill3:OnValueChanged(value)
        RubimRH.db.profile[250].smartds = value
    end
    --StdUi:AddLabel(window, skill3, 'DS (HP Percent)', 'TOP');
    skill3:Hide()

    local skill32 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].deficitds);
    skill32:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill32, skill22, 0, -34, 'RIGHT');
    function skill32:OnValueChanged(value)
        RubimRH.db.profile[250].deficitds = value
    end
    --StdUi:AddLabel(window, skill32, 'DS (Rune Deficit)', 'TOP');
    skill32:Hide()

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -410);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20 , 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -34, 'LEFT');
    extra1:SetScript('OnClick', function()
        SpellBlocker()
        end);

    local extra2 = StdUi:Checkbox(window, 'Auto Attack');
    StdUi:GlueBelow(extra2, extraSep, 100, -34, 'RIGHT');
    function extra2:OnValueChanged(value)
        RubimRH.AttackToggle()
    end
    extra2:Hide()
end

local function UnholyMenu()
    local window = StdUi:Window(UIParent, 'Death Knight - Unholu', 350, 500);
    window:SetPoint('CENTER');


    local general = StdUi:FontString(window, 'General');
    StdUi:GlueTop(general, window, 0, -40);
    local generalSep = StdUi:FontString(window, '=======');
    StdUi:GlueTop(generalSep, general, 0, -12);

    local general1 = StdUi:Checkbox(window, 'Cooldown');
    general1:SetChecked(RubimRH.config.cooldown)
    StdUi:GlueBelow(general1, generalSep, -100, -34, 'LEFT');
    function general1:OnValueChanged(value)
        RubimRH.CDToggle()
    end

    local general12 = StdUi:Checkbox(window, 'Auto Attack');
    general12:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(general12, generalSep, 100, -34, 'RIGHT');
    function general12:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local general2 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    general2:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(general2, general1, 0, -34, 'LEFT');
    function general2:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end
    StdUi:AddLabel(window, general2, 'Healthstone', 'TOP');

    local defensiveCDs = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(defensiveCDs, window, 0, -200);
    local defensiveCDsSep = StdUi:FontString(window, '===================');
    StdUi:GlueTop(defensiveCDsSep, defensiveCDs, 0, -12);

    local skill1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[252].icebound);
    skill1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill1, defensiveCDsSep, -50, -34, 'LEFT')
    function skill1:OnValueChanged(value)
        RubimRH.db.profile[250].icebound = value
    end
    StdUi:AddLabel(window, skill1, 'Icebound', 'TOP');

    local skill12 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].runetap);
    skill12:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill12, defensiveCDsSep, 50, -34, 'RIGHT');
    function skill12:OnValueChanged(value)
        RubimRH.db.profile[250].runetap = value
    end
    --StdUi:AddLabel(window, skill12, 'Runetap', 'TOP');
    skill12:Hide()

    local skill2 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].vampiricblood);
    skill2:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill2, skill1, 0, -34, 'LEFT');
    function skill2:OnValueChanged(value)
        RubimRH.db.profile[250].vampiricblood = value
    end
    --StdUi:AddLabel(window, skill2, 'Vampiric Blood', 'TOP');
    skill2:Hide()

    local skill22 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].drw);
    skill22:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill22, skill12, 0, -34, 'RIGHT');
    function skill22:OnValueChanged(value)
        RubimRH.db.profile[250].drw = value
    end
    --StdUi:AddLabel(window, skill22, 'DRW', 'TOP');
    skill22:Hide()

    local skill3 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].smartds);
    skill3:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill3, skill2, 0, -34, 'LEFT')
    function skill3:OnValueChanged(value)
        RubimRH.db.profile[250].smartds = value
    end
    --StdUi:AddLabel(window, skill3, 'DS (HP Percent)', 'TOP');
    skill3:Hide()

    local skill32 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].deficitds);
    skill32:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(skill32, skill22, 0, -34, 'RIGHT');
    function skill32:OnValueChanged(value)
        RubimRH.db.profile[250].deficitds = value
    end
    --StdUi:AddLabel(window, skill32, 'DS (Rune Deficit)', 'TOP');
    skill32:Hide()

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -410);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20 , 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -34, 'LEFT');
    extra1:SetScript('OnClick', function()
        SpellBlocker()
        end);

    local extra2 = StdUi:Checkbox(window, 'Auto Attack');
    StdUi:GlueBelow(extra2, extraSep, 100, -34, 'RIGHT');
    function extra2:OnValueChanged(value)
        RubimRH.AttackToggle()
    end
    extra2:Hide()
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

function RubimRH.ClassConfig(specID)
    if specID == 250 then
        BloodMenu()
        --InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.dkBlood)
        --InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.dkBlood)
    end        
    if specID == 251 then
        FrostMenu()
    end

    if specID == 252 then
        UnholyMenu()
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