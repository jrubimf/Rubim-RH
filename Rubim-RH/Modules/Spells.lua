---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rubim.
--- DateTime: 23/07/2018 19:21
---
-- HeroLib
local HL = HeroLib;
local Spell = HL.Spell;
local Item = HL.Item;


--20594 DWARF
--20549 TAUREN
--28730 ARCANE TORRENT
--68992 DARK FLIGHT
--58984 SHADOWMELD

----WARRIOR
--FURY
RubimRH.Spell[72] = {
    -- Racials
    ArcaneTorrent = Spell(80483),
    AncestralCall = Spell(274738),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Fireblood = Spell(265221),
    GiftoftheNaaru = Spell(59547),
    LightsJudgment = Spell(255647),
    -- Abilities
    BattleShout = Spell(6673),
    BerserkerRage = Spell(18499),
    Bloodthirst = Spell(23881),
    Charge = Spell(100),
    Execute = Spell(5308),
    ExecuteMassacre = Spell(280735),
    HeroicLeap = Spell(6544),
    HeroicThrow = Spell(57755),
    RagingBlow = Spell(85288),
    Rampage = Spell(184367),
    Recklessness = Spell(1719),
    VictoryRush = Spell(34428),
    Whirlwind = Spell(190411),
    WhirlwindBuff = Spell(85739),
    Enrage = Spell(184362),
    -- Talents
    WarMachine = Spell(262231),
    EndlessRage = Spell(202296),
    FreshMeat = Spell(215568),
    DoubleTime = Spell(103827),
    ImpendingVictory = Spell(202168),
    StormBolt = Spell(107570),
    InnerRage = Spell(215573),
    FuriousSlash = Spell(100130),
    FuriousSlashBuff = Spell(202539),
    Carnage = Spell(202922),
    Massacre = Spell(206315),
    FrothingBerserker = Spell(215571),
    MeatCleaver = Spell(280392),
    DragonRoar = Spell(118000),
    Bladestorm = Spell(46924),
    RecklessAbandon = Spell(202751),
    AngerManagement = Spell(152278),
    Siegebreaker = Spell(280772),
    SiegebreakerDebuff = Spell(280773),
    SuddenDeath = Spell(280721),
    SuddenDeathBuff = Spell(280776),
    SuddenDeathBuffLeg = Spell(225947),
    -- Defensive
    -- Utility
    Pummel = Spell(6552),
    -- Legendaries
    FujiedasFury = Spell(207776),
    StoneHeart = Spell(225947),
    -- Misc
    UmbralMoonglaives = Spell(242553),
}
--ARMS
RubimRH.Spell[71] = {
    -- Racials
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    ArcaneTorrent = Spell(28730),

    -- Abilities
    BattleCry = Spell(1719),
    BattleCryBuff = Spell(1719),
    ColossusSmash = Spell(167105),
    ColossusSmashDebuff = Spell(208086),
    Execute = Spell(163201),
    ExecutionersPrecisionDebuff = Spell(242188),
    Cleave = Spell(845),
    CleaveBuff = Spell(231833),
    Charge = Spell(100),
    Bladestorm = Spell(227847),
    MortalStrike = Spell(12294),
    Whirlwind = Spell(1680),
    HeroicThrow = Spell(57755),
    Slam = Spell(1464),

    -- Talents
    Dauntless = Spell(202297),
    Avatar = Spell(107574),
    AvatarBuff = Spell(107574),
    FocusedRage = Spell(207982),
    FocusedRageBuff = Spell(207982),
    Rend = Spell(772),
    RendDebuff = Spell(772),
    Overpower = Spell(7384),
    Ravager = Spell(152277),
    StormBolt = Spell(107570),
    DeadlyCalm = Spell(227266),
    FervorOfBattle = Spell(202316),
    SweepingStrikes = Spell(202161),
    AngerManagement = Spell(152278),
    InForTheKill = Spell(248621),
    InForTheKillBuff = Spell(248622),
    -- Talents
    SkullSplinter = Spell(260643),
    Warbreaker = Spell(262161),

    -- Defensive
    CommandingShout = Spell(97462),
    DefensiveStance = Spell(197690),
    DiebytheSword = Spell(118038),
    Victorious = Spell(32216),
    VictoryRush = Spell(34428),

    -- Utility
    Pummel = Spell(6552),
    Shockwave = Spell(46968),
    ShatteredDefensesBuff = Spell(248625),
    PreciseStrikesBuff = Spell(209492),

    -- Legendaries
    StoneHeartBuff = Spell(225947),

    -- Misc
    WeightedBlade = Spell(253383)
}
--PROT
RubimRH.Spell[73] = {
ArcaneTorrent = Spell(69179),
Berserking = Spell(26297),
BloodFury = Spell(20572),
Shadowmeld = Spell(58984),
    -- Abilities
    BerserkerRage = Spell(18499),
    Charge = Spell(100), -- Unused
    DemoralizingShout = Spell(1160),
    Devastate = Spell(20243),
    HeroicLeap = Spell(6544), -- Unused
    HeroicThrow = Spell(57755), -- Unused
    Revenge = Spell(6572),
    RevengeBuff = Spell(5302),
    ShieldSlam = Spell(23922),
    ThunderClap = Spell(6343),
    VictoryRush = Spell(34428),
    Victorious = Spell(32216),
    LastStand = Spell(12975),
    Avatar = Spell(107574),
    BattleShout = Spell(6673),
    -- Talents
    BoomingVoice = Spell(202743),
    ImpendingVictory = Spell(202168),
    Shockwave = Spell(46968),
    CracklingThunder = Spell(203201),
    Vengeance = Spell(202572),
    VegeanceIP = Spell(202574),
    VegeanceRV = Spell(202573),
    UnstoppableForce = Spell(275336),
    Ravager = Spell(228920),
    Bolster = Spell(280001),
    -- PVP Talents
    ShieldBash = Spell(198912),
    -- Defensive
    IgnorePain = Spell(190456),
    Pummel = Spell(6552),
    ShieldBlock = Spell(2565),
    ShieldBlockBuff = Spell(132404),
    ShieldWall = Spell(871)
}


----MONK
--Brewing
RubimRH.Spell[268] = {
    -- Spells
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BlackoutCombo = Spell(196736),
    BlackoutComboBuff = Spell(228563),
    BlackoutStrike = Spell(205523),
    BlackOxBrew = Spell(115399),
    BloodFury = Spell(20572),
    BreathOfFire = Spell(115181),
    BreathofFireDotDebuff = Spell(123725),
    Brews = Spell(115308),
    ChiBurst = Spell(123986),
    ChiWave = Spell(115098),
    DampenHarm = Spell(122278),
    DampenHarmBuff = Spell(122278),
    ExplodingKeg = Spell(214326),
    FortifyingBrew = Spell(115203),
    FortifyingBrewBuff = Spell(115203),
    InvokeNiuzaotheBlackOx = Spell(132578),
    IronskinBrew = Spell(115308),
    IronskinBrewBuff = Spell(215479),
    KegSmash = Spell(121253),
    LightBrewing = Spell(196721),
    PotentKick = Spell(213047),
    PurifyingBrew = Spell(119582),
    RushingJadeWind = Spell(116847),
    TigerPalm = Spell(100780),
    HeavyStagger = Spell(124273),
    ModerateStagger = Spell(124274),
    LightStagger = Spell(124275),
    SpearHandStrike = Spell(116705),
    ModerateStagger = Spell(124274),
    HeavyStagger = Spell(124273),
    HealingElixir = Spell(122281),
    BlackOxStatue = Spell(115315),
    Guard = Spell(202162),
    LegSweep = Spell(119381)
}

----SHAMMY
--ELE
RubimRH.Spell[262] = {
    -- Racials
    Berserking = Spell(26297),
    BloodFury = Spell(33697),

    -- Abilities
    FlameShock = Spell(188389),
    FlameShockDebuff = Spell(188389),
    BloodLust = Spell(2825),
    BloodLustBuff = Spell(2825),

    TotemMastery = Spell(210643),
    EmberTotemBuff = Spell(210658),
    TailwindTotemBuff = Spell(210659),
    ResonanceTotemBuff = Spell(202192),
    StormTotemBuff = Spell(210652),

    HealingSurge = Spell(188070),

    EarthShock = Spell(8042),
    LavaBurst = Spell(51505),
    FireElemental = Spell(198067),
    EarthElemental = Spell(198103),
    LightningBolt = Spell(188196),
    LavaBeam = Spell(114074),
    EarthQuake = Spell(61882),
    LavaSurgeBuff = Spell(77762),
    ChainLightning = Spell(188443),
    ElementalFocusBuff = Spell(16246),
    FrostShock = Spell(196840),

    -- Talents
    ElementalMastery = Spell(16166),
    ElementalMasteryBuff = Spell(16166),
    Ascendance = Spell(114050),
    AscendanceBuff = Spell(114050),
    LightningRod = Spell(210689),
    LightningRodDebuff = Spell(197209),
    LiquidMagmaTotem = Spell(192222),
    ElementalBlast = Spell(117014),
    Aftershock = Spell(210707),
    Icefury = Spell(210714),
    IcefuryBuff = Spell(210714),

    -- Artifact
    Stormkeeper = Spell(205495),
    StormkeeperBuff = Spell(205495),
    SwellingMaelstrom = Spell(238105),
    PowerOfTheMaelstrom = Spell(191861),
    PowerOfTheMaelstromBuff = Spell(191861),

    -- Tier bonus
    EarthenStrengthBuff = Spell(252141),

    -- Utility
    WindShear = Spell(57994),
}
-- Enhancement
RubimRH.Spell[263] = {
    -- Racials
    BloodFury = Spell(336970),
    Berserking = Spell(26297),
    -- Abilities
    WindShear = Spell(57994),
    AncestralSpirit = Spell(2008),
    CrashLightning = Spell(187874),
    EarthElemental = Spell(198103),
    AstralShift = Spell(108271),
    EarthbindTotem = Spell(2484),
    Bloodlust = Spell(2825),
    CapacitorTotem = Spell(192058),
    FeralSpirit = Spell(51533),
    CleanseSpirit = Spell(51886),
    Flametongue = Spell(193796),
    Frostbrand = Spell(196834),
    Purge = Spell(370),
    GhostWolf = Spell(2645),
    Rockbiter = Spell(193786),
    HealingSurge = Spell(188070),
    SpiritWalk = Spell(58875),
    Hex = Spell(51514),
    Stormstrike = Spell(17364),
    LavaLash = Spell(60103),
    TremorTotem = Spell(8143),
    LightningBolt = Spell(187837),
    -- Talents
    LightningShield = Spell(192106),
    HotHand = Spell(201900),
    BoulderFist = Spell(246035),
    Landslide = Spell(197992),
    ForcefulWinds = Spell(262647),
    TotemMastery = Spell(262395),
    SpiritWolf = Spell(260878),
    EarthShield = Spell(974),
    StaticCharge = Spell(265046),
    SearingAssault = Spell(192087),
    Hailstorm = Spell(210853),
    Overcharge = Spell(210727),
    NaturesGuardian = Spell(30884),
    FeralLunge = Spell(196884),
    WindRushTotem = Spell(192077),
    CrashingStorm = Spell(192246),
    FuryOfAir = Spell(197211),
    Sundering = Spell(197214),
    ElementalSpirits = Spell(262624),
    EarthenSpike = Spell(188089),
    Ascendance = Spell(114051),
    TotemMastery = Spell(262395),
    -- Passives // Buffs
    GatheringStorms = Spell(198300),
    Stormbringer = Spell(201845),
    ResonanceTotemBuff = Spell(262417),
    LandslideBuff = Spell(202004),
    -- Morphed Spells
    Windstrike = Spell(115356)
}

----ROGUE
--ASS
RubimRH.Spell[259] = {
    -- Racials
    ArcaneTorrent = Spell(25046),
    Berserking = Spell(26297),
    Blindside = Spell(22339),
    BloodFury = Spell(20572),
    GiftoftheNaaru = Spell(59547),
    -- Abilities
    Envenom = Spell(32645),
    FanofKnives = Spell(51723),
    Garrote = Spell(703),
    KidneyShot = Spell(408),
    Mutilate = Spell(1329),
    PoisonedKnife = Spell(185565),
    Rupture = Spell(1943),
    Stealth = Spell(1784),
    Stealth2 = Spell(115191), -- w/ Subterfuge Talent
    Vanish = Spell(1856),
    VanishBuff = Spell(11327),
    Vendetta = Spell(79140),
    -- Talents
    Alacrity = Spell(193539),
    AlacrityBuff = Spell(193538),
    Anticipation = Spell(114015),
    CrimsonTempest = Spell(23174),
    DeathfromAbove = Spell(152150),
    DeeperStratagem = Spell(193531),
    ElaboratePlanning = Spell(193640),
    ElaboratePlanningBuff = Spell(193641),
    Exsanguinate = Spell(200806),
    HiddenBlades = Spell(22133),
    Hemorrhage = Spell(16511),
    InternalBleeding = Spell(154953),
    MarkedforDeath = Spell(137619),
    MasterPoisoner = Spell(196864),
    Nightstalker = Spell(14062),
    ShadowFocus = Spell(108209),
    Subterfuge = Spell(108208),
    ToxicBlade = Spell(245388),
    ToxicBladeDebuff = Spell(245389),
    VenomRush = Spell(152152),
    Vigor = Spell(14983),
    -- Artifact
    AssassinsBlades = Spell(214368),
    Kingsbane = Spell(192759),
    MasterAssassin = Spell(192349),
    PoisonKnives = Spell(192376),
    SilenceoftheUncrowned = Spell(241152),
    SinisterCirculation = Spell(238138),
    SlayersPrecision = Spell(214928),
    SurgeofToxins = Spell(192425),
    ToxicBlades = Spell(192310),
    UrgetoKill = Spell(192384),
    -- Defensive
    CrimsonVial = Spell(185311),
    Feint = Spell(1966),
    -- Utility
    Blind = Spell(2094),
    Kick = Spell(1766),
    PickPocket = Spell(921),
    Sprint = Spell(2983),
    -- Poisons
    CripplingPoison = Spell(3408),
    DeadlyPoison = Spell(2823),
    DeadlyPoisonDebuff = Spell(2818),
    LeechingPoison = Spell(108211),
    WoundPoison = Spell(8679),
    WoundPoisonDebuff = Spell(8680),
    -- Legendaries
    DreadlordsDeceit = Spell(228224),
    -- Tier
    MutilatedFlesh = Spell(211672),
    VirulentPoisons = Spell(252277),
}
--SUB
RubimRH.Spell[261] = {
    -- Racials
    ArcanePulse = Spell(260364),
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Shadowmeld = Spell(58984),
    -- Abilities
    Backstab = Spell(53),
    Eviscerate = Spell(196819),
    Nightblade = Spell(195452),
    ShadowBlades = Spell(121471),
    ShurikenComboBuff = Spell(245640),
    ShadowDance = Spell(185313),
    ShadowDanceBuff = Spell(185422),
    Shadowstrike = Spell(185438),
    ShurikenStorm = Spell(197835),
    ShurikenToss = Spell(114014),
    Stealth = Spell(1784),
    Stealth2 = Spell(115191), -- w/ Subterfuge Talent
    SymbolsofDeath = Spell(212283),
    Vanish = Spell(1856),
    VanishBuff = Spell(11327),
    VanishBuff2 = Spell(115193), -- w/ Subterfuge Talent
    -- Talents
    Alacrity = Spell(193539),
    DarkShadow = Spell(245687),
    DeeperStratagem = Spell(193531),
    EnvelopingShadows = Spell(238104),
    FindWeaknessDebuff = Spell(91021),
    Gloomblade = Spell(200758),
    MarkedforDeath = Spell(137619),
    MasterofShadows = Spell(196976),
    Nightstalker = Spell(14062),
    SecretTechnique = Spell(280719),
    ShadowFocus = Spell(108209),
    ShurikenTornado = Spell(277925),
    Subterfuge = Spell(108208),
    Vigor = Spell(14983),
    -- Azerite Traits
    SharpenedBladesBuff = Spell(272916),
    -- Defensive
    CrimsonVial = Spell(185311),
    Feint = Spell(1966),
    -- Utility
    Blind = Spell(2094),
    CheapShot = Spell(1833),
    Kick = Spell(1766),
    KidneyShot = Spell(408),
    Sprint = Spell(2983),
    -- Misc
}
--Outlaw
RubimRH.Spell[260] = {
    -- Racials
    ArcanePulse                     = Spell(260364),
    ArcaneTorrent                   = Spell(25046),
    Berserking                      = Spell(26297),
    BloodFury                       = Spell(20572),
    LightsJudgment                  = Spell(255647),
    Shadowmeld                      = Spell(58984),
    -- Abilities
    AdrenalineRush                  = Spell(13750),
    Ambush                          = Spell(8676),
    BetweentheEyes                  = Spell(199804),
    BladeFlurry                     = Spell(13877),
    Opportunity                     = Spell(195627),
    PistolShot                      = Spell(185763),
    RolltheBones                    = Spell(193316),
    Dispatch                        = Spell(2098),
    SaberSlash                      = Spell(193315),
    Stealth                         = Spell(1784),
    Vanish                          = Spell(1856),
    VanishBuff                      = Spell(11327),
    -- Talents
    BladeRush                       = Spell(271877),
    DeeperStratagem                 = Spell(193531),
    GhostlyStrike                   = Spell(196937),
    KillingSpree                    = Spell(51690),
    LoadedDiceBuff                  = Spell(256171),
    MarkedforDeath                  = Spell(137619),
    QuickDraw                       = Spell(196938),
    SliceandDice                    = Spell(5171),
    -- Defensive
    CrimsonVial                     = Spell(185311),
    Feint                           = Spell(1966),
    -- Utility
    Kick                            = Spell(1766),
    -- Roll the Bones
    Broadside                       = Spell(193356),
    BuriedTreasure                  = Spell(199600),
    GrandMelee                      = Spell(193358),
    RuthlessPrecision               = Spell(193357),
    SkullandCrossbones              = Spell(199603),
    TrueBearing                     = Spell(193359)
    };

----PALADIN
--Protection
RubimRH.Spell[66] = {
    -- Racials
    ArcaneTorrent = Spell(155145),
    -- Primary rotation abilities
    AvengersShield = Spell(31935),
    AvengersValor = Spell(197561),
    AvengingWrath = Spell(31884),
    Consecration = Spell(26573),
    HammerOfTheRighteous = Spell(53595),
    Judgment = Spell(275779),
    ShieldOfTheRighteous = Spell(53600),
    ShieldOfTheRighteousBuff = Spell(132403),
    GrandCrusader = Spell(85043),
    -- Talents
    BlessedHammer = Spell(204019),
    ConsecratedHammer = Spell(203785),
    CrusadersJudgment = Spell(204023),
    Seraphim = Spell(152262),
    -- Defensive / Utility
    LightOfTheProtector = Spell(184092),
    HandOfTheProtector = Spell(213652),
    LayOnHands = Spell(633),
    GuardianOfAncientKings = Spell(86659),
    ArdentDefender = Spell(31850),
    BlessingOfFreedom = Spell(1044),
    HammerOfJustice = Spell(853),
    BlessingOfProtection = Spell(1022),
    BlessingOfSacrifice = Spell(6940),
    DivineShield = Spell(642),
    -- Utility
    Rebuke = Spell(96231)
}
--Retribution
RubimRH.Spell[70] = {
    -- Racials
    ArcaneTorrent = Spell(25046),
    GiftoftheNaaru = Spell(59547),
    -- Abilities
    BladeofJustice = Spell(184575),
    Consecration = Spell(205228),
    CrusaderStrike = Spell(35395),
    DivineHammer = Spell(198034),
    DivinePurpose = Spell(223817),
    DivinePurposeBuff = Spell(223819),
    DivineStorm = Spell(53385),
    ExecutionSentence = Spell(267798),
    GreaterJudgment = Spell(218718),
    HolyWrath = Spell(210220),
    Judgment = Spell(20271),
    JudgmentDebuff = Spell(197277),
    JusticarsVengeance = Spell(215661),
    TemplarsVerdict = Spell(85256),
    TheFiresofJustice = Spell(203316),
    TheFiresofJusticeBuff = Spell(209785),
    Zeal = Spell(217020),
    FinalVerdict = Spell(198038),
    -- Offensive
    AvengingWrath = Spell(31884),
    Crusade = Spell(231895),
    --Talent
    Inquisition = Spell(84963),
    DivineJudgement = Spell(271580),
    HammerofWrath = Spell(24275),
    WakeofAshes = Spell(255937),

    -- Defensive
    -- Utility
    HammerofJustice = Spell(853),
    Rebuke = Spell(96231),
    DivineSteed = Spell(190784),
    WorldofGlory = Spell(210191),
    FlashOfLight = Spell(19750),
    SelfLessHealerBuff = Spell (114250),
    -- Legendaries
    LiadrinsFuryUnleashed = Spell(208408),
    ScarletInquisitorsExpurgation = Spell(248289),
    WhisperoftheNathrezim = Spell(207635),

    -- PvP Talent
    HammerOfReckoning = Spell(247675),
    HammerOfReckoningBuff = Spell(247677),
}

----HUNTER
--BeastMastery
RubimRH.Spell[253] = {
    -- Racials
    ArcaneTorrent                 = Spell(80483),
    AncestralCall                 = Spell(274738),
    Berserking                    = Spell(26297),
    BloodFury                     = Spell(20572),
    Fireblood                     = Spell(265221),
    GiftoftheNaaru                = Spell(59547),
    LightsJudgment                = Spell(255647),
    -- Abilities
    AspectoftheWild               = Spell(193530),
    BardedShot                    = Spell(217200),
    Frenzy                        = Spell(272790),
    BeastCleave                   = Spell(115939),
    BeastCleaveBuff               = Spell(118455),
    BestialWrath                  = Spell(19574),
    CobraShot                     = Spell(193455),
    KillCommand                   = Spell(34026),
    MultiShot                     = Spell(2643),
    -- Talents
    AMurderofCrows                = Spell(131894),
    AnimalCompanion               = Spell(267116),
    AspectoftheBeast              = Spell(191384),
    Barrage                       = Spell(120360),
    BindingShot                   = Spell(109248),
    ChimaeraShot                  = Spell(53209),
    DireBeast                     = Spell(120679),
    KillerInstinct                = Spell(273887),
    OnewiththePack                = Spell(199528),
    ScentofBlood                  = Spell(193532),
    SpittingCobra                 = Spell(194407),
    Stampede                      = Spell(201430),
    ThrilloftheHunt               = Spell(257944),
    VenomousBite                  = Spell(257891),
    -- Defensive
    AspectoftheTurtle             = Spell(186265),
    Exhilaration                  = Spell(109304),
    -- Utility
    AspectoftheCheetah            = Spell(186257),
    CounterShot                   = Spell(147362),
    Disengage                     = Spell(781),
    FreezingTrap                  = Spell(187650),
    FeignDeath                    = Spell(5384),
    TarTrap                       = Spell(187698),
    -- Legendaries
    ParselsTongueBuff             = Spell(248084),
    -- Misc
    PoolFocus                     = Spell(9999000010),
    PotionOfProlongedPowerBuff    = Spell(229206),
    SephuzBuff                    = Spell(208052),
    -- Macros
}

--Marksman
RubimRH.Spell[254] = {
    ArcaneTorrent                 = Spell(80483),
    AncestralCall                 = Spell(274738),
    Berserking                    = Spell(26297),
    BloodFury                     = Spell(20572),
    Fireblood                     = Spell(265221),
    GiftoftheNaaru                = Spell(59547),
    LightsJudgment                = Spell(255647),
    -- Abilities
    AimedShot                     = Spell(19434),
    ArcaneShot                    = Spell(185358),
    BurstingShot                  = Spell(186387),
    HuntersMark                   = Spell(185365),
    MultiShot                     = Spell(257620),
    PreciseShots                  = Spell(260242),
    RapidFire                     = Spell(257044),
    SteadyShot                    = Spell(56641),
    TrickShots                    = Spell(257622),
    TrueShot                      = Spell(193526),
    -- Talents
    AMurderofCrows                = Spell(131894),
    Barrage                       = Spell(120360),
    BindingShot                   = Spell(109248),
    CallingtheShots               = Spell(260404),
    DoubleTap                     = Spell(260402),
    ExplosiveShot                 = Spell(212431),
    HuntersMark                   = Spell(257284),
    LethalShots                   = Spell(260393),
    LockandLoad                   = Spell(194594),
    MasterMarksman                = Spell(260309),
    PiercingShot                  = Spell(198670),
    SerpentSting                  = Spell(271788),
    SerpentStingDebuff            = Spell(271788),
    SteadyFocus                   = Spell(193533),
    Volley                        = Spell(260243),
    -- Defensive
    AspectoftheTurtle             = Spell(186265),
    Exhilaration                  = Spell(109304),
    -- Utility
    AspectoftheCheetah            = Spell(186257),
    CounterShot                   = Spell(147362),
    Disengage                     = Spell(781),
    FreezingTrap                  = Spell(187650),
    FeignDeath                    = Spell(5384),
    TarTrap                       = Spell(187698),
    -- Legendaries
    SentinelsSight                = Spell(208913),
    -- Misc
    CriticalAimed                 = Spell(242243),
    PotionOfProlongedPowerBuff    = Spell(229206),
    SephuzBuff                    = Spell(208052),
    MKIIGyroscopicStabilizer      = Spell(235691),
}

----DRUID
-- Feral
RubimRH.Spell[103] = {
    -- Racials
    Berserking = Spell(26297),
    Shadowmeld = Spell(58984),
    -- Abilities
    Berserk = Spell(106951),
    FerociousBite = Spell(22568),
    Maim = Spell(22570),
    MoonfireCat = Spell(155625),
    PredatorySwiftness = Spell(69369),
    Prowl = Spell(5215),
    ProwlJungleStalker = Spell(102547),
    Rake = Spell(1822),
    RakeDebuff = Spell(155722),
    Rip = Spell(1079),
    Shred = Spell(5221),
    Swipe = Spell(106785),
    Thrash = Spell(106830),
    TigersFury = Spell(5217),
    WildCharge = Spell(49376),
    -- Talents
    BalanceAffinity = Spell(197488),
    Bloodtalons = Spell(155672),
    BloodtalonsBuff = Spell(145152),
    BrutalSlash = Spell(202028),
    ElunesGuidance = Spell(202060),
    GuardianAffinity = Spell(217615),
    Incarnation = Spell(102543),
    JungleStalker = Spell(252071),
    JaggedWounds = Spell(202032),
    LunarInspiration = Spell(155580),
    RestorationAffinity = Spell(197492),
    Sabertooth = Spell(202031),
    SavageRoar = Spell(52610),
    MomentOfClarity = Spell(236068),
    SavageRoar = Spell(52610),
    FeralFrenzy = Spell(274837),
    -- Artifact
    AshamanesFrenzy = Spell(210722),
    -- Defensive
    Regrowth = Spell(8936),
    Renewal = Spell(108238),
    SurvivalInstincts = Spell(61336),
    -- Utility
    SkullBash = Spell(106839),
    -- Shapeshift
    BearForm = Spell(5487),
    CatForm = Spell(768),
    MoonkinForm = Spell(197625),
    TravelForm = Spell(783),
    -- Legendaries
    FieryRedMaimers = Spell(236757),
    -- Tier Set
    ApexPredator = Spell(252752), -- TODO: Verify T21 4-Piece Buff SpellID
    -- Misc
    RipAndTear = Spell(203242),
    Clearcasting = Spell(135700)
}
-- Guardian
RubimRH.Spell[104] = {
    -- Racials
    WarStomp             = Spell(20549),
    Berserking           = Spell(26297),
    -- Abilities
    FrenziedRegeneration = Spell(22842),
    Gore                 = Spell(210706),
    GoreBuff             = Spell(93622),
    GoryFur              = Spell(201671),
    Ironfur              = Spell(192081),
    Mangle               = Spell(33917),
    Maul                 = Spell(6807),
    Moonfire             = Spell(8921),
    MoonfireDebuff       = Spell(164812),
    Sunfire              = Spell(197630),
    SunfireDebuff        = Spell(164815),
    Starsurge            = Spell(197626),
    LunarEmpowerment     = Spell(164547),
    SolarEmpowerment     = Spell(164545),
    LunarStrike          = Spell(197628),
    Wrath                = Spell(197629),
    Regrowth             = Spell(8936),
    Swipe                = Spell(213771),
    Thrash               = Spell(77758),
    ThrashDebuff         = Spell(192090),
    ThrashCat            = Spell(106830),
    Prowl                = Spell(5215),
    -- Talents
    BalanceAffinity      = Spell(197488),
    BloodFrenzy          = Spell(203962),
    Brambles             = Spell(203953),
    BristlingFur         = Spell(155835),
    Earthwarden          = Spell(203974),
    EarthwardenBuff      = Spell(203975),
    FeralAffinity        = Spell(202155),
    GalacticGuardian     = Spell(203964),
    GalacticGuardianBuff = Spell(213708),
    GuardianOfElune      = Spell(155578),
    GuardianOfEluneBuff  = Spell(213680),
    Incarnation          = Spell(102558),
    LunarBeam            = Spell(204066),
    Pulverize            = Spell(80313),
    PulverizeBuff        = Spell(158792),
    RestorationAffinity  = Spell(197492),
    SouloftheForest      = Spell(158477),
    MightyBash           = Spell(5211),
    Typhoon              = Spell(132469),
    Entanglement         = Spell(102359),
    -- Artifact
    RageoftheSleeper     = Spell(200851),
    -- Defensive
    SurvivalInstincts    = Spell(61336),
    Barkskin             = Spell(22812),
    -- Utility
    Growl                = Spell(6795),
    SkullBash            = Spell(106839),
    -- Affinity
    FerociousBite        = Spell(22568),
    HealingTouch         = Spell(5185),
    Rake                 = Spell(1822),
    RakeDebuff           = Spell(155722),
    Rejuvenation         = Spell(774),
    Rip                  = Spell(1079),
    Shred                = Spell(5221),
    Swiftmend            = Spell(18562),
    -- Shapeshift
    BearForm             = Spell(5487),
    CatForm              = Spell(768),
    MoonkinForm          = Spell(197625),
    TravelForm           = Spell(783)
}

----DEATH KNIGHT
-- Blood
RubimRH.Spell[250] = {
    -- Racials
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    -- Abilities
    BloodBoil = Spell(50842),
    Blooddrinker = Spell(206931),
    BloodMirror = Spell(206977),
    BloodPlague = Spell(55078),
    BloodShield = Spell(77535),
    BoneShield = Spell(195181),
    Bonestorm = Spell(194844),
    Consumption = Spell(274156),
    CrimsonScourge = Spell(81141),
    DancingRuneWeapon = Spell(49028),
    DancingRuneWeaponBuff = Spell(81256),
    DeathandDecay = Spell(43265),
    DeathsCaress = Spell(195292),
    DeathStrike = Spell(49998),
    HeartBreaker = Spell(221536),
    HeartStrike = Spell(206930),
    Marrowrend = Spell(195182),
    MindFreeze = Spell(47528),
    Ossuary = Spell(219786),
    RapidDecomposition = Spell(194662),
    RuneTap = Spell(194679),
    RuneStrike = Spell(210764),
    RuneStrikeTalent = Spell(19217),
    UmbilicusEternus = Spell(193249),
    VampiricBlood = Spell(55233),
    -- Legendaries
    HaemostasisBuff = Spell(235558),
    SephuzBuff = Spell(208052),

    -- PVP
    MurderousIntent =   Spell(207018),
    Intimidated     =   Spell(206891),
    DeathChain      =   Spell(203173),
}
--FROST
RubimRH.Spell[251] = {
    -- Racials
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    GiftoftheNaaru = Spell(59547),

    -- Abilities
    ChainsOfIce = Spell(45524),
    EmpowerRuneWeapon = Spell(47568),
    FrostFever = Spell(55095),
    FrostStrike = Spell(49143),
    HowlingBlast = Spell(49184),
    Obliterate = Spell(49020),
    PillarOfFrost = Spell(51271),
    RazorIce = Spell(51714),
    RemorselessWinter = Spell(196770),
    KillingMachine = Spell(51124),
    Rime = Spell(59052),
    UnholyStrength = Spell(53365),
    -- Talents
    BreathofSindragosa = Spell(152279),
    BreathofSindragosaTicking = Spell(155166),
    FrostScythe = Spell(207230),
    FrozenPulse = Spell(194909),
    FreezingFog = Spell(207060),
    GatheringStorm = Spell(194912),
    GatheringStormBuff = Spell(211805),
    GlacialAdvance = Spell(194913),
    HornOfWinter = Spell(57330),
    IcyTalons = Spell(194878),
    IcyTalonsBuff = Spell(194879),
    MurderousEfficiency = Spell(207061),
    Obliteration = Spell(281238),
    RunicAttenuation = Spell(207104),
    ShatteringStrikes = Spell(207057),
    Icecap = Spell(207126),
    ColdHeartTalent = Spell(281208),
    ColdHeartBuff = Spell(281209),
    ColdHeartItemBuff = Spell(235599),
    FrostwyrmsFury = Spell(279302),
    -- Defensive
    AntiMagicShell = Spell(48707),
    DeathStrike = Spell(49998),
    IceboundFortitude = Spell(48792),
    DarkSuccor = Spell(101568),
    -- Utility
    ControlUndead = Spell(45524),
    DeathGrip = Spell(49576),
    MindFreeze = Spell(47528),
    PathOfFrost = Spell(3714),
    WraithWalk = Spell(212552),
    ChillStreak = Spell(204160),
}
-- UNHOLY
RubimRH.Spell[252] = {
    -- Racials
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    GiftoftheNaaru = Spell(59547),
    -- Artifact
    Apocalypse = Spell(275699),
    --Abilities
    ArmyOfDead = Spell(42650),
    ChainsOfIce = Spell(45524),
    ScourgeStrike = Spell(55090),
    DarkTransformation = Spell(63560),
    DeathAndDecay = Spell(43265),
    DeathCoil = Spell(47541),
    DeathStrike = Spell(49998),
    FesteringStrike = Spell(85948),
    Outbreak = Spell(77575),
    SummonPet = Spell(46584),
    --Talents
    Pestilence = Spell(277234),
    InfectedClaws = Spell(207272),
    AllWillServe = Spell(194916),
    ClawingShadows = Spell(207311),
    PestilentPustules = Spell(194917),
    InevitableDoom = Spell(276023),
    SoulReaper = Spell(130736),
    BurstingSores = Spell(207264),
    EbonFever = Spell(207269),
    UnholyBlight = Spell(115989),
    CorpseExplosion = Spell(276049),
    Defile = Spell(152280),
    Epidemic = Spell(207317),
    DarkInfusion = Spell(198943),
    UnholyFrenzy = Spell(207289),
    SummonGargoyle = Spell(49206),
    --Necrosis                      = Spell(207346), not on beta atm
    --Buffs/Procs
    --MasterOfGhouls                = Spell(246995), not on beta atm
    SuddenDoom = Spell(81340),
    UnholyStrength = Spell(53365),
    --NecrosisBuff                  = Spell(216974), not on beta atm
    DeathAndDecayBuff = Spell(188290),
    --Debuffs
    SoulReaperDebuff = Spell(130736),
    FesteringWounds = Spell(194310), --max 8 stacks
    VirulentPlagueDebuff = Spell(191587), -- 13s debuff from Outbreak
    --Defensives
    AntiMagicShell = Spell(48707),
    IcebornFortitute = Spell(48792),
    -- Utility
    ControlUndead = Spell(45524),
    DeathGrip = Spell(49576),
    MindFreeze = Spell(47528),
    PathOfFrost = Spell(3714),
    WraithWalk = Spell(212552),
    --Legendaries Buffs/SpellIds
    ColdHeartItemBuff = Spell(235599),
    InstructorsFourthLesson = Spell(208713),
    KiljaedensBurningWish = Spell(144259),
    --SummonGargoyle HiddenAura
    SummonGargoyleActive = Spell(212412), --tbc
}

----DEMONHUNTER
-- Vengeance
RubimRH.Spell[581] = {
    -- Abilities
    Felblade = Spell(232893),
    FelDevastation = Spell(212084),
    Fracture = Spell(263642),
    FractureTalent = Spell(227700),
    Frailty = Spell(247456),
    ImmolationAura = Spell(178740),
    Sever = Spell(235964),
    Shear = Spell(203782),
    SigilofFlame = Spell(204596),
    SpiritBomb = Spell(247454),
    SoulCleave = Spell(228477),
    SoulFragments = Spell(203981),
    ThrowGlaive = Spell(204157),
    -- Offensive
    SoulCarver = Spell(207407),
    -- Defensive
    FieryBrand = Spell(204021),
    DemonSpikes = Spell(203720),
    DemonSpikesBuff = Spell(203819),
    -- Utility
    ConsumeMagic = Spell(183752),
    InfernalStrike = Spell(189110)
}
--Havoc
RubimRH.Spell[577] = {
    -- Racials
    ArcaneTorrent = Spell(80483),
    Shadowmeld = Spell(58984),
    -- Abilities
    Annihilation = Spell(201427),
    BladeDance = Spell(188499),
    ConsumeMagic = Spell(183752),
    ChaosStrike = Spell(162794),
    ChaosNova = Spell(179057),
    DeathSweep = Spell(210152),
    DemonsBite = Spell(162243),
    EyeBeam = Spell(198013),
    FelRush = Spell(195072),
    Metamorphosis = Spell(191427),
    MetamorphosisImpact = Spell(200166),
    MetamorphosisBuff = Spell(162264),
    ThrowGlaive = Spell(185123),
    VengefulRetreat = Spell(198793),
    -- Talents
    BlindFury = Spell(203550),
    Bloodlet = Spell(206473),
    ChaosBlades = Spell(247938),
    ChaosCleave = Spell(206475),
    DemonBlades = Spell(203555),
    Demonic = Spell(213410),
    DemonicAppetite = Spell(206478),
    DemonReborn = Spell(193897),
    Felblade = Spell(232893),
    FelEruption = Spell(211881),
    FelMastery = Spell(192939),
    FirstBlood = Spell(206416),
    MasterOfTheGlaive = Spell(203556),
    Momentum = Spell(206476),
    MomentumBuff = Spell(208628),
    Nemesis = Spell(206491),
    -- Artifact
    FuryOfTheIllidari = Spell(201467),


    -- Talents
    ImmolationAura = Spell(258920),
    FelBarrage = Spell(258925),
    DarkSlash = Spell(258860),

    -- Set Bonuses
    T21_4pc_Buff = Spell(252165),
}
--- Warlock

-- Affliction
RubimRH.Spell[265] = {
    -- Baseline
    DemonicGateway = Spell(111771),
    CreateSoulwell = Spell(29893),
    EnslaveDemon = Spell(1098),
    UnendingResolve = Spell(104773),
    Soulstone = Spell(20707),
    RitualOfSummoning = Spell(698),
    CommandDemon = Spell(119898),
    SummonFelhunter = Spell(691),
    Banish = Spell(710),
    SummonSuccubus = Spell(712),
    UnendingBreath = Spell(5697),
    HealthFunnel = Spell(755),
    SummonVoidwalker = Spell(697),
    CreateHealthstone = Spell(6201),
    Fear = Spell(5782),
    SummonImp = Spell(688),
    -- Specialization
    PotentAfflictions = Spell(77215),
    Shadowfury = Spell(30283),
    SummonDarkglare = Spell(205180),
    Agony =  Spell(980),
    SeedOfCorruption = Spell(27243),
    UnstableAffliction = Spell(30108),
    DrainLife = Spell(234153),
    Corruption = Spell(172),
    ShadowBolt = Spell(232670),
    -- Talents
    CreepingDeath = Spell(264000),
    Deathbolt = Spell(264106),
    DarkSoulMisery = Spell(113860),
    SoulConduit = Spell(215941),
    GrimoireOfSacrifice = Spell(108503),
    Haunt = Spell(48181),
    PhantomSingularity = Spell(205179),
    SowTheSeeds = Spell(196226),
    VileTaint = Spell(278350),
    AbsoluteCorruption = Spell(196103),
    WritheInAgony = Spell(196102),
    DrainSoul = Spell(198590),
    Nightfall = Spell(108558)
}