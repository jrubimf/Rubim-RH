--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet = Unit.Pet
local Spell = HL.Spell
local Item = HL.Item
local mainAddon = RubimRH
local MouseOver = Unit.MouseOver;

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[103] = {
    Regrowth = Spell(8936),
    BloodtalonsBuff = Spell(145152),
    Bloodtalons = Spell(155672),
    CatFormBuff = Spell(768),
    CatForm = Spell(768),
    ProwlBuff = Spell(5215),
    Prowl = Spell(5215),
    IncarnationBuff = Spell(102543),
    JungleStalkerBuff = Spell(252071),
    Berserk = Spell(106951),
    TigersFury = Spell(5217),
    TigersFuryBuff = Spell(5217),
    Berserking = Spell(26297),
    FeralFrenzy = Spell(274837),
    Incarnation = Spell(102543),
    BerserkBuff = Spell(106951),
    Shadowmeld = Spell(58984),
    Rake = Spell(1822),
    RakeDebuff = Spell(155722),
    ShadowmeldBuff = Spell(58984),
    FerociousBite = Spell(22568),
    PredatorySwiftnessBuff = Spell(69369),
    RipDebuff = Spell(1079),
    ApexPredatorBuff = Spell(252752),
    MomentofClarity = Spell(236068),
    SavageRoar = Spell(52610),
    SavageRoarBuff = Spell(52610),
    Rip = Spell(1079),
    FerociousBiteMaxEnergy = Spell(22568),
    BrutalSlash = Spell(202028),
    ThrashCat = Spell(106830),
    ThrashCatDebuff = Spell(106830),
    MoonfireCat = Spell(155625),
    ClearcastingBuff = Spell(135700),
    SwipeCat = Spell(106785),
    Shred = Spell(5221),
    LunarInspiration = Spell(155580),
    MoonfireCatDebuff = Spell(155625),
    Sabertooth = Spell(202031),
    PoweroftheMoon = Spell(273389),
    PrimalWrath = Spell(285381),
	Typhoon = Spell(132469),
	MightyBash = Spell(5211),
	Maim = Spell(22570),	
	SkullBash = Spell(106839),
    IronJawsBuff = Spell(276026),
	WildChargeCat = Spell(102401),
	SurvivalInstincts = Spell(61336),
	Thorns = Spell(467),
	
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
local S = RubimRH.Spell[103];

-- Items
if not Item.Druid then
    Item.Druid = {}
end
Item.Druid.Feral = {
    LuffaWrappings = Item(137056),
    OldWar = Item(127844),
    AiluroPouncers = Item(137024)
};
local I = Item.Druid.Feral;

-- Rotation Var
local ShouldReturn; -- Used to get the return string
-- Variables
local VarUseThrash = 0;
local VarDelayedTfOpener = 0;
local VarOpenerDone = 0;

local EnemyRanges = { 5, 8 }
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

local function num(val)
    if val then
        return 1
    else
        return 0
    end
end

local function bool(val)
    return val ~= 0
end

S.FerociousBiteMaxEnergy.CustomCost = {
    [3] = function()
        if Player:BuffP(S.ApexPredatorBuff) then
            return 0
        elseif (Player:BuffP(S.IncarnationBuff) or Player:BuffP(S.BerserkBuff)) then
            return 25
        else
            return 50
        end
    end
}

S.Rip:RegisterPMultiplier({ S.BloodtalonsBuff, 1.2 }, { S.SavageRoar, 1.15 }, { S.TigersFury, 1.15 })
S.Rake:RegisterPMultiplier(
        S.RakeDebuff,
        { function()
            return Player:IsStealthed(true, true) and 2 or 1;
        end },
        { S.BloodtalonsBuff, 1.2 }, { S.SavageRoar, 1.15 }, { S.TigersFury, 1.15 }
)

local OffensiveCDs = {
    S.Incarnation,
    S.Berserk,
}

local function UpdateCDs()
    RubimRH.db.profile.mainOption.disabledSpellsCD = {}
    if RubimRH.CDsON() then
        for i, spell in pairs(OffensiveCDs) do
            if not spell:IsEnabledCD() then
                RubimRH.delSpellDisabledCD(spell:ID())
            end
        end

    end
    if not RubimRH.CDsON() then
        for i, spell in pairs(OffensiveCDs) do
            if spell:IsEnabledCD() then
                RubimRH.addSpellDisabledCD(spell:ID())
            end
        end
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

--- ======= ACTION LISTS =======
local function APL()
    local Precombat, Cooldowns, Opener, SingleTarget, StFinishers, StGenerators
    UpdateRanges()
    UpdateCDs()
    DetermineEssenceRanks()
	Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- regrowth,if=talent.bloodtalons.enabled
        if S.Regrowth:IsReady() and (S.Bloodtalons:IsAvailable()) and Player:BuffDown(S.BloodtalonsBuff) and not Player:PrevGCDP(1, S.Regrowth) then
            return S.Regrowth:Cast()
        end
        -- variable,name=use_thrash,value=2
        if (true) then
            VarUseThrash = 2
        end
        -- variable,name=use_thrash,value=1,if=azerite.power_of_the_moon.enabled
        if (S.PoweroftheMoon:AzeriteEnabled()) then
            VarUseThrash = 1
        end
        -- variable,name=delayed_tf_opener,value=0
        if (true) then
            VarDelayedTfOpener = 0
        end
        -- variable,name=delayed_tf_opener,value=1,if=talent.sabertooth.enabled&talent.bloodtalons.enabled&!talent.lunar_inspiration.enabled
        if (S.Sabertooth:IsAvailable() and S.Bloodtalons:IsAvailable() and not S.LunarInspiration:IsAvailable()) then
            VarDelayedTfOpener = 1
        end
        -- cat_form
        if S.CatForm:IsReady() and Player:BuffDownP(S.CatFormBuff) then
            return S.CatForm:Cast()
        end
        -- prowl
        if S.Prowl:IsReady() and Player:BuffDownP(S.ProwlBuff) then
            return S.Prowl:Cast()
        end
        -- snapshot_stats
        -- potion
        -- berserk
        if S.Berserk:IsReady() and Player:BuffDownP(S.BerserkBuff) and RubimRH.CDsON() then
            return S.Berserk:Cast()
        end
    end
    
	Cooldowns = function()
-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn and (true) then return ShouldReturn; end
        -- dash,if=!buff.cat_form.up
        -- prowl,if=buff.incarnation.remains<0.5&buff.jungle_stalker.up
        if S.Prowl:IsReady() and (Player:BuffRemainsP(S.IncarnationBuff) < 0.5 and Player:BuffP(S.JungleStalkerBuff)) then
            return S.Prowl:Cast()
        end
        -- berserk,if=energy>=30&(cooldown.tigers_fury.remains>5|buff.tigers_fury.up)
        if S.Berserk:IsReady() and RubimRH.CDsON() and (Player:EnergyPredicted() >= 30 and (S.TigersFury:CooldownRemainsP() > 5 or Player:BuffP(S.TigersFuryBuff))) then
            return S.Berserk:Cast()
        end
        -- tigers_fury,if=energy.deficit>=60
        if S.TigersFury:IsReady() and (Player:EnergyDeficitPredicted() >= 60) then
            return S.TigersFury:Cast()
        end
        -- berserking
        if S.Berserking:IsReady() and RubimRH.CDsON() then
            return S.Berserking:Cast()
        end
        -- feral_frenzy,if=combo_points=0
        if S.FeralFrenzy:IsReady() and (Player:ComboPoints() == 0) then
            return S.FeralFrenzy:Cast()
        end
        -- incarnation,if=energy>=30&(cooldown.tigers_fury.remains>15|buff.tigers_fury.up)
        if S.Incarnation:IsReady() and RubimRH.CDsON() and (Player:EnergyPredicted() >= 30 and (S.TigersFury:CooldownRemainsP() > 15 or Player:BuffP(S.TigersFuryBuff))) then
            return S.Incarnation:Cast()
        end
        -- potion,name=battle_potion_of_agility,if=target.time_to_die<65|(time_to_die<180&(buff.berserk.up|buff.incarnation.up))
        -- shadowmeld,if=combo_points<5&energy>=action.rake.cost&dot.rake.pmultiplier<2.1&buff.tigers_fury.up&(buff.bloodtalons.up|!talent.bloodtalons.enabled)&(!talent.incarnation.enabled|cooldown.incarnation.remains>18)&!buff.incarnation.up
        -- use_items
    end
    
	Opener = function()
        -- tigers_fury,if=variable.delayed_tf_opener=0
        if S.TigersFury:IsReady() and (VarDelayedTfOpener == 0) then
            return S.TigersFury:Cast()
        end
        -- rake,if=!ticking|buff.prowl.up
        if S.Rake:IsReady() and (not Target:DebuffP(S.RakeDebuff) or Player:BuffP(S.ProwlBuff)) then
            return S.Rake:Cast()
        end
        -- variable,name=opener_done,value=dot.rip.ticking
        if (true) then
            VarOpenerDone = num(Target:DebuffP(S.RipDebuff))
        end
        -- wait,sec=0.001,if=dot.rip.ticking
        -- moonfire_cat,if=!ticking|buff.bloodtalons.stack=1&combo_points<5
        if S.MoonfireCat:IsReady() and (not Target:DebuffP(S.MoonfireCatDebuff) or Player:BuffStackP(S.BloodtalonsBuff) == 1 and Player:ComboPoints() < 5) then
            return S.MoonfireCat:Cast()
        end
        -- thrash,if=!ticking&combo_points<5
        if S.ThrashCat:IsReadyMorph() and (not Player:BuffP(S.ThrashCatDebuff) and Player:ComboPoints() < 5) then
            return S.ThrashCat:Cast()
        end
        -- shred,if=combo_points<5
        if S.Shred:IsReady() and (Player:ComboPoints() < 5) then
            return S.Shred:Cast()
        end
        -- regrowth,if=combo_points=5&talent.bloodtalons.enabled&(talent.sabertooth.enabled&buff.bloodtalons.down|buff.predatory_swiftness.up)
        if S.Regrowth:IsReady() and not Player:PrevGCDP(1, S.Regrowth) and (Player:ComboPoints() == 5 and S.Bloodtalons:IsAvailable() and (S.Sabertooth:IsAvailable() and Player:BuffDownP(S.BloodtalonsBuff) or Player:BuffP(S.PredatorySwiftnessBuff))) then
            return S.Regrowth:Cast()
        end
        -- tigers_fury
        if S.TigersFury:IsReady() then
            return S.TigersFury:Cast()
        end
        -- rip,if=combo_points=5
        if S.Rip:IsReady() and (Player:ComboPoints() == 5) then
            return S.Rip:Cast()
        end
    end
    
	SingleTarget = function()
        -- rake,if=buff.prowl.up|buff.shadowmeld.up
        if S.Rake:IsReady() and (Player:BuffP(S.ProwlBuff) or Player:BuffP(S.ShadowmeldBuff)) then
            return S.Rake:Cast()
        end
        -- auto_attack
        -- call_action_list,name=cooldowns
        if Cooldowns() ~= nil then
            return Cooldowns()
        end
        -- ferocious_bite,target_if=dot.rip.ticking&dot.rip.remains<3&target.time_to_die>10&(target.health.pct<25|talent.sabertooth.enabled)
        if S.FerociousBite:IsReady() and (Target:DebuffP(S.RipDebuff) and Target:DebuffRemainsP(S.RipDebuff) < 3 and Target:TimeToDie() > 10 and (Target:HealthPercentage() < 25 or S.Sabertooth:IsAvailable())) then
            return S.FerociousBite:Cast()
        end
        -- regrowth,if=combo_points=5&buff.predatory_swiftness.up&talent.bloodtalons.enabled&buff.bloodtalons.down&(!buff.incarnation.up|dot.rip.remains<8)
        if S.Regrowth:IsReady() and not Player:PrevGCDP(1, S.Regrowth) and (Player:ComboPoints() == 5 and Player:BuffP(S.PredatorySwiftnessBuff) and S.Bloodtalons:IsAvailable() and Player:BuffDownP(S.BloodtalonsBuff) and (not Player:BuffP(S.IncarnationBuff) or Target:DebuffRemainsP(S.RipDebuff) < 8)) then
            return S.Regrowth:Cast()
        end
        -- regrowth,if=combo_points>3&talent.bloodtalons.enabled&buff.predatory_swiftness.up&buff.apex_predator.up&buff.incarnation.down
        if S.Regrowth:IsReady() and not Player:PrevGCDP(1, S.Regrowth) and (Player:ComboPoints() > 3 and S.Bloodtalons:IsAvailable() and Player:BuffP(S.PredatorySwiftnessBuff) and Player:BuffP(S.ApexPredatorBuff) and Player:BuffDownP(S.IncarnationBuff)) then
            return S.Regrowth:Cast()
        end
        -- ferocious_bite,if=buff.apex_predator.up&((combo_points>4&(buff.incarnation.up|talent.moment_of_clarity.enabled))|(talent.bloodtalons.enabled&buff.bloodtalons.up&combo_points>3))
        if S.FerociousBite:IsReady() and (Player:BuffP(S.ApexPredatorBuff) and ((Player:ComboPoints() > 4 and (Player:BuffP(S.IncarnationBuff) or S.MomentofClarity:IsAvailable())) or (S.Bloodtalons:IsAvailable() and Player:BuffP(S.BloodtalonsBuff) and Player:ComboPoints() > 3))) then
            return S.FerociousBite:Cast()
        end
        -- run_action_list,name=st_finishers,if=combo_points>4
        if (Player:ComboPoints() > 4) then
            return StFinishers();
        end
        -- run_action_list,name=st_generators
        if (true) then
            return StGenerators();
        end
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
    end
    
	StFinishers = function()
        -- pool_resource,for_next=1
        -- savage_roar,if=buff.savage_roar.down
        if S.SavageRoar:IsCastable() and (Player:BuffDownP(S.SavageRoarBuff)) then
            if S.SavageRoar:IsUsablePPool() then
                return S.SavageRoar:Cast()
            else
                S.SavageRoar:QueueAuto()
                return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
            end
        end
        -- pool_resource,for_next=1
        -- primal_wrath,target_if=spell_targets.primal_wrath>1&dot.rip.remains<4
        if S.PrimalWrath:IsCastableP() and Cache.EnemiesCount[5] > 1 and Target:DebuffRemainsP(S.RipDebuff) < 4 then
            return S.PrimalWrath:Cast()
        end
        -- pool_resource,for_next=1
        -- primal_wrath,target_if=spell_targets.primal_wrath>=2
        if S.PrimalWrath:IsCastableP() and Cache.EnemiesCount[5] >= 2 then
            return S.PrimalWrath:Cast()
        end
        -- pool_resource,for_next=1
        -- rip,target_if=!ticking|(remains<=duration*0.3)&(target.health.pct>25&!talent.sabertooth.enabled)|(remains<=duration*0.8&persistent_multiplier>dot.rip.pmultiplier)&target.time_to_die>8
        if S.Rip:IsCastable() and (not Target:DebuffP(S.RipDebuff) or (Target:DebuffRemainsP(S.RipDebuff) <= S.RipDebuff:BaseDuration() * 0.3) and (Target:HealthPercentage() > 25 and not S.Sabertooth:IsAvailable()) or (Target:DebuffRemainsP(S.RipDebuff) <= S.RipDebuff:BaseDuration() * 0.8 and Player:PMultiplier(S.Rip) > Target:PMultiplier(S.Rip)) and Target:TimeToDie() > 8) then
            if S.Rip:IsUsablePPool() then
                return S.Rip:Cast()
            else
                S.Rip:QueueAuto()
                return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
            end
        end
        -- pool_resource,for_next=1
        -- savage_roar,if=buff.savage_roar.remains<12
        if S.SavageRoar:IsCastable() and (Player:BuffRemainsP(S.SavageRoarBuff) < 12) then
            if S.SavageRoar:IsUsablePPool() then
                return S.SavageRoar:Cast()
            else
                S.SavageRoar:QueueAuto()
                return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
            end
        end
        -- pool_resource,for_next=1
        -- maim,if=buff.iron_jaws.up
        if S.Maim:IsCastable() and (Player:BuffP(S.IronJawsBuff)) then
            if S.Maim:IsUsablePPool() then
                return S.Maim:Cast()
            else
			    S.Maim:QueueAuto()
                return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
            end
        end
        -- ferocious_bite,max_energy=1
        if S.FerociousBiteMaxEnergy:IsReady() and S.FerociousBiteMaxEnergy:IsUsableP() then
            return S.FerociousBiteMaxEnergy:Cast()
        end
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
    end
    
	StGenerators = function()
        -- regrowth,if=talent.bloodtalons.enabled&buff.predatory_swiftness.up&buff.bloodtalons.down&combo_points=4&dot.rake.remains<4
        if S.Regrowth:IsReady() and not Player:PrevGCDP(1, S.Regrowth) and (S.Bloodtalons:IsAvailable() and Player:BuffP(S.PredatorySwiftnessBuff) and Player:BuffDownP(S.BloodtalonsBuff) and Player:ComboPoints() == 4 and Target:DebuffRemainsP(S.RakeDebuff) < 4) then
            return S.Regrowth:Cast()
        end
        -- regrowth,if=equipped.ailuro_pouncers&talent.bloodtalons.enabled&(buff.predatory_swiftness.stack>2|(buff.predatory_swiftness.stack>1&dot.rake.remains<3))&buff.bloodtalons.down
        if S.Regrowth:IsReady() and not Player:PrevGCDP(1, S.Regrowth) and (I.AiluroPouncers:IsEquipped() and S.Bloodtalons:IsAvailable() and (Player:BuffStackP(S.PredatorySwiftnessBuff) > 2 or (Player:BuffStackP(S.PredatorySwiftnessBuff) > 1 and Target:DebuffRemainsP(S.RakeDebuff) < 3)) and Player:BuffDownP(S.BloodtalonsBuff)) then
            return S.Regrowth:Cast()
        end
        -- brutal_slash,if=spell_targets.brutal_slash>desired_targets
        if S.BrutalSlash:IsReadyMorph() and (Cache.EnemiesCount[8] > 1) then
            return S.BrutalSlash:Cast()
        end
        -- pool_resource,for_next=1
        -- thrash_cat,if=refreshable&(spell_targets.thrash_cat>2)
        if S.ThrashCat:IsCastableMorph() and (Target:DebuffRefreshableCP(S.ThrashCatDebuff) and (Cache.EnemiesCount[8] > 2)) then
            if S.ThrashCat:IsUsablePPool() then
                return S.ThrashCat:Cast()
            else
                S.ThrashCat:QueueAuto()
                return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
            end
        end
        -- pool_resource,for_next=1
        -- thrash_cat,if=spell_targets.thrash_cat>3&equipped.luffa_wrappings&talent.brutal_slash.enabled
        if S.ThrashCat:IsCastableMorph() and (Cache.EnemiesCount[8] > 3 and I.LuffaWrappings:IsEquipped() and S.BrutalSlash:IsAvailable()) then
            if S.ThrashCat:IsUsablePPool() then
                return S.ThrashCat:Cast()
            else
                S.ThrashCat:QueueAuto()
                return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
            end
        end
        -- pool_resource,for_next=1
        -- rake,target_if=!ticking|(!talent.bloodtalons.enabled&remains<duration*0.3)&target.time_to_die>4
        if S.Rake:IsCastable() and (not Target:DebuffP(S.RakeDebuff) or (not S.Bloodtalons:IsAvailable() and Target:DebuffRemainsP(S.RakeDebuff) < S.RakeDebuff:BaseDuration() * 0.3) and Target:TimeToDie() > 4) then
            if S.Rake:IsUsablePPool() then
                return S.Rake:Cast()
            else
                S.Rake:QueueAuto()
                return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
            end
        end
        -- pool_resource,for_next=1
        -- rake,target_if=talent.bloodtalons.enabled&buff.bloodtalons.up&((remains<=7)&persistent_multiplier>dot.rake.pmultiplier*0.85)&target.time_to_die>4
        if S.Rake:IsCastable() and (S.Bloodtalons:IsAvailable() and Player:BuffP(S.BloodtalonsBuff) and ((Target:DebuffRemainsP(S.RakeDebuff) <= 7) and Player:PMultiplier(S.Rake) > Target:PMultiplier(S.Rake) * 0.85) and Target:TimeToDie() > 4) then
            if S.Rake:IsUsablePPool() then
                return S.Rake:Cast()
            else
                S.Rake:QueueAuto()
                return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
            end
        end
        -- brutal_slash,if=(buff.tigers_fury.up&(raid_event.adds.in>(1+max_charges-charges_fractional)*recharge_time))
        if S.BrutalSlash:IsReadyMorph() and ((Player:BuffP(S.TigersFuryBuff) and (10000000000 > (1 + S.BrutalSlash:MaxCharges() - S.BrutalSlash:ChargesFractional()) * S.BrutalSlash:RechargeP()))) then
            return S.BrutalSlash:Cast()
        end
        -- moonfire_cat,target_if=refreshable
        if S.MoonfireCat:IsReadyMorph() and (Target:DebuffRefreshableCP(S.MoonfireCatDebuff)) then
            return S.MoonfireCat:Cast()
        end
        -- pool_resource,for_next=1
        -- thrash_cat,if=refreshable&(variable.use_thrash=2|spell_targets.thrash_cat>1)
        if S.ThrashCat:IsCastableMorph() and (Target:DebuffRefreshableCP(S.ThrashCatDebuff) and (VarUseThrash == 2 or Cache.EnemiesCount[8] > 1)) then
            if S.ThrashCat:IsUsablePPool() then
                return S.ThrashCat:Cast()
            else
                S.ThrashCat:QueueAuto()
                return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
            end
        end
        -- thrash_cat,if=refreshable&variable.use_thrash=1&buff.clearcasting.react
        if S.ThrashCat:IsReadyMorph() and (Target:DebuffRefreshableCP(S.ThrashCatDebuff) and VarUseThrash == 1 and bool(Player:BuffStackP(S.ClearcastingBuff))) then
            return S.ThrashCat:Cast()
        end
        -- pool_resource,for_next=1
        -- swipe_cat,if=spell_targets.swipe_cat>1
        if S.SwipeCat:IsCastableMorph() and (Cache.EnemiesCount[8] > 1) then
            if S.SwipeCat:IsUsablePPool() then
                return S.SwipeCat:Cast()
            else
                S.SwipeCat:QueueAuto()
                return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
            end
        end
        -- shred,if=dot.rake.remains>(action.shred.cost+action.rake.cost-energy)%energy.regen|buff.clearcasting.react
        if S.Shred:IsReady() and (Target:DebuffRemainsP(S.RakeDebuff) > (S.Shred:Cost() + S.Rake:Cost() - Player:EnergyPredicted()) / Player:EnergyRegen() or bool(Player:BuffStackP(S.ClearcastingBuff))) then
            return S.Shred:Cast()
        end
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
    end
    -- stuff
    if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end

    if QueueSkill() ~= nil then
        return QueueSkill()
    end

    -- call precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
	
	-- WildChargeCat
	--if Target:MinDistanceToPlayer(true) >= 8 and Target:MinDistanceToPlayer(true) <= 25 and S.WildChargeCat:CooldownRemainsP() < 0.1 then
    --    return 538771
    --end
	
	-- Mouseover Thorns
    local MouseoverUnit = UnitExists("mouseover") and UnitIsFriend("player", "mouseover")
    if MouseoverUnit then
        -- PurifyDisease
	    if S.Thorns:IsCastable() then
            return S.Thorns:Cast()
        end
    end
	    -- cat_form,if=!buff.cat_form.up
        if S.CatForm:IsReady() and (not Player:BuffP(S.CatFormBuff)) then
            return S.CatForm:Cast()
        end
	-- SurvivalInstincts
    if S.SurvivalInstincts:IsReady() and Player:HealthPercentage() <= mainAddon.db.profile[103].sk3 then
        return S.SurvivalInstincts:Cast()
    end

	-- QueueSkill
    if QueueSkill() ~= nil then
        return QueueSkill()
    end

	-- interrupt.SkullBash
    if S.SkullBash:CooldownRemainsP() < 0.1 and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.SkullBash:Cast()
    end
    -- interrupt.Maim
    if S.Maim:CooldownRemainsP() < 0.1 and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Maim:Cast()
    end
	-- interrupt.talent.typhoon
    if S.Typhoon:IsAvailable() and S.Typhoon:CooldownRemainsP() < 0.1 and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Typhoon:Cast()
    end
    -- interrupt.talent.mightybash
    if S.MightyBash:IsAvailable() and S.MightyBash:CooldownRemainsP() < 0.1 and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.MightyBash:Cast()
    end
    -- run_action_list,name=opener,if=variable.opener_done=0
    --if (VarOpenerDone == 0) then
        --return Opener();
    --end

    -- run_action_list,name=single_target
    if (true) then
        return SingleTarget();
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(103, APL)

local function PASSIVE()
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(103, PASSIVE)