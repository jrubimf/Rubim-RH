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
    HolyShock = Spell(20473),
    InfusionofLight = Spell(54149),
    BeaconofLight = Spell(53563),
    BeaconofVirtue = Spell(200025),
    LightofDawn = Spell(85222),
	AuraMastery = Spell(31821),
	AvengingWrath = Spell(31884),
	HolyAvenger = Spell(105809),
	BestowFaith = Spell(223306),
	AvengingCrusader = Spell(216331),
	JudgmentOfLightHoly = Spell(183778),
	BlessingOfSacrifice = Spell(6940),
	BeaconOfFaith = Spell(156910),
	JudgementofLight = Spell(183778),
	CrusadersMight = Spell(196926),
	ConsecrationUp = Spell(204242),
	JudgmentUp = Spell(214222),
	HolyPrism = Spell(114165),

    --Azerite
    DivineRevelations = Spell(275469),
	
	--Heart Essences
	UnleashHeartofAzeroth = Spell(280431),
	ConcentratedFlameHeal = Spell(295375),
	VitalityConduit = Spell(299959),
	Refreshment = Spell(299933),

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

		if S.Judgement:IsCastableP(30) and not Player:Buff(S.AvengingCrusader) then
			return S.Judgement:Cast()
		end

		if S.HolyShock:IsCastableP(40) and not Player:Buff(S.AvengingCrusader) then
			return S.HolyShock:Cast()
		end
		
		if S.CrusaderStrike:IsCastableP("Melee") and not Player:Buff(S.AvengingCrusader) then
			return S.CrusaderStrike:Cast()
		end
		
		if S.Consecration:IsCastableP("Melee") and not Player:Buff(S.AvengingCrusader) and not Target:Debuff(S.ConsecrationUp) then
			return S.Consecration:Cast()
		end
		
		if S.Judgement:IsCastableP(30) and Player:Buff(S.AvengingCrusader) then
			return S.Judgement:Cast()
		end

		if S.CrusaderStrike:IsCastableP() and Player:Buff(S.AvengingCrusader) then
			return S.CrusaderStrike:Cast()
		end
		

        return 0, 135328
    end

    local Healing = function()
	
		--Save yourself
		if S.DivineShield:IsCastableP() and Player:HealthPercentage() <= RubimRH.db.profile[65].sk2 and not Player:Debuff(S.Forbearance) then
			return S.DivineShield:Cast()
		end	

        --Tank Emergency
        if S.LayOnHands:IsCastableP() and not Target:Debuff(S.Forbearance) then
            if LowestAlly("TANK", "HP") < 25 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:HealthPercentage() < 25 then
                return S.LayOnHands:Cast()
            end
        end

		--Dispell
		--if not Player:CanAttack(Target) and S.Cleanse:IsCastableP() and Target:HasDispelableDebuff("Magic", "Poison", "Disease") then
			--return S.Cleanse:Cast()
		--end

        --BURST HEAL
		if RubimRH.CDsON() and S.AvengingWrath:IsCastableP() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.HolyAvenger) then
            return S.AvengingWrath:Cast()
        end

		if RubimRH.CDsON() and S.AvengingCrusader:IsCastableP() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.HolyAvenger) then
            return S.AvengingCrusader:Cast()
        end		
		
		if RubimRH.CDsON() and S.HolyAvenger:IsCastableP() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.AvengingWrath) and not Player:Buff(S.AvengingCrusader) then
            return S.HolyAvenger:Cast()
        end

		if RubimRH.CDsON() and S.AuraMastery:IsCastableP() and not Player:Buff(S.AvengingWrath) and not Player:Buff(S.AvengingCrusader) and not Player:Buff(S.HolyAvenger) then
			return S.AuraMastery:Cast()
		end

        --Beacon of Virtue
        if S.BeaconofVirtue:IsCastableP() and GroupedBelow(85) >= 3 then
			return S.BeaconofVirtue:Cast()
		end

        --Light of Dawn
        if S.LightofDawn:IsCastableP() and GroupedBelow(85) >= 3 then
			return S.LightofDawn:Cast()
        end


		--Holy Shock
        if S.HolyShock:IsCastableP() then
            if LowestAlly("ALL", "HP") <= 90 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() < 90 then
                return S.HolyShock:Cast()
            end

        end

        --Judgment Of Light
        if RubimRH.AoEON() and S.Judgement:IsCastableP() and S.JudgementofLight:IsAvailable() then
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end
			
            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 95 then
                return S.Judgement:Cast()
            end
        end
		
        --Bestow Faith
        if S.BestowFaith:IsAvailable() and S.BestowFaith:IsCastableP() then
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end
            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 95 then
                return S.BestowFaith:Cast()
            end
        end
		
		--Concentrated Flame Heal
        if S.ConcentratedFlameHeal:IsCastableP() and not Player:IsMoving() then
            if LowestAlly("ALL", "HP") <= 75 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 75 then
                return S.UnleashHeartofAzeroth:Cast()
            end
        end
		
		--Vitality Conduit
        if S.VitalityConduit:IsCastableP() and not Player:IsMoving() then
            if LowestAlly("TANK", "HP") <= 75 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:HealthPercentage() <= 75 then
                return S.UnleashHeartofAzeroth:Cast()
            end
        end
		
		--Refreshment
        if S.Refreshment:IsCastableP() and not Player:IsMoving() then
            if LowestAlly("ALL", "HP") <= 75 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 75 then
                return S.UnleashHeartofAzeroth:Cast()
            end
        end
		
        --Flash of Light
        if S.FlashofLight:IsCastableP() and not Player:IsMoving() then
            if LowestAlly("ALL", "HP") <= 75 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 75 then
                return S.FlashofLight:Cast()
            end
        end

        --Crusader Strike
        if S.CrusaderStrike:IsReady() and S.CrusadersMight:IsAvailable() then
            return S.CrusaderStrike:Cast()
        end

        --Holy Light
        if S.HolyLight:IsCastableP() and not Player:IsMoving() then
            if LowestAlly("ALL", "HP") <= 90 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 90 then
                return S.HolyLight:Cast()
            end
        end
		
        --Light of the Martyr
        if S.LightoftheMartyr:IsCastableP() and Player:IsMoving() and Player:HealthPercentage() > 75 then
            if LowestAlly("ALL", "HP") <= 75 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() < 75 then
                return S.LightoftheMartyr:Cast()
            end
        end

    end
	
    if QueueSkill() ~= nil then
		return QueueSkill()
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

    if S.DivineShield:IsCastableP() and Player:HealthPercentage() <= RubimRH.db.profile[65].sk2 and not Player:Debuff(S.Forbearance) then
        return S.DivineShield:Cast()
    end

    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(65, PASSIVE);