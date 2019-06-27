--- Arrays/Table
-- @module Lists

local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Arena = Unit.Arena;
local Spell = HL.Spell;
local Item = HL.Item;


RubimRH.Listener:Add('Rubim_Events', 'PLAYER_ENTERING_WORLD', function(...)

    RubimRH.List.SpellSchool = {
        Physical = 1,
        Holy = 2,
        Fire = 4,
        Nature = 8,
        Frost = 16,
        Shadow = 32,
    }
    RubimRH.List.DefensiveType = {
        DamageType = {
            All = {
                --DK
                Spell(48792), --Icebound Fortitude
                Spell(207319), --Corpse Shield

                --DRUID
                Spell(61336), -- Survival Instics
                Spell(22817), -- Barksin
                Spell(102342), -- Ironbark

                --HUNTER
                Spell(19263), --Deterrence
                Spell(53480), --Roar of Sacrifice

                --MAGE
                Spell(45438), --Iceblock

                --MONK
                Spell(120954), --Fortifying Brew
                Spell(122278), --Dampem Harm
                Spell(116849), --Life Coccon
                Spell(122470), --Touch of Karma

                --MAGIC
                Spell(122783), --Diffuse Magic

                --PALADIN
                Spell(1044), --Blessing of Freedom
                Spell(642), --Divine Shield
                Spell(6940), -- Blessing of Sacrifice
                Spell(31850), --Ardent Defender
                Spell(184662), --Shield of Vengance

                --PRIEST
                Spell(33206), -- Pain Suppression
                Spell(47585), -- Dispersion
                Spell(47788), -- Guardian Spirit


                --Rogue
                --Physical
                Spell(5277), -- Evasion

                --MAGIC
                Spell(31224), -- Cloak of Shadows


                --SHAMAN
                Spell(108271), -- Astral Shift

                --LOCK
                Spell(104773), --Unending Resolve

                --WARRIOR
                Spell(871), -- Shield Wall

                Spell(104773), --Unending Resolve
                Spell(871), --Shield Wall
                Spell(642), --Divine shield
                Spell(4543), --Ice Block
                Spell(47788), --Guardian Spirit
                Spell(184662), --Shield of Vengance
            },

            Physical = {
                --Paladin
                Spell(1022), --Blessing of Protection

                --Rogue
                Spell(5277), -- Evasion

                --Warrior
                Spell(118038), -- Die by the Sword
            },

            Magic = {
                --DK
                Spell(48707), -- Anti-Magic Shell

                --Monk
                Spell(122783), --Diffuse Magic
            },
        }
    }

    --- Dangerous Spells
    -- @table RubimRH.List.DangerousSpells
    RubimRH.List.DangerousSpells = {
        Spell(157695), -- Demonbolt**
        Spell(32375), --Mass Dispel
        Spell(48181), -- Haunt
        Spell(202771), -- Full Moon*
        Spell(199786), -- Glacial Spike
        Spell(116858), -- Chaos Bolt
        Spell(105174), -- Hand of Gul'dan
        Spell(228260), -- Void Eruption
        Spell(34914), -- Vampiric Touch
        Spell(124465), -- Vampiric Touch
        Spell(30108), -- Unstable Affliction
        Spell(214634), -- Ebonbolt
        Spell(205495), -- Stormkeeper
        Spell(203286), -- Great Pyroblast
    }

    --- Big DMG
    -- @table RubimRH.List.DMG
    RubimRH.List.DMG = {
        Spell(116), --  Frostbolt
        Spell(2948), --  Scorch
        Spell(51505), --  Lava Burst
        Spell(403), --  Lightnin Bolt
        Spell(48181), --  Haunt
        Spell(30451), --  Arcane Blast
        Spell(113092), --  Frost Bomb
        Spell(8092), --  Mind Blast
        Spell(11366), --  Pyroblast
        Spell(203286), -- Great Pyroblast
        Spell(126201), --  Frost Bolt
        Spell(15407), --  Mind Flay
        Spell(44614), --  Frostfire Bolt
        Spell(133), --  Fireball
        Spell(103103), --  Malefic Grasp
        Spell(117014), --  Elemental Blast
        Spell(118297), --  Immolate
    }

    --- Healing
    -- @table RubimRH.List.HEALING
    RubimRH.List.HEALING = {
        Spell(2060), --Heal
        Spell(8936), --  Regrowth
        Spell(19750), --  Flash of Light
        Spell(82326), --  Divine Light
        Spell(2061), --  Flash Heal
        Spell(64901), --  Hymn of Hope
        Spell(12051), --  Evocation
        Spell(64843), --  Divine Hymn
        Spell(115175), --  Soothing Mist
        Spell(8936), --  Regrowth
        Spell(2061), --  Flash Heal
        Spell(32546), --  binding Heal
        Spell(2060), --  Greater Heal
        Spell(2006), --  Resurrection
        Spell(596), --  Prayer of Healing
        Spell(19750), --  Flash of Light
        Spell(7328), --  Redemption
        Spell(2008), --  Ancestral Spirit
        Spell(50769), --  Revive
        Spell(82326), --  Divine Light
        Spell(740), --  Tranquillity
        Spell(124682), --  Enveloping Mist
        Spell(64901), --  Hymn of Hope
        Spell(64843), --  Divine Hymn
        Spell(115151), --  Renewing Mist
        Spell(115310), --  Revival
        Spell(152118), --  Clarity of Will
        Spell(186263), --  Shadow Mend
    }

    --- Hex
    -- @table RubimRH.List.HEX
    RubimRH.List.HEX = {
        Spell(5782), --  Fear
        Spell(33786), --  Cyclone
        Spell(28272), --  Pig Poly (if we have a resto Druid team mate check if out of form)
        Spell(118), --  Sheep Poly (same as above ^^)
        Spell(61305), --  Cat Poly (^^)
        Spell(61721), --  Rabbit Poly (^^)
        Spell(61780), --  Turkey Poly (^^)
        Spell(28271), --  Turtle Poly (^^)
        Spell(51514), --  Hex (Only kick if we do not have a feral Druid in our team)
        Spell(20066), --  Repentance
        Spell(82012), --  Repentance
        Spell(605), --  Dominate Mind
        Spell(51514), -- Hex
        Spell(211004), -- Hex
        Spell(210873), -- Hex
        Spell(211015), -- Hex
        Spell(211010), -- Hex
        Spell(605), -- Mind Control
        Spell(28271), -- Turtle
        Spell(61780), -- Turkey
        Spell(61721), -- Rabbit
        Spell(61305), -- Black Cat
        Spell(28272), -- Pig
    }

    --- BreakableCC
    -- @table RubimRH.List.BreakableCC
    RubimRH.List.BreakableCC = {
        Spell(118), -- Sheep
        Spell(28271), -- Turtle
        Spell(61780), -- Turkey
        Spell(61721), -- Rabbit
        Spell(61305), -- Black Cat
        Spell(28272), -- Pig
        Spell(6770), -- Sap
        Spell(20066), -- Repentance
        Spell(51514), -- Hex
        Spell(211004), -- Hex
        Spell(210873), -- Hex
        Spell(211015), -- Hex
        Spell(211010), -- Hex
        Spell(5782), -- Fear
        Spell(3355), -- Freezing Trap
        Spell(209790), -- Freezing Arrow (Talent)
        Spell(6358), -- Seduction
        Spell(2094), -- Blind
        Spell(19386), -- Wyverm Sting
        Spell(82691), -- Ring of Frost
        Spell(115078), -- Paralysis
        Spell(115268), -- Mesmerize
        Spell(5484), -- Howl of Terror
        Spell(5246), -- Intimidating Shout
        Spell(6789), -- Mortal Coil
        Spell(8122), -- Psychic Scream
        Spell(99), -- Incapacitating Roar
        Spell(1776), -- Gouge
        Spell(31661), -- Dragon's Breath
        Spell(105421), -- Blinding Light
        Spell(186387), -- Bursting Shot
        Spell(202274), -- Incendiary Brew
        Spell(207167), -- Blinding Sheet
        Spell(213691), -- Scatter Shot (Honor)
        Spell(605), -- Mind Control
        Spell(217832), -- Imprison
        Spell(339), -- Entagle Roots
        Spell(34787), --Frozen Circles
    }

    --- Disarm Debuffs
    -- @table RubimRH.List.Disarm
    RubimRH.List.Disarm = {
        Spell(207777), -- Dismantle
        Spell(236077), -- Disarm
        Spell(236236), -- Disarm
        Spell(209749), -- Faerie Swarm
        Spell(233759), -- Gapple Weapon
    }

    --- Reflect Spells
    -- @table RubimRH.List.Reflect
    RubimRH.List.Reflect = {
        Spell(161372), -- Poly
        Spell(190319), -- Combustion
        Spell(161372), -- Polymorph
        Spell(203286), -- Greater Pyroblast
        Spell(199786), --  Glacial Spike
        Spell(257537), -- Ebonbolt
        Spell(161372), -- Polymorph
        Spell(210714), -- Icefury
        Spell(191634), -- Stormkeeper
        Spell(116858), -- Chaos Bolt
    }

    --- Bursting Spells
    -- @table RubimRH.List.Burst
    RubimRH.List.Burst = {
        Spell(1719), -- RecklessNess
        Spell(51271), -- Pillar of Frost
        Spell(47568), -- Empower Rune Weapon
        Spell(152279), -- Breath of Sindragosa

        Spell(63560), -- Dark Transformation
        Spell(49206), -- Summon Gargoyle
        Spell(207289), -- Unholy Frenzy

        Spell(106951), -- Berserk
        Spell(5217), -- Tiger's Fury
        Spell(102543), -- Incarnation: King of the Jungle

        Spell(202770), -- Fury of Elune
        Spell(194223), -- Celestial Alignment
        Spell(205636), -- Force of Nature
        Spell(102560), -- Incarnation: Chosen of Elune

        Spell(193526), -- Trueshot

        Spell(266779), -- Coordinated Assault
        Spell(186289), -- Aspect of the Eagle
        Spell(19574), -- Bestial Wrath
        Spell(193530), -- Aspect of the Wild
        Spell(201430), -- Stampede
        Spell(131894), -- A Murder of Crows
        Spell(194407), -- Spitting Cobra
        Spell(264667), -- Primal Rage

        Spell(152173), -- Serenity
        Spell(115080), -- Touhc of Death
        Spell(137639), -- Storm, Earth, and Fire
        Spell(123904), -- Invoke Xuen, the White Tiger

        Spell(31884), -- Avenging Wrath
        Spell(231895), -- Crusade

        Spell(79140), -- Vendetta

        Spell(121471), -- Shadow of Blades
        Spell(185313), -- Shadow Dance
        Spell(212283), -- Symbols of Death

        Spell(13750), -- Adrenaline Rush
        Spell(13877), -- Blade Furry
        Spell(57934), -- Tricks of the Trade
        Spell(51690), -- Killing Spree

        Spell(191427), -- Metamorphosis
        Spell(162264), -- Metamorphosis
        Spell(206491), -- Nemesis

        Spell(12042), -- Arcane Power
        Spell(205025), -- Presence of Mind

        Spell(190319), -- Combustion
        Spell(161372), -- Polymorph
        Spell(203286), -- Greater Pyro Blast

        Spell(12472), -- Icy Veins
        Spell(199786), -- Glacial Spike
        Spell(257537), -- Ebonbolt

        Spell(34433), -- Shadowfiend
        Spell(228260), -- Void Eruption

        Spell(210714), -- Icefury
        Spell(191634), -- Stormkeeper
        Spell(114050), -- Ascendance

        Spell(51533), -- Feral Spirit
        Spell(114052), -- Ascendance

        Spell(205180), -- Summon Darkglare
        Spell(264106), -- Dethbolt
        Spell(30108), -- Unstable Affliction
        Spell(113860), -- Dark Soul: Misery

        Spell(1122), -- Summon Infernal

        Spell(265187), -- Summon Demonic Tyrant
    }

    --- Immunity Buffs
    -- @table RubimRH.List.Immunity
    RubimRH.List.Immunity = {
        Spell(196555), -- Netherwak
        Spell(198111), -- Temporal Shield
        Spell(45438), -- Iceblock
        Spell(642), -- Divine Shield
        Spell(184662), -- Shield of Vengeance
        Spell(47585), -- Dispersion
        Spell(212295), --Netherward
        Spell(33786), --  Cyclone
        Spell(186265), -- Aspect of Turtle
    }

    --- Immunity to Stun
    -- @table RubimRH.List.StunImmunity
    RubimRH.List.StunImmunity = {
        Spell(48792), -- Icebound Fortitude
        Spell(53271), -- Master's Call
        Spell(198144), --Iceform
    }

    --- Defensive
    -- @table RubimRH.List.DefensiveAll
    RubimRH.List.DefensiveAll = {
        Spell(48792), -- Icebound Fortitude
        Spell(61336), -- Survival Instics
        Spell(207319), --Corpse Shield
        Spell(53480), --Roar of Sacrifice
        Spell(122278), --Dampem Harm
        Spell(115203), --Fortifying Brew
        Spell(31850), --Ardent Defender
        Spell(33206), --Pain Suppresion
        Spell(108271), --Astral Shift
        Spell(104773), --Unending REsolve
        Spell(871), --Shield Wall
    }

    --- ImmuneMagic
    -- @table RubimRH.List.ImmuneMagic
    RubimRH.List.MagicImmunity = {
        Spell(48707), -- AMS
        Spell(122783), -- Diffuse Magic
        Spell(31224), -- Cloak of Shadows
    }

    --- ImmunePhys
    -- @table RubimRH.List.ImmunePhys
    RubimRH.List.PhysImmunity = {
        Spell(212800), -- Blur
        Spell(1022), -- Blessing of Protection
        Spell(5277), -- Evasion
        Spell(199754), -- Riposte
        Spell(210918), -- Ethereal Form
        Spell(118038), -- Die by Sword
        --Spell(236696), -- Thorns
    }

    --- Purge List
    -- @table RubimRH.List.purgeList
    RubimRH.List.purgeList = {
        Spell(1022), --BOP
        Spell(213610), --Holy Ward
        Spell(204018), --Blessing of spellwarding
        Spell(29166), --innervate
        Spell(205025), --POM
        Spell(1044), --Freedom
        Spell(198111), ---Temporal Shield
        Spell(210294), --Divine Favor
        Spell(212295), --Nteher
    }

    --- Immunity List
    RubimRH.List.PvEImmunity = {
        Spell(275129), -- Corpulent Mass
        Spell(263217), -- BloodShield
        Spell(271965), -- Powered Down
        Spell(260189), -- Config Drill
    }

    RubimRH.List.Melee = {
        [250] = true,
        [251] = true,
        [252] = true,
        [577] = true,
        [581] = true,
        [103] = true,
        [104] = true,
        [255] = true,
        [268] = true,
        [269] = true,
        [70] = true,
        [259] = true,
        [260] = true,
        [261] = true,
        [263] = true,
        [71] = true,
        [72] = true,
        [73] = true,
    }

    RubimRH.List.Healer = {
        [105] = true,
        [270] = true,
        [65] = true,
        [256] = true,
        [257] = true,
        [264] = true,
    }

    RubimRH.List.RangedSpec = {
        [102] = true,
        [105] = true,
        [253] = true,
        [254] = true,
        [255] = true,
        [270] = true,
        [62] = true,
        [63] = true,
        [64] = true,
        [256] = true,
        [257] = true,
        [258] = true,
        [262] = true,
        [264] = true,
        [265] = true,
        [266] = true,
        [267] = true,
    }

    RubimRH.List.DesarmableSpec = {
        [250] = true,
        [251] = true,
        [252] = true,
        [577] = true,
        [581] = true,
        [254] = true,
        [255] = true,
        [70] = true,
        [66] = true,
        [259] = true,
        [260] = true,
        [261] = true,
        [263] = true,
        [71] = true,
        [72] = true,
        [73] = true,
    }

    RubimRH.List.PvPDispel = {
        [145206]= { Type = 'Magic', Zone = 'PvP' }, --Aqua Bomb
        [853]= { Type = 'Magic', Zone = 'PvP' }, --Hammer of Justice
        [28272]= { Type = 'Magic', Zone = 'PvP' }, --Pig Poly
        [118]= { Type = 'Magic', Zone = 'PvP' }, --Sheep Poly
        [61305]= { Type = 'Magic', Zone = 'PvP' }, --Cat Poly
        [61721]= { Type = 'Magic', Zone = 'PvP' }, --Rabbit Poly
        [61780]= { Type = 'Magic', Zone = 'PvP' }, --Turkey Poly
        [28271]= { Type = 'Magic', Zone = 'PvP' }, --Turtle Poly
        [161355]= { Type = 'Magic', Zone = 'PvP' }, --Penguin Poly
        [161354]= { Type = 'Magic', Zone = 'PvP' }, --Monkey Poly
        [161353]= { Type = 'Magic', Zone = 'PvP' }, --Bear Cub Poly
        [126819]= { Type = 'Magic', Zone = 'PvP' }, --Pig Poly
        [161372]= { Type = 'Magic', Zone = 'PvP' }, --Peacock Poly
        [82691]= { Type = 'Magic', Zone = 'PvP' }, --Ring of Frost--Shaman
        [51514]= { Type = 'Magic', Zone = 'PvP' }, --Hex
        [3355]= { Type = 'Magic', Zone = 'PvP' }, --Freezing Trap
        [203337]= { Type = 'Magic', Zone = 'PvP' }, --Freezing Trap
        [209790]= { Type = 'Magic', Zone = 'PvP' }, --Freezing Arrow
        [19386]= { Type = 'Magic', Zone = 'PvP' }, --Wyvern Sting
        [145067]= { Type = 'Magic', Zone = 'PvP' }, --Turn Evil (Evil is a Point of View)--Priest
        [8122]= { Type = 'Magic', Zone = 'PvP' }, --Psychic Scream--Warlock
        [5782]= { Type = 'Magic', Zone = 'PvP' }, --Fear
        [118699]= { Type = 'Magic', Zone = 'PvP' }, --Fear
        [130616]= { Type = 'Magic', Zone = 'PvP' }, --Fear (Glyph of Fear)
        [5484]= { Type = 'Magic', Zone = 'PvP' }, --Howl of Terror
        [115268]= { Type = 'Magic', Zone = 'PvP' }, --Mesmerize (Shivarra)
        [6358]= { Type = 'Magic', Zone = 'PvP' }, --Seduction (Succubus)--Warrior
        [20066]= { Type = 'Magic', Zone = 'PvP' }, --Repentance
        [115750]= { Type = 'Magic', Zone = 'PvP' }, --Priest
        [605]= { Type = 'Magic', Zone = 'PvP' }, --Dominate Mind
        [179057]= { Type = 'Magic', Zone = 'PvP' }, --chaos nova
        [122]= { Type = 'Magic', Zone = 'PvP' }, --Frost Nova
        [33395]= { Type = 'Magic', Zone = 'PvP' }, --Freeze (Water Elemental)
        [64695]= { Type = 'Magic', Zone = 'PvP' }, --Earthgrab (Earthgrab Totem)
        [339]= { Type = 'Magic', Zone = 'PvP' }, -- Entangling Roots,
        [217832]= { Type = 'Magic', Zone = 'PvP' }, --imprision
        [118905]= { Type = 'Magic', Zone = 'PvP' }, --static charge
        [20066]= { Type = 'Magic', Zone = 'PvP' }, --  Repentance
        [82012]= { Type = 'Magic', Zone = 'PvP' }, --  Repentance
        [339]= { Type = 'Magic', Zone = 'PvP' }, --Roots
    }

    RubimRH.List.PvPPurge = {
        [1022] = true, --BOP
        [213610] = true, --Holy Ward
        [204018] = true, --Blessing of spellwarding
        [29166] = true, --innervate
        [205025] = true, --POM
        [1044] = true, --Freedom
        [198111] = true, --Temporal Shield
        [210294] = true, --Divine Favor
        [212295] = true, --Nteher
    }

    RubimRH.List.PvEInterrupts = {
        [140983] = { useKick = true, useCC = false, Zone = 'Brawler' },
        [281949] = { useKick = true, useCC = false, Zone = 'Brawler' },
        [142621] = { useKick = true, useCC = false, Zone = 'Brawler' },
        [33975] = { useKick = true, useCC = false, Zone = 'Brawler' },
        [132666] = { useKick = false, useCC = true, Zone = 'Brawler' },
        [282081] = { useKick = true, useCC = true, Zone = 'Brawler' },
        [287419] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [283628] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [284578] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [282243] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [286379] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [287887] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [289861] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [268198] = { useKick = true, useCC = false, Zone = "Uldir" },
        [267180] = { useKick = true, useCC = false, Zone = "Uldir" },
        [273350] = { useKick = true, useCC = false, Zone = "Uldir" },
        [267427] = { useKick = true, useCC = false, Zone = "Uldir" },
        [263307] = { useKick = true, useCC = false, Zone = "Uldir" },
        [256849] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [253517] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [253548] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [253583] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [255041] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [256849] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [252781] = { useKick = true, useCC = true, Zone = "Atal'Dazar" },
        [250368] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [259572] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [250096] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [253562] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [255824] = { useKick = true, useCC = true, Zone = "Atal'Dazar" },
        [252923] = { useKick = true, useCC = true, Zone = "Atal'Dazar" },
        [265089] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [265091] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [278755] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [260879] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [266106] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [278961] = { useKick = true, useCC = true, Zone = "The Underrot" },
        [266201] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [272183] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [272180] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [265433] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [265523] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [267824] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [265371] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [263891] = { useKick = true, useCC = true, Zone = "Waycrest Manor" },
        [266035] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [266036] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [260805] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [278551] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [278474] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [263943] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [264520] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [278444] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [265407] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [265876] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [264105] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [278551] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [264384] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [263959] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [268278] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [266225] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [273657] = { useKick = false, useCC = true, Zone = "Waycrest Manor" },
        [265368] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [269972] = { useKick = true, useCC = false, Zone = "Kings' Rest" },
        [270923] = { useKick = true, useCC = false, Zone = "Kings' Rest" },
        [270901] = { useKick = true, useCC = false, Zone = "Kings' Rest" },
        [267763] = { useKick = true, useCC = false, Zone = "Kings' Rest" },
        [270492] = { useKick = true, useCC = true, Zone = "Kings' Rest" },
        [267273] = { useKick = true, useCC = false, Zone = "Kings' Rest" },
        [258128] = { useKick = true, useCC = false, Zone = "TolDagor" },
        [258153] = { useKick = true, useCC = false, Zone = "TolDagor" },
        [257791] = { useKick = true, useCC = false, Zone = "TolDagor" },
        [258313] = { useKick = true, useCC = true, Zone = "TolDagor" },
        [258869] = { useKick = true, useCC = false, Zone = "TolDagor" },
        [258634] = { useKick = true, useCC = false, Zone = "TolDagor" },
        [258935] = { useKick = true, useCC = true, Zone = "TolDagor" },
        [256060] = { useKick = true, useCC = false, Zone = "Freehold" },
        [257397] = { useKick = true, useCC = true, Zone = "Freehold" },
        [258777] = { useKick = true, useCC = false, Zone = "Freehold" },
        [257732] = { useKick = true, useCC = false, Zone = "Freehold" },
        [257736] = { useKick = true, useCC = true, Zone = "Freehold" },
        [257756] = { useKick = false, useCC = true, onChannel = true, Zone = "Freehold" },
        [256957] = { useKick = true, useCC = true, Zone = "Siege of Boralus" },
        [272571] = { useKick = true, useCC = true, Zone = "Siege of Boralus" },
        [274569] = { useKick = true, useCC = true, Zone = "Siege of Boralus" },
        [265968] = { useKick = true, useCC = true, Zone = "Temple of Selthralis" },
        [261635] = { useKick = true, useCC = true, Zone = "Temple of Selthralis" },
        [261624] = { useKick = true, useCC = true, Zone = "Temple of Selthralis" },
        [265912] = { useKick = true, useCC = false, Zone = "Temple of Selthralis" },
        [272820] = { useKick = true, useCC = false, Zone = "Temple of Selthralis" },
        [268061] = { useKick = true, useCC = false, Zone = "Temple of Selthralis" },
        [267433] = { useKick = false, useCC = true, Zone = "Motherlode" },
        [280604] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [268185] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [268129] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [269302] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [267354] = { useKick = false, useCC = true, Zone = "Motherlode" },
        [268709] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [268702] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [263215] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [263066] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [263103] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [268797] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [269090] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [271579] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [263202] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [262554] = { useKick = false, useCC = true, Zone = "Motherlode" },
        [258627] = { useKick = false, useCC = true, Zone = "Motherlode" },
        [267977] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [267969] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [268030] = { useKick = true, useCC = true, Zone = "Shrine of the Storm" },
        [274438] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [268309] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [268322] = { useKick = true, useCC = true, Zone = "Shrine of the Storm" },
        [268317] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [268375] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [267809] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [267818] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [268347] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [276292] = { useKick = false, useCC = true, Zone = "Shrine of the Storm" },
    }
	
	RubimRH.List.MixedInterrupts = {
	    -- PVE
        [140983] = { useKick = true, useCC = false, Zone = 'Brawler' },
        [281949] = { useKick = true, useCC = false, Zone = 'Brawler' },
        [142621] = { useKick = true, useCC = false, Zone = 'Brawler' },
        [33975] = { useKick = true, useCC = false, Zone = 'Brawler' },
        [132666] = { useKick = false, useCC = true, Zone = 'Brawler' },
        [282081] = { useKick = true, useCC = true, Zone = 'Brawler' },
        [287419] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [283628] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [284578] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [282243] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [286379] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [287887] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [289861] = { useKick = true, useCC = false, Zone = "Dazar'alor" },
        [268198] = { useKick = true, useCC = false, Zone = "Uldir" },
        [267180] = { useKick = true, useCC = false, Zone = "Uldir" },
        [273350] = { useKick = true, useCC = false, Zone = "Uldir" },
        [267427] = { useKick = true, useCC = false, Zone = "Uldir" },
        [263307] = { useKick = true, useCC = false, Zone = "Uldir" },
        [256849] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [253517] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [253548] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [253583] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [255041] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [256849] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [252781] = { useKick = true, useCC = true, Zone = "Atal'Dazar" },
        [250368] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [259572] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [250096] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [253562] = { useKick = true, useCC = false, Zone = "Atal'Dazar" },
        [255824] = { useKick = true, useCC = true, Zone = "Atal'Dazar" },
        [252923] = { useKick = true, useCC = true, Zone = "Atal'Dazar" },
        [265089] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [265091] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [278755] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [260879] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [266106] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [278961] = { useKick = true, useCC = true, Zone = "The Underrot" },
        [266201] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [272183] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [272180] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [265433] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [265523] = { useKick = true, useCC = false, Zone = "The Underrot" },
        [267824] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [265371] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [263891] = { useKick = true, useCC = true, Zone = "Waycrest Manor" },
        [266035] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [266036] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [260805] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [278551] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [278474] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [263943] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [264520] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [278444] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [265407] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [265876] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [264105] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [278551] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [264384] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [263959] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [268278] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [266225] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [273657] = { useKick = false, useCC = true, Zone = "Waycrest Manor" },
        [265368] = { useKick = true, useCC = false, Zone = "Waycrest Manor" },
        [269972] = { useKick = true, useCC = false, Zone = "Kings' Rest" },
        [270923] = { useKick = true, useCC = false, Zone = "Kings' Rest" },
        [270901] = { useKick = true, useCC = false, Zone = "Kings' Rest" },
        [267763] = { useKick = true, useCC = false, Zone = "Kings' Rest" },
        [270492] = { useKick = true, useCC = true, Zone = "Kings' Rest" },
        [267273] = { useKick = true, useCC = false, Zone = "Kings' Rest" },
        [258128] = { useKick = true, useCC = false, Zone = "TolDagor" },
        [258153] = { useKick = true, useCC = false, Zone = "TolDagor" },
        [257791] = { useKick = true, useCC = false, Zone = "TolDagor" },
        [258313] = { useKick = true, useCC = true, Zone = "TolDagor" },
        [258869] = { useKick = true, useCC = false, Zone = "TolDagor" },
        [258634] = { useKick = true, useCC = false, Zone = "TolDagor" },
        [258935] = { useKick = true, useCC = true, Zone = "TolDagor" },
        [256060] = { useKick = true, useCC = false, Zone = "Freehold" },
        [257397] = { useKick = true, useCC = true, Zone = "Freehold" },
        [258777] = { useKick = true, useCC = false, Zone = "Freehold" },
        [257732] = { useKick = true, useCC = false, Zone = "Freehold" },
        [257736] = { useKick = true, useCC = true, Zone = "Freehold" },
        [257756] = { useKick = false, useCC = true, onChannel = true, Zone = "Freehold" },
        [256957] = { useKick = true, useCC = true, Zone = "Siege of Boralus" },
        [272571] = { useKick = true, useCC = true, Zone = "Siege of Boralus" },
        [274569] = { useKick = true, useCC = true, Zone = "Siege of Boralus" },
        [265968] = { useKick = true, useCC = true, Zone = "Temple of Selthralis" },
        [261635] = { useKick = true, useCC = true, Zone = "Temple of Selthralis" },
        [261624] = { useKick = true, useCC = true, Zone = "Temple of Selthralis" },
        [265912] = { useKick = true, useCC = false, Zone = "Temple of Selthralis" },
        [272820] = { useKick = true, useCC = false, Zone = "Temple of Selthralis" },
        [268061] = { useKick = true, useCC = false, Zone = "Temple of Selthralis" },
        [267433] = { useKick = false, useCC = true, Zone = "Motherlode" },
        [280604] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [268185] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [268129] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [269302] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [267354] = { useKick = false, useCC = true, Zone = "Motherlode" },
        [268709] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [268702] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [263215] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [263066] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [263103] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [268797] = { useKick = true, useCC = true, Zone = "Motherlode" },
        [269090] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [271579] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [263202] = { useKick = true, useCC = false, Zone = "Motherlode" },
        [262554] = { useKick = false, useCC = true, Zone = "Motherlode" },
        [258627] = { useKick = false, useCC = true, Zone = "Motherlode" },
        [267977] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [267969] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [268030] = { useKick = true, useCC = true, Zone = "Shrine of the Storm" },
        [274438] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [268309] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [268322] = { useKick = true, useCC = true, Zone = "Shrine of the Storm" },
        [268317] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [268375] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [267809] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [267818] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [268347] = { useKick = true, useCC = false, Zone = "Shrine of the Storm" },
        [276292] = { useKick = false, useCC = true, Zone = "Shrine of the Storm" },
		
		-- PvP
	    [51505] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Lava Burst
		[48181] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Haunt
		[203286] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Great Pyroblast
		[234153] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Drain Life
		[2060] = { useKick = true, useCC = false, Zone = 'PvP' },    --Heal
		[8936] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Regrowth
		[19750] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash of Light
		[82326] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Light
		[2061] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash Heal
		[64901] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Hymn of Hope
		[12051] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Evocation
		[64843] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Hymn
		[115175] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Soothing Mist
		[8936] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Regrowth
		[2061] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash Heal
		[32546] = { useKick = true, useCC = false, Zone = 'PvP' }, --  binding Heal
		[2060] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Greater Heal
		[2006] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Resurrection
		[596] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Prayer of Healing
		[19750] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash of Light
		[7328] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Redemption
		[2008] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Ancestral Spirit
		[50769] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Revive
		[82326] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Light
		[740] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Tranquillity
		[124682] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Enveloping Mist
		[64901] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Hymn of Hope
		[64843] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Hymn
		[115151] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Renewing Mist
		[115310] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Revival
		[152118] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Clarity of Will
		[186263] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Shadow Mend
    }
	
	RubimRH.List.CustomInterrupts = {}

    RubimRH.List.PvEPurge = {
        [255579] = { Zone = "Atal'Dazar" },
        [254974] = { Zone = "Atal'Dazar" },
        [256849] = { Zone = "Atal'Dazar" },
        [282098] = { Zone = "Atal'Dazar" },

        [257397] = { Zone = "Freehold" },

        [269935] = { Zone = "King's Rest" },
        [270920] = { Zone = "King's Rest" },
        [270901] = { Zone = "King's Rest" },

        [267977] = { Zone = "Shrine of Storms" },
        [276266] = { Zone = "Shrine of Storms" },
        [268030] = { Zone = "Shrine of Storms" },
        [274210] = { Zone = "Shrine of Storms" },
        [276767] = { Zone = "Shrine of Storms" },

        [256957] = { Zone = "Siege of Boralus" },
        [275826] = { Zone = "Siege of Boralus" },

        [272659] = { Zone = "Temple of Sethraliss" },
        [269896] = { Zone = "Temple of Sethraliss" },
        [265912] = { Zone = "Temple of Sethraliss" },

        [268709] = { Zone = "The Motherlode" },
        [263215] = { Zone = "The Motherlode" },
        [262947] = { Zone = "The Motherlode" },
        [262540] = { Zone = "The Motherlode" },

        [258153] = { Zone = "Tol Dagor" },
        [258133] = { Zone = "Tol Dagor" },
        [257827] = { Zone = "Tol Dagor" },
        [258938] = { Zone = "Tol Dagor" },

        [265091] = { Zone = "Underot" },
        [266201] = { Zone = "Underot" },

        [278551] = { Zone = "Waycrest Manor" },
        [265368] = { Zone = "Waycrest Manor" },
        [264834] = { Zone = "Waycrest Manor" },
    }

    RubimRH.List.PvEEnragePurge = {
        [228318] = { Zone = "Affix" },

        [262092] = { Zone = 'Motherlode' },

        [255824] = { Zone = "Atal'Dazar" },

        [257476] = { Zone = "Freehold" },
        [254476] = { Zone = "Freehold" },
        [257739] = { Zone = "Freehold" },

        [269976] = { Zone = "King's Rest" },

        [137517] = { Zone = "Shrine of Storms" },

        [259975] = { Zone = "Tol Dagor" },

        [265081] = { Zone = "Underot" },
        [266209] = { Zone = "Underot" },

        [257260] = { Zone = "Waycrest Manor" },

        [272888] = { Zone = "Siege of Boralus"},
    }

    RubimRH.List.PvEDispel = {
        [288388] = { Type = 'Magic', Zone = 'Affix', Count = 8 },
        [145206] = { Type = 'Magic', Zone = 'Proving Grounds' },

        [286988] = { Type = 'Magic', Zone = "Battle for Dazar'Alor" },
        [285879] = { Type = 'Magic', Zone = "Battle for Dazar'Alor" },
        [287167] = { Type = 'Magic', Zone = "Battle for Dazar'Alor" },
        [287626] = { Type = 'Magic', Zone = "Battle for Dazar'Alor" },
        [287456] = { Type = 'Magic', Zone = "Battle for Dazar'Alor" },
        [287295] = { Type = 'Magic', Zone = "Battle for Dazar'Alor" },
        [285878] = { Type = 'Magic', Zone = "Battle for Dazar'Alor" },
        [284470] = { Type = 'Magic', Zone = "Battle for Dazar'Alor" },

        [277072] = { Type = 'Magic', Zone = "Atal'Dazar" },
        [253562] = { Type = 'Magic', Zone = "Atal'Dazar" },
        [255582] = { Type = 'Magic', Zone = "Atal'Dazar" },
        [255041] = { Type = 'Magic', Zone = "Atal'Dazar" },
        [255371] = { Type = 'Magic', Zone = "Atal'Dazar" },
        [252781] = { Type = 'Curse', Radius = 8, Zone = "Atal'Dazar",},
        [250096] = { Type = 'Curse', Zone = "Atal'Dazar" },
        [250372] = { Type = 'Disease', Zone = "Atal'Dazar" },
        [252687] = { Type = 'Poison', Zone = "Atal'Dazar" },

        [257908] = { Type = 'Magic', Zone = "Freehold" },
        [258323] = { Type = 'Disease', Zone = "Freehold" },
        [257775] = { Type = 'Disease', Zone = "Freehold" },
        [257436] = { Type = 'Poison', Zone = "Freehold" },
        [257437] = { Type = 'Poison', Zone = "Freehold", Count = 3 },


        [270499] = { Type = 'Magic', Zone = "King's Rest" },
        [276031] = { Type = 'Curse', Zone = "King's Rest" },
        [270492] = { Type = 'Curse', Zone = "King's Rest" },
        [267763] = { Type = 'Disease', Zone = "King's Rest" },
        [270865] = { Type = 'Poison', Zone = "King's Rest" },
        [271563] = { Type = 'Poison', Zone = "King's Rest" },
        [271564] = { Type = 'Poison', Zone = "King's Rest", Count = 4 },
        [270507] = { Type = 'Poison', Zone = "King's Rest" },

        [264560] = { Type = 'Magic', Zone = "Shrine of Storms" },
        [268233] = { Type = 'Magic', Zone = "Shrine of Storms" },
        [268322] = { Type = 'Magic', Zone = "Shrine of Storms" },
        [268391] = { Type = 'Magic', Zone = "Shrine of Storms" },
        [268896] = { Type = 'Magic', Zone = "Shrine of Storms" },
        [269104] = { Type = 'Magic', Zone = "Shrine of Storms" },
        [267034] = { Type = 'Magic', Zone = "Shrine of Storms" },
        [267037] = { Type = 'Magic', Zone = "Shrine of Storms", Count = 4 },
        [260703] = { Type = 'Magic', Radius = 8, Zone = "Shrine of Storms" },
        [265880] = { Type = 'Magic', Radius = 8, Zone = "Shrine of Storms" },
        [264105] = { Type = 'Magic', Radius = 8, Zone = "Shrine of Storms" },

        [274991] = { Type = 'Magic', Radius = 10, Zone = "Siege of Boralus" },
        [272571] = { Type = 'Magic', Zone = "Siege of Boralus" },
        [274991] = { Type = 'Magic', Zone = "Siege of Boralus" },
        [257168] = { Type = 'Curse', Zone = "Siege of Boralus" },
        [275835] = { Type = 'Poison', Zone = "Siege of Boralus" },

        [268013] = { Type = 'Magic', Zone = "Temple of Sethraliss" },
        [268008] = { Type = 'Magic', Zone = "Temple of Sethraliss" },
        [269686] = { Type = 'Disease', Zone = "Temple of Sethraliss" },
        [273563] = { Type = 'Poison', Zone = "Temple of Sethraliss" },
        [272657] = { Type = 'Poison', Zone = "Temple of Sethraliss" },
        [267027] = { Type = 'Poison', Zone = "Temple of Sethraliss" },
        [272699] = { Type = 'Poison', Zone = "Temple of Sethraliss" },


        [280605] = { Type = 'Magic', Zone = "The Motherlode" },
        [262268] = { Type = 'Magic', Zone = "The Motherlode" },
        [268797] = { Type = 'Magic', Zone = "The Motherlode" },
        [259853] = { Type = 'Magic', Zone = "The Motherlode" },
        [259856] = { Type = 'Magic', Zone = "The Motherlode" },
        [263074] = { Type = 'Disease', Zone = "The Motherlode" },
        [269298] = { Type = 'Poison', Zone = "The Motherlode" },

        [265889] = { Type = 'Magic', Zone = "Tol Dagor" },
        [258128] = { Type = 'Magic', Zone = "Tol Dagor" },
        [165889] = { Type = 'Magic', Zone = "Tol Dagor" },
        [258864] = { Type = 'Magic', Zone = "Tol Dagor" },
        [257028] = { Type = 'Magic', Zone = "Tol Dagor" },
        [257777] = { Type = 'Poison', Zone = "Tol Dagor" },

        [266209] = { Type = 'Magic', Zone = "Underot" },
        [272180] = { Type = 'Magic', Zone = "Underot" },
        [272609] = { Type = 'Magic', Zone = "Underot" },
        [269301] = { Type = 'Magic', Zone = "Underot", Count = 3 },
        [265468] = { Type = 'Curse', Zone = "Underot", Count = 3 },
        [278961] = { Type = 'Disease', Zone = "Underot" },
        [259714] = { Type = 'Disease', Zone = "Underot" },

        [263891] = { Type = 'Magic', Zone = "Waycrest Manor" },
        [265352] = { Type = 'Magic', Zone = "Waycrest Manor" },
        [264378] = { Type = 'Magic', Zone = "Waycrest Manor" },
        [278551] = { Type = 'Magic', Zone = "Waycrest Manor" },
        -- Curse does low dmg and explode on party.
        -- Diseases needs players to be spreadout

    }


end)

RubimRH.List.PvPInterruptsCC = {
    [5782] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Fear
    [33786] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Cyclone
    [28272] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Pig Poly (if we have a resto Druid team mate check if out of form)
    [118] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Sheep Poly (same as above ^^)
    [61305] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Cat Poly (^^)
    [61721] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Rabbit Poly (^^)
    [61780] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Turkey Poly (^^)
    [28271] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Turtle Poly (^^)
    [51514] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Hex (Only kick if we do not have a feral Druid in our team)
    [20066] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Repentance
    [82012] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Repentance
    [605] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Dominate Mind
    [51514] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Hex
    [211004] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Hex
    [210873] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Hex
    [211015] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Hex
    [211010] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Hex
    [605] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Mind Control
    [28271] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Turtle
    [61780] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Turkey
    [61721] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Rabbit
    [61305] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Black Cat
    [28272] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Pig
}

RubimRH.List.PvPInterruptsHealing = {
    [2060] = { useKick = true, useCC = false, Zone = 'PvP' }, --Heal
    [8936] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Regrowth
    [19750] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash of Light
    [82326] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Light
    [2061] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash Heal
    [64901] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Hymn of Hope
    [12051] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Evocation
    [64843] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Hymn
    [115175] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Soothing Mist
    [8936] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Regrowth
    [2061] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash Heal
    [32546] = { useKick = true, useCC = false, Zone = 'PvP' }, --  binding Heal
    [2060] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Greater Heal
    [2006] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Resurrection
    [596] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Prayer of Healing
    [19750] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash of Light
    [7328] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Redemption
    [2008] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Ancestral Spirit
    [50769] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Revive
    [82326] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Light
    [740] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Tranquillity
    [124682] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Enveloping Mist
    [64901] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Hymn of Hope
    [64843] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Hymn
    [115151] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Renewing Mist
    [115310] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Revival
    [152118] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Clarity of Will
    [186263] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Shadow Mend
}

RubimRH.List.PvPInterruptsDMG = {
    [51505] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Lava Burst
    [48181] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Haunt
    [203286] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Great Pyroblast
    [234153] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Drain Life
}

RubimRH.List.PvPInterrupts = {
    [51505] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Lava Burst
    [48181] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Haunt
    [203286] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Great Pyroblast
    [234153] = { useKick = true, useCC = false, Zone = 'PvP' }, -- Drain Life
    [2060] = { useKick = true, useCC = false, Zone = 'PvP' },    --Heal
    [8936] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Regrowth
    [19750] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash of Light
    [82326] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Light
    [2061] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash Heal
    [64901] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Hymn of Hope
    [12051] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Evocation
    [64843] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Hymn
    [115175] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Soothing Mist
    [8936] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Regrowth
    [2061] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash Heal
    [32546] = { useKick = true, useCC = false, Zone = 'PvP' }, --  binding Heal
    [2060] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Greater Heal
    [2006] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Resurrection
    [596] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Prayer of Healing
    [19750] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Flash of Light
    [7328] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Redemption
    [2008] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Ancestral Spirit
    [50769] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Revive
    [82326] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Light
    [740] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Tranquillity
    [124682] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Enveloping Mist
    [64901] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Hymn of Hope
    [64843] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Divine Hymn
    [115151] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Renewing Mist
    [115310] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Revival
    [152118] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Clarity of Will
    [186263] = { useKick = true, useCC = false, Zone = 'PvP' }, --  Shadow Mend
}

RubimRH.List.BlockedDispels = {

}

RubimRH.List.PvPHEX = {
    [5782] = true, --  Fear
    [33786] = true, --  Cyclone
    [28272] = true, --  Pig Poly (if we have a resto Druid team mate check if out of form)
    [118] = true, --  Sheep Poly (same as above ^^)
    [61305] = true, --  Cat Poly (^^)
    [61721] = true, --  Rabbit Poly (^^)
    [61780] = true, --  Turkey Poly (^^)
    [28271] = true, --  Turtle Poly (^^)
    [51514] = true, --  Hex (Only kick if we do not have a feral Druid in our team)
    [20066] = true, --  Repentance
    [82012] = true, --  Repentance
    [605] = true, --  Dominate Mind
    [51514] = true, -- Hex
    [211004] = true, -- Hex
    [210873] = true, -- Hex
    [211015] = true, -- Hex
    [211010] = true, -- Hex
    [605] = true, -- Mind Control
    [28271] = true, -- Turtle
    [61780] = true, -- Turkey
    [61721] = true, -- Rabbit
    [61305] = true, -- Black Cat
    [28272] = true, -- Pig
}
RubimRH.List.PvPBreakableCC = {
    [118] = true, -- Sheep
    [28271] = true, -- Turtle
    [61780] = true, -- Turkey
    [61721] = true, -- Rabbit
    [61305] = true, -- Black Cat
    [28272] = true, -- Pig
    [6770] = true, -- Sap
    [20066] = true, -- Repentance
    [51514] = true, -- Hex
    [211004] = true, -- Hex
    [210873] = true, -- Hex
    [211015] = true, -- Hex
    [211010] = true, -- Hex
    [5782] = true, -- Fear
    [3355] = true, -- Freezing Trap
    [209790] = true, -- Freezing Arrow (Talent)
    [6358] = true, -- Seduction
    [2094] = true, -- Blind
    [19386] = true, -- Wyverm Sting
    [82691] = true, -- Ring of Frost
    [115078] = true, -- Paralysis
    [115268] = true, -- Mesmerize
    [5484] = true, -- Howl of Terror
    [5246] = true, -- Intimidating Shout
    [6789] = true, -- Mortal Coil
    [8122] = true, -- Psychic Scream
    [99] = true, -- Incapacitating Roar
    [1776] = true, -- Gouge
    [31661] = true, -- Dragon's Breath
    [105421] = true, -- Blinding Light
    [186387] = true, -- Bursting Shot
    [202274] = true, -- Incendiary Brew
    [207167] = true, -- Blinding Sheet
    [213691] = true, -- Scatter Shot (Honor)
    [605] = true, -- Mind Control
    [217832] = true, -- Imprison
    [339] = true, -- Entagle Roots
    [34787] = true, --Frozen Circles
}
RubimRH.List.PvPHealing = {
    [2060] = true, --Heal
    [8936] = true, --  Regrowth
    [19750] = true, --  Flash of Light
    [82326] = true, --  Divine Light
    [2061] = true, --  Flash Heal
    [64901] = true, --  Hymn of Hope
    [12051] = true, --  Evocation
    [64843] = true, --  Divine Hymn
    [115175] = true, --  Soothing Mist
    [8936] = true, --  Regrowth
    [2061] = true, --  Flash Heal
    [32546] = true, --  binding Heal
    [2060] = true, --  Greater Heal
    [2006] = true, --  Resurrection
    [596] = true, --  Prayer of Healing
    [19750] = true, --  Flash of Light
    [7328] = true, --  Redemption
    [2008] = true, --  Ancestral Spirit
    [50769] = true, --  Revive
    [82326] = true, --  Divine Light
    [740] = true, --  Tranquillity
    [124682] = true, --  Enveloping Mist
    [64901] = true, --  Hymn of Hope
    [64843] = true, --  Divine Hymn
    [115151] = true, --  Renewing Mist
    [115310] = true, --  Revival
    [152118] = true, --  Clarity of Will
    [186263] = true, --  Shadow Mend
}

--PVP Lists
RubimRH.List.PvPDMG = {
    [116] = true, --  Frostbolt
    [2948] = true, --  Scorch
    [51505] = true, --  Lava Burst
    [403] = true, --  Lightnin Bolt
    [48181] = true, --  Haunt
    [30451] = true, --  Arcane Blast
    [113092] = true, --  Frost Bomb
    [8092] = true, --  Mind Blast
    [11366] = true, --  Pyroblast
    [203286] = true, -- Great Pyroblast
    [126201] = true, --  Frost Bolt
    [15407] = true, --  Mind Flay
    [44614] = true, --  Frostfire Bolt
    [133] = true, --  Fireball
    [103103] = true, --  Malefic Grasp
    [117014] = true, --  Elemental Blast
    [118297] = true, --  Immolate
}

RubimRH.List.BlacklistLoS = {
    [44566] = true,
    [46753] = true,
    [56754] = true,
    [61463] = true,
    [72156] = true,
    [76267] = true,
    [76379] = true,
    [76585] = true,
    [76973] = true,
    [76974] = true,
    [77182] = true,
    [91331] = true,
    [91005] = true,
    [91808] = true,
    [96028] = true,
    [97259] = true,
    [97260] = true,
    [96759] = true,
    [98363] = true,
    [98696] = true,
    [99801] = true,
    [100354] = true,
    [100360] = true,
    [120436] = true,
    [118460] = true,
    [116939] = true,
    [119072] = true,
    [119397] = true,
    [119072] = true,
    [118460] = true,
    [118462] = true,
    [120368] = true,
    [122450] = true,
    [124167] = true,
    [123371] = true,
    [128154] = true,
    [128429] = true,
    [125050] = true,
    [122578] = true,
    [127231] = true,
    [127230] = true,
    [127235] = true,
    [122773] = true,
    [122778] = true,
    [128429] = true,
    [114537] = true,
    [105906] = true,
    [100362] = true,
    [98363] = true,
    [96759] = true,
    [91808] = true,
    [91005] = true,
    [131863] = true, --BIG BOY MANOR
    [137625] = true,
    [137405] = true,
    [137626] = true,
    [137614] = true,
    [137627] = true,
    [137119] = true,
    [138959] = true,
    [138530] = true,
    [140447] = true, --HENTA
    [143648] = true,
    [140393] = true, -- Tendril's Gore
    [146256] = true, -- Laminaria
    [147376] = true, -- Barrier
    [148890] = true, -- Wall of Ice
    [149907] = true, -- Wall of Ice
    [133392] = true,
    [131199] = true, --Pridze
}

RubimRH.List.BlacklistRaid = {
    [145053] = true, --Crucible, Eldritch Abomination
}

RubimRH.List.Class = {
    [1] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [2] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [3] = { Type = "Ranged", Slow = "Physical", ImmuneSlow = "False" },
    [4] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [5] = { Type = "Caster", Slow = "Magic", ImmuneSlow = "False" },
    [6] = { Type = "Melee", Slow = "Magic", ImmuneSlow = "False" },
    [7] = { Type = "Caster", Slow = "Magic", ImmuneSlow = "False" },
    [8] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },
    [9] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },
    [10] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [11] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },
    [12] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
}

RubimRH.List.Spec = {
    [71] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [72] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [73] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },

    [65] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [66] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [70] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },

    [253] = { Type = "Ranged", Slow = "Physical", ImmuneSlow = "False" },
    [254] = { Type = "Ranged", Slow = "Physical", ImmuneSlow = "False" },
    [255] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },

    [259] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [260] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [261] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },

    [256] = { Type = "Caster", Slow = "Magic", ImmuneSlow = "False" },
    [257] = { Type = "Caster", Slow = "Magic", ImmuneSlow = "False" },
    [258] = { Type = "Caster", Slow = "Magic", ImmuneSlow = "False" },

    [250] = { Type = "Melee", Slow = "Magic", ImmuneSlow = "False" },
    [251] = { Type = "Melee", Slow = "Magic", ImmuneSlow = "False" },
    [252] = { Type = "Melee", Slow = "Magic", ImmuneSlow = "False" },

    [262] = { Type = "Caster", Slow = "Magic", ImmuneSlow = "False" },
    [263] = { Type = "Melee", Slow = "Magic", ImmuneSlow = "False" },
    [264] = { Type = "Caster", Slow = "Magic", ImmuneSlow = "False" },

    [62] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },
    [63] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },
    [64] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },

    [265] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },
    [266] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },
    [267] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },

    [268] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [269] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [270] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },

    [102] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },
    [103] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [104] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [105] = { Type = "Caster", Slow = "Physical", ImmuneSlow = "False" },

    [577] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
    [581] = { Type = "Melee", Slow = "Physical", ImmuneSlow = "False" },
}

RubimRH.List.DispelType = {
    [62] = {
        ["Curse"] = true
    },
    [63] = {
        ["Curse"] = true
    },
    [64] = {
        ["Curse"] = true
    },
    [65] = {
        ["Disease"] = true,
        ["Magic"] = true,
        ["Poison"] = true,
    },
    [66] = {
        ["Disease"] = true,
        ["Poison"] = true,
    },
    [70] = {
        ["Disease"] = true,
        ["Poison"] = true,
    },
    [102] = {
        ["Curse"] = true,
        ["Poison"] = true,
    },
    [103] = {
        ["Curse"] = true,
        ["Poison"] = true,
    },
    [105] = {
        ["Curse"] = true,
        ["Magic"] = true,
        ["Poison"] = true,
    },
    [256] = {
        ["Disease"] = true,
        ["Magic"] = true,
    },
    [257] = {
        ["Disease"] = true,
        ["Magic"] = true,
    },
    [258] = {
        ["Disease"] = true,
    },
    [262] = {
        ["Curse"] = true,
    },
    [263] = {
        ["Curse"] = true,
    },
    [264] = {
        ["Curse"] = true,
        ["Magic"] = true,
    },
    [269] = {
        ["Disease"] = true,
        ["Poison"] = true,
    },
    [270] = {
        ["Disease"] = true,
        ["Magic"] = true,
        ["Poison"] = true,
    },
}

RubimRH.List.Priority = {
    [120651] = true, --GHUNN CREEP
    [136461] = true, --GHUUN CREEP
    [141851] = true, --GHUUN CREEP
    [120651] = true, --EXPLOSIVES
    [146731] = true, --ZOMBIE DUST TOTEM
    [5925] = true, --GROUNDINGTOTEM
    [61245] = true, --CAPACITOR
    [105451] = true, --COUNTER
    [53006] = true --SPIRT LINK
}

RubimRH.List.Offsets = {
    ['BoundingRadius'] = 0x15DC,
    ['CombatReach'] = 0x15E0, --BoundingRadius + 4
    ['CastingTarget'] = 0x4f8,
    ['SpecID'] = 0x1AE4,
    ['SummonedBy'] = 0x1510,
    ['CreatedBy'] = 0x1520, --SummonedBy + 10
    ['Target'] = 0x1550,
    ['Rotation'] = 0x160,
    ['DynamicFlags'] = 0xdc,
}
