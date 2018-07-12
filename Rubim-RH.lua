local foundError = false
local errorEvent = CreateFrame("Frame")
errorEvent:RegisterEvent("PLAYER_LOGIN")
errorEvent:SetScript("OnEvent", function(self, event)
    if AethysCore == nil then
        message("Missing dependency: Aethys Core")
        foundError = true
    end
    if AethysCache == nil then
        message("Missing dependency: Aetyhs Cache")
        foundError = true
    end

    if RubimExtra == false then
        message("Missing dependency: RubimExtra")
        foundError = true
    end

    if GetCVar("nameplateShowEnemies") ~= "1" then
        message("Is nameplates off? You need it in order to get the most optimal results..");
    end
end)

local RubimRH = LibStub("AceAddon-3.0"):NewAddon("RubimRH", "AceEvent-3.0", "AceConsole-3.0")
_G["RubimRH"] = RubimRH
local AceGUI = LibStub("AceGUI-3.0")
RubimRH.varClass = {}
RubimRH.currentSpec = "None"

-- Defines the APL
RubimRH.Rotation = {}
RubimRH.Rotation.APLs = {}
RubimRH.Rotation.PASSIVEs = {}

function RubimRH.Rotation.SetAPL (Spec, APL)
    RubimRH.Rotation.APLs[Spec] = APL;
end

function RubimRH.Rotation.SetPASSIVE (Spec, PASSIVE)
    RubimRH.Rotation.PASSIVEs[Spec] = PASSIVE;
end

local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;

local EnabledRotation = {
    -- Death Knight
    [250] = true, -- Blood
    [251] = true, -- Frost
    [252] = true, -- Unholy
    -- Demon Hunter
    [577] = true, -- Havoc
    [581] = true, -- Vengeance
    -- Druid
    [102] = false, -- Balance
    [103] = true, -- Feral
    [104] = true, -- Guardian
    [105] = false, -- Restoration
    -- Hunter
    [253] = false, -- Beast Mastery
    [254] = true, -- Marksmanship
    [255] = true, -- Survival
    -- Mage
    [62] = false, -- Arcane
    [63] = false, -- Fire
    [64] = false, -- Frost
    -- Monk
    [268] = true, -- Brewmaster
    [269] = true, -- Windwalker
    [270] = false, -- Mistweaver
    -- Paladin
    [65] = true, -- Holy
    [66] = true, -- Protection
    [70] = true, -- Retribution
    -- Priest
    [256] = false, -- Discipline
    [257] = false, -- Holy
    [258] = false, -- Shadow
    -- Rogue
    [259] = false, -- Assassination
    [260] = true, -- Outlaw
    [261] = false, -- Subtlety
    -- Shaman
    [262] = false, -- Elemental
    [263] = true, -- Enhancement
    [264] = false, -- Restoration
    -- Warlock
    [265] = false, -- Affliction
    [266] = false, -- Demonology
    [267] = false, -- Destruction
    -- Warrior
    [71] = true, -- Arms
    [72] = true, -- Fury
    [73] = true  -- Protection
}

--DK
local DeathStrike = 49998
local RuneTap = 194679
local BreathOfSindragosa = 152279
local SindragosasFury = 190778
local PillarOfFrost = 51271
local DeathandDecay = 43265
--DH
local FelRush = 195072
local EyeBeam = 198013
local FelBarrage = 211053
--Warrior
local Warbreaker = 209577
local Ravager = 152277
local OdynsFury = 205545
local Charge = 100
--Paladin
local JusticarVengeance = 215661
local WordofGlory = 210191
local LayonHands = 633
local GuardianofAncientKings = 86659
local ArdentDefender = 31850
--Shaman
local HealingSurge = 188070
--Druid
local Regrowth = 8936
local Renewal = 108238

local defaults = {
    profile = {
        mainOption = {
            updateConf = "yes",
            cooldownbind = nil,
            interruptsbind = nil,
            aoebind = nil,
            ccbreak = true,
            startattack = false,
            healthstoneper = 20,
            align = "CENTER",
            xCord = 0,
            yCord = -200,
            disabledSpells = {}
        },
        DemonHunter = {
            Havoc = {
                cooldown = true,
                Spells = {
                    { spellID = FelRush, isActive = true },
                    { spellID = EyeBeam, isActive = true },
                    { spellID = FelBarrage, isActive = true }
                }
            },
            Vengeance = {
                cooldown = true,
            },
        },
        DeathKnight = {
            Blood = {
                cooldown = true,
                smartds = 30,
                deficitds = 10,
                Spells = {
                    { spellID = DeathStrike, isActive = false, description = "Enable Smart USE of Death Strike.\nBanking DS and only use on extreme scenarios." },
                    { spellID = RuneTap, isActive = false, description = "Always bank runes so we can use Rune Tap." },
                    { spellID = DeathandDecay, isActive = true, description = "Disable Death and Decay." }
                }
            },
            Frost = {
                cooldown = true,
                deathstrike = 85,
                Spells = {
                    { spellID = DeathStrike, isActive = true },
                    { spellID = BreathOfSindragosa, isActive = true },
                    { spellID = SindragosasFury, isActive = true },
                    { spellID = PillarOfFrost, isActive = true }
                }
            },
            Unholy = {
                cooldown = true,
                deathstrike = 85,
                Spells = {
                    { spellID = DeathStrike, isActive = true },
                    { spellID = RuneTap, isActive = true }
                }
            },
        },
        Paladin = {
            Retribution = {
                cooldown = true,
                justicarglory = 50,
                Spells = {
                    { spellID = JusticarVengeance, isActive = true }
                }
            },
            Holy = {
                cooldown = true,
            },
            Protection = {
                cooldown = true,
                lightoftheprotectorpct = 90,
                layonahandspct = 20,
                ardentdefenderpct = 5,
                guardianofancientkingspct = 50,
                Spells = {
                    { spellID = LayonHands, isActive = false },
                    { spellID = ArdentDefender, isActive = false },
                    { spellID = GuardianofAncientKings, isActive = false },
                }
            },
        },
        Warrior = {
            Arms = {
                cooldown = true,
                victoryrush = 80,
                Spells = {
                    { spellID = Warbreaker, isActive = true },
                    { spellID = Ravager, isActive = true },
                    { spellID = Charge, isActive = true }
                }
            },
            Fury = {
                cooldown = true,
                Spells = {
                    { spellID = OdynsFury, isActive = true },
                    { spellID = Charge, isActive = true }
                }
            },
            Protection = {
                cooldown = true,
                victoryrush = 80,
            }
        },
        Rogue = {
            Outlaw = {
                cooldown = true,
            },
            Subtlety = {
                cooldown = true,
            },
            Assassination = {
                cooldown = true,
            }
        },
        Hunter = {
            Marksmanship = {
                cooldown = true,
            },
            Beastmaster = {
                cooldown = true,
            },

            Survival = {
                cooldown = true,
            }
        },
        Monk = {
            Brewmaster = {
                cooldown = true,
            },
            Windwalker = {
                cooldown = true,
            },
        },
        Shaman = {
            Enhancement = {
                healingsurge = 80,
                cooldown = true,
                Spells = {
                    { spellID = HealingSurge, isActive = true }
                }
            },
        },
        Druid = {
            Feral = {
                cooldowns = false,
                renewal = 50,
                regrowth = 85,
                Spells = {
                    { spellID = Renewal, isActive = true },
                    { spellID = Regrowth, isActive = true },
                }
            },
            Guardian = {
                cooldowns = false,
            }
        }
    }
}

--[[ RubimRH Initialize ]]--
function RubimRH:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("RubimRHDB", defaults, true)
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
    self.db.RegisterCallback(self, "OnNewProfile", "OnNewProfile")
    self:SetupOptions()
end

local updateClassVariables = CreateFrame("Frame")
updateClassVariables:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
updateClassVariables:RegisterEvent("PLAYER_LOGIN")

local playerSpec = 0
updateClassVariables:SetScript("OnEvent", function(self, event, ...)
    playerSpec = Cache.Persistent.Player.Spec[1] or 0
    if playerSpec ~= 0 then
        Player:RegisterListenedSpells(playerSpec)
    end
    RubimRH.varClass = {}
    RubimRH.varSpells = {}

    --DeathKnight
    if playerSpec == 250 then
        RubimRH.varClass = RubimRH.db.profile.DeathKnight.Blood
        RubimRH.varSpells = AethysCore.Spell.DeathKnight.Blood
    end
    if playerSpec == 251 then
        RubimRH.varClass = RubimRH.db.profile.DeathKnight.Frost
        RubimRH.varSpells = AethysCore.Spell.DeathKnight.Frost
    end
    if playerSpec == 252 then
        RubimRH.varClass = RubimRH.db.profile.DeathKnight.Unholy
        RubimRH.varSpells = AethysCore.Spell.DeathKnight.Unholy
    end
    --DemonHunter
    if playerSpec == 577 then
        RubimRH.varClass = RubimRH.db.profile.DemonHunter.Havoc
        RubimRH.varSpells = AethysCore.Spell.DemonHunter.Havoc
    end
    if playerSpec == 581 then
        RubimRH.varClass = RubimRH.db.profile.DemonHunter.Vengeance
        RubimRH.varSpells = AethysCore.Spell.DemonHunter.Vengeance
    end
    --Druid
    if playerSpec == 102 then
        RubimRH.varClass = RubimRH.db.profile.Druid.Balance
        RubimRH.varSpells = AethysCore.Spell.Druid.Balance
    end
    if playerSpec == 103 then
        RubimRH.varClass = RubimRH.db.profile.Druid.Feral
        RubimRH.varSpells = AethysCore.Spell.Druid.Feral
    end
    if playerSpec == 104 then
        RubimRH.varClass = RubimRH.db.profile.Druid.Guardian
        RubimRH.varSpells = AethysCore.Spell.Druid.Guardian
    end
    if playerSpec == 105 then
        RubimRH.varClass = RubimRH.db.profile.Druid.Restoration
        RubimRH.varSpells = AethysCore.Spell.Druid.Restoration
    end
    --Hunter
    if playerSpec == 253 then
        RubimRH.varClass = RubimRH.db.profile.Hunter.BeastMastery
        RubimRH.varSpells = AethysCore.Spell.Hunter.BeastMastery
    end
    if playerSpec == 254 then
        RubimRH.varClass = RubimRH.db.profile.Hunter.Marksmanship
        RubimRH.varSpells = AethysCore.Spell.Hunter.Marksmanship
    end
    if playerSpec == 255 then
        RubimRH.varClass = RubimRH.db.profile.Hunter.Survival
        RubimRH.varSpells = AethysCore.Spell.Hunter.Survival
    end
    --Mage
    if playerSpec == 62 then
        RubimRH.varClass = RubimRH.db.profile.Mage.Arcane
        RubimRH.varSpells = AethysCore.Spell.Mage.Arcane
    end
    if playerSpec == 63 then
        RubimRH.varClass = RubimRH.db.profile.Mage.Fire
        RubimRH.varSpells = AethysCore.Spell.Mage.Fire
    end
    if playerSpec == 64 then
        RubimRH.varClass = RubimRH.db.profile.Mage.Frost
        RubimRH.varSpells = AethysCore.Spell.Mage.Frost
    end
    --Monk
    if playerSpec == 268 then
        RubimRH.varClass = RubimRH.db.profile.Monk.Brewmaster
        RubimRH.varSpells = AethysCore.Spell.Monk.Brewmaster
    end
    if playerSpec == 269 then
        RubimRH.varClass = RubimRH.db.profile.Monk.Windwalker
        RubimRH.varSpells = AethysCore.Spell.Monk.Windwalker
    end
    if playerSpec == 270 then
        RubimRH.varClass = RubimRH.db.profile.Monk.Mistweaver
        RubimRH.varSpells = AethysCore.Spell.Monk.Mistweaver
    end
    --Paladin
    if playerSpec == 65 then
        RubimRH.varClass = RubimRH.db.profile.Paladin.Holy
        RubimRH.varSpells = AethysCore.Spell.Paladin.Holy
    end
    if playerSpec == 66 then
        RubimRH.varClass = RubimRH.db.profile.Paladin.Protection
        RubimRH.varSpells = AethysCore.Spell.Paladin.Protection
    end
    if playerSpec == 70 then
        RubimRH.varClass = RubimRH.db.profile.Paladin.Retribution
        RubimRH.varSpells = AethysCore.Spell.Paladin.Retribution
    end
    --Priest
    if playerSpec == 256 then
        RubimRH.varClass = RubimRH.db.profile.Priest.Discipline
        RubimRH.varSpells = AethysCore.Spell.Priest.Discipline
    end
    if playerSpec == 257 then
        RubimRH.varClass = RubimRH.db.profile.Priest.Holy
        RubimRH.varSpells = AethysCore.Spell.Priest.Holy
    end
    if playerSpec == 258 then
        RubimRH.varClass = RubimRH.db.profile.Priest.Shadow
        RubimRH.varSpells = AethysCore.Spell.Priest.Shadow
    end
    --Rogue
    if playerSpec == 259 then
        RubimRH.varClass = RubimRH.db.profile.Rogue.Assassination
        RubimRH.varSpells = AethysCore.Spell.Rogue.Assassination
    end
    if playerSpec == 260 then
        RubimRH.varClass = RubimRH.db.profile.Rogue.Outlaw
        RubimRH.varSpells = AethysCore.Spell.Rogue.Outlaw
    end
    if playerSpec == 261 then
        RubimRH.varClass = RubimRH.db.profile.Rogue.Subtlety
        RubimRH.varSpells = AethysCore.Spell.Rogue.Subtlety
    end
    --Shaman
    if playerSpec == 262 then
        RubimRH.varClass = RubimRH.db.profile.Shaman.Elemental
        RubimRH.varSpells = AethysCore.Spell.Shaman.Elemental
    end
    if playerSpec == 263 then
        RubimRH.varClass = RubimRH.db.profile.Shaman.Enhancement
        RubimRH.varSpells = AethysCore.Spell.Shaman.Enhancement
    end
    if playerSpec == 264 then
        RubimRH.varClass = RubimRH.db.profile.Shaman.Restoration
        RubimRH.varSpells = AethysCore.Spell.Shaman.Restoration
    end
    --Warlock
    if playerSpec == 265 then
        RubimRH.varClass = RubimRH.db.profile.Warlock.Affliction
        RubimRH.varSpells = AethysCore.Spell.Warlock.Affliction
    end
    if playerSpec == 266 then
        RubimRH.varClass = RubimRH.db.profile.Warlock.Demonology
        RubimRH.varSpells = AethysCore.Spell.Warlock.Demonology
    end
    if playerSpec == 267 then
        RubimRH.varClass = RubimRH.db.profile.Warlock.Destruction
        RubimRH.varSpells = AethysCore.Spell.Warlock.Destruction
    end
    --Warrior
    if playerSpec == 71 then
        RubimRH.varClass = RubimRH.db.profile.Warrior.Arms
        RubimRH.varSpells = AethysCore.Spell.Warrior.Arms
    end
    if playerSpec == 72 then
        RubimRH.varClass = RubimRH.db.profile.Warrior.Fury
        RubimRH.varSpells = AethysCore.Spell.Warrior.Fury
    end
    if playerSpec == 73 then
        RubimRH.varClass = RubimRH.db.profile.Warrior.Protection
        RubimRH.varSpells = AethysCore.Spell.Warrior.Protection
    end


    RubimRH.useCD = RubimRH.varClass.cooldown or false
    ccBreak = RubimRH.db.profile.mainOption.ccbreak
end)

function RubimRH:OnEnable()
    print("|cffc41f3bRubim RH|r: |cffffff00/rubimrh|r for GUI menu")
end

function RubimRH:OnProfileChanged(event, db)
    self.db.profile = db.profile
end

function RubimRH:OnProfileReset(event, db)
    for k, v in pairs(defaults) do
        db.profile[k] = v
    end
    self.db.profile = db.profile
end

function RubimRH:OnNewProfile(event, db)
    for k, v in pairs(defaults) do
        db.profile[k] = v
    end
end

--IconRotation.texture:SetTexture(GetSpellTexture(BloodRotation()))

-- Last Update: 05/04/18 02:42
-- Author: Rubim
--if isEqual(thisobj:GetRealSettings().Name) == true then
--return true
--end

--- ============================   MAIN_ROT   ============================
function RubimRH.shouldStop()
    if foundError == 1 then
        return "ERROR"
    end

    if EnabledRotation[playerSpec] == false then
        return "ERROR"
    end

    if Player:IsMounted() or (select(3, UnitClass("player")) == 11 and (GetShapeshiftForm() == 3 or GetShapeshiftForm() == 5)) then
        return 0, 975744
    end

    if ACTIVE_CHAT_EDIT_BOX ~= nil then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\chatting.tga"
    end

    if _G.LootFrame:IsShown() then
        return 0, 975746
    end

    if RubimPVP ~= nil and RubimRH.breakableCC(Target) == true then
        return 0, 135860
    end

    if Cache.EnemiesCount[30] == 0 then
        return 0, 975743
    end
end