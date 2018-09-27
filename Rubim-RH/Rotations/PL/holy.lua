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
    LightsHammer = Spell(114158),
    HolyPrism = Spell(114165),
    BestowFaith = Spell(223306),
    JudgementofLight = Spell(183778),
    AvengingCrusade = Spell(216331),
    CrusadersMight = Spell(196926),
    Cleanse = Spell(4987),
    Judgement = Spell(275773),
    CrusaderStrike = Spell(35395),
    Consecration = Spell(26573),
    LightoftheMartyr = Spell(183998),
    LightoftheMartyrStack = Spell(223316),
    FlashofLight = Spell(19750),
    HolyShock = Spell(20473),
    InfusionofLight = Spell(53576),
    BeaconofLight = Spell(53563),
    BeaconofVirtue = Spell(200025),
    LightofDawn = Spell(85222),

    --Azerite
    DivineRevelations = Spell(275469),
    GraveofJusticar = Spell(278593),

    --Healing
    BlessingofProtection = Spell(1022),
    HolyLight = Spell(82326),


    LayOnHands = Spell(633),
    Forbearance = Spell(25771),
    DivineProtection = Spell(498),
    DivineShield = Spell(642),
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
    local DPS, Healing
    --- Out of Combat    LeftCtrl = IsLeftControlKeyDown();
    HL.GetEnemies("Melee"); -- Melee
    HL.GetEnemies(6, true); --
    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();
    LeftAlt = IsLeftAltKeyDown();

    local DPS = function()
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
        return 0, 135328
    end

    local Healing = function()

        --Tank Emergency
        if S.LayOnHands:IsCastableP() then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and CanUse(HolyShock)
            if LowestAlly("TANK", "HP") <= 25 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:HealthPercentage() <= 25 then
                return S.LayOnHands:Cast()
            end
        end

        --Blessing on Low Ally
        if S.BlessingofProtection:IsCastableP() then
            if LowestAlly("ALL", "HP") <= 30 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 30 then
                return S.BlessingofProtection:Cast()
            end

        end

        --14Judgment
        if Player:CanAttack(Target) and S.Judgement:IsReady() and Player:Buff(S.AvengingCrusade) then
            return S.Judgement:Cast()
        end

        --15 Crusader Strike
        if Player:CanAttack(Target) and S.CrusaderStrike:IsReady() and Player:Buff(S.AvengingCrusade) then
            return S.CrusaderStrike:Cast()
        end

        --16Beacon of Virtue
        if S.BeaconofVirtue:IsCastableP() then
            --if InjuredAlliesInExplicitRadius(30, true, 0.75) >= 3
            if GroupedBelow(75) >= 3 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") then
                return S.BeaconofVirtue:Cast()
            end
        end

        --17Aura Mastery
        --18Avenging Wrath
        --19Avenging Crusader
        --20Holy Avenger
        --21Light of Dawn
        if S.LightofDawn:IsCastableP() and GroupedBelow(85) >= 3 then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and CanUse(HolyShock)
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 95 then
                return S.LightofDawn:Cast()
            end
        end

        --22HolyLight
        --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith)
        if S.HolyLight:IsCastableP() and S.DivineRevelations:AzeriteEnabled() and  Player:Buff(S.InfusionofLight) and S.HolyShock:IsCastableP() and not Target:Buff(S.BeaconofLight) and not Target:Buff(S.BeaconofVirtue) then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and CanUse(HolyShock)
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 95 then
                return S.HolyLight:Cast()
            end
        end

        --23Flash of Light
        if S.FlashofLight:IsCastableP() and S.HolyShock:IsCastableP() and not Target:Buff(S.BeaconofLight) and not Target:Buff(S.BeaconofVirtue) then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and AllyHealthPercent < 0.65 and CanUse(HolyShock)
            if LowestAlly("ALL", "HP") <= 65 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 65 then
                return S.FlashofLight:Cast()
            end


        end

        --24HolyLight
        if S.HolyLight:IsCastableP() and Player:Buff(S.InfusionofLight) and S.HolyShock:IsCastableP() and not Target:Buff(S.BeaconofLight) and not Target:Buff(S.BeaconofVirtue) then
            --if HasBuff(InfusionOfLight) and not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith) and CanUse(HolyShock)
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 95 then
                return S.HolyLight:Cast()
            end
        end

        --25HolyShock
        if S.HolyShock:IsCastableP() and not Target:Buff(S.BeaconofLight) and not Target:Buff(S.BeaconofVirtue) then
            --if not HasBuff(BeaconOfLight) and not HasBuff(BeaconOfFaith)
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() < 95 then
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
            ForceHealingTarget("TANK")
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

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() < 90 then
                return S.HolyLight:Cast()
            end
        end

        --30Light of the Martyr
        if S.LightoftheMartyr:IsCastableP() and Player:HealthPercentage() > 75 then
            if LowestAlly("ALL", "HP") <= 65 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID")  and Target:HealthPercentage() < 65 then
                return S.LightoftheMartyr:Cast()
            end
        end

        --31Flash of Light
        if S.FlashofLight:IsCastableP() then
            if LowestAlly("ALL", "HP") <= 65 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 65 then
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

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 85 then
                return S.HolyLight:Cast()
            end
        end

    end

    if Player:IsChanneling() or Player:IsCasting() then
        return 0, 236353
    end

    if Player:CanAttack(Target) then
        ForceHealingTarget("None")
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