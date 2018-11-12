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

    if RubimRH.TargetIsValid() then
        if RubimRH.CDsON() then
            --cds=hunters_mark,if=debuff.hunters_mark.down
            if S.HuntersMark:IsReady() and not Target:Debuff(S.HuntersMarkDebuff) then
                return S.HuntersMark:Cast()
            end
            --cds+=/double_tap,if=cooldown.rapid_fire.remains<gcd
            if S.DoubleTap:IsReady() and (S.RapidFire:CooldownRemainsP() < Player:GCD()) then
                return S.DoubleTap:Cast()
            end
            --cds+=/berserking,if=cooldown.trueshot.remains>30
            if S.Berserking:IsReady() and (S.TrueShot:CooldownRemainsP() > 30) then
                return S.Berserking:Cast()
            end
            --cds+=/blood_fury,if=cooldown.trueshot.remains>30
            if S.BloodFury:IsReady() and (S.TrueShot:CooldownRemainsP() > 30) then
                return S.Berserking:Cast()
            end

            --cds+=/ancestral_call,if=cooldown.trueshot.remains>30
            if S.AncestralCall:IsReady() and (S.TrueShot:CooldownRemainsP() > 30) then
                return S.Berserking:Cast()
            end

            --cds+=/fireblood,if=cooldown.trueshot.remains>30
            if S.Fireblood:IsReady() and (S.TrueShot:CooldownRemainsP() > 30) then
                return S.Berserking:Cast()
            end

            --cds+=/lights_judgment
            --cds+=/potion,if=buff.trueshot.react&buff.bloodlust.react|buff.trueshot.react&target.health.pct<20&talent.careful_aim.enabled|target.time_to_die<25
            --cds+=/trueshot,if=(cooldown.aimed_shot.charges<1&!talent.lethal_shots.enabled&!talent.steady_focus.enabled)|buff.bloodlust.react|target.time_to_die>cooldown.trueshot.duration_guess+duration|((target.health.pct<20|!talent.careful_aim.enabled)&(buff.lethal_shots.up|!talent.lethal_shots.enabled))|target.time_to_die<15
            if S.TrueShot:IsReady() and ((S.AimedShot:ChargesP() < 1 and not S.LethalShots:IsAvailable() and not S.SteadyFocus:IsAvailable()) or Player:HasHeroismP() or Target:TimeToDie() >= 20 or ((Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable()) and (Player:BuffP(S.LethalShotsBuff) or not S.LethalShots:IsAvailable())) or Target:TimeToDie() > 15) then
                return S.TrueShot:Cast()
            end
        end

        SingleTarget = function()
            --st=explosive_shot
            if S.ExplosiveShot:IsReady() and (true) then
                return S.ExplosiveShot:Cast()
            end
            --st+=/barrage,if=active_enemies>1
            if S.Barrage:IsReady() and (Cache.EnemiesCount[40] > 1) and RubimRH.AoEON() then
                return S.Barrage:Cast()
            end
            --st+=/arcane_shot,if=buff.precise_shots.up&(cooldown.aimed_shot.full_recharge_time<gcd*buff.precise_shots.stack+action.aimed_shot.cast_time|buff.lethal_shots.up)
            if S.ArcaneShot:IsReady() and (Player:BuffP(S.PreciseShotsBuff) and (S.AimedShot:FullRechargeTime() < Player:GCD() * Player:BuffStackP(S.PreciseShotsBuff) + S.AimedShot:CastTime() or Player:BuffP(S.LethalShotsBuff))) then
                return S.ArcaneShot:Cast()
            end
            --st+=/rapid_fire,if=(!talent.lethal_shots.enabled|buff.lethal_shots.up)&azerite.focused_fire.enabled|azerite.in_the_rhythm.rank>1
            if S.RapidFire:IsReady() and ((not S.LethalShots:IsAvailable() or Player:BuffP(S.LethalShotsBuff)) and S.FocusedFire:AzeriteEnabled() or S.InTheRhythm:AzeriteRank() > 1) then
                return S.RapidFire:Cast()
            end
            --st+=/aimed_shot,if=buff.precise_shots.down&(buff.double_tap.down&full_recharge_time<cast_time+gcd|buff.lethal_shots.up)
            if S.AimedShot:IsReady() and (not Player:BuffP(S.PreciseShotsBuff) and (not Player:BuffP(S.DoubleTapBuff) and S.AimedShot:FullRechargeTime() < S.AimedShot:CastTime() + Player:GCD() or Player:BuffP(S.LethalShotsBuff))) then
                return S.AimedShot:Cast()
            end
            --st+=/rapid_fire,if=!talent.lethal_shots.enabled|buff.lethal_shots.up
            if S.RapidFire:IsReady() and (not S.LethalShots:IsAvailable() or Player:BuffP(S.LethalShotsBuff)) then
                return S.RapidFire:Cast()
            end
            --st+=/piercing_shot
            if S.PiercingShot:IsReady() and (true) then
                return S.PiercingShot:Cast()
            end
            --st+=/a_murder_of_crows
            if S.AMurderofCrows:IsReady() and (true) then
                return S.AMurderofCrows:Cast()
            end
            --st+=/serpent_sting,if=refreshable
            if S.SerpentSting:IsReady() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
                return S.SerpentSting:Cast()
            end
            --st+=/aimed_shot,if=buff.precise_shots.down&(!talent.steady_focus.enabled&focus>70|!talent.lethal_shots.enabled|buff.lethal_shots.up)
            if S.AimedShot:IsReady() and (not Player:BuffP(S.PreciseShotsBuff) and (not S.SteadyFocus:IsAvailable() and Player:Focus() > 70 or not S.LethalShots:IsAvailable() or Player:BuffP(S.LethalShotsBuff))) then
                return S.AimedShot:Cast()
            end
            --st+=/arcane_shot,if=buff.precise_shots.up|focus>60&(!talent.lethal_shots.enabled|buff.lethal_shots.up)
            if S.ArcaneShot:IsReady() and (Player:BuffP(S.PreciseShotsBuff) or Player:Focus() > 60 and (not S.LethalShots:IsAvailable() or Player:BuffP(S.LethalShotsBuff))) then
                return S.ArcaneShot:Cast()
            end
            --st+=/steady_shot,if=focus+cast_regen<focus.max|(talent.lethal_shots.enabled&buff.lethal_shots.down)
            if S.SteadyShot:IsReady() and (Player:Focus() + Player:FocusCastRegen(S.SteadyShot:ExecuteTime()) < Player:FocusMax() or (S.LethalShots:IsAvailable() and not Player:BuffP(S.LethalShotsBuff))) then
                return S.SteadyShot:Cast()
            end
            --st+=/arcane_shot
            if S.ArcaneShot:IsReady() and (true) then
                return S.Arcaneshot:Cast()
            end
        end

        SteadyST = function()
            --steady_st=a_murder_of_crows,if=buff.steady_focus.down|target.time_to_die<16
            if S.AMurderofCrows:IsReady() and (not Player:BuffP(S.SteadyFocusBuff) or Target:TimeToDie() > 16) then
                return S.AMurderofCrows:Cast()
            end
            --steady_st+=/aimed_shot,if=buff.lethal_shots.up|target.time_to_die<3|debuff.steady_aim.stack=5&(buff.lock_and_load.up|full_recharge_time<cast_time)
            if S.AimedShot:IsReady() and (Player:BuffP(S.LethalShots) or Target:TimeToDie() > 3 or Target:DebuffStackP(S.SteadyAimDebuff) == 5 and (Player:BuffP(S.LockandLoad) or S.AimedShot:FullRechargeTime() < S.AimedShot:CastTime())) then
                return S.AimedShot:Cast()
            end
            --steady_st+=/arcane_shot,if=buff.precise_shots.up&(buff.lethal_shots.up|target.health.pct>20&target.health.pct<80)
            if S.ArcaneShot:IsReady() and (Player:BuffP(S.PreciseShotsBuff) and (Player:BuffP(S.LethalShotsBuff) or Target:HealthPercentage() > 20 and Target:HealthPercentage() < 80)) then
                return S.ArcaneShot:Cast()
            end
            --steady_st+=/serpent_sting,if=refreshable
            if S.SerpentSting:IsReady() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
                return S.SerpentSting:Cast()
            end
            --steady_st+=/steady_shot
            if S.SteadyShot:IsReady() and (true) then
                return S.SteadyShot:Cast()
            end
        end

        TrickShots = function()
            --trickshots=barrage
            if S.Barrage:IsReady() and (true) then
                return S.Barrage:Cast()
            end
            --trickshots+=/explosive_shot
            if S.ExplosiveShot:IsReady() and (true) then
                return S.ExplosiveShot:Cast()
            end
            --trickshots+=/rapid_fire,if=buff.trick_shots.up&!talent.barrage.enabled
            if S.RapidFire:IsReady() and (Player:BuffP(S.TrickShotsBuff) and not S.Barrage:IsAvailable()) then
                return S.RapidFire:Cast()
            end
            --trickshots+=/aimed_shot,if=buff.trick_shots.up&buff.precise_shots.down&buff.double_tap.down&(!talent.lethal_shots.enabled|buff.lethal_shots.up|focus>60)
            if S.AimedShot:IsReady() and (Player:BuffP(S.TrickShotsBuff) and not Player:BuffP(S.PreciseShotsBuff) and not Player:BuffP(S.DoubleTapBuff) and (not S.LethalShots:IsAvailable() or Player:BuffP(S.LethalShotsBuff) or Player:Focus() > 60)) then
                return S.AimedShot:Cast()
            end
            --trickshots+=/rapid_fire,if=buff.trick_shots.up
            if S.RapidFire:IsReady() and (Player:BuffP(S.TrickShotsBuff)) then
                return S.RapidFire:Cast()
            end
            --trickshots+=/multishot,if=buff.trick_shots.down|(buff.precise_shots.up|buff.lethal_shots.up)&(!talent.barrage.enabled&buff.steady_focus.down&focus>45|focus>70)
            if S.MultiShot:IsReady() and (not Player:BuffP(S.TrickShotsBuff) or (Player:BuffP(S.PreciseShotsBuff) or Player:BuffP(S.LethalShotsBuff)) and (not S.Barrage:IsAvailable() and not Player:BuffP(S.SteadyFocusBuff) and Player:Focus() > 45 or Player:Focus() > 70)) then
                return S.MultiShot:Cast()
            end
            --trickshots+=/piercing_shot
            if S.PiercingShot:IsReady() and (true) then
                return S.PiercingShot:Cast()
            end
            --trickshots+=/a_murder_of_crows
            if S.AMurderofCrows:IsReady() and (true) then
                return S.AMurderofCrows:Cast()
            end
            --trickshots+=/serpent_sting,if=refreshable
            if S.SerpentSting:IsReady() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
                return S.SerpentSting:Cast()
            end
            --trickshots+=/steady_shot,if=focus+cast_regen<focus.max|(talent.lethal_shots.enabled&buff.lethal_shots.down)
            if S.SteadyShot:IsReady() and (Player:Focus() + Player:FocusCastRegen(S.SteadyShot:ExecuteTime()) < Player:FocusMax() or (S.LethalShots:IsAvailable() and not Player:BuffP(S.LethalShotsBuff))) then
                return S.SteadyShot:Cast()
            end
        end

        --run_action_list,name=steady_st,if=active_enemies<2&talent.lethal_shots.enabled&talent.steady_focus.enabled&azerite.steady_aim.rank>1
        if (((Cache.EnemiesCount[40] < 2) or not RubimRH.AoEON()) and S.LethalShots:IsAvailable() and S.SteadyFocus:IsAvailable() and S.SteadyAim:AzeriteRank() > 1) then
            return SteadyST()
        end
        --run_action_list,name=st,if=active_enemies<3
        if ((Cache.EnemiesCount[40] < 3) or not RubimRH.AoEON()) then
            return SingleTarget()
        end
        --run_action_list,name=trickshots
        if ((Cache.EnemiesCount[40] > 1) and RubimRH.AoEON()) then
            return TrickShots()
        end
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