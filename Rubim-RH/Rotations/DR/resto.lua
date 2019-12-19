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
	
		  --8.2 Essences
  UnleashHeartOfAzeroth = Spell(280431),
  BloodOfTheEnemy       = Spell(297108),
  BloodOfTheEnemy2      = Spell(298273),
  BloodOfTheEnemy3      = Spell(298277),
  ConcentratedFlame     = Spell(295373),
  ConcentratedFlame2    = Spell(299349),
  ConcentratedFlame3    = Spell(299353),
  GuardianOfAzeroth     = Spell(295840),
  GuardianOfAzeroth2    = Spell(299355),
  GuardianOfAzeroth3    = Spell(299358),
  FocusedAzeriteBeam    = Spell(295258),
  FocusedAzeriteBeam2   = Spell(299336),
  FocusedAzeriteBeam3   = Spell(299338),
  PurifyingBlast        = Spell(295337),
  PurifyingBlast2       = Spell(299345),
  PurifyingBlast3       = Spell(299347),
  TheUnboundForce       = Spell(298452),
  TheUnboundForce2      = Spell(299376),
  TheUnboundForce3      = Spell(299378),
  RippleInSpace         = Spell(302731),
  RippleInSpace2        = Spell(302982),
  RippleInSpace3        = Spell(302983),
  WorldveinResonance    = Spell(295186),
  WorldveinResonance2   = Spell(298628),
  WorldveinResonance3   = Spell(299334),
  MemoryOfLucidDreams   = Spell(298357),
  MemoryOfLucidDreams2  = Spell(299372),
  MemoryOfLucidDreams3  = Spell(299374),
	
	
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


local function BadDebuffOnTarget()    
    local DarkestDepths = Spell(292127)
	
	if Target:DebuffRemainsP(DarkestDepths) > 0 then 
        return true
    end
	
	--[[for i 1, #DebuffList do		
	    if Target:DebuffRemainsP(i) > 0 then 
            return true
        end
	end]]--
	
    return false
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

local function AVG_DMG()
    local total = 0
    if RubimRH.tableexist(RubimRH.gHE) then
        for i = 1, #RubimRH.gHE do
            total = total + RubimRH.gHE[i].DMG
        end
        total = total / #RubimRH.gHE
    end
    return total
end

local function AVG_HPS()
    local total = 0
    if RubimRH.tableexist(RubimRH.gHE) then
        for i = 1, #RubimRH.gHE do
            total = total + RubimRH.gHE[i].HEAL
        end
        total = total / #RubimRH.gHE
    end
    return total
end

local function Last5sec_DMG()
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
local AVG_DMG = AVG_DMG()
local AVG_HPS = AVG_HPS()


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

-- # Essences
local function Essences()
  -- blood_of_the_enemy
  if S.BloodOfTheEnemy:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- concentrated_flame
  if S.ConcentratedFlame:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- guardian_of_azeroth
  if S.GuardianOfAzeroth:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- focused_azerite_beam
  if S.FocusedAzeriteBeam:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- purifying_blast
  if S.PurifyingBlast:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- the_unbound_force
  if S.TheUnboundForce:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- ripple_in_space
  if S.RippleInSpace:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- worldvein_resonance
  if S.WorldveinResonance:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- memory_of_lucid_dreams,if=fury<40&buff.metamorphosis.up
  if S.MemoryOfLucidDreams:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  return false
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

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 25 then
                return S.Ironbark:Cast()
            end
        end
		
		--Tank Priority Lifebloom
        if S.Lifebloom:IsReady() and Target:BuffDownP(S.Lifebloom) then
            if LowestAlly("TANK", "HP") <= 99 then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 97 then
                return S.Lifebloom:Cast()
            end
        end
		
		--Tank Priority Rejuvenation
        if S.Rejuvenation:IsReady() and Target:BuffDownP(S.Rejuvenation) then
            if LowestAlly("TANK", "HP") <= 98 then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 98 then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority Rejuvenation With Germination
        if S.Rejuvenation:IsReady() and Target:BuffRemainsP(S.Rejuvenation) > 1 and not Target:Buff(S.RejuvenationGerm) and S.Germination:IsAvailable() then
            if LowestAlly("TANK", "HP") <= 97 then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 93 then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority CenarionWard
        if S.CenarionWard:IsReady() and RubimRH.SpellInRange("target", 102351) and RubimRH.PredictHeal("Cenarion Ward", "target") then
            if LowestAlly("TANK", "HP") <= 90 then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 90 then
                return S.CenarionWard:Cast()
            end
        end
		
        --Tank Priority Swiftmend
        if S.Swiftmend:IsReady() then
            --if InjuredAlliesInExplicitRadius(30, true, 0.75) >= 3
            if LowestAlly("TANK", "HP") <= 70 then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 50 then
                return S.Swiftmend:Cast()
            end
        end
    end
	
	-- Tank Priority Spells
    local Healing_Tank = function()
	
         --Tank Emergency Ironbark
        if S.Ironbark:IsReady() then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_bark"]["value"] then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:BuffRemainsP(S.Rejuvenation) > 1 and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_bark"]["value"] then
                return S.Ironbark:Cast()
            end
        end
		
		--Tank Priority Lifebloom
        if S.Lifebloom:IsReady() then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_lifebloom"]["value"] then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:BuffDownP(S.Lifebloom) or Target:BuffRemainsP(S.Lifebloom) < 3 and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_lifebloom"]["value"] then
                return S.Lifebloom:Cast()
            end
        end
		
		--Tank Priority Rejuvenation
        if S.Rejuvenation:IsReady() then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_rejuv"]["value"] then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:BuffDownP(S.Rejuvenation) or Target:BuffRemainsP(S.Rejuvenation) < 3 and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_rejuv"]["value"] then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority Rejuvenation With Germination
        if S.Rejuvenation:IsReady() then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_germi"]["value"] then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:BuffRemainsP(S.Rejuvenation) > 1 and not Target:Buff(S.RejuvenationGerm) and S.Germination:IsAvailable() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_germi"]["value"] then
                return S.Rejuvenation:Cast()
            end
        end
		
		--Tank Priority CenarionWard
        if S.CenarionWard:IsReady() then
            if LowestAlly("TANK", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_cenar"]["value"] then
                ForceHealingTarget("TANK")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and RubimRH.SpellInRange("target", 102351) and RubimRH.PredictHeal("Cenarion Ward", "target") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_cenar"]["value"] then
                return S.CenarionWard:Cast()
            end
        end
    end
	

	-- Raid Healing rotation
    local Healing_Raid = function()
	
   
	    --Tank Priority Lifebloom
        if S.Lifebloom:IsReady() then
            if LowestAlly(RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["lifebloom"]["value"], "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_lifebloom"]["value"] then
                ForceHealingTarget(RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["lifebloom"]["value"])
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:BuffDownP(S.Lifebloom) or Target:BuffRemainsP(S.Lifebloom) < 3 and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["tank_lifebloom"]["value"] then
                return S.Lifebloom:Cast()
            end
        end
	
        --16Swiftmend on low allies
        if S.Swiftmend:IsReady() then
            --if InjuredAlliesInExplicitRadius(30, true, 0.75) >= 3
            if LowestAlly("ALL", "HP") <= 50 then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and RubimRH.PredictHeal("Swiftmend", "target") and Target:Exists() and Target:HealthPercentage() <= 50 then
                return S.Swiftmend:Cast()
            end
        end
        --23Rejuvenation
        if S.Rejuvenation:IsReady() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_rejuv"]["value"] then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:BuffDownP(S.Rejuvenation) and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_rejuv"]["value"] then
                return S.Rejuvenation:Cast()
            end
        end
		
		--23.2Germination
        if S.Rejuvenation:IsReady() and S.Germination:IsAvailable() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_germi"]["value"] then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:BuffRemainsP(S.Rejuvenation) > 1 and not Target:Buff(S.RejuvenationGerm) and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_germi"]["value"] then
                return S.Rejuvenation:Cast()
            end
        end

		--21WildGrowth_Party
        if S.WildGrowth:IsReady() and RubimRH.AoEON() and RubimRH.AoEHP(RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_wildg"]["value"]) >= 3 then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_wildg"]["value"] then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and RubimRH.PredictHeal("Wild Growth", "target") and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_wildg"]["value"] then
                return S.WildGrowth:Cast()
            end
        end
				
		--25CenarionWard
        if S.CenarionWard:IsReady() then
            if LowestAlly("ALL", "HP") <= 75 then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:BuffRemainsP(S.Rejuvenation) > 1 and Target:Exists() and Target:HealthPercentage() <= 75 then
                return S.CenarionWard:Cast()
            end
        end
		

        --24Regrowth
        if S.Regrowth:IsReady() then
            if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_regro"]["value"] then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:Buff(S.Rejuvenation) and RubimRH.PredictHeal("Regrowth", "target") and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_regro"]["value"] then
                return S.Regrowth:Cast()
            end
        end

		
		--22Efflorescence
        if S.Efflorescence:IsReady() and RubimRH.AoEON() and GroupedBelow(RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_efflo"]["value"]) >= 4 and Efflorescence() <= 3 then
           if LowestAlly("ALL", "HP") <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_efflo"]["value"] then
                ForceHealingTarget("ALL")
            end

            if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= RubimRH.db.profile.mainOption.classprofiles[105][RubimRH.db.profile.mainOption.selectedProfile]["raid_efflo"]["value"] then
                return S.Efflorescence:Cast()
            end
        end	
		

		
		--17Priority Lifebloom on low allies
        --if S.Lifebloom:IsReady() and Target:BuffDownP(S.Lifebloom) then
        --    if LowestAlly("ALL", "HP") <= 35 then
        --        ForceHealingTarget("ALL")
        --    end

        --    if not BadDebuffOnTarget() and Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 35 then
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
		-- Targetting Dispell 
		local TargetUnit = UnitExists("target") and UnitIsFriend("player", "target") and Unit("target") or nil
        if TargetUnit then
            -- Nature Cure
		    if S.NaturesCure:IsReady() and MouseOver:HasDispelableDebuff("Magic", "Poison", "Curse") then
                return S.NaturesCure:Cast()
            end
        end
		
		-- Mouseover Attack handler
        local MouseoverEnemyUnit = UnitExists("mouseover") and not UnitIsFriend("player", "mouseover")
        if MouseoverEnemyUnit then
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