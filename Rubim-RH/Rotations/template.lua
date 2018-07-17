--- ============================ HEADER ============================
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
local addonName, addonTable = ...;
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;

local activeUnitPlates = {}

if not Spell.CLASS then
    Spell.CLASS = {};
end

Spell.CLASS.Spec = {
};

-- Items
if not Item.CLASS then
    Item.CLASS = {};
end
Item.CLASS.Spec = {
};

local S = Spell.CLASS.SPEC;
local I = Item.CLASS.SPEC;

local T202PC, T204PC = AC.HasTier("T20");
local T212PC, T214PC = AC.HasTier("T21");


local function APL()
    if not Player:AffectingCombat() then
        return 0, 462338
    end
    AC.GetEnemies("Melee");
    AC.GetEnemies(8, true);
    AC.GetEnemies(10, true);

    return 0, 975743
end
RubimRH.Rotation.SetAPL(XXX, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(XXX, PASSIVE);