local error = error
local setmetatable = setmetatable
local stringformat = string.format

local function Class()
    local Class = {}
    Class.__index = Class
    setmetatable(Class, {
        __call = function(self, ...)
            local Object = {}
            setmetatable(Object, self)
            Object:New(...)
            return Object
        end
    })
    return Class
end

local Spell = Class()
function Spell:New(SpellID, SpellType)
    self.SpellID = SpellID
    self.isActive = true
end

local Spells = {
    ArcaneBarrage = Spell(44425),
}

local S = Spells

function Spell:CDRemains()
    return TMW.CNDT.Env.CooldownDuration(self.SpellID)
end

function mainRotation()
    return 44425
end

function RotationHelper(icon)
    local spellID = tonumber(icon.Name)
    if icon.Enabled and spellID == mainRotation() then
        return true
    end
    return false
end

local L = TMW.L
local CNDT = TMW.CNDT
local ConditionCategory = CNDT:GetCategory("MISC")
local rotationPassed = false
ConditionCategory:RegisterCondition(0, "ROTATIONCHECK", {
    text = "Ayni - Rotation Check",
    tooltip = "This should be in every Spell",

    bool = true,
    unit = false,
    icon = "Interface\\Icons\\inv_misc_map08",
    tcoords = CNDT.COMMON.standardtcoords,
    funcstr = function(c, icon)
        print("Limpinha")
        return [[BOOLCHECK(true)]]
    end,
})

