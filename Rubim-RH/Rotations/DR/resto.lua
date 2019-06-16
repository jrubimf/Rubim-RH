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
local mainAddon = RubimRH

--- APL Local Vars
-- Spells
RubimRH.Spell[105] = {
    -- Racials
    ArcaneTorrent    = Spell(25046),
    GiftoftheNaaru   = Spell(59547),
	Berserking       = Spell(26297),

    -- Spells
    Rejuvenation     = Spell(774),
    RejuvenationGerm = Spell(155777),
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
	SunfireDebuff     = Spell(164815),
	MoonfireDebuff    = Spell(164812),
	Germination       = Spell(155675),
	
	
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

-- PvE
local function PvESoothe(unit)
    -- https://questionablyepic.com/bfa-dungeon-debuffs/
    return RubimRH.Buffs(unit, {
            228318, -- Raging (Raging Affix)
            255824, -- Fanatic's Rage (Dazar'ai Juggernaut)
            257476, -- Bestial Wrath (Irontide Mastiff)
            269976, -- Ancestral Fury (Shadow-Borne Champion)
            262092, -- Inhale Vapors (Addled Thug)
            272888, -- Ferocity (Ashvane Destroyer)
            259975, -- Enrage (The Sand Queen)
            265081, -- Warcry (Chosen Blood Matron)
            266209, -- Wicked Frenzy (Fallen Deathspeaker)
    })>2
end

--local RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile] = RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]
--RubimRH.db.profile[64].sk1
-- Restoration

-- Get averange inc dmg/heal for raid/group
RubimRH.gHE = {}
local gHEupdate = CreateFrame("Frame")
gHEupdate:SetScript("OnUpdate", function (self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed;
        if (self.elapsed >= 1 and RubimRH.playerSpec == 105) then
            table.insert(RubimRH.gHE, {DMG = Group_incDMG(), HEAL = Group_getHEAL()})
            self.elapsed = 0                
        end
end)

RubimRH.Listener:Add('Rubim_Events', "PLAYER_REGEN_ENABLED", function()
        wipe(RubimRH.gHE)
end)

function RubimRH.AVG_DMG()
    local total = 0
    if RubimRH.tableexist(RubimRH.gHE) then
        for i = 1, #RubimRH.gHE do
            total = total + RubimRH.gHE[i].DMG
        end
        total = total / #RubimRH.gHE
    end
    return total
end

function RubimRH.AVG_HPS()
    local total = 0
    if RubimRH.tableexist(RubimRH.gHE) then
        for i = 1, #RubimRH.gHE do
            total = total + RubimRH.gHE[i].HEAL
        end
        total = total / #RubimRH.gHE
    end
    return total
end

function RubimRH.Last5sec_DMG()
    local total = 0
    if RubimRH.tableexist(RubimRH.gHE) and #RubimRH.gHE >= 6 then
        for i = #RubimRH.gHE - 5, #RubimRH.gHE do
            total = total + RubimRH.gHE[i].DMG
        end
        total = total / 5
    end
    return total
end

-- HealingEngine
local AVG_DMG = RubimRH.AVG_DMG()
local AVG_HPS = RubimRH.AVG_HPS()


local function Efflorescence()
    for i = 1, 5 do
        local active, totemName, startTime, duration, textureId  = GetTotemInfo(i)
        if active == true and textureId == 134222 then
            return startTime + duration - GetTime()
        end
    end
    return 0
end

local EnemyRanges = { 35 }
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

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
    local DPS, CDs, Healing_Raid, Healing_Tank
    
	--- Out of Combat
    UpdateRanges()
    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();
    LeftAlt = IsLeftAltKeyDown();

	-- Dps rotation
    local DPS = function()
        if S.Sunfire:IsReady() and Target:DebuffRemainsP(S.SunfireDebuff) < 4 then
            return S.Sunfire:Cast()
        end

        if S.Moonfire:IsReady() and Target:DebuffRemainsP(S.MoonfireDebuff) < 4 then
            return S.Moonfire:Cast()
        end

        if S.SolarWrath:IsReady() and Target:DebuffRemainsP(S.MoonfireDebuff) >= 4 and Target:DebuffRemainsP(S.SunfireDebuff) >= 4 then
            return S.SolarWrath:Cast()
        end

        
    end
	
	-- CDs Priorities
    local CDs = function()
	    
		--26Flourish
		-- Combo Tranquility + Wild Growth 
        if S.Flourish:CooldownRemainsP() < 0.1 and S.WildGrowth:CooldownRemainsP() > 4 and (RubimRH.incdmg5secs() > AVG_DMG + AVG_HPS) and AoEFlourish(60) then
            if S.Flourish:IsAvailable() then
                if GroupedBelow(RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["health_flourish"]["value"]) >= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["nb_flourish"]["value"] then
                    return S.Flourish:Cast()
                end
            end
		end
		
		--27Tranquility
        if S.Tranquility:IsReady() and S.WildGrowth:CooldownRemainsP() > 1 then
            if GroupedBelow(RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["health_tranqui"]["value"]) >= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["nb_tranqui"]["value"] then
                return S.Tranquility:Cast()
            end
        end
		


        --28Tree of Life
        if S.TreeOfLife:IsAvailable() then
            if GroupedBelow(35) >= 2 then
                return S.TreeOfLife:Cast()
            end
        end
		
        --29Innervate
        if S.Innervate:IsReady() and RubimRH.TimeToDie("target") > Player:GCD() * 5 then
		     -- if 67% of total members have <50% hp in 40yards
            if Player:ManaPercentage() <= 90 and RubimRH.AoEHP(50) > RubimRH.AoEMembers(true, 3, 4) then
                return S.Innervate:Cast()
            end
        end
    end
	
	-- Arena Rotation
    local Healing_Arena = function()
	
        --Tank Emergency Ironbark
        if S.Ironbark:IsReady() then
            if LowestAlly("TANK", "HP") <= 25 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 25 then
                return S.Ironbark:Cast()
            end
        end
		
		--Tank Priority Lifebloom
        if S.Lifebloom:IsReady() and Target:BuffDownP(S.Lifebloom) then
            if LowestAlly("TANK", "HP") <= 99 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 97 then
                return S.Lifebloom:Cast()
            end
        end
		
		--Tank Priority Rejuvenation
        if S.Rejuvenation:IsReady() and Target:BuffDownP(S.Rejuvenation) then
            if LowestAlly("TANK", "HP") <= 98 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 98 then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority Rejuvenation With Germination
        if S.Rejuvenation:IsReady() and Target:BuffRemainsP(S.Rejuvenation) > 1 and not Target:Buff(S.RejuvenationGerm) and S.Germination:IsAvailable() then
            if LowestAlly("TANK", "HP") <= 97 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 93 then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority CenarionWard
        if S.CenarionWard:IsReady() and RubimRH.SpellInRange("target", 102351) and RubimRH.PredictHeal("Cenarion Ward", "target") then
            if LowestAlly("TANK", "HP") <= 90 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 90 then
                return S.CenarionWard:Cast()
            end
        end
		
        --Tank Priority Swiftmend
        if S.Swiftmend:IsReady() then
            --if InjuredAlliesInExplicitRadius(30, true, 0.75) >= 3
            if LowestAlly("TANK", "HP") <= 70 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 50 then
                return S.Swiftmend:Cast()
            end
        end
    end
	
	-- Tank Priority Spells
    local Healing_Mythic = function()
	
        --Tank Emergency Ironbark
        if S.Ironbark:IsReady() then
            if LowestAlly("TANK", "HP") <= 25 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 25 then
                return S.Ironbark:Cast()
            end
        end		
		
		--Tank Priority Rejuvenation
        if S.Rejuvenation:IsReady() and Target:BuffDownP(S.Rejuvenation) then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_rejuv"]["value"] then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_rejuv"]["value"] then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority Rejuvenation With Germination
        if S.Rejuvenation:IsReady() and Target:BuffRemainsP(S.Rejuvenation) > 1 and not Target:Buff(S.RejuvenationGerm) and S.Germination:IsAvailable() then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_germi"]["value"] then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_germi"]["value"] then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority CenarionWard
        if S.CenarionWard:IsReady() and RubimRH.SpellInRange("target", 102351) and RubimRH.PredictHeal("Cenarion Ward", "target") then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_cenar"]["value"] then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_cenar"]["value"] then
                return S.CenarionWard:Cast()
            end
        end
		
        --Tank Priority Swiftmend
        if S.Swiftmend:IsReady() then
            --if InjuredAlliesInExplicitRadius(30, true, 0.75) >= 3
            if LowestAlly("TANK", "HP") <= 70 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 50 then
                return S.Swiftmend:Cast()
            end
        end
    end
	

	-- Raid Healing rotation
    local Healing_Raid = function()
	
   
	   --Tank Emergency Ironbark
        if S.Ironbark:IsReady() then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_bark"]["value"] then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:BuffRemainsP(S.Rejuvenation) > 1 and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_bark"]["value"] then
                return S.Ironbark:Cast()
            end
        end
		
		--Tank Priority Lifebloom
        if S.Lifebloom:IsReady() and Target:BuffDownP(S.Lifebloom) then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_lifebloom"]["value"] then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_lifebloom"]["value"] then
                return S.Lifebloom:Cast()
            end
        end
		
		--Tank Priority Rejuvenation
        if S.Rejuvenation:IsReady() and Target:BuffDownP(S.Rejuvenation) then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_rejuv"]["value"] then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_rejuv"]["value"] then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority Rejuvenation With Germination
        if S.Rejuvenation:IsReady() and Target:BuffRemainsP(S.Rejuvenation) > 1 and not Target:Buff(S.RejuvenationGerm) and S.Germination:IsAvailable() then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_germi"]["value"] then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_germi"]["value"] then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority CenarionWard
        if S.CenarionWard:IsReady() and RubimRH.SpellInRange("target", 102351) and RubimRH.PredictHeal("Cenarion Ward", "target") then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_cenar"]["value"] then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_cenar"]["value"] then
                return S.CenarionWard:Cast()
            end
        end
	
        --16Swiftmend on low allies
        if S.Swiftmend:IsReady() and RubimRH.PredictHeal("Swiftmend", "target") then
            --if InjuredAlliesInExplicitRadius(30, true, 0.75) >= 3
            if LowestAlly("ALL", "HP") <= 50 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:BuffRemainsP(S.Rejuvenation) > 1 and Target:Exists() and Target:HealthPercentage() <= 50 then
                return S.Swiftmend:Cast()
            end
        end
        --23Rejuvenation
        if S.Rejuvenation:IsReady() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_rejuv"]["value"] then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:BuffDownP(S.Rejuvenation) and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_rejuv"]["value"] then
                return S.Rejuvenation:Cast()
            end
        end
		
		--23.2Germination
        if S.Rejuvenation:IsReady() and S.Germination:IsAvailable() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_germi"]["value"] then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:BuffRemainsP(S.Rejuvenation) > 1 and not Target:Buff(S.RejuvenationGerm) and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_germi"]["value"] then
                return S.Rejuvenation:Cast()
            end
        end

		--21WildGrowth_Party
        if S.WildGrowth:IsReady() and RubimRH.AoEON() and RubimRH.PredictHeal("Wild Growth", "target") and GroupedBelow(RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_wildg"]["value"]) >= 3 then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_wildg"]["value"] then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:BuffRemainsP(S.Rejuvenation) > 1 and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_wildg"]["value"] then
                return S.WildGrowth:Cast()
            end
        end
				
		--25CenarionWard
        if S.CenarionWard:IsReady() then
            if LowestAlly("ALL", "HP") <= 75 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:BuffRemainsP(S.Rejuvenation) > 1 and Target:Exists() and Target:HealthPercentage() <= 75 then
                return S.CenarionWard:Cast()
            end
        end
		

        --24Regrowth
        if S.Regrowth:IsReady() and Target:Buff(S.Rejuvenation) and RubimRH.PredictHeal("Regrowth", "target") then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_regro"]["value"] then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_regro"]["value"] then
                return S.Regrowth:Cast()
            end
        end

	
		
		--22Efflorescence_Prediction
        if S.Efflorescence:IsReady() and RubimRH.AoEON() and RubimRH.PredictHeal("Efflorescence", "target") and Efflorescence() <= 3 and GroupedBelow(90) >= 3 then
           if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_efflo"]["value"] then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_efflo"]["value"] then
                return S.Efflorescence:Cast()
            end
        end
		
		--22Efflorescence
        if S.Efflorescence:IsReady() and RubimRH.AoEON() and GroupedBelow(RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_efflo"]["value"]) >= 3 and Efflorescence() <= 3 then
           if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_efflo"]["value"] then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_efflo"]["value"] then
                return S.Efflorescence:Cast()
            end
        end
		
		

		
		--17Priority Lifebloom on low allies
        --if S.Lifebloom:IsReady() and Target:BuffDownP(S.Lifebloom) then
        --    if LowestAlly("ALL", "HP") <= 35 then
        --        ForceHealingTarget("ALL")
        --    end

        --    if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 35 then
        --        return S.Lifebloom:Cast()
        --    end
        --end




    end
	
	-- if we are in combat 
    --if UnitAffectingCombat("player") then
        -- QueueSkill
        if QueueSkill() ~= nil then
            return QueueSkill()
        end
        -- Mouseover Dispell handler
        local MouseoverUnit = UnitExists("mouseover") and UnitIsFriend("player", "mouseover") and Unit("mouseover") or nil
        if MouseoverUnit then
            -- Nature Cure
		    if S.NaturesCure:IsReady() and MouseOver:HasDispelableDebuff("Magic", "Poison", "Curse") then
                return S.NaturesCure:Cast()
            end
        end
		
		-- Mouseover Attack handler
        local MouseoverEnemyUnit = UnitExists("mouseover") and not UnitIsFriend("target", "mouseover") and Unit("mouseover") or nil
        if MouseoverUnit then
            return DPS()
        end	

        -- Anti channeling interrupt
        if Player:IsChanneling() or Player:IsCasting() then
            return 0, 236353
        end
       
	    if Player:CanAttack(Target) then
            return DPS()
        end
		
		-- CDs handler
		if CDs() ~= nil and RubimRH.CDsON() then
            return CDs()
        end
		-- Healing tank
		--if IsInRaid() then 
        --    if Healing_Tank() ~= nil then
       --         return Healing_Tank()
		--	end
       -- end
	   	-- Arena Rotation
	    --if select(2, IsInInstance()) == "arena" then 
        --    if Healing_Arena() ~= nil then
        --        return Healing_Arena()
		--	end
        --end
	   -- Mythic + Rotation
	    --if select(2, IsInInstance()) == "party" then 
        --    if Healing_Mythic() ~= nil then
        --        return Healing_Mythic()
		--	end
     -- end

	     -- Healing raid
        if Healing_Raid() ~= nil then
            return Healing_Raid()
        end
    return 0, 135328
	--end
end

RubimRH.Rotation.SetAPL(105, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(105, PASSIVE)