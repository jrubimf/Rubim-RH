local HL = HeroLib;
local Cache = HeroCache;
local StdUi = LibStub('StdUi')
local AceGUI = LibStub("AceGUI-3.0")

function AllMenu(selectedTab, point, relativeTo, relativePoint, xOfs, yOfs)
    local window = StdUi:Window(UIParent, 'Class Config', 450, 500);

    window:SetPoint('CENTER');

    if point ~= nil then
        window:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local tabs = {
        {
            name = 'firstTab',
            title = 'General',
        },
        {
            name = 'secondTab',
            title = select(2, GetSpecializationInfo(GetSpecialization())),
        },
        {
            name = 'thirdTab',
            title = 'Spells',
        },
        {
            name = 'forthTab',
            title = 'Extra Info',
        },
    }
    local tabFrame = StdUi:TabPanel(window, nil, nil, tabs);
    StdUi:GlueAcross(tabFrame, window, 10, -40, -10, 20);

    if selectedTab ~= nil then
        tabFrame:SelectTab(selectedTab)
    end

    tabFrame:EnumerateTabs(function(tab)
        if tab.title == "General" then
            local gn_title = StdUi:FontString(tab.frame, 'Interface');
            StdUi:GlueTop(gn_title, tab.frame, 0, -10);
            local gn_separator = StdUi:FontString(tab.frame, '===================');
            StdUi:GlueTop(gn_separator, gn_title, 0, -12);

            local config1_0 = StdUi:Checkbox(tab.frame, 'Glow Action Bar');
            StdUi:GlueTop(config1_0, gn_separator, -50, -24, 'LEFT');
            config1_0:SetChecked(RubimRH.db.profile.mainOption.glowactionbar)
            function config1_0:OnValueChanged(self, state, value)
                RubimRH.GlowActionBarToggle()
            end

            local config1_1 = StdUi:Checkbox(tab.frame, 'Mute Sounds');
            StdUi:GlueTop(config1_1, gn_separator, 50, -24, 'RIGHT');
            config1_1:SetChecked(RubimRH.db.profile.mainOption.mute)
            function config1_1:OnValueChanged(self, state, value)
                RubimRH.MuteToggle()
            end

            local config2_0 = StdUi:Checkbox(tab.frame, 'Debug Verbose');
            StdUi:GlueTop(config2_0, config1_0, 0, -24, 'LEFT');
            config2_0:SetChecked(RubimRH.db.profile.mainOption.debug)
            function config2_0:OnValueChanged(self, state, value)
                RubimRH.DebugToggle()
            end

            local ic_title = StdUi:FontString(tab.frame, 'Icon');
            StdUi:GlueTop(ic_title, tab.frame, 0, -110);
            local ic_separator = StdUi:FontString(tab.frame, '===================');
            StdUi:GlueTop(ic_separator, ic_title, 0, -12);

            local ic_1_0 = StdUi:Checkbox(tab.frame, 'Lock Icon');
            StdUi:GlueTop(ic_1_0, ic_separator, -50, -24, 'LEFT');
            ic_1_0:SetChecked(RubimRH.db.profile.mainOption.mainIconLock)
            function ic_1_0:OnValueChanged(self, state, value)
                RubimRH.MainIconLockToggle()
            end

            local ic_1_1 = StdUi:Checkbox(tab.frame, 'Enable Icon');
            StdUi:GlueTop(ic_1_1, ic_separator, 50, -24, 'RIGHT');
            ic_1_1:SetChecked(RubimRH.db.profile.mainOption.mainIcon)
            function ic_1_1:OnValueChanged(self, state, value)
                RubimRH.MainIconToggle()
            end

            local ic_2_0 = StdUi:Checkbox(tab.frame, 'Hide Texture');
            StdUi:GlueTop(ic_2_0, ic_1_0, 0, -24, 'LEFT');
            ic_2_0:SetChecked(RubimRH.db.profile.mainOption.hidetexture)
            function ic_2_0:OnValueChanged(self, state, value)
                RubimRH.HideTextureToggle()
            end

            local ic_2_1 = StdUi:Checkbox(tab.frame, 'Debug Verbose');
            StdUi:GlueTop(ic_2_1, ic_1_1, 0, -24, 'RIGHT');
            ic_2_1:SetChecked(RubimRH.db.profile.mainOption.glowactionbar)
            function ic_2_1:OnValueChanged(self, state, value)
                RubimRH.GlowActionBarToggle()
            end

            ic_2_1:Hide()

            local ic_3_0 = StdUi:Slider(tab.frame, 125, 16, RubimRH.db.profile.mainOption.mainIconOpacity, false, 0, 100)
            StdUi:GlueBelow(ic_3_0, ic_2_0, 0, -24, 'LEFT');
            local config3_1Label = StdUi:FontString(tab.frame, "Icon Opacity: " .. RubimRH.db.profile.mainOption.mainIconOpacity)
            StdUi:GlueTop(config3_1Label, ic_3_0, 0, 16);
            StdUi:FrameTooltip(ic_3_0, "Controls the opacity of the main icon", 'TOPLEFT', 'TOPRIGHT', true);
            function ic_3_0:OnValueChanged(value)
                value = (math.floor((value * ((100) + 0.5)) / (100)))
                RubimRH.db.profile.mainOption.mainIconOpacity = value
                ic_3_0 = value
                config3_1Label:SetText("Icon Opacity: " .. RubimRH.db.profile.mainOption.mainIconOpacity)
            end

            local ic_3_1 = StdUi:Slider(tab.frame, 125, 16, RubimRH.db.profile.mainOption.mainIconScale / 10, false, 5, 75)
            StdUi:GlueBelow(ic_3_1, ic_2_1, 0, -24, 'RIGT');
            local config3_1Label = StdUi:FontString(tab.frame, "Icon Size: " .. RubimRH.db.profile.mainOption.mainIconScale)
            StdUi:GlueTop(config3_1Label, ic_3_1, 0, 16);
            StdUi:FrameTooltip(ic_3_1, "Controls the opacity of the main icon", 'TOPLEFT', 'TOPRIGHT', true);
            function ic_3_1:OnValueChanged(value)
                local value = math.floor(value) * 10
                RubimRH.db.profile.mainOption.mainIconScale = value
                ic_3_1 = value
                config3_1Label:SetText("Icon Size: " .. RubimRH.db.profile.mainOption.mainIconScale)
            end

            local ex_title = StdUi:FontString(tab.frame, 'Extra');
            StdUi:GlueTop(ex_title, tab.frame, 0, -250);
            local ex_separator = StdUi:FontString(tab.frame, '===================');
            StdUi:GlueTop(ex_separator, ex_title, 0, -12);

            local ex_title = StdUi:FontString(tab.frame, 'Keybind section was moved to the WoW Keybind interface.\nESC -> KEY BINDING > RUBIMRH');
            StdUi:GlueBelow(ex_title, ex_separator, 0, -25, "CENTER");


        end
        if tab.title == select(2, GetSpecializationInfo(GetSpecialization())) then
            local sk1 = RubimRH.db.profile[RubimRH.playerSpec].sk1 or -1
            local sk1id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk1id) or RubimRH.db.profile[RubimRH.playerSpec].sk1id or "") .. ": "
            local sk1tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk1tooltip or ""

            local sk2 = RubimRH.db.profile[RubimRH.playerSpec].sk2 or -1
            local sk2id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk2id) or RubimRH.db.profile[RubimRH.playerSpec].sk2id or "") .. ": "
            local sk2tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk2tooltip or ""

            local sk3 = RubimRH.db.profile[RubimRH.playerSpec].sk3 or -1
            local sk3id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk3id) or RubimRH.db.profile[RubimRH.playerSpec].sk3id or "") .. ": "
            local sk3tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk3tooltip or ""

            local sk4 = RubimRH.db.profile[RubimRH.playerSpec].sk4 or -1
            local sk4id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk4id) or RubimRH.db.profile[RubimRH.playerSpec].sk4id or "") .. ": "
            local sk4tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk4tooltip or ""

            local sk5 = RubimRH.db.profile[RubimRH.playerSpec].sk5 or -1
            local sk5id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk5id) or RubimRH.db.profile[RubimRH.playerSpec].sk5id or "") .. ": "
            local sk5tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk5tooltip or ""

            local sk6 = RubimRH.db.profile[RubimRH.playerSpec].sk6 or -1
            local sk6id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk6id) or RubimRH.db.profile[RubimRH.playerSpec].sk6id or "") .. ": "
            local sk6tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk6tooltip or ""

            local windowHeight = 380
            local extraPosition = -280
            if sk3 >= 0 then
                windowHeight = 428
                extraPosition = -328
            end
            if sk6 >= 0 then
                windowHeight = 456
                extraPosition = -368
            end

            --local window = StdUi:Window(UIParent, select(2, UnitClass("player")) .. " - " .. select(2, GetSpecializationInfo(GetSpecialization())), 350, windowHeight);
            --window:SetPoint('CENTER');
            --if point ~= nil then
            --window:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
            --end

            local gn_title = StdUi:FontString(tab.frame, select(2, UnitClass("player")) .. " - " .. select(2, GetSpecializationInfo(GetSpecialization())));
            StdUi:GlueTop(gn_title, tab.frame, 0, -10);
            local gn_separator = StdUi:FontString(tab.frame, '===================');
            StdUi:GlueTop(gn_separator, gn_title, 0, -12);

            local gn_1_0 = StdUi:Checkbox(tab.frame, 'Auto Next Target');
            StdUi:FrameTooltip(gn_1_0, 'When you are in combat, it will suggest skills even without a target.', 'TOPLEFT', 'TOPRIGHT', true);
            gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
            StdUi:GlueBelow(gn_1_0, gn_separator, -50, -24, 'LEFT');
            function gn_1_0:OnValueChanged(value)
                RubimRH.AttackToggle()
            end

            local trinketOptions = {
                { text = 'Trinket 1', value = 1 },
                { text = 'Trinket 2', value = 2 },
            }

            local gn_1_1 = StdUi:Dropdown(tab.frame, 125, 20, trinketOptions, nil, true);
            gn_1_1:SetPlaceholder(' -- Trinkets --');
            item1 = gn_1_1.optsFrame.scrollChild.items[1]
            item2 = gn_1_1.optsFrame.scrollChild.items[2]
            StdUi:GlueBelow(gn_1_1, gn_separator, 50, -24, 'RIGHT');
            gn_1_1.OnValueChanged = function(self, value)
                local option1, option2 = unpack(value)

                if option1 == 1 or option2 == 1 then
                    RubimRH.db.profile.mainOption.useTrinkets[1] = true
                end

                if option1 == 2 or option2 == 2 then
                    RubimRH.db.profile.mainOption.useTrinkets[2] = true
                end

            end;

            if RubimRH.db.profile.mainOption.useTrinkets[1] == true then
                gn_1_1:ToggleValue(1, true)
                gn_1_1.optsFrame.scrollChild.items[1]:SetChecked(true)
            end

            if RubimRH.db.profile.mainOption.useTrinkets[2] == true then
                gn_1_1:ToggleValue(2, true)
                gn_1_1.optsFrame.scrollChild.items[2]:SetChecked(true)
            end

            local gn_2_0 = StdUi:Checkbox(tab.frame, 'Use Potion');
            StdUi:FrameTooltip(gn_2_0, 'For now this is depreciated.', 'TOPLEFT', 'TOPRIGHT', true);
            gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
            StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
            function gn_2_0:OnValueChanged(value)
                RubimRH.PotionToggle()
            end

            local gn_2_1 = StdUi:Slider(tab.frame, 125, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
            StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
            local gn_2_1Label = StdUi:FontString(tab.frame, 'Healthstone: |cff00ff00' .. RubimRH.db.profile.mainOption.healthstoneper);

            StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
            StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
            function gn_2_1:OnValueChanged(value)
                local value = math.floor(value) * 2.5
                RubimRH.db.profile.mainOption.healthstoneper = value
                gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
            end

            local gn_3_0 = StdUi:Checkbox(tab.frame, 'Burst CD');
            gn_3_0:SetChecked(RubimRH.db.profile.mainOption.burstCD)
            StdUi:FrameTooltip(gn_3_0, "This will make the CD to be turned off after 10 seconds.\n\nUseful if you want a Burst button.", 'TOPLEFT', 'TOPRIGHT', true);
            function gn_3_0:OnValueChanged(value)
                RubimRH.burstCDToggle()
            end
            StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');

            local cdOptions = {
                { text = 'Everything', value = "Everything" },
                { text = 'Boss Only', value = "Boss Only" },
            }
            local gn_3_1 = StdUi:Dropdown(tab.frame, 125, 20, cdOptions, nil, nil);
            StdUi:FrameTooltip(gn_3_1, 'Everything - Every mob available\nBosses - Only Bosses or Rares', 'TOPLEFT', 'TOPRIGHT', true);
            gn_3_1:SetPlaceholder("|cfff0f8ffCD: |r" .. RubimRH.db.profile.mainOption.cooldownsUsage);
            gn_3_1.OnValueChanged = function(self, val)
                RubimRH.db.profile.mainOption.cooldownsUsage = val
                if val == "Everything" then
                    print("CDs will be used on every mob")
                else
                    print("CDs will only be used on Bosses/Rares")
                end
                gn_3_1:SetText("|cfff0f8ffCD: |r" .. RubimRH.db.profile.mainOption.cooldownsUsage);
            end
            StdUi:GlueBelow(gn_3_1, gn_2_1, 0, -24, 'RIGHT');

            --------------------------------------------------
            local sk_title = StdUi:FontString(tab.frame, 'Class Specific');
            StdUi:GlueTop(sk_title, tab.frame, 0, -190);
            local sk_separator = StdUi:FontString(tab.frame, '===================');
            StdUi:GlueTop(sk_separator, sk_title, 0, -12);

            local sk_1_0
            if sk1 >= 0 then
                sk_1_0 = StdUi:Slider(tab.frame, 125, 16, sk1 / 2.5, false, 0, 40)
                StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
                local sk_1_0Label = StdUi:FontString(tab.frame, sk1id .. sk1);
                StdUi:GlueTop(sk_1_0Label, sk_1_0, 0, 16);
                StdUi:FrameTooltip(sk_1_0, sk1tooltip, 'TOPLEFT', 'TOPRIGHT', true);
                function sk_1_0:OnValueChanged(value)
                    local value = math.floor(value) * 2.5
                    RubimRH.db.profile[RubimRH.playerSpec].sk1 = value
                    sk1 = value
                    sk_1_0Label:SetText(sk1id .. sk1)
                end
            end

            local sk_1_1
            if sk2 >= 0 then
                sk_1_1 = StdUi:Slider(tab.frame, 125, 16, sk2 / 2.5, false, 0, 40)
                StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
                local sk_1_1Label = StdUi:FontString(tab.frame, sk2id .. sk2);
                StdUi:GlueTop(sk_1_1Label, sk_1_1, 0, 16);
                StdUi:FrameTooltip(sk_1_1, sk2tooltip, 'TOPLEFT', 'TOPRIGHT', true);
                function sk_1_1:OnValueChanged(value)
                    local value = math.floor(value) * 2.5
                    RubimRH.db.profile[RubimRH.playerSpec].sk2 = value
                    sk2 = value
                    sk_1_1Label:SetText(sk2id .. sk2)
                end
            end

            local sk_2_0
            if sk3 >= 0 then
                sk_2_0 = StdUi:Slider(tab.frame, 125, 16, sk3 / 2.5, false, 0, 40)
                StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
                local sk_2_0Label = StdUi:FontString(tab.frame, sk3id .. sk3);
                StdUi:GlueTop(sk_2_0Label, sk_2_0, 0, 16);
                StdUi:FrameTooltip(sk_2_0, sk3tooltip, 'TOPLEFT', 'TOPRIGHT', true);
                function sk_2_0:OnValueChanged(value)
                    local value = math.floor(value) * 2.5
                    RubimRH.db.profile[RubimRH.playerSpec].sk3 = value
                    sk3 = value
                    sk_2_0Label:SetText(sk3id .. sk3)
                end
            end

            --ROGUE Sub
            if RubimRH.playerSpec == Subtlety or RubimRH.playerSpec == Assassination or RubimRH.playerSpec == Outlaw then
                local sk_2_1 = StdUi:Checkbox(tab.frame, "Vanish Attack");
                sk_2_1:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].vanishattack)
                StdUi:GlueBelow(sk_2_1, sk_1_1, 15, -24, 'RIGHT');
                function sk_2_1:OnValueChanged(value)
                    if RubimRH.db.profile[RubimRH.playerSpec].vanishattack then
                        RubimRH.db.profile[RubimRH.playerSpec].vanishattack = false
                    else
                        RubimRH.db.profile[RubimRH.playerSpec].vanishattack = true
                    end
                end

                if RubimRH.playerSpec == Outlaw then
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

                    local diceRoll = StdUi:Dropdown(tab.frame, 125, 24, dice, 1);
                    StdUi:GlueBelow(diceRoll, sk_1_0, 0, -64, 'LEFT');
                    StdUi:AddLabel(tab.frame, diceRoll, 'Roll the Bones', 'TOP');
                    function diceRoll:OnValueChanged(value)
                        RubimRH.db.profile[RubimRH.playerSpec].dice = self:GetText()
                        print("Roll the Bones: " .. RubimRH.db.profile[RubimRH.playerSpec].dice)
                    end
                end

            end

            local sk_2_1
            if sk4 >= 0 then
                sk_2_1 = StdUi:Slider(tab.frame, 125, 16, sk4 / 2.5, false, 0, 40)
                StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -24, 'RIGHT');
                local sk_2_1Label = StdUi:FontString(tab.frame, sk4id .. sk4);
                StdUi:GlueTop(sk_2_1Label, sk_2_1, 0, 16);
                StdUi:FrameTooltip(sk_2_1, sk4tooltip, 'TOPLEFT', 'TOPRIGHT', true);
                function sk_2_1:OnValueChanged(value)
                    local value = math.floor(value) * 2.5
                    RubimRH.db.profile[RubimRH.playerSpec].sk4 = value
                    sk4 = value
                    sk_2_1Label:SetText(sk4id .. sk4)
                end

            end

            if sk5 >= 0 then
                local sk_3_0 = StdUi:Slider(tab.frame, 125, 16, sk5 / 2.5, false, 0, 40)
                StdUi:GlueBelow(sk_3_0, sk_2_0, 0, -24, 'LEFT');
                local sk_3_0Label = StdUi:FontString(tab.frame, sk5id .. sk5);
                StdUi:GlueTop(sk_3_0Label, sk_3_0, 0, 16);
                StdUi:FrameTooltip(sk_3_0, sk5tooltip, 'TOPLEFT', 'TOPRIGHT', true);
                function sk_3_0:OnValueChanged(value)
                    local value = math.floor(value) * 2.5
                    RubimRH.db.profile[RubimRH.playerSpec].sk5 = value
                    sk5 = value
                    sk_3_0Label:SetText(sk5id .. sk5)
                end
            end

            if sk6 >= 0 then
                local sk_3_1 = StdUi:Slider(tab.frame, 125, 16, sk6 / 2.5, false, 0, 40)
                StdUi:GlueBelow(sk_3_1, sk_2_1, 0, -24, 'RIGHT');
                local sk_3_1Label = StdUi:FontString(tab.frame, sk6id .. sk6);
                StdUi:GlueTop(sk_3_1Label, sk_3_1, 0, 16);
                StdUi:FrameTooltip(sk_3_1, sk6tooltip, 'TOPLEFT', 'TOPRIGHT', true);
                function sk_3_1:OnValueChanged(value)
                    local value = math.floor(value) * 2.5
                    RubimRH.db.profile[RubimRH.playerSpec].sk6 = value
                    sk6 = value
                    sk_3_1Label:SetText(sk6id .. sk6)
                end
            end

        end
        if tab.title == "Spells" then
            local spellBlocker_title = StdUi:FontString(tab.frame, 'Spell Blocker');
            StdUi:GlueTop(spellBlocker_title, tab.frame, 0, -10, 'CENTER');

            local function showTooltip(frame, show, spellId)
                if show then
                    GameTooltip:SetOwner(frame);
                    GameTooltip:SetPoint('RIGHT');
                    GameTooltip:SetSpellByID(spellId)
                else
                    GameTooltip:Hide();
                end

            end

            local data = {};
            local cols = {

                {
                    name = 'Enabled',
                    width = 60,
                    align = 'LEFT',
                    index = 'enabled',
                    format = 'string',
                    color = function(table, value, rowData, columnData)
                        if value == "True" then
                            return { r = 0, g = 1, b = 0, a = 1 }
                        end
                        if value == "False" then
                            return { r = 1, g = 0, b = 0, a = 1 }
                        end
                    end
                },

                {
                    name = 'Spell ID',
                    width = 60,
                    align = 'LEFT',
                    index = 'spellId',
                    format = 'number',
                    color = function(table, value)
                        --local x = value / 200000;
                        --return { r = x, g = 1 - x, b = 0, a = 1 };
                    end
                },
                {
                    name = 'Spell Name',
                    width = 160,
                    align = 'LEFT',
                    index = 'name',
                    format = 'string',
                },

                {
                    name = 'Icon',
                    width = 40,
                    align = 'LEFT',
                    index = 'icon',
                    format = 'icon',
                    sortable = false,
                    events = {
                        OnEnter = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                            local cellData = rowData[columnData.index];
                            showTooltip(cellFrame, true, rowData.spellId);
                            return false;
                        end,
                        OnLeave = function(rowFrame, cellFrame)
                            showTooltip(cellFrame, false);
                            return false;
                        end,
                    },
                },
            }

            local st = StdUi:ScrollTable(tab.frame, cols, 12, 20);
            st:EnableSelection(true);
            StdUi:GlueTop(st, tab.frame, 0, -60);

            local function getRandomSpell()
                local name = nil;
                local icon, castTime, minRange, maxRange, spellId;

                while name == nil do
                    name, _, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(math.random(100, 200000));
                end

                return {
                    enabled = "True",
                    name = GetSpellLink(spellId),
                    icon = icon,
                    castTime = castTime,
                    minRange = minRange,
                    maxRange = maxRange,
                    spellId = spellId;
                };
            end

            local function addSpell(spellID)
                local name = nil;
                local icon, castTime, minRange, maxRange, spellId;

                name, _, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spellID);
                local enabled = "True"
                if RubimRH.db.profile.mainOption.disabledSpells[spellID] == true then
                    enabled = "False"
                end

                return {
                    enabled = enabled,
                    name = name,
                    icon = icon,
                    castTime = castTime,
                    minRange = minRange,
                    maxRange = maxRange,
                    spellId = spellId;
                };
            end

            local data = {};

            for i, spell in pairs(RubimRH.allSpells) do
                    tinsert(data, addSpell(spell.SpellID));
            end

            -- update scroll table data
            st:SetData(data);

            local function btn_blockSpell()
                if data[st:GetSelection()] ~= nil then
                    local spellID = data[st:GetSelection()].spellId
                    if RubimRH.db.profile.mainOption.disabledSpells[spellID] ~= nil then
                        RubimRH.db.profile.mainOption.disabledSpells[spellID] = nil
                        data[st:GetSelection()].enabled = "True"
                        print("Removed: " .. GetSpellLink(spellID))
                    else
                        RubimRH.db.profile.mainOption.disabledSpells[spellID] = true
                        print("Added: " .. GetSpellLink(spellID))
                        data[st:GetSelection()].enabled = "False"
                    end
                    RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\button.ogg")
                    --window:Hide()
                    --local point, relativeTo, relativePoint, xOfs, yOfs = window:GetPoint()
                    --AllMenu("thirdTab", point, relativeTo, relativePoint, xOfs, yOfs)
                    --RubimRH.SpellBlocker(nil, point, relativeTo, relativePoint, xOfs, yOfs)
                    --

                    return
                end
                print("No Spell Selected")
            end

            local function btn_createMacro()
                if data[st:GetSelection()] ~= nil then
                    local SpellDATA = data[st:GetSelection()]
                    local SpellVAR = nil

                    for i = 1, #RubimRH.allSpells do
                        if RubimRH.allSpells[i].SpellID == SpellDATA.spellId then
                            SpellVAR = i
                            break
                        end
                    end
                    RubimRH.print("Macro for: " .. GetSpellLink(SpellDATA.spellId) .. " was created. Check your Character Macros.")
                    CreateMacro(SpellDATA.name, SpellDATA.icon, "/run RubimRH.allSpells[" .. tostring(SpellVAR) .. "]:Queue()", 1)
                    RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\button.ogg")
                    return
                end
                print("No Spell Selected")
            end

            local btn = StdUi:Button(tab.frame, 125, 24, 'Block Spell');
            StdUi:GlueBelow(btn, st, 0, -24, "LEFT");
            btn:SetScript('OnClick', btn_blockSpell);
            StdUi:FrameTooltip(btn, 'This will block the spell from the spellist of the rotation aka it will never cast it.', 'TOPLEFT', 'TOPRIGHT', true);

            local btn2 = StdUi:Button(tab.frame, 125, 24, 'Create Macro');
            StdUi:GlueBelow(btn2, st, 0, -24, "RIGHT");
            btn2:SetScript('OnClick', btn_createMacro);
            StdUi:FrameTooltip(btn2, 'This will create a Queue macro :).', 'TOPLEFT', 'TOPRIGHT', true);

            --local blockingTip = StdUi:FontString(tab.frame, 'You can macro the spell blocker by using:\n/run RubimRH.SpellBlocker(spellID)');
            --StdUi:GlueTop(blockingTip, btn, 0, -30);
        end
    end);
end

function RubimRH.SpellBlocker(spellID, point, relativeTo, relativePoint, xOfs, yOfs)
    if spellID ~= nil then
        if RubimRH.db.profile.mainOption.disabledSpells[spellID] ~= nil then
            RubimRH.db.profile.mainOption.disabledSpells[spellID] = nil
            print("Removed: " .. GetSpellLink(spellID))
        else
            RubimRH.db.profile.mainOption.disabledSpells[spellID] = true
            print("Added: " .. GetSpellLink(spellID))
        end
        return
    end

    local window = StdUi:Window(UIParent, 'Spell Blocker', 500, 500);
    window:SetPoint('CENTER');
    if point ~= nil then
        window:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local function showTooltip(frame, show, spellId)
        if show then
            GameTooltip:SetOwner(frame);
            GameTooltip:SetPoint('RIGHT');
            GameTooltip:SetSpellByID(spellId)
        else
            GameTooltip:Hide();
        end

    end

    local data = {};
    local cols = {

        {
            name = 'Enabled',
            width = 60,
            align = 'LEFT',
            index = 'enabled',
            format = 'string',
            color = function(table, value, rowData, columnData)
                if value == "True" then
                    return { r = 0, g = 1, b = 0, a = 1 }
                end
                if value == "False" then
                    return { r = 1, g = 0, b = 0, a = 1 }
                end
            end
        },

        {
            name = 'Spell Id',
            width = 60,
            align = 'LEFT',
            index = 'spellId',
            format = 'number',
            color = function(table, value)
                --local x = value / 200000;
                --return { r = x, g = 1 - x, b = 0, a = 1 };
            end
        },
        {
            name = 'Text',
            width = 180,
            align = 'LEFT',
            index = 'name',
            format = 'string',
        },

        {
            name = 'Icon',
            width = 40,
            align = 'LEFT',
            index = 'icon',
            format = 'icon',
            sortable = false,
            events = {
                OnEnter = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                    local cellData = rowData[columnData.index];
                    showTooltip(cellFrame, true, rowData.spellId);
                    return false;
                end,
                OnLeave = function(rowFrame, cellFrame)
                    showTooltip(cellFrame, false);
                    return false;
                end,
            },
        },
    }

    local st = StdUi:ScrollTable(window, cols, 14, 24);
    st:EnableSelection(true);
    StdUi:GlueTop(st, window, 0, -60);

    local function getRandomSpell()
        local name = nil;
        local icon, castTime, minRange, maxRange, spellId;

        while name == nil do
            name, _, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(math.random(100, 200000));
        end

        return {
            enabled = "True",
            name = name,
            icon = icon,
            castTime = castTime,
            minRange = minRange,
            maxRange = maxRange,
            spellId = spellId;
        };
    end

    local function addSpell(spellID)
        local name = nil;
        local icon, castTime, minRange, maxRange, spellId;

        name, _, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spellID);
        local enabled = "True"
        if RubimRH.db.profile.mainOption.disabledSpells[spellID] == true then
            enabled = "False"
        end

        return {
            enabled = enabled,
            name = name,
            icon = icon,
            castTime = castTime,
            minRange = minRange,
            maxRange = maxRange,
            spellId = spellId;
        };
    end

    local data = {};

    for i, spell in pairs(RubimRH.Spell[RubimRH.playerSpec]) do
        if spell:IsAvailable() then
            tinsert(data, addSpell(spell.SpellID));
        end
    end

    -- update scroll table data
    st:SetData(data);

    local function btn_blockSpell()
        if data[st:GetSelection()].spellId ~= nil then
            local spellID = data[st:GetSelection()].spellId
            if RubimRH.db.profile.mainOption.disabledSpells[spellID] ~= nil then
                RubimRH.db.profile.mainOption.disabledSpells[spellID] = nil
                print("Removed: " .. GetSpellLink(spellID))
            else
                RubimRH.db.profile.mainOption.disabledSpells[spellID] = true
                print("Added: " .. GetSpellLink(spellID))
            end
            st:ClearSelection()

            --
            window:Hide();
            local point, relativeTo, relativePoint, xOfs, yOfs = window:GetPoint()
            RubimRH.SpellBlocker(nil, point, relativeTo, relativePoint, xOfs, yOfs)
            --

            return
        end
        print("No Spell Selected")
    end

    local btn = StdUi:Button(window, 100, 24, 'Block Spell');
    StdUi:GlueBelow(btn, st, 0, -20);

    btn:SetScript('OnClick', btn_blockSpell);

    local blockingTip = StdUi:FontString(window, 'You can macro the spell blocker by using:\n/run RubimRH.SpellBlocker(spellID)');
    StdUi:GlueTop(blockingTip, btn, 0, -30);

end

testTable = {}
function RubimRH.SpellBlocker2(spellID, point, relativeTo, relativePoint, xOfs, yOfs)
    if spellID ~= nil then
        if RubimRH.db.profile.mainOption.disabledSpells[spellID] ~= nil then
            RubimRH.db.profile.mainOption.disabledSpells[spellID] = nil
            print("Removed: " .. GetSpellLink(spellID))
        else
            RubimRH.db.profile.mainOption.disabledSpells[spellID] = true
            print("Added: " .. GetSpellLink(spellID))
        end
        return
    end

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
            print("Added: " .. GetSpellLink(val))
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
                print("Removed: " .. GetSpellLink(val))
            else
                table.insert(RubimRH.db.profile.mainOption.disabledSpells, { text = GetSpellInfo(val), value = val })
                print("Added: " .. GetSpellLink(val))
            end
        end
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        RubimRH.SpellBlocker(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local extra1 = StdUi:Button(window, 125, 20, 'Clear');
    StdUi:GlueBelow(extra1, spellList, 0, -24, 'CENTER');
    extra1:SetScript('OnClick', function()
        print("RubimRH: Disabled spells cleared.")
        RubimRH.db.profile.mainOption.disabledSpells = {}
    end);
end

local function AllMenuOLD(point, relativeTo, relativePoint, xOfs, yOfs)
    local sk1 = RubimRH.db.profile[RubimRH.playerSpec].sk1 or -1
    local sk1id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk1id) or RubimRH.db.profile[RubimRH.playerSpec].sk1id or "") .. ": "
    local sk1tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk1tooltip or ""

    local sk2 = RubimRH.db.profile[RubimRH.playerSpec].sk2 or -1
    local sk2id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk2id) or RubimRH.db.profile[RubimRH.playerSpec].sk2id or "") .. ": "
    local sk2tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk2tooltip or ""

    local sk3 = RubimRH.db.profile[RubimRH.playerSpec].sk3 or -1
    local sk3id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk3id) or RubimRH.db.profile[RubimRH.playerSpec].sk3id or "") .. ": "
    local sk3tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk3tooltip or ""

    local sk4 = RubimRH.db.profile[RubimRH.playerSpec].sk4 or -1
    local sk4id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk4id) or RubimRH.db.profile[RubimRH.playerSpec].sk4id or "") .. ": "
    local sk4tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk4tooltip or ""

    local sk5 = RubimRH.db.profile[RubimRH.playerSpec].sk5 or -1
    local sk5id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk5id) or RubimRH.db.profile[RubimRH.playerSpec].sk5id or "") .. ": "
    local sk5tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk5tooltip or ""

    local sk6 = RubimRH.db.profile[RubimRH.playerSpec].sk6 or -1
    local sk6id = (GetSpellInfo(RubimRH.db.profile[RubimRH.playerSpec].sk6id) or RubimRH.db.profile[RubimRH.playerSpec].sk6id or "") .. ": "
    local sk6tooltip = RubimRH.db.profile[RubimRH.playerSpec].sk6tooltip or ""

    local windowHeight = 380
    local extraPosition = -280
    if sk3 >= 0 then
        windowHeight = 428
        extraPosition = -328
    end
    if sk6 >= 0 then
        windowHeight = 456
        extraPosition = -368
    end

    local window = StdUi:Window(UIParent, select(2, UnitClass("player")) .. " - " .. select(2, GetSpecializationInfo(GetSpecialization())), 350, windowHeight);
    window:SetPoint('CENTER');
    if point ~= nil then
        window:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_title = StdUi:FontString(window, 'General');
    StdUi:GlueTop(gn_title, window, 0, -30);
    local gn_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(gn_separator, gn_title, 0, -12);

    local gn_1_0 = StdUi:Checkbox(window, 'Auto Target');
    StdUi:FrameTooltip(gn_1_0, 'Will try to use skills even without a target.', 'TOPLEFT', 'TOPRIGHT', true);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);
    StdUi:FrameTooltip(gn_1_1, 'Enable/Disable the usage of trinkets.', 'TOPLEFT', 'TOPRIGHT', true);
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
        AllMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    StdUi:FrameTooltip(gn_2_0, 'For now this is depreciated.', 'TOPLEFT', 'TOPRIGHT', true);
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local gn_3_0 = StdUi:Checkbox(window, 'Burst CD');
    gn_3_0:SetChecked(RubimRH.db.profile.mainOption.burstCD)
    StdUi:FrameTooltip(gn_3_0, "This will make the CD to be turned off after 10 seconds.\n\nUseful if you want a Burst button.", 'TOPLEFT', 'TOPRIGHT', true);
    function gn_3_0:OnValueChanged(value)
        RubimRH.burstCDToggle()
    end
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_1 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);
    StdUi:FrameTooltip(gn_3_1, 'Everything - Every mob available\nBosses - Only Bosses or Rares', 'TOPLEFT', 'TOPRIGHT', true);
    gn_3_1:SetPlaceholder('-- CDs  --');
    gn_3_1.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        AllMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end
    StdUi:GlueBelow(gn_3_1, gn_2_1, 0, -24, 'RIGHT');

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0
    if sk1 >= 0 then
        sk_1_0 = StdUi:Slider(window, 100, 16, sk1 / 2.5, false, 0, 40)
        StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
        local sk_1_0Label = StdUi:FontString(window, sk1id .. sk1);
        StdUi:GlueTop(sk_1_0Label, sk_1_0, 0, 16);
        StdUi:FrameTooltip(sk_1_0, sk1tooltip, 'TOPLEFT', 'TOPRIGHT', true);
        function sk_1_0:OnValueChanged(value)
            local value = math.floor(value) * 2.5
            RubimRH.db.profile[RubimRH.playerSpec].sk1 = value
            sk1 = value
            sk_1_0Label:SetText(sk1id .. sk1)
        end
    end

    local sk_1_1
    if sk2 >= 0 then
        sk_1_1 = StdUi:Slider(window, 100, 16, sk2 / 2.5, false, 0, 40)
        StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
        local sk_1_1Label = StdUi:FontString(window, sk2id .. sk2);
        StdUi:GlueTop(sk_1_1Label, sk_1_1, 0, 16);
        StdUi:FrameTooltip(sk_1_1, sk2tooltip, 'TOPLEFT', 'TOPRIGHT', true);
        function sk_1_1:OnValueChanged(value)
            local value = math.floor(value) * 2.5
            RubimRH.db.profile[RubimRH.playerSpec].sk2 = value
            sk2 = value
            sk_1_1Label:SetText(sk2id .. sk2)
        end
    end

    local sk_2_0
    if sk3 >= 0 then
        sk_2_0 = StdUi:Slider(window, 100, 16, sk3 / 2.5, false, 0, 40)
        StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
        local sk_2_0Label = StdUi:FontString(window, sk3id .. sk3);
        StdUi:GlueTop(sk_2_0Label, sk_2_0, 0, 16);
        StdUi:FrameTooltip(sk_2_0, sk3tooltip, 'TOPLEFT', 'TOPRIGHT', true);
        function sk_2_0:OnValueChanged(value)
            local value = math.floor(value) * 2.5
            RubimRH.db.profile[RubimRH.playerSpec].sk3 = value
            sk3 = value
            sk_2_0Label:SetText(sk3id .. sk3)
        end
    end

    --ROGUE Sub
    if RubimRH.playerSpec == Subtlety or RubimRH.playerSpec == Assassination then
        local sk_2_1 = StdUi:Checkbox(window, "Vanish Attack");
        sk_2_1:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].vanishattack)
        StdUi:GlueBelow(sk_2_1, sk_1_1, 15, -24, 'RIGHT');
        function sk_2_1:OnValueChanged(value)
            if RubimRH.db.profile[RubimRH.playerSpec].vanishattack then
                RubimRH.db.profile[RubimRH.playerSpec].vanishattack = false
            else
                RubimRH.db.profile[RubimRH.playerSpec].vanishattack = true
            end
        end
    end

    local sk_2_1
    if sk4 >= 0 then
        sk_2_1 = StdUi:Slider(window, 100, 16, sk4 / 2.5, false, 0, 40)
        StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -24, 'RIGHT');
        local sk_2_1Label = StdUi:FontString(window, sk4id .. sk4);
        StdUi:GlueTop(sk_2_1Label, sk_2_1, 0, 16);
        StdUi:FrameTooltip(sk_2_1, sk4tooltip, 'TOPLEFT', 'TOPRIGHT', true);
        function sk_2_1:OnValueChanged(value)
            local value = math.floor(value) * 2.5
            RubimRH.db.profile[RubimRH.playerSpec].sk4 = value
            sk4 = value
            sk_2_1Label:SetText(sk4id .. sk4)
        end

    end

    if sk5 >= 0 then
        local sk_3_0 = StdUi:Slider(window, 100, 16, sk5 / 2.5, false, 0, 40)
        StdUi:GlueBelow(sk_3_0, sk_2_0, 0, -24, 'LEFT');
        local sk_3_0Label = StdUi:FontString(window, sk5id .. sk5);
        StdUi:GlueTop(sk_3_0Label, sk_3_0, 0, 16);
        StdUi:FrameTooltip(sk_3_0, sk5tooltip, 'TOPLEFT', 'TOPRIGHT', true);
        function sk_3_0:OnValueChanged(value)
            local value = math.floor(value) * 2.5
            RubimRH.db.profile[RubimRH.playerSpec].sk5 = value
            sk5 = value
            sk_3_0Label:SetText(sk5id .. sk5)
        end
    end

    if sk6 >= 0 then
        local sk_3_1 = StdUi:Slider(window, 100, 16, sk6 / 2.5, false, 0, 40)
        StdUi:GlueBelow(sk_3_1, sk_2_1, 0, -24, 'RIGHT');
        local sk_3_1Label = StdUi:FontString(window, sk6id .. sk6);
        StdUi:GlueTop(sk_3_1Label, sk_3_1, 0, 16);
        StdUi:FrameTooltip(sk_3_1, sk6tooltip, 'TOPLEFT', 'TOPRIGHT', true);
        function sk_3_1:OnValueChanged(value)
            local value = math.floor(value) * 2.5
            RubimRH.db.profile[RubimRH.playerSpec].sk6 = value
            sk6 = value
            sk_3_1Label:SetText(sk6id .. sk6)
        end
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, extraPosition);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:FrameTooltip(extra1, 'Useful if you want to ban a spell from the rotation.', 'TOPLEFT', 'TOPRIGHT', true);
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);

end

local function BloodMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local sk1var = RubimRH.db.profile[RubimRH.playerSpec].icebound
    local sk1text = "Icebound: "
    local sk1tooltip = "HP Percent to use Icebound Fortitude."

    local sk2var = RubimRH.db.profile[RubimRH.playerSpec].runetap
    local sk2text = "Runetap: "
    local sk2tooltip = "HP Percent to use Runetap."

    local sk3var = RubimRH.db.profile[RubimRH.playerSpec].vampiricblood
    local sk3text = "Vamp Blood: "
    local sk3tooltip = "HP Percent to use Vampiric Blood."

    local sk4var = RubimRH.db.profile[RubimRH.playerSpec].drw
    local sk4text = "DRW: "
    local sk4tooltip = "HP Percent to use Dancing Rune Weapon."

    local sk5var = RubimRH.db.profile[RubimRH.playerSpec].smartds
    local sk5text = "Inc DmG DS: "
    local sk5tooltip = "How much (percent wise) of inc dmg that we should use DS to heal back."

    local sk6var = RubimRH.db.profile[RubimRH.playerSpec].deficitds
    local sk6text = "Deficit RP: "
    local sk6tooltip = "How much deficit of Runic Power (MaxRP - CurrentRP) so we can start to use Death Strike./nValue of 20 means usually at 130RP."

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
    StdUi:FrameTooltip(gn_1_0, "This is will enable auto switching target and auto attacking outside of combat.", 'TOPLEFT', 'TOPRIGHT', true);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        BloodMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        BloodMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:Slider(window, 100, 16, sk1var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    local sk_1_0Label = StdUi:FontString(window, sk1text .. sk1var);
    StdUi:GlueTop(sk_1_0Label, sk_1_0, 0, 16);
    StdUi:FrameTooltip(sk_1_0, sk1tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].icebound = value
        sk1var = value
        sk_1_0Label:SetText(sk1text .. sk1var)
    end

    local sk_1_1 = StdUi:Slider(window, 100, 16, sk2var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    local sk_1_1Label = StdUi:FontString(window, sk2text .. sk2var);
    StdUi:GlueTop(sk_1_1Label, sk_1_1, 0, 16);
    StdUi:FrameTooltip(sk_1_1, sk2tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].runetap = value
        sk2var = value
        sk_1_1Label:SetText(sk2text .. sk2var)
    end

    local sk_2_0 = StdUi:Slider(window, 100, 16, sk3var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    local sk_2_0Label = StdUi:FontString(window, sk3text .. sk3var);
    StdUi:GlueTop(sk_2_0Label, sk_2_0, 0, 16);
    StdUi:FrameTooltip(sk_2_0, sk3tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_2_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].vampiricblood = value
        sk3var = value
        sk_2_0Label:SetText(sk3text .. sk3var)
    end

    local sk_2_1 = StdUi:Slider(window, 100, 16, sk4var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -24, 'RIGHT');
    local sk_2_1Label = StdUi:FontString(window, sk4text .. sk4var);
    StdUi:GlueTop(sk_2_1Label, sk_2_1, 0, 16);
    StdUi:FrameTooltip(sk_2_1, sk4tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].drw = value
        sk4var = value
        sk_2_1Label:SetText(sk4text .. sk4var)
    end

    local sk_3_0 = StdUi:Slider(window, 100, 16, sk5var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_3_0, sk_2_0, 0, -24, 'LEFT');
    local sk_3_0Label = StdUi:FontString(window, sk5text .. sk5var);
    StdUi:GlueTop(sk_3_0Label, sk_3_0, 0, 16);
    StdUi:FrameTooltip(sk_3_0, sk5tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_3_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].smartds = value
        sk5var = value
        sk_3_0Label:SetText(sk5text .. sk5var)
    end

    local sk_3_1 = StdUi:Slider(window, 100, 16, sk6var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_3_1, sk_2_1, 0, -24, 'RIGHT');
    local sk_3_1Label = StdUi:FontString(window, sk6text .. sk6var);
    StdUi:GlueTop(sk_3_1Label, sk_3_1, 0, 16);
    StdUi:FrameTooltip(sk_3_1, sk6tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_3_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].deficitds = value
        sk6var = value
        sk_3_1Label:SetText(sk6text .. sk6var)
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -410);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);

end

local function FrostMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local sk1var = RubimRH.db.profile[RubimRH.playerSpec].icebound
    local sk1text = "Icebound: "
    local sk1tooltip = "HP Percent to use Icebound Fortitude."

    local sk2var = RubimRH.db.profile[RubimRH.playerSpec].deathstrike
    local sk2text = "Death Strike (Proc): "
    local sk2tooltip = "HP Percent to use Death Stike with Dark Succur."

    local sk3var = RubimRH.db.profile[RubimRH.playerSpec].deathstrikeper
    local sk3text = "Death Strike: "
    local sk3tooltip = "HP Percent to use Death Strike."

    local sk4var = RubimRH.db.profile[RubimRH.playerSpec].deathpact
    local sk4text = "Death Pact: "
    local sk4tooltip = "HP Percent to use Death Pact."

    local window = StdUi:Window(UIParent, 'Death Knight - Frost', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        FrostMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        FrostMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:Slider(window, 100, 16, sk1var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    local sk_1_0Label = StdUi:FontString(window, sk1text .. sk1var);
    StdUi:GlueTop(sk_1_0Label, sk_1_0, 0, 16);
    StdUi:FrameTooltip(sk_1_0, sk1tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].icebound = value
        sk1var = value
        sk_1_0Label:SetText(sk1text .. sk1var)
    end

    local sk_1_1 = StdUi:Slider(window, 100, 16, sk2var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    local sk_1_1Label = StdUi:FontString(window, sk2text .. sk2var);
    StdUi:GlueTop(sk_1_1Label, sk_1_1, 0, 16);
    StdUi:FrameTooltip(sk_1_1, sk2tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].deathstrike = value
        sk2var = value
        sk_1_1Label:SetText(sk2text .. sk2var)
    end

    local sk_2_0 = StdUi:Slider(window, 100, 16, sk3var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    local sk_2_0Label = StdUi:FontString(window, sk3text .. sk3var);
    StdUi:GlueTop(sk_2_0Label, sk_2_0, 0, 16);
    StdUi:FrameTooltip(sk_2_0, sk3tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_2_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].deathstrikeper = value
        sk3var = value
        sk_2_0Label:SetText(sk3text .. sk3var)
    end

    local sk_2_1 = StdUi:Slider(window, 100, 16, sk4var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -24, 'RIGHT');
    local sk_2_1Label = StdUi:FontString(window, sk4text .. sk4var);
    StdUi:GlueTop(sk_2_1Label, sk_2_1, 0, 16);
    StdUi:FrameTooltip(sk_2_1, sk4tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].deathpact = value
        sk4var = value
        sk_2_1Label:SetText(sk4text .. sk4var)
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -310);
    local extraSep = StdUi:FontString(window, '===================');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -50, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function UnholyMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local sk1var = RubimRH.db.profile[RubimRH.playerSpec].icebound
    local sk1text = "Icebound: "
    local sk1tooltip = "HP Percent to use Icebound Fortitude."

    local sk2var = RubimRH.db.profile[RubimRH.playerSpec].deathstrike
    local sk2text = "Death Strike (Proc): "
    local sk2tooltip = "HP Percent to use Death Stike with Dark Succur."

    local sk3var = RubimRH.db.profile[RubimRH.playerSpec].deathstrikeper
    local sk3text = "Death Strike: "
    local sk3tooltip = "HP Percent to use Death Strike."

    local sk4var = RubimRH.db.profile[RubimRH.playerSpec].deathpact
    local sk4text = "Death Pact: "
    local sk4tooltip = "HP Percent to use Death Pact."

    local window = StdUi:Window(UIParent, 'Death Knight - Unholy', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        UnholyMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        UnholyMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:Slider(window, 100, 16, sk1var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    local sk_1_0Label = StdUi:FontString(window, sk1text .. sk1var);
    StdUi:GlueTop(sk_1_0Label, sk_1_0, 0, 16);
    StdUi:FrameTooltip(sk_1_0, sk1tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].icebound = value
        sk1var = value
        sk_1_0Label:SetText(sk1text .. sk1var)
    end

    local sk_1_1 = StdUi:Slider(window, 100, 16, sk2var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    local sk_1_1Label = StdUi:FontString(window, sk2text .. sk2var);
    StdUi:GlueTop(sk_1_1Label, sk_1_1, 0, 16);
    StdUi:FrameTooltip(sk_1_1, sk2tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].deathstrike = value
        sk2var = value
        sk_1_1Label:SetText(sk2text .. sk2var)
    end

    local sk_2_0 = StdUi:Slider(window, 100, 16, sk3var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    local sk_2_0Label = StdUi:FontString(window, sk3text .. sk3var);
    StdUi:GlueTop(sk_2_0Label, sk_2_0, 0, 16);
    StdUi:FrameTooltip(sk_2_0, sk3tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_2_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].deathstrikeper = value
        sk3var = value
        sk_2_0Label:SetText(sk3text .. sk3var)
    end

    local sk_2_1 = StdUi:Slider(window, 100, 16, sk4var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -24, 'RIGHT');
    local sk_2_1Label = StdUi:FontString(window, sk4text .. sk4var);
    StdUi:GlueTop(sk_2_1Label, sk_2_1, 0, 16);
    StdUi:FrameTooltip(sk_2_1, sk4tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].deathpact = value
        sk4var = value
        sk_2_1Label:SetText(sk4text .. sk4var)
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -310);
    local extraSep = StdUi:FontString(window, '===================');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -50, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function ArmsMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local sk1var = RubimRH.db.profile[RubimRH.playerSpec].victoryrush
    local sk1text = "Victory Rush: "
    local sk1tooltip = "HP Percent to use Victory Rush."

    local sk2var = RubimRH.db.profile[RubimRH.playerSpec].diebythesword
    local sk2text = "Dye by the Sword: "
    local sk2tooltip = "HP Percent to use Die by the Sword."

    local sk3var = RubimRH.db.profile[RubimRH.playerSpec].rallyingcry
    local sk3text = "Rallying Cry: "
    local sk3tooltip = "HP Percent to use Rallying Cry."

    local window = StdUi:Window(UIParent, 'Warrior - Arms', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

    gn_1_1:SetPlaceholder('-- Trinkets1 --');
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
        ArmsMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        ArmsMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:Slider(window, 100, 16, sk1var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    local sk_1_0Label = StdUi:FontString(window, sk1text .. sk1var);
    StdUi:GlueTop(sk_1_0Label, sk_1_0, 0, 16);
    StdUi:FrameTooltip(sk_1_0, sk1tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].victoryrush = value
        sk1var = value
        sk_1_0Label:SetText(sk1text .. sk1var)
    end

    local sk_1_1 = StdUi:Slider(window, 100, 16, sk2var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    local sk_1_1Label = StdUi:FontString(window, sk2text .. sk2var);
    StdUi:GlueTop(sk_1_1Label, sk_1_1, 0, 16);
    StdUi:FrameTooltip(sk_1_1, sk2tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].diebythesword = value
        sk2var = value
        sk_1_1Label:SetText(sk2text .. sk2var)
    end

    local sk_2_0 = StdUi:Slider(window, 100, 16, sk3var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    local sk_2_0Label = StdUi:FontString(window, sk3text .. sk3var);
    StdUi:GlueTop(sk_2_0Label, sk_2_0, 0, 16);
    StdUi:FrameTooltip(sk_2_0, sk3tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_2_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].rallyingcry = value
        sk3var = value
        sk_2_0Label:SetText(sk3text .. sk3var)
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end
local function FuryMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local sk1var = RubimRH.db.profile[RubimRH.playerSpec].victoryrush
    local sk1text = "Victory Rush: "
    local sk1tooltip = "HP Percent to use Victory Rush."

    local sk2var = RubimRH.db.profile[RubimRH.playerSpec].rallyingcry
    local sk2text = "Rallying Cry: "
    local sk2tooltip = "HP Percent to use Rallying Cry."

    local window = StdUi:Window(UIParent, 'Warrior - Fury', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        FuryMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        FuryMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:Slider(window, 100, 16, sk1var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    local sk_1_0Label = StdUi:FontString(window, sk1text .. sk1var);
    StdUi:GlueTop(sk_1_0Label, sk_1_0, 0, 16);
    StdUi:FrameTooltip(sk_1_0, sk1tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].victoryrush = value
        sk1var = value
        sk_1_0Label:SetText(sk1text .. sk1var)
    end

    local sk_1_1 = StdUi:Slider(window, 100, 16, sk2var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    local sk_1_1Label = StdUi:FontString(window, sk2text .. sk2var);
    StdUi:GlueTop(sk_1_1Label, sk_1_1, 0, 16);
    StdUi:FrameTooltip(sk_1_1, sk2tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].rallyingcry = value
        sk2var = value
        sk_1_1Label:SetText(sk2text .. sk2var)
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function MMMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local sk1var = RubimRH.db.profile[RubimRH.playerSpec].exhilaration
    local sk1text = "Exhilaration: "
    local sk1tooltip = "HP Percent to use Exhilaration."

    local sk2var = RubimRH.db.profile[RubimRH.playerSpec].aspectoftheturtle
    local sk2text = "Aspect Turtle: "
    local sk2tooltip = "HP Percent to use Aspect of the Turtle."

    local window = StdUi:Window(UIParent, 'Hunter - Marksman', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        MMMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        MMMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_1Label = StdUi:FontString(window, sk1text .. sk1var);
    StdUi:GlueTop(sk_1_1Label, sk_1_1, 0, 16);
    StdUi:FrameTooltip(sk_1_1, sk1tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].exhilaration = value
        sk1var = value
        sk_1_1Label:SetText(sk1text .. sk1var)
    end

    local sk_2_0 = StdUi:Slider(window, 100, 16, sk2var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    local sk_2_0Label = StdUi:FontString(window, sk2text .. sk2var);
    StdUi:GlueTop(sk_2_0Label, sk_2_0, 0, 16);
    StdUi:FrameTooltip(sk_2_0, sk3tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_2_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].aspectoftheturtle = value
        sk3var = value
        sk_2_0Label:SetText(sk3text .. sk3var)
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function SurvivalMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local sk1var = RubimRH.db.profile[RubimRH.playerSpec].mendpet
    local sk1text = "Mend Ptt: "
    local sk1tooltip = "HP Percent to use Mend Pet."

    local sk2var = RubimRH.db.profile[RubimRH.playerSpec].aspectoftheturtle
    local sk2text = "Aspect Turtle: "
    local sk2tooltip = "HP Percent to use Aspect of the Turtle."

    local sk3var = RubimRH.db.profile[RubimRH.playerSpec].exhilaration
    local sk3text = "Exhilaration: "
    local sk3tooltip = "HP Percent to use Exhilaration."

    local window = StdUi:Window(UIParent, 'Hunter - Survival', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        SurvivalMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        SurvivalMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_1Label = StdUi:FontString(window, sk2text .. sk2var);
    StdUi:GlueTop(sk_1_1Label, sk_1_1, 0, 16);
    StdUi:FrameTooltip(sk_1_1, sk2tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].runetap = value
        sk2var = value
        sk_1_1Label:SetText(sk2text .. sk2var)
    end

    local sk_2_0 = StdUi:Slider(window, 100, 16, sk3var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    local sk_2_0Label = StdUi:FontString(window, sk3text .. sk3var);
    StdUi:GlueTop(sk_2_0Label, sk_2_0, 0, 16);
    StdUi:FrameTooltip(sk_2_0, sk3tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_2_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].mendpet = value
        sk3var = value
        sk_2_0Label:SetText(sk3text .. sk3var)
    end

    local sk_2_1 = StdUi:Slider(window, 100, 16, sk4var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_2_1, sk_1_1, 0, -24, 'RIGHT');
    local sk_2_1Label = StdUi:FontString(window, sk4text .. sk4var);
    StdUi:GlueTop(sk_2_1Label, sk_2_1, 0, 16);
    StdUi:FrameTooltip(sk_2_1, sk4tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].drw = value
        sk4var = value
        sk_2_1Label:SetText(sk4text .. sk4var)
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function BMMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local window = StdUi:Window(UIParent, 'Hunter - Beast Mastery', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        BMMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        BMMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].mendpet);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Mend Pet', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].mendpet = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].aspectoftheturtle);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Aspect of the Turtle', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].aspectoftheturtle = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end


--local tex = StdUi:Texture(window, 350, 500, [[Interface\AddOns\AltzUI\media\statusbar]]);
--tex:SetColorTexture(1, 1, 1, 1)
--StdUi:GlueTop(tex, window, 0, 0);
local function OutMenu(point, relativeTo, relativePoint, xOfs, yOfs)
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

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].crimsonvial);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Crimson Vial', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].crimsonvial = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].cloakofshadows);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Cloak of Shadows', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].cloakofshadows = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].riposte);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Riposte', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].riposte = value
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
        RubimRH.db.profile[RubimRH.playerSpec].dice = self:GetText()
        print("Roll the Bones: " .. RubimRH.db.profile[RubimRH.playerSpec].dice)
    end

    local sk_3_0 = StdUi:Checkbox(window, "Vanish Attack");
    sk_3_0:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].vanishattack)
    StdUi:GlueBelow(sk_3_0, sk_2_0, 0, -24, 'LEFT');
    function sk_3_0:OnValueChanged(value)
        if RubimRH.db.profile[RubimRH.playerSpec].vanishattack then
            RubimRH.db.profile[RubimRH.playerSpec].vanishattack = false
        else
            RubimRH.db.profile[RubimRH.playerSpec].vanishattack = true
        end
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -380);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function SubMenu(point, relativeTo, relativePoint, xOfs, yOfs)
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

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].crimsonvial);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Crimson Vial', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].crimsonvial = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].cloakofshadows);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Cloak of Shadows', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].cloakofshadows = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].evasion);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Evasion', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].evasion = value
    end

    local sk_2_1 = StdUi:Checkbox(window, "Vanish Attack");
    sk_2_1:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].vanishattack)
    StdUi:GlueBelow(sk_2_1, sk_1_1, 15, -24, 'RIGHT');
    function sk_2_1:OnValueChanged(value)
        if RubimRH.db.profile[RubimRH.playerSpec].vanishattack then
            RubimRH.db.profile[RubimRH.playerSpec].vanishattack = false
        else
            RubimRH.db.profile[RubimRH.playerSpec].vanishattack = true
        end
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -380);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function AssMenu(point, relativeTo, relativePoint, xOfs, yOfs)
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

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].crimsonvial);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Crimson Vial', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].crimsonvial = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].cloakofshadows);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Cloak of Shadows', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].cloakofshadows = value
    end

    local sk_2_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].evasion);
    sk_2_0:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_2_0, sk_1_0, 0, -24, 'LEFT');
    StdUi:AddLabel(window, sk_2_0, 'Evasion', 'TOP');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].evasion = value
    end

    local sk_2_1 = StdUi:Checkbox(window, "Vanish Attack");
    sk_2_1:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].vanishattack)
    StdUi:GlueBelow(sk_2_1, sk_1_1, 15, -24, 'RIGHT');
    function sk_2_1:OnValueChanged(value)
        if RubimRH.db.profile[RubimRH.playerSpec].vanishattack then
            RubimRH.db.profile[RubimRH.playerSpec].vanishattack = false
        else
            RubimRH.db.profile[RubimRH.playerSpec].vanishattack = true
        end
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -380);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function HavocMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local window = StdUi:Window(UIParent, 'Demon Hunter - Havoc', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        HavocMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        HavocMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].blur);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Blur', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].blur = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].darkness);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Darkness', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].darkness = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function RetributionMenu(point, relativeTo, relativePoint, xOfs, yOfs)
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
    gn_3_0:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].SoVEnabled)
    StdUi:GlueBelow(gn_3_0, sk_separator, -50, -5, 'LEFT');
    function gn_3_0:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].SoVEnabled = value
        print("|cFF69CCF0Vengance" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].SoVEnabled))
    end

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].SoVHP);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, gn_3_0, 0, 0, 'LEFT');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].SoVHP = value
    end

    local flashoflight = StdUi:Checkbox(window, 'Flash of Light');
    flashoflight:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].FoL)
    StdUi:GlueBelow(flashoflight, sk_separator, 50, -5, 'RIGHT');
    function flashoflight:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].FoL = value
        print("|cFF69CCF0Flash of Light" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].FoL))
    end

    local FoLHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].flashoflight);
    FoLHP :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(FoLHP, flashoflight, -5, 0, 'RIGHT');
    function FoLHP :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].flashoflight = value
    end

    local justicarEnabled = StdUi:Checkbox(window, 'Justicar');
    justicarEnabled:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].justicariSEnabled)
    StdUi:GlueBelow(justicarEnabled, sk_1_0, 0, -5, 'LEFT');
    function justicarEnabled:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].justicariSEnabled = value
        print("|cFF69CCF0Justicar" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].justicariSEnabled))
    end

    local justicarHealth = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].JusticarHP);
    justicarHealth :SetMinMaxValue(10, 100);
    StdUi:GlueBelow(justicarHealth, justicarEnabled, 0, 0, 'LEFT');
    function justicarHealth :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].JusticarHP = value
    end

    local DivineEnabled = StdUi:Checkbox(window, 'Divine Shield');
    DivineEnabled:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].divineEnabled)
    StdUi:GlueBelow(DivineEnabled, FoLHP, 0, -5, 'RIGHT');
    function DivineEnabled:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].divineEnabled = value
        print("|cFF69CCF0Divine Shield" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].divineEnabled))
    end

    local DivineHealth = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].DivineHP);
    DivineHealth :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(DivineHealth, DivineEnabled, 0, 0, 'RIGHT');
    function DivineHealth :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].DivineHP = value
    end

    local LayOnHandEnabled = StdUi:Checkbox(window, 'Lay on Hands');
    LayOnHandEnabled:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].lohEnabled)
    StdUi:GlueBelow(LayOnHandEnabled, justicarHealth, 0, -5, 'LEFT');
    function LayOnHandEnabled:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].lohEnabled = value
        print("|cFF69CCF0Lay on Hands" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].lohEnabled))
    end

    local lohHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].lohHealth);
    lohHP :SetMinMaxValue(10, 100);
    StdUi:GlueBelow(lohHP, LayOnHandEnabled, 0, 0, 'LEFT');
    function lohHP :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].lohHealth = value
    end

    local wogactive = StdUi:Checkbox(window, 'Word of Glory');
    wogactive:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].wogenabled)
    StdUi:GlueBelow(wogactive, DivineHealth, 0, -5, 'RIGHT');
    function wogactive:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].wogenabled = value
        print("|cFF69CCF0Word of Glory" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].wogenabled))
    end

    local woghealth = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].wogHP);
    woghealth :SetMinMaxValue(10, 100);
    StdUi:GlueBelow(woghealth, wogactive, 0, 0, 'RIGHT');
    function woghealth :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].wogHP = value
    end

    local op_title = StdUi:FontString(window, 'Offensive Options');
    StdUi:GlueTop(op_title, window, 0, -350);
    local op_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(op_separator, op_title, 0, -12);

    local gn_4_0 = StdUi:Checkbox(window, 'Vengence in Opener');
    gn_4_0:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].SoVOpener)
    StdUi:GlueBelow(gn_4_0, op_separator, 0, -6, 'CENTER');
    function gn_4_0:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].SoVOpener = value
        print("|cFF69CCF0Vengance" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].SoVOpener))
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -420);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, 0, -14, 'CENTER');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function WWMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local window = StdUi:Window(UIParent, 'Monk - Windwalker', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        WWMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        WWMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].touchofkarma);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Touch of Karma', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].touchofkarma = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].dampemharm);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Dampem Harm', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].dampemharm = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -350);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function PProtectionMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local window = StdUi:Window(UIParent, 'Paladin - Protection', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        PProtectionMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        WWMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local LayOnHandEnabled = StdUi:Checkbox(window, 'Lay on Hands');
    LayOnHandEnabled:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].lohEnabled)
    StdUi:GlueBelow(LayOnHandEnabled, sk_separator, -50, -5, 'LEFT');
    function LayOnHandEnabled:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].lohEnabled = value
        print("|cFF69CCF0Lay on Hands" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].lohEnabled))
    end

    local lohHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].lohHealth);
    lohHP :SetMinMaxValue(10, 100);
    StdUi:GlueBelow(lohHP, LayOnHandEnabled, 0, 0, 'LEFT');
    function lohHP :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].lohHealth = value
    end

    local ancientKingEnabled = StdUi:Checkbox(window, 'Ancient Kings');
    ancientKingEnabled:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].akEnabled)
    StdUi:GlueBelow(ancientKingEnabled, sk_separator, 55, -5, 'RIGHT');
    function ancientKingEnabled:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].akEnabled = value
        print("|cFF69CCF0Guardian of the Ancient Kings" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].akEnabled))
    end

    local ancientKingHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].akHP);
    ancientKingHP :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(ancientKingHP, ancientKingEnabled, -5, 0, 'RIGHT');
    function ancientKingHP :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].akHP = value
    end

    local ArdentDefenderEnabled = StdUi:Checkbox(window, 'Ardent Defender');
    ArdentDefenderEnabled:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].adEnabled)
    StdUi:GlueBelow(ArdentDefenderEnabled, lohHP, 0, -5, 'LEFT');
    function ArdentDefenderEnabled:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].adEnabled = value
        print("|cFF69CCF0Ardent Defender" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].adEnabled))
    end

    local ArdentHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].adHP);
    ArdentHP :SetMinMaxValue(10, 100);
    StdUi:GlueBelow(ArdentHP, ArdentDefenderEnabled, 0, 0, 'LEFT');
    function ArdentHP :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].adHP = value
    end

    local protectorEnabled = StdUi:Checkbox(window, 'LotP');
    protectorEnabled:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].lotpEnabled)
    StdUi:GlueBelow(protectorEnabled, ancientKingHP, 0, -5, 'CENTER');
    function protectorEnabled:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].lotpEnabled = value
        print("|cFF69CCF0Light of the Protector" .. "|r: |cFF00FF00" .. tostring(RubimRH.db.profile[RubimRH.playerSpec].lotpEnabled))
    end

    local protectorHP = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].lotpHP);
    protectorHP :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(protectorHP, protectorEnabled, -5, 0, 'CENTER');
    function protectorHP :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].lotpHP = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -300);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, 0, -14, 'CENTER');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function EnhancementMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local sk1var = RubimRH.db.profile[RubimRH.playerSpec].HealingSurge
    local sk1text = "Healing Surge: "
    local sk1tooltip = "HP Percent to use Healing Surge."

    local sk2var = RubimRH.db.profile[RubimRH.playerSpec].EnableFS
    local sk2text = "Feral Spirit: "
    local sk2tooltip = "Check if you want use Feral Spirits."

    local sk3var = RubimRH.db.profile[RubimRH.playerSpec].EnableEE
    local sk3text = "Earth Elemental: "
    local sk3tooltip = "Check if you want to use earth Elemental."

    local sk4var = RubimRH.db.profile[RubimRH.playerSpec].interupt
    local sk4text = "Interupt: "
    local sk4tooltip = "Check if you want to use earth Elemental."

    local window = StdUi:Window(UIParent, 'Shaman - Enhancement', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        EnhancementMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        BloodMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:Slider(window, 100, 16, sk1var / 2.5, false, 0, 40)
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    local sk_1_0Label = StdUi:FontString(window, sk1text .. sk1var);
    StdUi:GlueTop(sk_1_0Label, sk_1_0, 0, 16);
    StdUi:FrameTooltip(sk_1_0, sk1tooltip, 'TOPLEFT', 'TOPRIGHT', true);
    function sk_1_0:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile[RubimRH.playerSpec].HealingSurge = value
        sk1var = value
        sk_1_0Label:SetText(sk1text .. sk1var)
    end

    local sk_2_0 = StdUi:Checkbox(window, 'Feral Spirits');
    sk_2_0:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].EnableFS)
    StdUi:GlueBelow(sk_2_0, sk_1_0Label, 0, -30, 'LEFT');
    function sk_2_0:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].EnableFS = value
        sk2var = value
        sk_2_0Label:SetText(sk2text .. tostring(sk2var))
    end

    local sk_3_0 = StdUi:Checkbox(window, 'Earth Elemental');
    sk_3_0:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].EnableEE)
    StdUi:GlueBelow(sk_3_0, sk_separator, 70, -20, 'LEFT');
    function sk_3_0:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].EnableEE = value
        sk3var = value
        sk_3_0Label:SetText(sk3text .. tostring(sk3var))
    end

    local sk_4_0 = StdUi:Checkbox(window, 'Use Interupt');
    sk_4_0:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].interupt)
    StdUi:GlueBelow(sk_4_0, sk_3_0, 0, -13, 'LEFT');
    function sk_4_0:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].interupt = value
        sk4var = value
        sk_4_0Label:SetText(sk4text .. tostring(sk4var))
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -410);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);

end

local function FeralMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local window = StdUi:Window(UIParent, 'Druid - Feral', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        FeralMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        FeralMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
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

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

local function VengMenu(point, relativeTo, relativePoint, xOfs, yOfs)
    local window = StdUi:Window(UIParent, 'Demon Hunter - Vengeance', 350, 500);
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

    local gn_1_1 = StdUi:Dropdown(window, 125, 20, trinketOptions, nil, nil);

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
        VengMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    local gn_2_0 = StdUi:Checkbox(window, 'Use Potion');
    gn_2_0:SetChecked(RubimRH.db.profile.mainOption.usePotion)
    StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -24, 'LEFT');
    function gn_2_0:OnValueChanged(value)
        RubimRH.PotionToggle()
    end

    local gn_2_1 = StdUi:Slider(window, 100, 16, RubimRH.db.profile.mainOption.healthstoneper / 2.5, false, 0, 40)
    StdUi:GlueBelow(gn_2_1, gn_1_1, 0, -24, 'RIGHT');
    local gn_2_1Label = StdUi:FontString(window, 'Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper);
    StdUi:GlueTop(gn_2_1Label, gn_2_1, 0, 16);
    StdUi:FrameTooltip(gn_2_1, 'Percent HP to use Healthstone.', 'TOPLEFT', 'TOPRIGHT', true);
    function gn_2_1:OnValueChanged(value)
        local value = math.floor(value) * 2.5
        RubimRH.db.profile.mainOption.healthstoneper = value
        gn_2_1Label:SetText('Healthstone: ' .. RubimRH.db.profile.mainOption.healthstoneper)
    end

    local cdOptions = {
        { text = 'Everything', value = "Everything" },
        { text = 'Boss Only', value = "Boss Only" },
    }
    if RubimRH.db.profile.mainOption.cooldownsUsage == "Everything" then
        cdOptions[1].text = "|cFF00FF00" .. "Everything " .. "|r"
    else
        cdOptions[1].text = "|cFFFF0000" .. "Everything " .. "|r"
    end

    if RubimRH.db.profile.mainOption.cooldownsUsage == "Boss Only" then
        cdOptions[2].text = "|cFF00FF00" .. "Boss Only " .. "|r"
    else
        cdOptions[2].text = "|cFFFF0000" .. "Boss Only " .. "|r"
    end

    local gn_3_0 = StdUi:Dropdown(window, 125, 20, cdOptions, nil, nil);

    gn_3_0:SetPlaceholder('-- CDs  --');
    StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -24, 'LEFT');
    gn_3_0.OnValueChanged = function(self, val)
        RubimRH.db.profile.mainOption.cooldownsUsage = val

        if val == "Everything" then
            print("CDs will be used on every mob")
        else
            print("CDs will only be used on Bosses/Rares")
        end

        --self:GetParent():Hide();
        self:GetParent():Hide();
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
        VengMenu(nil, point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --------------------------------------------------
    local sk_title = StdUi:FontString(window, 'Class Specific');
    StdUi:GlueTop(sk_title, window, 0, -200);
    local sk_separator = StdUi:FontString(window, '===================');
    StdUi:GlueTop(sk_separator, sk_title, 0, -12);

    local sk_1_0 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].metamorphosis);
    sk_1_0 :SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_0, sk_separator, -50, -24, 'LEFT');
    StdUi:AddLabel(window, sk_1_0, 'Metamorphosis', 'TOP');
    function sk_1_0 :OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].metamorphosis = value
    end

    local sk_1_1 = StdUi:NumericBox(window, 100, 24, RubimRH.db.profile[RubimRH.playerSpec].soulbarrier);
    sk_1_1:SetMinMaxValue(0, 100);
    StdUi:GlueBelow(sk_1_1, sk_separator, 50, -24, 'RIGHT');
    StdUi:AddLabel(window, sk_1_1, 'Soul Barrier', 'TOP');
    function sk_1_1:OnValueChanged(value)
        RubimRH.db.profile[RubimRH.playerSpec].soulbarrier = value
    end

    local extra = StdUi:FontString(window, 'Extra');
    StdUi:GlueTop(extra, window, 0, -310);
    local extraSep = StdUi:FontString(window, '=====');
    StdUi:GlueTop(extraSep, extra, 0, -12);

    local extra1 = StdUi:Button(window, 125, 20, 'Spells Blocker');
    StdUi:GlueBelow(extra1, extraSep, -100, -24, 'LEFT');
    extra1:SetScript('OnClick', function()
        window:Hide()
        RubimRH.SpellBlocker()
    end);
end

function RubimRH.ClassConfig(specID)
    AllMenu('secondTab')
end