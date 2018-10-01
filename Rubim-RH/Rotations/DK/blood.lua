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
}

local S = RubimRH.Spell[250]
S.RuneStrike.TextureSpellID = { S.BloodDrinker:ID() }
local I = Item.DeathKnight.Blood;

local EnemyRanges = { "Melee", 5, 10, 20 }
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

local function APL()
    local Precombat, StandardSimc, Standard, Immunity
    UpdateRanges()
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);

    Precombat = function()

    end

    Immunity = function()
        if S.DeathStrike:IsReady() and (Player:RunicPowerDeficit() <= RubimRH.db.profile[250].sk6) then
            return S.DeathStrike:Cast()
        end

        if S.DeathStrike:IsReady() and Player:HealthPercentage() <= 90 and S.DeathStrike:TimeSinceLastCast() >= Player:GCD() * 2 then
            return S.DeathStrike:Cast()
        end

        if S.HeartStrike:IsReady("Melee") and Player:RunicPowerDeficit() <= RubimRH.db.profile[250].sk6 * 1.5 then
            return S.HeartStrike:Cast()
        end

        if S.Marrowrend:IsReady("Melee") and (not Player:Buff(S.BoneShield) or Player:BuffRemains(S.BoneShield) <= 3 or Player:BuffStack(S.BoneShield) <= 7) then
            return S.Marrowrend:Cast()
        end
        return 0, 135328
    end

    StandardSimc = function()
        -- death_strike,custom==bossmechanics
        if S.DeathStrike:IsReady("Melee") and (Player:ActiveMitigationNeeded() or Player:HealthPercentage() <= 50) and S.DeathStrike:TimeSinceLastCast() >= Player:GCD() * 2 then
            return S.DeathStrike:Cast()
        end

        if Player:NeedThreat() and S.BloodBoil:IsReady() and Cache.EnemiesCount[8] >= 1 and Player:BuffStack(S.BoneShield) >= 3 then
            return S.BloodBoil:Cast()
        end

        --Needs Marrowrend
        if Target:MinDistanceToPlayer(true) <= 8 and (not Player:Buff(S.BoneShield) or Player:BuffRemains(S.BoneShield) <= Player:RuneTimeToX(3) or Player:BuffStack(S.BoneShield) <= 5) then
            S.Marrowrend:QueueAuto()
        end

        if Player:LastDamage3Seconds() > RubimRH.db.profile[250].sk5 and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 90 and S.DeathStrike:TimeSinceLastCast() >= Player:GCD() * 2 then
            return S.DeathStrike:Cast()
        end

        -- death_strike,if=runic_power.deficit<=10
        if S.DeathStrike:IsReady() and (Player:RunicPowerDeficit() <= RubimRH.db.profile[250].sk6) then
            return S.DeathStrike:Cast()
        end

        --BloodBoil
        if S.BloodBoil:IsReady() and S.BloodBoil:ChargesFractional() >= 1.8 and Cache.EnemiesCount[8] >= 1 then
            return S.BloodBoil:Cast()
        end

        if Player:NeedThreat() and S.HeartStrike:IsReady("Melee") and Cache.EnemiesCount[8] >= 1 then
            return S.HeartStrike:Cast()
        end

        --Aggro
        if Player:StackUp() and S.DeathandDecay:IsReady() then
            return S.DeathandDecay:Cast()
        end

        -- BloodDrinker,if=!buff.dancing_rune_weapon.up
        if S.BloodDrinker:IsReady() and (not Player:BuffP(S.DancingRuneWeaponBuff)) then
            return S.BloodDrinker:Cast()
        end
        -- marrowrend,if=(buff.bone_shield.remains<=rune.time_to_3|buff.bone_shield.remains<=(gcd+cooldown.BloodDrinker.ready*talent.BloodDrinker.enabled*2)|buff.bone_shield.stack<3)&runic_power.deficit>=20
        if S.Marrowrend:IsReady("Melee") and ((Player:BuffRemainsP(S.BoneShieldBuff) <= Player:RuneTimeToX(3) or Player:BuffRemainsP(S.BoneShieldBuff) <= (Player:GCD() + num(S.BloodDrinker:CooldownUpP()) * num(S.BloodDrinker:IsAvailable()) * 2) or Player:BuffStackP(S.BoneShieldBuff) < 3) and Player:RunicPowerDeficit() >= 20) then
            return S.Marrowrend:Cast()
        end

        if S.Marrowrend:IsReady("Melee") and ((Player:BuffRemainsP(S.BoneShieldBuff) <= Player:GCD() * 2)) then
            return S.Marrowrend:Cast()
        end
        -- blood_boil,if=charges_fractional>=1.8&(buff.hemostasis.stack<=(5-spell_targets.blood_boil)|spell_targets.blood_boil>2)
        if S.BloodBoil:IsReady() and Cache.EnemiesCount[8] >= 1 and (S.BloodBoil:ChargesFractional() >= 1.8 and (Player:BuffStackP(S.HemostasisBuff) <= (5 - Cache.EnemiesCount[5]) or Cache.EnemiesCount[5] > 2)) then
            return S.BloodBoil:Cast()
        end
        -- marrowrend,if=buff.bone_shield.stack<5&talent.ossuary.enabled&runic_power.deficit>=15
        if S.Marrowrend:IsReady("Melee") and (Player:BuffStackP(S.BoneShieldBuff) < 5 and S.Ossuary:IsAvailable() and Player:RunicPowerDeficit() >= 15) then
            return S.Marrowrend:Cast()
        end
        -- bonestorm,if=runic_power>=100&!buff.dancing_rune_weapon.up
        if S.Bonestorm:IsReady() and (Player:RunicPower() >= 100 and not Player:BuffP(S.DancingRuneWeaponBuff)) then
            return S.Bonestorm:Cast()
        end
        -- death_strike,if=runic_power.deficit<=(15+buff.dancing_rune_weapon.up*5+spell_targets.heart_strike*talent.HeartBreaker.enabled*2)|target.time_to_die<10
        if S.DeathStrike:IsReady() and (Player:RunicPowerDeficit() <= (15 + num(Player:BuffP(S.DancingRuneWeaponBuff)) * 5 + Cache.EnemiesCount[5] * num(S.HeartBreaker:IsAvailable()) * 2) or Target:TimeToDie() < 10) then
            return S.DeathStrike:Cast()
        end
        -- death_and_decay,if=spell_targets.death_and_decay>=3
        if S.DeathandDecay:IsReady() and (Cache.EnemiesCount[5] >= 3) then
            return S.DeathandDecay:Cast()
        end
        -- rune_strike,if=(charges_fractional>=1.8|buff.dancing_rune_weapon.up)&rune.time_to_3>=gcd
        if S.RuneStrike:IsReady("Melee") and ((S.RuneStrike:ChargesFractional() >= 1.8 or Player:BuffP(S.DancingRuneWeaponBuff)) and Player:RuneTimeToX(3) >= Player:GCD()) then
            return S.RuneStrike:Cast()
        end
        -- heart_strike,if=buff.dancing_rune_weapon.up|rune.time_to_4<gcd
        if S.HeartStrike:IsReady("Melee") and (Player:BuffP(S.DancingRuneWeaponBuff) or Player:RuneTimeToX(4) < Player:GCD()) then
            return S.HeartStrike:Cast()
        end
        -- blood_boil,if=buff.dancing_rune_weapon.up
        if S.BloodBoil:IsReady() and (Player:BuffP(S.DancingRuneWeaponBuff)) and Cache.EnemiesCount[8] >= 1 then
            return S.BloodBoil:Cast()
        end
        -- death_and_decay,if=buff.crimson_scourge.up|talent.rapid_decomposition.enabled|spell_targets.death_and_decay>=2
        if S.DeathandDecay:IsReady() and Player:AreaTTD() >= 6 and (Player:BuffP(S.CrimsonScourge) or S.RapidDecomposition:IsAvailable() or Cache.EnemiesCount[5] >= 2) then
            return S.DeathandDecay:Cast()
        end
        -- consumption
        if S.Consumption:IsReady() and (true) then
            return S.Consumption:Cast()
        end
        -- blood_boil
        if S.BloodBoil:IsReady() and Cache.EnemiesCount[8] >= 1 then
            return S.BloodBoil:Cast()
        end
        -- heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
        if S.HeartStrike:IsReady("Melee") and (Player:RuneTimeToX(3) < Player:GCD() or Player:BuffStackP(S.BoneShieldBuff) > 6) then
            return S.HeartStrike:Cast()
        end
        -- rune_strike
        if S.RuneStrike:IsReady("Melee") and (true) then
            return S.RuneStrike:Cast()
        end
        -- arcane_torrent,if=runic_power.deficit>20
        if S.ArcaneTorrent:IsReady() and (Player:RunicPowerDeficit() > 20) then
            return S.ArcaneTorrent:Cast()
        end
    end

    Standard = function()
        --Get Runes
        if S.RuneStrike:IsAvailable() and S.RuneStrike:IsReady("Melee") and Player:Runes() <= 4 then
            return S.RuneStrike:Cast()
        end

        --Needs Marrowrend
        if S.Marrowrend:IsReady("Melee") and (not Player:Buff(S.BoneShield) or Player:BuffRemains(S.BoneShield) <= 3 or Player:BuffStack(S.BoneShield) <= 1) then
            return S.Marrowrend:Cast()
        end

        if S.DeathStrike:IsReady() and Player:RunicPowerDeficit() < RubimRH.db.profile[250].sk6 then
            return S.DeathStrike:Cast()
        end

        --Needs Marrowrend
        if S.Marrowrend:IsReady("Melee") and (not Player:Buff(S.BoneShield) or Player:BuffRemains(S.BoneShield) <= 3 or Player:BuffStack(S.BoneShield) <= 5) then
            return S.Marrowrend:Cast()
        end

        if S.Bonestorm:IsReady() and Cache.EnemiesCount[8] >= 2 and Player:RunicPower() <= 99 and not Bonestorm:Queued() then
            S.Bonestorm:Queue()
        end

        --DSEmergency
        if Player:IncDmgPercentage() > RubimRH.db.profile[250].sk5 and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 85 and S.DeathStrike:TimeSinceLastCast() >= Player:GCD() * 2 then
            return S.DeathStrike:Cast()
        end

        --Mechanics
        if S.DeathStrike:IsReady("Melee") and Player:ActiveMitigationNeeded() then
            return S.DeathStrike:Cast()
        end

        --Overcap
        if S.DeathStrike:IsReady("Melee") and Player:RunicPowerDeficit() < RubimRH.db.profile[250].sk6 then
            return S.DeathStrike:Cast()
        end

        --DnD AoE
        if S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[10] >= 3 and Player:IsTankingAoE() then
            return S.DeathandDecay:Cast()
        end

        --BloodBoil
        if Player:IsTankingAoE() and S.BloodBoil:IsReady(10) and Cache.EnemiesCount[10] >= 3 then
            return S.BloodBoil:Cast()
        end

        --Overcap Math
        if S.DeathStrike:IsReady("Melee") and (Player:RunicPower() + (5 + math.min(Cache.EnemiesCount[8], 5) * 2)) >= Player:RunicPowerMax() then
            return S.DeathStrike:Cast()
        end

        --Heal needed
        if S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 85 and not RubimRH.config.Spells[1].isActive then
            return S.DeathStrike:Cast()
        end

        --actions.standard+=/death_and_decay,if=talent.rapid_decomposition.enabled&!buff.dancing_rune_weapon.up
        if S.DeathandDecay:IsReady(10) and S.RapidDecomposition:IsAvailable() and not Player:Buff(S.DancingRuneWeaponBuff) then
            return S.DeathandDecay:Cast()
        end

        --actions.standard+=/BloodDrinker,if=!buff.dancing_rune_weapon.up
        if S.BloodDrinker:IsReady() and S.BloodDrinker:IsReady() and not Player:Buff(S.DancingRuneWeaponBuff) and Player:BuffRemains(S.BoneShield) >= 3 and Player:Runes() >= 2 then
            return S.BloodDrinker:Cast()
        end

        --actions.standard+=/marrowrend,if=buff.bone_shield.remains<=gcd*2
        if S.Marrowrend:IsReady("Melee") and Player:BuffRemains(S.BoneShield) <= Player:GCD() * 2 then
            return S.Marrowrend:Cast()
        end

        --actions.standard+=/blood_boil,if=charges_fractional>=1.8&buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
        if S.BloodBoil:IsReady(10) and Cache.EnemiesCount[8] >= 1 and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStack(S.HaemostasisBuff) < 5 and (Player:BuffStack(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
            return S.BloodBoil:Cast()
        end

        --actions.standard+=/marrowrend,if=(buff.bone_shield.stack<5&talent.ossuary.enabled)|buff.bone_shield.remains<gcd*3
        if S.Marrowrend:IsReady("Melee") and ((Player:BuffStack(S.BoneShield) < 5 and S.Ossuary:IsAvailable()) or Player:BuffRemains(S.BoneShield) < Player:GCD() * 3) then
            return S.Marrowrend:Cast()
        end

        --actions.standard+=/bonestorm,if=runic_power>=100&spell_targets.bonestorm>=3
        --actions.standard+=/death_strike,if=buff.blood_shield.up|(runic_power.deficit<15&(runic_power.deficit<25|!buff.dancing_rune_weapon.up))
        --if S.DeathStrike:IsReady("Melee") and not RubimRH.config.Spells[1].isActive and (Player:Buff(S.BloodShield) or (Player:RunicPowerDeficit() < 15 and (Player:RunicPowerDeficit() < 25 or not Player:Buff(S.DancingRuneWeaponBuff)))) then
        --        return S.DeathStrike:Cast()
        --end

        --actions.standard+=/consumption
        if S.Consumption:IsAvailable() and S.Consumption:IsReady("Melee") and Cache.EnemiesCount["Melee"] >= 1 then
            return S.Consumption:Cast()
        end

        --actions.standard+=/heart_strike,if=buff.dancing_rune_weapon.up
        if S.HeartStrike:IsReady("Melee") and Player:Buff(S.DancingRuneWeaponBuff) and not RubimRH.config.Spells[2].isActive then
            return S.HeartStrike:Cast()
        end

        if S.HeartStrike:IsReady("Melee") and Player:Buff(S.DancingRuneWeaponBuff) and RubimRH.config.Spells[2].isActive and Player:Runes() >= 3 then
            return S.HeartStrike:Cast()
        end

        --actions.standard+=/death_and_decay,if=buff.crimson_scourge.up
        if S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and Player:Buff(S.CrimsonScourge) and RubimRH.lastMoved() > 0.5 then
            return S.DeathandDecay:Cast()
        end

        --actions.standard+=/blood_boil,if=buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
        if S.BloodBoil:IsReady(10) and Cache.EnemiesCount[8] >= 1 and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStack(S.HaemostasisBuff) < 5 and (Player:BuffStack(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
            return S.BloodBoil:Cast()
        end
        --actions.standard+=/death_and_decay
        if S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and RubimRH.lastMoved() > 0.5 and not RubimRH.config.Spells[2].isActive then
            return S.DeathandDecay:Cast()
        end

        if S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and RubimRH.lastMoved() > 0.5 and RubimRH.config.Spells[2].isActive and Player:Runes() >= 3 then
            return S.DeathandDecay:Cast()
        end

        --actions.standard+=/heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
        if S.HeartStrike:IsReady("Melee") and ((Player:RuneTimeToX(3) <= Player:GCD()) or Player:BuffStack(S.BoneShield) >= 6) and not RubimRH.config.Spells[2].isActive then
            return S.HeartStrike:Cast()
        end

        if S.HeartStrike:IsReady("Melee") and ((Player:RuneTimeToX(3) <= Player:GCD()) or (Player:BuffStack(S.BoneShield) >= 6 and Player:Runes() >= 3)) and RubimRH.config.Spells[2].isActive then
            return S.HeartStrike:Cast()
        end
    end

    --if Target:MinDistanceToPlayer(true) >= 15 and Target:MinDistanceToPlayer(true) <= 40 and S.DeathGrip:IsReady() and Target:IsQuestMob() and S.DeathGrip:TimeSinceLastCast() >= Player:GCD() then
    --        return S.DeathGrip:Cast()
    --    end

    ----CHANNEL BLOOD DRINKER
    if Player:IsChanneling(S.BloodDrinker) or Player:IsChanneling(S.WraithWalk) then
        return 0, 236353
    end

    if QueueSkill() ~= nil then

        if RubimRH.QueuedSpell():ID() == S.Bonestorm:ID() then

            if Player:RunicPower() >= 100 then
                return QueueSkill()
            end

        else
            return QueueSkill()
        end
    end

    --Mov Speed
    if Player:MovingFor() >= 2 and S.DeathsAdvance:IsReadyMorph() then
        return S.DeathsAdvance:Cast()
    end

    if not Player:AffectingCombat() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end

    if S.DancingRuneWeapon:IsReady() and Target:IsQuestMob() then
        return S.DancingRuneWeapon:Cast()
    end

    -- custom
    if S.VampiricBlood:IsCastable() and Player:HealthPercentage() <= RubimRH.db.profile[250].sk3 then
        return S.VampiricBlood:Cast()
    end

    -- mind_freeze
    if S.MindFreeze:IsReady() and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.MindFreeze:Cast()
    end
    -- blood_fury,if=cooldown.dancing_rune_weapon.ready&(!cooldown.BloodDrinker.ready|!talent.BloodDrinker.enabled)
    if S.BloodFury:IsCastable() and (S.DancingRuneWeapon:CooldownUpP() and (not S.BloodDrinker:CooldownUpP() or not S.BloodDrinker:IsAvailable())) then
        return S.BloodFury:Cast()
    end
    -- berserking
    if S.Berserking:IsCastable() and (true) then
        return S.Berserking:Cast()
    end
    -- use_items
    -- potion,if=buff.dancing_rune_weapon.up
    -- dancing_rune_weapon,if=!talent.BloodDrinker.enabled|!cooldown.BloodDrinker.ready
    if S.DancingRuneWeapon:IsReady() and RubimRH.CDsON() and (not S.BloodDrinker:IsAvailable() or not S.BloodDrinker:CooldownUpP()) then
        return S.DancingRuneWeapon:Cast()
    end
    -- tombstone,if=buff.bone_shield.stack>=7
    if S.Tombstone:IsReady() and (Player:BuffStackP(S.BoneShieldBuff) >= 7) then
        return S.Tombstone:Cast()
    end

    if Target:IsPvEImmunity() then
        return Immunity()
    end

    -- call_action_list,name=standard
    if (true) then
        if StandardSimc() ~= nil then
            return StandardSimc()
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(250, APL);

local function PASSIVE()
    if Player:AffectingCombat() then
        if S.IceboundFortitude:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[250].sk1 then
            return S.IceboundFortitude:Cast()
        end

        if S.RuneTap:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[250].sk2 then
            return S.RuneTap:Cast()
        end

        if RubimRH.Shared() ~= nil then
            return RubimRH.Shared()
        end
    end
end

RubimRH.Rotation.SetPASSIVE(250, PASSIVE);
