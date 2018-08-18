local HL = HeroLib;
local Cache = HeroCache;
local StdUi = LibStub('StdUi')
local AceGUI = LibStub("AceGUI-3.0")

testTable = {}
function RubimRH.SpellBlocker(point, relativeTo, relativePoint, xOfs, yOfs)
    local currentSpellsNum = {}
    local numCount = 1
    local currentSpells = {}
    local disabledSpells = {}

    for _, Spell in pairs(RubimRH.allSpells) do
        if GetSpellInfo(Spell:ID()) ~= nil then
            table.insert(currentSpells, { text = "|cFF00FF00" .. GetSpellInfo(Spell:ID()) .. "|r", value = Spell:ID(), enabled = false })
            numCount = numCount + 1
            --table.insert(currentSpellsNum, Spell:ID())
        end
    end

    for i, v in pairs(currentSpells) do
        for i, p in pairs(RubimRH.db.profile.mainOption.disabledSpells) do
            if v.value == p.value then
                v.text = "|cFFFF0000" .. GetSpellInfo(v.value) .. "|r"
                --spellList:SetValue(v.value, "|cFFFF0000" .. v.text .. "|r")
            end
        end
    end

    local window = StdUi:Window(UIParent, 'Spell Blocker', 300, 200);
    window:SetPoint('CENTER');
    if point ~= nil then
        window:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local general = StdUi:FontString(window, 'Spells List');
    StdUi:GlueTop(general, window, 0, -40);
    local generalSep = StdUi:FontString(window, '============');
    StdUi:GlueTop(generalSep, general, 0, -12);

    if #RubimRH.db.profile.mainOption.disabledSpells > 0 then
        disabledSpells = RubimRH.db.profile.mainOption.disabledSpells
    end

    -- multi select dropdown
    local spellList = StdUi:Dropdown(window, 200, 20, currentSpells, nil, nil);
    spellList:SetPlaceholder('-- Spell List --');
    StdUi:GlueBelow(spellList, generalSep, 0, -20);
    spellList.OnValueChanged = function(self, val)

        if RubimRH.db.profile.mainOption.disabledSpells[1] == nil then
            table.insert(RubimRH.db.profile.mainOption.disabledSpells, { text = GetSpellInfo(val), value = val })
            print("Added: " .. GetSpellInfo(val))
        else
            local duplicated = false
            local duplicatedNumber = 0
            for i = 1, #RubimRH.db.profile.mainOption.disabledSpells do
                if RubimRH.db.profile.mainOption.disabledSpells[i].value == val then
                    duplicated = true
                    duplicatedNumber = i
                    break
                end
            end

            if duplicated then
                table.remove(RubimRH.db.profile.mainOption.disabledSpells, duplicatedNumber)
                print("Removed: " .. GetSpellInfo(val))
            else
                table.insert(RubimRH.db.profile.mainOption.disabledSpells, { text = GetSpellInfo(val), value = val })
                print("Added: " .. GetSpellInfo(val))
            end
        end
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        RubimRH.SpellBlocker(point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local extra1 = StdUi:Button(window, 100, 20, 'Clear');
    StdUi:GlueBelow(extra1, spellList, 0, -24, 'CENTER');
    extra1:SetScript('OnClick', function()
        print("RubimRH: Disabled spells cleared.")
        RubimRH.db.profile.mainOption.disabledSpells = {}
    end);
end

local function BloodMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local window = StdUi:Window(UIParent, 'Death Knight - Blood', 350, 500);
    window:SetPoint('CENTER');
    if point ~= nil then
        window:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local trinketOptions = {
        { text = 'Trinket 1', value = 1 },
        { text = 'Trinket 2', value = 2 },
    }

    for i = 1, #trinketOptions do
        local duplicated = false
        for p = 1, #RubimRH.db.profile.mainOption.useTrinkets do
            if trinketOptions[i].value == RubimRH.db.profile.mainOption.useTrinkets[p] then
                trinketOptions[i].text = "|cFF00FF00" .. "Trinket " .. i .. "|r"
                duplicated = true
            end
            if duplicated == false then
                trinketOptions[i].text = "|cFFFF0000" .. "Trinket " .. i .. "|r"
            end
        end
    end

    if #RubimRH.db.profile.mainOption.useTrinkets == 0 then
        for i = 1, #trinketOptions do
            trinketOptions[i].text = "|cFFFF0000" .. "Trinket " .. i .. "|r"
        end
    end

    local gn_1_1 = StdUi:Dropdown(window, 100, 20, trinketOptions, nil, nil);

    gn_1_1:SetPlaceholder('-- Trinkets --');
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    gn_1_1.OnValueChanged = function(self, val)

        if RubimRH.db.profile.mainOption.useTrinkets[1] == nil then
            table.insert(RubimRH.db.profile.mainOption.useTrinkets, val)
            print("Trinket " .. val .. ": Enabled")
        else
            local duplicated = false
            local duplicatedNumber = 0
            for i = 1, #RubimRH.db.profile.mainOption.useTrinkets do
                if RubimRH.db.profile.mainOption.useTrinkets[i] == val then
                    duplicated = true
                    duplicatedNumber = i
                    break
                end
            end

            if duplicated then
                table.remove(RubimRH.db.profile.mainOption.useTrinkets, duplicatedNumber)
                print("Trinket " .. val .. ": Disabled")
            else
                table.insert(RubimRH.db.profile.mainOption.useTrinkets, val)
                print("Trinket " .. val .. ": Enabled")
            end
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        BloodMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].icebound);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Icebound', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[250].icebound = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].runetap);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Runetap', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[250].runetap = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].vampiricblood);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Vampiric Blood', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[250].vampiricblood = value
    end

    local sk_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].drw);
    sk_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_2_1, 'DRW', 'TOP');
    function sk_2_1:OnValueChanged(value)
        RubimRH.db.profile[250].drw = value
    end

    --    local sk_3_0 = StdUi:Slider(window, 100, 16, RubimRH.db.profile[250].smartds, false, 0, 100)
    --local sk_3_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].smartds);
    --sk_3_0:SetMinMaxValue(0, 100);
    --    StdUi:GlueBelow(sk_3_0, sk_2_0, 0, -24, 'LEFT');
    --    StdUi:AddLabel(window, sk_3_0, 'DS - ' .. RubimRH.db.profile[250].smartds, 'TOP');
    --    StdUi:FrameTooltip(sk_3_0, 'How much inc dmg, in percent so we can start using DS.', 'TOPLEFT', 'TOPRIGHT', true);
    --    function sk_3_0:OnValueChanged(value)
    --        local value = math.floor(value)
    --      sk_3_0:SetValue(value);

    --        if RubimRH.db.profile[250].smartds ~= value then
    --            print('DS Percent: '  .. value)
    --      end

    --        RubimRH.db.profile[250].smartds = value
    --end

    local sk_3_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].smartds);
    sk_3_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_3_0, sk_2_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_3_0, 'DS (InC DMG Percent)', 'TOP');
    function sk_3_0:OnValueChanged(value)
        RubimRH.db.profile[250].smartds = value
    end

    local sk_3_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].deficitds);
    sk_3_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_3_1, sk_2_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_3_1, 'DS (Rune Deficit)', 'TOP');
    function sk_3_1:OnValueChanged(value)
        RubimRH.db.profile[250].deficitds = value
    end
    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -410);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end
local function FrostMenu()
    local window = StdUi:Window(UIParent, 'Death Knight - Frost', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[251].icebound);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Icebound', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[250].icebound = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[251].deathstrike);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Death Strike (Proc)', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[251].deathstrike = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[251].deathstrikeper);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Death Strike (Emergency)', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[251].deathstrikeper = value
    end

    local sk_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[251].deathpact);
    sk_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_2_1, 'Death Pact', 'TOP');
    function sk_2_1:OnValueChanged(value)
        RubimRH.db.profile[251].deathpact = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -310);
    local extraSep = StdUi:FontString(window, '===================');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -50, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function UnholyMenu()
    local window = StdUi:Window(UIParent, 'Death Knight - Unholy', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[252].icebound);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Icebound', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[250].icebound = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[252].deathstrike);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Death Strike (Proc)', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[252].deathstrike = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[252].deathstrikeper);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Death Strike', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[252].deathstrikeper = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -310);
    local extraSep = StdUi:FontString(window, '===================');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -50, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function ArmsMenu()
    local window = StdUi:Window(UIParent, 'Warrior - Arms', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[71].diebythesword);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Dy By The Sword', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[71].diebythesword = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[71].victoryrush);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Victory Rush', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[71].victoryrush = value
    end

    local sk_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[71].rallyingcry);
    sk_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_2_1, 'Rallying Cry', 'TOP');
    function sk_2_1:OnValueChanged(value)
        RubimRH.db.profile[71].rallyingcry = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end
local function FuryMenu()
    local window = StdUi:Window(UIParent, 'Warrior - Fury', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[71].rallyingcry);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Rallying Cry', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[71].rallyingcry = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[71].victoryrush);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Victory Rush', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[71].victoryrush = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function MMMenu()
    local window = StdUi:Window(UIParent, 'Hunter - Marksman', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[254].exhilaration);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Exhilaration', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[254].exhilaration = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[254].aspectoftheturtle);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Aspect of the Turtle', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[254].aspectoftheturtle = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function SurvivalMenu()
    local window = StdUi:Window(UIParent, 'Hunter - Survival', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[255].mendpet);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Mend Pet', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[255].mendpet = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[255].aspectoftheturtle);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Aspect of the Turtle', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[255].aspectoftheturtle = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[255].exhilaration);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Exhilaration', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[255].exhilaration = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function BMMenu()
    local window = StdUi:Window(UIParent, 'Hunter - Beast Mastery', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[253].mendpet);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Mend Pet', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[253].mendpet = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[253].aspectoftheturtle);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Aspect of the Turtle', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[253].aspectoftheturtle = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end


--local tex = StdUi:Texture(window, 350, 500, [[Interface\AddOns\AltzUI\media\statusbar]]);
--tex:SetColorTexture(1, 1, 1, 1)
--StdUi:GlueTop(tex, window, 0, 0);
local function OutMenu()
    local window = StdUi:Window(UIParent, 'Rogue - Outlaw', 350, 500);
    window:SetPoint('CENTER');


    --window.texture = window:CreateTexture(nil, "BACKGROUND")
    --window.texture:SetTexture(1, 1, 1, 1)
    --window.texture:SetColorTexture(1, 1, 1, 1)

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[260].crimsonvial);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Crimson Vial', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[260].crimsonvial = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[260].cloakofshadows);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Cloak of Shadows', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[260].cloakofshadows = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[260].riposte);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Riposte', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[260].riposte = value
    end

    local dice = {
        { text = 'Simcraft', value = 1 },
        { text = 'SoloMode', value = 2 },
        { text = '1+ Buff', value = 3 },
        { text = 'Broadsides', value = 4 },
        { text = 'Buried Treasure', value = 5 },
        { text = 'Grand Melee', value = 6 },
        { text = 'Jolly Roger', value = 7 },
        { text = 'Shark Infested Waters', value = 8 },
        { text = 'Ture Bearing', value = 9 },
    };

    local sk_2_1 = StdUi:Dropdown(window, 100, 24, dice, 1);
    StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_2_1, 'Roll the Bones', 'TOP');
    function sk_2_1:OnValueChanged(value)
        RubimRH.db.profile[260].dice = self:GetText()
        print("Roll the Bones: " .. RubimRH.db.profile[260].dice)
    end

    local sk_3_0 = StdUi:Checkbox(window, "Vanish Attack");
    sk_3_0:SetChecked(RubimRH.db.profile[260].vanishattack)
    StdUi:GlueBelow(sk_3_0, sk_2_0, 0, -24, 'LEFT');
    function sk_3_0:OnValueChanged(value)
        if RubimRH.db.profile[260].vanishattack then
            RubimRH.db.profile[260].vanishattack = false
        else
            RubimRH.db.profile[260].vanishattack = true
        end
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -380);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function SubMenu()
    local window = StdUi:Window(UIParent, 'Rogue - Sub', 350, 500);
    window:SetPoint('CENTER');


    --window.texture = window:CreateTexture(nil, "BACKGROUND")
    --window.texture:SetTexture(1, 1, 1, 1)
    --window.texture:SetColorTexture(1, 1, 1, 1)

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[261].crimsonvial);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Crimson Vial', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[261].crimsonvial = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[261].cloakofshadows);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Cloak of Shadows', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[261].cloakofshadows = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[261].evasion);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Evasion', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[261].evasion = value
    end

    local sk_2_1 = StdUi:Checkbox(window, "Vanish Attack");
    sk_2_1:SetChecked(RubimRH.db.profile[261].vanishattack)
    StdUi:GlueBelow(sk_2_1, sk_1_1, 15, -24, 'RIGHT');
    function sk_2_1:OnValueChanged(value)
        if RubimRH.db.profile[261].vanishattack then
            RubimRH.db.profile[261].vanishattack = false
        else
            RubimRH.db.profile[261].vanishattack = true
        end
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -380);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function AssMenu()
    local window = StdUi:Window(UIParent, 'Rogue - Ass', 350, 500);
    window:SetPoint('CENTER');


    --window.texture = window:CreateTexture(nil, "BACKGROUND")
    --window.texture:SetTexture(1, 1, 1, 1)
    --window.texture:SetColorTexture(1, 1, 1, 1)

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[259].crimsonvial);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Crimson Vial', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[259].crimsonvial = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[259].cloakofshadows);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Cloak of Shadows', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[259].cloakofshadows = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[259].evasion);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Evasion', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[259].evasion = value
    end

    local sk_2_1 = StdUi:Checkbox(window, "Vanish Attack");
    sk_2_1:SetChecked(RubimRH.db.profile[259].vanishattack)
    StdUi:GlueBelow(sk_2_1, sk_1_1, 15, -24, 'RIGHT');
    function sk_2_1:OnValueChanged(value)
        if RubimRH.db.profile[259].vanishattack then
            RubimRH.db.profile[259].vanishattack = false
        else
            RubimRH.db.profile[259].vanishattack = true
        end
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -380);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function HavocMenu()
    local window = StdUi:Window(UIParent, 'Demon Hunter - Havoc', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[577].blur);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Blur', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[577].blur = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[577].darkness);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Darkness', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[577].darkness = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function RetributionMenu()
    local window = StdUi:Window(UIParent, 'Paladin - Retribution', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local healthStoneValue = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    healthStoneValue:SetMinMaxValue(0, 100);
    StdUi:AddLabel(window, healthStoneValue, 'Healthstone', 'TOP');
    StdUi:GlueBelow(healthStoneValue, gn_separator, 50, -25, 'RIGHT');
    function healthStoneValue:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -15, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local racialUsage = StdUi:Checkbox(window, 'Use Racial');
    racialUsage:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(racialUsage, gn_1_0, 0, -25, 'LEFT');
    function racialUsage:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -150);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local gn_3_0 = StdUi:Checkbox(window, 'Vengance');
    gn_3_0:SetChecked(RubimRH.db.profile[70].SoVEnabled)
    StdUi:GlueBelow(gn_3_0, sk_separator, -50, -5, 'LEFT');
    function gn_3_0:OnValueChanged(value)
        RubimRH.db.profile[70].SoVEnabled = value
        print("|cFF69CCF0Vengance" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[70].SoVEnabled))
    end

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[70].SoVHP);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, gn_3_0, 0, 0, 'LEFT');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[70].SoVHP = value
    end

    local flashoflight = StdUi:Checkbox(window, 'Flash of Light');
    flashoflight:SetChecked(RubimRH.db.profile[70].FoL)
    StdUi:GlueBelow(flashoflight, sk_separator, 50, -5, 'RIGHT');
    function flashoflight:OnValueChanged(value)
        RubimRH.db.profile[70].FoL = value
        print("|cFF69CCF0Flash of Light" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[70].FoL))
    end

    local FoLHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[70].flashoflight);
    FoLHP :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(FoLHP, flashoflight, -5, 0, 'RIGHT');
    function FoLHP :OnValueChanged(value)
        RubimRH.db.profile[70].flashoflight = value
    end

    local justicarEnabled = StdUi:Checkbox(window, 'Justicar');
    justicarEnabled:SetChecked(RubimRH.db.profile[70].justicariSEnabled)
    StdUi:GlueBelow(justicarEnabled, sk_1_0, 0, -5, 'LEFT');
    function justicarEnabled:OnValueChanged(value)
        RubimRH.db.profile[70].justicariSEnabled = value
        print("|cFF69CCF0Justicar" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[70].justicariSEnabled))
    end

    local justicarHealth = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[70].JusticarHP);
    justicarHealth :SetMinMaxValue(10, 100);
    StdUi:GlueBelow(justicarHealth, justicarEnabled, 0, 0, 'LEFT');
    function justicarHealth :OnValueChanged(value)
        RubimRH.db.profile[70].JusticarHP = value
    end

    local DivineEnabled = StdUi:Checkbox(window, 'Divine Shield');
    DivineEnabled:SetChecked(RubimRH.db.profile[70].divineEnabled)
    StdUi:GlueBelow(DivineEnabled, FoLHP, 0, -5, 'RIGHT');
    function DivineEnabled:OnValueChanged(value)
        RubimRH.db.profile[70].divineEnabled = value
        print("|cFF69CCF0Divine Shield" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[70].divineEnabled))
    end

    local DivineHealth = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[70].DivineHP);
    DivineHealth :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(DivineHealth, DivineEnabled, 0, 0, 'RIGHT');
    function DivineHealth :OnValueChanged(value)
        RubimRH.db.profile[70].DivineHP = value
    end

    local LayOnHandEnabled = StdUi:Checkbox(window, 'Lay on Hands');
    LayOnHandEnabled:SetChecked(RubimRH.db.profile[70].lohEnabled)
    StdUi:GlueBelow(LayOnHandEnabled, justicarHealth, 0, -5, 'LEFT');
    function LayOnHandEnabled:OnValueChanged(value)
        RubimRH.db.profile[70].lohEnabled = value
        print("|cFF69CCF0Lay on Hands" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[70].lohEnabled))
    end

    local lohHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[70].lohHealth);
    lohHP :SetMinMaxValue(10, 100);
    StdUi:GlueBelow(lohHP, LayOnHandEnabled, 0, 0, 'LEFT');
    function lohHP :OnValueChanged(value)
        RubimRH.db.profile[70].lohHealth = value
    end

    local wogactive = StdUi:Checkbox(window, 'Word of Glory');
    wogactive:SetChecked(RubimRH.db.profile[70].wogenabled)
    StdUi:GlueBelow(wogactive, DivineHealth, 0, -5, 'RIGHT');
    function wogactive:OnValueChanged(value)
        RubimRH.db.profile[70].wogenabled = value
        print("|cFF69CCF0Word of Glory" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[70].wogenabled))
    end

    local woghealth = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[70].wogHP);
    woghealth :SetMinMaxValue(10, 100);
    StdUi:GlueBelow(woghealth, wogactive, 0, 0, 'RIGHT');
    function woghealth :OnValueChanged(value)
        RubimRH.db.profile[70].wogHP = value
    end

    local op_title = StdUi:FontString(window, 'Offensive Options');
    StdUi:GlueTop(op_title, window, 0, -350);
    local op_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(op_separator, op_title, 0, -12);

    local gn_4_0 = StdUi:Checkbox(window, 'Vengence in Opener');
    gn_4_0:SetChecked(RubimRH.db.profile[70].SoVOpener)
    StdUi:GlueBelow(gn_4_0, op_separator, 0, -6, 'CENTER');
    function gn_4_0:OnValueChanged(value)
        RubimRH.db.profile[70].SoVOpener = value
        print("|cFF69CCF0Vengance" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[70].SoVOpener))
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -420);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, 0, -14, 'CENTER');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function WWMenu()
    local window = StdUi:Window(UIParent, 'Monk - Windwalker', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[269].touchofkarma);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Touch of Karma', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[269].touchofkarma = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[269].dampemharm);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Dampem Harm', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[269].dampemharm = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function PaladinProtectionMenu()
    local window = StdUi:Window(UIParent, 'Paladin - Protection', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local healthStoneValue = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    healthStoneValue:SetMinMaxValue(0, 100);
    StdUi:AddLabel(window, healthStoneValue, 'Healthstone', 'TOP');
    StdUi:GlueBelow(healthStoneValue, gn_separator, 50, -25, 'RIGHT');
    function healthStoneValue:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -25, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local racialUsage = StdUi:Checkbox(window, 'Use Racial');
    racialUsage:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(racialUsage, gn_1_0, 0, -25, 'LEFT');
    function racialUsage:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -150);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local LayOnHandEnabled = StdUi:Checkbox(window, 'Lay on Hands');
    LayOnHandEnabled:SetChecked(RubimRH.db.profile[66].lohEnabled)
    StdUi:GlueBelow(LayOnHandEnabled, sk_separator, -50, -5, 'LEFT');
    function LayOnHandEnabled:OnValueChanged(value)
        RubimRH.db.profile[66].lohEnabled = value
        print("|cFF69CCF0Lay on Hands" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[66].lohEnabled))
    end

    local lohHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[66].lohHealth);
    lohHP :SetMinMaxValue(10, 100);
    StdUi:GlueBelow(lohHP, LayOnHandEnabled, 0, 0, 'LEFT');
    function lohHP :OnValueChanged(value)
        RubimRH.db.profile[66].lohHealth = value
    end

    local ancientKingEnabled = StdUi:Checkbox(window, 'Ancient Kings');
    ancientKingEnabled:SetChecked(RubimRH.db.profile[66].akEnabled)
    StdUi:GlueBelow(ancientKingEnabled, sk_separator, 55, -5, 'RIGHT');
    function ancientKingEnabled:OnValueChanged(value)
        RubimRH.db.profile[66].akEnabled = value
        print("|cFF69CCF0Guardian of the Ancient Kings" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[66].akEnabled))
    end

    local ancientKingHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[66].akHP);
    ancientKingHP :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(ancientKingHP, ancientKingEnabled, -5, 0, 'RIGHT');
    function ancientKingHP :OnValueChanged(value)
        RubimRH.db.profile[66].akHP = value
    end

    local ArdentDefenderEnabled = StdUi:Checkbox(window, 'Ardent Defender');
    ArdentDefenderEnabled:SetChecked(RubimRH.db.profile[66].adEnabled)
    StdUi:GlueBelow(ArdentDefenderEnabled, lohHP, 0, -5, 'LEFT');
    function ArdentDefenderEnabled:OnValueChanged(value)
        RubimRH.db.profile[66].adEnabled = value
        print("|cFF69CCF0Ardent Defender" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[66].adEnabled))
    end

    local ArdentHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[66].adHP);
    ArdentHP :SetMinMaxValue(10, 100);
    StdUi:GlueBelow(ArdentHP, ArdentDefenderEnabled, 0, 0, 'LEFT');
    function ArdentHP :OnValueChanged(value)
        RubimRH.db.profile[66].adHP = value
    end

    local protectorEnabled = StdUi:Checkbox(window, 'LotP');
    protectorEnabled:SetChecked(RubimRH.db.profile[66].lotpEnabled)
    StdUi:GlueBelow(protectorEnabled, ancientKingHP, 0, -5, 'CENTER');
    function protectorEnabled:OnValueChanged(value)
        RubimRH.db.profile[66].lotpEnabled = value
        print("|cFF69CCF0Light of the Protector" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[66].lotpEnabled))
    end

    local protectorHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[66].lotpHP);
    protectorHP :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(protectorHP, protectorEnabled, -5, 0, 'CENTER');
    function protectorHP :OnValueChanged(value)
        RubimRH.db.profile[66].lotpHP = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -300);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, 0, -14, 'CENTER');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function FeralMenu()
    local window = StdUi:Window(UIParent, 'Warrior - Arms', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function VengMenu()
    local window = StdUi:Window(UIParent, 'Demon Hunter - Vengeance', 350, 500);
    window:SetPoint('CENTER');

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial)
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[581].metamorphosis);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Metamorphosis', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[581].metamorphosis = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[581].soulbarrier);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Soul Barrier', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[581].soulbarrier = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -310);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

function RubimRH.ClassConfig(specID)
    if specID == 250 then
        BloodMenu()
    end
    if specID == 251 then
        FrostMenu()
    end

    if specID == 252 then
        UnholyMenu()
    end

    if specID == 71 then
        ArmsMenu()
    end

    if specID == 72 then
        FuryMenu()
    end

    if specID == 253 then
        BMMenu()
    end

    if specID == 254 then
        MMMenu()
    end

    if specID == 255 then
        SurvivalMenu()
    end

    if specID == 70 then
        RetributionMenu()
    end

    if specID == 66 then
        PaladinProtectionMenu()
    end

    if specID == 259 then
        AssMenu()
    end

    if specID == 260 then
        OutMenu()
    end

    if specID == 261 then
        SubMenu()
    end

    if specID == 577 then
        HavocMenu()
    end

    if specID == 581 then
        VengMenu()
    end

    if specID == 269 then
        WWMenu()
    end

    if specID == 103 then
        FeralMenu()
    end
end