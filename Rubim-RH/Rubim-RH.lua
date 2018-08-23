local foundError = false
local errorEvent = CreateFrame("Frame")
errorEvent:RegisterEvent("PLAYER_LOGIN")
errorEvent:SetScript("OnEvent", function(self, event)
    if HeroLib == nil then
        message("Missing dependency: HeroLib")
        foundError = true
    end
    if HeroCache == nil then
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
RubimRH.version = "bfa_1.0_c"
RubimRH.debug = false

local AceGUI = LibStub("AceGUI-3.0")
RubimRH.config = {}
RubimRH.currentSpec = "None"
RubimRH.Spell = {}

local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

--ClassGlobals
Blood = 250
Frost = 251
Unholy = 252

Havoc = 577
Vengeance = 581

Balance = 102
Feral = 103
Guardian = 104
Restoration = 105

BeastMastery = 253
Marmanship = 254
Survival = 255

Arcane = 62
Fire = 63
MFrost = 64

Brewmaster = 268
Mistweaver = 270
Windwalker = 269

Holy = 65
PProtection = 66
Retribution = 70

Discipline = 256
PHoly = 257
Shadow = 258

Assassination = 259
Outlaw = 260
Subtlety = 261

Elemental = 262
Enhancement = 263
Restoration = 264

Affliction = 265
Demonology = 266
Destruction = 267

Arms = 71
Fury = 72
Protection = 73

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

local EnabledRotation = {
    -- Death Knight
    [250] = true, -- Blood
    [251] = true, -- Frost
    [252] = true, -- Unholy
    -- Demon Hunter
    [577] = true, -- Havoc
    [581] = true, -- Vengeance
    -- Druid
    [102] = true, -- Balance
    [103] = true, -- Feral
    [104] = true, -- Guardian
    [105] = false, -- Restoration
    -- Hunter
    [253] = true, -- Beast Mastery
    [254] = true, -- Marksmanship
    [255] = true, -- Survival
    -- Mage
    [62] = false, -- Arcane
    [63] = true, -- Fire
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
    [259] = true, -- Assassination
    [260] = true, -- Outlaw
    [261] = true, -- Subtlety
    -- Shaman
    [262] = true, -- Elemental
    [263] = true, -- Enhancement
    [264] = false, -- Restoration
    -- Warlock
    [265] = true, -- Affliction
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

local FrostwyrmsFury = 279302
local PillarOfFrost = 51271
local DeathandDecay = 43265
--DH
local FelRush = 195072
local EyeBeam = 198013
local FelBarrage = 258925
local FieryBrand = 204021
local InfernalStrike = 189110

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
local FlashofLight = 19750
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
            usePotion = true,
            useInterrupts = true,
            useRacial = true,
            startattack = false,
            healthstoneper = 20,
            healthstoneEnabled = true,
            mainIcon = true,
            mainIconOpacity = 100,
            mainIconScale = 100,
            align = "CENTER",
            xCord = 0,
            yCord = 0,
            disabledSpells = {},
            disabledSpellsCD = {},
            useTrinkets = {},
            cooldownsUsage = "Everything"
        },
        --DEMONHUTER
        [577] = {
            cooldown = true,
            blur = 75,
            darkness = 50,
            Spells = {
                { spellID = FelRush, isActive = true },
                { spellID = EyeBeam, isActive = true },
                { spellID = FelBarrage, isActive = true }
            }
        },
        [581] = {
            cooldown = true,
            metamorphosis = 50,
            soulbarrier = 75,
            Spells = {
                { spellID = InfernalStrike, isActive = true },
                { spellID = FieryBrand, isActive = true },
            }
        },
        --DK
        [250] = {
            cooldown = true,
            icebound = 60,
            runetap = 35,
            vampiricblood = 50,
            smartds = 30,
            deficitds = 30,
            drw = 75,
            Spells = {
                { spellID = DeathStrike, isActive = true, description = "Enable Smart USE of Death Strike.\nBanking DS and only use on extreme scenarios." },
                { spellID = RuneTap, isActive = false, description = "Always bank runes so we can use Rune Tap." },
                { spellID = DeathandDecay, isActive = true, description = "Disable Death and Decay." }
            }
        },
        [251] = {
            cooldown = true,
            deathstrike = 85,
            icebound = 60,
            deathstrikeper = 25,
            deathpact = 40,
            Spells = {
                { spellID = DeathStrike, isActive = true },
                { spellID = BreathOfSindragosa, isActive = true },
                { spellID = FrostwyrmsFury, isActive = true },
                { spellID = PillarOfFrost, isActive = true }
            }
        },
        [252] = {
            cooldown = true,
            deathstrike = 85,
            deathstrikeper = 25,
            icebound = 60,
            deathpact = 40,
            Spells = {
                { spellID = DeathStrike, isActive = true },
                { spellID = RuneTap, isActive = true }
            }
        },
        --PALADIN
        [70] = {
            cooldown = true,
            SoVEnabled = false,
            SoVHP = 70,
            FoL = false,
            flashoflight = 80,
            justicariSEnabled = false,
            JusticarHP = 50,
            divineEnabled = false,
            DivineHP = 20,
            wogenabled = false,
            wogHP = 65,
            SoVOpener = false,
        },
        [65] = {
            cooldown = true,
        },
        [66] = {
            cooldown = true,
            akEnabled = false,
            akHP = 30,
            adEnabled = false,
            adHP = 70,
            lohEnabled = false,
            lohHealth = 30,
            lotpEnabled = true,
            lotpHP = 50,
        },
        --WARRIOR
        --ARMS
        [71] = {
            cooldown = true,
            victoryrush = 80,
            diebythesword = 50,
            rallyingcry = 30,
            Spells = {
                { spellID = Warbreaker, isActive = true },
                { spellID = Ravager, isActive = true },
                { spellID = Charge, isActive = true }
            }
        },
        [72] = {
            cooldown = true,
            rallyingcry = 30,
            victoryrush = 80,
            Spells = {
                { spellID = Charge, isActive = true }
            }
        },
        [73] = {
            cooldown = true,
            victoryrush = 80,
        },
        --ROGUE
        [260] = {
            cooldown = true,
            stealthOOC = true,
            crimsonvial = 65,
            cloakofshadows = 15,
            riposte = 50,
            dice = "Simcraft",
            vanishattack = true
        },
        [261] = {
            cooldown = true,
            stealthOOC = true,
            vanishattack = true,
            crimsonvial = 65,
            cloakofshadows = 15,
            evasion = 50,
        },
        [259] = {
            cooldown = true,
            stealthOOC = true,
            vanishattack = true,
            crimsonvial = 65,
            cloakofshadows = 15,
            evasion = 50,
        },
        --HUNTER
        [254] = {
            cooldown = true,
            exhilaration = 65,
            aspectoftheturtle = 30,
        },
        [253] = {
            cooldown = true,
            mendpet = 70,
            aspectoftheturtle = 30,
        },

        [255] = {
            cooldown = true,
            mendpet = 70,
            aspectoftheturtle = 30,
            exhilaration = 65,
        },
        --MONK
        [268] = {
            cooldown = true,
        },
        [269] = {
            cooldown = true,
            touchofkarma = 50,
            dampemharm = 35,
        },
        --SHAMAN
        [Enhancement] = {
            sk1 = 80, -- Healing Surge
            sk1id = HealingSurge, -- Healing Surge ID
            cooldown = true,
        },
        [262] = {
            healingsurge = 80,
        },
        --DRUID
        [102] = {
            cooldowns = true,
        },
        [Feral] = {
            cooldowns = true,

            sk1 = 50, -- Renewal
            sk1id = Renewal, -- Renewall
            sk1tooltip = "Percent HP to use Renewal",

            sk2 = 85, -- Renewal
            sk2id = Regrowth, -- Renewall
            sk2tooltip = "Percent HP to use Regrowth",

            sk3 = 85, -- Renewal
            sk3id = Regrowth, -- Renewall
            sk3tooltip = "Percent HP to use Regrowth",

            sk4 = 85, -- Renewal
            sk4id = Regrowth, -- Renewall
            sk4tooltip = "Percent HP to use Regrowth",

            sk5 = 85, -- Renewal
            sk5id = Regrowth, -- Renewall
            sk5tooltip = "Percent HP to use Regrowth",

            sk6 = 85, -- Renewal
            sk6id = Regrowth, -- Renewall
            sk6tooltip = "Percent HP to use Regrowth",


            Spells = {
                { spellID = Renewal, isActive = true },
                { spellID = Regrowth, isActive = true },
            }
        },
        [Guardian] = {
            cooldowns = true,
        },
        --Warlock
        [265] = {
            cooldowns = true,
        },
        [266] = {
            cooldowns = true,
        },
        [267] = {
            cooldowns = true,
        },
        --Mage
        [62] = {
            cooldowns = true
        },
        [63] = {
            cooldowns = true
        },
        [64] = {
            cooldowns = true
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
updateClassVariables:RegisterEvent("PLAYER_ENTERING_WORLD")
updateClassVariables:RegisterEvent("PLAYER_PVP_TALENT_UPDATE")
updateClassVariables:RegisterEvent("PLAYER_TALENT_UPDATE")
updateClassVariables:SetScript("OnEvent", function(self, event, ...)
    RubimRH.playerSpec = Cache.Persistent.Player.Spec[1] or 0
    if RubimRH.playerSpec == 0 then
        return
    end

    if RubimRH.db.profile[RubimRH.playerSpec] == nil then
        return
    end

    --if RubimRH.playerSpec ~= 0 then
    --        Player:RegisterListenedSpells(RubimRH.playerSpec)
    --    end
    RubimRH.config = {}
    RubimRH.allSpells = {}
    if RubimRH.playerSpec ~= 0 then
        RubimRH.config = RubimRH.db.profile[RubimRH.playerSpec]
        for pos, spell in pairs(RubimRH.Spell[RubimRH.playerSpec]) do
            if spell:IsAvailable() then
                table.insert(RubimRH.allSpells, spell)
            end
        end
    end
    RubimRH.useCD = false or RubimRH.db.profile[RubimRH.playerSpec].cooldown
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
function RubimRH.mainRotation(option)
    local Rotation = option or "SingleTarget"
    if foundError == 1 then
        return "ERROR"
    end

    if EnabledRotation[RubimRH.playerSpec] == false then
        return "ERROR"
    end

    --    if Player:AffectingCombat() and not Target:Exists() then
    --        if RubimRH.TargetNext("Melee", 1030902) ~= nil then
    --            return 1, RubimRH.TargetNext("Melee", 1030902)
    --end
    --endd

    if Player:IsDeadOrGhost() then
        return 0, 236399
    end

    if Player:IsMounted() or (select(3, UnitClass("player")) == 11 and (GetShapeshiftForm() == 3 or GetShapeshiftForm() == 5)) then
        return 0, 975744
    end

    if ACTIVE_CHAT_EDIT_BOX ~= nil then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\chatting.tga"
    end

    if SpellIsTargeting() then
        return 0, 236353
    end

    if _G.LootFrame:IsShown() then
        return 0, 975746
    end

    if Rotation == "Passive" then
        return RubimRH.Rotation.PASSIVEs[RubimRH.playerSpec]()
    end

    if Rotation == "SingleTarget" then
        if RubimRHPvP ~= nil and RubimRHPvP.active and RubimRH.PvP() ~= nil then
            return RubimRH.PvP()
        else
            return RubimRH.Rotation.APLs[RubimRH.playerSpec]()
        end
    end
end