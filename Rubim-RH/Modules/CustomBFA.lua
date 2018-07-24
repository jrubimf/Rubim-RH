GG = {}

local function RunesAvailable()
    local available = 0
    --    local number2 = tonumber(number)
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown(i);
        if runeReady then
            available = available + 1
        end
    end
    return available
end

local function SpellStacksFrac(spell)
    local currentcharges, maxcharges, chargestarttime, rechargerate = GetSpellCharges(spell)
    if currentcharges == maxcharges then
        return (select(1, GetSpellCharges(spell)))
    else
        local currenttime = GetTime()
        return currentcharges + ((currenttime - chargestarttime) / rechargerate)
    end
end

local function SpellCD(spell)
    return select(2, TMW.CNDT.Env.GetSpellCooldown(spell))
end

local function BuffDur(spell)
    return select(1, TMW.CNDT.Env.AuraDur("player", spell, GetSpellInfo(spell)))
end

local function BuffStack(spell)
    return TMW.CNDT.Env.AuraStacks("player", spell, GetSpellInfo(spell))
end

local function hasTalent(tier, rank)
    return select(4, GetTalentInfo(tier, rank, 1))
end

local setmetatable = setmetatable;
local function Class ()
    local Class = {};
    Class.__index = Class;
    setmetatable(Class, { __call = function(self, ...)
        local Object = {};
        setmetatable(Object, self);
        Object:New(...);
        return Object;
    end
    });
    return Class;
end
--- ======= SPELL =======
do
    local Spell = Class();
    GG.Spell = Spell;
    function Spell:New (SpellID, IsActive, SpellType)
        if type(SpellID) ~= "number" then
            error("Invalid SpellID.");
        end
        if SpellType and type(SpellType) ~= "string" then
            error("Invalid Spell Type.");
        end
        self.SpellID = SpellID;
        self.SpellType = SpellType or "Player"; -- For Pet, put "Pet". Default is "Player".
        self.IsActive = IsActive;
    end
end

function GG.Spell:ID()
    return tostring(self.SpellID)
end

function GG.Spell:Known()
    if self.IsActive == false then
        return false
    end
    return IsSpellKnown(self.SpellID, true) or IsPlayerSpell(self.SpellID)
end

function GG.Spell:Charges()
    local currentcharges, maxcharges, chargestarttime, rechargerate = GetSpellCharges(self.SpellID)
    if currentcharges == maxcharges then
        return (select(1, GetSpellCharges(self.SpellID)))
    else
        local currenttime = GetTime()
        return currentcharges + ((currenttime - chargestarttime) / rechargerate)
    end
end

function GG.Spell:BuffDuration(Target)
    local tar = Target or "Player"

    if not UnitExists(tar) then return 0 end

    return select(1, TMW.CNDT.Env.AuraDur(tar, self.SpellID, GetSpellInfo(self.SpellID)))
end

function GG.UpdateStatus()
    if TellMeWhen_Group9_Icon83.Enabled ~= nil then
        GG.Spell.Enhc = {
            Rockbiter = GG.Spell(279302, TellMeWhen_Group8_Icon25.Enabled),
        }
    end
end
local S = GG.Spell.Enhc
--end

function RotationHelper(Class)
    GG.UpdateStatus()
    --updateSpells()
    --MAINDK
    local runicpower = UnitPower("player")
    local percenthp = UnitHealthMax("player") * 100 / UnitHealth("player")

    --Cast Rockbiter Icon Rockbiter if the buff is not currently active and you are about to reach 2 charges.
    --S.Rockbiter:Known() and S.Rockbiter:BuffDuration() <= 0

    --if S.Rockbiter
    --Cast Fury of Air Icon Fury of Air if it is not active.
    --Cast Totem Mastery Icon Totem Mastery if not active.
    --Cast Crash Lightning Icon Crash Lightning if 2 targets are in range and the buff is not present.
    --Cast Windstrike Icon Windstrike during Ascendance Icon Ascendance.
    --Cast Flametongue Icon Flametongue if the buff is not active.
    --Cast Feral Spirit Icon Feral Spirit on cooldown.
    --Cast Earthen Spike Icon Earthen Spike.
    --Cast Frostbrand Icon Frostbrand if not active Hailstorm Icon Hailstorm effect.
    --Cast Ascendance Icon Ascendance.
    --Cast Stormstrike Icon Stormstrike with or without Stormbringer Icon Stormbringer.
    --Cast Crash Lightning Icon Crash Lightning if 3 targets are in range.
    --Cast Lightning Bolt Icon Lightning Bolt if above 40 Maelstrom (50 with Fury of Air Icon Fury of Air).
    --Cast Flametongue Icon Flametongue regardless of buff duration to trigger Searing Assault Icon Searing Assault.
    --Cast Sundering Icon Sundering.
    --Cast Rockbiter Icon Rockbiter if below 70 Maelstrom and about to reach 2 charges.
    --Cast Frostbrand Icon Frostbrand with Hailstorm Icon Hailstorm taken and the buff has less than 4.5 seconds remaining.
    --Cast Crash Lightning Icon Crash Lightning if 2 targets are in range.
    --Cast Lava Lash Icon Lava Lash if above 40 Maelstrom (50 with Fury of Air Icon Fury of Air taken.
    --Cast Rockbiter Icon Rockbiter.
    return "NO SPELL"
end

function TMW.CNDT.Env.isEqual(skill, rotation)
    if skill == RotationHelper(rotation) then
        return true
    end
    return false
end

