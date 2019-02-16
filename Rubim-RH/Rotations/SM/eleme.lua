--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[262] = {
  TotemMastery                          = Spell(210643),
  StormkeeperBuff                       = Spell(191634),
  Stormkeeper                           = Spell(191634),
  FireElemental                         = Spell(198067),
  StormElemental                        = Spell(192249),
  ElementalBlast                        = Spell(117014),
  LavaBurst                             = Spell(51505),
  ChainLightning                        = Spell(188443),
  FlameShock                            = Spell(188389),
  FlameShockDebuff                      = Spell(188389),
  WindGustBuff                          = Spell(263806),
  Ascendance                            = Spell(114050),
  Icefury                               = Spell(210714),
  IcefuryBuff                           = Spell(210714),
  LiquidMagmaTotem                      = Spell(192222),
  Earthquake                            = Spell(61882),
  MasteroftheElements                   = Spell(16166),
  MasteroftheElementsBuff               = Spell(260734),
  LavaSurgeBuff                         = Spell(77762),
  AscendanceBuff                        = Spell(114050),
  FrostShock                            = Spell(196840),
  LavaBeam                              = Spell(114074),
  SurgeofPowerBuff                      = Spell(285514),
  NaturalHarmony                        = Spell(278697),
  SurgeofPower                          = Spell(262303),
  LightningBolt                         = Spell(188196),
  EarthShock                            = Spell(8042),
  CalltheThunder                        = Spell(260897),
  EchooftheElementals                   = Spell(275381),
  ResonanceTotemBuff                    = Spell(202192),
  WindShear                             = Spell(57994),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738)
};
local S = Spell.Shaman.Elemental;

-- Items
if not Item.Shaman then Item.Shaman = {} end
Item.Shaman.Elemental = {
  BattlePotionofIntellect          = Item(163222)
};
local I = Item.Shaman.Elemental;

-- Rotation Var
local ShouldReturn; -- Used to get the return string


local EnemyRanges = {40, 5}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end


local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, SingleTarget
  UpdateRanges()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- totem_mastery
    if S.TotemMastery:IsCastableP() then
      return S.TotemMastery:Cast()
    end
    -- earth_elemental,if=!talent.primal_elementalist.enabled
    -- stormkeeper,if=talent.stormkeeper.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)
    if S.Stormkeeper:IsCastableP() and Player:BuffDownP(S.StormkeeperBuff) and (S.Stormkeeper:IsAvailable() and ((Cache.EnemiesCount[40] - 1) < 3 or 10000000000 > 50)) then
      return S.Stormkeeper:Cast()
    end
    -- fire_elemental,if=!talent.storm_elemental.enabled
    if S.FireElemental:IsCastableP() and RubimRH.CDsON() and (not S.StormElemental:IsAvailable()) then
      return S.FireElemental, Settings.Elemental.GCDasOffGCD.FireElemental:Cast()
    end
    -- storm_elemental,if=talent.storm_elemental.enabled
    if S.StormElemental:IsCastableP() and RubimRH.CDsON() and (S.StormElemental:IsAvailable()) then
      return S.StormElemental, Settings.Elemental.GCDasOffGCD.StormElemental:Cast()
    end
    -- potion
    -- elemental_blast,if=talent.elemental_blast.enabled&spell_targets.chain_lightning<3
    if S.ElementalBlast:IsCastableP() and (S.ElementalBlast:IsAvailable() and Cache.EnemiesCount[40] < 3) then
      return S.ElementalBlast:Cast()
    end
    -- lava_burst,if=!talent.elemental_blast.enabled&spell_targets.chain_lightning<3
    if S.LavaBurst:IsCastableP() and (not S.ElementalBlast:IsAvailable() and Cache.EnemiesCount[40] < 3) then
      return S.LavaBurst:Cast()
    end
    -- chain_lightning,if=spell_targets.chain_lightning>2
    if S.ChainLightning:IsCastableP() and (Cache.EnemiesCount[40] > 2) then
      return S.ChainLightning:Cast()
    end
  end
  Aoe = function()
    -- stormkeeper,if=talent.stormkeeper.enabled
    if S.Stormkeeper:IsCastableP() and (S.Stormkeeper:IsAvailable()) then
      return S.Stormkeeper:Cast()
    end
    -- flame_shock,target_if=refreshable&(spell_targets.chain_lightning<(5-!talent.totem_mastery.enabled)|!talent.storm_elemental.enabled&(cooldown.fire_elemental.remains>(120+14*spell_haste)|cooldown.fire_elemental.remains<(24-14*spell_haste)))&(!talent.storm_elemental.enabled|cooldown.storm_elemental.remains<120|spell_targets.chain_lightning=3&buff.wind_gust.stack<14)
    if S.FlameShock:IsCastableP() and TargetUnit:DebuffRefreshableCP(S.FlameShockDebuff) and (Cache.EnemiesCount[40] < (5 - num(not S.TotemMastery:IsAvailable())) or not S.StormElemental:IsAvailable() and (S.FireElemental:CooldownRemainsP() > (120 + 14 * Player:SpellHaste()) or S.FireElemental:CooldownRemainsP() < (24 - 14 * Player:SpellHaste()))) and (not S.StormElemental:IsAvailable() or S.StormElemental:CooldownRemainsP() < 120 or Cache.EnemiesCount[40] == 3 and Player:BuffStackP(S.WindGustBuff) < 14) then
        return S.FlameShock:Cast()
	end
    -- ascendance,if=talent.ascendance.enabled&(talent.storm_elemental.enabled&cooldown.storm_elemental.remains<120&cooldown.storm_elemental.remains>15|!talent.storm_elemental.enabled)&(!talent.icefury.enabled|!buff.icefury.up&!cooldown.icefury.up)
    if S.Ascendance:IsCastableP() and RubimRH.CDsON() and (S.Ascendance:IsAvailable() and (S.StormElemental:IsAvailable() and S.StormElemental:CooldownRemainsP() < 120 and S.StormElemental:CooldownRemainsP() > 15 or not S.StormElemental:IsAvailable()) and (not S.Icefury:IsAvailable() or not Player:BuffP(S.IcefuryBuff) and not S.Icefury:CooldownUpP())) then
      return S.Ascendance:Cast()
    end
    -- liquid_magma_totem,if=talent.liquid_magma_totem.enabled
    if S.LiquidMagmaTotem:IsCastableP() and (S.LiquidMagmaTotem:IsAvailable()) then
      return S.LiquidMagmaTotem:Cast()
    end
    -- earthquake,if=!talent.master_of_the_elements.enabled|buff.stormkeeper.up|maelstrom>=(100-4*spell_targets.chain_lightning)|buff.master_of_the_elements.up|spell_targets.chain_lightning>3
    if S.Earthquake:IsCastableP() and (not S.MasteroftheElements:IsAvailable() or Player:BuffP(S.StormkeeperBuff) or Player:Maelstrom() >= (100 - 4 * Cache.EnemiesCount[40]) or Player:BuffP(S.MasteroftheElementsBuff) or Cache.EnemiesCount[40] > 3) then
      return S.Earthquake:Cast()
    end
    -- chain_lightning,if=buff.stormkeeper.remains<3*gcd*buff.stormkeeper.stack
    if S.ChainLightning:IsCastableP() and (Player:BuffRemainsP(S.StormkeeperBuff) < 3 * Player:GCD() * Player:BuffStackP(S.StormkeeperBuff)) then
      return S.ChainLightning:Cast()
    end
    -- lava_burst,if=buff.lava_surge.up&spell_targets.chain_lightning<4&(!talent.storm_elemental.enabled|cooldown.storm_elemental.remains<120)&dot.flame_shock.ticking
    if S.LavaBurst:IsCastableP() and (Player:BuffP(S.LavaSurgeBuff) and Cache.EnemiesCount[40] < 4 and (not S.StormElemental:IsAvailable() or S.StormElemental:CooldownRemainsP() < 120) and Target:DebuffP(S.FlameShockDebuff)) then
      return S.LavaBurst:Cast()
    end
    -- icefury,if=spell_targets.chain_lightning<4&!buff.ascendance.up
    if S.Icefury:IsCastableP() and (Cache.EnemiesCount[40] < 4 and not Player:BuffP(S.AscendanceBuff)) then
      return S.Icefury:Cast()
    end
    -- frost_shock,if=spell_targets.chain_lightning<4&buff.icefury.up&!buff.ascendance.up
    if S.FrostShock:IsCastableP() and (Cache.EnemiesCount[40] < 4 and Player:BuffP(S.IcefuryBuff) and not Player:BuffP(S.AscendanceBuff)) then
      return S.FrostShock:Cast()
    end
    -- elemental_blast,if=talent.elemental_blast.enabled&spell_targets.chain_lightning<4&(!talent.storm_elemental.enabled|cooldown.storm_elemental.remains<120)
    if S.ElementalBlast:IsCastableP() and (S.ElementalBlast:IsAvailable() and Cache.EnemiesCount[40] < 4 and (not S.StormElemental:IsAvailable() or S.StormElemental:CooldownRemainsP() < 120)) then
      return S.ElementalBlast:Cast()
    end
    -- lava_beam,if=talent.ascendance.enabled
    if S.LavaBeam:IsCastableP() and (S.Ascendance:IsAvailable()) then
      return S.LavaBeam:Cast()
    end
    -- chain_lightning
    if S.ChainLightning:IsCastableP() then
      return S.ChainLightning:Cast()
    end
    -- lava_burst,moving=1,if=talent.ascendance.enabled
    if S.LavaBurst:IsCastableP() and Player:IsMoving() and (S.Ascendance:IsAvailable()) then
      return S.LavaBurst:Cast()
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and Player:IsMoving() and TargetUnit:DebuffRefreshableCP(S.FlameShockDebuff) then
      return S.FlameShock:Cast()
    end
    -- frost_shock,moving=1
    if S.FrostShock:IsCastableP() and Player:IsMoving() then
      return S.FrostShock:Cast()
    end
  end
  SingleTarget = function()
    -- flame_shock,if=(!ticking|talent.storm_elemental.enabled&cooldown.storm_elemental.remains<2*gcd|dot.flame_shock.remains<=gcd|talent.ascendance.enabled&dot.flame_shock.remains<(cooldown.ascendance.remains+buff.ascendance.duration)&cooldown.ascendance.remains<4&(!talent.storm_elemental.enabled|talent.storm_elemental.enabled&cooldown.storm_elemental.remains<120))&buff.wind_gust.stack<14&!buff.surge_of_power.up
    if S.FlameShock:IsCastableP() and ((not Target:DebuffP(S.FlameShockDebuff) or S.StormElemental:IsAvailable() and S.StormElemental:CooldownRemainsP() < 2 * Player:GCD() or Target:DebuffRemainsP(S.FlameShockDebuff) <= Player:GCD() or S.Ascendance:IsAvailable() and Target:DebuffRemainsP(S.FlameShockDebuff) < (S.Ascendance:CooldownRemainsP() + S.AscendanceBuff:BaseDuration()) and S.Ascendance:CooldownRemainsP() < 4 and (not S.StormElemental:IsAvailable() or S.StormElemental:IsAvailable() and S.StormElemental:CooldownRemainsP() < 120)) and Player:BuffStackP(S.WindGustBuff) < 14 and not Player:BuffP(S.SurgeofPowerBuff)) then
      return S.FlameShock:Cast()
    end
    -- ascendance,if=talent.ascendance.enabled&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&(!talent.storm_elemental.enabled|cooldown.storm_elemental.remains>120)&(!talent.icefury.enabled|!buff.icefury.up&!cooldown.icefury.up)
    if S.Ascendance:IsCastableP() and RubimRH.CDsON() and (S.Ascendance:IsAvailable() and (HL.CombatTime() >= 60 or Player:HasHeroism()) and S.LavaBurst:CooldownRemainsP() > 0 and (not S.StormElemental:IsAvailable() or S.StormElemental:CooldownRemainsP() > 120) and (not S.Icefury:IsAvailable() or not Player:BuffP(S.IcefuryBuff) and not S.Icefury:CooldownUpP())) then
      return S.Ascendance, Settings.Elemental.GCDasOffGCD.Ascendance:Cast()
    end
    -- elemental_blast,if=talent.elemental_blast.enabled&(talent.master_of_the_elements.enabled&buff.master_of_the_elements.up&maelstrom<60|!talent.master_of_the_elements.enabled)&(!(cooldown.storm_elemental.remains>120&talent.storm_elemental.enabled)|azerite.natural_harmony.rank=3&buff.wind_gust.stack<14)
    if S.ElementalBlast:IsCastableP() and (S.ElementalBlast:IsAvailable() and (S.MasteroftheElements:IsAvailable() and Player:BuffP(S.MasteroftheElementsBuff) and Player:Maelstrom() < 60 or not S.MasteroftheElements:IsAvailable()) and (not (S.StormElemental:CooldownRemainsP() > 120 and S.StormElemental:IsAvailable()) or S.NaturalHarmony:AzeriteRank() == 3 and Player:BuffStackP(S.WindGustBuff) < 14)) then
      return S.ElementalBlast:Cast()
    end
    -- stormkeeper,if=talent.stormkeeper.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)&(!talent.surge_of_power.enabled|buff.surge_of_power.up|maelstrom>=44)
    if S.Stormkeeper:IsCastableP() and (S.Stormkeeper:IsAvailable() and ((Cache.EnemiesCount[40] - 1) < 3 or 10000000000 > 50) and (not S.SurgeofPower:IsAvailable() or Player:BuffP(S.SurgeofPowerBuff) or Player:Maelstrom() >= 44)) then
      return S.Stormkeeper:Cast()
    end
    -- liquid_magma_totem,if=talent.liquid_magma_totem.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)
    if S.LiquidMagmaTotem:IsCastableP() and (S.LiquidMagmaTotem:IsAvailable() and ((Cache.EnemiesCount[40] - 1) < 3 or 10000000000 > 50)) then
      return S.LiquidMagmaTotem:Cast()
    end
    -- lightning_bolt,if=buff.stormkeeper.up&spell_targets.chain_lightning<2&(buff.master_of_the_elements.up&!talent.surge_of_power.enabled|buff.surge_of_power.up)
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.StormkeeperBuff) and Cache.EnemiesCount[40] < 2 and (Player:BuffP(S.MasteroftheElementsBuff) and not S.SurgeofPower:IsAvailable() or Player:BuffP(S.SurgeofPowerBuff))) then
      return S.LightningBolt:Cast()
    end
    -- earthquake,if=active_enemies>1&spell_targets.chain_lightning>1&(!talent.surge_of_power.enabled|!dot.flame_shock.refreshable|cooldown.storm_elemental.remains>120)&(!talent.master_of_the_elements.enabled|buff.master_of_the_elements.up|maelstrom>=92)
    if S.Earthquake:IsCastableP() and (Cache.EnemiesCount[40] > 1 and Cache.EnemiesCount[40] > 1 and (not S.SurgeofPower:IsAvailable() or not Target:DebuffRefreshableCP(S.FlameShockDebuff) or S.StormElemental:CooldownRemainsP() > 120) and (not S.MasteroftheElements:IsAvailable() or Player:BuffP(S.MasteroftheElementsBuff) or Player:Maelstrom() >= 92)) then
      return S.Earthquake:Cast()
    end
    -- earth_shock,if=!buff.surge_of_power.up&talent.master_of_the_elements.enabled&(buff.master_of_the_elements.up|maelstrom>=92+30*talent.call_the_thunder.enabled|buff.stormkeeper.up&active_enemies<2)|!talent.master_of_the_elements.enabled&(buff.stormkeeper.up|maelstrom>=90+30*talent.call_the_thunder.enabled|!(cooldown.storm_elemental.remains>120&talent.storm_elemental.enabled)&expected_combat_length-time-cooldown.storm_elemental.remains-150*floor((expected_combat_length-time-cooldown.storm_elemental.remains)%150)>=30*(1+(azerite.echo_of_the_elementals.rank>=2)))
    if S.EarthShock:IsCastableP() and (not Player:BuffP(S.SurgeofPowerBuff) and S.MasteroftheElements:IsAvailable() and (Player:BuffP(S.MasteroftheElementsBuff) or Player:Maelstrom() >= 92 + 30 * num(S.CalltheThunder:IsAvailable()) or Player:BuffP(S.StormkeeperBuff) and Cache.EnemiesCount[40] < 2) or not S.MasteroftheElements:IsAvailable() and (Player:BuffP(S.StormkeeperBuff) or Player:Maelstrom() >= 90 + 30 * num(S.CalltheThunder:IsAvailable()) or not (S.StormElemental:CooldownRemainsP() > 120 and S.StormElemental:IsAvailable()) and expected_combat_length - HL.CombatTime() - S.StormElemental:CooldownRemainsP() - 150 * math.floor ((expected_combat_length - HL.CombatTime() - S.StormElemental:CooldownRemainsP()) / 150) >= 30 * (1 + num((S.EchooftheElementals:AzeriteRank() >= 2))))) then
      return S.EarthShock:Cast()
    end
    -- earth_shock,if=talent.surge_of_power.enabled&!buff.surge_of_power.up&cooldown.lava_burst.remains<=gcd&(!talent.storm_elemental.enabled&!(cooldown.fire_elemental.remains>120)|talent.storm_elemental.enabled&!(cooldown.storm_elemental.remains>120))
    if S.EarthShock:IsCastableP() and (S.SurgeofPower:IsAvailable() and not Player:BuffP(S.SurgeofPowerBuff) and S.LavaBurst:CooldownRemainsP() <= Player:GCD() and (not S.StormElemental:IsAvailable() and not (S.FireElemental:CooldownRemainsP() > 120) or S.StormElemental:IsAvailable() and not (S.StormElemental:CooldownRemainsP() > 120))) then
      return S.EarthShock:Cast()
    end
    -- lightning_bolt,if=cooldown.storm_elemental.remains>120&talent.storm_elemental.enabled
    if S.LightningBolt:IsCastableP() and (S.StormElemental:CooldownRemainsP() > 120 and S.StormElemental:IsAvailable()) then
      return S.LightningBolt:Cast()
    end
    -- frost_shock,if=talent.icefury.enabled&talent.master_of_the_elements.enabled&buff.icefury.up&buff.master_of_the_elements.up
    if S.FrostShock:IsCastableP() and (S.Icefury:IsAvailable() and S.MasteroftheElements:IsAvailable() and Player:BuffP(S.IcefuryBuff) and Player:BuffP(S.MasteroftheElementsBuff)) then
      return S.FrostShock:Cast()
    end
    -- lava_burst,if=buff.ascendance.up
    if S.LavaBurst:IsCastableP() and (Player:BuffP(S.AscendanceBuff)) then
      return S.LavaBurst:Cast()
    end
    -- flame_shock,target_if=refreshable&active_enemies>1&buff.surge_of_power.up
    if S.FlameShock:IsCastableP() and TargetUnit:DebuffRefreshableCP(S.FlameShockDebuff) and Cache.EnemiesCount[40] > 1 and Player:BuffP(S.SurgeofPowerBuff) then
      return S.FlameShock:Cast()
    end
    -- lava_burst,if=talent.storm_elemental.enabled&cooldown_react&buff.surge_of_power.up&(expected_combat_length-time-cooldown.storm_elemental.remains-150*floor((expected_combat_length-time-cooldown.storm_elemental.remains)%150)<30*(1+(azerite.echo_of_the_elementals.rank>=2))|(1.16*(expected_combat_length-time)-cooldown.storm_elemental.remains-150*floor((1.16*(expected_combat_length-time)-cooldown.storm_elemental.remains)%150))<(expected_combat_length-time-cooldown.storm_elemental.remains-150*floor((expected_combat_length-time-cooldown.storm_elemental.remains)%150)))
    if S.LavaBurst:IsCastableP() and (S.StormElemental:IsAvailable() and S.LavaBurst:CooldownUpP() and Player:BuffP(S.SurgeofPowerBuff) and (expected_combat_length - HL.CombatTime() - S.StormElemental:CooldownRemainsP() - 150 * math.floor ((expected_combat_length - HL.CombatTime() - S.StormElemental:CooldownRemainsP()) / 150) < 30 * (1 + num((S.EchooftheElementals:AzeriteRank() >= 2))) or (1.16 * (expected_combat_length - HL.CombatTime()) - S.StormElemental:CooldownRemainsP() - 150 * math.floor ((1.16 * (expected_combat_length - HL.CombatTime()) - S.StormElemental:CooldownRemainsP()) / 150)) < (expected_combat_length - HL.CombatTime() - S.StormElemental:CooldownRemainsP() - 150 * math.floor ((expected_combat_length - HL.CombatTime() - S.StormElemental:CooldownRemainsP()) / 150)))) then
      return S.LavaBurst:Cast()
    end
    -- lava_burst,if=!talent.storm_elemental.enabled&cooldown_react&buff.surge_of_power.up&(expected_combat_length-time-cooldown.fire_elemental.remains-150*floor((expected_combat_length-time-cooldown.fire_elemental.remains)%150)<30*(1+(azerite.echo_of_the_elementals.rank>=2))|(1.16*(expected_combat_length-time)-cooldown.fire_elemental.remains-150*floor((1.16*(expected_combat_length-time)-cooldown.fire_elemental.remains)%150))<(expected_combat_length-time-cooldown.fire_elemental.remains-150*floor((expected_combat_length-time-cooldown.fire_elemental.remains)%150)))
    if S.LavaBurst:IsCastableP() and (not S.StormElemental:IsAvailable() and S.LavaBurst:CooldownUpP() and Player:BuffP(S.SurgeofPowerBuff) and (expected_combat_length - HL.CombatTime() - S.FireElemental:CooldownRemainsP() - 150 * math.floor ((expected_combat_length - HL.CombatTime() - S.FireElemental:CooldownRemainsP()) / 150) < 30 * (1 + num((S.EchooftheElementals:AzeriteRank() >= 2))) or (1.16 * (expected_combat_length - HL.CombatTime()) - S.FireElemental:CooldownRemainsP() - 150 * math.floor ((1.16 * (expected_combat_length - HL.CombatTime()) - S.FireElemental:CooldownRemainsP()) / 150)) < (expected_combat_length - HL.CombatTime() - S.FireElemental:CooldownRemainsP() - 150 * math.floor ((expected_combat_length - HL.CombatTime() - S.FireElemental:CooldownRemainsP()) / 150)))) then
      return S.LavaBurst:Cast()
    end
    -- lightning_bolt,if=buff.surge_of_power.up
    if S.LightningBolt:IsCastableP() and (Player:BuffP(S.SurgeofPowerBuff)) then
      return S.LightningBolt:Cast()
    end
    -- lava_burst,if=cooldown_react
    if S.LavaBurst:IsCastableP() and (S.LavaBurst:CooldownUpP()) then
      return S.LavaBurst:Cast()
    end
    -- flame_shock,target_if=refreshable&!buff.surge_of_power.up
    if S.FlameShock:IsCastableP() and TargetUnit:DebuffRefreshableCP(S.FlameShockDebuff) and not Player:BuffP(S.SurgeofPowerBuff) then
      return S.FlameShock:Cast()
    end
    -- totem_mastery,if=talent.totem_mastery.enabled&(buff.resonance_totem.remains<6|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15))
    if S.TotemMastery:IsCastableP() and (S.TotemMastery:IsAvailable() and (Player:BuffRemainsP(S.ResonanceTotemBuff) < 6 or (Player:BuffRemainsP(S.ResonanceTotemBuff) < (S.AscendanceBuff:BaseDuration() + S.Ascendance:CooldownRemainsP()) and S.Ascendance:CooldownRemainsP() < 15))) then
      return S.TotemMastery:Cast()
    end
    -- frost_shock,if=talent.icefury.enabled&buff.icefury.up&(buff.icefury.remains<gcd*4*buff.icefury.stack|buff.stormkeeper.up|!talent.master_of_the_elements.enabled)
    if S.FrostShock:IsCastableP() and (S.Icefury:IsAvailable() and Player:BuffP(S.IcefuryBuff) and (Player:BuffRemainsP(S.IcefuryBuff) < Player:GCD() * 4 * Player:BuffStackP(S.IcefuryBuff) or Player:BuffP(S.StormkeeperBuff) or not S.MasteroftheElements:IsAvailable())) then
      return S.FrostShock:Cast()
    end
    -- icefury,if=talent.icefury.enabled
    if S.Icefury:IsCastableP() and (S.Icefury:IsAvailable()) then
      return S.Icefury:Cast()
    end
    -- lightning_bolt
    if S.LightningBolt:IsCastableP() then
      return S.LightningBolt:Cast()
    end
    -- flame_shock,moving=1,target_if=refreshable
    if S.FlameShock:IsCastableP() and Player:IsMoving() and TargetUnit:DebuffRefreshableCP(S.FlameShockDebuff) then
      return S.FlameShock:Cast()
    end
    -- flame_shock,moving=1,if=movement.distance>6
    if S.FlameShock:IsCastableP() and Player:IsMoving() and (movement.distance > 6) then
      return S.FlameShock:Cast()
    end
    -- frost_shock,moving=1
    if S.FrostShock:IsCastableP() and Player:IsMoving() then
      return S.FrostShock:Cast()
    end
  end
  -- call precombat
  if not Player:AffectingCombat() and not Player:IsCasting() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if RubimRH.TargetIsValid() then
    -- bloodlust,if=azerite.ancestral_resonance.enabled
    -- potion,if=expected_combat_length-time<30|cooldown.fire_elemental.remains>120|cooldown.storm_elemental.remains>120
    -- wind_shear
    if S.WindShear:IsCastableP() and Target:IsInterruptible() and Settings.General.InterruptEnabled then
      return S.WindShear:Cast()
    end
    -- totem_mastery,if=talent.totem_mastery.enabled&buff.resonance_totem.remains<2
    if S.TotemMastery:IsCastableP() and (S.TotemMastery:IsAvailable() and Player:BuffRemainsP(S.ResonanceTotemBuff) < 2) then
      return S.TotemMastery:Cast()
    end
    -- fire_elemental,if=!talent.storm_elemental.enabled
    if S.FireElemental:IsCastableP() and RubimRH.CDsON() and (not S.StormElemental:IsAvailable()) then
      return S.FireElemental:Cast()
    end
    -- storm_elemental,if=talent.storm_elemental.enabled&(!talent.icefury.enabled|!buff.icefury.up&!cooldown.icefury.up)
    if S.StormElemental:IsCastableP() and RubimRH.CDsON() and (S.StormElemental:IsAvailable() and (not S.Icefury:IsAvailable() or not Player:BuffP(S.IcefuryBuff) and not S.Icefury:CooldownUpP())) then
      return S.StormElemental:Cast()
    end
    -- earth_elemental,if=!talent.primal_elementalist.enabled|talent.primal_elementalist.enabled&(cooldown.fire_elemental.remains<120&!talent.storm_elemental.enabled|cooldown.storm_elemental.remains<120&talent.storm_elemental.enabled)
    -- use_items
    -- blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
    if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
      return S.BloodFury:Cast()
    end
    -- berserking,if=!talent.ascendance.enabled|buff.ascendance.up
    if S.Berserking:IsCastableP() and RubimRH.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff)) then
      return S.Berserking:Cast()
    end
    -- fireblood,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
    if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
      return S.Fireblood:Cast()
    end
    -- ancestral_call,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
    if S.AncestralCall:IsCastableP() and RubimRH.CDsON() and (not S.Ascendance:IsAvailable() or Player:BuffP(S.AscendanceBuff) or S.Ascendance:CooldownRemainsP() > 50) then
      return S.AncestralCall:Cast()
    end
    -- run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
    if (Cache.EnemiesCount[40] > 2) then
      return Aoe();
    end
    -- run_action_list,name=single_target
    if (true) then
      return SingleTarget();
    end
  return 0, 135328
end

RubimRH.Rotation.SetAPL(262, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(262, PASSIVE);
