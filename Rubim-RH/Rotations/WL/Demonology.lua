local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item

local S = RubimRH.Spell[266]

RubimRH.Rotation.SetAPL(266, APL)

local function PASSIVE()
	return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(266, PASSIVE)