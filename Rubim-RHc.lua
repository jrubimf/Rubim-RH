---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rubim.
--- DateTime: 02/06/2018 12:53
---
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")

_G["RubimRH"] = RubimRH
function RubimRH.CDToggle()
    PlaySound(891, "Master");
    if useCD == false then
        varClass.cooldown = true
        useCD = true
    else
        useCD = false
        varClass.cooldown = false
    end
    print("|cFF69CCF0CD" .. "|r: |cFF00FF00" .. tostring(useCD))
end

local options, configOptions = nil, {}
--[[ This options table is used in the GUI config. ]]--
local function getOptions()
    if not options then
        options = {
            type = "group",
            name = "RubimRH",
            args = {
                mainOptions = {
                    order = 1,
                    type = "group",
                    name = "General",
                    childGroups = "tab",
                    args = {
                        general = {
                            order = 1,
                            type = "group",
                            childGroups = "tab",
                            inline = false,
                            name = "General",
                            get = function(info)
                                local key = info.arg or info[#info]
                                return RubimRH.db.profile.mo[key]
                            end,
                            set = function(info, value)
                                local key = info.arg or info[#info]
                                RubimRH.db.profile.mo[key] = value
                            end,
                            args = {
                                cooldownbind = {
                                    order = 1,
                                    type = "keybinding",
                                    get = function()
                                        return GetBindingKey("Cooldown Toggle")
                                    end,
                                    set = function(info, v)
                                        SetBinding(v, "Cooldown Toggle")
                                        SaveBindings(GetCurrentBindingSet())
                                    end,
                                    name = "Cooldowns"
                                },
                                interruptsbind = {
                                    order = 2,
                                    type = "keybinding",
                                    get = function()
                                        return GetBindingKey("Interrupt Toggle")
                                    end,
                                    set = function(info, v)
                                        SetBinding(v, "Interrupt Toggle")
                                        SaveBindings(GetCurrentBindingSet())
                                    end,
                                    name = "Interrupts"
                                },
                            }
                        },
                    }
                },
                Classes = {
                    order = 1,
                    type = "group",
                    name = "Classes",
                    args = {
                        frost = {
                            order = 2,
                            type = "group",
                            childGroups = "tab",
                            inline = false,
                            name = "Death Knight - Frost",
                            get = function(info)
                                local key = info.arg or info[#info]
                                return RubimRH.db.profile.dk.frost[key]
                            end,
                            set = function(info, value)
                                local key = info.arg or info[#info]
                                RubimRH.db.profile.dk.frost[key] = value
                            end,
                            args = {
                                cooldown = {
                                    order = 1,
                                    type = "toggle",
                                    get = function()
                                        return useCD
                                    end,
                                    set = function(info, v)
                                        RubimRH.CDToggle()
                                    end,
                                    name = "Cooldowns"
                                },
                                deathstrike = {
                                    order = 3,
                                    type = "range",
                                    min = 5,
                                    max = 95,
                                    step = 5,
                                    --fontSize = "medium",
                                    name = "Death Strike (Dark Succur)"
                                },
                            }
                        },
                        unholy = {
                            order = 3,
                            type = "group",
                            childGroups = "tab",
                            inline = false,
                            name = "Death Knight - Unholy",
                            get = function(info)
                                local key = info.arg or info[#info]
                                return RubimRH.db.profile.dk.unholy[key]
                            end,
                            set = function(info, value)
                                local key = info.arg or info[#info]
                                RubimRH.db.profile.dk.unholy[key] = value
                            end,
                            args = {
                                cooldown = {
                                    order = 1,
                                    type = "toggle",
                                    get = function()
                                        return useCD
                                    end,
                                    set = function(info, v)
                                        RubimRH.CDToggle()
                                    end,
                                    name = "Cooldowns"
                                },
                                deathstrike = {
                                    order = 1,
                                    type = "range",
                                    min = 5,
                                    max = 95,
                                    step = 5,
                                    --fontSize = "medium",
                                    name = "Death Strike (Dark Succur)"
                                },
                            }
                        },
                        prot = {
                            order = 4,
                            type = "group",
                            childGroups = "tab",
                            inline = false,
                            name = "Paladin - Protection",
                            get = function(info)
                                local key = info.arg or info[#info]
                                return RubimRH.db.profile.pl.prot[key]
                            end,
                            set = function(info, value)
                                local key = info.arg or info[#info]
                                RubimRH.db.profile.pl.prot[key] = value
                            end,
                            args = {
                                cooldown = {
                                    order = 1,
                                    type = "toggle",
                                    get = function()
                                        return useCD
                                    end,
                                    set = function(info, v)
                                        RubimRH.CDToggle()
                                    end,
                                    name = "Cooldowns"
                                },
                                layonahandspct = {
                                    order = 1,
                                    type = "range",
                                    min = 5,
                                    max = 95,
                                    step = 5,
                                    --fontSize = "medium",
                                    name = "Lay on Hands"
                                },
                                ardentdefenderpct = {
                                    order = 2,
                                    type = "range",
                                    min = 5,
                                    max = 95,
                                    step = 5,
                                    --fontSize = "medium",
                                    name = "Ardent Defender"
                                },
                                guardianofancientkingspct = {
                                    order = 3,
                                    type = "range",
                                    min = 5,
                                    max = 95,
                                    step = 5,
                                    --fontSize = "medium",
                                    name = "Guardian of Ancient Kings"
                                },
                            }
                        },
                        ret = {
                            order = 5,
                            type = "group",
                            childGroups = "tab",
                            inline = false,
                            name = "Paladin - Retribution",
                            get = function(info)
                                local key = info.arg or info[#info]
                                return RubimRH.db.profile.pl.ret[key]
                            end,
                            set = function(info, value)
                                local key = info.arg or info[#info]
                                RubimRH.db.profile.pl.ret[key] = value
                            end,
                            args = {
                                cooldown = {
                                    order = 1,
                                    type = "toggle",
                                    get = function()
                                        return useCD
                                    end,
                                    set = function(info, v)
                                        RubimRH.CDToggle()
                                    end,
                                    name = "Cooldowns"
                                },
                                justicarglory = {
                                    order = 1,
                                    type = "range",
                                    min = 5,
                                    max = 95,
                                    step = 5,
                                    --fontSize = "medium",
                                    name = "Justicar/Word of Glory"
                                },
                            }
                        },
                        feral = {
                            order = 6,
                            type = "group",
                            childGroups = "tab",
                            inline = false,
                            name = "Druid - Feral",
                            get = function(info)
                                local key = info.arg or info[#info]
                                return RubimRH.db.profile.dr.feral[key]
                            end,
                            set = function(info, value)
                                local key = info.arg or info[#info]
                                RubimRH.db.profile.dr.feral[key] = value
                            end,
                            args = {
                                cooldown = {
                                    order = 1,
                                    type = "toggle",
                                    get = function()
                                        return useCD
                                    end,
                                    set = function(info, v)
                                        RubimRH.CDToggle()
                                    end,
                                    name = "Cooldowns"
                                },
                                renewal = {
                                    order = 1,
                                    type = "range",
                                    min = 5,
                                    max = 95,
                                    step = 5,
                                    --fontSize = "medium",
                                    name = "Renewal"
                                },
                                regrowth = {
                                    order = 1,
                                    type = "range",
                                    min = 5,
                                    max = 95,
                                    step = 5,
                                    --fontSize = "medium",
                                    name = "Regrowth"
                                },
                            }
                        },
                        arms = {
                            order = 7,
                            type = "group",
                            childGroups = "tab",
                            inline = false,
                            name = "Warrior - Arms",
                            get = function(info)
                                local key = info.arg or info[#info]
                                return RubimRH.db.profile.wr.arms[key]
                            end,
                            set = function(info, value)
                                local key = info.arg or info[#info]
                                RubimRH.db.profile.wr.arms[key] = value
                            end,
                            args = {
                                cooldown = {
                                    order = 1,
                                    type = "toggle",
                                    get = function()
                                        return useCD
                                    end,
                                    set = function(info, v)
                                        RubimRH.CDToggle()
                                    end,
                                    name = "Cooldowns"
                                },
                                victoryrush = {
                                    order = 1,
                                    type = "range",
                                    min = 5,
                                    max = 95,
                                    step = 5,
                                    --fontSize = "medium",
                                    name = "Victory Rush"
                                },
                            }
                        },
                    }
                },
            }
        }
        for k, v in pairs(configOptions) do
            options.args[k] = (type(v) == "function") and v() or v
        end
    end

    return options
end

local function openConfig()
    InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.Profiles)
    InterfaceOptionsFrame_OpenToCategory(RubimRH.optionsFrames.RubimRH)
    InterfaceOptionsFrame:Raise()
end

function RubimRH:SetupOptions()
    self.optionsFrames = {}

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RubimRH", getOptions)
    self.optionsFrames.RubimRH = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RubimRH", nil, nil, "mainOptions")
    self.optionsFrames["Profiles"] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RubimRH", "Classes", "RubimRH", "Classes")
--    self.optionsFrames["Profiles"] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RubimRH", "Paladin", "RubimRH", "Paladin")
--    self.optionsFrames["Profiles"] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RubimRH", "Warrior", "RubimRH", "Warrior")
--    self.optionsFrames["Profiles"] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RubimRH", "Druid", "RubimRH", "Druid")
    configOptions["Profiles"] = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    self.optionsFrames["Profiles"] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RubimRH", "Profiles", "RubimRH", "Profiles")

    LibStub("AceConsole-3.0"):RegisterChatCommand("RubimRH", openConfig)
end
