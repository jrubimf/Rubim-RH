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

--DEFAULTS
useRACIAL = true
useAoE = true
useCD = true
---SKILLS---
useS1 = true
useS2 = true
useS3 = true
---TIER---
t212 = true
t214 = true

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


function TargetIsValid()
    return Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost();
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

    if IsMounted() and UnitAura("player", GetSpellInfo(190784)) == nil then
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
            SetNextAbility(BloodRotation())
            --Frost
        elseif GetSpecialization() == 2 then
            SetNextAbility(FrostRotation())
        elseif GetSpecialization() == 3 then
            SetNextAbility(UnholyRotation())
        end
    end

    --Demon HUNTER
    if select(3, UnitClass("player")) == 12 then
        if GetSpecialization() == 1 then
            SetNextAbility(HavocRotation())
        elseif GetSpecialization() == 2 then
            SetNextAbility(VengRotation())
        end
    end

    --Rogue
    if select(3, UnitClass("player")) == 4 then
        if GetSpecialization() == 1 then
            SetNextAbility(AssasinationRotation())
        end
        if GetSpecialization() == 2 then
            SetNextAbility(OutlawRotation())
        end
        if GetSpecialization() == 3 then
            SetNextAbility(SubRotation())
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
            SetNextAbility(WarriorArms())
        end
        if GetSpecialization() == 2 then
            SetNextAbility(WarriorFury())
        end
        if GetSpecialization() == 3 then
            SetNextAbility(WarriorProt())
        end
    end

    --Hunter
    if select(3, UnitClass("player")) == 3 then
        if GetSpecialization() == 3 then
            SetNextAbility(HunterSurvival())
        end
    end

    --Shaman
    if select(3, UnitClass("player")) == 7 then
        if GetSpecialization() == 2 then
            SetNextAbility(Enhancement())
        end
    end

    --Paladin
    if select(3, UnitClass("player")) == 2 then
        if GetSpecialization() == 3 then
            SetNextAbility(PaladinRetribution())
        end

        if GetSpecialization() == 2 then
            SetNextAbility(PaladinProtection())
        end

        if GetSpecialization() == 1 then
            SetNextAbility(PaladinHoly())
        end
    end


    return GetNextAbility()
end