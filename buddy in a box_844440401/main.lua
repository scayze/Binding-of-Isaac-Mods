local BuddyBox = RegisterMod( "Buddy in a box",1 );
local familiarItem = Isaac.GetItemIdByName("Buddy in a box")
local familiarEntity = Isaac.GetEntityTypeByName("BoxBuddy")
local familiarEntityVariant = Isaac.GetEntityVariantByName("BoxBuddy")


--These effects will always happen

Movement = {
	FLAG_NO_EFFECT = 0,
	FLAG_SPECTRAL = 1,
	FLAG_PIERCING = 1<<1,
	FLAG_HOMING = 1<<2,
	FLAG_COAL = 1<<6,
	FLAG_PARASITE = 1<<7,
	FLAG_MAGIC_MIRROR = 1<<8,
	FLAG_WIGGLE_WORM = 1<<10,
	FLAG_TINY_PLANET = 1<<16,
	FLAG_ANTI_GRAVITY = 1<<17,
	FLAG_CRICKETS_BODY = 1<<18,
	FLAG_RUBBER_CEMENT = 1<<19,
	FLAG_PROPTOSIS = 1<<21,
	FLAG_STRANGE_ATTRACTOR = 1<<23,
	FLAG_PULSE_WORM = 1<<25,
	FLAG_RING_WORM = 1<<26,
	FLAG_FLAT_WORM = 1<<27,
	FLAG_HOOK_WORM = 1<<31,
	FLAG_CONTINUUM = 1<<36,
	FLAG_TOXIC_LIQUID = 1<<43,
	FLAG_OUROBOROS_WORM = 1<<44,
	FLAG_SPLIT = 1<<49,
	FLAG_JACOBS_LADDER = 1<<53,
}

-- And these should only shoot every so often

Effects = {
	FLAG_NO_EFFECT = 0,
	FLAG_SLOWING = 1<<3,
	FLAG_POISONING = 1<<4,
	FLAG_FREEZING = 1<<5,
	FLAG_POLYPHEMUS = 1<<9,
	FLAG_IPECAC = 1<<12,
	FLAG_CHARMING = 1<<13,
	FLAG_CONFUSING = 1<<14,
	FLAG_ENEMIES_DROP_HEARTS = 1<<15,
	FLAG_FEAR = 1<<20,
	FLAG_FIRE = 1<<22,
	FLAG_GODHEAD = 1<<32,
	FLAG_EXPLOSIVO = 1<<35,
	FLAG_HOLY_LIGHT = 1<<37,
	FLAG_KEEPER_HEAD = 1<<38,
	FLAG_ENEMIES_DROP_BLACK_HEARTS = 1<<39,
	FLAG_ENEMIES_DROP_BLACK_HEARTS2 = 1<<40,
	FLAG_GODS_FLESH = 1<<41,
	FLAG_GLAUCOMA = 1<<45,
	FLAG_BOOGERS = 1<<46,
	FLAG_PARASITOID = 1<<47,
	FLAG_DEADSHOT = 1<<50,
	FLAG_MIDAS = 1<<51,
	FLAG_EUTHANASIA = 1<<52,
	FLAG_LITTLE_HORN = 1<<54,
	FLAG_GHOST_PEPPER = 1<<55
}

--Tear Variants
TearVariant = {
  BLUE = 0,
  BLOOD = 1,
  TOOTH = 2,
  METALLIC = 3,
  FIRE_MIND = 5,
  DARK_MATTER = 6,
  MYSTERIOUS = 7,
  SCHYTHE = 8,
  LOST_CONTACT = 10,
  CUPID_BLUE = 11,
  NAIL = 13,
  PUPULA = 14,
  PUPULA_BLOOD = 15,
  GODS_FLESH = 16,
  DIAMOND = 18,
  EXPLOSIVO = 19,
  COIN = 20,
  STONE = 22,
  NAIL_BLOOD = 23,
  GLAUCOMA = 24,
  BOOGER = 26,
  EGG = 27,
  BONE = 29,
  BLACK_TOOTH = 30,
  NEEDLE = 31,
  BELIAL = 32
}

local teardelay = 30
local had = false
local sprites = nil 
	--FDS
	sprites = {"000_baby_spider.png","001isaac_2p.png","001_baby_love.png","002_baby_bloat.png","003_baby_water.png","004_baby_psy.png","005_baby_cursed.png","006_baby_troll.png","007_baby_ybab.png","008_baby_cockeyed.png","009_baby_host.png","010_baby_lost.png","011_baby_cute.png","012_baby_crow.png","013_baby_shadow.png","014_baby_glass.png","015_baby_gold.png","016_baby_cy.png","017_baby_bean.png","018_baby_mag.png","019_baby_wrath.png","020_baby_wrapped.png","021_baby_begotten.png","022_baby_dead.png","023_baby_fighting.png","024_baby_0.png","025_baby_glitch.png","026_baby_magnet.png","027_baby_black.png","027_baby_steven.png","028_baby_monocle.png","028_baby_red.png","029_baby_belial.png","029_baby_white.png","030_baby_blue.png","030_baby_monstro.png","031_baby_fez.png","031_baby_rage.png","032_baby_cry.png","032_baby_meatboy.png","033_baby_skull.png","033_baby_yellow.png","034_baby_conjoined.png","034_baby_long.png","035_baby_green.png","035_baby_skinny.png","036_baby_lil.png","036_baby_spider.png","037_baby_big.png","037_baby_shopkeeper.png","038_baby_brown.png","038_baby_fancy.png","039_baby_chubby.png","039_baby_noose.png","040_baby_cyclops.png","040_baby_hive.png","041_baby_buddy.png","041_baby_isaac.png","042_baby_colorful.png","042_baby_plug.png","043_baby_drool.png","043_baby_whore.png","044_baby_cracked.png","044_baby_wink.png","045_baby_dripping.png","045_baby_pox.png","046_baby_blinding.png","046_baby_onion.png","047_baby_sucky.png","047_baby_zipper.png","048_baby_buckteeth.png","048_baby_dark.png","049_baby_beard.png","049_baby_picky.png","050_baby_hanger.png","050_baby_revenge.png","051_baby_belial.png","051_baby_vampire.png","052_baby_sale.png","052_baby_tilt.png","053_baby_bawl.png","053_baby_goatbaby.png","054_baby_lemon.png","054_baby_super greedbaby.png","055_baby_mort.png","055_baby_tooth.png","056_baby_apollyon.png","056_baby_haunt.png","057_baby_bigeyes.png","057_baby_tooth.png","058_baby_haunt.png","058_baby_sleep.png","059_baby_bigeyes.png","059_baby_zombie.png","060_baby_goat.png","060_baby_sleep.png","061_baby_butthole.png","061_baby_zombie.png","062_baby_eyepatch.png","062_baby_goat.png","063_baby_bloodeyes.png","063_baby_butthole.png","064_baby_eyepatch.png","064_baby_mustache.png","065_baby_bloodeyes.png","065_baby_spittle.png","066_baby_brain.png","066_baby_mustache.png","067_baby_spittle.png","067_baby_threeeyes.png","068_baby_brain.png","068_baby_viridian.png","069_baby_blockhead.png","069_baby_threeeyes.png","070_baby_viridian.png","070_baby_worm.png","071_baby_blockhead.png","071_baby_lowface.png","072_baby_alienhominid.png","072_baby_worm.png","073_baby_bomb.png","073_baby_lowface.png","074_baby_alienhominid.png","074_baby_video.png","075_baby_bomb.png","075_baby_parasite.png","076_baby_derp.png","076_baby_video.png","077_baby_lobotomy.png","077_baby_parasite.png","078_baby_choke.png","078_baby_derp.png","079_baby_lobotomy.png","079_baby_scream.png","080_baby_choke.png","080_baby_gurdy.png","081_baby_ghoul.png","081_baby_scream.png","082_baby_goatee.png","082_baby_gurdy.png","083_baby_ghoul.png","083_baby_shades.png","084_baby_goatee.png","084_baby_statue.png","085_baby_bloodsucker.png","085_baby_shades.png","086_baby_bandaid.png","086_baby_statue.png","087_baby_bloodsucker.png","087_baby_eyebrows.png","088_baby_bandaid.png","088_baby_nerd.png","089_baby_boss.png","089_baby_eyebrows.png","090_baby_nerd.png","090_baby_turd.png","091_baby_boss.png","091_baby_o.png","092_baby_squareeyes.png","092_baby_turd.png","093_baby_o.png","093_baby_teeth.png","094_baby_frown.png","094_baby_squareeyes.png","095_baby_teeth.png","095_baby_tongue.png","096_baby_frown.png","096_baby_halfhead.png","097_baby_makeup.png","097_baby_tongue.png","098_baby_ed.png","098_baby_halfhead.png","099_baby_d.png","099_baby_makeup.png","100_baby_ed.png","100_baby_guppy.png","101_baby_d.png","101_baby_puke.png","102_baby_dumb.png","102_baby_guppy.png","103_baby_lipstick.png","103_baby_puke.png","104_baby_aether.png","104_baby_dumb.png","105_baby_brownie.png","105_baby_lipstick.png","106_baby_aether.png","106_baby_vvvvvv.png","107_baby_brownie.png","107_baby_nosferatu.png","108_baby_pubic.png","108_baby_vvvvvv.png","109_baby_eyemouth.png","109_baby_nosferatu.png","110_baby_pubic.png","110_baby_weirdo.png","111_baby_eyemouth.png","111_baby_v.png","112_baby_strangemouth.png","112_baby_weirdo.png","113_baby_masked.png","113_baby_v.png","114_baby_cyber.png","114_baby_strangemouth.png","115_baby_axewound.png","115_baby_masked.png","116_baby_cyber.png","116_baby_statue.png","117_baby_axewound.png","117_baby_grin.png","118_baby_statue.png","118_baby_upset.png","119_baby_grin.png","119_baby_plastic.png","120_baby_monochrome.png","120_baby_upset.png","121_baby_onetooth.png","121_baby_plastic.png","122_baby_monochrome.png","122_baby_tusks.png","123_baby_hopeless.png","123_baby_onetooth.png","124_baby_bigmouth.png","124_baby_tusks.png","125_baby_hopeless.png","125_baby_peeeyes.png","126_baby_bigmouth.png","126_baby_earwig.png","127_baby_ninkumpoop.png","127_baby_peeeyes.png","128_baby_earwig.png","128_baby_strangeshape.png","129_baby_bugeyed.png","129_baby_ninkumpoop.png","130_baby_freaky.png","130_baby_strangeshape.png","131_baby_bugeyed.png","131_baby_crooked.png","132_baby_freaky.png","132_baby_spiderlegs.png","133_baby_crooked.png","133_baby_smiling.png","134_baby_spiderlegs.png","134_baby_tears.png","135_baby_bowling.png","135_baby_smiling.png","136_baby_mohawk.png","136_baby_tears.png","137_baby_bowling.png","137_baby_rottenmeat.png","138_baby_mohawk.png","138_baby_noarms.png","139_baby_rottenmeat.png","139_baby_twin2.png","140_baby_noarms.png","140_baby_uglygirl.png","141_baby_chompers.png","141_baby_twin2.png","142_baby_camillojr.png","142_baby_uglygirl.png","143_baby_chompers.png","143_baby_eyeless.png","144_baby_camillojr.png","144_baby_sloppy.png","145_baby_bluebird.png","145_baby_eyeless.png","146_baby_fat.png","146_baby_sloppy.png","147_baby_bluebird.png","147_baby_butterfly.png","148_baby_fat.png","148_baby_goggles.png","149_baby_apathetic.png","149_baby_butterfly.png","150_baby_cape.png","150_baby_goggles.png","151_baby_apathetic.png","151_baby_sorrow.png","152_baby_cape.png","152_baby_rictus.png","153_baby_awaken.png","153_baby_sorrow.png","154_baby_puff.png","154_baby_rictus.png","155_baby_attractive.png","155_baby_awaken.png","156_baby_pretty.png","156_baby_puff.png","157_baby_attractive.png","157_baby_crackedinfamy.png","158_baby_distended.png","158_baby_pretty.png","159_baby_crackedinfamy.png","159_baby_mean.png","160_baby_digital.png","160_baby_distended.png","161_baby_helmet.png","161_baby_mean.png","162_baby_blackeye.png","162_baby_digital.png","163_baby_helmet.png","163_baby_lights.png","164_baby_blackeye.png","164_baby_spike.png","165_baby_lights.png","165_baby_worry.png","166_baby_ears.png","166_baby_spike.png","167_baby_funeral.png","167_baby_worry.png","168_baby_ears.png","168_baby_libra.png","169_baby_funeral.png","169_baby_gappy.png","170_baby_libra.png","170_baby_sunburn.png","171_baby_atepoop.png","171_baby_gappy.png","172_baby_electris.png","172_baby_sunburn.png","173_baby_atepoop.png","173_baby_bloodhole.png","174_baby_electris.png","174_baby_transforming.png","175_baby_aban.png","175_baby_bloodhole.png","176_baby_bandagegirl.png","176_baby_transforming.png","177_baby_aban.png","177_baby_piecea.png","178_baby_bandagegirl.png","178_baby_pieceb.png","179_baby_piecea.png","179_baby_spelunker.png","180_baby_frog.png","180_baby_pieceb.png","181_baby_crook.png","181_baby_spelunker.png","182_baby_don.png","182_baby_frog.png","183_baby_crook.png","183_baby_web.png","184_baby_don.png","184_baby_faded.png","185_baby_sick.png","185_baby_web.png","186_baby_drfetus.png","186_baby_faded.png","187_baby_sick.png","187_baby_spectral.png","188_baby_drfetus.png","188_baby_redskeleton.png","189_baby_skeleton.png","189_baby_spectral.png","190_baby_jammies.png","190_baby_redskeleton.png","191_baby_newjammies.png","191_baby_skeleton.png","192_baby_cold.png","192_baby_jammies.png","193_baby_newjammies.png","193_baby_oldman.png","194_baby_cold.png","194_baby_spooked.png","195_baby_nice.png","195_baby_oldman.png","196_baby_dots.png","196_baby_spooked.png","197_baby_nice.png","197_baby_peeling.png","198_baby_dots.png","198_baby_smallface.png","199_baby_good.png","199_baby_peeling.png","200_baby_blindfold.png","200_baby_smallface.png","201_baby_good.png","201_baby_pipe.png","202_baby_blindfold.png","202_baby_dented.png","203_baby_pipe.png","203_baby_steven.png","204_baby_dented.png","204_baby_monocle.png","205_baby_belial.png","205_baby_steven.png","206_baby_monocle.png","206_baby_monstro.png","207_baby_belial.png","207_baby_fez.png","208_baby_meatboy.png","208_baby_monstro.png","209_baby_fez.png","209_baby_skull.png","210_baby_conjoined.png","210_baby_meatboy.png","211_baby_skinny.png","211_baby_skull.png","212_baby_conjoined.png","212_baby_spider.png","213_baby_shopkeeper.png","213_baby_skinny.png","214_baby_fancy.png","214_baby_spider.png","215_baby_chubby.png","215_baby_shopkeeper.png","216_baby_cyclops.png","216_baby_fancy.png","217_baby_chubby.png","217_baby_isaac.png","218_baby_cyclops.png","218_baby_plug.png","219_baby_drool.png","219_baby_isaac.png","220_baby_plug.png","220_baby_wink.png","221_baby_drool.png","221_baby_pox.png","222_baby_onion.png","222_baby_wink.png","223_baby_pox.png","223_baby_zipper.png","224_baby_buckteeth.png","224_baby_onion.png","225_baby_beard.png","225_baby_zipper.png","226_baby_buckteeth.png","226_baby_hanger.png","227_baby_beard.png","227_baby_vampire.png","228_baby_hanger.png","228_baby_tilt.png","229_baby_bawl.png","229_baby_vampire.png","230_baby_lemon.png","230_baby_tilt.png","231_baby_bawl.png","231_baby_punkboy.png","232_baby_lemon.png","232_baby_punkgirl.png","233_baby_computer.png","233_baby_punkboy.png","234_baby_mask.png","234_baby_punkgirl.png","235_baby_computer.png","235_baby_gem.png","236_baby_mask.png","236_baby_shark.png","237_baby_beret.png","237_baby_gem.png","238_baby_blisters.png","238_baby_shark.png","239_baby_beret.png","239_baby_radioactive.png","240_baby_beast.png","240_baby_blisters.png","241_baby_dark.png","241_baby_radioactive.png","242_baby_beast.png","242_baby_snail.png","243_baby_blood.png","243_baby_dark.png","244_baby_8ball.png","244_baby_snail.png","245_baby_blood.png","245_baby_wisp.png","246_baby_8ball.png","246_baby_cactus.png","247_baby_loveeye.png","247_baby_wisp.png","248_baby_cactus.png","248_baby_medusa.png","249_baby_loveeye.png","249_baby_nuclear.png","250_baby_medusa.png","250_baby_purple.png","251_baby_nuclear.png","251_baby_wizard.png","252_baby_earth.png","252_baby_purple.png","253_baby_saturn.png","253_baby_wizard.png","254_baby_cloud.png","254_baby_earth.png","255_baby_saturn.png","255_baby_tube.png","256_baby_cloud.png","256_baby_rocker.png","257_baby_king.png","257_baby_tube.png","258_baby_coat.png","258_baby_rocker.png","259_baby_king.png","259_baby_viking.png","260_baby_coat.png","260_baby_panda.png","261_baby_raccoon.png","261_baby_viking.png","262_baby_bear.png","262_baby_panda.png","263_baby_polarbear.png","263_baby_raccoon.png","264_baby_bear.png","264_baby_lovebear.png","265_baby_hare.png","265_baby_polarbear.png","266_baby_lovebear.png","266_baby_squirrel.png","267_baby_hare.png","267_baby_tabby.png","268_baby_porcupine.png","268_baby_squirrel.png","269_baby_puppy.png","269_baby_tabby.png","270_baby_parrot.png","270_baby_porcupine.png","271_baby_chameleon.png","271_baby_puppy.png","272_baby_boulder.png","272_baby_parrot.png","273_baby_aqua.png","273_baby_chameleon.png","274_baby_boulder.png","274_baby_gargoyle.png","275_baby_aqua.png","275_baby_spikydemon.png","276_baby_gargoyle.png","276_baby_reddemon.png","277_baby_orangedemon.png","277_baby_spikydemon.png","278_baby_eyedemon.png","278_baby_reddemon.png","279_baby_fangdemon.png","279_baby_orangedemon.png","280_baby_eyedemon.png","280_baby_ghost.png","281_baby_arachnid.png","281_baby_fangdemon.png","282_baby_bony.png","282_baby_ghost.png","283_baby_arachnid.png","283_baby_bigtongue.png","284_baby_3d.png","284_baby_bony.png","285_baby_bigtongue.png","285_baby_suit.png","286_baby_3d.png","286_baby_butt.png","287_baby_cupid.png","287_baby_suit.png","288_baby_butt.png","288_baby_heart.png","289_baby_cupid.png","289_baby_killer.png","290_baby_heart.png","290_baby_lantern.png","291_baby_banshee.png","291_baby_killer.png","292_baby_lantern.png","292_baby_ranger.png","293_baby_banshee.png","293_baby_rider.png","294_baby_choco.png","294_baby_ranger.png","295_baby_rider.png","295_baby_woodsman.png","296_baby_brunette.png","296_baby_choco.png","297_baby_blonde.png","297_baby_woodsman.png","298_baby_bluehair.png","298_baby_brunette.png","299_baby_blonde.png","299_baby_bloodied.png","300_baby_bluehair.png","300_baby_cheese.png","301_baby_bloodied.png","301_baby_pizza.png","302_baby_cheese.png","302_baby_hotdog.png","303_baby_hotdog.png","303_baby_pizza.png","304_baby_borg.png","304_baby_hotdog.png","305_baby_corrupted.png","305_baby_pear.png","306_baby_borg.png","306_baby_xmouth.png","307_baby_corrupted.png","307_baby_xeyes.png","308_baby_stareyes.png","308_baby_xmouth.png","309_baby_surgeon.png","309_baby_xeyes.png","310_baby_stareyes.png","310_baby_sword.png","311_baby_monk.png","311_baby_surgeon.png","312_baby_disco.png","312_baby_sword.png","313_baby_monk.png","313_baby_puzzle.png","314_baby_disco.png","314_baby_speaker.png","315_baby_puzzle.png","315_baby_scary.png","316_baby_fireball.png","316_baby_speaker.png","317_baby_maw.png","317_baby_scary.png","318_baby_exploding.png","318_baby_fireball.png","319_baby_cupcake.png","319_baby_maw.png","320_baby_exploding.png","320_baby_skinless.png","321_baby_ballerina.png","321_baby_cupcake.png","322_baby_goblin.png","322_baby_skinless.png","323_baby_ballerina.png","323_baby_coolgoblin.png","324_baby_geek.png","324_baby_goblin.png","325_baby_coolgoblin.png","325_baby_longbeard.png","326_baby_geek.png","326_baby_muttonchops.png","327_baby_longbeard.png","327_baby_spartan.png","328_baby_muttonchops.png","328_baby_tortoise.png","329_baby_slicer.png","329_baby_spartan.png","330_baby_butterfly.png","330_baby_tortoise.png","331_baby_homeless.png","331_baby_slicer.png","332_baby_butterfly.png","332_baby_lumberjack.png","333_baby_cyberspace.png","333_baby_homeless.png","334_baby_hero.png","334_baby_lumberjack.png","335_baby_boxers.png","335_baby_cyberspace.png","336_baby_hero.png","336_baby_winghelmet.png","337_baby_boxers.png","337_baby_x.png","338_baby_o.png","338_baby_winghelmet.png","339_baby_vomit.png","339_baby_x.png","340_baby_merman.png","340_baby_o.png","341_baby_cyborg.png","341_baby_vomit.png","342_baby_barbarian.png","342_baby_merman.png","343_baby_cyborg.png","343_baby_locust.png","344_baby_barbarian.png","344_baby_twotone.png","345_baby_2600.png","345_baby_locust.png","346_baby_fourtone.png","346_baby_twotone.png","347_baby_2600.png","347_baby_grayscale.png","348_baby_fourtone.png","348_baby_rabbit.png","349_baby_grayscale.png","349_baby_mouse.png","350_baby_critter.png","350_baby_rabbit.png","351_baby_bluerobot.png","351_baby_mouse.png","352_baby_critter.png","352_baby_pilot.png","353_baby_bluerobot.png","353_baby_redplumber.png","354_baby_greenplumber.png","354_baby_pilot.png","355_baby_redplumber.png","355_baby_yellowplumber.png","356_baby_greenplumber.png","356_baby_purpleplumber.png","357_baby_tanooki.png","357_baby_yellowplumber.png","358_baby_mushroomman.png","358_baby_purpleplumber.png","359_baby_mushroomgirl.png","359_baby_tanooki.png","360_baby_cannonball.png","360_baby_mushroomman.png","361_baby_froggy.png","361_baby_mushroomgirl.png","362_baby_cannonball.png","362_baby_turtledragon.png","363_baby_froggy.png","363_baby_shellsuit.png","364_baby_fiery.png","364_baby_turtledragon.png","365_baby_meanmushroom.png","365_baby_shellsuit.png","366_baby_arcade.png","366_baby_fiery.png","367_baby_meanmushroom.png","367_baby_scaredghost.png","368_baby_arcade.png","368_baby_blueghost.png","369_baby_redghost.png","369_baby_scaredghost.png","370_baby_blueghost.png","370_baby_pinkghost.png","371_baby_orangeghost.png","371_baby_redghost.png","372_baby_pinkghost.png","372_baby_pinkprincess.png","373_baby_orangeghost.png","373_baby_yellowprincess.png","374_baby_dino.png","374_baby_pinkprincess.png","375_baby_elf.png","375_baby_yellowprincess.png","376_baby_darkelf.png","376_baby_dino.png","377_baby_darkknight.png","377_baby_elf.png","378_baby_darkelf.png","378_baby_octopus.png","379_baby_darkknight.png","379_baby_orangepig.png","380_baby_bluepig.png","380_baby_octopus.png","381_baby_elfprincess.png","381_baby_orangepig.png","382_baby_bluepig.png","382_baby_fishman.png","383_baby_elfprincess.png","383_baby_fairyman.png","384_baby_fishman.png","384_baby_imp.png","385_baby_fairyman.png","385_baby_worm.png","386_baby_bluewrestler.png","386_baby_imp.png","387_baby_redwrestler.png","387_baby_worm.png","388_baby_bluewrestler.png","388_baby_toast.png","389_baby_redwrestler.png","389_baby_roboboy.png","390_baby_liberty.png","390_baby_toast.png","391_baby_dreamknight.png","391_baby_roboboy.png","392_baby_cowboy.png","392_baby_liberty.png","393_baby_dreamknight.png","393_baby_mermaid.png","394_baby_cowboy.png","394_baby_plague.png","395_baby_mermaid.png","395_baby_spacesoldier.png","396_baby_darkspacesoldier.png","396_baby_plague.png","397_baby_gasmask.png","397_baby_spacesoldier.png","398_baby_darkspacesoldier.png","398_baby_tomboy.png","399_baby_corgi.png","399_baby_gasmask.png","400_baby_tomboy.png","400_baby_unicorn.png","401_baby_corgi.png","401_baby_pixie.png","402_baby_referee.png","402_baby_unicorn.png","403_baby_dealwithit.png","403_baby_pixie.png","404_baby_astronaut.png","404_baby_referee.png","405_baby_blurred.png","405_baby_dealwithit.png","406_baby_astronaut.png","406_baby_censored.png","407_baby_blurred.png","407_baby_coolghost.png","408_baby_censored.png","408_baby_gills.png","409_baby_bluehat.png","409_baby_coolghost.png","410_baby_catsuit.png","410_baby_gills.png","411_baby_bluehat.png","411_baby_pirate.png","412_baby_catsuit.png","412_baby_superrobo.png","413_baby_lightmage.png","413_baby_pirate.png","414_baby_puncher.png","414_baby_superrobo.png","415_baby_holyknight.png","415_baby_lightmage.png","416_baby_puncher.png","416_baby_shadowmage.png","417_baby_firemage.png","417_baby_holyknight.png","418_baby_priest.png","418_baby_shadowmage.png","419_baby_firemage.png","419_baby_zipper.png","420_baby_bag.png","420_baby_priest.png","421_baby_sailor.png","421_baby_zipper.png","422_baby_bag.png","422_baby_rich.png","423_baby_sailor.png","423_baby_toga.png","424_baby_knight.png","424_baby_rich.png","425_baby_blackknight.png","425_baby_toga.png","426_baby_knight.png","427_baby_blackknight.png","428_baby_magiccat.png","429_baby_littlehorn.png","430_baby_folder.png","431_baby_driver.png","432_baby_dragon.png","433_baby_downwell.png","434_baby_cylinder.png","435_baby_cup.png","436_baby_cave_robot.png","437_baby_breadmeat_hoodiebread.png","438_baby_bigmouth.png","439_baby_afro_rainbow.png","440_baby_afro.png","441_baby_tv.png","442_baby_tooth.png","443_baby_tired.png","444_baby_steroids.png","445_baby_soap_monster.png","446_baby_rojen_whitefox.png","447_baby_rocket.png","448_baby_nurf.png","449_baby_mutated_fish.png","450_baby_moth.png","451_baby_buttface.png","452_baby_flying_candle.png","453_baby_graven.png","454_baby_gizzy_chargeshot.png","455_baby_green_koopa.png","456_baby_handsome_mrfrog.png","457_baby_pumpkin_guy.png","458_baby_red_koopa.png","459_baby_sad_bunny.png","460_baby_saturn.png","461_baby_toast_boy.png","462_baby_voxdog.png","463_baby_404.png","464_baby_arrowhead.png","465_baby_beanie.png","466_baby_blindcursed.png","467_baby_burning.png","468_baby_cursor.png","469_baby_flybaby.png","470_baby_headphone.png","471_baby_knife.png","472_baby_mufflerscarf.png","473_baby_robbermask.png","474_baby_scoreboard.png","475_baby_somanyeyes.png","476_baby_text.png","477_baby_wing.png"}
	--FDSF
local data = {Damage = 0, Height = 0, Speed = 0, FallingSpeed = 0, TearFlags1 = 0, TearFlags2 = 0, Luck = 0, Variant = 0, r = 0, g = 0, b = 0}


local timer = 0

local oldstage = -1


function BuddyBox:UPDATE()

	local game = Game()
	local room = game:GetRoom()
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(familiarItem) then
		if had == false then
			local f = Isaac.Spawn(familiarEntity,familiarEntityVariant,0,player.Position,Vector(0,0),player)
			had = true
		end
	end
end

function BuddyBox:FamiliarInit(fam)
	BuddyBox:rerollStats(fam)

end

function BuddyBox:rerollStats(familiar)
	local room = Game():GetRoom()
	math.randomseed(room:GetDecorationSeed() + Game():GetFrameCount())
	local num = math.random(1,#sprites)
	familiar:GetSprite():ReplaceSpritesheet(0,"gfx/characters/player2/" .. sprites[num])
	familiar:GetSprite():LoadGraphics()

	--INITILIZING STATS
	teardelay = math.random(12,25)
	data.Damage = math.random(2,6)
	data.Height = math.random(18,27)
	data.Speed = math.random(1,7)
	data.FallingSpeed = -0.2 + math.random(0,1)/10*4

	data.Luck = math.random() + 0.3

	data.r = math.random()
	data.g = math.random()
	data.b = math.random()

	data.Variant = BuddyBox:randomTable(TearVariant)
	if math.random() <= 0.5 then 
		data.Variant = -1
	end


	data.TearFlags1 = BuddyBox:randomTable(Movement)
	data.TearFlags2 = BuddyBox:randomTable(Effects)

end

function BuddyBox:randomTable(t)
	local keys, i = {}, 1
	for k,_ in pairs(t) do
	 keys[i] = k
	 i= i+1
	end

	local rand
	rand = math.random(1,#keys)
	return t[keys[rand]]
end

function BuddyBox:FamiliarUpdate(fam)
	--Follow Position
	local player = Isaac.GetPlayer(0)
	fam:FollowPosition(player.Position)

	if Game():GetLevel():GetStage() ~= oldstage then
		BuddyBox:rerollStats(fam)
		oldstage = Game():GetLevel():GetStage()
	end
	--Animations
	local currentAnim = ""

	if player:GetFireDirection() ~= Direction.NO_DIRECTION then
		if player:GetHeadDirection() == Direction.LEFT then
			currentAnim = "HeadLeft"
		elseif player:GetHeadDirection() == Direction.RIGHT then
			currentAnim = "HeadRight"
		elseif player:GetHeadDirection() == Direction.UP then
			currentAnim = "HeadUp"
		elseif player:GetHeadDirection() == Direction.DOWN then
			currentAnim = "HeadDown"
		end 
	else
		local dir = BuddyBox:toDirection(fam.Velocity)
		if dir== Direction.LEFT then
			currentAnim = "HeadLeft"
		elseif dir == Direction.RIGHT then
			currentAnim = "HeadRight"
		elseif dir == Direction.UP then
			currentAnim = "HeadUp"
		elseif dir == Direction.DOWN then
			currentAnim = "HeadDown"
		else 
			currentAnim = "HeadDown"
		end
	end

	fam:GetSprite():Play(currentAnim,true)
	if timer > teardelay / 2 then
		fam:GetSprite():SetFrame(currentAnim,2)
	else
		fam:GetSprite():SetFrame(currentAnim,0)
	end

	--Firing tears
	timer = timer - 1

	if timer <= 0 then

		local oldDamage = player.Damage
		local oldTearHeight = player.TearHeight
		local oldShotSpeed = player.ShotSpeed
		local oldTearFallingSpeed = player.TearFallingSpeed
		local oldTearFlags = player.TearFlags

		player.Damage = data.Damage
		--player.TearHeight = -data.Height
		player.ShotSpeed = data.Speed
		player.TearFallingSpeed = data.FallingSpeed

		player.TearFlags = data.TearFlags1
		if data.Luck > math.random() * 2.7 and data.Variant == -1 then
			player.TearFlags = player.TearFlags | data.TearFlags2
		end

		local tear = nil

		if player:GetFireDirection() ~= Direction.NO_DIRECTION then

			if player:GetFireDirection() == Direction.LEFT then
				tear = player:FireTear(fam.Position, Vector(-10,0) + fam.Velocity*0.7,false,false,false)
			elseif player:GetFireDirection() == Direction.RIGHT then
				tear = player:FireTear(fam.Position, Vector(10,0) + fam.Velocity*0.7,false,false,false)
			elseif player:GetFireDirection() == Direction.UP then
				tear = player:FireTear(fam.Position, Vector(0,-10) + fam.Velocity*0.7,false,false,false)
			elseif player:GetFireDirection() == Direction.DOWN then
				tear = player:FireTear(fam.Position, Vector(0,10) + fam.Velocity*0.7,false,false,false)
			end
			timer = teardelay
			tear.Color = Color(data.r,data.g,data.b,1,0,0,0)
			if data.Variant ~= -1 then
				tear:ChangeVariant(data.Variant)
			end
			tear.TearFlags = player.TearFlags
		else
		end


		--tear.Parent = nil
		--tear.SpawnerEntity = nil

		player.Damage = oldDamage
		player.TearHeight = oldTearHeight
		player.ShotSpeed = oldShotSpeed
		player.TearFallingSpeed = oldTearFallingSpeed
		player.TearFlags = oldTearFlags

	end

end

function BuddyBox:toDirection(vec)
	if math.abs(vec.X) > math.abs(vec.Y) then
		if vec.X > 0 then 		return Direction.RIGHT
		elseif vec.X < 0 then	return Direction.LEFT
		end
	elseif math.abs(vec.X) < math.abs(vec.Y) then
		if vec.Y > 0 then 		return Direction.DOWN
		elseif vec.Y < 0 then	return Direction.UP
		end
	end

	return Direction.NO_DIRECTION
end


function BuddyBox:OnRunStart()
	had = false
	sprites = {"000_baby_spider.png","001isaac_2p.png","001_baby_love.png","002_baby_bloat.png","003_baby_water.png","004_baby_psy.png","005_baby_cursed.png","006_baby_troll.png","007_baby_ybab.png","008_baby_cockeyed.png","009_baby_host.png","010_baby_lost.png","011_baby_cute.png","012_baby_crow.png","013_baby_shadow.png","014_baby_glass.png","015_baby_gold.png","016_baby_cy.png","017_baby_bean.png","018_baby_mag.png","019_baby_wrath.png","020_baby_wrapped.png","021_baby_begotten.png","022_baby_dead.png","023_baby_fighting.png","024_baby_0.png","025_baby_glitch.png","026_baby_magnet.png","027_baby_black.png","027_baby_steven.png","028_baby_monocle.png","028_baby_red.png","029_baby_belial.png","029_baby_white.png","030_baby_blue.png","030_baby_monstro.png","031_baby_fez.png","031_baby_rage.png","032_baby_cry.png","032_baby_meatboy.png","033_baby_skull.png","033_baby_yellow.png","034_baby_conjoined.png","034_baby_long.png","035_baby_green.png","035_baby_skinny.png","036_baby_lil.png","036_baby_spider.png","037_baby_big.png","037_baby_shopkeeper.png","038_baby_brown.png","038_baby_fancy.png","039_baby_chubby.png","039_baby_noose.png","040_baby_cyclops.png","040_baby_hive.png","041_baby_buddy.png","041_baby_isaac.png","042_baby_colorful.png","042_baby_plug.png","043_baby_drool.png","043_baby_whore.png","044_baby_cracked.png","044_baby_wink.png","045_baby_dripping.png","045_baby_pox.png","046_baby_blinding.png","046_baby_onion.png","047_baby_sucky.png","047_baby_zipper.png","048_baby_buckteeth.png","048_baby_dark.png","049_baby_beard.png","049_baby_picky.png","050_baby_hanger.png","050_baby_revenge.png","051_baby_belial.png","051_baby_vampire.png","052_baby_sale.png","052_baby_tilt.png","053_baby_bawl.png","053_baby_goatbaby.png","054_baby_lemon.png","054_baby_super greedbaby.png","055_baby_mort.png","055_baby_tooth.png","056_baby_apollyon.png","056_baby_haunt.png","057_baby_bigeyes.png","057_baby_tooth.png","058_baby_haunt.png","058_baby_sleep.png","059_baby_bigeyes.png","059_baby_zombie.png","060_baby_goat.png","060_baby_sleep.png","061_baby_butthole.png","061_baby_zombie.png","062_baby_eyepatch.png","062_baby_goat.png","063_baby_bloodeyes.png","063_baby_butthole.png","064_baby_eyepatch.png","064_baby_mustache.png","065_baby_bloodeyes.png","065_baby_spittle.png","066_baby_brain.png","066_baby_mustache.png","067_baby_spittle.png","067_baby_threeeyes.png","068_baby_brain.png","068_baby_viridian.png","069_baby_blockhead.png","069_baby_threeeyes.png","070_baby_viridian.png","070_baby_worm.png","071_baby_blockhead.png","071_baby_lowface.png","072_baby_alienhominid.png","072_baby_worm.png","073_baby_bomb.png","073_baby_lowface.png","074_baby_alienhominid.png","074_baby_video.png","075_baby_bomb.png","075_baby_parasite.png","076_baby_derp.png","076_baby_video.png","077_baby_lobotomy.png","077_baby_parasite.png","078_baby_choke.png","078_baby_derp.png","079_baby_lobotomy.png","079_baby_scream.png","080_baby_choke.png","080_baby_gurdy.png","081_baby_ghoul.png","081_baby_scream.png","082_baby_goatee.png","082_baby_gurdy.png","083_baby_ghoul.png","083_baby_shades.png","084_baby_goatee.png","084_baby_statue.png","085_baby_bloodsucker.png","085_baby_shades.png","086_baby_bandaid.png","086_baby_statue.png","087_baby_bloodsucker.png","087_baby_eyebrows.png","088_baby_bandaid.png","088_baby_nerd.png","089_baby_boss.png","089_baby_eyebrows.png","090_baby_nerd.png","090_baby_turd.png","091_baby_boss.png","091_baby_o.png","092_baby_squareeyes.png","092_baby_turd.png","093_baby_o.png","093_baby_teeth.png","094_baby_frown.png","094_baby_squareeyes.png","095_baby_teeth.png","095_baby_tongue.png","096_baby_frown.png","096_baby_halfhead.png","097_baby_makeup.png","097_baby_tongue.png","098_baby_ed.png","098_baby_halfhead.png","099_baby_d.png","099_baby_makeup.png","100_baby_ed.png","100_baby_guppy.png","101_baby_d.png","101_baby_puke.png","102_baby_dumb.png","102_baby_guppy.png","103_baby_lipstick.png","103_baby_puke.png","104_baby_aether.png","104_baby_dumb.png","105_baby_brownie.png","105_baby_lipstick.png","106_baby_aether.png","106_baby_vvvvvv.png","107_baby_brownie.png","107_baby_nosferatu.png","108_baby_pubic.png","108_baby_vvvvvv.png","109_baby_eyemouth.png","109_baby_nosferatu.png","110_baby_pubic.png","110_baby_weirdo.png","111_baby_eyemouth.png","111_baby_v.png","112_baby_strangemouth.png","112_baby_weirdo.png","113_baby_masked.png","113_baby_v.png","114_baby_cyber.png","114_baby_strangemouth.png","115_baby_axewound.png","115_baby_masked.png","116_baby_cyber.png","116_baby_statue.png","117_baby_axewound.png","117_baby_grin.png","118_baby_statue.png","118_baby_upset.png","119_baby_grin.png","119_baby_plastic.png","120_baby_monochrome.png","120_baby_upset.png","121_baby_onetooth.png","121_baby_plastic.png","122_baby_monochrome.png","122_baby_tusks.png","123_baby_hopeless.png","123_baby_onetooth.png","124_baby_bigmouth.png","124_baby_tusks.png","125_baby_hopeless.png","125_baby_peeeyes.png","126_baby_bigmouth.png","126_baby_earwig.png","127_baby_ninkumpoop.png","127_baby_peeeyes.png","128_baby_earwig.png","128_baby_strangeshape.png","129_baby_bugeyed.png","129_baby_ninkumpoop.png","130_baby_freaky.png","130_baby_strangeshape.png","131_baby_bugeyed.png","131_baby_crooked.png","132_baby_freaky.png","132_baby_spiderlegs.png","133_baby_crooked.png","133_baby_smiling.png","134_baby_spiderlegs.png","134_baby_tears.png","135_baby_bowling.png","135_baby_smiling.png","136_baby_mohawk.png","136_baby_tears.png","137_baby_bowling.png","137_baby_rottenmeat.png","138_baby_mohawk.png","138_baby_noarms.png","139_baby_rottenmeat.png","139_baby_twin2.png","140_baby_noarms.png","140_baby_uglygirl.png","141_baby_chompers.png","141_baby_twin2.png","142_baby_camillojr.png","142_baby_uglygirl.png","143_baby_chompers.png","143_baby_eyeless.png","144_baby_camillojr.png","144_baby_sloppy.png","145_baby_bluebird.png","145_baby_eyeless.png","146_baby_fat.png","146_baby_sloppy.png","147_baby_bluebird.png","147_baby_butterfly.png","148_baby_fat.png","148_baby_goggles.png","149_baby_apathetic.png","149_baby_butterfly.png","150_baby_cape.png","150_baby_goggles.png","151_baby_apathetic.png","151_baby_sorrow.png","152_baby_cape.png","152_baby_rictus.png","153_baby_awaken.png","153_baby_sorrow.png","154_baby_puff.png","154_baby_rictus.png","155_baby_attractive.png","155_baby_awaken.png","156_baby_pretty.png","156_baby_puff.png","157_baby_attractive.png","157_baby_crackedinfamy.png","158_baby_distended.png","158_baby_pretty.png","159_baby_crackedinfamy.png","159_baby_mean.png","160_baby_digital.png","160_baby_distended.png","161_baby_helmet.png","161_baby_mean.png","162_baby_blackeye.png","162_baby_digital.png","163_baby_helmet.png","163_baby_lights.png","164_baby_blackeye.png","164_baby_spike.png","165_baby_lights.png","165_baby_worry.png","166_baby_ears.png","166_baby_spike.png","167_baby_funeral.png","167_baby_worry.png","168_baby_ears.png","168_baby_libra.png","169_baby_funeral.png","169_baby_gappy.png","170_baby_libra.png","170_baby_sunburn.png","171_baby_atepoop.png","171_baby_gappy.png","172_baby_electris.png","172_baby_sunburn.png","173_baby_atepoop.png","173_baby_bloodhole.png","174_baby_electris.png","174_baby_transforming.png","175_baby_aban.png","175_baby_bloodhole.png","176_baby_bandagegirl.png","176_baby_transforming.png","177_baby_aban.png","177_baby_piecea.png","178_baby_bandagegirl.png","178_baby_pieceb.png","179_baby_piecea.png","179_baby_spelunker.png","180_baby_frog.png","180_baby_pieceb.png","181_baby_crook.png","181_baby_spelunker.png","182_baby_don.png","182_baby_frog.png","183_baby_crook.png","183_baby_web.png","184_baby_don.png","184_baby_faded.png","185_baby_sick.png","185_baby_web.png","186_baby_drfetus.png","186_baby_faded.png","187_baby_sick.png","187_baby_spectral.png","188_baby_drfetus.png","188_baby_redskeleton.png","189_baby_skeleton.png","189_baby_spectral.png","190_baby_jammies.png","190_baby_redskeleton.png","191_baby_newjammies.png","191_baby_skeleton.png","192_baby_cold.png","192_baby_jammies.png","193_baby_newjammies.png","193_baby_oldman.png","194_baby_cold.png","194_baby_spooked.png","195_baby_nice.png","195_baby_oldman.png","196_baby_dots.png","196_baby_spooked.png","197_baby_nice.png","197_baby_peeling.png","198_baby_dots.png","198_baby_smallface.png","199_baby_good.png","199_baby_peeling.png","200_baby_blindfold.png","200_baby_smallface.png","201_baby_good.png","201_baby_pipe.png","202_baby_blindfold.png","202_baby_dented.png","203_baby_pipe.png","203_baby_steven.png","204_baby_dented.png","204_baby_monocle.png","205_baby_belial.png","205_baby_steven.png","206_baby_monocle.png","206_baby_monstro.png","207_baby_belial.png","207_baby_fez.png","208_baby_meatboy.png","208_baby_monstro.png","209_baby_fez.png","209_baby_skull.png","210_baby_conjoined.png","210_baby_meatboy.png","211_baby_skinny.png","211_baby_skull.png","212_baby_conjoined.png","212_baby_spider.png","213_baby_shopkeeper.png","213_baby_skinny.png","214_baby_fancy.png","214_baby_spider.png","215_baby_chubby.png","215_baby_shopkeeper.png","216_baby_cyclops.png","216_baby_fancy.png","217_baby_chubby.png","217_baby_isaac.png","218_baby_cyclops.png","218_baby_plug.png","219_baby_drool.png","219_baby_isaac.png","220_baby_plug.png","220_baby_wink.png","221_baby_drool.png","221_baby_pox.png","222_baby_onion.png","222_baby_wink.png","223_baby_pox.png","223_baby_zipper.png","224_baby_buckteeth.png","224_baby_onion.png","225_baby_beard.png","225_baby_zipper.png","226_baby_buckteeth.png","226_baby_hanger.png","227_baby_beard.png","227_baby_vampire.png","228_baby_hanger.png","228_baby_tilt.png","229_baby_bawl.png","229_baby_vampire.png","230_baby_lemon.png","230_baby_tilt.png","231_baby_bawl.png","231_baby_punkboy.png","232_baby_lemon.png","232_baby_punkgirl.png","233_baby_computer.png","233_baby_punkboy.png","234_baby_mask.png","234_baby_punkgirl.png","235_baby_computer.png","235_baby_gem.png","236_baby_mask.png","236_baby_shark.png","237_baby_beret.png","237_baby_gem.png","238_baby_blisters.png","238_baby_shark.png","239_baby_beret.png","239_baby_radioactive.png","240_baby_beast.png","240_baby_blisters.png","241_baby_dark.png","241_baby_radioactive.png","242_baby_beast.png","242_baby_snail.png","243_baby_blood.png","243_baby_dark.png","244_baby_8ball.png","244_baby_snail.png","245_baby_blood.png","245_baby_wisp.png","246_baby_8ball.png","246_baby_cactus.png","247_baby_loveeye.png","247_baby_wisp.png","248_baby_cactus.png","248_baby_medusa.png","249_baby_loveeye.png","249_baby_nuclear.png","250_baby_medusa.png","250_baby_purple.png","251_baby_nuclear.png","251_baby_wizard.png","252_baby_earth.png","252_baby_purple.png","253_baby_saturn.png","253_baby_wizard.png","254_baby_cloud.png","254_baby_earth.png","255_baby_saturn.png","255_baby_tube.png","256_baby_cloud.png","256_baby_rocker.png","257_baby_king.png","257_baby_tube.png","258_baby_coat.png","258_baby_rocker.png","259_baby_king.png","259_baby_viking.png","260_baby_coat.png","260_baby_panda.png","261_baby_raccoon.png","261_baby_viking.png","262_baby_bear.png","262_baby_panda.png","263_baby_polarbear.png","263_baby_raccoon.png","264_baby_bear.png","264_baby_lovebear.png","265_baby_hare.png","265_baby_polarbear.png","266_baby_lovebear.png","266_baby_squirrel.png","267_baby_hare.png","267_baby_tabby.png","268_baby_porcupine.png","268_baby_squirrel.png","269_baby_puppy.png","269_baby_tabby.png","270_baby_parrot.png","270_baby_porcupine.png","271_baby_chameleon.png","271_baby_puppy.png","272_baby_boulder.png","272_baby_parrot.png","273_baby_aqua.png","273_baby_chameleon.png","274_baby_boulder.png","274_baby_gargoyle.png","275_baby_aqua.png","275_baby_spikydemon.png","276_baby_gargoyle.png","276_baby_reddemon.png","277_baby_orangedemon.png","277_baby_spikydemon.png","278_baby_eyedemon.png","278_baby_reddemon.png","279_baby_fangdemon.png","279_baby_orangedemon.png","280_baby_eyedemon.png","280_baby_ghost.png","281_baby_arachnid.png","281_baby_fangdemon.png","282_baby_bony.png","282_baby_ghost.png","283_baby_arachnid.png","283_baby_bigtongue.png","284_baby_3d.png","284_baby_bony.png","285_baby_bigtongue.png","285_baby_suit.png","286_baby_3d.png","286_baby_butt.png","287_baby_cupid.png","287_baby_suit.png","288_baby_butt.png","288_baby_heart.png","289_baby_cupid.png","289_baby_killer.png","290_baby_heart.png","290_baby_lantern.png","291_baby_banshee.png","291_baby_killer.png","292_baby_lantern.png","292_baby_ranger.png","293_baby_banshee.png","293_baby_rider.png","294_baby_choco.png","294_baby_ranger.png","295_baby_rider.png","295_baby_woodsman.png","296_baby_brunette.png","296_baby_choco.png","297_baby_blonde.png","297_baby_woodsman.png","298_baby_bluehair.png","298_baby_brunette.png","299_baby_blonde.png","299_baby_bloodied.png","300_baby_bluehair.png","300_baby_cheese.png","301_baby_bloodied.png","301_baby_pizza.png","302_baby_cheese.png","302_baby_hotdog.png","303_baby_hotdog.png","303_baby_pizza.png","304_baby_borg.png","304_baby_hotdog.png","305_baby_corrupted.png","305_baby_pear.png","306_baby_borg.png","306_baby_xmouth.png","307_baby_corrupted.png","307_baby_xeyes.png","308_baby_stareyes.png","308_baby_xmouth.png","309_baby_surgeon.png","309_baby_xeyes.png","310_baby_stareyes.png","310_baby_sword.png","311_baby_monk.png","311_baby_surgeon.png","312_baby_disco.png","312_baby_sword.png","313_baby_monk.png","313_baby_puzzle.png","314_baby_disco.png","314_baby_speaker.png","315_baby_puzzle.png","315_baby_scary.png","316_baby_fireball.png","316_baby_speaker.png","317_baby_maw.png","317_baby_scary.png","318_baby_exploding.png","318_baby_fireball.png","319_baby_cupcake.png","319_baby_maw.png","320_baby_exploding.png","320_baby_skinless.png","321_baby_ballerina.png","321_baby_cupcake.png","322_baby_goblin.png","322_baby_skinless.png","323_baby_ballerina.png","323_baby_coolgoblin.png","324_baby_geek.png","324_baby_goblin.png","325_baby_coolgoblin.png","325_baby_longbeard.png","326_baby_geek.png","326_baby_muttonchops.png","327_baby_longbeard.png","327_baby_spartan.png","328_baby_muttonchops.png","328_baby_tortoise.png","329_baby_slicer.png","329_baby_spartan.png","330_baby_butterfly.png","330_baby_tortoise.png","331_baby_homeless.png","331_baby_slicer.png","332_baby_butterfly.png","332_baby_lumberjack.png","333_baby_cyberspace.png","333_baby_homeless.png","334_baby_hero.png","334_baby_lumberjack.png","335_baby_boxers.png","335_baby_cyberspace.png","336_baby_hero.png","336_baby_winghelmet.png","337_baby_boxers.png","337_baby_x.png","338_baby_o.png","338_baby_winghelmet.png","339_baby_vomit.png","339_baby_x.png","340_baby_merman.png","340_baby_o.png","341_baby_cyborg.png","341_baby_vomit.png","342_baby_barbarian.png","342_baby_merman.png","343_baby_cyborg.png","343_baby_locust.png","344_baby_barbarian.png","344_baby_twotone.png","345_baby_2600.png","345_baby_locust.png","346_baby_fourtone.png","346_baby_twotone.png","347_baby_2600.png","347_baby_grayscale.png","348_baby_fourtone.png","348_baby_rabbit.png","349_baby_grayscale.png","349_baby_mouse.png","350_baby_critter.png","350_baby_rabbit.png","351_baby_bluerobot.png","351_baby_mouse.png","352_baby_critter.png","352_baby_pilot.png","353_baby_bluerobot.png","353_baby_redplumber.png","354_baby_greenplumber.png","354_baby_pilot.png","355_baby_redplumber.png","355_baby_yellowplumber.png","356_baby_greenplumber.png","356_baby_purpleplumber.png","357_baby_tanooki.png","357_baby_yellowplumber.png","358_baby_mushroomman.png","358_baby_purpleplumber.png","359_baby_mushroomgirl.png","359_baby_tanooki.png","360_baby_cannonball.png","360_baby_mushroomman.png","361_baby_froggy.png","361_baby_mushroomgirl.png","362_baby_cannonball.png","362_baby_turtledragon.png","363_baby_froggy.png","363_baby_shellsuit.png","364_baby_fiery.png","364_baby_turtledragon.png","365_baby_meanmushroom.png","365_baby_shellsuit.png","366_baby_arcade.png","366_baby_fiery.png","367_baby_meanmushroom.png","367_baby_scaredghost.png","368_baby_arcade.png","368_baby_blueghost.png","369_baby_redghost.png","369_baby_scaredghost.png","370_baby_blueghost.png","370_baby_pinkghost.png","371_baby_orangeghost.png","371_baby_redghost.png","372_baby_pinkghost.png","372_baby_pinkprincess.png","373_baby_orangeghost.png","373_baby_yellowprincess.png","374_baby_dino.png","374_baby_pinkprincess.png","375_baby_elf.png","375_baby_yellowprincess.png","376_baby_darkelf.png","376_baby_dino.png","377_baby_darkknight.png","377_baby_elf.png","378_baby_darkelf.png","378_baby_octopus.png","379_baby_darkknight.png","379_baby_orangepig.png","380_baby_bluepig.png","380_baby_octopus.png","381_baby_elfprincess.png","381_baby_orangepig.png","382_baby_bluepig.png","382_baby_fishman.png","383_baby_elfprincess.png","383_baby_fairyman.png","384_baby_fishman.png","384_baby_imp.png","385_baby_fairyman.png","385_baby_worm.png","386_baby_bluewrestler.png","386_baby_imp.png","387_baby_redwrestler.png","387_baby_worm.png","388_baby_bluewrestler.png","388_baby_toast.png","389_baby_redwrestler.png","389_baby_roboboy.png","390_baby_liberty.png","390_baby_toast.png","391_baby_dreamknight.png","391_baby_roboboy.png","392_baby_cowboy.png","392_baby_liberty.png","393_baby_dreamknight.png","393_baby_mermaid.png","394_baby_cowboy.png","394_baby_plague.png","395_baby_mermaid.png","395_baby_spacesoldier.png","396_baby_darkspacesoldier.png","396_baby_plague.png","397_baby_gasmask.png","397_baby_spacesoldier.png","398_baby_darkspacesoldier.png","398_baby_tomboy.png","399_baby_corgi.png","399_baby_gasmask.png","400_baby_tomboy.png","400_baby_unicorn.png","401_baby_corgi.png","401_baby_pixie.png","402_baby_referee.png","402_baby_unicorn.png","403_baby_dealwithit.png","403_baby_pixie.png","404_baby_astronaut.png","404_baby_referee.png","405_baby_blurred.png","405_baby_dealwithit.png","406_baby_astronaut.png","406_baby_censored.png","407_baby_blurred.png","407_baby_coolghost.png","408_baby_censored.png","408_baby_gills.png","409_baby_bluehat.png","409_baby_coolghost.png","410_baby_catsuit.png","410_baby_gills.png","411_baby_bluehat.png","411_baby_pirate.png","412_baby_catsuit.png","412_baby_superrobo.png","413_baby_lightmage.png","413_baby_pirate.png","414_baby_puncher.png","414_baby_superrobo.png","415_baby_holyknight.png","415_baby_lightmage.png","416_baby_puncher.png","416_baby_shadowmage.png","417_baby_firemage.png","417_baby_holyknight.png","418_baby_priest.png","418_baby_shadowmage.png","419_baby_firemage.png","419_baby_zipper.png","420_baby_bag.png","420_baby_priest.png","421_baby_sailor.png","421_baby_zipper.png","422_baby_bag.png","422_baby_rich.png","423_baby_sailor.png","423_baby_toga.png","424_baby_knight.png","424_baby_rich.png","425_baby_blackknight.png","425_baby_toga.png","426_baby_knight.png","427_baby_blackknight.png","428_baby_magiccat.png","429_baby_littlehorn.png","430_baby_folder.png","431_baby_driver.png","432_baby_dragon.png","433_baby_downwell.png","434_baby_cylinder.png","435_baby_cup.png","436_baby_cave_robot.png","437_baby_breadmeat_hoodiebread.png","438_baby_bigmouth.png","439_baby_afro_rainbow.png","440_baby_afro.png","441_baby_tv.png","442_baby_tooth.png","443_baby_tired.png","444_baby_steroids.png","445_baby_soap_monster.png","446_baby_rojen_whitefox.png","447_baby_rocket.png","448_baby_nurf.png","449_baby_mutated_fish.png","450_baby_moth.png","451_baby_buttface.png","452_baby_flying_candle.png","453_baby_graven.png","454_baby_gizzy_chargeshot.png","455_baby_green_koopa.png","456_baby_handsome_mrfrog.png","457_baby_pumpkin_guy.png","458_baby_red_koopa.png","459_baby_sad_bunny.png","460_baby_saturn.png","461_baby_toast_boy.png","462_baby_voxdog.png","463_baby_404.png","464_baby_arrowhead.png","465_baby_beanie.png","466_baby_blindcursed.png","467_baby_burning.png","468_baby_cursor.png","469_baby_flybaby.png","470_baby_headphone.png","471_baby_knife.png","472_baby_mufflerscarf.png","473_baby_robbermask.png","474_baby_scoreboard.png","475_baby_somanyeyes.png","476_baby_text.png","477_baby_wing.png"}
end

function BuddyBox:drawText( )
	local game = Game()
	local player = Isaac.GetPlayer(0)
	local room = game:GetRoom()
	--Isaac.RenderText(tostring(player.TearHeight),100,60,1,1,1,255)
	--[[
	local ents = Isaac.GetRoomEntities()
	for i=1,#ents do
		if ents[i].Type == 3 then
			local vec = Isaac.WorldToRenderPosition(ents[i].Position, true)
			--Isaac.RenderText(tostring(data.TearFlags),vec.X,vec.Y,1,1,1,255)
		end
	end
	]]
end

BuddyBox:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, BuddyBox.FamiliarInit, familiarEntityVariant)
BuddyBox:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BuddyBox.FamiliarUpdate, familiarEntityVariant)

BuddyBox:AddCallback(ModCallbacks.MC_POST_RENDER,BuddyBox.drawText)
BuddyBox:AddCallback(ModCallbacks.MC_POST_UPDATE,BuddyBox.UPDATE)

BuddyBox:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT,BuddyBox.OnRunStart)