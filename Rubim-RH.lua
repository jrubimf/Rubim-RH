local RubimRH = LibStub("AceAddon-3.0"):NewAddon("RubimRH", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
--local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
--[[ The defaults a user without a profile will get. ]]--

local classRotation = "None"

--DK
local DeathStrike = 49998
local RuneTap = 194679
local BreathOfSindragosa = 152279
local SindragosasFury = 190778
local PillarOfFrost = 51271

--DH
local FelRush = 195072
local EyeBeam = 198013
local FelBarrage = 211053

--Warrior
local Warbreaker = 209577
local Ravager = 152277
local OdynsFury = 205545

--Paladin
local JusticarVengeance = 215661
local WordofGlory = 210191
local layonahands = 633
local guardianofancientkings = 86659
local ardentdefender = 31850

--Shaman
local HealingSurge = 188070

--Druid
local Regrowth = 8936
local Renewal = 108238

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

local defaults = {
    profile = {
        mainOption = {
            cooldownbind = nil,
            interruptsbind = nil,
        },
        dh = {
            havoc = {
                cooldown = true,
                spells = {
                    { spellID = FelRush, isActive = true },
                    { spellID = EyeBeam, isActive = true },
                    { spellID = FelBarrage, isActive = true }
                }
            },
            veng = {
                cooldown = true,
            },
        },
        dk = {
            blood = {
                cooldown = true,
                spells = {
                    { spellID = DeathStrike, isActive = true },
                    { spellID = RuneTap, isActive = true }
                }
            },
            frost = {
                cooldown = true,
                deathstrike = 85,
                spells = {
                    { spellID = DeathStrike, isActive = true },
                    { spellID = BreathOfSindragosa, isActive = true },
                    { spellID = SindragosasFury, isActive = true },
                    { spellID = PillarOfFrost, isActive = true }
                }
            },
            unholy = {
                cooldown = true,
                deathstrike = 85,
                spells = {
                    { spellID = DeathStrike, isActive = true },
                    { spellID = RuneTap, isActive = true }
                }
            },
        },
        pl = {
            ret = {
                cooldown = true,
                justicarglory = 50,
                spells = {
                    { spellID = JusticarVengeance, isActive = true }
                }
            },
            holy = {
                cooldown = true,
            },
            prot = {
                cooldown = true,
                lightoftheprotectorpct = 90,
                layonahandspct = 20,
                ardentdefenderpct = 5,
                guardianofancientkingspct = 50,
                spells = {
                    { spellID = layonahands, isActive = false },
                    { spellID = ardentdefender, isActive = false },
                    { spellID = guardianofancientkings, isActive = false },
                }
            },
        },
        wr = {
            arms = {
                cooldown = true,
                victoryrush = 80,
                spells = {
                    { spellID = Warbreaker, isActive = true },
                    { spellID = Ravager, isActive = true }
                }
            },
            fury = {
                cooldown = true,
                spells = {
                    { spellID = OdynsFury, isActive = true }
                }
            },
            prot = {
                cooldown = true,
                victoryrush = 80,
            }
        },
        rg = {
            out = {
                cooldown = true,
            },
            sub = {
                cooldown = true,
            },
            ass = {
                cooldown = true,
            }
        },
        hr = {
            mm = {
                cooldown = true,
            },
            bm = {
                cooldown = true,
            },

            surv = {
                cooldown = true,
            }
        },
        mk = {
            brew = {
                cooldown = true,
            },
            wind = {
                cooldown = true,
            },
        },
        sh = {
            enh = {
                cooldown = true,
                spells = {
                    { spellID = HealingSurge, isActive = true }
                }
            },
        },
        dr = {
            feral = {
                cooldowns = false,
                renewal = 50,
                regrowth = 85,
                spells = {
                    { spellID = Renewal, isActive = true },
                    { spellID = Regrowth, isActive = true },
                }
            },
            guardian = {
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

updateClassVariables:SetScript("OnEvent", function(self, event, ...)

    --DK
    if select(3, UnitClass("player")) == 6 then
        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(250)
            classRotation = "blood"
            varClass = RubimRH.db.profile.dk.blood
        elseif GetSpecialization() == 2 then
            Player:RegisterListenedSpells(251)
            classRotation = "frost"
            varClass = RubimRH.db.profile.dk.frost
        elseif GetSpecialization() == 3 then
            Player:RegisterListenedSpells(252)
            classRotation = "unholy"
            varClass = RubimRH.db.profile.dk.unholy
        end
    end

    --Demon HUNTER
    if select(3, UnitClass("player")) == 12 then
        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(577)
            classRotation = "havoc"
            varClass = RubimRH.db.profile.dh.havoc
        elseif GetSpecialization() == 2 then
            Player:RegisterListenedSpells(581)
            classRotation = "veng"
            varClass = RubimRH.db.profile.dh.veng
        end
    end

    --Rogue
    if select(3, UnitClass("player")) == 4 then
        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(259)
            classRotation = "ass"
            varClass = RubimRH.db.profile.rg.ass
        end
        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(260)
            classRotation = "out"
            varClass = RubimRH.db.profile.rg.out
        end
        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(261)
            varClass = RubimRH.db.profile.rg.sub
        end
    end

    --Monk
    if select(3, UnitClass("player")) == 10 then
        if GetSpecialization() == 1 then
            classRotation = "brew"
            varClass = RubimRH.db.profile.mk.brew
        end
        if GetSpecialization() == 3 then
            classRotation = "wind"
            varClass = RubimRH.db.profile.mk.ww
        end
    end

    --Warrior
    if select(3, UnitClass("player")) == 1 then
        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(71)
            classRotation = "arms"
            varClass = RubimRH.db.profile.wr.arms
        end
        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(72)
            classRotation = "fury"
            varClass = RubimRH.db.profile.wr.fury
        end
        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(73)
            classRotation = "prot"
            varClass = RubimRH.db.profile.wr.prot
        end
    end

    --Hunter
    if select(3, UnitClass("player")) == 3 then
        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(255)
            classRotation = "surv"
            varClass = RubimRH.db.profile.hr.surv
        end

        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(254)
            classRotation = "mm"
            varClass = RubimRH.db.profile.hr.mm
        end
    end

    --Shaman
    if select(3, UnitClass("player")) == 7 then
        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(263)
            classRotation = "enh"
            varClass = RubimRH.db.profile.sh.enh
        end
    end

    --Paladin
    if select(3, UnitClass("player")) == 2 then
        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(65)
            classRotation = "ret"
            varClass = RubimRH.db.profile.pl.ret
        end

        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(66)
            classRotation = "pprot"
            varClass = RubimRH.db.profile.pl.prot
        end

        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(70)
            classRotation = "holy"
            varClass = RubimRH.db.profile.pl.holy
        end
    end

    --Druid
    if select(3, UnitClass("player")) == 11 then
        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(103)
            classRotation = "feral"
            varClass = RubimRH.db.profile.dr.feral
        end

        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(104)
            classRotation = "guardian"
            varClass = RubimRH.db.profile.dr.guardian
        end
    end

    if classRotation == "None" then
        message("ERROR: Class not supported")
    end
    useCD = varClass.cooldown or false
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

    if Player:IsMounted() or (select(3, UnitClass("player")) == 11 and (GetShapeshiftForm() == 3 or GetShapeshiftForm() == 5)) then
        return 0, 975744
    end

    if ACTIVE_CHAT_EDIT_BOX ~= nil then
        return 0, 413580
    end

    if _G.LootFrame:IsShown() then
        return 0, 975746
    end

    if not Player:AffectingCombat() then
        SetNextAbility(146250)
    else
        SetNextAbility(233159)
    end

    --    shiftDown = IsShiftKeyDown()
    --    if shiftDown then
    --        return 69042
    --    end

    --    if Player:Level() < 10 then
    --        return 91344
    --    end

    --DK
    if classRotation == "blood" then
        SetNextAbility(BloodRotation())
    end

    if classRotation == "frost" then
        SetNextAbility(FrostRotation())
    end

    if classRotation == "unholy" then
        SetNextAbility(UnholyRotation())
    end

    --DH
    if classRotation == "havoc" then
        SetNextAbility(HavocRotation())
    end
    if classRotation == "veng" then
        SetNextAbility(VengRotation())
    end

    --RG
    if classRotation == "ass" then
        SetNextAbility(RogueAss())
    end
    if classRotation == "out" then
        SetNextAbility(RogueOutlaw())
    end
    if classRotation == "sub" then
        SetNextAbility(RogueSub())
    end



    --MK
    if classRotation == "brew" then
        SetNextAbility(BrewMasterRotation())
    end
    if classRotation == "mind" then
        SetNextAbility(WindWalkerRotation())
    end


    --Warrior
    if classRotation == "arms" then
        SetNextAbility(WarriorArms())
    end
    if classRotation == "fury" then
        SetNextAbility(WarriorFury())
    end
    if classRotation == "prot" then
        SetNextAbility(WarriorProt())
    end


    --Hunter
    if classRotation == "mm" then
        SetNextAbility(HunterMM())
    end
    if classRotation == "surv" then
        SetNextAbility(HunterSurvival())
    end

    --Shaman
    if classRotation == "enh" then
        SetNextAbility(ShamanEnh())
    end

    --Paladin
    if classRotation == "holy" then
        SetNextAbility(PaladinHoly())
    end
    if classRotation == "pprot" then
        SetNextAbility(PaladinProtection())
    end
    if classRotation == "ret" then
        SetNextAbility(PaladinRetribution())
    end

    --Druid
    if classRotation == "feral" then
        SetNextAbility(DruidFeral())
    end
    if classRotation == "guardian" then
        SetNextAbility(DruidGuardian())
    end
    return GetNextAbility()
end