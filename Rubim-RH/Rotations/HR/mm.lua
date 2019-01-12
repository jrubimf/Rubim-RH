local addonName, addonTable = ...;
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Pet = Unit.Pet;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
RubimRH.Spell[254] = {
    ArcaneTorrent = Spell(80483),
    AncestralCall = Spell(274738),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Fireblood = Spell(265221),
    GiftoftheNaaru = Spell(59547),
    LightsJudgment = Spell(255647),
    --Pet
    CallPet = Spell(883),
    MendPet = Spell(136),
    RevivePet = Spell(982),
    -- Abilities
    AimedShot = Spell(19434),
    ArcaneShot = Spell(185358),
    BurstingShot = Spell(186387),
    MultiShot = Spell(257620),
    PreciseShots = Spell(260242),
    PreciseShotsBuff = Spell(260242),
    RapidFire = Spell(257044),
    SteadyAim = Spell(277651),
    SteadyAimDebuff = Spell(277957),
    SteadyShot = Spell(56641),
    SteadyShotBuff = Spell(56641),
    TrickShots = Spell(257622),
    TrickShotsBuff = Spell(257622),
    TrueShot = Spell(193526),
    -- Talents
    AMurderofCrows = Spell(131894),
    Barrage = Spell(120360),
    BindingShot = Spell(109248),
    CallingtheShots = Spell(260404),
    CarefulAim = Spell(260228),
    DoubleTap = Spell(260402),
    DoubleTapBuff = Spell(260402),
    ExplosiveShot = Spell(212431),
    FocusedFire = Spell(278531),
    HuntersMark = Spell(257284),
    HuntersMarkDebuff = Spell(257284),
    InTheRhythm = Spell(264198),
    LethalShots = Spell(260393),
    LethalShotsBuff = Spell(260395),
    LockandLoad = Spell(194594),
    MasterMarksman = Spell(260309),
    PiercingShot = Spell(198670),
    SerpentSting = Spell(271788),
    SerpentStingDebuff = Spell(271788),
    SteadyFocus = Spell(193533),
    SteadyFocusBuff = Spell(193533),
    SteadyBuff = Spell(193533),
    Volley = Spell(260243),
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
    SentinelsSight = Spell(208913),
    -- Misc
    CriticalAimed = Spell(242243),
    PotionOfProlongedPowerBuff = Spell(229206),
    SephuzBuff = Spell(208052),
    MKIIGyroscopicStabilizer = Spell(235691),
}

local S = RubimRH.Spell[254]

if not Item.Hunter then
    Item.Hunter = {}
end

Item.Hunter.Marksmanship = {
    -- Legendaries
    SephuzSecret = Item(132452, { 11, 12 }),
    -- Trinkets
    onvergenceofFates = Item(140806, { 13, 14 }),
    -- Potions
    PotionOfProlongedPower = Item(142117),
}
local I = Item.Hunter.Marksmanship

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

S.AimedShot:RegisterInFlight()

--- APL Main
local function APL ()
    local SingleTarget, SteadyST, TrickShots
    HL.GetEnemies(40)

    if Player:IsChanneling() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end

    if not Player:AffectingCombat() then

        --    if S.MendPet:IsCastable() and Pet:IsActive() and (Cache.EnemiesCount[40] < 3)  and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= 95 and not Pet:Buff(S.MendPet) then
        --        return S.MendPet:Cast()
        --    end

        --        if Pet:IsDeadOrGhost() and (Cache.EnemiesCount[40] < 3) then
        --            return S.MendPet:Cast()
        --        elseif not Pet:IsActive() and (Cache.EnemiesCount[40] < 3) then
        --            return S.CallPet:Cast()
        --        end

        if RubimRH.TargetIsValid() then
            if S.HuntersMark:IsReady() and not Target:Debuff(S.HuntersMarkDebuff) then
                return S.HuntersMark:Cast()
            end
            -- double_tap,precast_time=5
            if S.DoubleTap:IsReady() then
                return S.DoubleTap:Cast()
            end
            -- aimed_shot,if=active_enemies<3
            if S.AimedShot:IsReady() and (Cache.EnemiesCount[40] < 3) and RubimRH.lastMoved() >= 0.5 then
                return S.AimedShot:Cast()
            end
            -- explosive_shot,if=active_enemies>2
            if S.ExplosiveShot:IsReady() and (Cache.EnemiesCount[40] > 2) then
                return S.ExplosiveShot:Cast()
            end
        end
        return 0, 462338
    end

    if QueueSkill() ~= nil then
        return QueueSkill()
    end

    if S.Exhilaration:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[254].sk1 then
        return S.Exhilaration:Cast()
    end

    -- auto_shot
    -- counter_shot,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
    -- Counter Shot -> User request
    if S.CounterShot:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.CounterShot:Cast()
    end


    --    if S.MendPet:IsCastable() and Pet:IsActive() and (Cache.EnemiesCount[40] < 3)  and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= 95 and not Pet:Buff(S.MendPet) then
    --        return S.MendPet:Cast()
    --    end

    --    if Pet:IsDeadOrGhost() and (Cache.EnemiesCount[40] < 3) then
    --        return S.MendPet:Cast()
    --    elseif not Pet:IsActive() and (Cache.EnemiesCount[40] < 3) then
    --        return S.MendPet:Cast()
    --    end

    if S.HuntersMark:IsReady(nil, nil, Target) and not Target:Debuff(S.HuntersMarkDebuff) then
        return S.HuntersMark:Cast()
    end
    -- double_tap,if=cooldown.rapid_fire.remains<gcd
    if S.DoubleTap:IsReady(nil, nil, Target) and (S.RapidFire:CooldownRemainsP() < Player:GCD()) then
        return S.DoubleTap:Cast()
    end
    -- berserking,if=cooldown.trueshot.remains>30
    if S.Berserking:IsReady(nil, nil, Target) and RubimRH.CDsON() and RubimRH.RacialON() and (S.TrueShot:CooldownRemainsP() > 30) then
        return S.Berserking:Cast()
    end
    -- blood_fury,if=cooldown.trueshot.remains>30
    if S.BloodFury:IsReady(nil, nil, Target) and RubimRH.CDsON() and RubimRH.RacialON() and (S.TrueShot:CooldownRemainsP() > 30) then
        return S.BloodFury:Cast()
    end
    -- ancestral_call,if=cooldown.trueshot.remains>30
    if S.AncestralCall:IsReady(nil, nil, Target) and RubimRH.RacialON() and (S.TrueShot:CooldownRemainsP() > 30) then
        return S.AncestralCall:Cast()
    end
    -- fireblood,if=cooldown.trueshot.remains>30
    if S.Fireblood:IsReady(nil, nil, Target) and RubimRH.RacialON() and (S.TrueShot:CooldownRemainsP() > 30) then
        return S.Fireblood:Cast()
    end
    -- lights_judgment
    if S.LightsJudgment:IsReady(nil, nil, Target) and RubimRH.RacialON() and RubimRH.CDsON() then
        return S.LightsJudgment:Cast()
    end
    -- potion,if=(buff.trueshot.react&buff.bloodlust.react)|((consumable.prolonged_power&target.time_to_die<62)|target.time_to_die<31)

    -- trueshot,if=cooldown.aimed_shot.charges<1
    if S.TrueShot:IsReady(nil, nil, Target) and (S.AimedShot:ChargesP() < 1) then
        return S.TrueShot:Cast()
    end
    -- barrage,if=active_enemies>1
    if S.Barrage:IsReady(nil, nil, Target) and (Cache.EnemiesCount[40] > 1) then
        return S.Barrage:Cast()
    end
    -- explosive_shot,if=active_enemies>1
    if S.ExplosiveShot:IsReady(nil, nil, Target) and (Cache.EnemiesCount[40] > 1) then
        return S.ExplosiveShot:Cast()
    end
    -- multishot,if=active_enemies>2&buff.precise_shots.up&cooldown.aimed_shot.full_recharge_time<gcd*buff.precise_shots.stack+action.aimed_shot.cast_time
    if S.MultiShot:IsReady(nil, nil, Target) and  RubimRH.AoEON() and (Cache.EnemiesCount[40] > 2 and Player:BuffP(S.PreciseShotsBuff) and S.AimedShot:FullRechargeTime() < Player:GCD() * Player:BuffStackP(S.PreciseShotsBuff) + S.AimedShot:CastTime()) then
        return S.MultiShot:Cast()
    end
    -- arcane_shot,if=active_enemies<3&buff.precise_shots.up&cooldown.aimed_shot.full_recharge_time<gcd*buff.precise_shots.stack+action.aimed_shot.cast_time
    if S.ArcaneShot:IsReady(nil, nil, Target) and (Cache.EnemiesCount[40] < 3 and Player:BuffP(S.PreciseShotsBuff) and S.AimedShot:FullRechargeTime() < Player:GCD() * Player:BuffStackP(S.PreciseShotsBuff) + S.AimedShot:CastTime()) then
        return S.ArcaneShot:Cast()
    end
    -- aimed_shot,if=buff.precise_shots.down&buff.double_tap.down&(active_enemies>2&buff.trick_shots.up|active_enemies<3&full_recharge_time<cast_time+gcd)
    if S.AimedShot:IsReady(nil, nil, Target) and RubimRH.AoEON() and (Player:BuffDownP(S.PreciseShotsBuff) and Player:BuffDownP(S.DoubleTapBuff) and (Cache.EnemiesCount[40] > 2 and Player:BuffP(S.TrickShotsBuff) or Cache.EnemiesCount[40] < 3 and S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime() + Player:GCD())) then
        return S.AimedShot:Cast()
    end
    -- rapid_fire,if=active_enemies<3|buff.trick_shots.up
    if S.RapidFire:IsReady(nil, nil, Target) and (Cache.EnemiesCount[40] < 3 or Player:BuffP(S.TrickShotsBuff)) then
        return S.RapidFire:Cast()
    end
    -- explosive_shot
    if S.ExplosiveShot:IsReady(nil, nil, Target) and (true) then
        return S.ExplosiveShot:Cast()
    end
    -- piercing_shot
    if S.PiercingShot:IsReady(nil, nil, Target) and (true) then
        return S.PiercingShot:Cast()
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsReady(nil, nil, Target) and (true) then
        return S.AMurderofCrows:Cast()
    end
    -- multishot,if=active_enemies>2&buff.trick_shots.down
    if S.MultiShot:IsReady(nil, nil, Target) and RubimRH.AoEON() and (Cache.EnemiesCount[40] > 2 and Player:BuffDownP(S.TrickShotsBuff)) then
        return S.MultiShot:Cast()
    end
    -- aimed_shot,if=buff.precise_shots.down&(focus>70|buff.steady_focus.down)
    if S.AimedShot:IsReady(nil, nil, Target) and (Player:BuffDownP(S.PreciseShotsBuff) and (Player:Focus() > 70 or Player:BuffDownP(S.SteadyFocusBuff))) then
        return S.AimedShot:Cast()
    end
    -- multishot,if=active_enemies>2&(focus>90|buff.precise_shots.up&(focus>70|buff.steady_focus.down&focus>45))
    if S.MultiShot:IsReady(nil, nil, Target) and RubimRH.AoEON() and (Cache.EnemiesCount[40] > 2 and (Player:Focus() > 90 or Player:BuffP(S.PreciseShotsBuff) and (Player:Focus() > 70 or Player:BuffDownP(S.SteadyFocusBuff) and Player:Focus() > 45))) then
        return S.MultiShot:Cast()
    end
    -- arcane_shot,if=active_enemies<3&(focus>70|buff.steady_focus.down&(focus>60|buff.precise_shots.up))
    if S.ArcaneShot:IsReady(nil, nil, Target) and (Cache.EnemiesCount[40] < 3 and (Player:Focus() > 70 or Player:BuffDownP(S.SteadyFocusBuff) and (Player:Focus() > 60 or Player:BuffP(S.PreciseShotsBuff)))) then
        return S.ArcaneShot:Cast()
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsReady(nil, nil, Target) and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
        return S.SerpentSting:Cast()
    end
    -- steady_shot
    if S.SteadyShot:IsReady(nil, nil, Target) and (true) then
        return S.SteadyShot:Cast()
    end

    return 0, 135328
end
RubimRH.Rotation.SetAPL(254, APL)
local function PASSIVE()
    if S.AspectoftheTurtle:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[254].sk2 then
        return S.AspectoftheTurtle:Cast()
    end

    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(254, PASSIVE)