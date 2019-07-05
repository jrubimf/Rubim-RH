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
RubimRH.Spell[257] = {
    -- Racials
    ArcaneTorrent         = Spell(25046),
    GiftoftheNaaru        = Spell(59547),
    BloodFury             = Spell(20572),
    Berserking            = Spell(26297),
    Fireblood             = Spell(265221),
    AncestralCall         = Spell(274738),

    -- Main Spells 
    Heal                  = Spell(2060),
	FlashHeal             = Spell(2061),
	Renew                 = Spell(139),	
	HolyWordSerenity      = Spell(2050),
	HolyWordSanctify      = Spell(34861),
	PrayerOfHealing       = Spell(596),
	PrayerOfMending       = Spell(33076),
	
	-- Offensive Abilities
	HolyWordChastise      = Spell(88625),
	Smite                 = Spell(585),
	HolyNova              = Spell(132157),
	HolyFire              = Spell(14914),
	
	-- Cooldowns
	DivineHymn            = Spell(64843),
	GuardianSpirit        = Spell(47788),
	
	-- Utilities
	SymbolOfHope          = Spell(64901),
	Fade                  = Spell(586),
	DispellMagic          = Spell(528),
	LeapOfFaith           = Spell(73325),
	MindControl           = Spell(136287),
	MassDispell           = Spell(32375),
	Purify                = Spell(527),
	
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
local S = RubimRH.Spell[257];

-- Items
if not Item.Priest then
    Item.Priest = {};
end

Item.Priest.Holy = {
    -- Legendaries
    JusticeGaze = Item(137065, { 1 }),
    LiadrinsFuryUnleashed = Item(137048, { 11, 12 }),
    WhisperoftheNathrezim = Item(137020, { 15 })
};
local I = Item.Priest.Holy;
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
	    -- HolyWord Chastise
        if S.HolyWordChastise:IsCastableP() then
            return S.HolyWordChastise:Cast()
        end
        -- HolyFire
        if S.HolyFire:IsCastableP() then
            return S.HolyFire:Cast()
        end
	    -- Smite
        if S.Smite:IsCastableP() then
            return S.Smite:Cast()
        end
        --Holy Nova if target enemies >= 5
	    if S.HolyNova:IsReady() and active_enemies() >= 5 then
            return S.HolyNova:Cast()
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
    end
	
	-- CDs Priorities
    local CDs = function()
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
		-- 1 DivineHymn
        if S.DivineHymn:IsReady() and (RubimRH.incdmg5secs() > AVG_DMG + AVG_HPS) and RubimRH.AoEHP(50) > 3 then
            if RubimRH.AoEHP(50) > 3 then
                return S.DivineHymn:Cast()
            end
		end		
		--2 GuardianSpirit
        if S.GuardianSpirit:IsReady() and (RubimRH.incdmg5secs() > AVG_DMG + AVG_HPS) and RubimRH.AoEHP(50) > 4 then            
            return S.GuardianSpirit:Cast()            
        end
    end	
	
	-- Tank Priority Spells
    local Healing_Tank = function()	
        
    end
	

	-- Raid Healing rotation
    local Healing_Raid = function()	  
	
        --1a HolyWord Serenity (Emergency TANK Healing)
        if S.HolyWordSerenity:IsReady() then
            if LowestAlly("TANK", "HP") <= 45 then
                ForceHealingTarget("TANK")
            end

            if Target:GUID() == LowestAlly("TANK", "GUID") and Target:Exists() and Target:HealthPercentage() <= 45 then
                return S.HolyWordSerenity:Cast()
            end
        end
		
        --1b HolyWord Serenity (Emergency RAID Healing)
        if S.HolyWordSerenity:IsReady() then
            if LowestAlly("ALL", "HP") <= 35 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 35 then
                return S.HolyWordSerenity:Cast()
            end
        end
		
        --2 HolyWord Sanctify
        if S.HolyWordSanctify:IsReady() and RubimRH.AoEHP(91) >= 3 then
            if LowestAlly("ALL", "HP") <= 91 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 91 then
                return S.HolyWordSanctify:Cast()
            end
        end		
		
		--3 Prayer of Mending
        if S.PrayerOfMending:IsReady() then
           if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.PrayerOfMending:Cast()
            end
        end	

		--4 FlashHeal (moderate damage) and less than 3 people lower than 80% HP
        if S.FlashHeal:IsReady() and RubimRH.AoEHP(80) <= 3 then
            if LowestAlly("ALL", "HP") <= 60 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 60 then
                return S.FlashHeal:Cast()
            end
        end
		
		--5 Prayer Of Healing if party low and HolyWord Sanctify on cooldown
        if S.PrayerOfHealing:IsReady() and RubimRH.AoEON() and RubimRH.AoEHP(80) >= 3 and S.HolyWordSanctify:CooldownRemainsP() > 0.1 then
            if LowestAlly("ALL", "HP") <= 80 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 80 then
                return S.PrayerOfHealing:Cast()
            end
        end
		
		--5 Heal
        if S.Heal:IsReady() and not Player:IsMoving() then
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.Heal:Cast()
            end
        end

		--6 Renew
        if S.Renew:IsReady() then
            if LowestAlly("ALL", "HP") <= 95 then
                ForceHealingTarget("ALL")
            end

            if Target:GUID() == LowestAlly("ALL", "GUID") and Target:Exists() and Target:HealthPercentage() <= 95 then
                return S.Renew:Cast()
            end
        end	
    end
	
	-- if we are in combat 
    --if UnitAffectingCombat("player") then
        -- QueueSkill
        if QueueSkill() ~= nil then
            return QueueSkill()
        end
		-- purge (offensive dispell)
        if S.DispellMagic:IsCastableP() and Target:HasStealableBuff() then
            return S.DispellMagic:Cast()
        end
        -- Mouseover Dispell handler
        local MouseoverUnit = UnitExists("mouseover") and UnitIsFriend("player", "mouseover") and Unit("mouseover") or nil
        if MouseoverUnit then
            -- Purify
		    if S.Purify:IsReady() and MouseOver:HasDispelableDebuff("Magic", "Disease") then
                return S.Purify:Cast()
            end
        end
		-- Targetting Dispell 
		local TargetUnit = UnitExists("target") and UnitIsFriend("player", "target") and Unit("target") or nil
        if TargetUnit then
            -- Purify
		    if S.Purify:IsReady() and Target:HasDispelableDebuff("Magic", "Disease") then
                return S.Purify:Cast()
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
       
	    -- DPS Rotation
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

RubimRH.Rotation.SetAPL(257, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(257, PASSIVE)