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
RubimRH.Spell[264] = {
    -- Racials
    ArcaneTorrent         = Spell(25046),
    GiftoftheNaaru        = Spell(59547),
    BloodFury             = Spell(20572),
    Berserking            = Spell(26297),
    Fireblood             = Spell(265221),
    AncestralCall         = Spell(274738),

    -- Main Spells
    Riptide               = Spell(61295),
	HealingSurge          = Spell(8004),
	HealingWave           = Spell(77472),	
	ChainHeal             = Spell(1064),
	HealingRain           = Spell(73920),
	HealingStreamTotem    = Spell(5394),
	TidalWaveBuff         = Spell(53390),
	
	-- Offensive Abilities
	FlameShock            = Spell(188838),
	FlameShockDebuff      = Spell(188389),
	LavaBurst             = Spell(51505),
	LightningBolt         = Spell(403),
	ChainLightning        = Spell(421),
	
	-- Cooldowns
	HealingTideTotem      = Spell(108280),
	SpiritLinkTotem       = Spell(98008),
	SpiritWalkersGrace    = Spell(79206),
	
	-- Defensives
	AstralShift           = Spell(108271),
	
	-- Utilities
	AncestralSpirit       = Spell(2008),
	AncestralVision       = Spell(212048),
	AstralRecall          = Spell(556),
	EarthbindTotem        = Spell(2484),
	FarSight              = Spell(6196),
	GhostWolf             = Spell(2645),
	Bloodlust             = Spell(2825),
	Heroism               = Spell(32182),
	Hex                   = Spell(51514),
	Purge                 = Spell(370),
	PurifySpirit          = Spell(77130),
	WaterWalking          = Spell(546),
	WindShear             = Spell(57994),
	TremorTotem           = Spell(8143),
	EarthElemental        = Spell(198103),
	CapacitorTotem        = Spell(192058),
	
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
local S = RubimRH.Spell[264];

-- Items
if not Item.Shaman then
    Item.Shaman = {};
end

Item.Shaman.Resto = {
    -- Legendaries
    JusticeGaze = Item(137065, { 1 }),
    LiadrinsFuryUnleashed = Item(137048, { 11, 12 }),
    WhisperoftheNathrezim = Item(137020, { 15 })
};
local I = Item.Shaman.Resto;
-- Rotation Var

-- APL Action Lists (and Variables)

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


local function HealingRain()
    for i = 1, 5 do
        local active, totemName, startTime, duration, textureId  = GetTotemInfo(i)
        if active == true and textureId == 136037 then
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
        --actions=potion
        --actions+=/wind_shear

        --actions+=/use_items
        -- blood_fury
        if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
            return S.BloodFury:Cast()
        end
        -- berserking
        if S.Berserking:IsCastableP() and RubimRH.CDsON() then
            return S.Berserking:Cast()
        end
        -- fireblood
        if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
            return S.Fireblood:Cast()
        end
        -- ancestral_call
        if S.AncestralCall:IsCastableP() and RubimRH.CDsON() then
            return S.AncestralCall:Cast()
        end
        --actions+=/concentrated_flame
	    if S.ConcentratedFlame:IsCastableP() then 
	        return S.UnleashHeartOfAzeroth:Cast()
	    end
        --actions+=/ripple_in_space
	    if S.RippleInSpace:IsCastableP() then 
	        return S.UnleashHeartOfAzeroth:Cast()
	    end
        --actions+=/worldvein_resonance
	    if S.WorldveinResonance:IsCastableP() then 
	        return S.UnleashHeartOfAzeroth:Cast()
	    end
        --actions+=/flame_shock,target_if=(!ticking|dot.flame_shock.remains<=gcd)|refreshable
        if S.FlameShock:IsCastableP() and (Target:BuffDownP(S.FlameShockDebuff) or Target:DebuffRemainsP(S.FlameShockDebuff) < Player:GCD()) and Target:DebuffRefreshableCP(S.FlameShockDebuff) then
            return S.FlameShock:Cast()
        end
        --actions+=/lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
        if S.LavaBurst:IsCastableP() and (S.LavaBurst:CooldownUpP()) and Target:DebuffRemainsP(S.FlameShockDebuff) > S.LavaBurst:ExecuteTime() then
            return S.LavaBurst:Cast()
        end
        --actions+=/earth_elemental
	    if S.EarthElemental:IsReady() and RubimRH.CDsON() then
	        return S.EarthElemental:Cast()
        end
        --actions+=/lightning_bolt,if=spell_targets.chain_lightning<2
        if S.LightningBolt:IsCastableP() and active_enemies() < 2 then
            return S.LightningBolt:Cast()
        end
        --actions+=/chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
        if S.ChainLightning:IsCastableP() and active_enemies() > 1 then
            return S.ChainLightning:Cast()
        end
	    --actions+=/flame_shock,moving=1
        if S.FlameShock:IsCastableP() and Player:IsMoving() then
            return S.FlameShock:Cast()
        end        
    end
	
	-- CDs Priorities
    local CDs = function()
	    -- Astral Shift
        if S.AstralShift:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[262].sk2 then
            return S.AstralShift:Cast()
        end
		-- 1 Healing Tide Totem
        if S.HealingTideTotem:IsReady() and (RubimRH.incdmg5secs() > AVG_DMG + AVG_HPS) and RubimRH.AoEHP(50) > 3 then
            if RubimRH.AoEHP(50) > 3 then
                return S.HealingTideTotem:Cast()
            end
		end		
		--2 Spirit Link Totem
        if S.SpiritLinkTotem:IsReady() and (RubimRH.incdmg5secs() > AVG_DMG + AVG_HPS) and RubimRH.AoEHP(50) > 4 then            
            return S.SpiritLinkTotem:Cast()            
        end
    end	
	
	-- Tank Priority Spells
    local Healing_Tank = function()	
        
    end
	

	-- Raid Healing rotation
    local Healing_Raid = function()	  
	
        --1 Riptide on Tank
        if S.Riptide:IsReady() then
            if LowestAlly("ALL", "HP") <= 98 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 98 then
                return S.Riptide:Cast()
            end
        end
		
        --2 HealingStreamTotem
        if S.HealingStreamTotem:IsReady() then
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.HealingStreamTotem:Cast()
            end
        end		
		
		--4 ChainHeal
        if S.ChainHeal:IsReady() and RubimRH.AoEON() and RubimRH.AoEHP(80) >= 3 then
            if LowestAlly("ALL", "HP") <= 80 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 80 then
                return S.ChainHeal:Cast()
            end
        end
		
		--5 Healing Surge Emergency healing
        if S.HealingSurge:IsReady() and Player:BuffStack(S.TidalWaveBuff) >= 1 then
            if LowestAlly("ALL", "HP") <= 40 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 40 then
                return S.HealingSurge:Cast()
            end
        end

		--6 Healing Wave medium priority
        if S.HealingWave:IsReady() and Player:BuffStack(S.TidalWaveBuff) >= 1 then
            if LowestAlly("ALL", "HP") <= 75 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 75 then
                return S.HealingWave:Cast()
            end
        end	
		
		--6 Healing Wave low priority
        if S.HealingWave:IsReady() and Player:BuffStack(S.TidalWaveBuff) >= 1 then
            if LowestAlly("ALL", "HP") <= 90 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 90 then
                return S.HealingWave:Cast()
            end
        end	

		--3 HealingRain
        if S.HealingRain:IsReady() and RubimRH.AoEON() and RubimRH.AoEHP(95) >= 3 and HealingRain() <= 3 then
           if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.HealingRain:Cast()
            end
        end	
    end
	
	-- if we are in combat 
    --if UnitAffectingCombat("player") then
        -- QueueSkill
        if QueueSkill() ~= nil then
            return QueueSkill()
        end
	    -- wind_shear
        if S.WindShear:IsCastableP() and Target:IsInterruptible() and RubimRH.InterruptsON() then
            return S.WindShear:Cast()
        end
	    -- purge (offensive dispell)
        if S.Purge:IsCastableP() and Target:HasStealableBuff() then
            return S.Purge:Cast()
        end
        --actions+=/spiritwalkers_grace,moving=1,if=movement.distance>6
	    if S.SpiritWalkersGrace:IsReady() and Player:MovingFor() >= 5 and (RubimRH.incdmg5secs() > AVG_DMG + AVG_HPS) then
            return S.SpiritWalkersGrace:Cast()
        end
        -- Mouseover Dispell handler
        local MouseoverUnit = UnitExists("mouseover") and UnitIsFriend("player", "mouseover") and Unit("mouseover") or nil
        if MouseoverUnit then
            -- Nature Cure
		    if S.PurifySpirit:IsReady() and MouseOver:HasDispelableDebuff("Magic", "Curse") then
                return S.PurifySpirit:Cast()
            end
        end
		-- Targetting Dispell 
		local TargetUnit = UnitExists("target") and UnitIsFriend("player", "target") and Unit("target") or nil
        if TargetUnit then
            -- Nature Cure
		    if S.PurifySpirit:IsReady() and MouseOver:HasDispelableDebuff("Magic", "Curse") then
                return S.PurifySpirit:Cast()
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
       
	    if RubimRH.TargetIsValid() then
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

RubimRH.Rotation.SetAPL(264, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(264, PASSIVE)