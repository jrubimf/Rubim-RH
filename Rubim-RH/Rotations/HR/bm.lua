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

local mainAddon = RubimRH

-- Spells
mainAddon.Spell[253] = {
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
    ConcussiveShot = Spell(5116),
    ScorpidSting = Spell(202900),
    Intimidation = Spell(19577),
    -- Macros

}

local S = mainAddon.Spell[253]

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


local function bool(val)
    return val ~= 0
end

local function cacheOverwrite()
    Cache.Persistent.SpellLearned.Player[S.MendPet.SpellID] = true
end

--- APL Main
local function APL ()
    cacheOverwrite()
    -- Unit Update
    HL.GetEnemies(40);
    -- Defensives
    -- Exhilaration
    --if S.Exhilaration:IsReady() and Player:HealthPercentage() <= HPCONFIG then
    --        return S.Exhilaration:Cast()
    --    end
    -- Out of Combat
    if not Player:AffectingCombat() then
        if S.MendPet:IsCastable() and Pet:IsActive() and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= mainAddon.db.profile[253].sk1 and not Pet:Buff(S.MendPet) then
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
        if mainAddon.TargetIsValid() and Target:IsInRange(40) then
            if mainAddon.CDsON() then
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

    if S.MendPet:IsCastable() and Pet:IsActive() and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= mainAddon.db.profile[253].sk1 and not Pet:Buff(S.MendPet) then
        return S.MendPet:Cast()
    end

    if Pet:IsDeadOrGhost() then
        return S.MendPet:Cast()
    elseif not Pet:IsActive() then
        return S.MendPet:Cast()
    end

    if QueueSkill() ~= nil then
        return QueueSkill()
    end


    -- auto_shot
    -- use_items
    if S.Berserking:IsReady() and RubimRH.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
        return S.Berserking:Cast()
    end
    -- blood_fury,if=cooldown.bestial_wrath.remains>30
    if S.BloodFury:IsReady() and RubimRH.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
        return S.BloodFury:Cast()
    end
    -- ancestral_call,if=cooldown.bestial_wrath.remains>30
    if S.AncestralCall:IsReady() and RubimRH.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
        return S.AncestralCall:Cast()
    end
    -- fireblood,if=cooldown.bestial_wrath.remains>30
    if S.Fireblood:IsReady() and RubimRH.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
        return S.Fireblood:Cast()
    end
    -- potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up&(target.health.pct<35|!talent.killer_instinct.enabled)|target.time_to_die<25
    -- barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max|full_recharge_time<gcd.max&cooldown.bestial_wrath.remains
    if S.BarbedShot:IsReady(Target) and (Pet:BuffP(S.FrenzyBuff) and Pet:BuffRemainsP(S.FrenzyBuff) <= Player:GCD() or S.BarbedShot:FullRechargeTimeP() < Player:GCD() and bool(S.BestialWrath:CooldownRemainsP())) then
        return S.BarbedShot:Cast(Target)
    end
    -- lights_judgment
    if S.LightsJudgment:IsReady(Target) and RubimRH.CDsON() then
        return S.LightsJudgment:Cast(Target)
    end
    -- spitting_cobra
    if S.SpittingCobra:IsReady(Target) then
        return S.SpittingCobra:Cast(Target)
    end
    -- aspect_of_the_wild
    if S.AspectoftheWild:IsReady() and RubimRH.CDsON() then
        return S.AspectoftheWild:Cast()
    end
    -- a_murder_of_crows,if=active_enemies=1
    if S.AMurderofCrows:IsReady(Target) and (Player:EnemiesAround(40) == 1) then
        return S.AMurderofCrows:Cast(Target)
    end
    -- stampede,if=buff.aspect_of_the_wild.up&buff.bestial_wrath.up|target.time_to_die<15
    if S.Stampede:IsReady(Target) and (Player:BuffP(S.AspectoftheWildBuff) and Player:BuffP(S.BestialWrathBuff) or Target:TimeToDie() < 15) then
        return S.Stampede:Cast(Target)
    end
    -- multishot,if=spell_targets>2&gcd.max-pet.cat.buff.beast_cleave.remains>0.25
    if S.Multishot:IsReady(Target) and (Cache.EnemiesCount[40] > 2 and Player:GCD() - Pet:BuffRemainsP(S.BeastCleaveBuff) > 0.25) then
        return S.Multishot:Cast(Target)
    end
    -- bestial_wrath,if=cooldown.aspect_of_the_wild.remains>20|target.time_to_die<15
    if S.BestialWrath:IsReady() and (S.AspectoftheWild:CooldownRemainsP() > 20 or Target:TimeToDie() < 15) then
        return S.BestialWrath:Cast()
    end
    -- barrage,if=active_enemies>1
    if S.Barrage:IsReady(Target) and Target:Exists() and (Cache.EnemiesCount[40] > 1) then
        return S.Barrage:Cast()
    end
    -- chimaera_shot,if=spell_targets>1
    if S.ChimaeraShot:IsReady(Target) and (Cache.EnemiesCount[40] > 1) then
        return S.ChimaeraShot:Cast()
    end
    -- multishot,if=spell_targets>1&gcd.max-pet.cat.buff.beast_cleave.remains>0.25
    if S.Multishot:IsReady(Target) and (Cache.EnemiesCount[40] > 1 and Player:GCD() - Pet:BuffRemainsP(S.BeastCleaveBuff) > 0.25) then
        return S.Multishot:Cast()
    end
    -- kill_command
    if S.KillCommand:IsReady(Target) then
        return S.KillCommand:Cast()
    end
    -- chimaera_shot
    if S.ChimaeraShot:IsReady(Target) then
        return S.ChimaeraShot:Cast()
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsReady(Target) then
        return S.AMurderofCrows:Cast()
    end
    -- dire_beast
    if S.DireBeast:IsReady(Target) then
        return S.DireBeast:Cast()
    end
    -- barbed_shot,if=pet.cat.buff.frenzy.down&(charges_fractional>1.8|buff.bestial_wrath.up)|cooldown.aspect_of_the_wild.remains<6&azerite.primal_instincts.enabled|target.time_to_die<9
    if S.BarbedShot:IsReady(Target) and (Pet:BuffDownP(S.FrenzyBuff) and (S.BarbedShot:ChargesFractionalP() > 1.8 or Player:BuffP(S.BestialWrathBuff)) or S.AspectoftheWild:CooldownRemainsP() < 6 and S.PrimalInstincts:AzeriteEnabled() or Target:TimeToDie() < 9) then
        return S.BarbedShot:Cast()
    end
    -- barrage
    if S.Barrage:IsReady(Target) and Target:Exists() then
        return S.Barrage:Cast()
    end
    -- cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost|cooldown.kill_command.remains>1+gcd)&cooldown.kill_command.remains>1
    if S.CobraShot:IsReady(Target) and ((Cache.EnemiesCount[40] < 2 or S.KillCommand:CooldownRemainsP() > Player:FocusTimeToMaxPredicted()) and (Player:Focus() - S.CobraShot:Cost() + Player:FocusRegen() * (S.KillCommand:CooldownRemainsP() - 1) > S.KillCommand:Cost() or S.KillCommand:CooldownRemainsP() > 1 + Player:GCD()) and S.KillCommand:CooldownRemainsP() > 1) then
        return S.CobraShot:Cast()
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() then
        return S.ArcaneTorrent:Cast()
    end

    return 0, 135328
end

mainAddon.Rotation.SetAPL(253, APL);

local function PASSIVE()
    if S.AspectoftheTurtle:IsCastable() and Player:HealthPercentage() <= mainAddon.db.profile[253].sk2 then
        return S.AspectoftheTurtle:Cast()
    end

    if S.Exhilaration:IsCastable() and Player:HealthPercentage() <= mainAddon.db.profile[253].sk3 then
        return S.Exhilaration:Cast()
    end

    return mainAddon.Shared()
end

mainAddon.Rotation.SetPASSIVE(253, PASSIVE);
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