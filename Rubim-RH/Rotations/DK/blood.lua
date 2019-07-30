    --- ============================ HEADER ============================
local addonName, addonTable = ...;
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local MouseOver = Unit.MouseOver;
local Spell = HL.Spell;
local Item = HL.Item;

-- Items
if not Item.DeathKnight then
    Item.DeathKnight = { };
end
Item.DeathKnight.Blood = {
    SephuzSecret = Item(132452, { 11, 12 }), --11/12
}

RubimRH.Spell[250] = {
    -- Racials
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    -- Abilities
    ActiveMitigation = Spell(180612),
    BloodBoil = Spell(50842),
    BloodDrinker = Spell(206931),
    BloodMirror = Spell(206977),
    BloodPlague = Spell(55078),
    BloodShield = Spell(77535),
    BoneShield = Spell(195181),
    BoneShieldBuff = Spell(195181),
    Bonestorm = Spell(194844),
    Consumption = Spell(274156),
    CrimsonScourge = Spell(81141),
    DancingRuneWeapon = Spell(49028),
    DancingRuneWeaponBuff = Spell(81256),
    DeathandDecay = Spell(43265),
    DeathsCaress = Spell(195292),
    DeathStrike = Spell(49998),
    DeathsAdvance = Spell(48265),
    HemostasisBuff = Spell(273947),
    HeartBreaker = Spell(221536),
    HeartStrike = Spell(206930),
    Marrowrend = Spell(195182),
    MindFreeze = Spell(47528),
    Ossuary = Spell(219786),
    RapidDecomposition = Spell(194662),
    RuneStrike = Spell(210764),
    RuneStrikeTalent = Spell(19217),
    UmbilicusEternus = Spell(193249),
    WraithWalk = Spell(212552),
    -- Defensive
    IceboundFortitude = Spell(48792),
    VampiricBlood = Spell(55233),
    RuneTap = Spell(194679),
    Tombstone = Spell(219809),
    -- Legendaries

    HaemostasisBuff = Spell(235558),
    SephuzBuff = Spell(208052),
    -- PVP
    MurderousIntent = Spell(207018),
    Intimidated = Spell(206891),
    DeathChain = Spell(203173),
    DeathGrip = Spell(49576),
    DarkCommand = Spell(56222),
    Asphyxiate = Spell(221562),
    GorefiendsGrasp = Spell(108199),
    RaiseAlly = Spell(61999),
	
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
  Animaofdeath          = Spell(294926),

  -- Pvp

  BloodforBlood = Spell(233411)
}

local S = RubimRH.Spell[250]
S.RuneStrike.TextureSpellID = { S.BloodDrinker:ID() }
local I = Item.DeathKnight.Blood;

local EnemyRanges = { "Melee", 5, 10, 20, 40 }
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end
-- Rotation Var
local ShouldReturn; -- Used to get the return string
-- Rotation Var
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
    --custom
    -- blood_of_the_enemy
    if S.Animaofdeath:IsReady() then
        return S.UnleashHeartOfAzeroth:Cast()
      end
    -- blood_of_the_enemy
    if S.BloodOfTheEnemy:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- guardian_of_azeroth
    if S.GuardianOfAzeroth:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- purifying_blast
    if S.PurifyingBlast:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- the_unbound_force
    if S.TheUnboundForce:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- ripple_in_space
    if S.RippleInSpace:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsReady() then
      return S.UnleashHeartOfAzeroth:Cast()
    end
    -- memory_of_lucid_dreams,if=fury<40&buff.metamorphosis.up
    --if S.MemoryOfLucidDreams:IsReady() and Player:Rune() < 3 then
      --return S.UnleashHeartOfAzeroth:Cast()
    --end
    return false
end

local function APL()
    local Precombat, Standard
    UpdateRanges()

    if QueueSkill() ~= nil then

        if RubimRH.QueuedSpell():ID() == S.Bonestorm:ID() then

            if Player:RunicPower() >= 100 then
                return QueueSkill()
            end

        else
            return QueueSkill()
        end
    end

    Precombat = function()

    end


    Standard = function()
        -- death_strike,if=runic_power.deficit<=10
        if S.DeathStrike:IsReady('Melee') and (Player:RunicPowerDeficit() <= 10) then
            return S.DeathStrike:Cast()
        end
        -- blooddrinker,if=!buff.dancing_rune_weapon.up
        if S.BloodDrinker:IsReady(30) and (not Player:BuffP(S.DancingRuneWeaponBuff)) then
            return S.BloodDrinker:Cast()
        end
        -- marrowrend,if=(buff.bone_shield.remains<=rune.time_to_3|buff.bone_shield.remains<=(gcd+cooldown.blooddrinker.ready*talent.blooddrinker.enabled*2)|buff.bone_shield.stack<3)&runic_power.deficit>=20
        if S.Marrowrend:IsReady('Melee') and ((Player:BuffRemainsP(S.BoneShieldBuff) <= Player:RuneTimeToX(3) or Player:BuffRemainsP(S.BoneShieldBuff) <= (Player:GCD() + num(S.BloodDrinker:CooldownUpP()) * num(S.BloodDrinker:IsAvailable()) * 2) or Player:BuffStackP(S.BoneShieldBuff) < 3) and Player:RunicPowerDeficit() >= 20) then
            return S.Marrowrend:Cast()
        end
        if S.Marrowrend:IsReady('Melee') and Player:BuffP(S.MemoryOfLucidDreams) and ((Player:BuffRemainsP(S.BoneShieldBuff) <= Player:RuneTimeToX(3) or Player:BuffRemainsP(S.BoneShieldBuff) <= (Player:GCD() + num(S.BloodDrinker:CooldownUpP()) * num(S.BloodDrinker:IsAvailable()) * 2) or Player:BuffStackP(S.BoneShieldBuff) < 8) and Player:RunicPowerDeficit() >= 20) then
            return S.Marrowrend:Cast()
        end
        -- heart_essence,if=!buff.dancing_rune_weapon.up
        local ShouldReturn = Essences(); if ShouldReturn and (true) and not Player:BuffP(S.DancingRuneWeaponBuff) and RubimRH.CDsON() then return ShouldReturn; end
        
        -- blood_boil,if=charges_fractional>=1.8&(buff.hemostasis.stack<=(5-spell_targets.blood_boil)|spell_targets.blood_boil>2)
        if S.BloodBoil:IsReady(5) and (S.BloodBoil:ChargesFractionalP() >= 1.8 and (Player:BuffStackP(S.HemostasisBuff) <= (5 - Cache.EnemiesCount[5]) or Cache.EnemiesCount[5] > 2)) then
            return S.BloodBoil:Cast()
        end
        -- marrowrend,if=buff.bone_shield.stack<5&talent.ossuary.enabled&runic_power.deficit>=15
        if S.Marrowrend:IsReady('Melee') and (Player:BuffStackP(S.BoneShieldBuff) < 5 and S.Ossuary:IsAvailable() and Player:RunicPowerDeficit() >= 15) then
            return S.Marrowrend:Cast()
        end
        -- bonestorm,if=runic_power>=100&!buff.dancing_rune_weapon.up
        -- DS for health
        if S.DeathStrike:IsReady("Melee") and S.DeathStrike:TimeSinceLastCast() >= Player:GCD() * 2 and (Player:HealthPercentage() <= 50) and RubimRH.CDsON() and S.Bonestorm:CooldownRemainsP() >= 5 then
            return S.DeathStrike:Cast()
        end
        if S.DeathStrike:IsReady("Melee") and S.DeathStrike:TimeSinceLastCast() >= Player:GCD() * 2 and (Player:HealthPercentage() <= 50) and not RubimRH.CDsON() and S.Bonestorm:CooldownRemainsP() <= 5 then
            return S.DeathStrike:Cast()
        end
        -- death_strike,if=runic_power.deficit<=(15+buff.dancing_rune_weapon.up*5+spell_targets.heart_strike*talent.heartbreaker.enabled*2)|target.1.time_to_die<10
        if S.DeathStrike:IsReady('Melee') and (Player:RunicPowerDeficit() <= (15 + num(Player:BuffP(S.DancingRuneWeaponBuff)) * 5 + Cache.EnemiesCount[5] * num(S.HeartBreaker:IsAvailable()) * 2)) then
            return S.DeathStrike:Cast()
        end
        -- death_and_decay,if=spell_targets.death_and_decay>=3
        if S.DeathandDecay:IsReady('Melee') and (Cache.EnemiesCount[5] >= 3) then
            return S.DeathandDecay:Cast()
        end
        -- rune_strike,if=(charges_fractional>=1.8|buff.dancing_rune_weapon.up)&rune.time_to_3>=gcd
        if S.RuneStrike:IsReady('Melee') and ((S.RuneStrike:ChargesFractionalP() >= 1.8 or Player:BuffP(S.DancingRuneWeaponBuff)) and Player:RuneTimeToX(3) >= Player:GCD()) then
            return S.RuneStrike:Cast()
        end
        -- Blood for Blood
        if S.BloodforBlood:IsReady('Melee') and Player:HealthPercentage() > 50 and not Player:BuffP(S.BloodforBlood) and (Player:BuffP(S.DancingRuneWeaponBuff) or Player:RuneTimeToX(4) < Player:GCD()) then
            return S.BloodforBlood:Cast()
        end

        -- heart_strike,if=buff.dancing_rune_weapon.up|rune.time_to_4<gcd
        if S.HeartStrike:IsReady('Melee') and (Player:BuffP(S.DancingRuneWeaponBuff) or Player:RuneTimeToX(4) < Player:GCD()) then
            return S.HeartStrike:Cast()
        end
        -- blood_boil,if=buff.dancing_rune_weapon.up
        if S.BloodBoil:IsReady(5) and Cache.EnemiesCount[5] > 0 and (Player:BuffP(S.DancingRuneWeaponBuff)) then
            return S.BloodBoil:Cast()
        end
        -- death_and_decay,if=buff.crimson_scourge.up|talent.rapid_decomposition.enabled|spell_targets.death_and_decay>=2
        if S.DeathandDecay:IsReady('Melee') and RubimRH.CDsON() and (Player:BuffP(S.CrimsonScourge) or S.RapidDecomposition:IsAvailable() or Cache.EnemiesCount[5] >= 2) then
            return S.DeathandDecay:Cast()
        end
        -- consumption
        if S.Consumption:IsReady('Melee') then
            return S.Consumption:Cast()
        end
        -- blood_boil
        if S.BloodBoil:IsReady(5) and Cache.EnemiesCount[5] > 0 then
            return S.BloodBoil:Cast()
        end
        -- Blood for Blood
        if S.BloodforBlood:IsReady('Melee') and Player:HealthPercentage() > 50 and not Player:BuffP(S.BloodforBlood) and (Player:RuneTimeToX(3) < Player:GCD() or Player:BuffStackP(S.BoneShieldBuff) > 6) then
            return S.BloodforBlood:Cast()
        end
        -- heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
        if S.HeartStrike:IsReady('Melee') and (Player:RuneTimeToX(3) < Player:GCD() or Player:BuffStackP(S.BoneShieldBuff) > 6) then
            return S.HeartStrike:Cast()
        end
        -- use_item,name=grongs_primal_rage
        -- rune_strike
        if S.RuneStrike:IsReady('Melee') then
            return S.RuneStrike:Cast()
        end
        if S.MemoryOfLucidDreams:IsReady('Melee') and RubimRH.CDsON() then
            return S.UnleashHeartOfAzeroth:Cast()
          end
        -- arcane_torrent,if=runic_power.deficit>20
        if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Player:RunicPowerDeficit() > 20) then
            return S.ArcaneTorrent:Cast()
        end
    end

    --if Target:MinDistanceToPlayer(true) >= 15 and Target:MinDistanceToPlayer(true) <= 40 and S.DeathGrip:IsReady() and Target:IsQuestMob() and S.DeathGrip:TimeSinceLastCast() >= Player:GCD() then
    --        return S.DeathGrip:Cast()
    --    end

    ----CHANNEL BLOOD DRINKER
    if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) or Player:IsChanneling() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end 

    if not Player:AffectingCombat() and RubimRH.PrecombatON() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
    -- mind_freeze
    if S.MindFreeze:IsReady() and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.MindFreeze:Cast()
    end
    
    -- custom
    if S.VampiricBlood:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[250].sk3
        and not Player:BuffP(S.VampiricBlood)
        and not Player:BuffP(S.IceboundFortitude)
        and not Player:BuffP(S.DancingRuneWeaponBuff)
        and not Player:BuffP(S.Bonestorm) then
        return S.VampiricBlood:Cast()
    end
	
    
    -- blood_fury,if=cooldown.dancing_rune_weapon.ready&(!cooldown.blooddrinker.ready|!talent.blooddrinker.enabled)
    if S.BloodFury:IsReady() and RubimRH.CDsON() and (S.DancingRuneWeapon:CooldownUpP() and (not S.BloodDrinker:CooldownUpP() or not S.BloodDrinker:IsAvailable())) then
        return S.BloodFury:Cast()
    end
    -- berserking
    if S.Berserking:IsReady() and RubimRH.CDsON() then
        return S.Berserking:Cast()
    end
    -- use_items,if=cooldown.dancing_rune_weapon.remains>90
    -- use_item,name=razdunks_big_red_button
    -- use_item,name=merekthas_fang
    -- potion,if=buff.dancing_rune_weapon.up
    -- dancing_rune_weapon,if=!talent.blooddrinker.enabled|!cooldown.blooddrinker.ready
    if S.DancingRuneWeapon:IsReady() and ((not S.BloodDrinker:IsAvailable() or not S.BloodDrinker:CooldownUpP()) and  RubimRH.CDsON()
        and not Player:BuffP(S.VampiricBlood)
        and not Player:BuffP(S.IceboundFortitude)
        and not Player:BuffP(S.DancingRuneWeaponBuff)
        and not Player:BuffP(S.Bonestorm)) then
        return S.DancingRuneWeapon:Cast()
    end
    -- BS
    if S.Bonestorm:IsReady() and RubimRH.CDsON() and (Player:RunicPower() >= 100 and not Player:BuffP(S.DancingRuneWeaponBuff))
        and not Player:BuffP(S.VampiricBlood)
        and not Player:BuffP(S.IceboundFortitude)
        and not Player:BuffP(S.DancingRuneWeaponBuff)
        and not Player:BuffP(S.Bonestorm) then
    return S.Bonestorm:Cast()
    end
    -- tombstone,if=buff.bone_shield.stack>=7
    if S.Tombstone:IsReady() and (Player:BuffStackP(S.BoneShieldBuff) >= 7) then
        return S.Tombstone:Cast()
    end
    -- Icebound
    if S.IceboundFortitude:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[250].sk1 
        and not Player:BuffP(S.VampiricBlood)
        and not Player:BuffP(S.IceboundFortitude)
        and not Player:BuffP(S.DancingRuneWeaponBuff)
        and not Player:BuffP(S.Bonestorm) then
        return S.IceboundFortitude:Cast()
    end
    -- call_action_list,name=standard
    if (true) then
        if Standard() ~= nil then
            return Standard()
        end
    end
    if QueueSkill() ~= nil then

        if RubimRH.QueuedSpell():ID() == S.Bonestorm:ID() then

            if Player:RunicPower() >= 100
            and not Player:BuffP(S.VampiricBlood)
            and not Player:BuffP(S.IceboundFortitude)
            and not Player:BuffP(S.DancingRuneWeaponBuff)
            and not Player:BuffP(S.Bonestorm)  then
                return QueueSkill()
            end

        else
            return QueueSkill()
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(250, APL);

local function PASSIVE()
    if Player:AffectingCombat() then


        if S.RuneTap:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[250].sk2 then
            return S.RuneTap:Cast()
        end

        if RubimRH.Shared() ~= nil then
            return RubimRH.Shared()
        end
    end
end

RubimRH.Rotation.SetPASSIVE(250, PASSIVE);
