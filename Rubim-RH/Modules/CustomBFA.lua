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

local function EnemiesCount(range)


    return 0
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

local function GG.Spell:ID()
    return tostring(self.SpellID)
end

local function GG.Spell:Known()
    if self.IsActive == false then
        return false
    end
    return IsSpellKnown(self.SpellID, true) or IsPlayerSpell(self.SpellID)
end

local function GG.Spell:Charges()
    local currentcharges, maxcharges, chargestarttime, rechargerate = GetSpellCharges(self.SpellID)
    if currentcharges == maxcharges then
        return (select(1, GetSpellCharges(self.SpellID)))
    else
        local currenttime = GetTime()
        return currentcharges + ((currenttime - chargestarttime) / rechargerate)
    end
end

local function GG.Spell:BuffDuration(Target)
    local tar = Target or "Player"

    if not UnitExists(tar) then return 0 end

    return select(1, TMW.CNDT.Env.AuraDur(tar, self.SpellID, GetSpellInfo(self.SpellID)))
end

local function BuffDuration(target, spellID)
    return select(1, TMW.CNDT.Env.AuraDur(target, self.SpellID, GetSpellInfo(self.SpellID)))
end


local function GG.UpdateStatus()
    if TellMeWhen_Group9_Icon83.Enabled ~= nil then
        GG.Spell.Enhc = {
            Rockbiter = GG.Spell(279302, TellMeWhen_Group8_Icon25.Enabled),
        }

        GG.Spell.Feral = {
            Berserk         = GG.Spell(106951, TellMeWhen_Group8_Icon25.Enabled),
            TigersFury      = GG.Spell(5217, TellMeWhen_Group8_Icon25.Enabled),
            Regrowth        = GG.Spell(8936, TellMeWhen_Group8_Icon25.Enabled),
            Bloodtalons     = GG.Spell(155672, TellMeWhen_Group8_Icon25.Enabled),
            BloodtalonsBuff = GG.Spell(145152, TellMeWhen_Group8_Icon25.Enabled),
            Sabertooth      = GG.Spell(202031, TellMeWhen_Group8_Icon25.Enabled),
            Rip             = GG.Spell(1079, TellMeWhen_Group8_Icon25.Enabled),
            FerociousBite   = GG.Spell(1079, TellMeWhen_Group8_Icon25.Enabled),

            Thrash          = GG.Spell(106830, TellMeWhen_Group8_Icon25.Enabled),
            Rake            = GG.Spell(1822, TellMeWhen_Group8_Icon25.Enabled),
            RakeDebuff      = GG.Spell(155722, TellMeWhen_Group8_Icon25.Enabled),
            SavageRoar      = GG.Spell(52610, TellMeWhen_Group8_Icon25.Enabled),
            MoonfireCat     = GG.Spell(155625, TellMeWhen_Group8_Icon25.Enabled),
            BrutalSlash     = GG.Spell(202028, TellMeWhen_Group8_Icon25.Enabled),
        }
    end
end


local Feral = GG.Spell.Feral

local pvpImmunity = {
    33786, --  Cyclone
    642, --Divine Shield
    --122470, --Touch of Karma
    45438, -- Iceblock
    47585, --Dispersion
    31224, --Cloak of Shadows
    19263, --Deterrence
    212295, --Netherward
    210918, --Etheral Form
}

local pvpHasSlow = {
    
}




local function TargetIsImmune()
    if not UnitExists("target") then return false end
        for i,spellID in ipairs(pvpImmunity) do
            if BuffDuration("target", spellID) > 0 then
                return true
            end    
        end
    end    
end

function FeralRotation()
    GG.UpdateStatus()

    if TargetIsImmune() then
        return false
    end

    if UnitExists("target") and UnitIsPlayer("target") then
        return 0
    end

    if S.Berserk:Known() and RubimRH.CDsON() and Cache.EnemiesCount[8] >= 1 then
        return S.Berserk:ID()
    end

    if S.TigersFury:Known() and Player:EnergyPredicted() <= 45 and Cache.EnemiesCount[8] >= 1 then
        return S.TigersFury:ID()
    end

    if S.Regrowth:Known() and S.Bloodtalons:IsAvailable() and not Player:Buff(S.BloodtalonsBuff) then
        return S.Regrowth:ID()
    end

    if S.TigersFury:Known() and Player:EnergyPredicted() <= 30 then
        return S.TigersFury:ID()
    end

    if S.FeralFrenzy:Known() and Player:ComboPoints() == 0 then
        return S.FeralFrenzy:ID()
    end

    if S.Sabertooth:IsAvailable() then
        if S.FerociousBite:Known() and Target:DebuffRemains(S.Rip) >= 3 then
            return S.FerociousBite:ID()
        end
    else
        if S.Rip:Known() and Target:DebuffRemains(S.Rip) <= 3 and Target:HealthPercentage() > 25 then
            return S.Rip:ID()
        end

        if S.FerociousBite:Known() and Target:DebuffRemains(S.Rip) <= 3 and Target:HealthPercentage() < 25 then
            return S.FerociousBite:ID()
        end
    end

    if Cache.EnemiesCount[8] >= 3 and S.Thrash:Known() and Target:DebuffRemains(S.Thrash) < 3 then
        return S.Thrash:ID()
    end

    if S.Rip:Known() and Target:DebuffRemains(S.Rip) <= 3 then
        return S.Rip:ID()
    end

    if S.Rake:Known() and Target:DebuffRemains(S.RakeDebuff) <= 3 then
        return S.Rake:ID()
    end

    if S.SavageRoar:Known() and Player:BuffRemains(S.SavageRoar) <= 3 then
        return S.SavageRoar:ID()
    end

    if S.MoonfireCat:Known() and S.LunarInspiration:IsAvailable() then
        return S.MoonfireCat:ID()
    end

    if S.FerociousBite:Known() and Player:ComboPoints() == 5 and Player:BuffRemains(S.ApexPredator) > 0 then
        return S.FerociousBite:ID()
    end

    if S.Thrash:Known() and I.LuffaWrappings:IsEquipped() and Target:DebuffRemains(S.Thrash) <= 3 and Player:Buff(S.Clearcasting) then
        return S.Thrash:ID()
    end

    if S.FerociousBite:Known() and Player:ComboPoints() == 5 and Player:BuffRemains(S.SavageRoar) >= 7 and S.SavageRoar:IsAvailable() and Target:DebuffRemains(S.Rip) >= 7 then
        return S.FerociousBite:ID()
    end

    if S.FerociousBite:Known() and Player:ComboPoints() == 5 and not S.SavageRoar:IsAvailable() and Target:DebuffRemains(S.Rip) >= 7 then
        return S.FerociousBite:ID()
    end

    if S.BrutalSlash:Known() and Player:ComboPoints() < 5 then
        return S.BrutalSlash:ID()
    end

    if S.Shred:Known() then
        return S.Shred:ID()
    end
    return 0
end

function TMW.CNDT.Env.isEqual(skill, rotation)
    if skill == RotationHelper(rotation) then
        return true
    end
    return false
end
