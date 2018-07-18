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
  if not Spell.Paladin then Spell.Paladin = {}; end
  Spell.Paladin.Holy = {
    -- Racials
    ArcaneTorrent                 = Spell(25046),
    GiftoftheNaaru                = Spell(59547),
 
 
	--Spells
	Cleanse						  = Spell(4987),
	Judgement					  = Spell(20271),
	CrusaderStrike				  = Spell(35395),
	Consecration				  = Spell(26573),
	LightoftheMartyr			  = Spell(183998),
	LightoftheMartyrStack		  = Spell(223316),
	FlashofLight				  = Spell(19750),
	HolyLight					  = Spell(82326),
	HolyShock					  = Spell(20473),
	InfusionofLight				  = Spell(53576),
	BeaconofLight				  = Spell(53563),
	BeaconofVirtue				  = Spell(200025),
	LightofDawn					  = Spell(85222),


    -- Legendaries
    LiadrinsFuryUnleashed         = Spell(208408),
    ScarletInquisitorsExpurgation = Spell(248289);
    WhisperoftheNathrezim         = Spell(207635)
  };
  local S = Spell.Paladin.Holy;
-- Items
  if not Item.Paladin then Item.Paladin = {}; end
  Item.Paladin.Holy = {
    -- Legendaries
    JusticeGaze                   = Item(137065, {1}),
    LiadrinsFuryUnleashed         = Item(137048, {11, 12}),
    WhisperoftheNathrezim         = Item(137020, {15})
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
	for i=1,40 do
		for x=1,#dispelTypes do
            if select(5,UnitDebuff("mouseover",i)) == dispelTypes[x] then
				for i=1,#blacklist do
					if UnitDebuff("mouseover",blacklist[i]) then
						return false
					end
                end
				return true
            end
		end
	end
	return false	
end

function lowDmg()


end


local function APL()
	--- Out of Combat    LeftCtrl = IsLeftControlKeyDown();
	HL.GetEnemies("Melee"); -- Melee
	HL.GetEnemies(6, true); -- 
    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();
	LeftAlt = IsLeftAltKeyDown();
    
	if LeftShift and LeftAlt and S.LightofDawn:IsCastable() then
        return S.LightofDawn:ID()
    end
	
	if Player:IsChanneling() or Player:IsCasting() then
        return 0, 236353
    end

	if LeftCtrl and MouseOver:Exists() and ShouldDispell() and S.Cleanse:IsReady() then
		return S.Cleanse:ID()
	end

	if LeftShift and MouseOver:Exists() and S.BeaconofVirtue:IsReady() then
		return 77394
	end

	if MouseOver:Exists() and not MouseOver:Buff(S.BeaconofLight) and UnitGUID("mouseover") == UnitGUID("focus") then
		return S.BeaconofLight:ID()
	end

	if Target:Exists() then

		if S.BeaconofVirtue:IsReady() and AoEHealing(90) >= 3 then
			return 144473
		end

		if S.HolyShock:IsReady() and not Player:CanAttack(Target) and Target:HealthPercentage() <= 95 and (not Player:Buff(S.InfusionofLight) or Player:BuffRemains(S.InfusionofLight) <= 2) then
			return S.HolyShock:ID()
		end

		if S.HolyShock:IsReady() and  not Target:IsAPlayer() and Player:CanAttack(Target) then
			return S.HolyShock:ID()
		end

		if not Player:CanAttack(Target) and S.HolyShock:IsReady() and Target:HealthPercentage() <= 80 then
			return S.HolyShock:ID()
		end

		if UnitGUID("player") ~= UnitGUID("target") and S.LightoftheMartyr:IsCastable() and not Player:CanAttack(Target) and Target:HealthPercentage() <= 80 and Player:BuffStack(S.LightoftheMartyrStack) >= 4 then
			return S.LightoftheMartyr:ID()
		end

		if UnitGUID("player") ~= UnitGUID("target") and S.LightoftheMartyr:IsCastable() and not Player:CanAttack(Target) and Target:HealthPercentage() <= 70 and Player:BuffStack(S.LightoftheMartyrStack) >= 3 then
			return S.LightoftheMartyr:ID()
		end

		if not Player:IsMoving() and S.FlashofLight:IsCastable() and not Player:CanAttack(Target) and Target:HealthPercentage() <= 75 then
			return S.FlashofLight:ID()
		end

		if not Player:IsMoving() and S.HolyLight:IsCastable() and not Player:CanAttack(Target) and Target:HealthPercentage() <= 90 then
			return S.HolyLight:ID()
		end

		if Player:IsMoving() and UnitGUID("player") ~= UnitGUID("target") and S.LightoftheMartyr:IsCastable() and not Player:CanAttack(Target) and Target:HealthPercentage() <= 60 and Player:HealthPercentage() >= 80 then
			return S.LightoftheMartyr:ID()
		end
	end

	if Player:AffectingCombat() and RubimRH.TargetIsValid() then
		if S.Judgement:IsUsable() and S.Judgement:IsCastable() then
			return S.Judgement:ID()
		end	
	
		if S.CrusaderStrike:IsUsable() and S.CrusaderStrike:IsCastable() and not S.HolyShock:CooldownUp() then
			return S.CrusaderStrike:ID()
		end
	
		if S.Consecration:IsCastable() and S.Consecration:IsCastable() and Cache.EnemiesCount[6] >= 1 then
			return S.Consecration:ID()
		end	
	end
	
	return 0, 975743
end
RubimRH.Rotation.SetAPL(65, APL);

local function PASSIVE()
	return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(65, PASSIVE);