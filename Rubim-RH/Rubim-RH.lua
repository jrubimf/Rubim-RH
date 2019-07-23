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

RubimRH.CurrentAction = nil
RubimRH.Cache = {}
RubimRH.Cache.Persistent = {}
RubimRH.Cache.Temp = {}
RubimRH.GlobalTickCount = 0
RubimRH.IgnoreGeneralPvP = {}
--RubimRH.disabledSpellsCD = { RubimRH.Spell[1].Empty }
RubimRH.CustomTrinket = {}
RubimRH.List = {}
RubimRH.List.Cleave = {}
RubimRH.List.Stuns = {}
RubimRH.List.InterruptsCC = {}
RubimRH.List.Interrupts = {}
RubimRH.List.Snare = {}

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
Marksmanship = 254
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
RubimRH.CreateConfig = {}


function RubimRH.SetConfig (Spec, APL)
    RubimRH.CreateConfig[Spec] = APL;
end

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
    [105] = true, -- Restoration
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
    [256] = true, -- Discipline
    [257] = true, -- Holy
    [258] = true, -- Shadow
    -- Rogue
    [259] = true, -- Assassination
    [260] = true, -- Outlaw
    [261] = true, -- Subtlety
    -- Shaman
    [262] = true, -- Elemental
    [263] = true, -- Enhancement
    [264] = true, -- Restoration
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
local SigilofSilence = 202137
local SigilofMisery = 207684
local SigilofChains = 202138
	
--Warrior
local Warbreaker = 209577
local Ravager = 152277
local OdynsFury = 205545
local Charge = 100
local Stormbolt = 107570
local Shockwave = 46968
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
    global = {
        version = 1,
        blockedUnits = {},
        debuffStacks = {},
        dispelCount = {},
        interruptsConfig = {}
    },
	profile = {
        mainOption = {
            version = 27062019,
            cooldownbind = nil,
            interruptsbind = nil,
            aoebind = nil,
            ccbreak = true,
            smartCleave = false,
            PerfectPull = false,
            Precombat = true,
			InstantInterrupt = false,
			InterruptEverything = false,
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
			whiteList = true,		
	        selectedProfile = "Default",			
			classprofiles = {			    
				-- Restoration Druid settings
			    [105] = {	
						["Default"] = {
						
						              ["raid_rejuv"] = {value = 97},
						              ["raid_germi"] = {value = 95},
						              ["raid_wildg"] = {value = 96},
						              ["raid_cenar"] = {value = 40},
						              ["raid_efflo"] = {value = 80},
						              ["raid_regro"] = {value = 40},
						              ["raid_swift"] = {value = 50},
 						              
									  ["tank_rejuv"] = {value = 97},
						              ["tank_germi"] = {value = 95},
						              ["tank_cenar"] = {value = 40},
						              ["tank_regro"] = {value = 40},
						              ["tank_swift"] = {value = 50},
 						              ["tank_bark"] = {value = 30},
   						              ["tank_lifebloom"] = {value = 95},									  
									  ["nb_flourish"] = {value = 5},
									  ["health_flourish"] = {value = 40},
									  ["nb_tranqui"] = {value = 8},
									  ["health_tranqui"] = {value = 35},
									  ["lifebloom"] = {value = "TANK"},	
						              --["cd_flourish"] = {value = 5},									  
									  
						              },							
						
						},							
				-- Holy Paladin settings
			    [65] = {	
						["Default"] = {
						
						              ["raid_flashlight"] = {value = 75},
						              ["raid_holylight"] = {value = 90},
						              ["raid_holyshock"] = {value = 90},
						              ["raid_martyr"] = {value = 75},
 						              ["raid_lightofdawn"] = {value = 85},
									  
									  ["tank_flashlight"] = {value = 97},
						              ["tank_holylight"] = {value = 95},
						              ["tank_holyshock"] = {value = 40},
						              ["tank_martyr"] = {value = 40},									  
						              ["tank_layonhands"] = {value = 25},	
									  ["divine_shield"] = {value = 25},	
									  ["beacon_option"] = {value = "TANK"},	
									  ["nb_auramastery"] = {value = 5},	
									  ["health_auramastery"] = {value = 50},
									  ["divine_protection"] = {value = 50},
									  ["lay_on_hands"] = {value = 15},
									  
						              },							
						
						},
			},

			
			
			-- Interrupt UI values
			minInterruptValue = 7,
			maxInterruptValue = 17,
			
			-- System options
			dbm = true,			
			los = true,			
			fps = true,
			
			-- UI color
			-- Main frame
			mainframeColor_r = 0.06,
			mainframeColor_g = 0.05,
			mainframeColor_b = 0.03,
			mainframeColor_a = 0.75,
			-- Text Color
			--textColor_r = {0.95},
			--textColor_g = {0.95},
			--textColor_b = {0.96},
			--textColor_a = {0.85},		
			
			-- Languages
			activeLanguage = "English",
			
			-- Profils list
			activeList = "Mythic+",

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
				{ spellID = SigilofChains, isActive = true },
				{ spellID = SigilofMisery, isActive = true },
				{ spellID = SigilofSilence, isActive = true },
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
			
            sk5 = 50,
            sk5id = 48707,
            sk5tooltip = "Percent HP to use AntiMagic Shell",

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

            sk5 = 50,
            sk5id = 48707,
            sk5tooltip = "Percent HP to use AntiMagic Shell",
			
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
		-- Protection Paladin
        [66] = {
            cooldown = true,
			-- Avenger Shield defaut value
			ASInterrupt = true,

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
			UseShieldBlockDefensively = true,
			UseRageDefensively = true,
            victoryrush = 80,
			
            sk1 = 30, -- ShieldWall
            sk1id = 871,
            sk1tooltip =  "Percent HP to use Shield Wall",
			
            sk2 = 20, -- Last Stand
            sk2id = 12975,
            sk2tooltip =  "Percent HP to use Last Stand",
            
			Spells = {
                { spellID = Charge, isActive = true },
				{ spellID = Stormbolt, isActive = true },
				{ spellID = Shockwave, isActive = true }
            }
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
			AutoAoE = true,
			
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
        [Marksmanship] = {
            cooldown = true,
            exhilaration = 65,
            aspectoftheturtle = 30,
			useSplashData = "Disabled",
			-- Hunter pet list
			activepet = "",
			
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
			useSplashData = "Disabled",
			activepet = "",
			
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
			activepet = "",
			
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
		--Enh
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
		--Elem
        [262] = {
            sk1 = 80,
			sk1id = HealingSurge,
            sk1tooltip = "Percent HP to use Healing Surge",
            sk2 = 40,
			sk2id = 108271,
            sk2tooltip = "Percent HP to use Astral Shift",
            cooldown = true,
			useSplashData = "Disabled",
			
        },
		--Restoration
		[264] = {
            cooldowns = true,
			
        },
        --DRUID
        [102] = {
            cooldowns = true,
			AutoMorph = true,
			useSplashData = "Disabled",
			sk1 = 50, -- Regrowth
            sk1id = 8936, -- Regrowth
            sk1tooltip = "Percent HP to self heal with Regrowth",
			
			sk2 = 30, -- Barkskin
            sk2id = 22812, -- Barkskin
            sk2tooltip = "Percent HP to use Barkskin",
			
			sk3 = 30, -- Renewal
            sk3id = 108238, -- Renewal
            sk3tooltip = "Percent HP to use Renewal",
			
			sk4 = 50, -- Innervate
            sk4id = 29166, -- Innervate
            sk4tooltip = "Percent Mana on MouseOver to use Innervate",
			
        },
        [Feral] = {
            cooldowns = true,
			
            sk1 = 50, -- Renewal
            sk1id = Renewal, -- Renewall
            sk1tooltip = "Percent HP to use Renewal",

            sk2 = 85, -- Regrowth
            sk2id = Regrowth, -- Regrowth
            sk2tooltip = "Percent HP to use Regrowth",

            sk3 = 20, -- Survival Instincts
            sk3id = 61336, -- Survival Instincts
            sk3tooltip = "Percent HP to use Survival Instincts",
			
            Spells = {
                { spellID = Renewal, isActive = true },
                { spellID = Regrowth, isActive = true },
            }
        },
        [Guardian] = {
            cooldowns = true,
			
            sk1 = 50, -- Barkskin
            sk1id = 22812, -- Barkskin
            sk1tooltip = "Percent HP to use Barkskin",
			
            sk2 = 30, -- SurvivalInstincts
            sk2id = 61336, -- SurvivalInstincts
            sk2tooltip = "Percent HP to use Survival Instincts",
			
            sk3= 30, -- FrenziedRegeneration
            sk3id = 22842, -- FrenziedRegeneration
            sk3tooltip = "Percent HP to use Frenzied Regeneration",
			
            sk4 = 30, -- LunarBeam
            sk4id = 204066, -- LunarBeam
            sk4tooltip = "Percent HP to use Lunar Beam",
			
            sk5 = 30, -- BristlingFur
            sk5id = 155835, -- BristlingFur
            sk5tooltip = "Percent HP to use Bristling Fur",			

        },
		[105] = {
            cooldowns = true,
			force_rejuv = false,
			dbm_sync = false,
			
        },
        -- WARLOCK
		-- Affliction
        [265] = {
		    useSplashData = "Disabled",
            cooldowns = true,
			AutoAoE = true,			
			sk1 = 40,
            sk1id = 104773,
            sk1tooltip = "Percent HP to use Unending Resolve",
        },
		--Demonology
        [266] = {
            cooldowns = true,
			useSplashData = "Disabled",			
			sk1 = 40,
            sk1id = 104773,
            sk1tooltip = "Percent HP to use Unending Resolve",
			sk2 = 5, -- Implosion
            sk2id = 196277, -- Implosion
            sk2tooltip = "Imps to use Implosion (Aoe Mode)",

        },
		--Destruction
        [267] = {
            cooldowns = true,
			flamecolor = "Auto",
			useSplashData = "Disabled",			
			sk1 = 40,
            sk1id = 104773,
            sk1tooltip = "Percent HP to use Unending Resolve",
			sk2 = 7,
            sk2id = 5740,
            sk2tooltip = "Number of units to use Rain of Fire",
			
        },
        --Mage
		--Arcane
        [62] = {
            cooldowns = true,
			useSplashData = "Disabled",
            sk1 = 10, -- IceBlock
            sk1id = 45438, -- Iceblock
            sk1tooltip = "Percent HP to use Ice Block",
            sk2 = 95, -- Prismaticbarrier
            sk2id = 235450, -- Prismaticbarrier
            sk2tooltip = "Percent HP to use Prismatic barrier",
			useSplashData = "Disabled",
        },
		-- Fire
        [63] = {
		    useSplashData = "Disabled",
            cooldowns = true,
            sk1 = 10, -- IceBlock
            sk1id = 45438, -- Iceblock
            sk1tooltip = "Percent HP to use Ice Block",
            sk2 = 95, -- Blazing Barrier
            sk2id = 235313, -- Blazing Barrier
            sk2tooltip = "Percent HP to use Blazing Barrier",
        },
        -- Frost
        [64] = {
            cooldowns = true,
			useSplashData = "Disabled",
            sk1 = 10, -- IceBlock
            sk1id = 45438, -- Iceblock
            sk1tooltip = "Percent HP to use Ice Block",
            sk2 = 95, -- IceBarrier
            sk2id = 11426, -- IceBarrier
            sk2tooltip = "Percent HP to use Ice Barrier",
        },
		
		--Priest
		-- Holy
        [256] = {
            cooldowns = true,			
            sk1 = 10, -- IceBlock
            sk1id = 45438, -- Iceblock
            sk1tooltip = "Percent HP to use Ice Block",
        },
		-- Discipline
        [257] = {
            cooldowns = true,
            sk1 = 10, -- IceBlock
            sk1id = 45438, -- Iceblock
            sk1tooltip = "Percent HP to use Ice Block",
			
        },
		-- Shadow
        [258] = {
            cooldowns = true,
			AutoAoE = true,	
            sk1 = 20, -- Dispersion
            sk1id = 47585, -- Dispersion
            sk1tooltip = "Percent HP to use Dispersion",
            sk2 = 25, -- ShadowMend
            sk2id = 186263, -- ShadowMend
            sk2tooltip = "Percent HP to use ShadowMend",
			sk3 = 30, -- Vampiric Embrace
            sk3id = 15286, -- Vampiric Embrace
            sk3tooltip = "Lowest party member HP to use Vampiric Embrace",
			sk4 = 65, -- Power Word: Shield
            sk4id = 17, -- Power Word: Shield
            sk4tooltip = "Percent HP to use Power Word: Shield",
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

    if RubimRH.db.profile.mainOption.version ~= (27062019) then
        self.db:ResetDB(defaultProfile)
        message("New version:\nResetting Profile")
        print("Reseting profile to avoid bugs")
        print("If you still have issues, delete your Rubim.lua in WTF folder")
        RubimRH.db.profile.mainOption.version = 27062019
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
	
    --RubimRH.CreateConfig[RubimRH.playerSpec]()
-- check only for healing specs
if RubimRH.playerSpec == 105 or RubimRH.playerSpec == 65 or RubimRH.playerSpec == Holy then
    if RubimRH.db.profile[RubimRH.playerSpec] and not RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec] then
		RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec] = {}
		RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec]["Default"] = RubimRH.db.profile[RubimRH.playerSpec]
		RubimRH.db.profile.mainOption.selectedProfile = 'Default'
	end	

	if RubimRH.db.profile[RubimRH.playerSpec] and RubimRH.db.profile.mainOption.selectedProfile then
        RubimRH.db.profile[RubimRH.playerSpec] = RubimRH.db.profile.mainOption.classprofiles[RubimRH.playerSpec][RubimRH.db.profile.mainOption.selectedProfile]
	end
end
    --endd
    if UnitInVehicle("Player") then
        return 0, 236254
    end

    if Player:IsDeadOrGhost() then
        return 0, 236399
    end

    if Player:IsMounted() then
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

----------------------------
------- Cache Wrapper ------
----------------------------

local Cache = { 
	bufer = {},
	newVal = function(self, interval, keyArg, func, ...)
		local obj = {
		  t = HL.GetTime() + (interval or 0.01) + 0.001,  -- Add small delay to make sure what it's not previous corroute                
		  v = { func(...) },     
		}      
		if keyArg then 
			self.bufer[func][keyArg] = obj
		else 
			self.bufer[func] = obj
		end 
		return unpack(obj.v)
	end,	
	-- Static without arguments or with cycling arguments in func
	WrapStatic = function(t, func, interval)
		if not t.bufer[func] then 
			t.bufer[func] = setmetatable({}, { __mode == "kv" })
		end 	
		return function(...)  
			if HL.GetTime() > (t.bufer[func].t or 0) then			
				return t:newVal(interval, nil, func)
			else
				return unpack(t.bufer[func].v)
			end      
		end
	end,	
	-- Dynamic with unlimited arguments in func 
	WrapDynamic = function(t, func, interval)
		if not t.bufer[func] then 
			t.bufer[func] = setmetatable({}, { __mode == "kv" })
		end 	
		return function(...) 
			local arg = {...} 
            local keyArg = ""
            for i = 1, #arg do
                keyArg = keyArg .. tostring(arg[i])            
            end 			
			if HL.GetTime() > (t.bufer[func][keyArg] and t.bufer[func][keyArg].t or 0) then			
				return t:newVal(interval, keyArg, func, ...)
			else
				return unpack(t.bufer[func][keyArg].v)
			end      
		end
	end,		
}

function RubimRH.MakeFunctionCachedStatic(func, interval)
	return Cache:WrapStatic(func, interval)
end 

function RubimRH.MakeFunctionCachedDynamic(func, interval)
	return Cache:WrapDynamic(func, interval)
end 