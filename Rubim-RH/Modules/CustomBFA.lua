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

Spells = {
    ArcaneBarrage = 44425,
    FrostNova = 122,
}
local S = Spells


--Send Argument "gcd" to get gcd
local function CDDuration(spell)
    return TMW.CNDT.Env.CooldownDuration(spell)
end

local function BuffRemains(spell, unitID)
    local unitID = unitID or "Player"
    return select(1, TMW.CNDT.Env.AuraDur(unitID, spell, GetSpellInfo(spell)))
end

local function BuffDuration(spell, unitID)
    local unitID = unitID or "Player"
    return select(2, TMW.CNDT.Env.AuraDur(unitID, spell, GetSpellInfo(spell)))
end

local function BuffStack(spell, unitID)
    local unitID = unitID or "Player"
    return TMW.CNDT.Env.AuraStacks(unitID, spell, GetSpellInfo(spell))
end

local function SpellUsable(spell, offset)
    local offset = offset or 0.2
    return IsUsableSpell(spell) and CDDuration(spell) <= offset
end

function mainRotation()
    if CDDuration(S.ArcaneBarrage) > 0 then
        return S.FrostNova
    end

    if true then
        return S.ArcaneBarrage
    end

    return 0
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

