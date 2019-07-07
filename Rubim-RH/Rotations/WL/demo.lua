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
local Arena = Unit.Arena;

RubimRH.Spell[266] = {
  -- Racials
  Berserking                    = Spell(26297),
  BloodFury                     = Spell(20572),
  Fireblood                     = Spell(265221),
  -- Abilities
  DrainLife                     = Spell(234153),
  SummonDemonicTyrant           = Spell(265187),
  SummonImp                     = Spell(688),
  SummonFelguard                = Spell(30146),
  HandOfGuldan                  = Spell(105174),
  ShadowBolt                    = Spell(686),
  Demonbolt                     = Spell(264178),
  CallDreadStalkers             = Spell(104316),
  Fear                          = Spell(5782),
  Implosion                     = Spell(196277),
  Shadowfury                    = Spell(30283),

  -- Pet abilities
  CauterizeMaster               = Spell(119905),--imp
  Suffering                     = Spell(119907),--voidwalker
  Whiplash                      = Spell(119909),--Bitch
  FelStormFake                  = Spell(29893),-- HAck == CreateSoulwell
  FelStorm                      = Spell(89751),--FelGuard
  --PetStun                       = Spell(119914),Patch 4.x ?
  PetStun						= Spell(89766), 
  SpellLock                     = Spell(119898),

  -- Talents
  Dreadlash                     = Spell(264078),
  DemonicStrength               = Spell(267171),
  BilescourgeBombers            = Spell(267211),

  DemonicCalling                = Spell(205145),
  PowerSiphon                   = Spell(264130),
  Doom                          = Spell(265412),
  DoomDebuff                    = Spell(265412),

  DemonSkin                     = Spell(219272),
  BurningRush                   = Spell(111400),
  DarkPact                      = Spell(108416),

  FromTheShadows                = Spell(267170),
  SoulStrike                    = Spell(264057),
  SummonVilefiend               = Spell(264119),

  Darkfury                      = Spell(264874),
  MortalCoil                    = Spell(6789),
  DemonicCircle                 = Spell(268358),

  InnerDemons                   = Spell(267216),
  SoulConduit                   = Spell(215941),
  GrimoireFelguard              = Spell(108503), -- Hack id for proper pixel Original SpellID = 111898

  SacrificedSouls               = Spell(267214),
  DemonicConsumption            = Spell(267215),
  NetherPortal                  = Spell(267217),
  NetherPortalBuff              = Spell(267218),

  -- Defensive
  UnendingResolve               = Spell(104773),

  -- Azerite
  ForbiddenKnowledge            = Spell(279666),
  BalefulInvocation             = Spell(287059),
  ExplosivePotentialBuff        = Spell(275398),
  ExplosivePotential            = Spell(275395),
  ShadowsBite                   = Spell(272944),
  ShadowsBiteBuff               = Spell(272945),

  -- Utility
  TargetEnemy                   = Spell(153911),--doesnt work
  CreateHealthstone             = Spell(6201),--using this instead to target enemy
  DemonicCircleTeleport         = Spell(48020),  

  -- Misc
  DemonicCallingBuff            = Spell(205146),
  DemonicCoreBuff               = Spell(264173),
  DemonicPowerBuff              = Spell(265273),
  
  -- PvP Talents
  NetherWard                   = Spell(212295),
  CurseOfWeakness              = Spell(199892),
  CallFelLord                  = Spell(212459),
  CallObserver                 = Spell(201996),
  
  --8.2 Essences
  UnleashHeartOfAzeroth        = Spell(280431),
  BloodOfTheEnemy              = Spell(297108),
  BloodOfTheEnemy2             = Spell(298273),
  BloodOfTheEnemy3             = Spell(298277),
  ConcentratedFlame            = Spell(295373),
  ConcentratedFlame2           = Spell(299349),
  ConcentratedFlame3           = Spell(299353),
  GuardianOfAzeroth            = Spell(295840),
  GuardianOfAzeroth2           = Spell(299355),
  GuardianOfAzeroth3           = Spell(299358),
  FocusedAzeriteBeam           = Spell(295258),
  FocusedAzeriteBeam2          = Spell(299336),
  FocusedAzeriteBeam3          = Spell(299338),
  PurifyingBlast               = Spell(295337),
  PurifyingBlast2              = Spell(299345),
  PurifyingBlast3              = Spell(299347),
  TheUnboundForce              = Spell(298452),
  TheUnboundForce2             = Spell(299376),
  TheUnboundForce3             = Spell(299378),
  RippleInSpace                = Spell(302731),
  RippleInSpace2               = Spell(302982),
  RippleInSpace3               = Spell(302983),
  WorldveinResonance           = Spell(295186),
  WorldveinResonance2          = Spell(298628),
  WorldveinResonance3          = Spell(299334),
  MemoryOfLucidDreams          = Spell(298357),
  MemoryOfLucidDreams2         = Spell(299372),
  MemoryOfLucidDreams3         = Spell(299374),
};

local S = RubimRH.Spell[266]
-- Rotation Var
local ShouldReturn; -- Used to get the return string
-- Items
if not Item.Warlock then
        Item.Warlock = {}
end
Item.Warlock.Demonology = {
  BattlePotionOfIntellect       = Item(163222)
};
local I = Item.Warlock.Demonology

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end
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

  if Player:IsCasting(S.HandOfGuldan) then
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

local function DetermineEssenceRanks()
  S.BloodOfTheEnemy = S.BloodOfTheEnemy2:IsAvailable() and S.BloodOfTheEnemy2 or S.BloodOfTheEnemy
  S.BloodOfTheEnemy = S.BloodOfTheEnemy3:IsAvailable() and S.BloodOfTheEnemy3 or S.BloodOfTheEnemy
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams2:IsAvailable() and S.MemoryOfLucidDreams2 or S.MemoryOfLucidDreams
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams3:IsAvailable() and S.MemoryOfLucidDreams3 or S.MemoryOfLucidDreams
  S.PurifyingBlast = S.PurifyingBlast2:IsAvailable() and S.PurifyingBlast2 or S.PurifyingBlast
  S.PurifyingBlast = S.PurifyingBlast3:IsAvailable() and S.PurifyingBlast3 or S.PurifyingBlast
  S.RippleInSpace = S.RippleInSpace2:IsAvailable() and S.RippleInSpace2 or S.RippleInSpace
  S.RippleInSpace = S.RippleInSpace3:IsAvailable() and S.RippleInSpace3 or S.RippleInSpace
  S.ConcentratedFlame = S.ConcentratedFlame2:IsAvailable() and S.ConcentratedFlame2 or S.ConcentratedFlame
  S.ConcentratedFlame = S.ConcentratedFlame3:IsAvailable() and S.ConcentratedFlame3 or S.ConcentratedFlame
  S.TheUnboundForce = S.TheUnboundForce2:IsAvailable() and S.TheUnboundForce2 or S.TheUnboundForce
  S.TheUnboundForce = S.TheUnboundForce3:IsAvailable() and S.TheUnboundForce3 or S.TheUnboundForce
  S.WorldveinResonance = S.WorldveinResonance2:IsAvailable() and S.WorldveinResonance2 or S.WorldveinResonance
  S.WorldveinResonance = S.WorldveinResonance3:IsAvailable() and S.WorldveinResonance3 or S.WorldveinResonance
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam2:IsAvailable() and S.FocusedAzeriteBeam2 or S.FocusedAzeriteBeam
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam3:IsAvailable() and S.FocusedAzeriteBeam3 or S.FocusedAzeriteBeam
end

-- # Essences
local function Essences()
  -- blood_of_the_enemy

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
  if S.MemoryOfLucidDreams:IsCastableP() and FutureShard() < 2 and S.SummonDemonicTyrant:CooldownRemainsP() < 10 then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  return false
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat_DBM, Precombat, BuildAShard, DconOpener, Implosion, NetherPortal, NetherPortalActive, NetherPortalBuilding
  UpdateRanges()
  UpdatePetTable()
  UpdateSoulShards()
  DetermineEssenceRanks()
  
  -- Precombat DBM
  Precombat_DBM = function()
    -- flask
    -- food
    -- augmentation
    -- actions.precombat+=/summon_pet
    if not Pet:Exists() and FutureShard() >= 1 then
        return S.SummonFelguard:Cast()
    end
	-- potion
    if I.BattlePotionOfIntellect:IsReady() and RubimRH.DBM_PullTimer() >= S.Demonbolt:CastTime() + 1 and RubimRH.DBM_PullTimer() <= S.Demonbolt:CastTime() + 2 then
        return 967532
    end
    -- inner_demons,if=talent.inner_demons.enabled
    if S.InnerDemons:IsCastableP() and (S.InnerDemons:IsAvailable()) then
      return S.InnerDemons:Cast()
    end
    -- snapshot_stats
	-- potion
    -- demonbolt
    if S.Demonbolt:IsCastableP() and not Player:IsCasting(S.Demonbolt) and not Player:PrevGCDP(1, S.Demonbolt) and RubimRH.DBM_PullTimer() > 0.1 and RubimRH.DBM_PullTimer() <= S.Demonbolt:CastTime() + S.Demonbolt:TravelTime() then
      return S.Demonbolt:Cast()
    end
  end
  
  -- Precombat
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- actions.precombat+=/summon_pet
    if not Pet:Exists() and FutureShard() >= 1 then
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
  
  -- Shard generator
  BuildAShard = function()
        -- soul_strike,if=!talent.demonic_consumption.enabled|time>15|prev_gcd.1.hand_of_guldan&!buff.bloodlust.remains
        if S.SoulStrike:IsCastableP() and FutureShard() < 5 and (not S.DemonicConsumption:IsAvailable() or HL.CombatTime() > 15 or Player:PrevGCDP(1, S.HandOfGuldan) and not Player:HasHeroism()) then
          return S.SoulStrike:Cast()
        end
        -- shadow_bolt
        if S.ShadowBolt:IsCastableP() and not Player:IsCasting(S.ShadowBolt) and FutureShard() < 5 then
          return S.ShadowBolt:Cast()
        end
  end
  
  -- Demonic consumption opener
  DconOpener = function()
        -- hand_of_guldan,line_cd=30,if=azerite.explosive_potential.enabled
        if S.HandOfGuldan:IsCastableP() and not Player:PrevGCDP(1, S.HandOfGuldan) and (HL.CombatTime() < 2 and Player:SoulShardsP() > 2 and S.ExplosivePotential:AzeriteEnabled()) then
          return S.HandOfGuldan:Cast()
        end
        -- implosion,if=azerite.explosive_potential.enabled&buff.wild_imps.stack>2&buff.explosive_potential.down
        if S.Implosion:IsCastableP() and S.ExplosivePotential:AzeriteEnabled() and WildImpsCount() > 2 and Player:BuffDownP(S.ExplosivePotentialBuff) then
          return S.Implosion:Cast()
        end
        -- doom,line_cd=30
        if S.Doom:IsCastableP() and (Target:DebuffRefreshableCP(S.DoomDebuff)) then
          return S.Doom:Cast()
        end
        -- hand_of_guldan,if=prev_gcd.1.hand_of_guldan&soul_shard>0&prev_gcd.2.soul_strike
        if S.HandOfGuldan:IsCastableP() and Player:PrevGCDP(1, S.HandOfGuldan) and Player:SoulShardsP() > 0 and Player:PrevGCDP(2, S.SoulStrike) then
          return S.HandOfGuldan:Cast()
        end
		  -- memory_of_lucid_dreams
        if S.MemoryOfLucidDreams:IsCastableP() and FutureShard() < 5 and Player:PrevGCDP(1, S.HandOfGuldan) and HL.CombatTime() > 3 then
           return S.UnleashHeartOfAzeroth:Cast()
        end
        -- demonic_strength,if=prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan&(buff.wild_imps.stack>1&action.hand_of_guldan.in_flight)
        if S.DemonicStrength:IsReadyP() and S.FelStorm:CooldownRemainsP() <= 26.5 and (Player:PrevGCDP(1, S.HandOfGuldan) and not Player:PrevGCDP(2, S.HandOfGuldan) and (WildImpsCount() > 1 and S.HandOfGuldan:InFlight())) then
          return S.DemonicStrength:Cast()
        end
        -- bilescourge_bombers
        if S.BilescourgeBombers:IsReadyP() then
          return S.BilescourgeBombers:Cast()
        end
        -- soul_strike,line_cd=30,if=!buff.bloodlust.remains|time>5&prev_gcd.1.hand_of_guldan
        if S.SoulStrike:IsCastableP() and (not Player:HasHeroism() or HL.CombatTime() > 5 and Player:PrevGCDP(1, S.HandOfGuldan)) then
          return S.SoulStrike:Cast()
        end
        -- summon_vilefiend,if=soul_shard=5
        if S.SummonVilefiend:IsReadyP() and (Player:SoulShardsP() == 5) then
          return S.SummonVilefiend:Cast()
        end
        -- grimoire_felguard,if=soul_shard=5
        if S.GrimoireFelguard:IsReadyP() and (Player:SoulShardsP() == 5) then
          return S.GrimoireFelguard:Cast()
        end
        -- call_dreadstalkers,if=soul_shard=5
        if S.CallDreadStalkers:IsReadyP() and (Player:SoulShardsP() == 5) then
          return S.CallDreadStalkers:Cast()
        end
        -- hand_of_guldan,if=soul_shard=5
        if S.HandOfGuldan:IsCastableP() and (Player:SoulShardsP() == 5) then
          return S.HandOfGuldan:Cast()
        end
        -- hand_of_guldan,if=soul_shard>=3&prev_gcd.2.hand_of_guldan&time>5&(prev_gcd.1.soul_strike|!talent.soul_strike.enabled&prev_gcd.1.shadow_bolt)
        if S.HandOfGuldan:IsCastableP() and (Player:SoulShardsP() >= 3 and Player:PrevGCDP(2, S.HandOfGuldan) and HL.CombatTime() > 5 and (Player:PrevGCDP(1, S.SoulStrike) or not S.SoulStrike:IsAvailable() and Player:PrevGCDP(1, S.ShadowBolt))) then
          return S.HandOfGuldan:Cast()
        end
        -- summon_demonic_tyrant,if=prev_gcd.1.demonic_strength|prev_gcd.1.hand_of_guldan&prev_gcd.2.hand_of_guldan|!talent.demonic_strength.enabled&buff.wild_imps.stack+imps_spawned_during.2000%spell_haste>=6
        if S.SummonDemonicTyrant:IsCastableP() and ( (Player:PrevGCDP(1, S.HandOfGuldan) and Player:PrevGCDP(2, S.HandOfGuldan)) or (WildImpsCount() + ImpsSpawnedDuring(2000) > 6) ) then
          return S.SummonDemonicTyrant:Cast()
        end
        -- demonbolt,if=soul_shard<=3&buff.demonic_core.remains
        if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and bool(Player:BuffRemainsP(S.DemonicCoreBuff))) then
          return S.Demonbolt:Cast()
        end
        -- call_action_list,name=build_a_shard
        if (true) then
          local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
        end
  end
  
  --Implosion cycle 
  Implosion = function()
       	-- implosion,if=PetStack.imps>=mainAddon.db.profile[266].sk2+RubimRH.AoEON
        if S.Implosion:IsCastableP() and not Player:PrevGCDP(1, S.SummonDemonicTyrant) and not Player:PrevGCDP(1, S.Implosion) and WildImpsCount() > 2 and WildImpsCount() >= mainAddon.db.profile[266].sk2 and RubimRH.AoEON() and not Player:PrevGCDP(1, S.SummonDemonicTyrant) then
          return S.Implosion:Cast()
        end  
        -- implosion,if=(buff.wild_imps.stack>=6&(soul_shard<3|prev_gcd.1.call_dreadstalkers|buff.wild_imps.stack>=9|prev_gcd.1.bilescourge_bombers|(!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan))&!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan&buff.demonic_power.down)|(time_to_die<3&buff.wild_imps.stack>0)|(prev_gcd.2.call_dreadstalkers&buff.wild_imps.stack>2&!talent.demonic_calling.enabled)
        if S.Implosion:IsCastableP() and ((WildImpsCount() >= 6 and (Player:SoulShardsP() < 3 or Player:PrevGCDP(1, S.CallDreadStalkers) or WildImpsCount() >= 9 or Player:PrevGCDP(1, S.BilescourgeBombers) or (not Player:PrevGCDP(1, S.HandOfGuldan) and not Player:PrevGCDP(2, S.HandOfGuldan))) and not Player:PrevGCDP(1, S.HandOfGuldan) and not Player:PrevGCDP(2, S.HandOfGuldan) and Player:BuffDownP(S.DemonicPowerBuff)) or (Target:TimeToDie() < 3 and WildImpsCount() > 0) or (Player:PrevGCDP(2, S.CallDreadStalkers) and WildImpsCount() > 2 and not S.DemonicCalling:IsAvailable())) then
          return S.Implosion:Cast()
        end
        -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
        if S.GrimoireFelguard:IsReadyP() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13) and RubimRH.CDsON() then
          return S.GrimoireFelguard:Cast()
        end
        -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
        if S.CallDreadStalkers:IsReadyP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
          return S.CallDreadStalkers:Cast()
        end
        -- summon_demonic_tyrant
        if S.SummonDemonicTyrant:IsCastableP() and RubimRH.CDsON() and Target:TimeToDie() >= 25 then
          return S.SummonDemonicTyrant:Cast()
        end
        -- hand_of_guldan,if=soul_shard>=5
        if S.HandOfGuldan:IsCastableP() and (Player:SoulShardsP() >= 5) then
          return S.HandOfGuldan:Cast()
        end
        -- hand_of_guldan,if=soul_shard>=3&(((prev_gcd.2.hand_of_guldan|buff.wild_imps.stack>=3)&buff.wild_imps.stack<9)|cooldown.summon_demonic_tyrant.remains<=gcd*2|buff.demonic_power.remains>gcd*2)
        if S.HandOfGuldan:IsCastableP() and (Player:SoulShardsP() >= 3 and (((Player:PrevGCDP(2, S.HandOfGuldan) or WildImpsCount() >= 3) and WildImpsCount() < 9) or S.SummonDemonicTyrant:CooldownRemainsP() <= Player:GCD() * 2 or Player:BuffRemainsP(S.DemonicPowerBuff) > Player:GCD() * 2)) then
          return S.HandOfGuldan:Cast()
        end
        -- demonbolt,if=prev_gcd.1.hand_of_guldan&soul_shard>=1&(buff.wild_imps.stack<=3|prev_gcd.3.hand_of_guldan)&soul_shard<4&buff.demonic_core.up
        if S.Demonbolt:IsCastableP() and (Player:PrevGCDP(1, S.HandOfGuldan) and Player:SoulShardsP() >= 1 and (WildImpsCount() <= 3 or Player:PrevGCDP(3, S.HandOfGuldan)) and Player:SoulShardsP() < 4 and Player:BuffP(S.DemonicCoreBuff)) then
          return S.Demonbolt:Cast()
        end
        -- summon_vilefiend,if=(cooldown.summon_demonic_tyrant.remains>40&spell_targets.implosion<=2)|cooldown.summon_demonic_tyrant.remains<12
        if S.SummonVilefiend:IsReadyP() and ((S.SummonDemonicTyrant:CooldownRemainsP() > 40 and active_enemies() <= 2) or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
          return S.SummonVilefiend:Cast()
        end
        -- bilescourge_bombers,if=cooldown.summon_demonic_tyrant.remains>9
        if S.BilescourgeBombers:IsReadyP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 9) then
          return S.BilescourgeBombers:Cast()
        end
        -- soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
        if S.SoulStrike:IsCastableP() and (Player:SoulShardsP() < 5 and Player:BuffStackP(S.DemonicCoreBuff) <= 2) then
          return S.SoulStrike:Cast()
        end
        -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&(buff.demonic_core.stack>=3|buff.demonic_core.remains<=gcd*5.7)
        if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and Player:BuffP(S.DemonicCoreBuff) and (Player:BuffStackP(S.DemonicCoreBuff) >= 3 or Player:BuffRemainsP(S.DemonicCoreBuff) <= Player:GCD() * 5.7)) then
          return S.Demonbolt:Cast()
        end
        -- doom,cycle_targets=1,max_cycle_targets=7,if=refreshable
        if S.Doom:IsCastableP() then
          return S.Doom:Cast()
        end
        -- call_action_list,name=build_a_shard
        if (true) then
          local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
        end
  end
  -- NetherPortal handler
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
  -- NetherPortal active
  NetherPortalActive = function()
        -- bilescourge_bombers
        if S.BilescourgeBombers:IsReadyP() then
          return S.BilescourgeBombers:Cast()
        end
        -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
        if S.GrimoireFelguard:IsReadyP() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13) then
          return S.GrimoireFelguard:Cast()
        end
        -- summon_vilefiend,if=cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
        if S.SummonVilefiend:IsReadyP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 40 or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
          return S.SummonVilefiend:Cast()
        end
        -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
        if S.CallDreadStalkers:IsReadyP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
          return S.CallDreadStalkers:Cast()
        end
        -- call_action_list,name=build_a_shard,if=soul_shard=1&(cooldown.call_dreadstalkers.remains<action.shadow_bolt.cast_time|(talent.bilescourge_bombers.enabled&cooldown.bilescourge_bombers.remains<action.shadow_bolt.cast_time))
        if (Player:SoulShardsP() == 1 and (S.CallDreadStalkers:CooldownRemainsP() < S.ShadowBolt:CastTime() or (S.BilescourgeBombers:IsAvailable() and S.BilescourgeBombers:CooldownRemainsP() < S.ShadowBolt:CastTime()))) then
          local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
        end
        -- hand_of_guldan,if=((cooldown.call_dreadstalkers.remains>action.demonbolt.cast_time)&(cooldown.call_dreadstalkers.remains>action.shadow_bolt.cast_time))&cooldown.nether_portal.remains>(165+action.hand_of_guldan.cast_time)
        if S.HandOfGuldan:IsCastableP() and (Player:SoulShardsP() > 0 and ((S.CallDreadStalkers:CooldownRemainsP() > S.Demonbolt:CastTime()) and (S.CallDreadStalkers:CooldownRemainsP() > S.ShadowBolt:CastTime())) and S.NetherPortal:CooldownRemainsP() > (165 + S.HandOfGuldan:CastTime())) then
          return S.HandOfGuldan:Cast()
        end
        -- summon_demonic_tyrant,if=buff.nether_portal.remains<5&soul_shard=0
        if S.SummonDemonicTyrant:IsCastableP() and (Player:BuffRemainsP(S.NetherPortalBuff) < 5 and Player:SoulShardsP() == 0) then
          return S.SummonDemonicTyrant:Cast()
        end
        -- summon_demonic_tyrant,if=buff.nether_portal.remains<action.summon_demonic_tyrant.cast_time+0.5
        if S.SummonDemonicTyrant:IsCastableP() and (Player:BuffRemainsP(S.NetherPortalBuff) < S.SummonDemonicTyrant:CastTime() + 0.5) then
          return S.SummonDemonicTyrant:Cast()
        end
        -- demonbolt,if=buff.demonic_core.up&soul_shard<=3
        if S.Demonbolt:IsCastableP() and (Player:BuffP(S.DemonicCoreBuff) and Player:SoulShardsP() <= 3) then
          return S.Demonbolt:Cast()
        end
        -- call_action_list,name=build_a_shard
        if (true) then
          local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
        end
  end
  -- NetherPortal generator
  NetherPortalBuilding = function()
        -- nether_portal,if=soul_shard>=5&(!talent.power_siphon.enabled|buff.demonic_core.up)
        if S.NetherPortal:IsReadyP() and (Player:SoulShardsP() >= 5 and (not S.PowerSiphon:IsAvailable() or Player:BuffP(S.DemonicCoreBuff))) then
          return S.NetherPortal:Cast()
        end
        -- call_dreadstalkers
        if S.CallDreadStalkers:IsReadyP() then
          return S.CallDreadStalkers:Cast()
        end
        -- hand_of_guldan,if=cooldown.call_dreadstalkers.remains>18&soul_shard>=3
        if S.HandOfGuldan:IsCastableP() and (S.CallDreadStalkers:CooldownRemainsP() > 18 and Player:SoulShardsP() >= 3) then
          return S.HandOfGuldan:Cast()
        end
        -- power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&soul_shard>=3
        if S.PowerSiphon:IsCastableP() and (WildImpsCount() >= 2 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 and Player:BuffDownP(S.DemonicPowerBuff) and Player:SoulShardsP() >= 3) then
          return S.PowerSiphon:Cast()
        end
        -- hand_of_guldan,if=soul_shard>=5
        if S.HandOfGuldan:IsCastableP() and (Player:SoulShardsP() >= 5) then
          return S.HandOfGuldan:Cast()
        end
        -- call_action_list,name=build_a_shard
        if (true) then
          local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
        end
  end
  
  -- call precombat
  if not Player:AffectingCombat() and not Player:IsCasting() then
        local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  
  -- combat
  if RubimRH.TargetIsValid() then
        -- Queue system
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
-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn and (true) then return ShouldReturn; end
	    -- trinket1,if=pet.demonic_tyrant.active
	    if trinketReady(1) and TyranIsActive() then
            return trinket1
        end
	    -- trinket2,if=pet.demonic_tyrant.active
    	if trinketReady(2) and TyranIsActive() then
            return trinket2
        end
		-- Blood of the enemy with Tyran sync
		if S.BloodOfTheEnemy:IsCastableP() and TyranIsActive() then
            return S.UnleashHeartOfAzeroth:Cast()
        end
	    -- Mythic+ - interrupt2 (command demon)
    	if S.PetStun:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
    		return 0, "Interface\\Addons\\Rubim-RH\\Media\\wl_lock_red.tga"
    	end
     	-- unending resolve,defensive,player.health<=40
        if S.UnendingResolve:IsCastableP() and Player:HealthPercentage() <= mainAddon.db.profile[266].sk1 then
            return S.UnendingResolve:Cast()
        end  
        -- call_action_list,name=dcon_opener,if=talent.demonic_consumption.enabled&time<30&!cooldown.summon_demonic_tyrant.remains
        if (S.DemonicConsumption:IsAvailable() and HL.CombatTime() < 30 and not bool(S.SummonDemonicTyrant:CooldownRemainsP())) and RubimRH.CDsON() then
          local ShouldReturn = DconOpener(); if ShouldReturn then return ShouldReturn; end
        end
        -- hand_of_guldan,if=azerite.explosive_potential.rank&time<5&soul_shard>2&buff.explosive_potential.down&buff.wild_imps.stack<3&!prev_gcd.1.hand_of_guldan&&!prev_gcd.2.hand_of_guldan
        if S.HandOfGuldan:IsCastableP() and (bool(S.ExplosivePotential:AzeriteRank()) and HL.CombatTime() < 5 and Player:SoulShardsP() > 2 and Player:BuffDownP(S.ExplosivePotentialBuff) and WildImpsCount() < 3 and not Player:PrevGCDP(1, S.HandOfGuldan) and not Player:PrevGCDP(2, S.HandOfGuldan)) then
          return S.HandOfGuldan:Cast()
        end
        -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&buff.demonic_core.stack=4
        if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and Player:BuffP(S.DemonicCoreBuff) and Player:BuffStackP(S.DemonicCoreBuff) == 4) then
          return S.Demonbolt:Cast()
        end
        -- implosion,if=azerite.explosive_potential.rank&buff.wild_imps.stack>2&buff.explosive_potential.remains<action.shadow_bolt.execute_time&(!talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains>12)
        if S.Implosion:IsCastableP() and (bool(S.ExplosivePotential:AzeriteRank()) and WildImpsCount() > 2 and Player:BuffRemainsP(S.ExplosivePotentialBuff) < S.ShadowBolt:ExecuteTime() and (not S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() > 10)) then
          return S.Implosion:Cast()
        end
        -- doom,if=!ticking&time_to_die>30&spell_targets.implosion<2
        if S.Doom:IsCastableP() and (not Target:DebuffP(S.DoomDebuff) and Target:TimeToDie() > 30 and active_enemies() < 2) then
          return S.Doom:Cast()
        end
        -- bilescourge_bombers,if=azerite.explosive_potential.rank>0&time<10&spell_targets.implosion<2&buff.dreadstalkers.remains&talent.nether_portal.enabled
        if S.BilescourgeBombers:IsReadyP() and (S.ExplosivePotential:AzeriteRank() > 0 and HL.CombatTime() < 10 and active_enemies() < 2 and DreadStalkersTime() > 0 and S.NetherPortal:IsAvailable()) then
          return S.BilescourgeBombers:Cast()
        end
        -- demonic_strength,if=(buff.wild_imps.stack<6|buff.demonic_power.up)|spell_targets.implosion<2
        if S.DemonicStrength:IsReadyP() and S.FelStorm:CooldownRemainsP() <= 26.5 and ((WildImpsCount() < 6 or Player:BuffP(S.DemonicPowerBuff)) or active_enemies() < 2) then
          return S.DemonicStrength:Cast()
        end
        -- call_action_list,name=nether_portal,if=talent.nether_portal.enabled&spell_targets.implosion<=2
        if (S.NetherPortal:IsAvailable() and active_enemies() <= 2) and RubimRH.CDsON() then
          local ShouldReturn = NetherPortal(); if ShouldReturn then return ShouldReturn; end
        end
        -- call_action_list,name=implosion,if=spell_targets.implosion>1
        if active_enemies() > 1 and RubimRH.AoEON() then
          local ShouldReturn = Implosion(); if ShouldReturn then return ShouldReturn; end
        end
        -- grimoire_felguard,if=(target.time_to_die>120|target.time_to_die<cooldown.summon_demonic_tyrant.remains+15|cooldown.summon_demonic_tyrant.remains<13)
        if S.GrimoireFelguard:IsReadyP() and RubimRH.CDsON() and ((Target:TimeToDie() > 120 or Target:TimeToDie() < S.SummonDemonicTyrant:CooldownRemainsP() + 15 or S.SummonDemonicTyrant:CooldownRemainsP() < 13)) then
          return S.GrimoireFelguard:Cast()
        end
        -- summon_vilefiend,if=cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
        if S.SummonVilefiend:IsReadyP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 40 or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
          return S.SummonVilefiend:Cast()
        end
        -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
        if S.CallDreadStalkers:IsReadyP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
          return S.CallDreadStalkers:Cast()
        end
        -- bilescourge_bombers
        if S.BilescourgeBombers:IsReadyP() then
          return S.BilescourgeBombers:Cast()
        end
        -- hand_of_guldan,if=(azerite.baleful_invocation.enabled|talent.demonic_consumption.enabled)&prev_gcd.1.hand_of_guldan&cooldown.summon_demonic_tyrant.remains<2
        if S.HandOfGuldan:IsCastableP() and ((S.BalefulInvocation:AzeriteEnabled() or S.DemonicConsumption:IsAvailable()) and Player:PrevGCDP(1, S.HandOfGuldan) and S.SummonDemonicTyrant:CooldownRemainsP() < 2 and Player:SoulShardsP() > 0) then
          return S.HandOfGuldan:Cast()
        end
        -- summon_demonic_tyrant,if=soul_shard<3&(!talent.demonic_consumption.enabled|buff.wild_imps.stack+imps_spawned_during.2000%spell_haste>=6&time_to_imps.all.remains<cast_time)|target.time_to_die<20
        if S.SummonDemonicTyrant:IsCastableP() and RubimRH.CDsON() and (Player:SoulShardsP() < 3 and (not S.DemonicConsumption:IsAvailable() or WildImpsCount() + ImpsSpawnedDuring(2000) >= 6) or Target:TimeToDie() < 20) then
          return S.SummonDemonicTyrant:Cast()
        end
        -- power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&spell_targets.implosion<2
        if S.PowerSiphon:IsCastableP() and (WildImpsCount() >= 2 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 and Player:BuffDownP(S.DemonicPowerBuff) and active_enemies() < 2) then
          return S.PowerSiphon:Cast()
        end
        -- doom,if=talent.doom.enabled&refreshable&time_to_die>(dot.doom.remains+30)
        if S.Doom:IsCastableP() and (S.Doom:IsAvailable() and Target:DebuffRefreshableCP(S.DoomDebuff) and Target:TimeToDie() > (Target:DebuffRemainsP(S.DoomDebuff) + 30)) then
          return S.Doom:Cast()
        end
        -- hand_of_guldan,if=soul_shard>=5|(soul_shard>=3&cooldown.call_dreadstalkers.remains>4&(cooldown.summon_demonic_tyrant.remains>20|(cooldown.summon_demonic_tyrant.remains<gcd*2&talent.demonic_consumption.enabled|cooldown.summon_demonic_tyrant.remains<gcd*4&!talent.demonic_consumption.enabled))&(!talent.summon_vilefiend.enabled|cooldown.summon_vilefiend.remains>3))
        if S.HandOfGuldan:IsCastableP() and (Player:SoulShardsP() >= 5 or (Player:SoulShardsP() >= 3 and S.CallDreadStalkers:CooldownRemainsP() > 4 and (S.SummonDemonicTyrant:CooldownRemainsP() > 20 or (S.SummonDemonicTyrant:CooldownRemainsP() < Player:GCD() * 2 and S.DemonicConsumption:IsAvailable() or S.SummonDemonicTyrant:CooldownRemainsP() < Player:GCD() * 4 and not S.DemonicConsumption:IsAvailable())) and (not S.SummonVilefiend:IsAvailable() or S.SummonVilefiend:CooldownRemainsP() > 3))) then
          return S.HandOfGuldan:Cast()
        end
        -- soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
        if S.SoulStrike:IsCastableP() and (Player:SoulShardsP() < 5 and Player:BuffStackP(S.DemonicCoreBuff) <= 2) then
          return S.SoulStrike:Cast()
        end
        -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&((cooldown.summon_demonic_tyrant.remains<6|cooldown.summon_demonic_tyrant.remains>22&!azerite.shadows_bite.enabled)|buff.demonic_core.stack>=3|buff.demonic_core.remains<5|time_to_die<25|buff.shadows_bite.remains)
        if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and Player:BuffP(S.DemonicCoreBuff) and ((S.SummonDemonicTyrant:CooldownRemainsP() < 6 or S.SummonDemonicTyrant:CooldownRemainsP() > 22 and not S.ShadowsBite:AzeriteEnabled()) or Player:BuffStackP(S.DemonicCoreBuff) >= 3 or Player:BuffRemainsP(S.DemonicCoreBuff) < 5 or Target:TimeToDie() < 25 or bool(Player:BuffRemainsP(S.ShadowsBiteBuff)))) then
          return S.Demonbolt:Cast()
        end
        -- call_action_list,name=build_a_shard
        if (true) then
            local ShouldReturn = BuildAShard(); if ShouldReturn then return ShouldReturn; end
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(266, APL)

local function findEnemyHealer()
    for i = 1, 3 do
        local enemyHealer = "None"
        if GetSpecializationRoleByID(GetArenaOpponentSpec(i)) == "HEALER" then
            print("arena" .. i)
			enemyHealer = i
            break
        end
    end
	return enemyHealer
end

local function PvP()
    -- If we are in arena
    if select(2, IsInInstance()) == "arena" then
        -- For each possible target in current arena, handle differents situations...
        for i, arenaTarget in pairs(Arena) do
		    -- Pet Stun Target Arena enemy casting a heal
            if not arenaTarget:IsImmune() and arenaTarget:CastingHealing() and arenaTarget:IsInterruptible() and S.PetStun:IsReady() and arenaTarget:MinDistanceToPlayer() <= 30 then
                RubimRH.getArenaTarget(arenaTarget)
            end
            -- Pet Stun Target Arena enemy casting a CC
            if not arenaTarget:IsImmune() and arenaTarget:CastingCC() and arenaTarget:IsInterruptible() and S.PetStun:IsReady() and arenaTarget:MinDistanceToPlayer() <= 30 then
                RubimRH.getArenaTarget(arenaTarget)
            end
            -- NetherWard Target Arena enemy casting a CC
            if not arenaTarget:IsImmune() and arenaTarget:CastingCC() and arenaTarget:IsInterruptible() and S.NetherWard:IsCastable() and arenaTarget:CastPercentage() >= randomGenerator("Reflect") then
                RubimRH.getArenaTarget(arenaTarget)
            end
            -- NetherWard Target Arena enemy casting a BigDamage spell
            if not arenaTarget:IsImmune() and arenaTarget:IsBursting() and arenaTarget:IsInterruptible() and S.NetherWard:IsCastable() and arenaTarget:CastPercentage() >= randomGenerator("Reflect") then
                RubimRH.getArenaTarget(arenaTarget)
            end
		    -- MortalCoil Target Arena enemy casting a heal
            if not arenaTarget:IsImmune() and arenaTarget:CastingHealing() and arenaTarget:IsInterruptible() and S.MortalCoil:IsReady() and arenaTarget:MinDistanceToPlayer() <= 30 then
                RubimRH.getArenaTarget(arenaTarget)
            end
            -- MortalCoil Target Arena enemy casting a CC
            if not arenaTarget:IsImmune() and arenaTarget:CastingCC() and arenaTarget:IsInterruptible() and S.MortalCoil:IsReady() and arenaTarget:MinDistanceToPlayer() <= 30 then
                RubimRH.getArenaTarget(arenaTarget)
            end
            -- CurseOfWeakness Target Arena enemy currently bursting (Melee)
            if not arenaTarget:IsImmune() and S.CurseOfWeakness:IsCastable() and arenaTarget:IsMelee() and arenaTarget:IsBursting() and arenaTarget:MinDistanceToPlayer(true) <= 30 then
                S.CurseOfWeakness:ArenaCast(arenaTarget)
                return
            end
            -- MortalCoil Healer if one of the Arena target Health < 20%
            if not arenaTarget:IsImmune() and S.MortalCoil:IsCastable() and (arenaTarget:CastingHealing() or arenaTarget:HealthPercentage() <= 20) and arenaTarget:MinDistanceToPlayer(true) <= 30 then				
                S.MortalCoil:ArenaCast(arenaTarget)
                return
            end
			-- Panic Demonic Circle : Teleport if player HP < 30% and arena target is bursting and we dont have UnendingResolve ready
			if Player:HealthPercentage() <= 30 and not S.UnendingResolve:IsReady() and arenaTarget:IsBursting() and arenaTarget:IsTargeting(Player) then 
			    return S.DemonicCircleTeleport:Cast()
			end
			-- Demonic Circle : Teleport if player is bursting and arenaTarget is casting a CC on player
			if Player:IsBursting() and arenaTarget:CastingCC() and arenaTarget:IsTargeting(Player) then 
			    return S.DemonicCircleTeleport:Cast()
			end
        end
    end

    -- If we got a current arena target selected...
    if Target:Exists() then
	    -- Cast NetherWard to reflect current incoming CC
        if not Target:IsImmune() and Target:CastingCC() and Target:IsTargeting(Player) and S.NetherWard:IsCastable() and Target:CastPercentage() >= randomGenerator("Reflect") then
            return S.NetherWard:Cast()
        end
	    -- Cast PetStun if we got a valid target in the 30 yards range
        if S.PetStun:IsReadyP() and Target:MinDistanceToPlayer(true) <= 30 and (Target:CastingHealing() or Target:CastingCC()) and RubimRH.PetSpellInRange(S.PetStun, Target) then 
            return 0, "Interface\\Addons\\Rubim-RH\\Media\\wl_lock_red.tga"
        end
		-- Cast MortalCoil if we got a valid target in the 30 yards range
        if S.MortalCoil:IsReadyP() and Target:MinDistanceToPlayer(true) <= 30 and (Target:CastingHealing() or Target:CastingCC()) then
            return S.MortalCoil:Cast()
        end
		-- Cast CallFelLord if enemy melee is bursting us
        if S.CallFelLord:IsReadyP() and Target:MinDistanceToPlayer(true) <= 10 and Target:IsBursting() then
            return S.CallFelLord:Cast()
        end
		-- Cast CallObserver if enemy caster is bursting us
        if S.CallObserver:IsReadyP() and Target:MinDistanceToPlayer(true) <= 25 and Target:IsBursting() then
            return S.CallObserver:Cast()
        end
        -- Cast CurseOfWeakness if current target is using offensives CDs
        if not Target:IsImmune() and Target:IsBursting() and S.CurseOfWeakness:IsCastable() and Target:IsMelee() then
            return S.CurseOfWeakness:Cast()
        end
		
    end
end
RubimRH.Rotation.SetPvP(266, PvP);

local function PASSIVE()
       return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(266, PASSIVE)