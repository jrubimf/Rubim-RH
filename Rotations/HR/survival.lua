--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- AethysCore
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;
-- Spells
if not Spell.Hunter then Spell.Hunter = {}; end
Spell.Hunter.Survival = {
    -- Racials
    ArcaneTorrent = Spell(25046),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    GiftoftheNaaru = Spell(59547),
    Shadowmeld = Spell(58984),
    -- Abilities
    AspectoftheEagle = Spell(186289),
    Carve = Spell(187708),
    ExplosiveTrap = Spell(191433),
    ExplosiveTrapDot = Spell(13812),
    FlankingStrike = Spell(202800),
    Harpoon = Spell(190925),
    Lacerate = Spell(185855),
    MongooseBite = Spell(190928),
    MongooseFury = Spell(190931),
    RaptorStrike = Spell(186270),
    -- Talents
    AMurderofCrows = Spell(206505),
    AnimalInstincts = Spell(204315),
    Butchery = Spell(212436),
    Caltrops = Spell(187698),
    CaltropsDebuff = Spell(194279),
    CaltropsTalent = Spell(194277),
    DragonsfireGrenade = Spell(194855),
    MokNathalTactics = Spell(201081),
    SerpentSting = Spell(87935),
    SerpentStingDebuff = Spell(118253),
    SnakeHunter = Spell(201078),
    SpittingCobra = Spell(194407),
    SteelTrap = Spell(187650),
    SteelTrapDebuff = Spell(162487),
    SteelTrapTalent = Spell(162488),
    ThrowingAxes = Spell(200163),
    WayoftheMokNathal = Spell(201082),
    -- Artifact
    FuryoftheEagle = Spell(203415),
    -- Defensive
    AspectoftheTurtle = Spell(186265),
    Exhilaration = Spell(109304),
    -- Utility
    -- Legendaries
    -- Misc
    ExposedFlank = Spell(252094),
    PotionOfProlongedPowerBuff = Spell(229206),
    SephuzBuff = Spell(208052),
    PoolFocus = Spell(9999000010)
    -- Macros
};
local S = Spell.Hunter.Survival;
-- Items
if not Item.Hunter then Item.Hunter = {}; end
Item.Hunter.Survival = {
    -- Legendaries
    FrizzosFinger = Item(137043, { 11, 12 }),
    SephuzSecret = Item(132452, { 11, 12 }),
    -- Trinkets
    ConvergenceofFates = Item(140806, { 13, 14 }),
    -- Potions
    PotionOfProlongedPower = Item(142117)
}
local I = Item.Hunter.Survival;

local function mokTalented()
    return S.WayoftheMokNathal:IsAvailable();
end


local function fillers()
    --actions.fillers=flanking_strike,if=cooldown.mongoose_bite.charges<3
    if S.FlankingStrike:IsCastable() and S.MongooseBite:Charges() < 3 then
        return S.FlankingStrike:ID()
    end

    --actions.fillers+=/spitting_cobra
    if S.SpittingCobra:IsCastable() then
        return S.SpittingCobra:ID()
    end

    --actions.fillers+=/dragonsfire_grenade
    if S.DragonsfireGrenade:IsCastable() then
        return S.DragonsfireGrenade:ID()
    end

    --actions.fillers+=/lacerate,if=refreshable|!ticking
    if S.Lacerate:IsCastable() and (Target:DebuffRefreshable(S.Lacerate, 3.6) or not Target:Debuff(S.Lacerate)) then
        return S.Lacerate:ID()
    end

    --actions.fillers+=/raptor_strike,if=buff.t21_2p_exposed_flank.up&!variable.mokTalented
    if S.RaptorStrike:IsCastable() and Player:BuffP(S.ExposedFlank) and not mokTalented() then
        return S.RaptorStrike:ID()
    end

    --actions.fillers+=/raptor_strike,if=(talent.serpent_sting.enabled&!dot.serpent_sting.ticking)
    if S.RaptorStrike:IsCastable() and (S.SerpentSting:IsAvailable() and not Target:Debuff(S.SerpentStingDebuff)) then
        return S.RaptorStrike:ID()
    end

    --actions.fillers+=/steel_trap,if=refreshable|!ticking
    if IsSpellKnown(S.SteelTrapTalent:ID()) and S.SteelTrap:IsCastable() and S.SteelTrapTalent:CooldownUp() and not S.CaltropsTalent:IsAvailable() and (Target:DebuffRefreshable(S.SteelTrapDebuff, 3.6) or not Target:Debuff(S.SteelTrapTalent)) then
        return S.SteelTrap:ID()
    end

    --actions.fillers+=/caltrops,if=refreshable|!ticking
    if S.Caltrops:IsCastable() and S.CaltropsTalent:CooldownUp() and not S.SteelTrapTalent:IsAvailable() and (Target:DebuffRefreshable(S.CaltropsDebuff, 3.6) or not Target:Debuff(S.CaltropsDebuff)) then
        return S.Caltrops:ID()
    end

    --actions.fillers+=/explosive_trap
    if S.ExplosiveTrap:IsCastable() then
        return S.ExplosiveTrap:ID()
    end

    --actions.fillers+=/butchery,if=variable.frizzosEquipped&dot.lacerate.refreshable&(focus>((50+40)-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
    if S.Butchery:IsCastable() and Player:FocusPredicted(0.2) > 40 and FrizzosEquipped() and Target:DebuffRefreshable(S.Lacerate, 3.6) and (Player:Focus() + 40 > (50 - ((S.FlankingStrike:CooldownRemains() / Player:GCD()) * (Player:FocusRegen() * Player:GCD())))) then
        return S.Butchery:ID()
    end

    --actions.fillers+=/carve,if=variable.frizzosEquipped&dot.lacerate.refreshable&(focus>((50+40)-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
    if S.Carve:IsCastable() and Player:FocusPredicted(0.2) > 40 and FrizzosEquipped() and Target:DebuffRefreshable(S.Lacerate, 3.6) and (Player:Focus() + 40 > (50 - ((S.FlankingStrike:CooldownRemains() / Player:GCD()) * (Player:FocusRegen() * Player:GCD())))) then
        return S.Carve:ID()
    end

    --actions.fillers+=/flanking_strike
    if S.FlankingStrike:IsCastable() then
        return S.FlankingStrike:ID()
    end

    --actions.fillers+=/raptor_strike,if=(variable.mokTalented&buff.moknathal_tactics.remains<gcd*4)|(focus>((75-focus.regen*gcd)))
    if S.RaptorStrike:IsCastable() and (mokTalented() and Player:BuffRemains(S.MokNathalTactics) < Player:GCD() * 4) or (Player:Focus() > (75 - Player:FocusRegen() * Player:GCD())) then
        return S.RaptorStrike:ID()
    end
end

function biteTrigger()
    --actions.biteTrigger=lacerate,if=remains<14&set_bonus.tier20_4pc&cooldown.mongoose_bite.remains<gcd*3
    if S.Lacerate:IsCastable() and Target:DebuffRemainsP(S.Lacerate) < 14 and AC.Tier20_4Pc and S.MongooseBite:CooldownRemains() < Player:GCD() * 3 then
        return S.Lacerate:ID()
    end

    --actions.biteTrigger+=/mongoose_bite,if=charges>=2
    if S.MongooseBite:IsCastable() and S.MongooseBite:Charges() >= 3 then
        return S.MongooseBite:ID()
    end
end

function bitePhase()
    --actions.bitePhase=mongoose_bite,if=cooldown.mongoose_bite.charges=3
    if S.MongooseBite:IsCastable() and S.MongooseBite:Charges() == 3 then
        return S.MongooseBite:ID()
    end

    --actions.bitePhase+=/flanking_strike,if=buff.mongoose_fury.remains>(gcd*(cooldown.mongoose_bite.charges+1))
    if S.FlankingStrike:IsCastable() and Player:BuffRemainsP(S.MongooseFury) > (Player:GCD() *(S.MongooseBite:Charges() + 1)) then
        return S.FlankingStrike:ID()
    end

    --actions.bitePhase+=/mongoose_bite,if=buff.mongoose_fury.up
    if S.MongooseBite:IsCastable() and Player:Buff(S.MongooseFury) then
        return S.MongooseBite:ID()
    end

    --actions.bitePhase+=/fury_of_the_eagle,if=(!variable.mokTalented|(buff.moknathal_tactics.remains>(gcd*(8%3))))&!buff.aspect_of_the_eagle.up,interrupt_immediate=1,interrupt_if=	cooldown.mongoose_bite.charges=3|(ticks_remain<=1&buff.moknathal_tactics.remains<0.7)
    if CDsON() and S.FuryoftheEagle:IsCastable() and (not S.WayoftheMokNathal:IsAvailable() or Player:BuffRemains(S.MokNathalTactics) > (Player:GCD() * (8 / 3))) and Player:BuffStack(S.MongooseFury) == 6 then
        return S.FuryoftheEagle:ID()
    end

    --actions.bitePhase+=/lacerate,if=dot.lacerate.refreshable&(focus>((50+35)-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
    if S.Lacerate:IsCastable() and Player:FocusPredicted(0.2) > 30 and Target:DebuffRefreshable(S.Lacerate, 3.6) and (Player:Focus() + 35 >(45 -((S.FlankingStrike:CooldownRemains() / Player:GCD()) * (Player:FocusRegen() * Player:GCD())))) then
        return S.Lacerate:ID()
    end

    --actions.bitePhase+=/raptor_strike,if=buff.t21_2p_exposed_flank.up
    if S.RaptorStrike:IsCastable() and Player:FocusPredicted(0.2) > 25 and Player:BuffP(S.ExposedFlank) then
        return S.RaptorStrike:ID()
    end

    --actions.bitePhase+=/spitting_cobra
    if S.SpittingCobra:IsCastable() then
        return S.SpittingCobra:ID()
    end

    --actions.bitePhase+=/dragonsfire_grenade
    if S.DragonsfireGrenade:IsCastable() then
        return S.DragonsfireGrenade:ID()
    end

    --actions.bitePhase+=/steel_trap
    if IsSpellKnown(S.SteelTrapTalent:ID()) and S.SteelTrap:IsCastable() and S.SteelTrapTalent:CooldownUp() and not S.CaltropsTalent:IsAvailable() then
        return S.SteelTrap:ID()
    end

    --actions.bitePhase+=/a_murder_of_crows
    if S.AMurderofCrows:IsCastable() then
        return S.AMurderofCrows:ID()
    end

    --actions.bitePhase+=/caltrops,if=!ticking
    if S.Caltrops:IsCastable() and S.CaltropsTalent:CooldownUp() and not Target:Debuff(S.CaltropsDebuff) and not S.SteelTrapTalent:IsAvailable() then
        return S.Caltrops:ID()
    end

    --actions.bitePhase+=/explosive_trap
    if S.ExplosiveTrap:IsCastable() then
        return S.ExplositeTrap:ID()
    end
end

function HunterSurvival()
    -- AoE Check
    AC.GetEnemies(8);
    AC.GetEnemies(5);

    --NO COMBAT
    if not Player:AffectingCombat() then
        return "146250"
    end

    --actions=variable,name=frizzosEquipped,value=(equipped.137043)
    --actions+=/variable,name=mokTalented,value=(talent.way_of_the_moknathal.enabled)
    --actions+=/use_items
    --actions+=/muzzle,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
    --actions+=/auto_attack
    --actions+=/call_action_list,name=mokMaintain,if=variable.mokTalented
    --actions+=/call_action_list,name=CDs
    --actions+=/call_action_list,name=aoe,if=active_enemies>=3
    --actions+=/call_action_list,name=fillers,if=!buff.mongoose_fury.up
    if not Player:BuffP(S.MongooseFury) and fillers() ~= nil then
        return fillers()
    end

    --actions+=/call_action_list,name=biteTrigger,if=!buff.mongoose_fury.up
    if not Player:BuffP(S.MongooseFury) and biteTrigger() ~= nil then
        return biteTrigger()
    end

    --actions+=/call_action_list,name=bitePhase,if=buff.mongoose_fury.up
    if Player:Buff(S.MongooseFury) and bitePhase() ~= nil then
        return bitePhase()
    end


    --actions.CDs=arcane_torrent,if=focus<=30
    --actions.CDs+=/berserking,if=buff.aspect_of_the_eagle.up
    --actions.CDs+=/blood_fury,if=buff.aspect_of_the_eagle.up
    --actions.CDs+=/lights_judgment,if=!buff.aspect_of_the_eagle.up&cooldown.aspect_of_the_eagle.remains<2
    --actions.CDs+=/potion,if=buff.aspect_of_the_eagle.up&(buff.berserking.up|buff.blood_fury.up|!race.troll&!race.orc)
    --actions.CDs+=/snake_hunter,if=cooldown.mongoose_bite.charges=0&buff.mongoose_fury.remains>3*gcd&(cooldown.aspect_of_the_eagle.remains>5&!buff.aspect_of_the_eagle.up)
    --actions.CDs+=/aspect_of_the_eagle,if=buff.mongoose_fury.up&(cooldown.mongoose_bite.charges=0|buff.mongoose_fury.remains<11)

    --actions.aoe=butchery
    --actions.aoe+=/caltrops,if=!ticking
    --actions.aoe+=/explosive_trap
    --actions.aoe+=/carve,if=(talent.serpent_sting.enabled&dot.serpent_sting.refreshable)|(active_enemies>5)

    --actions.mokMaintain=raptor_strike,if=(buff.moknathal_tactics.remains<(gcd)|(buff.moknathal_tactics.stack<3))

    return 233159
end