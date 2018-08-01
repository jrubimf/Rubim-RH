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

	if RubimExtra == true and RubimExtraVer ~= "25072018" then
		message("Update the RubimRH Extra")
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
	[102] = false, -- Balance
	[103] = true, -- Feral
	[104] = true, -- Guardian
	[105] = false, -- Restoration
	-- Hunter
	[253] = true, -- Beast Mastery
	[254] = true, -- Marksmanship
	[255] = false, -- Survival
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
local FelBarrage = 211053
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
			startattack = false,
			healthstoneper = 20,
			align = "CENTER",
			xCord = 0,
			yCord = -200,
			disabledSpells = {}
		},
		--DEMONHUTER
		[577] = {
			cooldown = true,
			Spells = {
				{ spellID = FelRush, isActive = true },
				{ spellID = EyeBeam, isActive = true },
				{ spellID = FelBarrage, isActive = true }
			}
		},
		[581] = {
			cooldown = true,
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
			deficitds = 10,
			drw = 75,
			Spells = {
				{ spellID = DeathStrike, isActive = false, description = "Enable Smart USE of Death Strike.\nBanking DS and only use on extreme scenarios." },
				{ spellID = RuneTap, isActive = false, description = "Always bank runes so we can use Rune Tap." },
				{ spellID = DeathandDecay, isActive = true, description = "Disable Death and Decay." }
			}
		},
		[251] = {
			cooldown = true,
			deathstrike = 85,
			icebound = 60,
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
			icebound = 60,
			Spells = {
				{ spellID = DeathStrike, isActive = true },
				{ spellID = RuneTap, isActive = true }
			}
		},
		--PALADIN
		[70] = {
			cooldown = true,
			justicarglory = 50,
			flashoflight = 70,
			Spells = {
				{ spellID = JusticarVengeance, isActive = true },
				{ spellID = FlashofLight, isActive = true },
			}
		},
		[65] = {
			cooldown = true,
		},
		[66] = {
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
		--WARRIOR
		[71] = {
			cooldown = true,
			victoryrush = 80,
			Spells = {
				{ spellID = Warbreaker, isActive = true },
				{ spellID = Ravager, isActive = true },
				{ spellID = Charge, isActive = true }
			}
		},
		[72] = {
			cooldown = true,
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
		},
		[261] = {
			cooldown = true,
			stealthOOC = true,
			dice = "Simcraft"
		},
		[259] = {
			cooldown = true,
			stealthOOC = true,
		},
		--HUNTER
		[254] = {
			cooldown = true,
		},
		[253] = {
			cooldown = true,
		},

		[255] = {
			cooldown = true,
		},
		--MONK
		[268] = {
			cooldown = true,
		},
		[269] = {
			cooldown = true,
		},
		--SHAMAN
		[263] = {
			healingsurge = 80,
			cooldown = true,
			Spells = {
				{ spellID = HealingSurge, isActive = true }
			}
		},
		[262] = {
			healingsurge = 80,
		},
		--DRUID
		[103] = {
			cooldowns = false,
			renewal = 50,
			regrowth = 85,
			Spells = {
				{ spellID = Renewal, isActive = true },
				{ spellID = Regrowth, isActive = true },
			}
		},
		[104] = {
			cooldowns = false,
		},
		--Warlock
		[265] = {
			cooldowns = false,
				
		},
		[266] = {
			cooldowns = false,
		},
		[267] = {
			cooldowns = false,
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

	if _G.LootFrame:IsShown() then
		return 0, 975746
	end

	if Cache.EnemiesCount[30] == 0 then
		return 0, 135328
	end

	if Rotation == "Passive" then
		return RubimRH.Rotation.PASSIVEs[RubimRH.playerSpec]()
	end

	if Rotation == "SingleTarget" then
		if RubimPVP and RubimRH.PvP() ~= nil then
			return RubimRH.PvP()
		else
			return RubimRH.Rotation.APLs[RubimRH.playerSpec]()
		end	
	end
end