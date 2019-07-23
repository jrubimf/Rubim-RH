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
	LightsHammer = Spell(114158),

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
    -- Raid
	DarkestDepths = Spell(292127),
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
    WhisperoftheNathrezim = Item(137020, { 15 }),
	RevitalizingVoodooTotem = Item(158320, { 14 })
};
local I = Item.Paladin.Holy;
-- Rotation Var

-- APL Action Lists (and Variables)
local function BadDebuffOnTarget()    
    local DarkestDepths = Spell(292127)
	
	if Target:DebuffRemainsP(DarkestDepths) > 0 then 
        return true
    end
    return false
end	

-- Trinket var
local trinket2 = 1030910
local trinket1 = 1030902

-- Trinket Ready
local function trinketReady(trinketPosition)
    local inventoryPosition
    
	if trinketPosition == 1 then
        inventoryPosition = 13
    end
    
	if trinketPosition == 2 then
        inventoryPosition = 14
    end
    
	local start, duration, enable = GetInventoryItemCooldown("Player", inventoryPosition)
    if enable == 0 then
        return false
    end

    if start + duration - GetTime() > 0 then
        return false
    end
	
	if RubimRH.db.profile.mainOption.useTrinkets[1] == false then
	    return false
	end
	
   	if RubimRH.db.profile.mainOption.useTrinkets[2] == false then
	    return false
	end	
	
    if RubimRH.db.profile.mainOption.trinketsUsage == "Everything" then
        return true
    end
	
	if RubimRH.db.profile.mainOption.trinketsUsage == "Boss Only" then
        if not UnitExists("boss1") then
            return false
        end

        if UnitExists("target") and not (UnitClassification("target") == "worldboss" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "rare") then
            return false
        end
    end	
    return true
end

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

		if S.Judgement:IsReady(30) and not Player:Buff(S.AvengingCrusader) then
			return S.Judgement:Cast()
		end

		if S.HolyShock:IsReady(40) and not Player:Buff(S.AvengingCrusader) then
			return S.HolyShock:Cast()
		end
		
		if S.CrusaderStrike:IsReady("Melee") and not Player:Buff(S.AvengingCrusader) then
			return S.CrusaderStrike:Cast()
		end
		
		if S.Consecration:IsReady("Melee") and not Player:Buff(S.AvengingCrusader) and not Target:Debuff(S.ConsecrationUp) then
			return S.Consecration:Cast()
		end
		
		if S.Judgement:IsReady(30) and Player:Buff(S.AvengingCrusader) then
			return S.Judgement:Cast()
		end

		if S.CrusaderStrike:IsReady() and Player:Buff(S.AvengingCrusader) then
			return S.CrusaderStrike:Cast()
		end

        return 0, 135328
    end

    local Healing = function()
	
		DetermineEssenceRanks()
	
		--Save yourself
		if S.DivineShield:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["divine_shield"]["value"] and not Player:Debuff(S.Forbearance) then
			return S.DivineShield:Cast()
		end	

        --Tank Emergency
        if S.LayOnHands:IsReady() and not Target:Debuff(S.Forbearance) then
            if LowestAlly("TANK", "HP") < RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["tank_layonhands"]["value"] then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:HealthPercentage() < RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["tank_layonhands"]["value"] then
                return S.LayOnHands:Cast()
            end
        end
		
		--Custom Beacon
        if S.BeaconofLight:IsReady() and not Target:BuffRemainsP(S.BeaconofLight) then
            if LowestAlly(RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["beacon_option"]["value"], "HP") < 99 then
                ForceHealingTarget(RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["beacon_option"]["value"])
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly(RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["beacon_option"]["value"], "GUID") and Target:HealthPercentage() < 99 then
                return S.BeaconofLight:Cast()
            end
        end
		--Dispell
		--if not Player:CanAttack(Target) and S.Cleanse:IsReady() and Target:HasDispelableDebuff("Magic", "Poison", "Disease") then
			--return S.Cleanse:Cast()
		--end

    --Manuel Cooldown and not Glimmer of Light
	if RubimRH.CDsON() and not S.GlimmerofLight:AzeriteEnabled(3) then
		if S.AvengingWrath:IsReady() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.HolyAvenger) then
            return S.AvengingWrath:Cast()
        end

		if S.AvengingCrusader:IsReady() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.HolyAvenger) then
            return S.AvengingCrusader:Cast()
        end		
		
		if S.HolyAvenger:IsReady() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.AvengingWrath) and not Player:Buff(S.AvengingCrusader) then
            return S.HolyAvenger:Cast()
        end

		if S.AuraMastery:IsReady() and not Player:Buff(S.AvengingWrath) and not Player:Buff(S.AvengingCrusader) and not Player:Buff(S.HolyAvenger) then
			return S.AuraMastery:Cast()
		end
		
		if S.LifeBindersInvocation:IsReady() and RubimRH.AoEHP(85) >= 5 then
			return S.UnleashHeartofAzeroth:Cast()
		end
		
		if S.OverchargeMana:IsReady() then
			return S.UnleashHeartofAzeroth:Cast()
		end
	end
		
		if S.MemoryOfLucidDreams:IsReady() and Player:Mana() < Player:ManaMax() * 0.85 then
			return S.UnleashHeartofAzeroth:Cast()
		end
		
	--Manuel Cooldown and Glimmer of Light
	if RubimRH.CDsON() and S.GlimmerofLight:AzeriteEnabled(3) then
		if S.AvengingWrath:IsReady() and not Player:Buff(S.AuraMastery) and not Player:Buff(S.HolyAvenger) then
            return S.AvengingWrath:Cast()
        end
		
		if S.HolyAvenger:IsReady() and not Player:Buff(S.AuraMastery) then
            return S.HolyAvenger:Cast()
        end

		if S.AuraMastery:IsReady() and not Player:Buff(S.AvengingWrath) and not Player:Buff(S.AvengingCrusader) and not Player:Buff(S.HolyAvenger) then
			return S.AuraMastery:Cast()
		end
		
		if S.LifeBindersInvocation:IsReady() and RubimRH.AoEHP(85) >= 5 then
			return S.UnleashHeartofAzeroth:Cast()
		end
		
		if S.OverchargeMana:IsReady() then
			return S.UnleashHeartofAzeroth:Cast()
		end
	end
		
		if S.MemoryOfLucidDreams:IsReady() and Player:Mana() < Player:ManaMax() * 0.85 then
			return S.UnleashHeartofAzeroth:Cast()
		end
		
		--AuraMastery settings
        if S.AuraMastery:IsReady() and RubimRH.CDsON() and not Player:Buff(S.AvengingWrath) and not Player:Buff(S.AvengingCrusader) and not Player:Buff(S.HolyAvenger) then
            if RubimRH.AoEHP(RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["health_auramastery"]["value"]) >= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["nb_auramastery"]["value"] then
                return S.AuraMastery:Cast()
            end
        end
		
		--Use Trinkets
        --if I.RevitalizingVoodooTotem:IsReady() then
            --if LowestAlly("TANK", "HP") < 75 then
                --ForceHealingTarget("TANK")
            --end
            --if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:HealthPercentage() < 75 then
                --return S.GiftoftheNaaru:Cast()
            --end
        --end

        --Beacon of Virtue
        if S.BeaconofVirtue:IsReady() and RubimRH.AoEHP(85) >= 3 then
			return S.BeaconofVirtue:Cast()
		end

        --Light of Dawn
        if S.LightofDawn:IsReady() and RubimRH.AoEHP(85) >= 3 then
			return S.LightofDawn:Cast()
        end

		--Holy Shock
        if S.HolyShock:IsReady() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_holyshock"]["value"] then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_holyshock"]["value"] then
                return S.HolyShock:Cast()
            end

        end

        --Judgment Of Light
        if RubimRH.AoEON() and S.Judgement:IsReady() and S.JudgementofLight:IsAvailable() and Player:AffectingCombat() then
            return S.Judgement:Cast()
        end
		
		if RubimRH.AoEON() and S.LightsHammer:IsReady() and RubimRH.AoEHP(75) >= 5 then
			return S.LightsHammer:Cast()
		end
		
		--Holy Prism
		if RubimRH.AoEON() and S.HolyPrism:IsReady() and RubimRH.AoEHP(75) >= 3 then
			return S.HolyPrism:Cast()
		end
		
        --Bestow Faith
        if S.BestowFaith:IsAvailable() and S.BestowFaith:IsReady() then
            if LowestAlly("TANK", "HP") <= 95 then
                ForceHealingTarget("TANK")
            end
            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:HealthPercentage() <= 95 then
                return S.BestowFaith:Cast()
            end
        end
		
		--Concentrated Flame Heal
        if S.ConcentratedFlameHeal:IsReady() then
            if LowestAlly("ALL", "HP") <= 75 then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= 75 then
                return S.UnleashHeartofAzeroth:Cast()
            end
        end
		
		--Vitality Conduit
        if S.VitalityConduit:IsReady() then
            if LowestAlly("TANK", "HP") <= 75 then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:HealthPercentage() <= 75 then
                return S.UnleashHeartofAzeroth:Cast()
            end
        end
		
        --Flash of Light
        if S.FlashofLight:IsReady() and not Player:IsMoving() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_flashlight"]["value"] then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_flashlight"]["value"] then
                return S.FlashofLight:Cast()
            end
        end

        --Crusader Strike
        if RubimRH.AoEON() and S.CrusaderStrike:IsReady() and S.CrusadersMight:IsAvailable() and not S.HolyShock:IsReady() and Player:AffectingCombat() then
            return S.CrusaderStrike:Cast()
        end

        --Holy Light
        if S.HolyLight:IsReady() and not Player:IsMoving() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_holylight"]["value"] then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_holylight"]["value"] then
                return S.HolyLight:Cast()
            end
        end
		
        --Light of the Martyr
        if S.LightoftheMartyr:IsReady() and Player:IsMoving() and Player:HealthPercentage() > 75 then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_martyr"]["value"] then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:HealthPercentage() < RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["raid_martyr"]["value"] then
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

    if S.DivineShield:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[65][RubimRH.db.profile.mainOption.selectedProfile]["divine_shield"]["value"] and not Player:Debuff(S.Forbearance) then
        return S.DivineShield:Cast()
    end

    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(65, PASSIVE);