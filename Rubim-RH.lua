local errorEvent = CreateFrame("Frame")
errorEvent:RegisterEvent("PLAYER_LOGIN")
errorEvent:SetScript("OnEvent", function(self, event)

    if AethysCore == nil then
        message("ERROR: Aethyhs Core is missing. Please download it.")
    end
    if AethysCache == nil then
        message("ERROR: Aethyhs Cache is missing. Please download it.")
    end

    if RubimExtra == true and RubimExtraVer ~= "02072018" then
        message("ERROR: RubimExtra outdated. Please update it.")
    end
end)



local RubimRH = LibStub("AceAddon-3.0"):NewAddon("RubimRH", "AceEvent-3.0", "AceConsole-3.0")
_G["RubimRH"] = RubimRH
local AceGUI = LibStub("AceGUI-3.0")
--local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
--[[ The defaults a user without a profile will get. ]]--

RubimRH.currentSpec = "None"

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

local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;

useRACIAL = true
---SKILLS---
useS1 = true
useS2 = true
useS3 = true
RubimRH.useAoE = true

local defaults = {
    profile = {
        mainOption = {
            cooldownbind = nil,
            interruptsbind = nil,
            aoebind = nil,
            ccbreak = true,
            startattack = false,
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
                smartds = 30,
                spells = {
                    { spellID = DeathStrike, isActive = false },
                    { spellID = RuneTap, isActive = false }
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
                healingsurge = 80,
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
            RubimRH.currentSpec = "blood"
            varClass = RubimRH.db.profile.dk.blood
        elseif GetSpecialization() == 2 then
            Player:RegisterListenedSpells(251)
            RubimRH.currentSpec = "frost"
            varClass = RubimRH.db.profile.dk.frost
        elseif GetSpecialization() == 3 then
            Player:RegisterListenedSpells(252)
            RubimRH.currentSpec = "unholy"
            varClass = RubimRH.db.profile.dk.unholy
        end
    end

    --Demon HUNTER
    if select(3, UnitClass("player")) == 12 then
        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(577)
            RubimRH.currentSpec = "havoc"
            varClass = RubimRH.db.profile.dh.havoc
        elseif GetSpecialization() == 2 then
            Player:RegisterListenedSpells(581)
            RubimRH.currentSpec = "veng"
            varClass = RubimRH.db.profile.dh.veng
        end
    end

    --Rogue
    if select(3, UnitClass("player")) == 4 then
        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(259)
            RubimRH.currentSpec = "ass"
            varClass = RubimRH.db.profile.rg.ass
        end
        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(260)
            RubimRH.currentSpec = "out"
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
            RubimRH.currentSpec = "brew"
            varClass = RubimRH.db.profile.mk.brew
        end
        if GetSpecialization() == 3 then
            RubimRH.currentSpec = "wind"
            varClass = RubimRH.db.profile.mk.wind
        end
    end

    --Warrior
    if select(3, UnitClass("player")) == 1 then
        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(71)
            RubimRH.currentSpec = "arms"
            varClass = RubimRH.db.profile.wr.arms
        end
        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(72)
            RubimRH.currentSpec = "fury"
            varClass = RubimRH.db.profile.wr.fury
        end
        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(73)
            RubimRH.currentSpec = "prot"
            varClass = RubimRH.db.profile.wr.prot
        end
    end

    --Hunter
    if select(3, UnitClass("player")) == 3 then
        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(255)
            RubimRH.currentSpec = "surv"
            varClass = RubimRH.db.profile.hr.surv
        end

        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(254)
            RubimRH.currentSpec = "mm"
            varClass = RubimRH.db.profile.hr.mm
        end
    end

    --Shaman
    if select(3, UnitClass("player")) == 7 then
        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(263)
            RubimRH.currentSpec = "enh"
            varClass = RubimRH.db.profile.sh.enh
        end
    end

    --Paladin
    if select(3, UnitClass("player")) == 2 then
        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(65)
            RubimRH.currentSpec = "ret"
            varClass = RubimRH.db.profile.pl.ret
        end

        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(66)
            RubimRH.currentSpec = "pprot"
            varClass = RubimRH.db.profile.pl.prot
        end

        if GetSpecialization() == 1 then
            Player:RegisterListenedSpells(70)
            RubimRH.currentSpec = "holy"
            varClass = RubimRH.db.profile.pl.holy
        end
    end

    --Druid
    if select(3, UnitClass("player")) == 11 then
        if GetSpecialization() == 2 then
            Player:RegisterListenedSpells(103)
            RubimRH.currentSpec = "feral"
            varClass = RubimRH.db.profile.dr.feral
        end

        if GetSpecialization() == 3 then
            Player:RegisterListenedSpells(104)
            RubimRH.currentSpec = "guardian"
            varClass = RubimRH.db.profile.dr.guardian
        end
    end

    if RubimRH.currentSpec == "None" then
        message("ERROR: Class not supported")
    end
    RubimRH.useCD = varClass.cooldown or false
    ccBreak =  RubimRH.db.profile.mainOption.ccbreak
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

    if RubimRH.useCD == true then
        if UnitExists("boss1") == true or UnitClassification("target") == "worldboss" then
            return true
        end

        if UnitExists("target") and UnitHealthMax("target") >= UnitHealthMax("player") then
            return true
        end

        if Target:IsDummy() then
            return true
        end

        if UnitIsPlayer("target") then
            return true
        end
    end

    if RubimRH.useCD == false then
        return false
    end

    return false
end

function AoEON()
    if RubimRH.useAoE == true then
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
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\chatting.tga"
    end

    if _G.LootFrame:IsShown() then
        return 0, 975746
    end

    if RubimRH.breakableCC(Target) == true then
        return 243762
    end

--    if not Player:AffectingCombat() then
--        SetNextAbility(0, 462338)
--    else
--        SetNextAbility(0, 975743)
    --end

    --    shiftDown = IsShiftKeyDown()
    --    if shiftDown then
    --        return 69042
    --    end

    --    if Player:Level() < 10 then
    --        return 91344
    --    end

    --DK
    if RubimRH.currentSpec == "blood" then
        return BloodRotation()
    end

    if RubimRH.currentSpec == "frost" then
        return FrostRotation()
    end

    if RubimRH.currentSpec == "unholy" then
        return UnholyRotation()
    end

    --DH
    if RubimRH.currentSpec == "havoc" then
        return HavocRotation()
    end
    if RubimRH.currentSpec == "veng" then
        return VengRotation()
    end

    --RG
    if RubimRH.currentSpec == "ass" then
        return RogueAss()
    end
    if RubimRH.currentSpec == "out" then
        return RogueOutlaw()
    end
    if RubimRH.currentSpec == "sub" then
        return RogueSub()
    end



    --MK
    if RubimRH.currentSpec == "brew" then
        return BrewMasterRotation()
    end
    if RubimRH.currentSpec == "wind" then
        return WindWalkerRotation()
    end


    --Warrior
    if RubimRH.currentSpec == "arms" then
        return WarriorArms()
    end
    if RubimRH.currentSpec == "fury" then
        return WarriorFury()
    end
    if RubimRH.currentSpec == "prot" then
        return WarriorProt()
    end


    --Hunter
    if RubimRH.currentSpec == "mm" then
        return HunterMM()
    end
    if RubimRH.currentSpec == "surv" then
        return HunterSurvival()
    end

    --Shaman
    if RubimRH.currentSpec == "enh" then
        return ShamanEnh()
    end

    --Paladin
    if RubimRH.currentSpec == "holy" then
        return PaladinHoly()
    end
    if RubimRH.currentSpec == "pprot" then
        return PaladinProtection()
    end
    if RubimRH.currentSpec == "ret" then
        return PaladinRetribution()
    end

    --Druid
    if RubimRH.currentSpec == "feral" then
        return DruidFeral()
    end
    if RubimRH.currentSpec == "guardian" then
        return DruidGuardian()
    end
    return nil
end