--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Pet = Unit.Pet;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
-- Spells
RubimRH.Spell[253] = {
    -- Racials
    ArcaneTorrent = Spell(80483),
    AncestralCall = Spell(274738),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Fireblood = Spell(265221),
    GiftoftheNaaru = Spell(59547),
    LightsJudgment = Spell(255647),
    -- Pet
    CallPet = Spell(883),
    MendPet = Spell(136),
    RevivePet = Spell(982),
    -- Abilities
    AspectoftheWild = Spell(193530),
    BarbedShot = Spell(217200),
    Frenzy = Spell(272790),
    FrenzyBuff = Spell(272790),
    BeastCleave = Spell(115939),
    BeastCleaveBuff = Spell(118455),
    BestialWrath = Spell(19574),
    BestialWrathBuff = Spell(19574),
    CobraShot = Spell(193455),
    KillCommand = Spell(34026),
    MultiShot = Spell(2643),
    -- Talents
    AMurderofCrows = Spell(131894),
    AnimalCompanion = Spell(267116),
    AspectoftheBeast = Spell(191384),
    Barrage = Spell(120360),
    BindingShot = Spell(109248),
    ChimaeraShot = Spell(53209),
    DireBeast = Spell(120679),
    KillerInstinct = Spell(273887),
    OnewiththePack = Spell(199528),
    ScentofBlood = Spell(193532),
    SpittingCobra = Spell(194407),
    Stampede = Spell(201430),
    ThrilloftheHunt = Spell(257944),
    VenomousBite = Spell(257891),
    -- Defensive
    AspectoftheTurtle = Spell(186265),
    Exhilaration = Spell(109304),
    -- Utility
    AspectoftheCheetah = Spell(186257),
    CounterShot = Spell(147362),
    Disengage = Spell(781),
    FreezingTrap = Spell(187650),
    FeignDeath = Spell(5384),
    TarTrap = Spell(187698),
    -- Legendaries
    ParselsTongueBuff = Spell(248084),
    -- Misc
    PotionOfProlongedPowerBuff = Spell(229206),
    SephuzBuff = Spell(208052),
    -- Macros
}

local S = RubimRH.Spell[253]

S.CallPet.TextureSpellID = { S.MendPet:ID() }
S.RevivePet.TextureSpellID = { S.MendPet:ID() }

-- Items
if not Item.Hunter then
    Item.Hunter = { };
end
Item.Hunter.BeastMastery = {
    -- Legendaries
    CalloftheWild = Item(137101, { 9 }),
    TheMantleofCommand = Item(144326, { 3 }),
    ParselsTongue = Item(151805, { 5 }),
    QaplaEredunWarOrder = Item(137227, { 8 }),
    SephuzSecret = Item(132452, { 11, 12 }),
    -- Trinkets
    ConvergenceofFates = Item(140806, { 13, 14 }),
    -- Potions
    PotionOfProlongedPower = Item(142117),
};
local I = Item.Hunter.BeastMastery;

local function PetActive()
    local petActive = false
    if Pet:Exists() then
        petActive = true
    end

    if Pet:IsActive() then
        petActive = true
    end

    if Pet:IsDeadOrGhost() then
        petActive = false
    end

    return petActive
end

--- APL Main
local function APL ()
    -- Unit Update
    HL.GetEnemies(40);
    -- Defensives
    -- Exhilaration
    --if S.Exhilaration:IsReady() and Player:HealthPercentage() <= HPCONFIG then
    --        return S.Exhilaration:Cast()
    --    end
    -- Out of Combat
    if not Player:AffectingCombat() then
        if S.MendPet:IsCastable() and Pet:IsActive() and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= RubimRH.db.profile[253].sk1 and not Pet:Buff(S.MendPet) then
            return S.MendPet:Cast()
        end

        if Pet:IsDeadOrGhost() then
            return S.MendPet:Cast()
        elseif not Pet:IsActive() then
            return S.CallPet:Cast()
        end
        -- Flask
        -- Food
        -- Rune
        -- PrePot w/ Bossmod Countdown
        -- Opener
        if RubimRH.TargetIsValid() and Target:IsInRange(40) then
            if RubimRH.CDsON() then
                if S.AMurderofCrows:IsReady() then
                    return S.AMurderofCrows:Cast()
                end
            end
            if PetActive() and S.BestialWrath:IsReady() and not Player:Buff(S.BestialWrath) then
                return S.BestialWrath:Cast()
            end
            -- if S.BarbedShot:IsReady() then

            -- end
            if PetActive() and S.KillCommand:IsReady() then
                return S.KillCommand:Cast()
            end
            if S.CobraShot:IsReady() then
                return S.CobraShot:Cast()
            end
        end
        return 0, 462338
    end

    if S.MendPet:IsCastable() and Pet:IsActive() and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= RubimRH.db.profile[253].sk1 and not Pet:Buff(S.MendPet) then
        return S.MendPet:Cast()
    end

    if Pet:IsDeadOrGhost() then
        return S.MendPet:Cast()
    elseif not Pet:IsActive() then
        return S.MendPet:Cast()
    end


    -- In Combat
    if RubimRH.TargetIsValid() then

        -- Counter Shot -> User request
        if S.CounterShot:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
            return S.CounterShot:Cast()
        end

        -- actions+=/counter_shot,if=target.debuff.casting.react // Sephuz Specific
        if RubimRH.CDsON() then
            -- actions+=/arcane_torrent,if=focus.deficit>=30
            --if S.ArcaneTorrent:IsReady() and Player:FocusDeficit() >= 30 then

            --end
            -- actions+=/berserking,if=cooldown.bestial_wrath.remains>30
            if S.Berserking:IsReady() and S.BestialWrath:CooldownRemains() > 30 then
                return S.Berserking:Cast()
            end
            -- actions+=/blood_fury,if=buff.bestial_wrath.remains>7
            if S.BloodFury:IsReady() and S.BestialWrath:CooldownRemains() > 30 then
                return S.BloodFury:Cast()
            end
            -- actions+=/ancestral_call,if=cooldown.bestial_wrath.remains>30
            if S.AncestralCall:IsReady() and S.BestialWrath:CooldownRemains() > 30 then
                return S.AncestralCall:Cast()
            end
            -- actions+=/fireblood,if=cooldown.bestial_wrath.remains>30
            if S.Fireblood:IsReady() and S.BestialWrath:CooldownRemains() > 30 then
                return S.Fireblood:Cast()
            end
            -- actions+=/lights_judgment
            if S.LightsJudgment:IsReady() then
                return S.LightsJudgment:Cast()
            end
        end
        -- actions+=/potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
        -- barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
        if S.BarbedShot:IsReady() and (Pet:BuffP(S.FrenzyBuff) and Pet:BuffRemainsP(S.FrenzyBuff) <= Player:GCD()) then
            return S.BarbedShot:Cast()
        end
        -- a_murder_of_crows
        if S.AMurderofCrows:IsReady() and (true) then
            return S.AMurderofCrows:Cast()
        end
        -- spitting_cobra
        if S.SpittingCobra:IsReady() and (true) then
            return S.SpittingCobra:Cast()
        end
        -- stampede,if=buff.bestial_wrath.up|cooldown.bestial_wrath.remains<gcd|target.time_to_die<15
        if S.Stampede:IsReady() and (Player:BuffP(S.BestialWrathBuff) or S.BestialWrath:CooldownRemainsP() < Player:GCD() or Target:TimeToDie() < 15) then
            return S.Stampede:Cast()
        end
        -- aspect_of_the_wild
        if RubimRH.CDsON() and S.AspectoftheWild:IsReady() and (true) then
            return S.AspectoftheWild:Cast()
        end
        -- bestial_wrath,if=!buff.bestial_wrath.up
        if PetActive() and S.BestialWrath:IsReady() and (not Player:BuffP(S.BestialWrathBuff)) then
            return S.BestialWrath:Cast()
        end
        -- MultiShot,if=spell_targets>2&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
        if RubimRH.AoEON() and S.MultiShot:IsReady() and (Cache.EnemiesCount[40] > 2 and (Pet:BuffRemainsP(S.BeastCleaveBuff) < Player:GCD() or Pet:BuffDownP(S.BeastCleaveBuff))) then
            return S.MultiShot:Cast()
        end
        -- chimaera_shot
        if S.ChimaeraShot:IsReady() and (true) then
            return S.ChimaeraShot:Cast()
        end
        -- kill_command
        if PetActive() and S.KillCommand:IsReady() and (true) then
            return S.KillCommand:Cast()
        end
        -- dire_beast
        if S.DireBeast:IsReady() and (true) then
            return S.DireBeast:Cast()
        end
        -- barbed_shot,if=pet.cat.buff.frenzy.down&charges_fractional>1.4|full_recharge_time<gcd.max|target.time_to_die<9
        if S.BarbedShot:IsReady() and (Pet:BuffDownP(S.FrenzyBuff) and S.BarbedShot:ChargesFractional() > 1.4 or S.BarbedShot:FullRechargeTimeP() < Player:GCD() * 2 or Target:TimeToDie() < 9) then
            return S.BarbedShot:Cast()
        end
        -- MultiShot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
        if RubimRH.AoEON() and S.MultiShot:IsReady() and (Cache.EnemiesCount[40] > 1 and (Pet:BuffRemainsP(S.BeastCleaveBuff) < Player:GCD() or Pet:BuffDownP(S.BeastCleaveBuff))) then
            return S.MultiShot:Cast()
        end
        -- cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(buff.bestial_wrath.up&active_enemies>1|cooldown.kill_command.remains>1+gcd&cooldown.bestial_wrath.remains>focus.time_to_max|focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost)
        if S.CobraShot:IsReady() and ((Cache.EnemiesCount[40] < 2 or S.KillCommand:CooldownRemains() > Player:FocusTimeToMax()) and (Player:Buff(S.BestialWrathBuff) and Cache.EnemiesCount[40] > 1 or S.KillCommand:CooldownRemains() > 1 + Player:GCD() and S.BestialWrath:CooldownRemains() > Player:FocusTimeToMax() or S.CobraShot:Cost() + Player:FocusRegen() * (S.KillCommand:CooldownRemains() - 1) > S.KillCommand:Cost())) then
            return S.CobraShot:Cast()
        end

    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(253, APL);

local function PASSIVE()
    if S.AspectoftheTurtle:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[253].sk2 then
        return S.AspectoftheTurtle:Cast()
    end

    if S.Exhilaration:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[253].sk3 then
        return S.Exhilaration:Cast()
    end

    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(253, PASSIVE);
--- Last Update: 07/17/2018

-- # Executed before combat begins. Accepts non-harmful actions only.
-- actions.precombat=flask
-- actions.precombat+=/augmentation
-- actions.precombat+=/food
-- actions.precombat+=/summon_pet
-- # Snapshot raid buffed stats before combat begins and pre-potting is done.
-- actions.precombat+=/snapshot_stats
-- actions.precombat+=/potion
-- actions.precombat+=/aspect_of_the_wild

-- # Executed every time the actor is available.
-- actions=auto_shot
-- actions+=/counter_shot,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
-- actions+=/use_items
-- actions+=/berserking,if=cooldown.bestial_wrath.remains>30
-- actions+=/blood_fury,if=cooldown.bestial_wrath.remains>30
-- actions+=/ancestral_call,if=cooldown.bestial_wrath.remains>30
-- actions+=/fireblood,if=cooldown.bestial_wrath.remains>30
-- actions+=/lights_judgment
-- actions+=/potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
-- actions+=/barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
-- actions+=/a_murder_of_crows
-- actions+=/spitting_cobra
-- actions+=/stampede,if=buff.bestial_wrath.up|cooldown.bestial_wrath.remains<gcd|target.time_to_die<15
-- actions+=/aspect_of_the_wild
-- actions+=/bestial_wrath,if=!buff.bestial_wrath.up
-- actions+=/MultiShot,if=spell_targets>2&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
-- actions+=/chimaera_shot
-- actions+=/kill_command
-- actions+=/dire_beast
-- actions+=/barbed_shot,if=pet.cat.buff.frenzy.down&charges_fractional>1.4|full_recharge_time<gcd.max|target.time_to_die<9
-- actions+=/barrage
-- actions+=/MultiShot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
-- actions+=/cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(buff.bestial_wrath.up&active_enemies>1|cooldown.kill_command.remains>1+gcd&cooldown.bestial_wrath.remains>focus.time_to_max|focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost)
