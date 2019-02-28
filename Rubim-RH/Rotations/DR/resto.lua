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

};
local S = RubimRH.Spell[105]

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
    local DPS = function()
        if S.Sunfire:IsReady(40) then
            return S.Sunfire:Cast()
        end

        if S.Moonfire:IsReady(40) then
            return S.Moonfire:Cast()
        end

        if S.SolarWrath:IsReady(40) then
            return S.SolarWrath:Cast()
        end

        return 0, 135328
    end

	-- Healing rotation
    local Healing = function()

        --Tank Emergency Ironbark
        if S.Ironbark:IsCastableP() then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and CanUse(HolyShock)
            if LowestAlly("TANK", "HP") <= 25 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 25 then
                return S.Ironbark:Cast()
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


        --21WildGrowth
        if S.WildGrowth:IsCastableP() and GroupedBelow(90) >= 6 then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and CanUse(HolyShock)
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.WildGrowth:Cast()
            end
        end

        --22Efflorescence
        if S.Efflorescence:IsCastableP() and Player:BuffDownP(S.EfflorescenceBuff) and GroupedBelow(90) >= 3 then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and CanUse(HolyShock)
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.Efflorescence:Cast()
            end
        end

        --23Flash of Light
        if S.FlashofLight:IsCastableP() and S.HolyShock:IsCastableP() and not Target:Buff(S.BeaconofLight) and not Target:Buff(S.BeaconofVirtue) then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and AllyHealthPercent < 0.65 and CanUse(HolyShock)
            if LowestAlly("ALL", "HP") <= 65 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 65 then
                return S.FlashofLight:Cast()
            end
        end

        --24HolyLight
        if S.HolyLight:IsCastableP() and Player:Buff(S.InfusionofLight) and S.HolyShock:IsCastableP() and not Target:Buff(S.BeaconofLight) and not Target:Buff(S.BeaconofVirtue) then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and CanUse(HolyShock)
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.HolyLight:Cast()
            end
        end

        --25HolyShock
        if S.HolyShock:IsCastableP() and not Target:Buff(S.BeaconofLight) and not Target:Buff(S.BeaconofVirtue) then
            --if not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith)
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:Exists() and Target:HealthPercentage() < 95 then
                return S.HolyShock:Cast()
            end

        end

        --26Light's Hammer
        if S.LightsHammer:IsAvailable() and S.LightsHammer:IsCastableP() then
            if GroupedBelow(75) >= 3 then
                return S.LightsHammer:Cast()
            end
        end

        --27Holy Prism
        if S.HolyPrism:IsAvailable() and S.HolyPrism:IsCastableP() then
            if GroupedBelow(75) >= 3 then
                return S.HolyPrism:Cast()
            end
        end

        --28Bestow Faith
        if S.BestowFaith:IsAvailable() and S.BestowFaith:IsCastableP() then
            if LowestAlly("TANK", "HP") <= 99 then
                ForceHealingTarget("TANK")
            end
            if Target:GUID() == LowestAlly("TANK", "GUID") then
                return S.BestowFaith:Cast()
            end
        end

        --29Holy Light
        if S.HolyLight:IsCastableP() and Player:Buff(S.InfusionofLight) and not Target:Buff(S.BeaconofLight) and not Target:Buff(S.BeaconofVirtue) then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and AllyHealthPercent < 0.9
            if LowestAlly("ALL", "HP") <= 90 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() < 90 then
                return S.HolyLight:Cast()
            end
        end

        --30Light of the Martyr
        if S.LightoftheMartyr:IsCastableP() and Player:HealthPercentage() > 75 then
            if LowestAlly("ALL", "HP") <= 65 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() < 65 then
                return S.LightoftheMartyr:Cast()
            end
        end

        --31Flash of Light
        if S.FlashofLight:IsCastableP() then
            if LowestAlly("ALL", "HP") <= 65 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 65 then
                return S.FlashofLight:Cast()
            end
        end

        --32Judgment
        if Player:CanAttack(Target) and S.Judgement:IsReady() and S.JudgementofLight:IsAvailable() then
            return S.Judgement:Cast()
        end

        --33Judgment
        if Player:CanAttack(Target) and S.Judgement:IsReady() and S.GraveofJusticar:AzeriteEnabled() then
            return S.Judgement:Cast()
        end

        --34Crusader Strike
        if Player:CanAttack(Target) and S.CrusaderStrike:IsReady() and S.CrusadersMight:IsAvailable() then
            return S.CrusaderStrike:Cast()
        end

        --35 Holy Light
        if S.HolyLight:IsCastableP() then
            if LowestAlly("ALL", "HP") <= 85 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 85 then
                return S.HolyLight:Cast()
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
RubimRH.Rotation.SetAPL(65, APL);

local function PASSIVE()
    if S.DivineProtection:IsCastableP() and Player:HealthPercentage() <= RubimRH.db.profile[65].sk1 then
        return S.DivineProtection:Cast()
    end

    if S.DivineShield:IsCastableP() and Player:HealthPercentage() <= RubimRH.db.profile[65].sk2 and not Player:Debuff(S.Forbearance) then
        return S.DivineShield:Cast()
    end

    if S.LayOnHands:IsCastableP() and Player:HealthPercentage() <= RubimRH.db.profile[65].sk3 and not Player:Debuff(S.Forbearance) then
        return S.LayOnHands:Cast()
    end

    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(65, PASSIVE);