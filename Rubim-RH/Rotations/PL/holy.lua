--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local MouseOver = Unit.MouseOver;
local Spell = HL.Spell;
local Item = HL.Item;
-- Lua
local pairs = pairs;


--- APL Local Vars
-- Spells
RubimRH.Spell[65] = {
	-- Racials
	ArcaneTorrent = Spell(25046),
	GiftoftheNaaru = Spell(59547),


	--Spells
	Cleanse = Spell(4987),
	Judgement = Spell(275773),
	CrusaderStrike = Spell(35395),
	Consecration = Spell(26573),
	LightoftheMartyr = Spell(183998),
	LightoftheMartyrStack = Spell(223316),
	FlashofLight = Spell(19750),
	HolyLight = Spell(82326),
	HolyShock = Spell(20473),
	InfusionofLight = Spell(53576),
	BeaconofLight = Spell(53563),
	BeaconofVirtue = Spell(200025),
	LightofDawn = Spell(85222),


	-- Legendaries
	LiadrinsFuryUnleashed = Spell(208408),
	ScarletInquisitorsExpurgation = Spell(248289);
	WhisperoftheNathrezim = Spell(207635)
};
local S = RubimRH.Spell[65]
-- Items
if not Item.Paladin then
	Item.Paladin = {};
end
Item.Paladin.Holy = {
	-- Legendaries
	JusticeGaze = Item(137065, { 1 }),
	LiadrinsFuryUnleashed = Item(137048, { 11, 12 }),
	WhisperoftheNathrezim = Item(137020, { 15 })
};
local I = Item.Paladin.Holy;
-- Rotation Var

-- APL Action Lists (and Variables)

-- APL Main
function ShouldDispell()
	-- Do not dispel these spells
	local blacklist = {
		33786,
		131736,
		30108,
		124465,
		34914
	}

	local dispelTypes = {
		"Poison",
		"Disease",
		"Magic"
	}
	for i = 1, 40 do
		for x = 1, #dispelTypes do
			if select(5, UnitDebuff("mouseover", i)) == dispelTypes[x] then
				for i = 1, #blacklist do
					if UnitDebuff("mouseover", blacklist[i]) then
						return false
					end
				end
				return true
			end
		end
	end
	return false
end
local function APL()
	--- Out of Combat    LeftCtrl = IsLeftControlKeyDown();
	HL.GetEnemies("Melee"); -- Melee
	HL.GetEnemies(6, true); --
	LeftCtrl = IsLeftControlKeyDown();
	LeftShift = IsLeftShiftKeyDown();
	LeftAlt = IsLeftAltKeyDown();

	if Player:IsChanneling() or Player:IsCasting() then
		return 0, 236353
	end

	if Player:AffectingCombat() and RubimRH.TargetIsValid() then
		if S.HolyShock:IsReady(40) then
			return S.HolyShock:Cast()
		end

		if S.Judgement:IsReady(30) then
			return S.Judgement:Cast()
		end

		if S.CrusaderStrike:IsReady()  then
			return S.CrusaderStrike:Cast()
		end

		if S.Consecration:IsReady() and Cache.EnemiesCount[6] >= 1 then
			return S.Consecration:Cast()
		end
	end

	return 0, 135328
end
RubimRH.Rotation.SetAPL(65, APL);

local function PASSIVE()
	return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(65, PASSIVE);