local HL = HeroLib;
local Cache = HeroCache;
local StdUi = LibStub('StdUi')
local AceGUI = LibStub("AceGUI-3.0")
local mainAddon = RubimRH

function AllMenu(selectedTab, point, relativeTo, relativePoint, xOfs, yOfs)
    local window = StdUi:Window(UIParent, 'Class Config', 650, 500);

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
            title = 'Interrupt',
        },
        {
            name = 'fifthTab',
            title = 'System',
        },
        {
            name = 'sixthTab',
            title = 'Healer',
        },
       {
            name = 'seventhTab',
            title = 'MSG Actions',
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
            StdUi:GlueTop(config1_0, gn_separator, -100, -24, 'LEFT');
            config1_0:SetChecked(RubimRH.db.profile.mainOption.glowactionbar)
            function config1_0:OnValueChanged(self, state, value)
                RubimRH.GlowActionBarToggle()
            end

            local config1_1 = StdUi:Checkbox(tab.frame, 'Mute Sounds');
            StdUi:GlueTop(config1_1, gn_separator, 100, -24, 'RIGHT');
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
            StdUi:GlueTop(ic_1_0, ic_separator, -100, -24, 'LEFT');
            ic_1_0:SetChecked(RubimRH.db.profile.mainOption.mainIconLock)
            function ic_1_0:OnValueChanged(self, state, value)
                RubimRH.MainIconLockToggle()
            end

            local ic_1_1 = StdUi:Checkbox(tab.frame, 'Enable Icon');
            StdUi:GlueTop(ic_1_1, ic_separator, 100, -24, 'RIGHT');
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

            local gn_1_0 = StdUi:Checkbox(tab.frame, 'Auto Suggest W/O Target');
            StdUi:FrameTooltip(gn_1_0, 'When you are in combat, it will suggest skills even without a target.', 'TOPLEFT', 'TOPRIGHT', true);
            gn_1_0:SetChecked(RubimRH.db.profile.mainOption.startattack)
            StdUi:GlueBelow(gn_1_0, gn_separator, -100, -8, 'LEFT');
            function gn_1_0:OnValueChanged(value)
                RubimRH.AttackToggle()
            end

            local trinketOptions = {
                { text = 'Trinket 1', value = 1 },
                { text = 'Trinket 2', value = 2 },
            }

            local gn_1_1 = StdUi:Dropdown(tab.frame, 125, 24, trinketOptions, nil, true);
            gn_1_1:SetPlaceholder(' -- Trinkets --');
            item1 = gn_1_1.optsFrame.scrollChild.items[1]
            item2 = gn_1_1.optsFrame.scrollChild.items[2]
            StdUi:GlueBelow(gn_1_1, gn_separator, 100, -8, 'RIGHT');
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
          
            local gn_2_0 = StdUi:Checkbox(tab.frame, 'Perfect Pull');
            StdUi:FrameTooltip(gn_2_0, 'WIP Auto prepots & prepull from DBM Pull Timer', 'TOPLEFT', 'TOPRIGHT', true);
            gn_2_0:SetChecked(RubimRH.db.profile.mainOption.PerfectPull)
            StdUi:GlueBelow(gn_2_0, gn_1_0, 0, -15, 'LEFT');
            function gn_2_0:OnValueChanged(value)
                RubimRH.PerfectPull()
            end
            -- Healthstone
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

            local gn_3_0 = StdUi:Checkbox(tab.frame, 'CD Mode: Burst');
            gn_3_0:SetChecked(RubimRH.db.profile.mainOption.burstCD)
            StdUi:FrameTooltip(gn_3_0, "This will make the CD to be turned off after 10 seconds.\n\nUseful if you want a Burst button.", 'TOPLEFT', 'TOPRIGHT', true);
            function gn_3_0:OnValueChanged(value)
                RubimRH.burstCDToggle()
            end

            StdUi:GlueBelow(gn_3_0, gn_2_0, 0, -15, 'LEFT');
            
            -- precombat toggle
            local gn_4_0 = StdUi:Checkbox(tab.frame, 'Auto Precombat');
            StdUi:FrameTooltip(gn_4_0, 'Activate prepull functions', 'TOPLEFT', 'TOPRIGHT', true);
            gn_4_0:SetChecked(RubimRH.db.profile.mainOption.Precombat)
            function gn_4_0:OnValueChanged(value)
                RubimRH.PrecombatToggle()
            end            
            StdUi:GlueBelow(gn_4_0, gn_3_0, 0, -15, 'LEFT');

            -- Break CC Toggle
            local gn_break_cc = StdUi:Checkbox(tab.frame, 'Break CCs');
            StdUi:FrameTooltip(gn_break_cc, 'Break CCs', 'TOPLEFT', 'TOPRIGHT', true);
            gn_break_cc:SetChecked(RubimRH.db.profile.mainOption.ccbreak)
            function gn_break_cc:OnValueChanged(value)
                RubimRH.CCToggle()
            end            
            StdUi:GlueBelow(gn_break_cc, gn_4_0, 0, -15, 'LEFT');

            -- Cds usage options
            local cdOptions = {
                { text = 'Everything', value = "Everything" },
                { text = 'Boss Only', value = "Boss Only" },
            }
            local gn_3_1 = StdUi:Dropdown(tab.frame, 125, 24, cdOptions, nil, nil);
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
                StdUi:GlueBelow(sk_1_0, sk_separator, -100, -24, 'LEFT');
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
                StdUi:GlueBelow(sk_1_1, sk_separator, 100, -24, 'RIGHT');
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
			
            -----------------------
			--- CLASS SPECIFICS ---
            -----------------------

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
                
                -- Dice
                if RubimRH.playerSpec == Outlaw then
                local dice = {
                         { text = 'Simcraft', value = "Simcraft" },
                        { text = '1+ Buff', value = "1+ Buff" },
                        { text = 'AoE Strat', value = "AoE Strat" },
                        { text = 'Mythic +', value = "Mythic +" },
                    }
                    local diceRoll = StdUi:Dropdown(tab.frame, 125, 24, dice, nil, nil);
                    --StdUi:FrameTooltip(diceRoll, 'Everything - Every mob available\nBosses - Only Bosses or Rares', 'TOPLEFT', 'TOPRIGHT', true);
                    diceRoll:SetPlaceholder("|cfff0f8ffCD: |r" .. RubimRH.db.profile[RubimRH.playerSpec].dice);
                    diceRoll.OnValueChanged = function(self, val)
                    RubimRH.db.profile[RubimRH.playerSpec].dice = val

                    if val == "Mythic +" then
                         print("Dice profil set on Mythic +")
                    elseif val == "1+ Buff" then
                         print("Dice profil set on 1+ Buff")
				    elseif val == "AoE Strat" then
                         print("Dice profil set on AoE Strat")
                    elseif val == "1+ Buff" then
                         print("Dice profil set on 1+ Buff")
				    elseif val == "AoE Strat" then
                         print("Dice profil set on AoE Strat")
                    else
                        print("Dice profil set on Simcraft")
                        diceRoll:SetText("|cfff0f8ffDice: |r" .. RubimRH.db.profile[RubimRH.playerSpec].dice);
                    end
                    end
                    StdUi:GlueBelow(diceRoll, sk_1_0, 0, -64, 'LEFT');
                end
            
            end


			    --PROT PALADIN
                if RubimRH.playerSpec == PProtection then
				    
					-- Create the checkbox for Avenger Shield interrupt
                    local ASInterruptbutton = StdUi:Checkbox(tab.frame, 'Avenger\'s Shield interrupt only');                    
					-- Set this checkbox a tooltip
					StdUi:FrameTooltip(ASInterruptbutton, 'This will force Avenger\s Shield to be used as interrupt', 'TOPLEFT', 'TOPRIGHT', true);                    
					-- Set default value (checked, unchecked)and save it to db 
					ASInterruptbutton:SetChecked(RubimRH.db.profile[66].ASInterrupt)                    
					-- Set positionning
					StdUi:GlueBelow(ASInterruptbutton, gn_4_0, 0, -150, 'LEFT');
                    -- What to do on value change                    
					function ASInterruptbutton:OnValueChanged(value)
					    -- See Rubim-RHc.lua 
                        RubimRH.ASInterrupt()
                    end
                
				end
				
			    --PROT WARRIOR 
                if RubimRH.playerSpec == Protection then
                  
        			-- UseShieldBlockDefensively
					local UseShieldBlockDef = StdUi:Checkbox(tab.frame, 'Use Shield Block Defensively');                    
					StdUi:FrameTooltip(UseShieldBlockDef, 'This will force Shield Block te be auto used defensively', 'TOPLEFT', 'TOPRIGHT', true);                    
					UseShieldBlockDef:SetChecked(RubimRH.db.profile[73].UseShieldBlockDefensively)                    
					StdUi:GlueBelow(UseShieldBlockDef, gn_4_0, 0, -100, 'LEFT');                  
					function UseShieldBlockDef:OnValueChanged(value)
                        RubimRH.UseShieldBlockDef()
                    end
					
                    -- UseRageDefensively
					local UseRageDef = StdUi:Checkbox(tab.frame, 'Use Rage Defensively');                    
					StdUi:FrameTooltip(UseRageDef, 'This will force Rage usage defensively', 'TOPLEFT', 'TOPRIGHT', true);                    
					UseRageDef:SetChecked(RubimRH.db.profile[73].UseRageDefensively)                    
					StdUi:GlueBelow(UseRageDef, gn_4_0, 0, -130, 'LEFT');                  
					function UseRageDef:OnValueChanged(value)
                        RubimRH.UseRageDef()
                    end
					
                end
				
			    --BALANCE DRUID
                if RubimRH.playerSpec == Balance then
				
                    local AutoMorphbutton = StdUi:Checkbox(tab.frame, 'Auto morph in Moonkin form');                    
					StdUi:FrameTooltip(AutoMorphbutton, 'This will force Moonkin form everytime', 'TOPLEFT', 'TOPRIGHT', true);                    
					AutoMorphbutton:SetChecked(RubimRH.db.profile[102].AutoMorph)                    
					-- Set positionning
					StdUi:GlueBelow(AutoMorphbutton, gn_4_0, 0, -150, 'LEFT');
                    -- What to do on value change                    
					function AutoMorphbutton:OnValueChanged(value)
					    -- See Rubim-RHc.lua 
                        RubimRH.AutoMorph()
                    end
					
                end
				
			    --AFFLICTION WARLOCK
                if RubimRH.playerSpec == Affliction then
				    
					-- Create the checkbox for Avenger Shield interrupt
                    local AutoAOEbutton = StdUi:Checkbox(tab.frame, 'Auto AoE');                    
					-- Set this checkbox a tooltip
					StdUi:FrameTooltip(AutoAOEbutton, 'Activate auto AoE targetting', 'TOPLEFT', 'TOPRIGHT', true);                    
					-- Set default value (checked, unchecked)and save it to db 
					AutoAOEbutton:SetChecked(RubimRH.db.profile[265].AutoAoE)                    
					-- Set positionning
					StdUi:GlueBelow(AutoAOEbutton, gn_4_0, 0, -150, 'LEFT');
                    -- What to do on value change                    
					function AutoAOEbutton:OnValueChanged(value)
					    -- See Rubim-RHc.lua 
                        RubimRH.AffliAutoAoE()
                    end
                
				end
				
			    --ASSA ROGUE
                if RubimRH.playerSpec == Assassination then
				    
					-- Create the checkbox for Avenger Shield interrupt
                    local AutoAOEbutton = StdUi:Checkbox(tab.frame, 'Auto AoE');                    
					-- Set this checkbox a tooltip
					StdUi:FrameTooltip(AutoAOEbutton, 'Activate auto AoE targetting', 'TOPLEFT', 'TOPRIGHT', true);                    
					-- Set default value (checked, unchecked)and save it to db 
					AutoAOEbutton:SetChecked(RubimRH.db.profile[259].AutoAoE)                    
					-- Set positionning
					StdUi:GlueBelow(AutoAOEbutton, gn_4_0, 0, -150, 'LEFT');
                    -- What to do on value change                    
					function AutoAOEbutton:OnValueChanged(value)
					    -- See Rubim-RHc.lua 
                        RubimRH.AssaAutoAoE()
                    end
                
				end
				
                --DESTRUCTION LOCK
                if RubimRH.playerSpec == Destruction then
				
                    local color = {
                        { text = 'Auto', value = 1 },
                        { text = 'Green', value = 2 },
                        { text = 'Orange', value = 3 },
                    };

                    local colorRoll = StdUi:Dropdown(tab.frame, 125, 24, color, 1);
                    StdUi:GlueBelow(colorRoll, sk_1_0, 0, -64, 'LEFT');
                    StdUi:AddLabel(tab.frame, colorRoll, 'Flames Color', 'TOP');
                    function colorRoll:OnValueChanged(value)
                        RubimRH.db.profile[RubimRH.playerSpec].color = self:GetText()
                        print("Flames Color set on: " .. RubimRH.db.profile[RubimRH.playerSpec].color)
                    end
					
                end
				
			    --SHADOW PRIEST
                if RubimRH.playerSpec == Shadow then
				    
					-- Create the checkbox for Avenger Shield interrupt
                    local AutoAOEbutton = StdUi:Checkbox(tab.frame, 'Auto AoE');                    
					-- Set this checkbox a tooltip
					StdUi:FrameTooltip(AutoAOEbutton, 'Activate auto AoE targetting', 'TOPLEFT', 'TOPRIGHT', true);                    
					-- Set default value (checked, unchecked)and save it to db 
					AutoAOEbutton:SetChecked(RubimRH.db.profile[258].AutoAoE)                    
					-- Set positionning
					StdUi:GlueBelow(AutoAOEbutton, gn_4_0, 0, -150, 'LEFT');
                    -- What to do on value change                    
					function AutoAOEbutton:OnValueChanged(value)
					    -- See Rubim-RHc.lua 
                        RubimRH.ShadowAutoAoE()
                    end
                
				end
                
				-- ARCANE MAGE
                if RubimRH.playerSpec == Arcane then
				
                    local useSplashData = {
                        { text = 'Enabled', value = "Enabled" },
                        { text = 'Disabled', value = "Disabled" },
                    }
                    local choosedata = StdUi:Dropdown(tab.frame, 125, 24, useSplashData, nil, nil);
                    choosedata:SetPlaceholder("|cfff0f8ff|r" .. RubimRH.db.profile[RubimRH.playerSpec].useSplashData);
                    StdUi:AddLabel(tab.frame, choosedata, 'Use Experimental Aoe Detection', 'TOP');
                    StdUi:FrameTooltip(choosedata, 'Use Combat Log to detect real numbers of enemies around your target', 'TOPLEFT', 'TOPRIGHT', true);                
                    
                    choosedata.OnValueChanged = function(self, val)
                    RubimRH.db.profile[RubimRH.playerSpec].useSplashData = val

                    if val == "Enabled" then
                        print("Experimental Aoe Detection Enabled")
                    else
                        print("Experimental Aoe Detection Disabled")
                        choosedata:SetText("|cfff0f8ff|r" .. RubimRH.db.profile[RubimRH.playerSpec].useSplashData);
                    end
                    end
                    StdUi:GlueBelow(choosedata, sk_1_0, 0, -64, 'LEFT');
					
                end
                
                
                -- SHAMAN ELEMENTAL
                if RubimRH.playerSpec == Elemental then
				
                    local useSplashData = {
                        { text = 'Enabled', value = "Enabled" },
                        { text = 'Disabled', value = "Disabled" },
                    }
                    local choosedata = StdUi:Dropdown(tab.frame, 125, 24, useSplashData, nil, nil);
                    choosedata:SetPlaceholder("|cfff0f8ff|r" .. RubimRH.db.profile[RubimRH.playerSpec].useSplashData);
                    StdUi:AddLabel(tab.frame, choosedata, 'Use Experimental Aoe Detection', 'TOP');
                    StdUi:FrameTooltip(choosedata, 'Use Combat Log to detect real numbers of enemies around your target', 'TOPLEFT', 'TOPRIGHT', true);                
                    
                    choosedata.OnValueChanged = function(self, val)
                    RubimRH.db.profile[RubimRH.playerSpec].useSplashData = val

                    if val == "Enabled" then
                        print("Experimental Aoe Detection Enabled")
                    else
                        print("Experimental Aoe Detection Disabled")
                        choosedata:SetText("|cfff0f8ff|r" .. RubimRH.db.profile[RubimRH.playerSpec].useSplashData);
                    end
                    end
                    StdUi:GlueBelow(choosedata, sk_1_0, 0, -64, 'LEFT');
					
                end

                
                -- HUNTER MARKMANSHIP

                if RubimRH.playerSpec == Marksmanship then
				
                    local useSplashData = {
                        { text = 'Enabled', value = "Enabled" },
                        { text = 'Disabled', value = "Disabled" },
                    }
                    local choosedata = StdUi:Dropdown(tab.frame, 125, 24, useSplashData, nil, nil);
                    choosedata:SetPlaceholder("|cfff0f8ff|r" .. RubimRH.db.profile[RubimRH.playerSpec].useSplashData);
                    StdUi:AddLabel(tab.frame, choosedata, 'Use Experimental Aoe Detection', 'TOP');
                    StdUi:FrameTooltip(choosedata, 'Use Combat Log to detect real numbers of enemies around your target', 'TOPLEFT', 'TOPRIGHT', true);                
                    
                    choosedata.OnValueChanged = function(self, val)
                    RubimRH.db.profile[RubimRH.playerSpec].useSplashData = val

                    if val == "Enabled" then
                        print("Experimental Aoe Detection Enabled")
                    else
                        print("Experimental Aoe Detection Disabled")
                        choosedata:SetText("|cfff0f8ff|r" .. RubimRH.db.profile[RubimRH.playerSpec].useSplashData);
                    end
                    end
                    StdUi:GlueBelow(choosedata, sk_1_0, 0, -64, 'LEFT');
					
                end
                
                -- HUNTER BEAST MASTER

                if RubimRH.playerSpec == BeastMastery then
				
                    local useSplashData = {
                        { text = 'Enabled', value = "Enabled" },
                        { text = 'Disabled', value = "Disabled" },
                    }
                    local choosedata = StdUi:Dropdown(tab.frame, 125, 24, useSplashData, nil, nil);
                    choosedata:SetPlaceholder("|cfff0f8ff|r" .. RubimRH.db.profile[RubimRH.playerSpec].useSplashData);
                    StdUi:AddLabel(tab.frame, choosedata, 'Use Experimental Aoe Detection', 'TOP');
                    StdUi:FrameTooltip(choosedata, 'Use Combat Log to detect real numbers of enemies around your target', 'TOPLEFT', 'TOPRIGHT', true);                
                    
                    choosedata.OnValueChanged = function(self, val)
                    RubimRH.db.profile[RubimRH.playerSpec].useSplashData = val

                    if val == "Enabled" then
                        print("Experimental Aoe Detection Enabled")
                    else
                        print("Experimental Aoe Detection Disabled")
                        choosedata:SetText("|cfff0f8ff|r" .. RubimRH.db.profile[RubimRH.playerSpec].useSplashData);
                    end
                    end
                    StdUi:GlueBelow(choosedata, sk_1_0, 0, -64, 'LEFT');
					
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

            local st = StdUi:ScrollTable(tab.frame, cols, 7, 40);
            st:EnableSelection(true);
            StdUi:GlueTop(st, tab.frame, 0, -60);

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

            for key, spell in pairs(HeroCache.Persistent.SpellLearned.Player) do
                if IsPassiveSpell(key) == false then
                    tinsert(data, addSpell(key));
                end
            end

            for key, spell in pairs(HeroCache.Persistent.SpellLearned.Pet) do
                if IsPassiveSpell(key) == false then
                    tinsert(data, addSpell(key));
                end
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
                    st:ClearSelection()
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

                    for key, Spell in pairs(RubimRH.Spell[RubimRH.playerSpec]) do
                        if Spell:ID() == SpellDATA.spellId then
                            SpellVAR = key
                        end
                    end
                    RubimRH.print("Macro for: " .. GetSpellLink(SpellDATA.spellId) .. " was created. Check your Character Macros.")
                    CreateMacro(SpellDATA.name, SpellDATA.icon, "#showtooltip " .. GetSpellInfo(SpellDATA.spellId) .. "\n/run HeroLib.Spell(" .. tostring(SpellDATA.spellId) .. "):Queue()", 1)
                    RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\button.ogg")
                    st:ClearSelection()
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
        
        if tab.title == "Interrupt" then
            local interruptList_title = StdUi:FontString(tab.frame, '');
            StdUi:GlueTop(interruptList_title, tab.frame, 0, 0, 'CENTER');

			-- Interrupt Everything
            local InterruptEverythingbutton = StdUi:Checkbox(tab.frame, 'Interrupt Everything');                    
		    -- Set this checkbox a tooltip
			StdUi:FrameTooltip(InterruptEverythingbutton, 'This will interrupt everything', 'TOPLEFT', 'TOPRIGHT', true);                    
			-- Set default value (checked, unchecked)and save it to db 
			InterruptEverythingbutton:SetChecked(RubimRH.db.profile.mainOption.InstantInterrupt)                    
			-- Set positionning
            StdUi:GlueBelow(InterruptEverythingbutton, interruptList_title, 170, -10, 'LEFT');
            -- What to do on value change                    
		    function InterruptEverythingbutton:OnValueChanged(value)
		    -- See Rubim-RHc.lua 
                 RubimRH.InterruptEverythingToggle()
            end
			
			--[[ Instant Interrupt
            local InstantInterruptbutton = StdUi:Checkbox(tab.frame, 'Instant Interrupt');                    
		    -- Set this checkbox a tooltip
			StdUi:FrameTooltip(InstantInterruptbutton, 'This will make all your interrupts almost instant with very low randomizer', 'TOPLEFT', 'TOPRIGHT', true);                    
			-- Set default value (checked, unchecked)and save it to db 
			InstantInterruptbutton:SetChecked(RubimRH.db.profile.mainOption.InstantInterrupt)                    
			-- Set positionning
            StdUi:GlueBelow(InstantInterruptbutton, interruptList_title, 170, -30, 'LEFT');
            -- What to do on value change                    
		    function InstantInterruptbutton:OnValueChanged(value)
		    -- See Rubim-RHc.lua 
                 RubimRH.InstantInterruptToggle()
            end]]--
			
            -- MIN Interrupt randomizer settings
            local interruptslider1 = StdUi:Slider(tab.frame, 100, 20, RubimRH.db.profile.mainOption.minInterruptValue, false, 5, 100)
            StdUi:GlueBelow(interruptslider1, interruptList_title, -80, -30, 'LEFT');
            local sliderlabel = StdUi:FontString(tab.frame, "Interrupt min: " .. RubimRH.db.profile.mainOption.minInterruptValue)
            StdUi:GlueTop(sliderlabel, interruptslider1, 0, 16);
            StdUi:FrameTooltip(interruptslider1, "What the lowest percent cast we should interrupt ?", 'TOPLEFT', 'TOPRIGHT', true);
            function interruptslider1:OnValueChanged(value)
                value = (math.floor((value * ((100) + 0.5)) / (100)))
                RubimRH.db.profile.mainOption.minInterruptValue = value
                interruptslider1 = value
                sliderlabel:SetText("Interrupt min: " .. RubimRH.db.profile.mainOption.minInterruptValue)
            end
			
            -- MAX Interrupt randomizer settings
            local interruptslider2 = StdUi:Slider(tab.frame, 100, 20, RubimRH.db.profile.mainOption.maxInterruptValue, false, 5, 100)
            StdUi:GlueBelow(interruptslider2, interruptList_title, 50, -30, 'LEFT');
            local sliderlabel = StdUi:FontString(tab.frame, "Interrupt max: " .. RubimRH.db.profile.mainOption.maxInterruptValue)
            StdUi:GlueTop(sliderlabel, interruptslider2, 0, 16);
            StdUi:FrameTooltip(interruptslider2, "What the highest percent cast we should interrupt ?", 'TOPLEFT', 'TOPRIGHT', true);
            function interruptslider2:OnValueChanged(value)
                value = (math.floor((value * ((100) + 0.5)) / (100)))
                RubimRH.db.profile.mainOption.maxInterruptValue = value
                interruptslider2 = value
                sliderlabel:SetText("Interrupt max: " .. RubimRH.db.profile.mainOption.maxInterruptValue)
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
            local selectedSpell = {}
            local data = {};
            local cols = {

            {
                    name = '',
                    width = 50,
                    align = 'LEFT',
                    index = 'icon',
                    format = 'icon',
                    sortable = false,
                    events = {
                        OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                            selectedSpell = rowData.spellId
                        end,

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
            
                {
                    name = 'ID',
                    width = 80,
                    align = 'LEFT',
                    index = 'spellId',
                    format = 'number',
                    color = function(table, value)
                        --local x = value / 200000;
                        --return { r = x, g = 1 - x, b = 0, a = 1 };
                    end,
                    events = {
                        OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                            selectedSpell = rowData.spellId
                        end,
                    }
                },
                {
                    name = 'Spell Name',
                    width = 170,
                    align = 'LEFT',
                    index = 'name',
                    format = 'string',
                    events = {
                        OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                            selectedSpell = rowData.spellId
                        end,
                    }
                },
                
                {
                    name = 'Kick',
                    width = 40,
                    align = 'LEFT',
                    index = 'useKick',
                    format = 'string',
                    color = function(table, value, rowData, columnData)
                        if value == "Yes" then
                            return { r = 0, g = 1, b = 0, a = 1 }
                        end
                        if value == "No" then
                            return { r = 1, g = 0, b = 0, a = 1 }
                        end
                    end,
                    events = {
                        OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                            if not RubimRH.db.global.interruptsConfig[rowData.spellId] then
                                RubimRH.db.global.interruptsConfig[rowData.spellId] = {}
                            end
                            if rowData.useKick == 'Yes' then
                                rowData.useKick = 'No'
                                RubimRH.db.global.interruptsConfig[rowData.spellId].useKick = false
                                currentList[rowData.spellId].useKick = false
                                print('UI: ' .. GetSpellInfo(rowData.spellId) .. " will NOT be kicked.")
                            else
                                rowData.useKick = 'Yes'
                                RubimRH.db.global.interruptsConfig[rowData.spellId].useKick = true
                                currentList[rowData.spellId].useKick = true
                                print('UI: ' .. GetSpellInfo(rowData.spellId) .. " will be kicked.")
                            end
                        end,
                    },
                },

                {
                    name = 'CC',
                    width = 40,
                    align = 'LEFT',
                    index = 'useCC',
                    format = 'string',
                    color = function(table, value, rowData, columnData)
                        if value == "Yes" then
                            return { r = 0, g = 1, b = 0, a = 1 }
                        end
                        if value == "No" then
                            return { r = 1, g = 0, b = 0, a = 1 }
                        end
                    end,
                    events = {
                        OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
                            if not RubimRH.db.global.interruptsConfig[rowData.spellId] then
                                RubimRH.db.global.interruptsConfig[rowData.spellId] = {}
                            end
                            if rowData.useCC == 'Yes' then
                                rowData.useCC = 'No'
                                RubimRH.db.global.interruptsConfig[rowData.spellId].useCC = false
                                currentList[rowData.spellId].useCC = false
                                print('UI: ' .. GetSpellInfo(rowData.spellId) .. " will NOT be CCed.")
                            else
                                rowData.useCC = 'Yes'
                                RubimRH.db.global.interruptsConfig[rowData.spellId].useCC = true
                                currentList[rowData.spellId].useCC = true
                                print('UI: ' .. GetSpellInfo(rowData.spellId) .. " will be CCed.")
                            end
                        end,
                    },
                },

                {
                    name = 'Zone',
                    width = 100,
                    align = 'LEFT',
                    index = 'zone',
                    format = 'string',
                },


            }    

            local st = StdUi:ScrollTable(tab.frame, cols, 6, 40);
            st:EnableSelection(true);
            StdUi:GlueTop(st, tab.frame, 2, -100);                
                                    
			------------------
			-- Interrupts Profils
			------------------               
            local interruptProfilschoice = {
                { text = 'Mythic+', value = "Mythic+" },
                { text = 'PvP', value = "PvP" },
                { text = 'Mixed PvE PvP', value = "Mixed PvE PvP" },
                { text = 'Custom', value = "Custom" },
            }			
			
            local chooseprofil = StdUi:Dropdown(tab.frame, 100, 20, interruptProfilschoice, nil, nil);
                chooseprofil:SetPlaceholder("|cfff0f8ff|r" .. RubimRH.db.profile.mainOption.activeList);
                --StdUi:AddLabel(tab.frame, chooseprofil, 'Selected Profil', 'TOP');
                local chooseprofillabel = StdUi:FontString(tab.frame, "Selected Profil: ")
                StdUi:GlueTop(chooseprofillabel, chooseprofil, 0, 16);
			 	StdUi:FrameTooltip(chooseprofil, 'Choose between interrupts profils', 'TOPLEFT', 'TOPRIGHT', true);                
                chooseprofil.OnValueChanged = function(self, val)
				
				--local currentList = RubimRH.db.profile.mainOption.activeList
                
				
				if val == "Mythic+" then
                    print("Interrupt profil set on Mythic+")
                    RubimRH.db.profile.mainOption.activeList = val
                    --currentList = RubimRH.db.profile.mainOption.mythicList
					currentList = RubimRH.List.PvEInterrupts
                    RubimRH.RefreshList()
                    
                elseif val == "PvP" then
                    print("Interrupt profil set on PvP")
                    RubimRH.db.profile.mainOption.activeList = val
                    --currentList = RubimRH.db.profile.mainOption.pvpList
					currentList = RubimRH.List.PvPInterrupts
                    RubimRH.RefreshList()
                    
                elseif val == "Mixed PvE PvP" then
                    print("Interrupt profil set on Mixed PvE PvP")
                    RubimRH.db.profile.mainOption.activeList = val
                    currentList = RubimRH.List.MixedInterrupts
                    RubimRH.RefreshList()
               
                elseif val == "Custom" then
                    print("Interrupt profil set on Custom")
                    RubimRH.db.profile.mainOption.activeList = val
                    currentList = RubimRH.List.CustomInterrupts
                    RubimRH.RefreshList()
                
				else
                    print("An error as occured, no data :( Try to delete Rubim.lua in your WTF folder")
					currentList = RubimRH.List.PvEInterrupts
                    RubimRH.RefreshList()
                end
                return currentList				
            end
            --StdUi:GlueTop(chooseprofil, tab.frame, 10, -60, 'LEFT');    
            StdUi:GlueBelow(chooseprofil, interruptList_title, -250, -30, 'LEFT');
                       
            local function addSpell(spellID)
                local name;
                local icon, castTime, minRange, maxRange, spellId;
                local zone = currentList[spellID].Zone
                local useKick = (currentList[spellID].useKick == true and "Yes") or "No"
                local useCC = (currentList[spellID].useCC == true and "Yes") or "No"
			    --local zone = currentList[spellID].Zone

				if currentList[spellID].Zone == nil then
				   zone = "Custom"
				end
				
                name, _, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spellID);

                return {
                        name = name,
                        icon = icon,
                        castTime = castTime,
                        minRange = minRange,
                        maxRange = maxRange,
                        spellId = spellId,
                        zone = zone,
                        useKick = useKick,
                        useCC = useCC,
                };
            end

            local data = {};
		        --for i, v in pairs(RubimRH.List.PvEInterrupts) do
                --    tinsert(data, addSpell(i));
                --end
            -- Checking for current list not nil
            if currentList ~= nil then 
                -- insert currentList values
                for i, spell in pairs(currentList) do
                    table.insert(data, addSpell(i));
                end
            end

            -- update scroll table data
            st:SetData(data);

            local tempAddSpell = 0
            local function btn_addSpell()

                if not GetSpellInfo(tempAddSpell) then
                    return
                end

                if tempAddSpell ~= 0 and currentList[tempAddSpell] == nil then
                    currentList[tempAddSpell] = {true, Zone = "Custom", useKick = true, useCC = false}
                end

                local data = {};
                for i, spell in pairs(currentList) do
                    table.insert(data, addSpell(i));
                end
                st:SetData(data);
            end
			
            function RubimRH.RefreshList()
                local data = {};
				                
				if currentList ~= nil then 
    				for i, spell in pairs(currentList) do
                        table.insert(data, addSpell(i));
                    end
				end  
                print(currentList)
				
				st:SetData(data);
                st:ClearSelection()
            end
			
            local function btn_delSpell()
                if selectedSpell ~= nil then
                    RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\button.ogg")
                    currentList[selectedSpell] = nil
                    selectedSpell = nil

                    local data = {};

                -- insert currentList values
                for i, spell in pairs(currentList) do
                    table.insert(data, addSpell(i));
                end

                    st:SetData(data);
                    st:ClearSelection()
                    return
                end
                print("No Spell Selected")
            end

            local btn = StdUi:Button(tab.frame, 125, 24, 'Add Spell');
            StdUi:GlueBelow(btn, st, 0, -5, "LEFT");
            btn:SetScript('OnClick', btn_addSpell);
            StdUi:FrameTooltip(btn, 'Add spell to the White or Black list.', 'TOPLEFT', 'TOPRIGHT', true);

            local btn_num = StdUi:NumericBox(tab.frame, 125, 24, 1);
            btn_num:SetMaxValue(9999999);
            btn_num:SetMinValue(0);
            StdUi:GlueBelow(btn_num, btn, 0, -5, 'LEFT');
            btn_num:SetScript("OnTextChanged", function(self, bool, value)
                showTooltip(self, true, self:GetNumber())
                tempAddSpell = self:GetNumber()
            end)

            btn_num:SetScript("OnEnterPressed", function(self, bool, value)
                showTooltip(self, false)
                tempAddSpell = self:GetNumber()
                btn_addSpell()
            end)

            local btn2 = StdUi:Button(tab.frame, 125, 24, 'Delete Spell');
            StdUi:GlueBelow(btn2, st, 0, -5, "RIGHT");
            btn2:SetScript('OnClick', btn_delSpell);
            StdUi:FrameTooltip(btn2, 'Delete a Spell.', 'TOPLEFT', 'TOPRIGHT', true);

            local whiteListOptions = {
                { text = 'Whitelist', value = "Whitelist" },
                { text = 'Blacklist', value = "Blacklist" },
            }

            local whiteListText = (RubimRH.db.profile.mainOption.whiteList == true and 'Whitelist' or 'Blacklist')

            local gn_2_1 = StdUi:Dropdown(tab.frame, 125, 24, whiteListOptions, nil, nil);
            gn_2_1:SetPlaceholder(whiteListText);
            gn_2_1.OnValueChanged = function(self, val)
                RubimRH.db.profile.mainOption.whiteList = (val == "Whitelist" and true or false)
                whiteListText = (RubimRH.db.profile.mainOption.whiteList == true and 'Whitelist' or 'Blacklist')
                gn_2_1:SetText(whiteListText);
            end
            StdUi:GlueBelow(gn_2_1, btn2, 0, -5, 'RIGHT');


            --local ic_2_1 = StdUi:Checkbox(tab.frame, 'Whitelist');
            --StdUi:GlueBelow(ic_2_1, btn2, 0, -24, 'RIGHT');
            --ic_2_1:SetChecked(RubimRH.db.profile.mainOption.whiteList)
            --function ic_2_1:OnValueChanged(self, state, value)
            --    if RubimRH.db.profile.mainOption.whiteList then
            --        RubimRH.db.profile.mainOption.whiteList = false
            --    else
            --        RubimRH.db.profile.mainOption.whiteList = true
            --    end
            --end
        end
        
        if tab.title == "System" then
            local system_title = StdUi:FontString(tab.frame, 'System Configuration');
            StdUi:GlueTop(system_title, tab.frame, 0, -10);
            local gn_separator = StdUi:FontString(tab.frame, '====== WORK IN PROGRESS =======');
            StdUi:GlueTop(gn_separator, system_title, 0, -12);

            local system1_0 = StdUi:Checkbox(tab.frame, 'FPS Optimization');
            StdUi:GlueTop(system1_0, gn_separator, -100, -24, 'LEFT');
            system1_0:SetChecked(RubimRH.db.profile.mainOption.fps)
            StdUi:FrameTooltip(system1_0, 'Optimize your game settings for better FPS', 'TOPLEFT', 'TOPRIGHT', true);
            function system1_0:OnValueChanged(self, state, value)
                if RubimRH.db.profile.mainOption.fps then
                    RubimRH.db.profile.mainOption.fps = false
                else
                    RubimRH.db.profile.mainOption.fps = true
                end
            end

            local system1_1 = StdUi:Checkbox(tab.frame, 'LOS System');
            StdUi:GlueTop(system1_1, gn_separator, -100, -48, 'LEFT');
            system1_1:SetChecked(RubimRH.db.profile.mainOption.los)
            StdUi:FrameTooltip(system1_1, 'Activate LOS check System', 'TOPLEFT', 'TOPRIGHT', true);
            function system1_1:OnValueChanged(self, state, value)
                if RubimRH.db.profile.mainOption.los then
                    RubimRH.db.profile.mainOption.los = false
                else
                    RubimRH.db.profile.mainOption.los = true
                end
            end
            
            local system1_2 = StdUi:Checkbox(tab.frame, 'DBM System');
            StdUi:GlueTop(system1_2, gn_separator, -100, -72, 'LEFT');
            system1_2:SetChecked(RubimRH.db.profile.mainOption.dbm)
            StdUi:FrameTooltip(system1_2, 'Activate DBM Timers synchronization with your CD\'s', 'TOPLEFT', 'TOPRIGHT', true);
            function system1_2:OnValueChanged(self, state, value)
                if RubimRH.db.profile.mainOption.dbm then
                    RubimRH.db.profile.mainOption.dbm = false
                else
                    RubimRH.db.profile.mainOption.dbm = true
                end
            end


            --  Custom language switcher               
            local localesOptions = {
                { text = 'Français', value = "Français" },
                { text = 'English', value = "English" },
                { text = 'Pусский', value = "Pусский" },
            }
            local sys_lang = StdUi:Dropdown(tab.frame, 80, -24, localesOptions, nil, nil);
                sys_lang:SetPlaceholder("|cfff0f8ff|r" .. RubimRH.db.profile.mainOption.activeLanguage);
                StdUi:AddLabel(tab.frame, sys_lang, 'Selected Language', 'TOP');
                StdUi:FrameTooltip(sys_lang, 'Choose between languages', 'TOPLEFT', 'TOPRIGHT', true);                
                 sys_lang.OnValueChanged = function(self, val)
                
                if val == "Français" then
                    print("Langue définie sur Français")
                    RubimRH.db.profile.mainOption.activeLanguage = val                    
                elseif val == "English" then
                    print("Language set on English")
                    RubimRH.db.profile.mainOption.activeLanguage = val                    
                elseif val == "Pусский" then
                    print("Язык установлен на русский")
                    RubimRH.db.profile.mainOption.activeLanguage = val
                else
                    print("An error as occured, no data :(")
                end
                --return currentLanguage
            end
            --StdUi:GlueTop(sys_lang, tab.frame, -100, -24, 'RIGHT');
            StdUi:GlueTop(sys_lang, gn_separator, 50, -68, 'RIGHT');
            
           -- local ic_title = StdUi:FontString(tab.frame, 'Icon');
           -- StdUi:GlueTop(ic_title, tab.frame, 0, -110);
            --local ic_separator = StdUi:FontString(tab.frame, '===================');
            --StdUi:GlueTop(ic_separator, ic_title, 0, -12);
            
            -- Color Picker mainframe
            local colortitle = StdUi:FontString(tab.frame, 'Main UI color :')
            StdUi:GlueTop(colortitle, system1_2, 0, -100, 'LEFT');			
            
            local r, g, b, a = RubimRH.db.profile.mainOption.mainframeColor_r, RubimRH.db.profile.mainOption.mainframeColor_g, RubimRH.db.profile.mainOption.mainframeColor_b, RubimRH.db.profile.mainOption.mainframeColor_a                         
            			
			window:SetBackdropColor(r, g, b, a)    
            local colorInput = StdUi:ColorInput(tab.frame, '', 40, 40, r, g, b, a);
            StdUi:FrameTooltip(colorInput, 'Click to open the color picker', 'TOPLEFT', 'TOPRIGHT', true);                
            StdUi:GlueTop(colorInput, system1_2, 100, -85, 'LEFT');
            function colorInput:OnValueChanged(r, g, b, a)
                window:SetBackdropColor(r, g, b, a)                
                RubimRH.db.profile.mainOption.mainframeColor_r = r 
                RubimRH.db.profile.mainOption.mainframeColor_g = g 
                RubimRH.db.profile.mainOption.mainframeColor_b = b 
                RubimRH.db.profile.mainOption.mainframeColor_a = a 
            end			

			-- Load defaults settings
            local function Loaddefaults()
                -- default color ui
				optionsList = {system1_0,system1_1,system1_2}
				window:SetBackdropColor(0.06, 0.05, 0.03, 0.75)
				colorInput:SetColor(0.06, 0.05, 0.03, 0.75)
				for i=1, 3 do
				    if system1_0:GetChecked() ~= true then			
                        system1_0:SetChecked(RubimRH.db.profile.mainOption.fps)	
                    elseif system1_1:GetChecked() ~= true then					
				        system1_1:SetChecked(RubimRH.db.profile.mainOption.los)
				    elseif system1_2:GetChecked() ~= true then	
				       system1_2:SetChecked(RubimRH.db.profile.mainOption.dbm)                   	
                    else
                        print("All checks done")
                    end	
                end					
            end	
			
            local system1_3 = StdUi:Button(tab.frame, 80, 40, 'Load Defaults Settings');
            StdUi:GlueTop(system1_3, system1_2, 0, -40, 'LEFT');
            system1_3:SetScript('OnClick', Loaddefaults);

        end
        
        if tab.title == "Healer" then
            
            --local heal_title = StdUi:FontString(tab.frame, 'Healer Configuration');
            --StdUi:GlueTop(heal_title, tab.frame, 0, -10);
            --local heal_separator = StdUi:FontString(tab.frame, '===================');
            --StdUi:GlueTop(heal_separator, heal_title, 0, -12);
			
			-- Raid settings title
            local raid_setting_title = StdUi:FontString(tab.frame, 'Raid settings');
            StdUi:GlueTop(raid_setting_title, tab.frame, -270, -10);
			local raid_setting_title_separator = StdUi:FontString(tab.frame, '-----------------');
            StdUi:GlueTop(raid_setting_title_separator, raid_setting_title, 0, -10);
			
			-- Tank settings title
            local tank_setting_title = StdUi:FontString(tab.frame, 'Tank settings');
            StdUi:GlueTop(tank_setting_title, tab.frame, -140, -10);
			local tank_setting_title_separator = StdUi:FontString(tab.frame, '-----------------');
            StdUi:GlueTop(tank_setting_title_separator, tank_setting_title, 0, -10);
			
			-- Profils settings title
            local profils_setting_title = StdUi:FontString(tab.frame, 'Profils settings');
            StdUi:GlueTop(profils_setting_title, tab.frame, 200, -10);
			local profils_setting_title_separator = StdUi:FontString(tab.frame, '-----------------');
            StdUi:GlueTop(profils_setting_title_separator, profils_setting_title, 0, -10);
			
			-- Misc settings title
            local general_setting_title = StdUi:FontString(tab.frame, 'General settings');
            StdUi:GlueTop(general_setting_title, tab.frame, 20, -10);
			local general_setting_title_separator = StdUi:FontString(tab.frame, '-----------------');
            StdUi:GlueTop(general_setting_title_separator, general_setting_title, 0, -10);
			
			-- Cooldowns settings title
            local misc_setting_title = StdUi:FontString(tab.frame, 'Cooldowns settings');
            StdUi:GlueTop(misc_setting_title, tab.frame, 20, -110);
			local misc_setting_title_separator = StdUi:FontString(tab.frame, '-----------------');
            StdUi:GlueTop(misc_setting_title_separator, misc_setting_title, 0, -10);
			
			------------------
			-- Profil system
			------------------
		-- Restoration Druid
		if RubimRH.playerSpec == 105 or RubimRH.playerSpec == 264 or RubimRH.playerSpec == 256 or RubimRH.playerSpec == 257 or RubimRH.playerSpec == 65 then
			
			local profileList = { }
			
			-- Dropdown choice list
            local profileDropdown = StdUi:Dropdown(tab.frame, 90, 25, profileList);
            profileDropdown:SetPlaceholder('Selected Profil');
            StdUi:GlueTop(profileDropdown, profils_setting_title, -40, -50, 'CENTER');
            local function update_profileList( )
                profileList = { }
                for k, v in pairs(RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec]) do
                    table.insert( profileList, { text = k, value = k })
                end
                profileDropdown:SetOptions( profileList )
            end
            update_profileList( )
			
			-- Need to implement a function to refresh all sliders 
			--[[function RubimRH.RefreshSettingsList()
                local data = {};
				for i = 1, #sliders, 2 do
                    table.insert(data, sliders(i));
					currentslider = sliders(i);
					currentslider:SetData(data);
					currentslider:ClearSelection();
                end
            end]]--
			if RubimRH.db.profile.mainOption.selectedProfile == nil then
			   RubimRH.db.profile.mainOption.selectedProfile = "Default"			
			end
			local datavalue = RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec][RubimRH.db.profile.mainOption.selectedProfile]
			
			
			
			---------------------------------
			-- #1 RESTO DRUID SLIDERS VAR  --
			---------------------------------
			if RubimRH.playerSpec == 105
			    ----------------------------
			    -- RAID PART
			    ----------------------------
			    -- Raid germination slider
                local raid_germi_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_germi"]["value"], 1, 100 );
			    -- Raid rejuvenation slider
                local raid_rejuv_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_rejuv"]["value"], 1, 100 );
			    -- Raid wild growth slider
                local raid_wildg_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_wildg"]["value"], 1, 100 );
			    -- Raid cenarion slider
                local raid_cenar_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_cenar"]["value"], 1, 100 );
			    -- Raid efflorescence slider
                local raid_efflo_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_efflo"]["value"], 1, 100 );
			    -- Raid regrowth slider
                local raid_regro_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_regro"]["value"], 1, 100 );		
                --------------------------
			    -- TANK PART
			    --------------------------
			    -- Tank germination slider
                local tank_germi_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_germi"]["value"], 1, 100 );
			     -- Tank rejuvenation slider
                local tank_rejuv_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_rejuv"]["value"], 1, 100 );
			    -- Tank cenarion slider
                local tank_cenar_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_cenar"]["value"], 1, 100 );
			    -- Tank regrowth slider
                local tank_regro_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_regro"]["value"], 1, 100 );
			    -- Tank ironbark slider
                local tank_bark_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_bark"]["value"], 1, 100 );	
			    -- Tank Lifebloom slider
                local tank_lifebloom_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_lifebloom"]["value"], 1, 100 );	
                -----------------------
			    -- MISC SETTINGS PART
			    -----------------------
			    -- Number of party member injured before using flourish...
                local flourish_number = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["nb_flourish"]["value"], 1, 9 );					
			    -- ....and how much hp should these number of party member have before using flourish
                local flourish_health = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["health_flourish"]["value"], 1, 100 );
			    -- Number of party member injured before using tranquility....
                local tranqui_number = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["nb_tranqui"]["value"], 1, 9 );
			    -- ....and how much hp should these number of party member have before using Tranquility
                local tranqui_health = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["health_tranqui"]["value"], 1, 100 );
			
			end
			
			-----------------------------
			-- #2 DISCI PRIEST SLIDERS --
			-----------------------------
			if RubimRH.playerSpec == 256
			    ----------------------------
			    -- RAID PART
			    ----------------------------
			    -- Raid germination slider
                local raid_germi_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_germi"]["value"], 1, 100 );
			    -- Raid rejuvenation slider
                local raid_rejuv_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_rejuv"]["value"], 1, 100 );
			    -- Raid wild growth slider
                local raid_wildg_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_wildg"]["value"], 1, 100 );
			    -- Raid cenarion slider
                local raid_cenar_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_cenar"]["value"], 1, 100 );
			    -- Raid efflorescence slider
                local raid_efflo_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_efflo"]["value"], 1, 100 );
			    -- Raid regrowth slider
                local raid_regro_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_regro"]["value"], 1, 100 );		
                --------------------------
			    -- TANK PART
			    --------------------------
			    -- Tank germination slider
                local tank_germi_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_germi"]["value"], 1, 100 );
			     -- Tank rejuvenation slider
                local tank_rejuv_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_rejuv"]["value"], 1, 100 );
			    -- Tank cenarion slider
                local tank_cenar_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_cenar"]["value"], 1, 100 );
			    -- Tank regrowth slider
                local tank_regro_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_regro"]["value"], 1, 100 );
			    -- Tank ironbark slider
                local tank_bark_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_bark"]["value"], 1, 100 );	
			    -- Tank Lifebloom slider
                local tank_lifebloom_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_lifebloom"]["value"], 1, 100 );	
                -----------------------
			    -- MISC SETTINGS PART
			    -----------------------
			    -- Number of party member injured before using flourish...
                local flourish_number = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["nb_flourish"]["value"], 1, 9 );					
			    -- ....and how much hp should these number of party member have before using flourish
                local flourish_health = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["health_flourish"]["value"], 1, 100 );
			    -- Number of party member injured before using tranquility....
                local tranqui_number = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["nb_tranqui"]["value"], 1, 9 );
			    -- ....and how much hp should these number of party member have before using Tranquility
                local tranqui_health = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["health_tranqui"]["value"], 1, 100 );
			
			end
			
			---------------------------------
			-- #3 HOLY PRIEST SLIDERS VAR  --
			---------------------------------
			if RubimRH.playerSpec == 257
			    ----------------------------
			    -- RAID PART
			    ----------------------------
			    -- Raid germination slider
                local raid_germi_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_germi"]["value"], 1, 100 );
			    -- Raid rejuvenation slider
                local raid_rejuv_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_rejuv"]["value"], 1, 100 );
			    -- Raid wild growth slider
                local raid_wildg_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_wildg"]["value"], 1, 100 );
			    -- Raid cenarion slider
                local raid_cenar_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_cenar"]["value"], 1, 100 );
			    -- Raid efflorescence slider
                local raid_efflo_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_efflo"]["value"], 1, 100 );
			    -- Raid regrowth slider
                local raid_regro_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_regro"]["value"], 1, 100 );		
                --------------------------
			    -- TANK PART
			    --------------------------
			    -- Tank germination slider
                local tank_germi_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_germi"]["value"], 1, 100 );
			     -- Tank rejuvenation slider
                local tank_rejuv_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_rejuv"]["value"], 1, 100 );
			    -- Tank cenarion slider
                local tank_cenar_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_cenar"]["value"], 1, 100 );
			    -- Tank regrowth slider
                local tank_regro_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_regro"]["value"], 1, 100 );
			    -- Tank ironbark slider
                local tank_bark_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_bark"]["value"], 1, 100 );	
			    -- Tank Lifebloom slider
                local tank_lifebloom_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_lifebloom"]["value"], 1, 100 );	
                -----------------------
			    -- MISC SETTINGS PART
			    -----------------------
			    -- Number of party member injured before using flourish...
                local flourish_number = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["nb_flourish"]["value"], 1, 9 );					
			    -- ....and how much hp should these number of party member have before using flourish
                local flourish_health = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["health_flourish"]["value"], 1, 100 );
			    -- Number of party member injured before using tranquility....
                local tranqui_number = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["nb_tranqui"]["value"], 1, 9 );
			    -- ....and how much hp should these number of party member have before using Tranquility
                local tranqui_health = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["health_tranqui"]["value"], 1, 100 );
			
			end
			
			--------------------------------
			-- #4 RESTO SHAM SLIDERS VAR  --
			--------------------------------
			if RubimRH.playerSpec == 264
			    ----------------------------
			    -- RAID PART
			    ----------------------------
			    -- Raid germination slider
                local raid_germi_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_germi"]["value"], 1, 100 );
			    -- Raid rejuvenation slider
                local raid_rejuv_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_rejuv"]["value"], 1, 100 );
			    -- Raid wild growth slider
                local raid_wildg_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_wildg"]["value"], 1, 100 );
			    -- Raid cenarion slider
                local raid_cenar_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_cenar"]["value"], 1, 100 );
			    -- Raid efflorescence slider
                local raid_efflo_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_efflo"]["value"], 1, 100 );
			    -- Raid regrowth slider
                local raid_regro_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_regro"]["value"], 1, 100 );		
                --------------------------
			    -- TANK PART
			    --------------------------
			    -- Tank germination slider
                local tank_germi_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_germi"]["value"], 1, 100 );
			     -- Tank rejuvenation slider
                local tank_rejuv_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_rejuv"]["value"], 1, 100 );
			    -- Tank cenarion slider
                local tank_cenar_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_cenar"]["value"], 1, 100 );
			    -- Tank regrowth slider
                local tank_regro_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_regro"]["value"], 1, 100 );
			    -- Tank ironbark slider
                local tank_bark_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_bark"]["value"], 1, 100 );	
			    -- Tank Lifebloom slider
                local tank_lifebloom_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_lifebloom"]["value"], 1, 100 );	
                -----------------------
			    -- MISC SETTINGS PART
			    -----------------------
			    -- Number of party member injured before using flourish...
                local flourish_number = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["nb_flourish"]["value"], 1, 9 );					
			    -- ....and how much hp should these number of party member have before using flourish
                local flourish_health = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["health_flourish"]["value"], 1, 100 );
			    -- Number of party member injured before using tranquility....
                local tranqui_number = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["nb_tranqui"]["value"], 1, 9 );
			    -- ....and how much hp should these number of party member have before using Tranquility
                local tranqui_health = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["health_tranqui"]["value"], 1, 100 );
			
			end
			
			---------------------------------
			-- #5 HOLY PALADIN SLIDERS VAR --
			---------------------------------
			if RubimRH.playerSpec == 65
			    ----------------------------
			    -- RAID PART
			    ----------------------------
			    -- Raid Flash of Light slider
                local raid_flashlight_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_flashlight"]["value"], 1, 100 );
			    -- Raid Holy Light slider
                local raid_holylight_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_holylight"]["value"], 1, 100 );
			    -- Raid Holy Shock slider
                local raid_holyshock_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_holyshock"]["value"], 1, 100 );
			    -- Raid Light of the Martyr
                local raid_martyr_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_martyr"]["value"], 1, 100 );
				-- Raid Light of Dawn
                local raid_lightofdawn_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["raid_lightofdawn"]["value"], 1, 100 );
		
                --------------------------
			    -- TANK PART
			    --------------------------
			    -- Tank Flash of Light slider
                local tank_flashlight_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_flashlight"]["value"], 1, 100 );
			    -- Tank Holy Light slider
                local tank_holylight_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_holylight"]["value"], 1, 100 );
			    -- Tank Holy Shock slider
                local tank_holyshock_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_holyshock"]["value"], 1, 100 );
			    -- Tank Light of the Martyr
                local tank_martyr_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_martyr"]["value"], 1, 100 );
			    -- Tank Lay on Hands
                local tank_layonhands_slider = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["tank_layonhands"]["value"], 1, 100 );				
                -----------------------
			    -- MISC SETTINGS PART
			    -----------------------
			    -- Divine Shield helth percentage for player
                local divine_shield = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["divine_shield"]["value"], 1, 100 );					
			    -- BeaconOfLight dropdown select
                -- Custom Beacon Options             
                local BeaconOptions = {
                    { text = 'Tank', value = "Tank" },
                    { text = 'Dps', value = "Dps" },
                    { text = 'Healer', value = "Healer" },
			        { text = 'All', value = "All" },
                }
                local beacon_choice = StdUi:Dropdown(tab.frame, 80, -24, BeaconOptions, nil, nil);
                beacon_choice:SetPlaceholder("|cfff0f8ff|r" .. datavalue["beacon_option"]["value"]);
                StdUi:AddLabel(tab.frame, beacon_choice, 'Beacon on:', 'TOP');
                StdUi:FrameTooltip(beacon_choice, 'Choose ', 'TOPLEFT', 'TOPRIGHT', true);                
                beacon_choice.OnValueChanged = function(self, val)
                    if val == "Tank" then
                        print("Beacon of Light will be used on Tanks")
                        datavalue["beacon_option"]["value"] = val                    
                    elseif val == "Dps" then
                        print("Beacon of Light will be used on DPS")
                        datavalue["beacon_option"]["value"] = val                  
                    elseif val == "Healer" then
                        print("Beacon of Light will be used on Healers")
                        datavalue["beacon_option"]["value"] = val 
                    else
                        print("An error as occured, no beacon data :(")
                    end
                end
                StdUi:GlueTop(beacon_choice, tab.frame, 50, -68, 'RIGHT');
			
			    -- Number of party member injured before using Aura Mastery....
                local auramastery_number = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["nb_auramastery"]["value"], 1, 9 );
			    -- ....and how much hp should these number of party member have before using Aura Mastery
                local auramastery_health = StdUi:SliderWithBox(tab.frame, 105, 16, datavalue["health_auramastery"]["value"], 1, 100 );
			
			end
			
			-- Set the value on dropdown menu...
			profileDropdown:SetValue(RubimRH.db.profile.mainOption.selectedProfile, RubimRH.db.profile.mainOption.selectedProfile)
			-- Current profil label
			StdUi:AddLabel( tab.frame, profileDropdown, "Current Profil : " .. RubimRH.db.profile.mainOption.selectedProfile, "TOP" );
            profileDropdown.label:SetFontObject( GameFontNormalLarge )
            profileDropdown.label:SetFont( profileDropdown.label:GetFont( ), 10 )
            profileDropdown.label:SetWidth( 0 )

            -- On dropdown menu value change...
            function profileDropdown:OnValueChanged( value, text )
			    
                --Saving the current profile to another table.
                RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec][RubimRH.db.profile.mainOption.selectedProfile] = RubimRH.db.profile[RubimRH.playerSpec]
                
                --Setting the select profile.
                RubimRH.db.profile[RubimRH.playerSpec] = RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec][value]
                RubimRH.db.profile.mainOption.selectedProfile = value
                RubimRH.Print( 'Profile Changed to: ' .. value )
				local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				
				--------------------------
				-- #2 Sliders Refresh Part
				--------------------------
				----- REFRESH LABELS -----
				--------------------------
				-- Profils label refresh
				profileDropdown.label:SetText("Current Profil : " .. RubimRH.db.profile.mainOption.selectedProfile)
				
				--------------------
				------ DRUID ------- 
				--------------------
				-- RAID PART
				raid_rejuv_slider.label:SetText("Rejuvenation : " .. datavalue["raid_rejuv"]["value"])
				raid_rejuv_slider.editBox:SetValue(datavalue["raid_rejuv"]["value"])
				raid_germi_slider.label:SetText("Germination : " .. datavalue["raid_germi"]["value"])
				raid_germi_slider.editBox:SetValue(datavalue["raid_germi"]["value"])
				raid_wildg_slider.label:SetText("Wild Growth : " .. datavalue["raid_wildg"]["value"])
				raid_wildg_slider.editBox:SetValue(datavalue["raid_wildg"]["value"])
				raid_cenar_slider.label:SetText("Cenarion Wild : " .. datavalue["raid_cenar"]["value"])
				raid_cenar_slider.editBox:SetValue(datavalue["raid_cenar"]["value"])
				raid_efflo_slider.label:SetText("Efflorescence : " .. datavalue["raid_efflo"]["value"])
				raid_efflo_slider.editBox:SetValue(datavalue["raid_efflo"]["value"])
				raid_regro_slider.label:SetText("Regrowth : " .. datavalue["raid_regro"]["value"])
				raid_regro_slider.editBox:SetValue(datavalue["raid_regro"]["value"])
                -- TANK PART
				tank_rejuv_slider.label:SetText("Rejuvenation : " .. datavalue["tank_rejuv"]["value"])
				tank_rejuv_slider.editBox:SetValue(datavalue["tank_rejuv"]["value"])
				tank_germi_slider.label:SetText("Germination : " .. datavalue["tank_germi"]["value"])
				tank_germi_slider.editBox:SetValue(datavalue["tank_germi"]["value"])
				tank_cenar_slider.label:SetText("Cenarion Wild : " .. datavalue["tank_cenar"]["value"])
				tank_cenar_slider.editBox:SetValue(datavalue["tank_cenar"]["value"])
				tank_regro_slider.label:SetText("Regrowth : " .. datavalue["tank_regro"]["value"])
				tank_regro_slider.editBox:SetValue(datavalue["tank_regro"]["value"])
				tank_bark_slider.label:SetText("IronBark : " .. datavalue["tank_bark"]["value"])
				tank_bark_slider.editBox:SetValue(datavalue["tank_bark"]["value"])
				tank_lifebloom_slider.label:SetText("Lifebloom : " .. datavalue["tank_lifebloom"]["value"])
				tank_lifebloom_slider.editBox:SetValue(datavalue["tank_lifebloom"]["value"])
  				
				--------------------
				----- PALADIN ------ 
				--------------------
				-- RAID PART
				raid_flashlight_slider.label:SetText("Flash of Light : " .. datavalue["raid_flashlight"]["value"])
				raid_flashlight_slider.editBox:SetValue(datavalue["raid_flashlight"]["value"])
				raid_holylight_slider.label:SetText("Holy Light : " .. datavalue["raid_holylight"]["value"])
				raid_holylight_slider.editBox:SetValue(datavalue["raid_holylight"]["value"])
				raid_holyshock_slider.label:SetText("Holy Shock : " .. datavalue["raid_holyshock"]["value"])
				raid_holyshock_slider.editBox:SetValue(datavalue["raid_holyshock"]["value"])
				raid_martyr_slider.label:SetText("Light of the Martyr : " .. datavalue["raid_martyr"]["value"])
				raid_martyr_slider.editBox:SetValue(datavalue["raid_martyr"]["value"])
				raid_lightofdawn_slider.label:SetText("Light of Dawn : " .. datavalue["raid_lightofdawn"]["value"])
				raid_lightofdawn_slider.editBox:SetValue(datavalue["raid_lightofdawn"]["value"])
                -- TANK PART
				tank_flashlight_slider.label:SetText("Flash of Light : " .. datavalue["tank_flashlight"]["value"])
				tank_flashlight_slider.editBox:SetValue(datavalue["tank_flashlight"]["value"])
				tank_holylight_slider.label:SetText("Holy Light : " .. datavalue["tank_holylight"]["value"])
				tank_holylight_slider.editBox:SetValue(datavalue["tank_holylight"]["value"])
				tank_holyshock_slider.label:SetText("Holy Shock : " .. datavalue["tank_holyshock"]["value"])
				tank_holyshock_slider.editBox:SetValue(datavalue["tank_holyshock"]["value"])
				tank_martyr_slider.label:SetText("Light of the Martyr : " .. datavalue["tank_martyr"]["value"])
				tank_martyr_slider.editBox:SetValue(datavalue["tank_martyr"]["value"])
				tank_layonhands_slider.label:SetText("Lay on Hands : " .. datavalue["tank_layonhands"]["value"])
				tank_layonhands_slider.editBox:SetValue(datavalue["tank_layonhands"]["value"])

				
            end
			RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec][RubimRH.db.profile.mainOption.selectedProfile] = RubimRH.db.profile[RubimRH.playerSpec]      
			
			-- Profil settings button - OK
            local profileSettingsButton = StdUi:Button(tab.frame, 90, 25, 'Profile Settings' );
			StdUi:GlueTop(profileSettingsButton, profils_setting_title, 60, -50, 'CENTER');
			-- Profil button label
			--StdUi:AddLabel( tab.frame, profileSettingsButton, "Manage my profils", "TOP" );
           -- profileSettingsButton.label:SetFontObject( GameFontNormalLarge )
           -- profileSettingsButton.label:SetFont( profileSettingsButton.label:GetFont( ), 10 )
           -- profileSettingsButton.label:SetWidth( 0 )
			
            profileSettingsButton:SetScript( 'OnClick', function( )
                local rr, gg, bb, aa = RubimRH.db.profile.mainOption.mainframeColor_r, RubimRH.db.profile.mainOption.mainframeColor_g, RubimRH.db.profile.mainOption.mainframeColor_b, RubimRH.db.profile.mainOption.mainframeColor_a			   
                StdUi.config.backdrop.panel = {r = rr, g = gg, b = bb, a = aa}
                local window = StdUi:Window(tab.frame, 'Profile Settings', 300, 150 );
				--window:SetPoint('TOPLEFT', window, 'BOTTOMRIGHT', -10, 10);
				--StdUi:GlueTop(window, tab.frame, 0, 0, 'LEFT');
                --local pRI = StdUi:PanelWithLabel(window, 80, 40, nil, 'GlueRight, Inside');
                local SelectedProfileText = StdUi:FontString( window, "Selected Profile: " .. RubimRH.db.profile.mainOption.selectedProfile );
                local createButton = StdUi:Button( window, 200, 20, 'Create Profile' );
                local createButtonTT = StdUi:FrameTooltip( createButton, 'Create a new profile using the name on the EditBox below.', 'tooltipDropDown', 'TOPRIGHT', true );
                local deleteButton = StdUi:Button( window, 200, 20, 'Delete Profile' );
                local createButtonTT = StdUi:FrameTooltip( deleteButton, 'Delete a profile using the name on the EditBox below.', 'tooltipDropDown', 'TOPRIGHT', true );
                local createNameEditbox = StdUi:EditBox( window, 150, 24, '-- Profile Name --', stringValidator );
                local createNameEditboxTT = StdUi:FrameTooltip( createNameEditbox, 'Sets an profile to create or delete. Only Alphanumeric.', 'tooltipDropDown', 'TOPRIGHT', true );
                
                createButton:SetScript( 'OnClick', function( )
                    local Name = createNameEditbox.value
                    if Name and not Name:match( "%W" ) and Name ~= 'Default' and not RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec][Name] then
                        function deepcopy( orig )
                            local orig_type = type( orig )
                            local copy
                            if orig_type == 'table' then
                                copy = { }
                                for orig_key, orig_value in next, orig, nil do
                                    copy[ deepcopy( orig_key )] = deepcopy( orig_value )
                                end
                                setmetatable( copy, deepcopy( getmetatable( orig )))
                            else -- number, string, boolean, etc
                                copy = orig
                            end
                            return copy
                        end
                        RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec][Name] = deepcopy(RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec]['Default'])
                        RubimRH.Print("Created Profile: " .. Name)
                        update_profileList( )
                    end
                end );
                
                deleteButton:SetScript( "OnClick", function( )
                    local Name = createNameEditbox.value
                    if Name and not Name:match( "%W" ) and Name ~= 'Default' and RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec][Name] then
                        RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec][Name] = nil
                        RubimRH.Print("Deleted Profile: " .. Name)
                        
                        if Name == RubimRH.db.profile.mainOption.selectedProfile then
                            profileDropdown:SetValue('Default', 'Default')
                        end
                        update_profileList( )
                    end
                end );
                
                local function stringValidator( self )
                    local text = self:GetText( );
                    
                    if text:match( "%W" ) then
                        StdUi:MarkAsValid( self, false ); -- red edge
                        RubimRH.Print( "Only Characters and Numbers." )
                        return false;
                    else
                        self.value = text;
                        StdUi:MarkAsValid( self, true );
                        return true;
                    end
                end
                
                --window:SetPoint('CENTER', tab.frame, 'LEFT', 24, 0);
                
                StdUi:EasyLayout( window, { padding = { top = 40 }});
                window:AddRow( ):AddElement( SelectedProfileText );
                window:AddRow( ):AddElements( createButton, deleteButton, { margin = { top = 0 }, column = '6' });
                window:AddRow( ):AddElement( createNameEditbox );
                
                window:Hide( )
                window:SetScript( 'OnShow', function( of )
                    of:DoLayout( );
                end );
                window:Show( )
                -- Popup positionning
                window:SetPoint( 'TOPRIGHT', tab.frame, 'TOPRIGHT', 310, 65 );
            end )
			
			------------------
			--- Healers UI ---
			------------------
            local sliders = { }
			local Name = RubimRH.db.profile.mainOption.selectedProfile
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
			
			--------------------------
			-- DRUID SLIDERS CONFIG --
			--------------------------	
            if playerSpec == 105 then 			
			--------------------
			-- Rejuvenation Raid   			
            StdUi:GlueTop(raid_rejuv_slider, raid_setting_title, 20, -50);
            raid_rejuv_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_rejuv_slider, "Rejuvenation : " .. datavalue["raid_rejuv"]["value"], "TOP" );
            raid_rejuv_slider.label:SetFontObject( GameFontNormalLarge )
            raid_rejuv_slider.label:SetFont( raid_rejuv_slider.label:GetFont( ), 10 )
            raid_rejuv_slider.label:SetWidth( 0 )
            raid_rejuv_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_rejuv"]["value"] = value
				print(datavalue["raid_rejuv"]["value"])
                raid_rejuv_slider.label:SetText("Rejuvenation : " .. datavalue["raid_rejuv"]["value"])
				raid_rejuv_slider.editBox:SetValue(datavalue["raid_rejuv"]["value"])
				
            end;
            table.insert(sliders, raid_rejuv_slider)	
            
			--local rejuv_separator = StdUi:FontString(tab.frame, '--------------------');
            --StdUi:GlueTop(rejuv_separator, raid_rejuv_slider, 0, -5);
			
			-------------------
			-- Germination Raid             
            StdUi:GlueTop(raid_germi_slider, raid_setting_title, 20, -110);
            raid_germi_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_germi_slider, "Germination : " .. datavalue["raid_germi"]["value"], "TOP" );
            raid_germi_slider.label:SetFontObject( GameFontNormalLarge )
            raid_germi_slider.label:SetFont( raid_germi_slider.label:GetFont( ), 10 )
            raid_germi_slider.label:SetWidth( 0 )
            raid_germi_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_germi"]["value"] = value
				print(datavalue["raid_germi"]["value"])
                raid_germi_slider.label:SetText("Germination : " .. datavalue["raid_germi"]["value"])
				raid_germi_slider.editBox:SetValue(datavalue["raid_germi"]["value"])
				
            end;
            table.insert(sliders, raid_germi_slider)			
			        	
			-------------------
			-- Cenarion Raid             
            StdUi:GlueTop(raid_cenar_slider, raid_setting_title, 20, -170);
            raid_cenar_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_cenar_slider, "Cenarion : " .. datavalue["raid_cenar"]["value"], "TOP" );
            raid_cenar_slider.label:SetFontObject( GameFontNormalLarge )
            raid_cenar_slider.label:SetFont( raid_cenar_slider.label:GetFont( ), 10 )
            raid_cenar_slider.label:SetWidth( 0 )
            raid_cenar_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_cenar"]["value"] = value
				print(datavalue["raid_cenar"]["value"])
                raid_cenar_slider.label:SetText("Cenarion : " .. datavalue["raid_cenar"]["value"])
				raid_cenar_slider.editBox:SetValue(datavalue["raid_cenar"]["value"])
				
            end;
            table.insert(sliders, raid_wildg_slider)
			
			-------------------
			-- Regrowth Raid             
            StdUi:GlueTop(raid_regro_slider, raid_setting_title, 20, -230);
            raid_regro_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_regro_slider, "Regrowth : " .. datavalue["raid_regro"]["value"], "TOP" );
            raid_regro_slider.label:SetFontObject( GameFontNormalLarge )
            raid_regro_slider.label:SetFont( raid_regro_slider.label:GetFont( ), 10 )
            raid_regro_slider.label:SetWidth( 0 )
            raid_regro_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_regro"]["value"] = value
				print(datavalue["raid_regro"]["value"])
                raid_regro_slider.label:SetText("Regrowth : " .. datavalue["raid_regro"]["value"])
				raid_regro_slider.editBox:SetValue(datavalue["raid_regro"]["value"])
				
            end;
            table.insert(sliders, raid_regro_slider)
			
			    		-------------------
			-- Wild Growth Raid             
            StdUi:GlueTop(raid_wildg_slider, raid_setting_title, 20, -290);
            raid_wildg_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_wildg_slider, "Wild Growth : " .. datavalue["raid_wildg"]["value"], "TOP" );
            raid_wildg_slider.label:SetFontObject( GameFontNormalLarge )
            raid_wildg_slider.label:SetFont( raid_wildg_slider.label:GetFont( ), 10 )
            raid_wildg_slider.label:SetWidth( 0 )
            raid_wildg_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_wildg"]["value"] = value
				print(datavalue["raid_wildg"]["value"])
                raid_wildg_slider.label:SetText("Wild Growth : " .. datavalue["raid_wildg"]["value"])
				raid_wildg_slider.editBox:SetValue(datavalue["raid_wildg"]["value"])
				
            end;
            table.insert(sliders, raid_wildg_slider)
	    	
			-------------------
			-- Efflorescence Raid             
            StdUi:GlueTop(raid_efflo_slider, raid_setting_title, 20, -350);
            raid_efflo_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_efflo_slider, "Efflorescence : " .. datavalue["raid_efflo"]["value"], "TOP" );
            raid_efflo_slider.label:SetFontObject( GameFontNormalLarge )
            raid_efflo_slider.label:SetFont( raid_efflo_slider.label:GetFont( ), 10 )
            raid_efflo_slider.label:SetWidth( 0 )
            raid_efflo_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_efflo"]["value"] = value
				print(datavalue["raid_efflo"]["value"])
                raid_efflo_slider.label:SetText("Efflorescence : " .. datavalue["raid_efflo"]["value"])
				raid_efflo_slider.editBox:SetValue(datavalue["raid_efflo"]["value"])
				
            end;
            table.insert(sliders, raid_efflo_slider)
			
			-------------------
			-- Tank Part ----
            --------------------
			-- Rejuvenation Tank             
            StdUi:GlueTop(tank_rejuv_slider, tank_setting_title, 20, -50);
            tank_rejuv_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_rejuv_slider, "Rejuvenation : " .. datavalue["tank_rejuv"]["value"], "TOP" );
            tank_rejuv_slider.label:SetFontObject( GameFontNormalLarge )
            tank_rejuv_slider.label:SetFont( tank_rejuv_slider.label:GetFont( ), 10 )
            tank_rejuv_slider.label:SetWidth( 0 )
            tank_rejuv_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_rejuv"]["value"] = value
				print(datavalue["tank_rejuv"]["value"])
                tank_rejuv_slider.label:SetText("Rejuvenation : " .. datavalue["tank_rejuv"]["value"])
				tank_rejuv_slider.editBox:SetValue(datavalue["tank_rejuv"]["value"])
				
            end;
            table.insert(sliders, tank_rejuv_slider)	
            
			-------------------
			-- Germination Tank             
            StdUi:GlueTop(tank_germi_slider, tank_setting_title, 20, -110);
            tank_germi_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_germi_slider, "Germination : " .. datavalue["tank_germi"]["value"], "TOP" );
            tank_germi_slider.label:SetFontObject( GameFontNormalLarge )
            tank_germi_slider.label:SetFont( tank_germi_slider.label:GetFont( ), 10 )
            tank_germi_slider.label:SetWidth( 0 )
            tank_germi_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_germi"]["value"] = value
				print(datavalue["tank_germi"]["value"])
                tank_germi_slider.label:SetText("Germination : " .. datavalue["tank_germi"]["value"])
				tank_germi_slider.editBox:SetValue(datavalue["tank_germi"]["value"])
				
            end;
            table.insert(sliders, tank_germi_slider)			
        	
			-------------------
			-- Cenarion Tank             
            StdUi:GlueTop(tank_cenar_slider, tank_setting_title, 20, -170);
            tank_cenar_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_cenar_slider, "Cenarion : " .. datavalue["tank_cenar"]["value"], "TOP" );
            tank_cenar_slider.label:SetFontObject( GameFontNormalLarge )
            tank_cenar_slider.label:SetFont( tank_cenar_slider.label:GetFont( ), 10 )
            tank_cenar_slider.label:SetWidth( 0 )
            tank_cenar_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_cenar"]["value"] = value
				print(datavalue["tank_cenar"]["value"])
                tank_cenar_slider.label:SetText("Cenarion : " .. datavalue["tank_cenar"]["value"])
				tank_cenar_slider.editBox:SetValue(datavalue["tank_cenar"]["value"])
				
            end;
            table.insert(sliders, tank_cenar_slider)	    	
			
			-------------------
			-- Regrowth Tank             
            StdUi:GlueTop(tank_regro_slider, tank_setting_title, 20, -230);
            tank_regro_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_regro_slider, "Regrowth : " .. datavalue["tank_regro"]["value"], "TOP" );
            tank_regro_slider.label:SetFontObject( GameFontNormalLarge )
            tank_regro_slider.label:SetFont( tank_regro_slider.label:GetFont( ), 10 )
            tank_regro_slider.label:SetWidth( 0 )
            tank_regro_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_regro"]["value"] = value
				print(datavalue["tank_regro"]["value"])
                tank_regro_slider.label:SetText("Regrowth : " .. datavalue["tank_regro"]["value"])
				tank_regro_slider.editBox:SetValue(datavalue["tank_regro"]["value"])
				
            end;
            table.insert(sliders, tank_regro_slider)
			
			-------------------
			-- Ironbark Tank             
            StdUi:GlueTop(tank_bark_slider, tank_setting_title, 20, -290);
            tank_bark_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_bark_slider, "IronBark : " .. datavalue["tank_bark"]["value"], "TOP" );
            tank_bark_slider.label:SetFontObject( GameFontNormalLarge )
            tank_bark_slider.label:SetFont( tank_bark_slider.label:GetFont( ), 10 )
            tank_bark_slider.label:SetWidth( 0 )
            tank_bark_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_bark"]["value"] = value
				print(datavalue["tank_bark"]["value"])
                tank_bark_slider.label:SetText("IronBark : " .. datavalue["tank_bark"]["value"])
				tank_bark_slider.editBox:SetValue(datavalue["tank_bark"]["value"])
				
            end;
            table.insert(sliders, tank_bark_slider)
			
						
			-------------------
			-- Lifebloom Tank             
            StdUi:GlueTop(tank_lifebloom_slider, tank_setting_title, 20, -350);
            tank_lifebloom_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_lifebloom_slider, "Lifebloom : " .. datavalue["tank_lifebloom"]["value"], "TOP" );
            tank_lifebloom_slider.label:SetFontObject( GameFontNormalLarge )
            tank_lifebloom_slider.label:SetFont( tank_lifebloom_slider.label:GetFont( ), 10 )
            tank_lifebloom_slider.label:SetWidth( 0 )
            tank_lifebloom_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_lifebloom"]["value"] = value
				print(datavalue["tank_lifebloom"]["value"])
                tank_lifebloom_slider.label:SetText("Lifebloom : " .. datavalue["tank_lifebloom"]["value"])
				tank_lifebloom_slider.editBox:SetValue(datavalue["tank_lifebloom"]["value"])
				
            end;
            table.insert(sliders, tank_lifebloom_slider)
			
			-------------------
			-- Flourish Number            
            StdUi:GlueTop(flourish_number, misc_setting_title, 0, -50);
            flourish_number:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, flourish_number, "Use Flourish on at least " .. datavalue["nb_flourish"]["value"] .. " people", "TOP" );
            flourish_number.label:SetFontObject( GameFontNormalLarge )
            flourish_number.label:SetFont( flourish_number.label:GetFont( ), 10 )
            flourish_number.label:SetWidth( 0 )
            flourish_number.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["nb_flourish"]["value"] = value
				print(datavalue["nb_flourish"]["value"])
                flourish_number.label:SetText("Use Flourish on at least " .. datavalue["nb_flourish"]["value"] .. " people")
				flourish_number.editBox:SetValue(datavalue["nb_flourish"]["value"])
				flourish_health.label:SetText("and if those " .. datavalue["nb_flourish"]["value"] .. " people HP <= " .. datavalue["health_flourish"]["value"])
				
            end;
            table.insert(sliders, flourish_number)
			
			-------------------
			-- Flourish Health           
            StdUi:GlueTop(flourish_health, misc_setting_title, 140, -50);
            flourish_health:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, flourish_health, "and if those " .. datavalue["nb_flourish"]["value"] .. " people HP <= " .. datavalue["health_flourish"]["value"], "TOP" );
            flourish_health.label:SetFontObject( GameFontNormalLarge )
            flourish_health.label:SetFont( flourish_health.label:GetFont( ), 10 )
            flourish_health.label:SetWidth( 0 )
            flourish_health.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["health_flourish"]["value"] = value
				print(datavalue["health_flourish"]["value"])
                flourish_health.label:SetText("and if those " .. datavalue["nb_flourish"]["value"] .. " people HP <= " .. datavalue["health_flourish"]["value"])
				flourish_health.editBox:SetValue(datavalue["health_flourish"]["value"])
				
            end;
            table.insert(sliders, flourish_health)
	      
		  
 			-------------------
			-- Tranquility Number            
            StdUi:GlueTop(tranqui_number, misc_setting_title, 0, -110);
            tranqui_number:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tranqui_number, "Use Tranqui on at least " .. datavalue["nb_tranqui"]["value"] .. " people", "TOP" );
            tranqui_number.label:SetFontObject( GameFontNormalLarge )
            tranqui_number.label:SetFont( tranqui_number.label:GetFont( ), 10 )
            tranqui_number.label:SetWidth( 0 )
            tranqui_number.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["nb_tranqui"]["value"] = value
				print(datavalue["nb_tranqui"]["value"])
                tranqui_number.label:SetText("Use Tranqui on at least " .. datavalue["nb_tranqui"]["value"] .. " people")
				tranqui_number.editBox:SetValue(datavalue["nb_tranqui"]["value"])
				tranqui_health.label:SetText("and if those " .. datavalue["nb_tranqui"]["value"] .. " people HP <= " .. datavalue["health_tranqui"]["value"])
				
            end;
            table.insert(sliders, tranqui_number)
			
			-------------------
			-- Tranquility Health           
            StdUi:GlueTop(tranqui_health, misc_setting_title, 140, -110);
            tranqui_health:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tranqui_health, "and if those " .. datavalue["nb_tranqui"]["value"] .. " people HP <= " .. datavalue["health_tranqui"]["value"], "TOP" );
            tranqui_health.label:SetFontObject( GameFontNormalLarge )
            tranqui_health.label:SetFont( tranqui_health.label:GetFont( ), 10 )
            tranqui_health.label:SetWidth( 0 )
            tranqui_health.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["health_tranqui"]["value"] = value
				print(datavalue["health_tranqui"]["value"])
                tranqui_health.label:SetText("and if those " .. datavalue["nb_tranqui"]["value"] .. " people HP <= " .. datavalue["health_tranqui"]["value"])
				tranqui_health.editBox:SetValue(datavalue["health_tranqui"]["value"])
				
            end;
            table.insert(sliders, tranqui_health)
		  
		    ----------------------------
			-- Force Rejuv on ALL button
		    local rejuv_all = StdUi:Checkbox(tab.frame, 'Force Rejuvenation');
            StdUi:GlueTop(rejuv_all, general_setting_title, -15, -30, 'LEFT');
            rejuv_all:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].force_rejuv)
			StdUi:FrameTooltip(rejuv_all, 'This will force Rejuvenation cast on everyone until you disable it. Look in WoW Rubim keybind', 'TOPLEFT', 'TOPRIGHT', true);
            function rejuv_all:OnValueChanged(self, state, value)			    
                RubimRH.ForceRejuv()
            end
			
		    ----------------------------
			-- Sync CDs with DBM
		    local dbm_sync = StdUi:Checkbox(tab.frame, 'Sync CDs with DBM');
            StdUi:GlueTop(dbm_sync, general_setting_title, -15, -50, 'LEFT');
            dbm_sync:SetChecked(RubimRH.db.profile[RubimRH.playerSpec].dbm_sync)
			StdUi:FrameTooltip(dbm_sync, 'This will sync your healing CDs with DBM events like big damage inc', 'TOPLEFT', 'TOPRIGHT', true);
            function dbm_sync:OnValueChanged(self, state, value)			    
                RubimRH.DBMSync()
            end
			
			
			end
		    -- The end of resto druid sliders loading
		    
			
			----------------------------
			-- PALADIN SLIDERS CONFIG --
			----------------------------	
            if playerSpec == 65 then 			
			--------------------
			-- Flash of Light   			
            StdUi:GlueTop(raid_flashlight_slider, raid_setting_title, 20, -50);
            raid_flashlight_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_flashlight_slider, "Flash of Light : " .. datavalue["raid_flashlight"]["value"], "TOP" );
            raid_flashlight_slider.label:SetFontObject( GameFontNormalLarge )
            raid_flashlight_slider.label:SetFont( raid_flashlight_slider.label:GetFont( ), 10 )
            raid_flashlight_slider.label:SetWidth( 0 )
            raid_flashlight_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_flashlight"]["value"] = value
				print(datavalue["raid_flashlight"]["value"])
                raid_flashlight_slider.label:SetText("Flash of Light : " .. datavalue["raid_flashlight"]["value"])
				raid_flashlight_slider.editBox:SetValue(datavalue["raid_flashlight"]["value"])
				
            end;
            table.insert(sliders, raid_flashlight_slider)	
			
			--------------------
			-- Holy Light  			
            StdUi:GlueTop(raid_holylight_slider, raid_setting_title, 20, -50);
            raid_holylight_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_holylight_slider, "Holy Light : " .. datavalue["raid_holylight"]["value"], "TOP" );
            raid_holylight_slider.label:SetFontObject( GameFontNormalLarge )
            raid_holylight_slider.label:SetFont( raid_holylight_slider.label:GetFont( ), 10 )
            raid_holylight_slider.label:SetWidth( 0 )
            raid_holylight_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_holylight"]["value"] = value
				print(datavalue["raid_holylight"]["value"])
                raid_holylight_slider.label:SetText("Holy Light : " .. datavalue["raid_holylight"]["value"])
				raid_holylight_slider.editBox:SetValue(datavalue["raid_holylight"]["value"])
				
            end;
            table.insert(sliders, raid_holylight_slider)	
			
			--------------------
			-- Holy Shock		
            StdUi:GlueTop(raid_holyshock_slider, raid_setting_title, 20, -50);
            raid_holyshock_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_holyshock_slider, "Holy Shock : " .. datavalue["raid_holyshock"]["value"], "TOP" );
            raid_holyshock_slider.label:SetFontObject( GameFontNormalLarge )
            raid_holyshock_slider.label:SetFont( raid_holyshock_slider.label:GetFont( ), 10 )
            raid_holyshock_slider.label:SetWidth( 0 )
            raid_holyshock_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_holyshock"]["value"] = value
				print(datavalue["raid_holyshock"]["value"])
                raid_holyshock_slider.label:SetText("Holy Shock : " .. datavalue["raid_holyshock"]["value"])
				raid_holyshock_slider.editBox:SetValue(datavalue["raid_holyshock"]["value"])
				
            end;
            table.insert(sliders, raid_holyshock_slider)
			
			--------------------
			-- Light of the Martyr		
            StdUi:GlueTop(raid_martyr_slider, raid_setting_title, 20, -50);
            raid_martyr_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_martyr_slider, "Light of the Martyr : " .. datavalue["raid_martyr"]["value"], "TOP" );
            raid_martyr_slider.label:SetFontObject( GameFontNormalLarge )
            raid_martyr_slider.label:SetFont( raid_martyr_slider.label:GetFont( ), 10 )
            raid_martyr_slider.label:SetWidth( 0 )
            raid_martyr_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_martyr"]["value"] = value
				print(datavalue["raid_martyr"]["value"])
                raid_martyr_slider.label:SetText("Light of the Martyr : " .. datavalue["raid_martyr"]["value"])
				raid_martyr_slider.editBox:SetValue(datavalue["raid_martyr"]["value"])
				
            end;
            table.insert(sliders, raid_martyr_slider)
			
			
			--------------------
			-- Light of Dawn		
            StdUi:GlueTop(raid_lightofdawn_slider, raid_setting_title, 20, -50);
            raid_lightofdawn_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, raid_lightofdawn_slider, "Light of Dawn : " .. datavalue["raid_lightofdawn"]["value"], "TOP" );
            raid_lightofdawn_slider.label:SetFontObject( GameFontNormalLarge )
            raid_lightofdawn_slider.label:SetFont( raid_lightofdawn_slider.label:GetFont( ), 10 )
            raid_lightofdawn_slider.label:SetWidth( 0 )
            raid_lightofdawn_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["raid_lightofdawn"]["value"] = value
				print(datavalue["raid_lightofdawn"]["value"])
                raid_lightofdawn_slider.label:SetText("Light of Dawn : " .. datavalue["raid_lightofdawn"]["value"])
				raid_lightofdawn_slider.editBox:SetValue(datavalue["raid_lightofdawn"]["value"])
				
            end;
            table.insert(sliders, raid_lightofdawn_slider)
			
			
			--------------------
			-- Tank Flash of Light		
            StdUi:GlueTop(tank_flashlight_slider, raid_setting_title, 20, -50);
            tank_flashlight_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_flashlight_slider, "Flash of Light : " .. datavalue["tank_flashlight"]["value"], "TOP" );
            tank_flashlight_slider.label:SetFontObject( GameFontNormalLarge )
            tank_flashlight_slider.label:SetFont( tank_flashlight_slider.label:GetFont( ), 10 )
            tank_flashlight_slider.label:SetWidth( 0 )
            tank_flashlight_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_flashlight"]["value"] = value
				print(datavalue["tank_flashlight"]["value"])
                tank_flashlight_slider.label:SetText("Flash of Light : " .. datavalue["tank_flashlight"]["value"])
				tank_flashlight_slider.editBox:SetValue(datavalue["tank_flashlight"]["value"])
				
            end;
            table.insert(sliders, tank_flashlight_slider)
			
			
			--------------------
			-- Tank Holy Light		
            StdUi:GlueTop(tank_holylight_slider, raid_setting_title, 20, -50);
            tank_holylight_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_holylight_slider, "Holy Light  : " .. datavalue["tank_holylight"]["value"], "TOP" );
            tank_holylight_slider.label:SetFontObject( GameFontNormalLarge )
            tank_holylight_slider.label:SetFont( tank_holylight_slider.label:GetFont( ), 10 )
            tank_holylight_slider.label:SetWidth( 0 )
            tank_holylight_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_holylight"]["value"] = value
				print(datavalue["tank_holylight"]["value"])
                tank_holylight_slider.label:SetText("Holy Light	 : " .. datavalue["tank_holylight"]["value"])
				tank_holylight_slider.editBox:SetValue(datavalue["tank_holylight"]["value"])
				
            end;
            table.insert(sliders, tank_holylight_slider)
			
			--------------------
			-- Tank Holy Shock	
            StdUi:GlueTop(tank_holyshock_slider, raid_setting_title, 20, -50);
            tank_holyshock_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_holyshock_slider, "Holy Shock  : " .. datavalue["tank_holyshock"]["value"], "TOP" );
            tank_holyshock_slider.label:SetFontObject( GameFontNormalLarge )
            tank_holyshock_slider.label:SetFont( tank_holyshock_slider.label:GetFont( ), 10 )
            tank_holyshock_slider.label:SetWidth( 0 )
            tank_holyshock_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_holyshock"]["value"] = value
				print(datavalue["tank_holyshock"]["value"])
                tank_holyshock_slider.label:SetText("Holy Shock	 : " .. datavalue["tank_holyshock"]["value"])
				tank_holyshock_slider.editBox:SetValue(datavalue["tank_holyshock"]["value"])
				
            end;
            table.insert(sliders, tank_holyshock_slider)

			--------------------
			-- Tank Light of the Martyr
            StdUi:GlueTop(tank_martyr_slider, raid_setting_title, 20, -50);
            tank_martyr_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_martyr_slider, "Light of the Martyr  : " .. datavalue["tank_martyr"]["value"], "TOP" );
            tank_martyr_slider.label:SetFontObject( GameFontNormalLarge )
            tank_martyr_slider.label:SetFont( tank_martyr_slider.label:GetFont( ), 10 )
            tank_martyr_slider.label:SetWidth( 0 )
            tank_martyr_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_martyr"]["value"] = value
				print(datavalue["tank_martyr"]["value"])
                tank_martyr_slider.label:SetText("Light of the Martyr  : " .. datavalue["tank_martyr"]["value"])
				tank_martyr_slider.editBox:SetValue(datavalue["tank_martyr"]["value"])
				
            end;
            table.insert(sliders, tank_martyr_slider)

			--------------------
			-- Tank Lay on Hands
            StdUi:GlueTop(tank_layonhands_slider, raid_setting_title, 20, -50);
            tank_layonhands_slider:SetPrecision( 0 );
            StdUi:AddLabel( tab.frame, tank_layonhands_slider, "Lay on Hands  : " .. datavalue["tank_layonhands"]["value"], "TOP" );
            tank_layonhands_slider.label:SetFontObject( GameFontNormalLarge )
            tank_layonhands_slider.label:SetFont( tank_layonhands_slider.label:GetFont( ), 10 )
            tank_layonhands_slider.label:SetWidth( 0 )
            tank_layonhands_slider.OnValueChanged = function( _, value)
			local datavalue = RubimRH.db.profile[RubimRH.playerSpec]
				datavalue["tank_layonhands"]["value"] = value
				print(datavalue["tank_layonhands"]["value"])
                tank_layonhands_slider.label:SetText("Lay on Hands  : " .. datavalue["tank_layonhands"]["value"])
				tank_layonhands_slider.editBox:SetValue(datavalue["tank_layonhands"]["value"])
				
            end;
            table.insert(sliders, tank_layonhands_slider)
			
			
		end
	    -- The end of spec == druid or paladin or shaman or priest
	
	-- The end of Healer tab --
	end 
	 
	 
	 
        -------------------	 
		-- MSG Addon things
		-------------------
        if tab.title == "MSG Actions" then
		
            local msg_title = StdUi:FontString(tab.frame, 'Action Message Macro');
            StdUi:GlueTop(msg_title, tab.frame, 0, -10);
            local gn_separator = StdUi:FontString(tab.frame, '===================');
            StdUi:GlueTop(gn_separator, msg_title, 0, -12);

			-- Leap of Faith macro
            local function btn_creategrip()
                RubimRH.print("Macro for Leap of Faith was created. Check your Character Macros and give the macro to your mate")
				CreateMacro("Leap of Faith","priest_spell_leapoffaith_a", "/script C_ChatInfo.SendAddonMessage(\"grip\", UnitName(\"player\"), \"RAID\")", 1)
                RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\button.ogg")
                --print("Macro creation worked")
            end     
            local btngrip = StdUi:Button(tab.frame, 120, 24, 'Create Grip Macro');
            --StdUi:GlueBelow(btngrip, tab.frame, 0, -24, "RIGHT");
			StdUi:GlueTop(btngrip, tab.frame, 10, -40, 'LEFT');
            btngrip:SetScript('OnClick', btn_creategrip);
            StdUi:FrameTooltip(btngrip, 'This will create a Leap of Faith macro to give to your mate :)', 'TOPLEFT', 'TOPRIGHT', true);

			-- Ironbark macro todo
            local function btn_createbark()
                RubimRH.print("Macro for Ironbark  was created. Check your Character Macros and give the macro to your mate")
				CreateMacro("Ironbark ","spell_druid_ironbark", "/script C_ChatInfo.SendAddonMessage(\"bark\", UnitName(\"player\"), \"RAID\")", 1)
                RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\button.ogg")
                --print("Macro creation worked")
            end     
            local btnbark = StdUi:Button(tab.frame, 120, 24, 'Create Bark Macro');
            --StdUi:GlueBelow(btngrip, tab.frame, 0, -24, "RIGHT");
			StdUi:GlueTop(btnbark, tab.frame, 10, -70, 'LEFT');
            btnbark:SetScript('OnClick', btn_createbark);
            StdUi:FrameTooltip(btnbark, 'This will create an Ironbark macro to give to your mate :)', 'TOPLEFT', 'TOPRIGHT', true);

			-- Priestt life swap macro todo
            local function btn_createswap()
                RubimRH.print("Macro for Void Shift was created. Check your Character Macros and give the macro to your mate")
				CreateMacro("Void Shift","spell_priest_voidshift", "/script C_ChatInfo.SendAddonMessage(\"swap\", UnitName(\"player\"), \"RAID\")", 1)
                RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\button.ogg")
                --print("Macro creation worked")
            end     
            local btnswap = StdUi:Button(tab.frame, 120, 24, 'Create Void Shift Macro');
            --StdUi:GlueBelow(btngrip, tab.frame, 0, -24, "RIGHT");
			StdUi:GlueTop(btnswap, tab.frame, 10, -100, 'LEFT');
            btnswap:SetScript('OnClick', btn_createswap);
            StdUi:FrameTooltip(btnswap, 'This will create a Void Shift macro to give to your mate :)', 'TOPLEFT', 'TOPRIGHT', true);

			-- Paladin bop macro todo
            local function btn_createbop()
                RubimRH.print("Macro for Blessing of Protection was created. Check your Character Macros and give the macro to your mate")
				CreateMacro("Blessing of Protection","spell_holy_sealofprotection", "/script C_ChatInfo.SendAddonMessage(\"bop\", UnitName(\"player\"), \"RAID\")", 1)
                RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\button.ogg")
                --print("Macro creation worked")
            end     
            local btnbop = StdUi:Button(tab.frame, 120, 24, 'Create Bop Macro');
            --StdUi:GlueBelow(btngrip, tab.frame, 0, -24, "RIGHT");
			StdUi:GlueTop(btnbop, tab.frame, 10, -130, 'LEFT');
            btnbop:SetScript('OnClick', btn_createbop);
            StdUi:FrameTooltip(btnbop, 'This will create a Blessing of Protection macro to give to your mate :)', 'TOPLEFT', 'TOPRIGHT', true);			
			

           -- end           
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
end

function RubimRH.ClassConfig(specID)
    AllMenu('secondTab')
end
