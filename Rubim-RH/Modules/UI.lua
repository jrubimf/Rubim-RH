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


    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -34, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial  )
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -34, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion  )
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -34, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end


    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].icebound);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0 , sk_separator, -50, -34, 'LEFT');
    StdUi:AddLabel(window, sk_1_0 , 'Icebound', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[250].icebound = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].runetap);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -34, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Runetap', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[250].runetap = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].vampiricblood);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0 , 0, -34, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Vampiric Blood', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[250].vampiricblood = value
    end

    local sk_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].drw);
    sk_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, sk_2_1, 'DRW', 'TOP');
    function sk_2_1:OnValueChanged(value)
        RubimRH.db.profile[250].drw = value
    end

    local sk_3_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].smartds);
    sk_3_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_3_0, sk_2_0, 0, -34, 'LEFT');
    StdUi:AddLabel(window, sk_3_0, 'DS (HP Percent)', 'TOP');
    function sk_3_0:OnValueChanged(value)
        RubimRH.db.profile[250].smartds = value
    end

    local sk_3_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[250].deficitds);
    sk_3_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_3_1, sk_2_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, sk_3_1, 'DS (Rune Deficit)', 'TOP');
    function sk_3_1:OnValueChanged(value)
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
end
local function FrostMenu()
    local window = StdUi:Window(UIParent, 'Death Knight - Frost', 350, 500);
    window:SetPoint('CENTER');


    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -34, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial  )
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -34, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion  )
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -34, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end


    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[251].icebound);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0 , sk_separator, -50, -34, 'LEFT');
    StdUi:AddLabel(window, sk_1_0 , 'Icebound', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[250].icebound = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -310);
    local extraSep = StdUi:FontString(window, '===================');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20 , 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -50, -34, 'LEFT');
    extra1:SetScript('OnClick', function()
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
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -34, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial  )
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -34, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion  )
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -34, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end


    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[252].icebound);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0 , sk_separator, -50, -34, 'LEFT');
    StdUi:AddLabel(window, sk_1_0 , 'Icebound', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[250].icebound = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -310);
    local extraSep = StdUi:FontString(window, '===================');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20 , 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -50, -34, 'LEFT');
    extra1:SetScript('OnClick', function()
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
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -34, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial  )
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -34, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion  )
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -34, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end


    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[71].diebythesword);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0 , sk_separator, -50, -34, 'LEFT');
    StdUi:AddLabel(window, sk_1_0 , 'Dy By The Sword', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[71].diebythesword = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[71].victoryrush);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -34, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Victory Rush', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[71].victoryrush = value
    end

    local sk_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[71].rallyingcry);
    sk_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, sk_2_1, 'DRW', 'TOP');
    function sk_2_1:OnValueChanged(value)
        RubimRH.db.profile[71].rallyingcry = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20 , 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -34, 'LEFT');
    extra1:SetScript('OnClick', function()
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
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -34, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial  )
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -34, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion  )
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -34, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end


    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[71].rallyingcry);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0 , sk_separator, -50, -34, 'LEFT');
    StdUi:AddLabel(window, sk_1_0 , 'Rallying Cry', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[71].rallyingcry = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[71].victoryrush);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -34, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Victory Rush', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[71].victoryrush = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20 , 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -34, 'LEFT');
    extra1:SetScript('OnClick', function()
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
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -34, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial  )
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -34, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion  )
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -34, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end


    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[254].exhilaration);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0 , sk_separator, -50, -34, 'LEFT');
    StdUi:AddLabel(window, sk_1_0 , 'Exhilaration', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[71].rallyingcry = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[254].aspectoftheturtle);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -34, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Aspect of the Turtle', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[71].victoryrush = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20 , 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -34, 'LEFT');
    extra1:SetScript('OnClick', function()
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
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -34, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial  )
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -34, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion  )
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -34, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end


    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[255].mendpet);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0 , sk_separator, -50, -34, 'LEFT');
    StdUi:AddLabel(window, sk_1_0 , 'Mend Pet', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[71].rallyingcry = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[255].aspectoftheturtle);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -34, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Aspect of the Turtle', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[71].victoryrush = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20 , 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -34, 'LEFT');
    extra1:SetScript('OnClick', function()
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
    gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack  )
    StdUi:GlueBelow(gn_1_0, gn_separator, -50, -34, 'LEFT');
    function gn_1_0:OnValueChanged(value)
        RubimRH.AttackToggle()
    end

    local gn_1_1 = StdUi:Checkbox(window, 'Use Racial');
    gn_1_1:SetChecked(RubimRH.db.profile.mainOption.useRacial  )
    StdUi:GlueBelow(gn_1_1, gn_separator, 50, -34, 'RIGHT');
    function gn_1_1:OnValueChanged(value)
        RubimRH.RacialToggle()
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion  )
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -34, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile.mainOption.healthstoneper);
    gn_2_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -34, 'RIGHT');
    StdUi:AddLabel(window, gn_2_1, 'Healthstone', 'TOP');
    function gn_2_1:OnValueChanged(value)
        RubimRH.db.profile.mainOption.healthstoneper = value
    end


    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Defensive Cooldowns');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[253].mendpet);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0 , sk_separator, -50, -34, 'LEFT');
    StdUi:AddLabel(window, sk_1_0 , 'Mend Pet', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[71].rallyingcry = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[253].aspectoftheturtle);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -34, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Aspect of the Turtle', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[71].victoryrush = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 100, 20 , 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -34, 'LEFT');
    extra1:SetScript('OnClick', function()
        RubimRH.SpellBlocker()
    end);
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
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.plRet)
        InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.plRet)
    end

    if specID == 260 then
        OutlawMenu()
    end
end