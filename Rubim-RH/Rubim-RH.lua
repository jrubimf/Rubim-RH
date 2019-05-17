local RubimRH = LibStub("AceAddon-3.0"):NewAddon("RubimRH", "AceEvent-3.0", "AceConsole-3.0")
_G["RubimRH"] = RubimRH

local foundError = false


local errorEvent = CreateFrame("Frame")
errorEvent:RegisterEvent("PLAYER_LOGIN")
errorEvent:SetScript("OnEvent", function(self, event)
    if HeroLib == nil then
        message("Missing dependency: HeroLib")
        foundError = true
    end
    if HeroCache == nil then
        message("Missing dependency: HeroCache")
        foundError = true
    end

    if RubimExtra == false then
        message("Missing dependency: RubimExtra")
    end

    if RubimExtraVer ~= 01102018 then
        message("Update Extra :)")
    end

    if GetCVar("nameplateShowEnemies") ~= "1" then
        message("Nameplates enabled to maximum AoE detection.");
        SetCVar("nameplateShowEnemies", 1)
    end
end)


RubimRH.burstCDtimer = GetTime()
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
RubimRH.Rotation.PvP = {}

function RubimRH.Rotation.SetAPL (Spec, APL)
    RubimRH.Rotation.APLs[Spec] = APL;
end

function RubimRH.Rotation.SetPASSIVE (Spec, APL)
    RubimRH.Rotation.PASSIVEs[Spec] = APL;
end

function RubimRH.Rotation.SetPvP (Spec, APL)
    RubimRH.Rotation.PvP[Spec] = APL;
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
    [62] = true, -- Arcane
    [63] = true, -- Fire
    [64] = true, -- Frost
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
    [258] = true, -- Shadow
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
    [266] = true, -- Demonology
    [267] = true, -- Destruction
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
local RallyingCry = 97462
local DefensiveStance = 197690
local DiebytheSword = 118038
local VictoryRush = 34428
local ImpendingVictory = 202168

--Survival
local MendPet = 136
local AspectoftheTurtle = 186265
local Exhilaration = 109304

--Paladin
local DivineShield = 642
local JusticarVengeance = 215661
local WordofGlory = 210191
local LayonHands = 633
local ShieldofVengeance = 184662
local GuardianofAncientKings = 86659
local ArdentDefender = 31850
local FlashofLight = 19750
--Shaman
local HealingSurge = 188070
local FeralSpirit = 51533
local EarthElemental = 198103
--Druid
local Regrowth = 8936
local Renewal = 108238

local defaults = {
    profile = {
        mainOption = {
            version = 26042019,
            cooldownbind = nil,
            interruptsbind = nil,
            aoebind = nil,
            ccbreak = true,
            smartCleave = false,
            usePotion = true,
            Precombat = true,
            useInterrupts = true,
            useRacial = true,
            startattack = false,
            healthstoneper = 20,
            healthstoneEnabled = true,
            mainIcon = true,
            mainIconOpacity = 100,
            mainIconScale = 150,
            mainIconLock = false,
            mute = false,
            align = "CENTER",
            xCord = 0,
            yCord = 0,
            disabledSpells = {},
            disabledSpellsCD = {},
            disabledSpellsCleave = {},
            interruptList = {

--temple of sethraliss

[265968] = true,
[263318] = true,
[272659] = true,
[261635] = true,
[273995] = true, -- interrupt by CC
[261624] = true,
[267237] = true, -- interrupt by hard CC
[265912] = true,
[268061] = true,
[268008] = true,

--FreeHold

[257397] = true,
[256060] = true,
[258777] = true,
[257732] = true,
[257899] = true, -- some groups leave this uninterrupted so enemies die faster 
[257736] = true,

--Shrine of the storm

[267981] = true,
[267977] = true,
[267969] = true,
[276266] = true, -- if we have a purge 
[268030] = true, -- high prio
[274438] = true,
[268177] = true, -- low prio
[267818] = true,
[268309] = true,
[268322] = true,
[268375] = true,
[276767] = true,
[268347] = true,
[267809] = true,

--Siege of boralus

[256957] = true,
[256897] = true, -- interrupt by CC
[274569] = true, -- high priority
[272571] = true, --medium prio

--Tol Dagor

[258128] = true,
[258153] = true,
[257791] = true,
[260067] = true, -- not sure if kickable
[258313] = true,
[258634] = true,
[258869] = true,
[258935] = true,

--Waycrest manor

[267824] = true, -- maybe 
[265368] = true,
[263891] = true,
[266035] = true,
[266036] = true,
[260805] = true,
[278551] = true,
[278474] = true,
[264520] = true,
[278444] = true,
[265407] = true,
[265876] = true,
[264105] = true,
[264384] = true,
[263959] = true,
[268278] = true,
[266225] = true,
[266181] = true, -- -unsure if interruptable
[268202] = true, -- interrupt by CC

--Atal'Dazar

[255824] = true,
[253517] = true,
[253548] = true,
[253583] = true,
[255041] = true,
[256849] = true,
[252781] = true,
[250368] = true,
[250096] = true,

--Kings Rest

[269972] = true,
[269973] = true,
[270923] = true,
[270901] = true,
[267763] = true,
[270492] = true,
[270493] = true, --- probably shouldnt add
[267273] = true,

--The MOTHERLODE!!

[280604] = true,
[268129] = true,
[267354] = true, -- interrupt by CC
[269302] = true,
[262092] = true,
[268709] = true,
[268702] = true,
[263215] = true,
[263103] = true,
[263066] = true,
[268797] = true,
[269090] = true,
[281621] = true,
[262540] = true,

--Underrot

[265089] = true,
[265091] = true,
[278755] = true,
[260879] = true,
[266106] = true,
[265668] = true, -- Low prio
[278961] = true, -- Highest prio
[272183] = true,
[266209] = true, -- high prio
[272180] = true,
[265433] = true,
[265487] = true,

--Battle for dazaralor

[283628] = true,
[284578] = true,
[282243] = true,
[285572] = true,
[286779] = true,
[287887] = true,
[289861] = true
			
			},
            whiteList = true,
            useTrinkets = {
                [1] = false,
                [2] = false
            },
            cooldownsUsage = "Everything",
            burstCD = false,
            debug = false,
            hidetexture = false,
            glowactionbar = false,
        },
        --DEMONHUTER
        [Havoc] = {
            cooldown = true,

            sk1 = 75,
            sk1id = 198589, --Blur
            sk1tooltip = "Percent HP to use Blur",

            sk2 = 50,
            sk2id = 196718, --Darkness
            sk2tooltip = "Percent HP to use Darkness",
            Spells = {
                { spellID = FelRush, isActive = true },
                { spellID = EyeBeam, isActive = true },
                { spellID = FelBarrage, isActive = true }
            }
        },
        [Vengeance] = {
            cooldown = true,


            sk1 = 50,
            sk1id = 187827, --Metamorphosis
            sk1tooltip = "Percent HP to use Metamorphosis",

            sk2 = 75,
            sk2id = 263648, --Soul Barrier
            sk2tooltip = "Percent HP to use Soul Barrier",

            Spells = {
                { spellID = InfernalStrike, isActive = true },
                { spellID = FieryBrand, isActive = true },
            }
        },
        --DK
        [Blood] = {
            cooldown = true,

            sk1 = 60,
            sk1id = 48792,
            sk1tooltip = "Percent HP to use Icebound",

            sk2 = 35,
            sk2id = 194679,
            sk2tooltip = "Percent HP to use Runetap",

            sk3 = 50,
            sk3id = 55233,
            sk3tooltip = "Percent HP to use Vampiric Blood",

            sk4 = 75,
            sk4id = 49028,
            sk4tooltip = "Percent HP to use Dancing Rune Weapon",

            sk5 = 15,
            sk5id = "Smart DS",
            sk5tooltip = "Percent DMG Take to use DS",

            sk6 = 30,
            sk6id = "Defict DS",
            sk6tooltip = "How much RP should we pool. MaximumRP - ThisAmount",

            sk7 = 50,
            sk7id = 49998,
            sk7tooltip = "How much HP is low enough so we can start the panic Death Strike.",

            Spells = {
                { spellID = DeathStrike, isActive = true, description = "Enable Smart USE of Death Strike.\nBanking DS and only use on extreme scenarios." },
                { spellID = RuneTap, isActive = false, description = "Always bank runes so we can use Rune Tap." },
                { spellID = DeathandDecay, isActive = true, description = "Disable Death and Decay." }
            }
        },
        [Frost] = {
            cooldown = true,

            sk1 = 85,
            sk1id = 101568,
            sk1tooltip = "Percent HP to use Death Strike (Dark Succur Proc)",

            sk2 = 60,
            sk2id = 48792,
            sk2tooltip = "Percent HP to use Ice Bound",

            sk3 = 25,
            sk3id = 49998,
            sk3tooltip = "Percent HP to use Death Strike",

            sk4 = 75,
            sk4id = 48743,
            sk4tooltip = "Percent HP to use Death Pact",

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
        [Unholy] = {
            cooldown = true,
            sk1 = 85,
            sk1id = 101568,
            sk1tooltip = "Percent HP to use Death Strike (Dark Succur Proc)",

            sk2 = 60,
            sk2id = 48792,
            sk2tooltip = "Percent HP to use Ice Bound",

            sk3 = 25,
            sk3id = 49998,
            sk3tooltip = "Percent HP to use Death Strike",

            sk4 = 75,
            sk4id = 48743,
            sk4tooltip = "Percent HP to use Death Pact",

            Spells = {
                { spellID = DeathStrike, isActive = true },
                { spellID = RuneTap, isActive = true }
            }
        },
        --PALADIN
        [Retribution] = {
            cooldown = true,

            sk1 = 85,
            sk1id = ShieldofVengeance,
            sk1tooltip = "Percent HP to use Shield of Vengeance",

            sk2 = 45,
            sk2id = FlashofLight,
            sk2tooltip = "Percent HP to use Flash of the Light",

            sk3 = 75, -- Die by the Sword
            sk3id = JusticarVengeance,
            sk3tooltip = "Percent HP to use Justicar's Vengeance",

            sk4 = 45,
            sk4id = DivineShield,
            sk4tooltip = "Percent HP to use Divine Shield",

            sk5 = 10,
            sk5id = LayonHands,
            sk5tooltip = "Percent HP to use Lay on Hands",

            sk6 = 75,
            sk6id = WordofGlory,
            sk6tooltip = "Percent HP to use Word of Glory",

            SoVOpener = false,
        },
        [Holy] = {
            dps = false,
            cooldown = true,
            sk1 = 50,
            sk1id = 498,
            sk1tooltip = "Percent HP to use Divine Protection",

            sk2 = 30,
            sk2id = 642,
            sk2tooltip = "Percent HP to use Divine Shield",

            sk3 = 15, --
            sk3id = 633, --Lay on HAnds
            sk3tooltip = "Percent HP to use Lay on Hands",


        },
        [66] = {
            cooldown = true,

            sk1 = 85,
            sk1id = 184092,
            sk1tooltip = "Percent HP to use Light of the Protector",

            sk2 = 15,
            sk2id = 31850,
            sk2tooltip = "Percent HP to use Ardent Defender",

            sk3 = 75, -- Die by the Sword
            sk3id = 86659,
            sk3tooltip = "Percent HP to use Guardian of the Ancient Kings",

            sk4 = 30,
            sk4id = 633,
            sk4id = "Percent HP to use Lay on Hands",

            Spells = {
                { spellID = FlashofLight, isActive = true }
            },
        },
        --WARRIOR
        --ARMS
        [Arms] = {
            cooldown = true,

            sk1 = 80, -- VictoryRush
            sk1id = VictoryRush,
            sk1tooltip = "Percent HP to use Victory Rush",

            sk2 = 70, -- ImpendingVictory
            sk2id = ImpendingVictory,
            sk2tooltip = "Percent HP to use Impending Victory",

            sk3 = 50, -- Die by the Sword
            sk3id = DiebytheSword,
            sk3tooltip = "Percent HP to use Die by the Sword",

            sk4 = 30, -- RallyingCry
            sk4id = RallyingCry,
            sk4tooltip = "Percent HP to use RallyingCry",
            Spells = {
                { spellID = Warbreaker, isActive = true },
                { spellID = Ravager, isActive = true },
                { spellID = Charge, isActive = true }
            }
        },
        [Fury] = {
            cooldown = true,

            sk1 = 80, -- VictoryRush
            sk1id = VictoryRush,
            sk1tooltip = "Percent HP to use Victory Rush",

            sk2 = 70, -- ImpendingVictory
            sk2id = ImpendingVictory,
            sk2tooltip = "Percent HP to use Impending Victory",

            sk3 = 30, -- RallyingCry
            sk3id = 97462,
            sk3tooltip = "Percent HP to use RallyingCry",

            Spells = {
                { spellID = Charge, isActive = true }
            }
        },
        [Protection] = {
            cooldown = true,
            victoryrush = 80,
            sk1 = 2.5,
            sk1id = "Light Damage",
            sk1tooltip = "How much DMG Taken is considered a Light Damage intake.",

            sk2 = 5, -- ImpendingVictory
            sk2id = "Moderate Damage",
            sk2tooltip =  "How much DMG Taken is considered a Moderate Damage intake.",

            sk3 = 10, -- RallyingCry
            sk3id = "High Damage",
            sk3tooltip =  "How much DMG Taken is considered a High Damage intake.",
			
            sk4 = 30, -- ShieldWall
            sk4id = 871,
            sk4tooltip =  "Percent HP to use Shield Wall",
			
            sk5 = 20, -- Last Stand
            sk5id = 12975,
            sk5tooltip =  "Percent HP to use Last Stand",

        },
        --ROGUE
        [260] = { --Outlaw
            cooldown = true,
            stealthOOC = true,
            vanishattack = true,
            sk1 = 65,
            sk1id = 185311,
            sk1tooltip = "Percent HP to use Crimson Vial",

            sk2 = 15,
            sk2id = 31224,
            sk2tooltip = "Percent HP to use Cloak of Shadows",

            sk3 = 50,
            sk3id = 199754,
            sk3tooltip = "Percent HP to use Riposte",
            dice = "Simcraft",
        },
        [261] = {
            cooldown = true,
            stealthOOC = true,
            vanishattack = true,

            sk1 = 65,
            sk1id = 185311,
            sk1tooltip = "Percent HP to use Crimson Vial",

            sk2 = 15,
            sk2id = 31224,
            sk2tooltip = "Percent HP to use Cloak of Shadows",

            sk3 = 50,
            sk3id = 31224,
            sk3tooltip = "Percent HP to use Evasion",
        },
        [259] = {
            cooldown = true,
            stealthOOC = true,
            vanishattack = true,

            sk1 = 65,
            sk1id = 185311,
            sk1tooltip = "Percent HP to use Crimson Vial",

            sk2 = 15,
            sk2id = 31224,
            sk2tooltip = "Percent HP to use Cloak of Shadows",

            sk3 = 50,
            sk3id = 5277,
            sk3tooltip = "Percent HP to use Evasion",
        },
        --HUNTER
        [Marmanship] = {
            cooldown = true,
            exhilaration = 65,
            aspectoftheturtle = 30,

            sk1 = 65,
            sk1id = 109304,
            sk1tooltip = "Percent HP to use Exhilaration",

            sk2 = 30,
            sk2id = 186265,
            sk2tooltip = "Percent HP to use Aspect of the Turtle",
			
            sk3 = 20,
            sk3id = 264735,
            sk3tooltip = "Percent HP to use Survival of the Fittest",

        },
        [BeastMastery] = {
            cooldown = true,

            sk1 = 70,
            sk1id = 136,
            sk1tooltip = "Percent HP to use Mend Pet",

            sk2 = 65,
            sk2id = 186265,
            sk2tooltip = "Percent HP to use Aspect of the Turtle",

            sk3 = 30,
            sk3id = 109304,
            sk3tooltip = "Percent HP to use Exhilaration",
        },

        [Survival] = {
            cooldown = true,
            sk1 = 70,
            sk1id = 136,
            sk1tooltip = "Percent HP to use Victory Rush",

            sk2 = 30,
            sk2id = 186265,
            sk2tooltip = "Percent HP to use Aspect of the Turtle",

            sk3 = 65,
            sk3id = 109304,
            sk3tooltip = "Percent HP to use Exhilaration",
        },
        --MONK
        [Brewmaster] = {
            cooldown = true,

            sk1 = 50,
            sk1id = 115072, -- ExpelHarm
            sk1tooltip = "Percent HP to use Expel Harm",
			sk2 = 20,
            sk2id = 115203, -- Fortifying brew
            sk2tooltip = "Percent HP to use Fortifying Brew",
        },
        [Windwalker] = {
            cooldown = true,

            sk1 = 50,
            sk1id = 122470, -- TouchofKarma
            sk1tooltip = "Percent HP to use Touch of Karma",

            sk2 = 35,
            sk2id = 122278, -- DampemHarm
            sk2tooltip = "Percent HP to use Dampem Harm",
        },
        --SHAMAN
        [263] = {
            sk1 = 70,
            sk1id = HealingSurge,
            sk1tooltip = "Percent HP to use Healing Surge",
            cooldown = true,

            Spells = {
                { spellID = FeralSpirit, isActive = true },
                { spellID = EarthElemental, isActive = true }
            }
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

            Spells = {
                { spellID = Renewal, isActive = true },
                { spellID = Regrowth, isActive = true },
            }
        },
        [Guardian] = {
            cooldowns = true,
        },
        -- WARLOCK
        [265] = {
            cooldowns = true,
			
			sk1 = 40,
            sk1id = 104773,
            sk1tooltip = "Percent HP to use Unending Resolve",
        },
        [266] = {
            cooldowns = true,
			
			sk1 = 40,
            sk1id = 104773,
            sk1tooltip = "Percent HP to use Unending Resolve",
			sk2 = 5, -- Implosion
            sk2id = 196277, -- Implosion
            sk2tooltip = "Imps to use Implosion (Aoe Mode)",

        },
        [267] = {
            cooldowns = true,
			flamecolor = "Auto",
			
			sk1 = 40,
            sk1id = 104773,
            sk1tooltip = "Percent HP to use Unending Resolve",
			sk2 = 7,
            sk2id = 5740,
            sk2tooltip = "Number of units to use Rain of Fire",
			
        },
        --Mage
        [62] = {
            cooldowns = true,
            sk1 = 10, -- IceBlock
            sk1id = 45438, -- Iceblock
            sk1tooltip = "Percent HP to use Ice Block",
        },
        [63] = {
            cooldowns = true
        },
        [64] = {
            cooldowns = true,
            sk1 = 10, -- IceBlock
            sk1id = 45438, -- Iceblock
            sk1tooltip = "Percent HP to use Ice Block",
            sk2 = 90, -- IceBarrier
            sk2id = 11426, -- IceBarrier
            sk2tooltip = "Percent HP to use Ice Barrier",
        },
		
		--Priest
        [256] = {
            cooldowns = true,
            sk1 = 10, -- IceBlock
            sk1id = 45438, -- Iceblock
            sk1tooltip = "Percent HP to use Ice Block",
        },
        [257] = {
            cooldowns = true
        },
        [258] = {
            cooldowns = true,
            sk1 = 20, -- Dispersion
            sk1id = 47585, -- Dispersion
            sk1tooltip = "Percent HP to use Dispersion",
            sk2 = 25, -- ShadowMend
            sk2id = 186263, -- ShadowMend
            sk2tooltip = "Percent HP to use ShadowMend",
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

    if RubimRH.db.profile.mainOption.version ~= (26042019) then
        self.db:ResetDB(defaultProfile)
        message("New version:\nResetting Profile")
        print("Reseting profile")
        RubimRH.db.profile.mainOption.version = 26042019
    end


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
    if foundError == true then
        return "ERROR"
    end

    if EnabledRotation[RubimRH.playerSpec] ~= true then
        return "ERROR"
    end

    --endd
    if UnitInVehicle("Player") then
        return 0, 236254
    end

    if Player:IsDeadOrGhost() then
        return 0, 236399
    end

    if Player:IsMounted() or (select(3, UnitClass("player")) == 11 and (GetShapeshiftForm() == 3 or GetShapeshiftForm() == 5)) then
        return 0, 975744
    end

    if Player:IsChanneling(Spell(267402)) then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end

    if ACTIVE_CHAT_EDIT_BOX ~= nil then
        return 0, 236254
    end

    if SpellIsTargeting() then
        return 0, 236353
    end

    if _G.LootFrame:IsShown() then
        return 0, 975746
    end

    --
    --UpdateCleave()
    --UpdateCD()

    if Rotation == "Passive" then
        return RubimRH.Rotation.PASSIVEs[RubimRH.playerSpec]()
    end

    if Rotation == "Defensive" then
        return RubimRH.Rotation.DEFENSIVE[RubimRH.playerSpec]()
    end

    if Rotation == "SingleTarget" then
        if RubimRH.PvP() ~= nil then
            return RubimRH.PvP()
        else
            return RubimRH.Rotation.APLs[RubimRH.playerSpec]()
        end
    end
end