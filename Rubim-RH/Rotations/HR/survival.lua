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

--Survival
RubimRH.Spell[255] = {
    --Racials
    -- Racials
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    AncestralCall = Spell(274738),
    Fireblood = Spell(265221),
    LightsJudgment = Spell(255647),
    ArcaneTorrent = Spell(80483),
    BerserkingBuff = Spell(26297),
    BloodFuryBuff = Spell(20572),
    -- Abilities
    Harpoon = Spell(190925),
    CoordinatedAssault = Spell(266779),
    KillCommand = Spell(259489),
    CoordinatedAssaultBuff = Spell(266779),
    Carve = Spell(187708),
    SerpentSting = Spell(259491),
    SerpentStingDebuff = Spell(259491),
    RaptorStrikeEagle = Spell(265189),
    RaptorStrike = Spell(186270),
    CounterShot = Spell(147362),
    -- Pet
    CallPet = Spell(883),
    Intimidation = Spell(19577),
    MendPet = Spell(136),
    RevivePet = Spell(982),
    -- Talents
    SteelTrapDebuff = Spell(162487),
    SteelTrap = Spell(162488),
    AMurderofCrows = Spell(131894),
    PheromoneBomb = Spell(270323),
    VolatileBomb = Spell(271045),
    ShrapnelBomb = Spell(270335),
    ShrapnelBombDebuff = Spell(270339),
    WildfireBomb = Spell(259495),
    GuerrillaTactics = Spell(264332),
    WildfireBombDebuff = Spell(269747),
    Chakrams = Spell(259391),
    Butchery = Spell(212436),
    WildfireInfusion = Spell(271014),
    InternalBleedingDebuff = Spell(270343),
    FlankingStrike = Spell(269751),
    VipersVenomBuff = Spell(268552),
    TermsofEngagement = Spell(265895),
    TipoftheSpearBuff = Spell(260286),
    MongooseBiteEagle = Spell(265888),
    MongooseBite = Spell(259387),
    BirdsofPrey = Spell(260331),
    MongooseFuryBuff = Spell(259388),
    VipersVenom = Spell(268501),
    -- Defensive
    AspectoftheTurtle = Spell(186265),
    Exhilaration = Spell(109304),
    -- Utility
    FreezingTrap = Spell(187650),
    AspectoftheEagle = Spell(186289),
    Muzzle = Spell(187707),
    -- PvP
    WingClip = Spell(195645),
    LatentPoison = Spell(273284),
    LatentPoisonDebuff = Spell(273286),
    HydrasBite = Spell(260241),
};

local S = RubimRH.Spell[255]
local VarCarveCdr = 0;

S.MongooseBite.TextureSpellID = { 224795 } -- Raptor Strikes
S.Butchery.TextureSpellID = { 203673 } -- Carve
S.ShrapnelBomb.TextureSpellID = { 269747 }
S.PheromoneBomb.TextureSpellID = { 269747 }
S.VolatileBomb.TextureSpellID = { 269747 }
S.WildfireBomb.TextureSpellID = { 269747 }
S.WingClip.TextureSpellID = { 76151 }

-- Items
if not Item.Hunter then
    Item.Hunter = {}
end
Item.Hunter.Survival = {
    ProlongedPower = Item(142117),
    SephuzsSecret = Item(132452)
};

-- Variables
local VarCanGcd = 0;

local EnemyRanges = { 8, 40, "Melee" }
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

local I = Item.Hunter.Survival;

--- APL Main

local OffensiveCDs = {
    S.Berserking,
    S.BloodFury,
    S.AncestralCall,
    S.Fireblood,
    S.LightsJudgment,
    S.ArcaneTorrent,
    S.CoordinatedAssault,
    S.AspectoftheEagle
}

local function UpdateCDs()
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

local function UpdateWFB()
    if S.ShrapnelBomb:IsReadyMorph() then
        S.WildfireBomb = Spell(270335)
    elseif S.VolatileBomb:IsReadyMorph() then
        S.WildfireBomb = Spell(271045)
    elseif S.PheromoneBomb:IsReadyMorph() then
        S.WildfireBomb = Spell(270323)
    else
        S.WildfireBomb = Spell(259495)
    end
    S.ShrapnelBomb.TextureSpellID = { 269747 }
    S.PheromoneBomb.TextureSpellID = { 269747 }
    S.VolatileBomb.TextureSpellID = { 269747 }
    S.WildfireBomb.TextureSpellID = { 269747 }

end

local function cacheOverwrite()
    Cache.Persistent.SpellLearned.Player[S.MendPet.SpellID] = true
end

--- APL Main
local function APL ()
    cacheOverwrite()
    local Precombat, Cds, Cleave, St, WfiSt
    UpdateRanges()
    UpdateCDs()
    UpdateWFB()

    Precombat = function()
        -- flask
        -- augmentation
        -- food
        -- summon_pet
        if not Pet:IsActive() then
            return S.MendPet:Cast()
        end

        if Pet:IsDeadOrGhost() then
            return S.MendPet:Cast()
        end
        -- snapshot_stats
        -- potion
        -- steel_trap
        if S.SteelTrap:IsReady() and Player:DebuffDownP(S.SteelTrapDebuff) and (true) then
            return S.SteelTrap:Cast()
        end
        -- harpoon
        if S.Harpoon:IsReady() and Target:MinDistanceToPlayer(true) >= 8 then
            return S.Harpoon:Cast()
        end
        return 0, 462338
    end

    Cds = function()
        -- berserking,if=cooldown.coordinated_assault.remains>30
        if S.Berserking:IsReady() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
            return S.Berserking:Cast()
        end
        -- blood_fury,if=cooldown.coordinated_assault.remains>30
        if S.BloodFury:IsReady() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
            return S.BloodFury:Cast()
        end
        -- ancestral_call,if=cooldown.coordinated_assault.remains>30
        if S.AncestralCall:IsReady() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
            return S.AncestralCall:Cast()
        end
        -- fireblood,if=cooldown.coordinated_assault.remains>30
        if S.Fireblood:IsReady() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
            return S.Fireblood:Cast()
        end
        -- lights_judgment
        if S.LightsJudgment:IsReady() and (true) then
            return S.LightsJudgment:Cast()
        end
        -- arcane_torrent,if=cooldown.kill_command.remains>gcd.max&focus<=30
        if S.ArcaneTorrent:IsReady() and (S.KillCommand:CooldownRemainsP() > Player:GCD() and Player:Focus() <= 30) then
            return S.ArcaneTorrent:Cast()
        end
        -- potion,if=buff.coordinated_assault.up&(buff.berserking.up|buff.blood_fury.up|!race.troll&!race.orc)
        -- aspect_of_the_eagle,if=target.distance>=6
        if S.AspectoftheEagle:IsReadyMorph() and Target:MinDistanceToPlayer(true) >= 6 and Target:MinDistanceToPlayer(true) <= 40 then
            return S.AspectoftheEagle:Cast()
        end
    end

    Cleave = function()
        -- variable,name=carve_cdr,op=setif,value=active_enemies,value_else=5,condition=active_enemies<5
        if (Cache.EnemiesCount["Melee"] < 5) then
            VarCarveCdr = Cache.EnemiesCount["Melee"]
        else
            VarCarveCdr = 5
        end
        -- a_murder_of_crows
        if S.AMurderofCrows:IsReady() and (true) then
            return S.AMurderofCrows:Cast()
        end
        -- coordinated_assault
        if S.CoordinatedAssault:IsReady() and (true) then
            return S.CoordinatedAssault:Cast()
        end
        -- carve,if=dot.shrapnel_bomb.ticking
        if S.Carve:IsReady() and (Target:DebuffP(S.ShrapnelBombDebuff)) then
            return S.Carve:Cast()
        end
        -- wildfire_bomb,if=!talent.guerrilla_tactics.enabled|full_recharge_time<gcd
        if S.WildfireBomb:IsReadyMorph() and (not S.GuerrillaTactics:IsAvailable() or S.WildfireBomb:FullRechargeTimeP() < Player:GCD()) then
            return S.WildfireBomb:Cast()
        end
        -- chakrams
        if S.Chakrams:IsReady() and (true) then
            return S.Chakrams:Cast()
        end
        -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max
        if S.KillCommand:IsReady() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax()) then
            return S.KillCommand:Cast()
        end
        -- butchery,if=full_recharge_time<gcd|!talent.wildfire_infusion.enabled|dot.shrapnel_bomb.ticking&dot.internal_bleeding.stack<3
        if S.Butchery:IsReady() and (S.Butchery:FullRechargeTimeP() < Player:GCD() or not S.WildfireInfusion:IsAvailable() or Target:DebuffP(S.ShrapnelBombDebuff) and Target:DebuffStackP(S.InternalBleedingDebuff) < 3) then
            return S.Butchery:Cast()
        end
        -- carve,if=talent.guerrilla_tactics.enabled
        if S.Carve:IsReady() and (S.GuerrillaTactics:IsAvailable()) then
            return S.Carve:Cast()
        end
        -- flanking_strike,if=focus+cast_regen<focus.max
        if S.FlankingStrike:IsReady() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
            return S.FlankingStrike:Cast()
        end
        -- wildfire_bomb,if=dot.wildfire_bomb.refreshable|talent.wildfire_infusion.enabled
        if (S.WildfireBomb:IsReadyMorph() or S.VolatileBomb:IsReadyMorph() or S.ShrapnelBomb:IsReadyMorph() or S.PheromoneBomb:IsReadyMorph()) and (Target:DebuffRefreshableCP(S.WildfireBombDebuff) or S.WildfireInfusion:IsAvailable()) then
            return S.WildfireBomb:Cast()
        end
        -- serpent_sting,target_if=min:remains,if=buff.vipers_venom.up
        if S.SerpentSting:IsReady() and (Player:BuffP(S.VipersVenomBuff)) then
            return S.SerpentSting:Cast()
        end
        -- carve,if=cooldown.wildfire_bomb.remains>variable.carve_cdr%2
        if S.Carve:IsReady() and (S.WildfireBomb:CooldownRemainsP() > VarCarveCdr / 2) then
            return S.Carve:Cast()
        end
        -- steel_trap
        if S.SteelTrap:IsReady() and (true) then
            return S.SteelTrap:Cast()
        end
        -- harpoon,if=talent.terms_of_engagement.enabled
        if S.Harpoon:IsReady() and Target:MinDistanceToPlayer(true) >= 8 and (S.TermsofEngagement:IsAvailable()) then
            return S.Harpoon:Cast()
        end
        -- serpent_sting,target_if=min:remains,if=refreshable&buff.tip_of_the_spear.stack<3
        if S.SerpentSting:IsReady() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and Player:BuffStackP(S.TipoftheSpearBuff) < 3) then
            return S.SerpentSting:Cast()
        end
        -- mongoose_bite_eagle
        if S.MongooseBiteEagle:IsReadyMorph() and Player:Buff(S.AspectoftheEagle) then
            return S.MongooseBiteEagle:Cast()
        end
        -- mongoose_bite
        if S.MongooseBite:IsReady() and (true) then
            return S.MongooseBite:Cast()
        end
        -- raptor_strike_eagle
        if S.RaptorStrikeEagle:IsReadyMorph() and Player:Buff(S.AspectoftheEagle) then
            return S.RaptorStrike:Cast()
        end
        -- raptor_strike
        if S.RaptorStrike:IsReady() and (true) then
            return S.RaptorStrike:Cast()
        end
    end
    St = function()
        -- a_murder_of_crows
        if S.AMurderofCrows:IsReady() and (true) then
            return S.AMurderofCrows:Cast()
        end
        -- coordinated_assault
        if S.CoordinatedAssault:IsReady() and (true) then
            return S.CoordinatedAssault:Cast()
        end
        -- raptor_strike_eagle,if=talent.birds_of_prey.enabled&buff.coordinated_assault.up&buff.coordinated_assault.remains<gcd
        if S.RaptorStrikeEagle:IsReadyMorph() and (S.BirdsofPrey:IsAvailable() and Player:BuffP(S.CoordinatedAssaultBuff) and Player:BuffRemainsP(S.CoordinatedAssaultBuff) < Player:GCD()) then
            return S.RaptorStrike:Cast()
        end
        -- raptor_strike,if=talent.birds_of_prey.enabled&buff.coordinated_assault.up&buff.coordinated_assault.remains<gcd
        if S.RaptorStrike:IsReady() and (S.BirdsofPrey:IsAvailable() and Player:BuffP(S.CoordinatedAssaultBuff) and Player:BuffRemainsP(S.CoordinatedAssaultBuff) < Player:GCD()) then
            return S.RaptorStrike:Cast()
        end
        -- mongoose_bite_eagle,if=talent.birds_of_prey.enabled&buff.coordinated_assault.up&buff.coordinated_assault.remains<gcd
        if S.MongooseBiteEagle:IsReadyMorph() and (S.BirdsofPrey:IsAvailable() and Player:BuffP(S.CoordinatedAssaultBuff) and Player:BuffRemainsP(S.CoordinatedAssaultBuff) < Player:GCD()) then
            return S.MongooseBite:Cast()
        end
        -- mongoose_bite,if=talent.birds_of_prey.enabled&buff.coordinated_assault.up&buff.coordinated_assault.remains<gcd
        if S.MongooseBite:IsReady() and (S.BirdsofPrey:IsAvailable() and Player:BuffP(S.CoordinatedAssaultBuff) and Player:BuffRemainsP(S.CoordinatedAssaultBuff) < Player:GCD()) then
            return S.MongooseBite:Cast()
        end
        -- kill_command,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3
        if S.KillCommand:IsReady() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and Player:BuffStackP(S.TipoftheSpearBuff) < 3) then
            return S.KillCommand:Cast()
        end
        -- chakrams
        if S.Chakrams:IsReady() and (true) then
            return S.Chakrams:Cast()
        end
        -- steel_trap
        if S.SteelTrap:IsReady() and (true) then
            return S.SteelTrap:Cast()
        end
        -- wildfire_bomb,if=focus+cast_regen<focus.max&(full_recharge_time<gcd|dot.wildfire_bomb.refreshable&buff.mongoose_fury.down)
        if S.WildfireBomb:IsReadyMorph() and (Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() and (S.WildfireBomb:FullRechargeTimeP() < Player:GCD() or Target:DebuffRefreshableCP(S.WildfireBombDebuff) and Player:BuffDownP(S.MongooseFuryBuff))) then
            return S.WildfireBomb:Cast()
        end
        -- harpoon,if=talent.terms_of_engagement.enabled
        if S.Harpoon:IsReady() and Target:MinDistanceToPlayer(true) >= 8 and (S.TermsofEngagement:IsAvailable()) then
            return S.Harpoon:Cast()
        end
        -- flanking_strike,if=focus+cast_regen<focus.max
        if S.FlankingStrike:IsReady() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
            return S.FlankingStrike:Cast()
        end
        -- serpent_sting,if=buff.vipers_venom.up|refreshable&(!talent.mongoose_bite.enabled&focus<90|!talent.vipers_venom.enabled)
        if S.SerpentSting:IsReady() and (Player:BuffP(S.VipersVenomBuff) or Target:DebuffRefreshableCP(S.SerpentStingDebuff) and (not S.MongooseBite:IsAvailable() and Player:Focus() < 90 or not S.VipersVenom:IsAvailable())) then
            return S.SerpentSting:Cast()
        end
        -- mongoose_bite_eagle,if=buff.mongoose_fury.up|focus>60
        if S.MongooseBiteEagle:IsReadyMorph() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60) then
            return S.MongooseBite:Cast()
        end
        -- mongoose_bite,if=buff.mongoose_fury.up|focus>60
        if S.MongooseBite:IsReady() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60) then
            return S.MongooseBite:Cast()
        end
        -- raptor_strike_eagle
        if S.RaptorStrikeEagle:IsReadyMorph() and (true) then
            return S.RaptorStrikeEagle:Cast()
        end
        -- raptor_strike
        if S.RaptorStrike:IsReady() and (true) then
            return S.RaptorStrike:Cast()
        end
        -- wildfire_bomb,if=dot.wildfire_bomb.refreshable
        if S.WildfireBomb:IsReadyMorph() and (Target:DebuffRefreshableCP(S.WildfireBombDebuff)) then
            return S.WildfireBomb:Cast()
        end
        -- serpent_sting,if=refreshable
        if S.SerpentSting:IsReady() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
            return S.SerpentSting:Cast()
        end
    end
    WfiSt = function()
        -- a_murder_of_crows
        if S.AMurderofCrows:IsReady() and (true) then
            return S.AMurderofCrows:Cast()
        end
        -- coordinated_assault
        if S.CoordinatedAssault:IsReady() and (true) then
            return S.CoordinatedAssault:Cast()
        end
        -- kill_command,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3
        if S.KillCommand:IsReady() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and Player:BuffStackP(S.TipoftheSpearBuff) < 3) then
            return S.KillCommand:Cast()
        end
        -- raptor_strike,if=dot.internal_bleeding.stack<3&dot.shrapnel_bomb.ticking&!talent.mongoose_bite.enabled
        if S.RaptorStrike:IsReady() and (Target:DebuffStackP(S.InternalBleedingDebuff) < 3 and Target:DebuffP(S.ShrapnelBombDebuff) and not S.MongooseBite:IsAvailable()) then
            return S.RaptorStrike:Cast()
        end
        -- wildfire_bomb,if=full_recharge_time<gcd|(focus+cast_regen<focus.max)&(next_wi_bomb.volatile&dot.serpent_sting.ticking&dot.serpent_sting.refreshable|next_wi_bomb.pheromone&focus+cast_regen<focus.max-action.kill_command.cast_regen*3)
        if (S.WildfireBomb:FullRechargeTimeP() < Player:GCD() or (Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax()) and ((S.VolatileBomb:IsReadyMorph() and Target:DebuffP(S.SerpentStingDebuff) and Target:DebuffRefreshableCP(S.SerpentStingDebuff)) or (S.PheromoneBomb:IsReadyMorph() and Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() - Player:FocusCastRegen(S.KillCommand:ExecuteTime()) * 3))) then
            return S.WildfireBomb:Cast()
        end
        -- wildfire_bomb,if=next_wi_bomb.shrapnel&buff.mongoose_fury.down&(cooldown.kill_command.remains>gcd|focus>60)
        if (S.ShrapnelBomb:IsReadyMorph() and Player:BuffDownP(S.MongooseFuryBuff) and (S.KillCommand:CooldownRemainsP() > Player:GCD() or Player:Focus() > 60)) then
            return S.WildfireBomb:Cast()
        end
        -- steel_trap
        if S.SteelTrap:IsReady() and (true) then
            return S.SteelTrap:Cast()
        end
        -- flanking_strike,if=focus+cast_regen<focus.max
        if S.FlankingStrike:IsReady() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
            return S.FlankingStrike:Cast()
        end
        -- serpent_sting,if=buff.vipers_venom.up|refreshable&(!talent.mongoose_bite.enabled|next_wi_bomb.volatile&!dot.shrapnel_bomb.ticking)
        if S.SerpentSting:IsReady() and (Player:BuffP(S.VipersVenomBuff) or Target:DebuffRefreshableCP(S.SerpentStingDebuff) and (not S.MongooseBite:IsAvailable() or S.VolatileBomb:IsReadyMorph() and not Target:DebuffP(S.ShrapnelBombDebuff))) then
            return S.SerpentSting:Cast()
        end
        -- harpoon,if=talent.terms_of_engagement.enabled
        if S.Harpoon:IsReady() and Target:MinDistanceToPlayer(true) >= 8 and (S.TermsofEngagement:IsAvailable()) then
            return S.Harpoon:Cast()
        end
        -- mongoose_bite_eagle,if=buff.mongoose_fury.up|focus>60|dot.shrapnel_bomb.ticking
        if S.MongooseBiteEagle:IsReadyMorph() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60 or Target:DebuffP(S.ShrapnelBombDebuff)) then
            return S.MongooseBiteEagle:Cast()
        end
        -- mongoose_bite,if=buff.mongoose_fury.up|focus>60|dot.shrapnel_bomb.ticking
        if S.MongooseBite:IsReady() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60 or Target:DebuffP(S.ShrapnelBombDebuff)) then
            return S.MongooseBite:Cast()
        end
        -- raptor_strike_eagle
        if S.RaptorStrikeEagle:IsReadyMorph() and (true) then
            return S.RaptorStrikeEagle:Cast()
        end
        -- raptor_strike
        if S.RaptorStrike:IsReady() and (true) then
            return S.RaptorStrike:Cast()
        end
        -- serpent_sting,if=refreshable
        if S.SerpentSting:IsReady() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
            return S.SerpentSting:Cast()
        end
        -- wildfire_bomb,if=next_wi_bomb.volatile&dot.serpent_sting.ticking|next_wi_bomb.pheromone|next_wi_bomb.shrapnel&focus>50
        if (S.VolatileBomb:IsReadyMorph() and Target:DebuffP(S.SerpentStingDebuff) or S.PheromoneBomb:IsReadyMorph() or S.ShrapnelBomb:IsReadyMorph() and Player:Focus() > 50) then
            return S.WildfireBomb:Cast()
        end
    end

    -- call precombat
    if not Player:AffectingCombat() then
        return Precombat()
    end
	
    -- countershot in combat
	if S.CounterShot:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.CounterShot:Cast()
    end

    if QueueSkill() ~= nil then
        return QueueSkill()
    end

    if S.MendPet:IsCastable() and Pet:IsActive() and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= RubimRH.db.profile[255].sk1 and not Pet:Buff(S.MendPet) then
        return S.MendPet:Cast()
    end

    if Pet:IsDeadOrGhost() then
        return S.MendPet:Cast()
    end

    if S.Muzzle:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Muzzle:Cast()
    end

    -- auto_attack
    -- use_items
    -- call_action_list,name=cds
    if Cds() ~= nil then
        return Cds()
    end
    -- call_action_list,name=wfi_st,if=active_enemies<2&talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[8] < 2 and S.WildfireInfusion:IsAvailable()) then
        if WfiSt() ~= nil then
            return WfiSt()
        end
    end
    -- call_action_list,name=st,if=active_enemies<2&!talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[8] < 2 and not S.WildfireInfusion:IsAvailable()) then
        if St() ~= nil then
            return St()
        end
    end
    -- call_action_list,name=cleave,if=active_enemies>1
    if (Cache.EnemiesCount[8] > 1) then
        if Cleave() ~= nil then
            return Cleave()
        end
    end

    return 0, 135328
end

RubimRH.Rotation.SetAPL(255, APL);

local function PASSIVE()

    if S.AspectoftheTurtle:IsCastable() and Player:HealthPercentage() <= RubimRH.db.profile[255].sk2 then
        return S.AspectoftheTurtle:Cast()
    end

    if S.Exhilaration:IsCastable() and Player:HealthPercentage() <= RubimRH.db.profile[255].sk3 then
        return S.Exhilaration:Cast()
    end

    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(255, PASSIVE);
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
-- actions+=/multishot,if=spell_targets>2&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
-- actions+=/chimaera_shot
-- actions+=/kill_command
-- actions+=/dire_beast
-- actions+=/barbed_shot,if=pet.cat.buff.frenzy.down&charges_fractional>1.4|full_recharge_time<gcd.max|target.time_to_die<9
-- actions+=/barrage
-- actions+=/multishot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
-- actions+=/cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(buff.bestial_wrath.up&active_enemies>1|cooldown.kill_command.remains>1+gcd&cooldown.bestial_wrath.remains>focus.time_to_max|focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost)