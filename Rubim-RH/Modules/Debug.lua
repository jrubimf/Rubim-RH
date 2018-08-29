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
    PrismaticBarrier = 235450,


    ArcanePower = 12042,
    ArcaneBlast = 30451,
    ArcaneBarrage = 44425,
    ArcaneMissiles = 5143,
    PresenceofMind = 205025,
    Clearcasting = 263725,
    FrostNova = 122,
    Evocation = 12051,

    Amplification = 236628,
    RuneofPower = 116011,
    Overpowered = 155147,
    ChargedUp = 205032,
    ArcaneOrb = 153626,
    NetherTempest = 114923,
}
local S = Spells


--Send Argument "gcd" to get gcd
local function CDDuration(spell)
    return TMW.CNDT.Env.CooldownDuration(spell)
end

local function BuffRemains(unitID, spell, source)
    local filter = "HELPFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return select(1, TMW.CNDT.Env.AuraDur(unitID, spell, filter))
end

local function Buffs(unitID, spell, source)
    local filter = "HELPFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"

    if #spell > 1 then
        local found = false
        for i, v in pairs(spell) do
            found = (select(2, TMW.CNDT.Env.AuraDur(unitID, v, filter)) > 0 and true or false)

            if found == true then
                break
            end
        end
        return found
    end

    return (select(2, TMW.CNDT.Env.AuraDur(unitID, spell, filter)) > 0 and true or false)
end

local function Buff(unitID, spell, source)

    local filter = "HELPFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"

    return (select(2, TMW.CNDT.Env.AuraDur(unitID, spell, filter)) > 0 and true or false)
end

local function BuffDuration(unitID, spell, source)
    local filter = "HELPFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return select(2, TMW.CNDT.Env.AuraDur(unitID, spell, filter))
end

local function BuffStack(unitID, spell, source)
    local filter = "HELPFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return TMW.CNDT.Env.AuraStacks(unitID, spell, filter)
end

local function DebuffRemains(unitID, spell, source)
    local filter = "HARMFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return select(1, TMW.CNDT.Env.AuraDur(unitID, spell, filter))
end

local function DebuffDuration(unitID, spell, source)
    local filter = "HARMFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return select(2, TMW.CNDT.Env.AuraDur(unitID, spell, filter))
end

local function DebuffStack(unitID, spell, source)
    local filter = "HARMFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return TMW.CNDT.Env.AuraStacks(unitID, spell, filter)
end

local function SpellUsable(spell, offset)
    local offset = offset or 0.2
    return IsUsableSpell(spell) and CDDuration(spell) <= offset
end

local function ArcanePowerCharge()
    return UnitPower("Player", Enum.PowerType.ArcaneCharges)
end

local function SpellAvailable(spellID)
    return IsSpellKnown(spellID, true) or IsPlayerSpell(spellID)
end

local function SpellReady(spellID)
    return SpellAvailable(spellID) and CDDuration(spellID) <= 0.2
end

local function SpellCharges(spellID)
    return GetSpellCharges(spellID)
end

local function ManaPct()
    return (UnitPower("Player", 0) / UnitPowerMax("Player", 0)) * 100
end

local function Invisible()
    return Buffs("player", { 114018, 32612, 110959, 198158 })
end

local function TargetIsEnemy()
    return ReactionUnit("target", "enemy")
end
function mainRotation()
    if SpellReady(S.PrismaticBarrier)
            and not Invisible()
            and TargetIsEnemy()
            and SpellInteract("target", 40)
            and BuffRemains("player", 235450, "player") <= CDDuration("GCD") * 5
            and CombatTime("player") == 0
            --and not ArcaneBurnPhase()
            and (not SpellAvailable(235463) or UnitPower("player") * 0.2 >= 20 / 100 * UnitHealthMax("player"))
    then
        return S.PrismaticBarrier
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