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


local function BuffRemains(spell, unitID, source)
    local filter = "HELPFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return select(1, TMW.CNDT.Env.AuraDur(unitID, spell, filter))
end

local function BuffDuration(spell, unitID, source)
    local filter = "HELPFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return select(2, TMW.CNDT.Env.AuraDur(unitID, spell, filter))
end

local function BuffStack(spell, unitID, source)
    local filter = "HELPFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return TMW.CNDT.Env.AuraStacks(unitID, spell, filter)
end

local function DebuffRemains(spell, unitID, source)
    local filter = "HARMFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return select(1, TMW.CNDT.Env.AuraDur(unitID, spell, filter))
end

local function DebuffDuration(spell, unitID, source)
    local filter = "HARMFUL"

    if source == "Player" then
        filter = filter .. " " .. "PLAYER"
    end

    local unitID = unitID or "Player"
    return select(2, TMW.CNDT.Env.AuraDur(unitID, spell, filter))
end

local function DebuffStack(spell, unitID, source)
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


local function BurnPhase()
    --Cast Charged Up if talented and you have 2 or less Arcane Charges.
    if SpellReady(S.ChargedUp) and ArcanePowerCharge() <= 2 then
        return S.ChargedUp
    end

    --Cast Arcane Orb Icon Arcane Orb if talented and if you do not have 4 Arcane Charges.
    if SpellReady(S.ArcaneOrb) and ArcanePowerCharge() < 4 then
        return S.ArcaneOrb
    end

    --Cast Nether Tempest Icon Nether Tempest if talented and you have 4 Arcane Charges, and it is not up, or has less than 3 seconds remaining, and both Arcane Power and Rune of Power are currently not active.
    if SpellReady(S.NetherTempest) and ArcanePowerCharge() == 4 and DebuffRemains(S.NetherTempest, "Target") <= 3 and BuffRemains(S.ArcanePower) == 0 and BuffRemains(S.RuneofPower) == 0 then
        return S.NetherTempest
    end

    --Cast Mirror Image Icon Mirror Image, if talented.
    if SpellReady(S.MirrorImage) then
        return S.MirrorImage
    end

    --Cast Rune of Power, if talented.
    if SpellReady(S.RuneofPower) then
        return S.RuneofPower
    end

    --Cast Arcane Power.
    if SpellReady(S.ArcanePower) then
        return S.ArcanePower
    end

    --Cast Presence of Mind Icon Presence of Mind.
    if SpellReady(S.PresenceofMind) then
        return S.PresenceofMind
    end

    --TODO AOE CHECK or TOGGLE
    --Cast Arcane Barrage Icon Arcane Barrage if there are 3 or more targets and you have 4 stacks of Arcane Charges.
    --Cast Arcane Explosion Icon Arcane Explosion if there are 3 or more targets.


    --Cast Arcane Missiles Icon Arcane Missiles when Clearcasting Icon Clearcasting procs and you have Amplification Icon Amplification talented.
    if SpellReady(S.ArcaneMissiles) and BuffRemains(S.Clearcasting) and SpellAvailable(S.Amplification) then
        return S.ArcaneMissiles
    end

    --Cast Arcane Missiles Icon Arcane Missiles when Clearcasting Icon Clearcasting procs and you have less than 95% Mana, and Arcane Power Icon Arcane Power is not active.
    if SpellReady(S.ArcaneMissiles) and BuffRemains(S.Clearcasting) and ManaPct() <= 95 and BuffRemains(S.ArcanePower) == 0 then
        return S.ArcaneMissiles
    end

    --Cast Arcane Blast Icon Arcane Blast.
    if SpellReady(S.ArcaneBlast) then
        return S.ArcaneBlast
    end
    --TODO HOW MUCH?
    --Cast Evocation Icon Evocation when out of Mana.
    --If you run out of Mana before Evocation Icon Evocation is available, simply use Arcane Barrage Icon Arcane Barrage to reset your Arcane Charges, and continue like normal until Evocation is available.

    return 0
end


local function ConservePhase()

end

function mainRotation()
    --Arcane Power Icon Arcane Power is ready;
    --you have 4 charges of Arcane Charges;
    --at least one charge of Rune of Power Icon Rune of Power is available, if running the talent;
    --you have at least 50% Mana (30% if Overpowered Icon Overpowered is talented).


    if CDDuration(S.ArcanePower) > 0 and ArcanePowerCharge() >= 4 and (SpellAvailable(S.RuneofPower) and SpellCharges(S.RuneofPower) >= 1 or (ManaPct() >= 50 or (ManaPct() >= 30 and SpellAvailable(S.Overpowered)))) then
        return BurnPhase()
    end

    if CDDuration(S.Evocation) > 0 then
        return ConservePhase()
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
ConditionCategory:RegisterCondition(0, "ROTATIONCHECK2", {
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
    events = function(ConditionObject, c)
        return
        ConditionObject:GenerateNormalEventString("SPELL_UPDATE_COOLDOWN"),
        ConditionObject:GenerateNormalEventString("SPELL_UPDATE_USABLE"),
        ConditionObject:GenerateNormalEventString("UNIT_AURA", "Player"),
        ConditionObject:GenerateNormalEventString("UNIT_AURA", "Target")
    end,
})

ConditionCategory:RegisterCondition(1,	 "ROTATIONCHECK", {
    text = "Rotation Checker",
    tooltip = "Use this on every ability.",
    bool = true,
    --levelChecks = true,
    --isicon = true,
    nooperator = true,
    unit = false,
    icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
    tcoords = CNDT.COMMON.standardtcoords,
    funcstr = function(c, icon)
        if c.Icon == "" or c.Icon == icon:GetGUID() then
            --return [[true]]
        end
        print(icon)
        return true
    end,
    --[[events = function(ConditionObject, c)
        local event = TMW.Classes.IconDataProcessor.ProcessorsByName.REALALPHA.changedEvent
        ConditionObject:RequestEvent(event)
        ConditionObject:SetNumEventArgs(1)
        return
            "event == '" .. event .. "' and arg1:GetGUID() == " .. format("%q", c.Icon)
    end,]]
})