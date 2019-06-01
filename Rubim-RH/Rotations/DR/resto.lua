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
RubimRH.Spell[105] = {
    -- Racials
    ArcaneTorrent    = Spell(25046),
    GiftoftheNaaru   = Spell(59547),
	Berserking       = Spell(26297),

    -- Spells
    Rejuvenation     = Spell(774),
	WildGrowth       = Spell(48438),
	Swiftmend        = Spell(18562),
	Lifebloom        = Spell(33763),
	Regrowth         = Spell(8936),
	Efflorescence    = Spell(145205),
	EfflorescenceBuff = Spell(145205),
	Innervate        = Spell(29166),
	Tranquility      = Spell(740),
	Flourish         = Spell(197721),
    
	-- Offensive
    Moonfire         = Spell(8921),
    Sunfire          = Spell(93402),
    SolarWrath       = Spell(5176),	
	
    -- Utility
	Ironbark         = Spell(102342),
	Barkskin         = Spell(22812),
	Soothe           = Spell(2908),
	EntanglingRoots  = Spell(339),
	Hibernate        = Spell(2637),
	Rebirth          = Spell(20484),
	NaturesCure      = Spell(88423),
	Prowl            = Spell(5215),
	
	-- Buff 
	OmenOfClarity    = Spell(113043),
   
    -- Talent
	CenarionWard     = Spell(102351),
	TreeOfLife       = Spell(33891),
	
	
};
local S = RubimRH.Spell[105];

-- Items
if not Item.Druid then
    Item.Druid = {};
end

Item.Druid.Resto = {
    -- Legendaries
    JusticeGaze = Item(137065, { 1 }),
    LiadrinsFuryUnleashed = Item(137048, { 11, 12 }),
    WhisperoftheNathrezim = Item(137020, { 15 })
};
local I = Item.Druid.Resto;
-- Rotation Var

-- APL Action Lists (and Variables)

-- APL Main
local function ShouldDispell()
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

-- Main Rotation start here
local function APL()
    local DPS, Healing
    
	--- Out of Combat    LeftCtrl = IsLeftControlKeyDown();
    HL.GetEnemies("Melee"); -- Melee
    HL.GetEnemies(6, true); --
    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();
    LeftAlt = IsLeftAltKeyDown();

	-- Dps rotation
    DPS = function()
        if S.Sunfire:IsReady() then
            return S.Sunfire:Cast()
        end

        if S.Moonfire:IsReady() then
            return S.Moonfire:Cast()
        end

        if S.SolarWrath:IsReady() then
            return S.SolarWrath:Cast()
        end

        return 0, 135328
    end

	-- Healing rotation
    Healing = function()

        --Tank Emergency Ironbark
        if S.Ironbark:IsCastableP() then
            if LowestAlly("TANK", "HP") <= 25 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 25 then
                return S.Ironbark:Cast()
            end
        end
		
		--Tank Priority Lifebloom
        if S.Lifebloom:IsCastableP() then
            if LowestAlly("TANK", "HP") <= 95 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.Lifebloom:Cast()
            end
        end
		
		--Tank Priority Rejuvenation
        if S.Rejuvenation:IsCastableP() then
            if LowestAlly("TANK", "HP") <= 93 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 93 then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority CenarionWard
        if S.CenarionWard:IsCastableP() then
            if LowestAlly("TANK", "HP") <= 90 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 90 then
                return S.CenarionWard:Cast()
            end
        end

        --16Swiftmend on low allies
        if S.Swiftmend:IsCastableP() then
            --if InjuredAlliesInExplicitRadius(30, true, 0.75) >= 3
            if LowestAlly("ALL", "HP") <= 25 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 25 then
                return S.Swiftmend:Cast()
            end
        end

        --22Efflorescence
        if S.Efflorescence:IsCastableP() and Player:BuffDownP(S.EfflorescenceBuff) and GroupedBelow(90) >= 3 then
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.Efflorescence:Cast()
            end
        end
		
        --21WildGrowth
        if S.WildGrowth:IsCastableP() and GroupedBelow(90) >= 6 then
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.WildGrowth:Cast()
            end
        end



        --23Rejuvenation
        if S.Rejuvenation:IsCastableP() and not Target:Buff(S.Rejuvenation) then
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.Rejuvenation:Cast()
            end
        end

        --24Regrowth
        if S.Regrowth:IsCastableP() and Target:Buff(S.Rejuvenation) then
            if LowestAlly("ALL", "HP") <= 65 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 65 then
                return S.Regrowth:Cast()
            end
        end
		
		--25CenarionWard
        if S.CenarionWard:IsCastableP() and Target:Buff(S.Rejuvenation) then
            if LowestAlly("ALL", "HP") <= 55 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 55 then
                return S.CenarionWard:Cast()
            end
        end

        --26Tranquility
        if S.Tranquility:IsCastableP() and RubimRH.CDsON() and S.WildGrowth:CooldownRemainsP() > 1 then
            if GroupedBelow(50) >= 8 then
                return S.Tranquility:Cast()
            end
        end

        --27Tree of Life
        if S.TreeOfLife:IsAvailable() and RubimRH.CDsON() then
            if GroupedBelow(35) >= 5 then
                return S.TreeOfLife:Cast()
            end
        end
    end

    if MouseOver:HasDispelableDebuff("Magic", "Poison", "Curse") then
        return S.NaturesCure:Cast()
    end

    if Player:IsChanneling() or Player:IsCasting() then
        return 0, 236353
    end

    if Player:CanAttack(Target) then
        return DPS()
    end

    if Healing() ~= nil then
        return Healing()
    end

    return 0, 135328
end

RubimRH.Rotation.SetAPL(105, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(105, PASSIVE)