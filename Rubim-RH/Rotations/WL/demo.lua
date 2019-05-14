-- Edit: Taste#0124
-- Updated to 8.1

-- Addon
local addonName, addonTable = ...

local mainAddon = RubimRH
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell = HL.Spell
local Item = HL.Item
local Pet = Unit.Pet

RubimRH.Spell[266] = {
  -- Racials
  Berserking            = Spell(26297),
  BloodFury             = Spell(20572),
  Fireblood             = Spell(265221),
  -- Abilities
  DrainLife             = Spell(234153),
  SummonDemonicTyrant   = Spell(265187),
  SummonImp             = Spell(688),
  SummonFelguard        = Spell(30146),
  HandOfGuldan          = Spell(105174),
  ShadowBolt            = Spell(686),
  Demonbolt             = Spell(264178),
  CallDreadStalkers     = Spell(104316),
  Fear                  = Spell(5782),
  Implosion             = Spell(196277),
  Shadowfury            = Spell(30283),

  -- Pet abilities
  CauterizeMaster         = Spell(119905),--imp
  Suffering               = Spell(119907),--voidwalker
  Whiplash                = Spell(119909),--Bitch
  FelStormFake            = Spell(29893),-- HAck == CreateSoulwell
  FelStorm                = Spell(89751),--FelGuard
  PetStun                 = Spell(119914),
  SpellLock               = Spell(119898),

  -- Talents
  Dreadlash               = Spell(264078),
  DemonicStrength         = Spell(267171),
  BilescourgeBombers      = Spell(267211),

  DemonicCalling          = Spell(205145),
  PowerSiphon             = Spell(264130),
  Doom                    = Spell(265412),
  DoomDebuff              = Spell(265412),

  DemonSkin               = Spell(219272),
  BurningRush             = Spell(111400),
  DarkPact                = Spell(108416),

  FromTheShadows          = Spell(267170),
  SoulStrike              = Spell(264057),
  SummonVilefiend         = Spell(264119),

  Darkfury                = Spell(264874),
  MortalCoil              = Spell(6789),
  DemonicCircle           = Spell(268358),

  InnerDemons             = Spell(267216),
  SoulConduit             = Spell(215941),
  GrimoireFelguard        = Spell(111898),
  GrimoireFelguardHack    = Spell(108503),

  SacrificedSouls         = Spell(267214),
  DemonicConsumption      = Spell(267215),
  NetherPortal            = Spell(267217),
  NetherPortalBuff        = Spell(267218),

  -- Defensive
  UnendingResolve         = Spell(104773),

  -- Azerite
  ForbiddenKnowledge      = Spell(279666),
  BalefulInvocation       = Spell(287059),
  ExplosivePotentialBuff  = Spell(275398),
  ExplosivePotential      = Spell(275395),

  -- Utility
  TargetEnemy             = Spell(153911),--doesnt work
  CreateHealthstone       = Spell(6201),--using this instead to target enemy
  
  -- Misc
  DemonicCallingBuff      = Spell(205146),
  DemonicCoreBuff         = Spell(264173),
  DemonicPowerBuff        = Spell(265273)
};

local S = RubimRH.Spell[266]

-- Demono pets function start
HL.GuardiansTable = {
    --{ID, name, spawnTime, ImpCasts, Duration, despawnTime}
    Pets = { 
      },
      ImpCount = 0,
	  ImpCastsRemaing = 0,
	  ImpTotalEnergy = 0,
	  WildImpDuration = 0,
      FelguardDuration = 0,
      DreadstalkerDuration = 0,
      DemonicTyrantDuration = 0,
	  VilefiendDuration = 0,
      -- Used for Wild Imps spawn prediction
      InnerDemonsNextCast = 0,
      ImpsSpawnedFromHoG = 0   	  
};


-- local for pets count & duration functions    
local PetDurations = {
 -- en, fr ,de ,ru
 ["Traqueffroi"] = 12.25,
 ["Dreadstalker"] = 12.25, 
 ["Зловещий охотник"] = 12.25, 
 ["Schreckenspirscher"] = 12.25, 
 ["Diablotin sauvage"] = 20, 
 ["Wild Imp"] = 20, 
 ["Дикий бес"] = 20, 
 ["Wildwichtel"] = 20,  
 ["Gangregarde"] = 28, 
 ["Felguard"] = 20, 
 ["Страж Скверны"] = 20, 
 ["Teufelswache"] = 20,  
 ["Tyran démoniaque"] = 15, 
 ["Demonic Tyrant"] = 20, 
 ["Демонический тиран"] = 20, 
 ["Dämonischer Tyrann"] = 20, 
 ["Démon abject"] = 15,
 ["Vilefiend"] = 20, 
 ["Мерзотень"] = 20, 
 ["Finsteres Scheusal"] = 20 
 
 };

 local PetTypes = {
  -- en, fr ,de ,ru
 ["Traqueffroi"] = true, 
 ["Dreadstalker"] = true, 
 ["Зловещий охотник"] = true, 
 ["Schreckenspirscher"] = true,
 ["Diablotin sauvage"]  = true, 
 ["Wild Imp"] = true, 
 ["Дикий бес"] = true, 
 ["Wildwichtel"] = true, 
 ["Gangregarde"] = true, 
 ["Felguard"] = true, 
 ["Страж Скверны"] = true, 
 ["Teufelswache"] = true,   
 ["Tyran démoniaque"] = true, 
 ["Demonic Tyrant"] = true, 
 ["Демонический тиран"] = true, 
 ["Dämonischer Tyrann"] = true,  
 ["Démon abject"] = true,
 ["Vilefiend"] = true, 
 ["Мерзотень"] = true, 
 ["Finsteres Scheusal"] = true  
};

local PetsData = {
    [98035] = {
      name = "Dreadstalker",
      duration = 12.25
    },
    [55659] = {
      name = "Wild Imp",
      duration = 20
    },
	[143622] = {
      name = "Wild Imp",
      duration = 20
    },
    [17252] = {
      name = "Felguard",
      duration = 28
    },
    [135002] = {
      name = "Demonic Tyrant",
      duration = 15
    },
	[135816] = {
      name = "Vilefiend",
      duration = 15
    },
};  
--------------------------
----- Demonology ---------
--------------------------
-- Update the GuardiansTable
function UpdatePetTable()
    for key, petTable in pairs(HL.GuardiansTable.Pets) do
        if petTable then
            -- Remove expired pets
            if GetTime() >= petTable.despawnTime then
		        if petTable.name == "Wild Imp" then
                    HL.GuardiansTable.ImpCount = HL.GuardiansTable.ImpCount - 1
			    end
			    if petTable.name == "Felguard" then
                    HL.GuardiansTable.FelguardDuration = 0
                elseif petTable.name == "Dreadstalker" then
                    HL.GuardiansTable.DreadstalkerDuration = 0
                elseif petTable.name == "Demonic Tyrant" then
                    HL.GuardiansTable.DemonicTyrantDuration = 0
			    elseif petTable.name == "Vilefiend" then
                    HL.GuardiansTable.VilefiendDuration = 0
                elseif petTable.name == "Wild Imp" then
                    HL.GuardiansTable.WildImpDuration = 0
                    HL.GuardiansTable.ImpCastsRemaing = HL.GuardiansTable.ImpCastsRemaing - petTable.ImpCasts
                    HL.GuardiansTable.ImpTotalEnergy =  HL.GuardiansTable.ImpCastsRemaing * 20
                end
                HL.GuardiansTable.Pets[key] = nil
            end
        end
        -- Remove any imp that has casted all of its bolts
        if petTable.ImpCasts <= 0 and  petTable.WildImpFrozenEnd < 1 then
            HL.GuardiansTable.ImpCount = HL.GuardiansTable.ImpCount - 1
            HL.GuardiansTable.Pets[key] = nil
        end
        -- Update Durations
        if GetTime() <= petTable.despawnTime then
            petTable.Duration = petTable.despawnTime - GetTime()
            if petTable.name == "Felguard" then
                HL.GuardiansTable.FelguardDuration = petTable.Duration
            elseif petTable.name == "Dreadstalker" then
                HL.GuardiansTable.DreadstalkerDuration = petTable.Duration
            elseif petTable.name == "Demonic Tyrant" then
                HL.GuardiansTable.DemonicTyrantDuration = petTable.Duration
            elseif petTable.name == "Vilefiend" then
                HL.GuardiansTable.VilefiendDuration = petTable.Duration
            elseif petTable.name == "Wild Imp" then
                HL.GuardiansTable.WildImpDuration = petTable.Duration
                if petTable.WildImpFrozenEnd ~= 0 then
                    local ImpTime =  math.floor(petTable.WildImpFrozenEnd - GetTime() + 0.5)
                    if ImpTime < 1 then 
					    petTable.WildImpFrozenEnd = 0 
					end
                end
            end	
            -- Add Time to pets  
		    if TyrantSpawed then
                if PetsData[UnitPetID] and PetsData[UnitPetID].name == "Demonic Tyrant" then
                    for key, petTable in pairs(HL.GuardiansTable.Pets) do
                        if petTable then
                            petTable.spawnTime = GetTime() + petTable.Duration + 15 - PetDurations[petTable.name]
                            petTable.despawnTime = petTable.spawnTime + PetDurations[petTable.name]
                            if petTable.name == "Wild Imp" then
                                petTable.WildImpFrozenEnd = GetTime() + 15
							end
                        end
                    end
                end
            end
        end
        if TyrantSpawed then TyrantSpawed = false end  
	end
end	

-- Add demon to table
HL:RegisterForSelfCombatEvent(
    function (...)
		--timestamp,Event,_,_,_,_,_,UnitPetGUID,petName,_,_,SpellID=select(1,...)
		local timestamp,Event,_,_,_,_,_,UnitPetGUID,_,_,_,SpellID=select(1,...)
        local _, _, _, _, _, _, _, UnitPetID = string.find(UnitPetGUID, "(%S+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%S+)")
        UnitPetID = tonumber(UnitPetID)
        
		-- Add pet
        if (UnitPetGUID ~= UnitGUID("pet") and Event == "SPELL_SUMMON" and PetsData[UnitPetID]) then
		    local summonedPet = PetsData[UnitPetID]
            local petTable = {
            ID = UnitPetGUID,
            name = summonedPet.name,
            spawnTime = GetTime(),
            ImpCasts = 5,
            Duration = summonedPet.duration,
			WildImpFrozenEnd = 0,
            despawnTime = GetTime() + tonumber(summonedPet.duration)
            }
            table.insert(HL.GuardiansTable.Pets,petTable)
		    if summonedPet.name == "Wild Imp" then
                HL.GuardiansTable.ImpCount = HL.GuardiansTable.ImpCount + 1
		    	HL.GuardiansTable.ImpCastsRemaing = HL.GuardiansTable.ImpCastsRemaing + 5
                HL.GuardiansTable.WildImpDuration = PetDurations[petName]
                petTable.WildImpFrozenEnd = 0 
		    elseif summonedPet.name == "Felguard" then
		        HL.GuardiansTable.FelguardDuration = PetDurations[petName]
		    elseif summonedPet.name == "Dreadstalker" then
		        HL.GuardiansTable.DreadstalkerDuration = PetDurations[petName]
		    elseif summonedPet.name == "Demonic Tyrant" then
                if not TyrantSpawed then TyrantSpawed = true  end
                HL.GuardiansTable.DemonicTyrantDuration = PetDurations[petName]
                UpdatePetTable()
		    elseif summonedPet.name == "Vilefiend" then
                HL.GuardiansTable.VilefiendDuration = PetDurations[petName]   
		    end
        end		
		
		-- Update when next Wild Imp will spawn from Inner Demons talent
        if UnitPetID == 143622 then
          HL.GuardiansTable.InnerDemonsNextCast = HL.GetTime() + 12
        end

         -- Updates how many Wild Imps have yet to spawn from HoG cast
        if UnitPetID == 55659 and HL.GuardiansTable.ImpsSpawnedFromHoG > 0 then
          HL.GuardiansTable.ImpsSpawnedFromHoG = HL.GuardiansTable.ImpsSpawnedFromHoG - 1
        end
		
        -- Update the pet table
        UpdatePetTable()
    end
    , "SPELL_SUMMON"
);
	
-- Decrement ImpCasts and Implosion Listener
HL:RegisterForCombatEvent(
    function (...)
      --local timestamp,Event,_,SourceGUID,SourceName,_,_,UnitPetGUID,petName,_,_,SpellID = select(4, ...);
      --local timestamp,Event,_,SourceGUID,SourceName,_,_,UnitPetGUID,petName,_,_,spell,SpellName=select(1,...)
        local SourceGUID,_,_,_,UnitPetGUID,_,_,_,SpellID = select(4, ...);
		
		-- Check for imp bolt casts
        if SpellID == 104318 then
            for key, petTable in pairs(HL.GuardiansTable.Pets) do
                if SourceGUID == petTable.ID then
                    if  petTable.WildImpFrozenEnd < 1 then
                        petTable.ImpCasts = petTable.ImpCasts - 1
                        HL.GuardiansTable.ImpCastsRemaing = HL.GuardiansTable.ImpCastsRemaing - 1
                    end
                end
            end
			HL.GuardiansTable.ImpTotalEnergy =  HL.GuardiansTable.ImpCastsRemaing * 20
        end
        
        -- Clear the imp table upon Implosion cast or Demonic Tyrant cast if Demonic Consumption is talented
        if SourceGUID == Player:GUID() and (SpellID == 196277 or (SpellID == 265187 and Spell(267215):IsAvailable())) then
            for key, petTable in pairs(HL.GuardiansTable.Pets) do
                if petTable.name == "Wild Imp" then
                    HL.GuardiansTable.Pets[key] = nil
                end
            end
            HL.GuardiansTable.ImpCount = 0
            HL.GuardiansTable.ImpCastsRemaing = 0
            HL.GuardiansTable.ImpTotalEnergy = 0
        end
        
        -- Update the imp table
        UpdatePetTable()
      end
    , "SPELL_CAST_SUCCESS"
);

-- Keep track how many Soul Shards we have
local SoulShards = 0;
function UpdateSoulShards()
    SoulShards = Player:SoulShards()
end

-- On Successful HoG cast add how many Imps will spawn
HL:RegisterForSelfCombatEvent(
    function(_, event, _, _, _, _, _, _, _, _, _, SpellID)
        if SpellID == 105174 then
            HL.GuardiansTable.ImpsSpawnedFromHoG = HL.GuardiansTable.ImpsSpawnedFromHoG + (SoulShards >= 3 and 3 or SoulShards)
        end
    end
    , "SPELL_CAST_SUCCESS"
);

local function ImpsSpawnedDuring(miliseconds)
  local ImpSpawned = 0
  local SpellCastTime = ( miliseconds / 1000 ) * Player:SpellHaste()

  if HL.GetTime() <= HL.GuardiansTable.InnerDemonsNextCast and (HL.GetTime() + SpellCastTime) >= HL.GuardiansTable.InnerDemonsNextCast then
    ImpSpawned = ImpSpawned + 1
  end

  if Player:IsCasting(S.HandofGuldan) then
    ImpSpawned = ImpSpawned + (Player:SoulShards() >= 3 and 3 or Player:SoulShards())
  end

  ImpSpawned = ImpSpawned +  HL.GuardiansTable.ImpsSpawnedFromHoG

  return ImpSpawned
end

-- Rotation Var
local ShouldReturn; -- Used to get the return string
local BestUnit, BestUnitTTD, BestUnitSpellToCast, DebuffRemains; -- Used for cycling
-- range for spell checking
local range = 40
    
   
-- Get if the pet are invoked. Parameter = true if you also want to test big pets
local function IsPetInvoked (testBigPets)
  testBigPets = testBigPets or false
  return S.Suffering:IsLearned() or S.SpellLock:IsLearned() or S.Whiplash:IsLearned() or S.CauterizeMaster:IsLearned() or S.PetStun:IsLearned() or (testBigPets and (S.ShadowLock:IsLearned() or S.MeteorStrike:IsLearned()))
end	
	
-- Function to check for imp count
local function WildImpsCount()
    return HL.GuardiansTable.ImpCount or 0
end

-- Function to check for remaining Dreadstalker duration
local function DreadStalkersTime()
    return HL.GuardiansTable.DreadstalkerDuration or 0
end

-- Function to check for remaining Grimoire Felguard duration
local function GrimoireFelguardTime()
    return HL.GuardiansTable.FelguardDuration or 0
end

-- Function to check for Demonic Tyrant duration
local function DemonicTyrantTime()
    return HL.GuardiansTable.DemonicTyrantDuration or 0
end     

-- Function to check Total active Imp Energy (More accurate than imp count for "Demonic Consumption" talent)
local function WildImpTotalEnergy()
    return HL.GuardiansTable.ImpTotalEnergy or 0
end

-- Demono pets function end

local function TyranIsActive()
    if DemonicTyrantTime() > 1 then
        return true
    else
        return false
    end
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

    return true
end

-- Calculate future shard count
local function FutureShard()
    local Shard = Player:SoulShards()
    if not Player:IsCasting() then
        return Shard
    else
        if Player:IsCasting(S.NetherPortal) then
            return Shard - 1
        elseif Player:IsCasting(S.CallDreadStalkers) and not Player:BuffP(S.DemonicCallingBuff) then
            return Shard - 2
	    elseif Player:IsCasting(S.BilescourgeBombers) then
            return Shard - 2
        elseif Player:IsCasting(S.SummonVilefiend) then
            return Shard - 1
        elseif Player:IsCasting(S.SummonFelguard) then
            return Shard - 1
		elseif Player:IsCasting(S.GrimoireFelguard) then
            return Shard - 1
		elseif Player:IsCasting(S.CallDreadStalkers) and Player:BuffP(S.DemonicCallingBuff) then
            return Shard - 1
        elseif Player:IsCasting(S.SummonDemonicTyrant) and S.BalefulInvocation:AzeriteEnabled() then
            return 5
        elseif Player:IsCasting(S.HandOfGuldan) then
            if Shard > 3 then
                return Shard - 3
            else
                return 0
            end
        elseif Player:IsCasting(S.Demonbolt) then
            if Shard >= 4 then
                return 5
            else
                return Shard + 2
            end
        elseif Player:IsCasting(S.ShadowBolt) then
            if Shard == 5 then
                return Shard
            else
                return Shard + 1
            end
		elseif Player:IsCasting(S.SoulStrike) then
            if Shard == 5 then
                return Shard
            else
                return Shard + 1
            end
        else
            return Shard
        end
    end
end


-- enemy in range
S.HandOfGuldan:RegisterInFlight()

local EnemyRanges = { 40, 5 }

local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

local function Precombat()
    -- flask
    -- food
    -- augmentation
    -- actions.precombat+=/summon_pet
    if (not IsPetInvoked() or not S.PetStun:IsLearned()) or not IsPetInvoked() and FutureShard() >= 1 then
        return S.SummonFelguard:Cast()
    end
    -- inner_demons,if=talent.inner_demons.enabled
    if S.InnerDemons:IsCastableP() and (S.InnerDemons:IsAvailable()) then
      return S.InnerDemons:Cast()
    end
    -- snapshot_stats
	-- potion
    -- demonbolt
    if S.Demonbolt:IsCastableP() and not Player:IsCasting(S.Demonbolt) and not Player:PrevGCDP(1, S.Demonbolt) then
      return S.Demonbolt:Cast()
    end
end

local function BuildAShard()
    -- soul_strike
    if S.SoulStrike:IsCastableP() and FutureShard() < 5 then
        return S.SoulStrike:Cast()
    end
	-- demonbolt,if=soul_shard<=3&buff.demonic_core.remains
  --  if S.Demonbolt:IsCastableP() and FutureShard() <= 3 and Player:BuffRemainsP(S.DemonicCoreBuff) >= 1 then
  --      return S.Demonbolt:Cast()
  --  end
    -- shadow_bolt
    if S.ShadowBolt:IsCastableP() and FutureShard() < 5 then
        return S.ShadowBolt:Cast()
    end
end
        
		
local function DconEpOpener()
	-- demonic_strength
    if S.DemonicStrength:IsCastableP() and IsPetInvoked() then
        return S.DemonicStrength:Cast()
    end
    -- doom,line_cd=30
    if S.Doom:IsCastableP() and not Target:DebuffP(S.DoomDebuff) then
        return S.Doom:Cast()
    end
	-- bilescourge_bombers
    if S.BilescourgeBombers:IsCastableP() and FutureShard() > 1 then
        return S.BilescourgeBombers:Cast()
    end
	-- hand_of_guldan,line_cd=30
    if S.HandOfGuldan:IsCastableP() and FutureShard() > 4 and HL.CombatTime() < 3 then
        return S.HandOfGuldan:Cast()
    end
	-- hand_of_guldan,line_cd=30
    if S.HandOfGuldan:IsCastableP() and WildImpsCount() >= 5 and FutureShard() > 0 then
        return S.HandOfGuldan:Cast()
    end
	-- soul_strike,if=(soul_shard<3|soul_shard=4&buff.demonic_core.stack<=3)|buff.demonic_core.down&soul_shard<5
    if S.SoulStrike:IsCastableP() and ((FutureShard() <= 2 or FutureShard() == 4 and Player:BuffStackP(S.DemonicCoreBuff) <= 3) or Player:BuffDownP(S.DemonicCoreBuff) and FutureShard() < 5) then
        return S.SoulStrike:Cast()
    end
	-- implosion,if=buff.wild_imps.stack>2&buff.explosive_potential.down
    if S.Implosion:IsCastableP() and not Player:PrevGCDP(1, S.SummonDemonicTyrant) and WildImpsCount() > 2 and Player:BuffDownP(S.ExplosivePotentialBuff) and HL.CombatTime() < 10 then
        return S.Implosion:Cast()
    end
	-- build up to 5 shards
    -- grimoire_felguard
    if S.GrimoireFelguard:IsCastableP() and FutureShard() >= 5 and Player:BuffRemainsP(S.ExplosivePotentialBuff) >= 1 then
        return S.GrimoireFelguardHack:Cast()
    end
	-- summon_vilefiend
    if S.SummonVilefiend:IsCastableP() and FutureShard() >= 4 and Player:BuffRemainsP(S.ExplosivePotentialBuff) >= 1 then
        return S.SummonVilefiend:Cast()
    end
	-- call_dreadstalkers,if=prev_gcd.1.hand_of_guldan
    if S.CallDreadStalkers:IsCastableP() and (FutureShard() > 4 or Player:PrevGCDP(1, S.SummonVilefiend) or Player:PrevGCDP(1, S.GrimoireFelguard)) and Player:BuffRemainsP(S.ExplosivePotentialBuff) > 1 then
        return S.CallDreadStalkers:Cast()
    end
	-- build to 5shards
	-- hand_of_guldan,if=soul_shard=5|soul_shard=4&buff.demonic_calling.remains
    if S.HandOfGuldan:IsCastableP() and FutureShard() > 4 and DreadStalkersTime() > 1 and WildImpsCount() < 3 and (Player:PrevGCDP(1, S.ShadowBolt) or Player:PrevGCDP(1, S.Demonbolt) or Player:PrevGCDP(1, S.SoulStrike)) then
        return S.HandOfGuldan:Cast()
    end
	-- build to 3shards
    -- hand_of_guldan,if=soul_shard=5|soul_shard=4&buff.demonic_calling.remains
    if S.HandOfGuldan:IsCastableP() and FutureShard() > 2 and DreadStalkersTime() > 1 and WildImpsCount() > 1 then
        return S.HandOfGuldan:Cast()
    end
    -- summon_demonic_tyrant,if=prev_gcd.1.call_dreadstalkers
    if S.SummonDemonicTyrant:IsCastableP() and RubimRH.CDsON() and (WildImpsCount() > 3 or (Player:PrevGCDP(1, S.HandOfGuldan) and Player:SoulShards() <= 1 and HL.CombatTime() > 8)) then
      return S.SummonDemonicTyrant:Cast()
    end
	-- demonbolt,if=soul_shard<=3&buff.demonic_core.remains
    if S.Demonbolt:IsCastableP() and (FutureShard() <= 3 and Player:BuffRemainsP(S.DemonicCoreBuff) >= 1) then
        return S.Demonbolt:Cast()
    end
    -- call_action_list,name=build_a_shard
    if (true) then
        if BuildAShard() ~= nil then
            return BuildAShard()
        end
    end
end
  
  
  
local function Implosion()
    -- bilescourge_bombers
    if S.BilescourgeBombers:IsCastableP() and FutureShard() > 2 and Cache.EnemiesCount[40] >= 3 and Target:TimeToDie() > 6 then
        return S.BilescourgeBombers:Cast()
    end  
  	-- implosion,if=PetStack.imps>=mainAddon.db.profile[266].sk2+RubimRH.AoEON
    if S.Implosion:IsCastableP() and not Player:PrevGCDP(1, S.SummonDemonicTyrant) and not Player:PrevGCDP(1, S.Implosion) and WildImpsCount() > 2 and WildImpsCount() >= mainAddon.db.profile[266].sk2 and RubimRH.AoEON() and not Player:PrevGCDP(1, S.SummonDemonicTyrant) then
        return S.Implosion:Cast()
    end  
    -- implosion,if=(buff.wild_imps.stack>=6&(soul_shard<3|prev_gcd.1.call_dreadstalkers|buff.wild_imps.stack>=9|prev_gcd.1.bilescourge_bombers|(!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan))&!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan&buff.demonic_power.down)|(time_to_die<3&buff.wild_imps.stack>0)|(prev_gcd.2.call_dreadstalkers&buff.wild_imps.stack>2&!talent.demonic_calling.enabled)
    if S.Implosion:IsCastableP() and not Player:PrevGCDP(1, S.SummonDemonicTyrant) and not Player:PrevGCDP(1, S.Implosion) and (WildImpsCount() >= 6 and (FutureShard() < 3 or Player:PrevGCDP(1, S.CallDreadStalkers) or WildImpsCount() >= 9 or Player:PrevGCDP(1, S.BilescourgeBombers) or (not Player:PrevGCDP(1, S.HandOfGuldan) and not Player:PrevGCDP(2, S.HandOfGuldan))) and not Player:PrevGCDP(1, S.HandOfGuldan) and not Player:PrevGCDP(2, S.HandOfGuldan) and Player:BuffDownP(S.DemonicPowerBuff)) or (Target:TimeToDie() < 3 and WildImpsCount() > 2) or (Player:PrevGCDP(2, S.CallDreadStalkers) and WildImpsCount() > 2 and not S.DemonicCalling:IsAvailable()) then
        return S.Implosion:Cast()
    end
    -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
    if S.GrimoireFelguard:IsCastableP() and FutureShard() > 1 and RubimRH.CDsON() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13) then
        return S.GrimoireFelguardHack:Cast()
    end
    -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
    if S.CallDreadStalkers:IsCastableP() and FutureShard() > 1 and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and Player:BuffRemainsP(S.DemonicCallingBuff)) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not Player:BuffRemainsP(S.DemonicCallingBuff)) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
        return S.CallDreadStalkers:Cast()
    end
    -- hand_of_guldan,if=soul_shard>=5
    if S.HandOfGuldan:IsCastableP() and (FutureShard() >= 5) then
        return S.HandOfGuldan:Cast()
    end
    -- hand_of_guldan,if=soul_shard>=3&(((prev_gcd.2.hand_of_guldan|buff.wild_imps.stack>=3)&buff.wild_imps.stack<9)|cooldown.summon_demonic_tyrant.remains<=gcd*2|buff.demonic_power.remains>gcd*2)
    if S.HandOfGuldan:IsCastableP() and FutureShard() >= 3 and (((Player:PrevGCDP(2, S.HandOfGuldan) or WildImpsCount() >= 3) and WildImpsCount() < 9) or S.SummonDemonicTyrant:CooldownRemainsP() <= Player:GCD() * 2 or Player:BuffRemainsP(S.DemonicPowerBuff) > Player:GCD() * 2) then
        return S.HandOfGuldan:Cast()
    end
    -- demonbolt,if=prev_gcd.1.hand_of_guldan&soul_shard>=1&(buff.wild_imps.stack<=3|prev_gcd.3.hand_of_guldan)&soul_shard<4&buff.demonic_core.up
    if S.Demonbolt:IsCastableP() and Player:PrevGCDP(1, S.HandOfGuldan) and FutureShard() >= 1 and (WildImpsCount() <= 3 or Player:PrevGCDP(3, S.HandOfGuldan)) and FutureShard() < 5 and Player:BuffP(S.DemonicCoreBuff) then
        return S.Demonbolt:Cast()
    end
    -- summon_vilefiend,if=(cooldown.summon_demonic_tyrant.remains>40&spell_targets.implosion<=2)|cooldown.summon_demonic_tyrant.remains<12
    if S.SummonVilefiend:IsCastableP() and FutureShard() > 1 and ((S.SummonDemonicTyrant:CooldownRemainsP() > 40 and Cache.EnemiesCount[40] <= 2) or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
        return S.SummonVilefiend:Cast()
    end
    -- bilescourge_bombers,if=cooldown.summon_demonic_tyrant.remains>9
    if S.BilescourgeBombers:IsCastableP() and FutureShard() > 1 and (S.SummonDemonicTyrant:CooldownRemainsP() > 9) then
        return S.BilescourgeBombers:Cast()
    end
    -- soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
    if S.SoulStrike:IsCastableP() and FutureShard() < 5 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 then
        return S.SoulStrike:Cast()
    end
    -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&(buff.demonic_core.stack>=3|buff.demonic_core.remains<=gcd*5.7)
    if S.Demonbolt:IsCastableP() and FutureShard() <= 3 and Player:BuffP(S.DemonicCoreBuff) and (Player:BuffStackP(S.DemonicCoreBuff) >= 3 or Player:BuffRemainsP(S.DemonicCoreBuff) <= Player:GCD() * 5.7) then
        return S.Demonbolt:Cast()
    end

    -- call_action_list,name=build_a_shard
    if (true) and FutureShard() <= 5 then
        if BuildAShard() ~= nil then
            return BuildAShard()
        end
    end
end


-- Auto switch target function
local function DoomDotCycle()
    if S.Doom:IsAvailable() and RubimRH.AoEON() and Cache.EnemiesCount[40] > 1 and Cache.EnemiesCount[40] <= 7 then
        if Target:DebuffRemainsP(S.Doom) <= 5 then
            return S.Doom:Cast()
	    elseif Target:DebuffRemainsP(S.Doom) >= 22 then
			return 0, CacheGetSpellTexture(153911)
		else
		    return Implosion()
		end		
	end
end
  
  
NetherPortal = function()
    -- call_action_list,name=nether_portal_building,if=cooldown.nether_portal.remains<20
    if (S.NetherPortal:CooldownRemainsP() < 20) then
      local ShouldReturn = NetherPortalBuilding(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>165
    if (S.NetherPortal:CooldownRemainsP() > 165) then
      local ShouldReturn = NetherPortalActive(); if ShouldReturn then return ShouldReturn; end
    end
end
  
  
-- NetherPortal Active
local function NetherPortalActive()
    -- bilescourge_bombers
    if S.BilescourgeBombers:IsCastableP() and FutureShard() > 1 then
        return S.BilescourgeBombers:Cast()
    end
    -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
    if S.GrimoireFelguard:IsCastableP() and S.SummonDemonicTyrant:CooldownRemainsP() < 13 and FutureShard() > 0 then
        return S.GrimoireFelguardHack:Cast()
    end
    -- summon_vilefiend,if=cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
    if S.SummonVilefiend:IsCastableP() and not Player:IsCasting(S.SummonVilefiend) and FutureShard() > 0 and (S.SummonDemonicTyrant:CooldownRemainsP() > 40 or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
        return S.SummonVilefiend:Cast()
    end
    -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
    if S.CallDreadStalkers:IsCastableP() and (FutureShard() > 1 or (FutureShard() > 0 and Player:BuffRemainsP(S.DemonicCallingBuff) > 0)) and not Player:IsCasting(S.CallDreadStalkers) and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and Player:BuffRemainsP(S.DemonicCallingBuff) > 0) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and Player:BuffRemainsP(S.DemonicCallingBuff) == 0) or S.SummonDemonicTyrant:CooldownRemainsP() < 14 ) then
        return S.CallDreadStalkers:Cast()
    end
    -- call_action_list,name=build_a_shard,if=soul_shard=1&(cooldown.call_dreadstalkers.remains<action.shadow_bolt.cast_time|(talent.bilescourge_bombers.enabled&cooldown.bilescourge_bombers.remains<action.shadow_bolt.cast_time))
    if FutureShard() == 1 and (S.CallDreadStalkers:CooldownRemainsP() < S.ShadowBolt:CastTime() or (S.BilescourgeBombers:IsAvailable() and S.BilescourgeBombers:CooldownRemainsP() < S.ShadowBolt:CastTime())) then
        if BuildAShard() ~= nil then
            return BuildAShard()
        end
    end
	-- summon_demonic_tyrant,if=buff.nether_portal.remains<5&soul_shard=0and WildImpsCount() >= mainAddon.db.profile[266].sk2
    if S.SummonDemonicTyrant:IsCastableP() and RubimRH.CDsON() and S.BalefulInvocation:AzeriteEnabled() and Player:BuffRemainsP(S.NetherPortalBuff) > 5 and FutureShard() == 0 then
        return S.SummonDemonicTyrant:Cast()
    end
    -- hand_of_guldan,if=((cooldown.call_dreadstalkers.remains>action.demonbolt.cast_time)&(cooldown.call_dreadstalkers.remains>action.shadow_bolt.cast_time))&cooldown.nether_portal.remains>(165+action.hand_of_guldan.cast_time)
    if S.HandOfGuldan:IsCastableP() and FutureShard() > 0 and (S.CallDreadStalkers:CooldownRemainsP() > S.Demonbolt:CastTime() and S.CallDreadStalkers:CooldownRemainsP() > S.ShadowBolt:CastTime()) and S.NetherPortal:CooldownRemainsP() > (165 + S.HandOfGuldan:CastTime()) then
        return S.HandOfGuldan:Cast()
    end
    -- summon_demonic_tyrant,if=buff.nether_portal.remains<5&soul_shard=0
    if S.SummonDemonicTyrant:IsCastableP() and RubimRH.CDsON() and Player:BuffRemainsP(S.NetherPortalBuff) < 5 and FutureShard() == 0 then
        return S.SummonDemonicTyrant:Cast()
    end
    -- summon_demonic_tyrant,if=buff.nether_portal.remains<action.summon_demonic_tyrant.cast_time+0.5.no_balefulinvocation:azerite
    if S.SummonDemonicTyrant:IsCastableP() and RubimRH.CDsON() and (Player:BuffRemainsP(S.NetherPortalBuff) < S.SummonDemonicTyrant:CastTime() + 0.5) then
        return S.SummonDemonicTyrant:Cast()
    end
	-- demonbolt,if=soul_shard<=3&buff.demonic_core.remains
    if S.Demonbolt:IsCastableP() and (FutureShard() <= 3 and Player:BuffRemainsP(S.DemonicCoreBuff) >= 1) then
        return S.Demonbolt:Cast()
    end
    -- call_action_list,name=build_a_shard
    if (true) then
        if BuildAShard() ~= nil then
            return BuildAShard()
        end
    end
end
  
-- NetherPortal Building
local function NetherPortalBuilding()
    -- nether_portal,if=soul_shard>=5&(!talent.power_siphon.enabled|buff.demonic_core.up)
    if S.NetherPortal:IsCastableP() and FutureShard() >= 5 and (not S.PowerSiphon:IsAvailable() or Player:BuffP(S.DemonicCoreBuff)) then
        return S.NetherPortal:Cast()
    end
    -- call_dreadstalkers
    if S.CallDreadStalkers:IsCastableP() and FutureShard() > 1 and FutureShard() >= 2 then
        return S.CallDreadStalkers:Cast()
    end
    -- hand_of_guldan,if=cooldown.call_dreadstalkers.remains>18&soul_shard>=3
    if S.HandOfGuldan:IsCastableP() and S.CallDreadStalkers:CooldownRemainsP() > 18 and FutureShard() >= 3 then
        return S.HandOfGuldan:Cast()
    end
    -- power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&soul_shard>=3
    if S.PowerSiphon:IsCastableP() and WildImpsCount() >= 2 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 and Player:BuffDownP(S.DemonicPowerBuff) and FutureShard() >= 3 then
        return S.PowerSiphon:Cast()
    end
    -- hand_of_guldan,if=soul_shard>=5
    if S.HandOfGuldan:IsCastableP() and (FutureShard() >= 5) then
        return S.HandOfGuldan:Cast()
    end
    -- call_action_list,name=build_a_shard
    if (true) then
        if BuildAShard() ~= nil then
            return BuildAShard()
        end
    end
end
        

--- ======= ACTION LISTS =======
local function APL()
    --local Precombat, BuildAShard, DconEpOpener, Implosion, NetherPortal, NetherPortalActive, NetherPortalBuilding
    UpdateRanges()
    --print(HL.GuardiansTable.ImpCount);
	--print(HL.GuardiansTable.ImpTotalEnergy);
	
  	-- call precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and not Player:IsCasting() then
        if Precombat() ~= nil then
            return Precombat()
        end
    end

  if RubimRH.TargetIsValid() then
	if QueueSkill() ~= nil then
        return QueueSkill()
    end
    -- berserking,if=pet.demonic_tyrant.active|target.time_to_die<=15
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and TyranIsActive() then
      return S.Berserking:Cast()
    end
    -- blood_fury,if=pet.demonic_tyrant.active|target.time_to_die<=15
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and TyranIsActive() then
      return S.BloodFury:Cast()
    end
    -- fireblood,if=pet.demonic_tyrant.active|target.time_to_die<=15
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and TyranIsActive() then
      return S.Fireblood:Cast()
    end
	-- trinket1,if=pet.demonic_tyrant.active
	if trinketReady(1) and TyranIsActive() then
        return trinket1
    end
	-- trinket2,if=pet.demonic_tyrant.active
	if trinketReady(2) and TyranIsActive() then
        return trinket2
    end
	-- Mythic+ - interrupt2 (command demon)
	if S.PetStun:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
		return 0, "Interface\\Addons\\Rubim-RH\\Media\\wl_lock_red.tga"
	end
	-- unending resolve,defensive,player.health<=40
    if S.UnendingResolve:IsCastableP() and Player:HealthPercentage() <= mainAddon.db.profile[266].sk1 then
        return S.UnendingResolve:Cast()
    end  
    -- call_action_list,name=dcon_ep_opener,if=azerite.explosive_potential.rank&talent.demonic_consumption.enabled&time<30&!cooldown.summon_demonic_tyrant.remains
    if S.ExplosivePotential:AzeriteEnabled() and RubimRH.CDsON() and S.DemonicConsumption:IsAvailable() and HL.CombatTime() < 30 and S.SummonDemonicTyrant:CooldownRemainsP() <= 5 then
	    if DconEpOpener() ~= nil then
            return DconEpOpener()
        end
    end
    -- hand_of_guldan,if=azerite.explosive_potential.rank&time<5&soul_shard>2&buff.explosive_potential.down&buff.wild_imps.stack<3&!prev_gcd.1.hand_of_guldan&&!prev_gcd.2.hand_of_guldan
    if S.HandOfGuldan:IsCastableP() and S.ExplosivePotential:AzeriteEnabled() and HL.CombatTime() < 5 and FutureShard() > 2 and Player:BuffDownP(S.ExplosivePotentialBuff) and WildImpsCount() < 3 and not Player:PrevGCDP(1, S.HandOfGuldan) and true and not Player:PrevGCDP(2, S.HandOfGuldan) then
      return S.HandOfGuldan:Cast()
    end
    -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&buff.demonic_core.stack=4
    if S.Demonbolt:IsCastableP() and FutureShard() <= 3 and Player:BuffP(S.DemonicCoreBuff) and Player:BuffStackP(S.DemonicCoreBuff) == 4 then
      return S.Demonbolt:Cast()
    end
    -- implosion,if=azerite.explosive_potential.rank&buff.wild_imps.stack>2&buff.explosive_potential.remains<action.shadow_bolt.execute_time
    if S.Implosion:IsCastableP() and not Player:PrevGCDP(1, S.SummonDemonicTyrant) and S.ExplosivePotential:AzeriteEnabled() and WildImpsCount() >= 4 and Player:BuffRemainsP(S.ExplosivePotentialBuff) < S.ShadowBolt:ExecuteTime() then
      return S.Implosion:Cast()
    end
    -- implosion,if=azerite.explosive_potential.rank&buff.wild_imps.stack>2&buff.explosive_potential.remains<cooldown.summon_demonic_tyrant.remains&cooldown.summon_demonic_tyrant.remains<11&talent.demonic_consumption.enabled
    if S.Implosion:IsCastableP() and not Player:PrevGCDP(1, S.SummonDemonicTyrant) and S.ExplosivePotential:AzeriteEnabled() and WildImpsCount() >= 4 and Player:BuffRemainsP(S.ExplosivePotentialBuff) < S.SummonDemonicTyrant:CooldownRemainsP() and S.SummonDemonicTyrant:CooldownRemainsP() < 11 and S.DemonicConsumption:IsAvailable() then
      return S.Implosion:Cast()
    end
    -- doom,if=!ticking&time_to_die>30&spell_targets.implosion<2
    if S.Doom:IsCastableP() and not Target:DebuffP(S.DoomDebuff) and Target:TimeToDie() > 30 and Cache.EnemiesCount[40] < 2 then
      return S.Doom:Cast()
    end
    -- bilescourge_bombers,if=azerite.explosive_potential.rank>0&time<10&spell_targets.implosion<2&buff.dreadstalkers.remains&talent.nether_portal.enabled
    if S.BilescourgeBombers:IsCastableP() and FutureShard() > 1 and S.ExplosivePotential:AzeriteRank() > 0 and HL.CombatTime() < 10 and Cache.EnemiesCount[40] < 2 and DreadStalkersTime() > 1 and S.NetherPortal:IsAvailable() then
      return S.BilescourgeBombers:Cast()
    end
    -- demonic_strength,if=(buff.wild_imps.stack<6|buff.demonic_power.up)|spell_targets.implosion<2
    if S.DemonicStrength:IsCastableP()  and S.FelStorm:CooldownRemainsP() <= 26.5 and ((WildImpsCount() < 6 or Player:BuffP(S.DemonicPowerBuff)) or Cache.EnemiesCount[40] < 2) then
      return S.DemonicStrength:Cast()
    end
    -- call_action_list,name=nether_portal,if=talent.nether_portal.enabled&spell_targets.implosion<=2
    if (S.NetherPortal:CooldownRemainsP() < 20) and RubimRH.CDsON() and S.NetherPortal:IsAvailable() then
        if NetherPortalBuilding() ~= nil then
            return NetherPortalBuilding()
        end
    end
    -- call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>165
    if (S.NetherPortal:CooldownRemainsP() > 165) and RubimRH.CDsON() and S.NetherPortal:IsAvailable() then
        if NetherPortalActive() ~= nil then
            return NetherPortalActive()
        end
    end  
	-- auto target
	if DoomDotCycle() ~= nil then
        return DoomDotCycle()
	end	
    -- call_action_list,name=implosion,if=spell_targets.implosion>1-and RubimRH.PetSpellInRange(30213, target)
    if (active_enemies() > 2) and RubimRH.AoEON() then
        if Implosion() ~= nil then
            return Implosion()
        end
    end
    -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13and (S.SummonDemonicTyrant:CooldownRemainsP() < 13)
    if S.GrimoireFelguard:IsCastableP() and FutureShard() >= 1 and RubimRH.CDsON() then
      return S.GrimoireFelguardHack:Cast()
    end
    -- summon_vilefiend,if=cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
    if S.SummonVilefiend:IsCastableP() and FutureShard() >= 1 and (S.SummonDemonicTyrant:CooldownRemainsP() > 40 or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
      return S.SummonVilefiend:Cast()
    end
        -- actions+=/call_dreadstalkers,if=equipped.132369|(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
        if S.CallDreadStalkers:IsCastable() and (FutureShard() > 1 or (FutureShard() > 0 and Player:BuffRemainsP(S.DemonicCallingBuff) > 0)) and not Player:IsCasting(S.CallDreadStalkers) and ( (S.SummonDemonicTyrant:CooldownRemainsP() < 9 and Player:BuffRemainsP(S.DemonicCallingBuff) > 0) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and Player:BuffRemainsP(S.DemonicCallingBuff) == 0) or S.SummonDemonicTyrant:CooldownRemainsP() > 14 ) then
           return S.CallDreadStalkers:Cast()
        end
    -- bilescourge_bombers
    if S.BilescourgeBombers:IsCastableP() and FutureShard() > 1 then
      return S.BilescourgeBombers:Cast()
    end
    -- summon_demonic_tyrant,if=soul_shard<3&(!talent.demonic_consumption.enabled|buff.wild_imps.stack>0)
    if S.SummonDemonicTyrant:IsCastableP() and FutureShard() < 3 and RubimRH.CDsON() and (not S.DemonicConsumption:IsAvailable() or (Player:PrevGCDP(1, S.HandOfGuldan) and WildImpsCount() > 2 )) then
      return S.SummonDemonicTyrant:Cast()
    end
    -- power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&spell_targets.implosion<2
    if S.PowerSiphon:IsCastableP() and WildImpsCount() >= 2 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 and Player:BuffDownP(S.DemonicPowerBuff) and Cache.EnemiesCount[40] < 2 then
      return S.PowerSiphon:Cast()
    end
    -- doom,if=talent.doom.enabled&refreshable&time_to_die>(dot.doom.remains+30)
    if S.Doom:IsCastableP() and S.Doom:IsAvailable() and Target:DebuffRefreshableCP(S.DoomDebuff) and Target:TimeToDie() > (Target:DebuffRemainsP(S.DoomDebuff) + 30) then
      return S.Doom:Cast()
    end
    -- hand_of_guldan,if=soul_shard>=5|(soul_shard>=3&cooldown.call_dreadstalkers.remains>4&(cooldown.summon_demonic_tyrant.remains>20|(cooldown.summon_demonic_tyrant.remains<gcd*2&talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains<gcd*4&!talent.demonic_consumption.enabled))&(!talent.summon_vilefiend.enabled|cooldown.summon_vilefiend.remains>3))
    if S.HandOfGuldan:IsCastableP() and FutureShard() >= 5 or (FutureShard() >= 3 and S.CallDreadStalkers:CooldownRemainsP() > 4 and (S.SummonDemonicTyrant:CooldownRemainsP() > 20 or (S.SummonDemonicTyrant:CooldownRemainsP() < Player:GCD() * 2 and S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() < Player:GCD() * 4 and not S.DemonicConsumption:IsAvailable())) and (not S.SummonVilefiend:IsAvailable() or S.SummonVilefiend:CooldownRemainsP() > 3)) then
      return S.HandOfGuldan:Cast()
    end
    -- soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
    if S.SoulStrike:IsCastableP() and FutureShard() < 5 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 then
      return S.SoulStrike:Cast()
    end
    -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&((cooldown.summon_demonic_tyrant.remains<6|cooldown.summon_demonic_tyrant.remains>22)|buff.demonic_core.stack>=3|buff.demonic_core.remains<5|time_to_die<25)
    if S.Demonbolt:IsCastableP() and FutureShard() <= 3 and Player:BuffP(S.DemonicCoreBuff) and ((S.SummonDemonicTyrant:CooldownRemainsP() < 6 or S.SummonDemonicTyrant:CooldownRemainsP() > 22) or Player:BuffStackP(S.DemonicCoreBuff) >= 3 or Player:BuffRemainsP(S.DemonicCoreBuff) < 5 or Target:TimeToDie() < 25) then
      return S.Demonbolt:Cast()
    end
    -- call_action_list,name=build_a_shard
        if (true) then
            if BuildAShard() ~= nil then
                return BuildAShard()
            end
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(266, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(266, PASSIVE)