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
	GlimmerofLight = Spell(287268),
	
	--Heart Essences
	ConcentratedFlameHeal = Spell(295373),
	ConcentratedFlameHeal2 = Spell(168612),
	ConcentratedFlameHeal3 = Spell(168613),
	LifeBindersInvocation = Spell(293032),
	LifeBindersInvocation2 = Spell(299943),
	LifeBindersInvocation3 = Spell(299944),
	OverchargeMana = Spell(296072),
	OverchargeMana2 = Spell(299875),
	OverchargeMana3 = Spell(299876),
	Refreshment = Spell(296197),
	Refreshment2 = Spell(299932),
	Refreshment3 = Spell(299933),
	UnleashHeartofAzeroth = Spell(280431),
	VitalityConduit = Spell(296230),
	VitalityConduit2 = Spell(299958),
	VitalityConduit3 = Spell(299959),
	MemoryOfLucidDreams = Spell(298357),
	MemoryOfLucidDreams2 = Spell(299372),
	MemoryOfLucidDreams3 = Spell(299374),

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

local function DetermineEssenceRanks()
	S.ConcentratedFlameHeal = S.ConcentratedFlameHeal2:IsAvailable() and S.ConcentratedFlameHeal2 or S.ConcentratedFlameHeal;
	S.ConcentratedFlameHeal = S.ConcentratedFlameHeal3:IsAvailable() and S.ConcentratedFlameHeal3 or S.ConcentratedFlameHeal;
	S.LifeBindersInvocation = S.LifeBindersInvocation2:IsAvailable() and S.LifeBindersInvocation2 or S.OverchargeMana;
	S.LifeBindersInvocation = S.LifeBindersInvocation3:IsAvailable() and S.LifeBindersInvocation3 or S.OverchargeMana;
	S.OverchargeMana = S.OverchargeMana2:IsAvailable() and S.OverchargeMana2 or S.OverchargeMana;
	S.OverchargeMana = S.OverchargeMana3:IsAvailable() and S.OverchargeMana3 or S.OverchargeMana;
	S.Refreshment = S.Refreshment2:IsAvailable() and S.Refreshment2 or S.Refreshment;
	S.Refreshment = S.Refreshment3:IsAvailable() and S.Refreshment3 or S.Refreshment;
	S.OverchargeMana = S.OverchargeMana2:IsAvailable() and S.OverchargeMana2 or S.OverchargeMana;
	S.OverchargeMana = S.OverchargeMana3:IsAvailable() and S.OverchargeMana3 or S.OverchargeMana;
	S.MemoryOfLucidDreams = S.MemoryOfLucidDreams2:IsAvailable() and S.MemoryOfLucidDreams2 or S.MemoryOfLucidDreams;
	S.MemoryOfLucidDreams = S.MemoryOfLucidDreams3:IsAvailable() and S.MemoryOfLucidDreams3 or S.MemoryOfLucidDreams;
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

		if S.Judgement:IsCastable(30) and not Player:Buff(S.AvengingCrusader) then
			return S.Judgement:Cast()
		end

		if S.HolyShock:IsCastable(40) and not Player:Buff(S.AvengingCrusader) then
			return S.HolyShock:Cast()
		end
		
		if S.CrusaderStrike:IsCastable("Melee") and not Player:Buff(S.AvengingCrusader) then
			return S.CrusaderStrike:Cast()
		end
		
		if S.Consecration:IsCastable("Melee") and not Player:Buff(S.AvengingCrusader) and not Target:Debuff(S.ConsecrationUp) then
			return S.Consecration:Cast()
		end
		
		if S.Judgement:IsCastable(30) and Player:Buff(S.AvengingCrusader) then
			return S.Judgement:Cast()
		end

		if S.CrusaderStrike:IsCastable() and Player:Buff(S.AvengingCrusader) then
			return S.CrusaderStrike:Cast()
		end

        return 0, 135328
    end

    local Healing = function()
	
		DetermineEssenceRanks()
	
		--Save yourself
		if S.DivineShield:IsCastable() and Player:HealthPercentage() <= RubimRH.db.profile[65].sk2 and not Player:Debuff(S.Forbearance) then
			return S.DivineShield:Cast()
		end	

        --Tank Emergency
        if S.LayOnHands:IsCastable() and not Target:Debuff(S.Forbearance) then
            if LowestAlly("TANK", "HP") < RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["tank_layonhands"]["value"] then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:HealthPercentage() < RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["tank_layonhands"]["value"] then
                return S.LayOnHands:Cast()
            end
        end

		--Dispell
		--if not Player:CanAttack(Target) and S.Cleanse:IsCastable() and Target:HasDispelableDebuff("Magic", "Poison", "Disease") then
			--return S.Cleanse:Cast()
		--end

        --Manuel Cooldown and not Glimmer of Light
		if RubimRH.CDsON() and not S.GlimmerofLight:AzeriteEnabled(3) then
		if S.AvengingWrath:IsCastable() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.HolyAvenger) then
            return S.AvengingWrath:Cast()
        end

		if S.AvengingCrusader:IsCastable() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.HolyAvenger) then
            return S.AvengingCrusader:Cast()
        end		
		
		if S.HolyAvenger:IsCastable() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.AvengingWrath) and not Player:Buff(S.AvengingCrusader) then
            return S.HolyAvenger:Cast()
        end

		if S.AuraMastery:IsCastable() and not Player:Buff(S.AvengingWrath) and not Player:Buff(S.AvengingCrusader) and not Player:Buff(S.HolyAvenger) then
			return S.AuraMastery:Cast()
		end
		
		if S.LifeBindersInvocation:IsCastable() and RubimRH.AoEHP(85) >= 5 then
			return S.UnleashHeartofAzeroth:Cast()
		end
		
		if S.OverchargeMana:IsCastable() then
			return S.UnleashHeartofAzeroth:Cast()
		end
		end
		
		if S.MemoryOfLucidDreams:IsCastable() and Player:Mana() < Player:ManaMax() * 0.85 then
			return S.UnleashHeartofAzeroth:Cast()
		end
		
		--Manuel Cooldown and Glimmer of Light
		if RubimRH.CDsON() and S.GlimmerofLight:AzeriteEnabled(3) then
		    if S.AvengingWrath:IsCastable() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.HolyAvenger) then
                return S.AvengingWrath:Cast()
            end
		
		    if S.HolyAvenger:IsCastable() and not Player:Buff(S.AuraMastery) then
                return S.HolyAvenger:Cast()
            end

		    if S.AuraMastery:IsCastable() and not Player:Buff(S.AvengingWrath) and not Player:Buff(S.AvengingCrusader) and not Player:Buff(S.HolyAvenger) then
		    	return S.AuraMastery:Cast()
		    end
		
		    if S.LifeBindersInvocation:IsCastable() and RubimRH.AoEHP(85) >= 5 then
		    	return S.UnleashHeartofAzeroth:Cast()
		    end
		
		    if S.OverchargeMana:IsCastable() then
		    	return S.UnleashHeartofAzeroth:Cast()
		    end
		end
		
		if S.MemoryOfLucidDreams:IsCastable() and Player:Mana() < Player:ManaMax() * 0.85 then
			return S.UnleashHeartofAzeroth:Cast()
		end

        --Beacon of Virtue
        if S.BeaconofVirtue:IsCastable() and RubimRH.AoEHP(85) >= 3 then
			return S.BeaconofVirtue:Cast()
		end

        --Light of Dawn
        if S.LightofDawn:IsCastable() and RubimRH.AoEHP(RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_lightofdawn"]["value"]) >= 3 then
			return S.LightofDawn:Cast()
        end

		--Holy Shock
        if S.HolyShock:IsCastable() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_holyshock"]["value"] then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() < RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_holyshock"]["value"] then
                return S.HolyShock:Cast()
            end

        end

        --Judgment Of Light
        if RubimRH.AoEON() and S.Judgement:IsCastable() and S.JudgementofLight:IsAvailable() then
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end
			
            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 95 then
                return S.Judgement:Cast()
            end
        end
		
        --Bestow Faith
        if S.BestowFaith:IsAvailable() and S.BestowFaith:IsCastable() then
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end
            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 95 then
                return S.BestowFaith:Cast()
            end
        end
		
		--Concentrated Flame Heal
        if S.ConcentratedFlameHeal:IsCastable() then
            if LowestAlly("ALL", "HP") <= 75 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 75 then
                return S.UnleashHeartofAzeroth:Cast()
            end
        end
		
		--Vitality Conduit
        if S.VitalityConduit:IsCastable() then
            if LowestAlly("TANK", "HP") <= 75 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:HealthPercentage() <= 75 then
                return S.UnleashHeartofAzeroth:Cast()
            end
        end
		
        --Flash of Light
        if S.FlashofLight:IsCastable() and not Player:IsMoving() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_flashlight"]["value"] then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_flashlight"]["value"] then
                return S.FlashofLight:Cast()
            end
        end

        --Crusader Strike
        if S.CrusaderStrike:IsReady() and S.CrusadersMight:IsAvailable() and not S.HolyShock:IsReady() and Player:AffectingCombat() then
            return S.CrusaderStrike:Cast()
        end

        --Holy Light
        if S.HolyLight:IsCastable() and not Player:IsMoving() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_holylight"]["value"] then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_holylight"]["value"] then
                return S.HolyLight:Cast()
            end
        end
		
        --Light of the Martyr
        if S.LightoftheMartyr:IsCastable() and Player:IsMoving() and Player:HealthPercentage() > 75 then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_martyr"]["value"] then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() < RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_martyr"]["value"] then
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
	
    if not UnitIsDead("target") and Player:CanAttack(Target) then
        return DPS()
    end

    if Healing() ~= nil then
        return Healing()
    end

    return 0, 135328
end
RubimRH.Rotation.SetAPL(65, APL);

local function PASSIVE()

    if S.DivineShield:IsCastable() and Player:HealthPercentage() <= RubimRH.db.profile[65].sk2 and not Player:Debuff(S.Forbearance) then
        return S.DivineShield:Cast()
    end

    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(65, PASSIVE);