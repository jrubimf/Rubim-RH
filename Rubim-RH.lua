local RubimRH = LibStub("AceAddon-3.0"):NewAddon("RubimRH", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
--local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
--[[ The defaults a user without a profile will get. ]]--

--DK
local DeathStrike = 49998
local RuneTap = 194679
local BreathOfSindragosa = 152279
local SindragosasFury = 190778
local PillarOfFrost = 51271

--DH
local FelRush = 195072
local EyeBeam = 198013

--Warrior
local Warbreaker = 209577
local Ravager = 152277
local OdynsFury = 205545

--Paladin
local JusticarVengeance = 215661
local WordofGlory = 210191

--Shaman
local HealingSurge = 188070

local defaults = {
    profile = {
        mainOption = {
            cooldownbind = nil,
            interruptsbind = nil,
        },
        dh = {
            havoc = {
                { spellID = FelRush, isActive = true },
                { spellID = EyeBeam, isActive = true }
            },
            cooldown = false
        },
        dk = {
            blood = {
                { spellID = DeathStrike, isActive = true },
                { spellID = RuneTap, isActive = true }
            },
            frost = {
                { spellID = DeathStrike, isActive = true },
                { spellID = BreathOfSindragosa, isActive = true },
                { spellID = SindragosasFury, isActive = true },
                { spellID = PillarOfFrost, isActive = true }
            },
            unholy = {
                { spellID = DeathStrike, isActive = true },
                { spellID = RuneTap, isActive = true }
            },
            cooldown = false,
            deathstrike = 0.85
        },
        pl = {
            ret = {
                { spellID = JusticarVengeance, isActive = true }
            },
            cooldown = false,
            lightoftheprotector = 0.90,
            justicarglory = 0.50,
        },
        wr = {
            arms = {
                { spellID = Warbreaker, isActive = true },
                { spellID = Ravager, isActive = true }
            },
            fury = {
                { spellID = OdynsFury, isActive = true }
            },
            cooldown = false,
            victoryrush = 0.80
        },
        rg = {
            cooldown = false,
        },
        hr = {
            cooldown = false,
        },
        mk = {
            cooldown = false,
        },
        sh = {
            enhc = {
                { spellID = HealingSurge, isActive = true }
            },
            cooldown = false,
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

    --DK
    if select(3, UnitClass("player")) == 6 then
        varClass = RubimRH.db.profile.dk
    end

    --Demon HUNTER
    if select(3, UnitClass("player")) == 12 then
        varClass = RubimRH.db.profile.dh
    end

    --Rogue
    if select(3, UnitClass("player")) == 4 then
        varClass = RubimRH.db.profile.rg
    end

    --Monk
    if select(3, UnitClass("player")) == 10 then
        varClass = RubimRH.db.profile.mk
    end

    --Warrior
    if select(3, UnitClass("player")) == 1 then
        varClass = RubimRH.db.profile.wr
    end

    --Hunter
    if select(3, UnitClass("player")) == 3 then
        varClass = RubimRH.db.profile.hr
    end

    --Shaman
    if select(3, UnitClass("player")) == 7 then
        varClass = RubimRH.db.profile.sh
    end

    --Paladin
    if select(3, UnitClass("player")) == 2 then
        varClass = RubimRH.db.profile.pl
    end
    useCD = varClass.cooldown or false
end

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

if AethysCore == nil then
    message("ERROR: Aethyhs Core is missing. Please download it.")
end
if AethysCache == nil then
    message("ERROR: Aethyhs Cache is missing. Please download it.")
end

local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;

useRACIAL = true
useAoE = true
---SKILLS---
useS1 = true
useS2 = true
useS3 = true

--IconRotation.texture:SetTexture(GetSpellTexture(BloodRotation()))

-- Last Update: 05/04/18 02:42
-- Author: Rubim
--if isEqual(thisobj:GetRealSettings().Name) == true then
--return true
--end
--- ============================              ============================
function CDsON()
    if Player:Level() < 109 then
        return true
    end

    if useCD == true then
        if UnitExists("boss1") == true or UnitClassification("target") == "worldboss" then
            return true
        end

        if UnitExists("target") and UnitHealthMax("target") >= UnitHealthMax("player") then
            return true
        end

        if Target:IsDummy() then
            return true
        end
    end

    if useCD == false then
        return false
    end

    return false
end

function AoEON()
    if useAoE == true then
        return true
    else
        return false
    end
end

--- ============================              ============================
local nextAbility
function GetNextAbility()
    return nextAbility
end

function SetNextAbility(skill)
    if skill == nil then
        print("ERROR")
        return 0
    else
        nextAbility = skill
    end
end

--- ============================   MAIN_ROT   ============================
function MainRotation()
    if error == 1 then
        return "ERROR: Missing an addon"
    end

    if Player:IsMounted() then
        return 155142
    end

    --    shiftDown = IsShiftKeyDown()
    --    if shiftDown then
    --        return 69042
    --    end

    --    if Player:Level() < 10 then
    --        return 91344
    --    end

    --DK
    if select(3, UnitClass("player")) == 6 then
        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(250)
            SetNextAbility(BloodRotation())
        elseif GetSpecialization() == 2 then
            Player:RegisterListenedSpells(251)
            SetNextAbility(FrostRotation())
        elseif GetSpecialization() == 3 then
            Player:RegisterListenedSpells(252)
            SetNextAbility(UnholyRotation())
        end
    end

    --Demon HUNTER
    if select(3, UnitClass("player")) == 12 then
        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(577)
            SetNextAbility(HavocRotation())
        elseif GetSpecialization() == 2 then
            Player:RegisterListenedSpells(581)
            SetNextAbility(VengRotation())
        end
    end

    --Rogue
    if select(3, UnitClass("player")) == 4 then
        if GetSpecialization() == 1 then
            SetNextAbility(RogueAss())
        end
        if GetSpecialization() == 2 then
            SetNextAbility(RogueOutlaw())
        end
        if GetSpecialization() == 3 then
            SetNextAbility(RogueSub())
        end
    end

    --Monk
    if select(3, UnitClass("player")) == 10 then
        if GetSpecialization() == 1 then
            SetNextAbility(BrewMasterRotation())
        end
        if GetSpecialization() == 3 then
            SetNextAbility(WindWalkerRotation())
        end
    end

    --Warrior
    if select(3, UnitClass("player")) == 1 then
        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(71)
            SetNextAbility(WarriorArms())
        end
        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(72)
            SetNextAbility(WarriorFury())
        end
        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(73)
            SetNextAbility(WarriorProt())
        end
    end

    --Hunter
    if select(3, UnitClass("player")) == 3 then
        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(255)
            SetNextAbility(HunterSurvival())
        end

        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(254)
            SetNextAbility(HunterMM())
        end
    end

    --Shaman
    if select(3, UnitClass("player")) == 7 then
        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(263)
            SetNextAbility(Enhancement())
        end
    end

    --Paladin
    if select(3, UnitClass("player")) == 2 then
        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(65)
            SetNextAbility(PaladinRetribution())
        end

        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(66)
            SetNextAbility(PaladinProtection())
        end

        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(70)
            SetNextAbility(PaladinHoly())
        end
    end
    return GetNextAbility()
end