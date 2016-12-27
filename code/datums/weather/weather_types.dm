//Different types of weather.

/datum/weather/floor_is_lava //The Floor is Lava: Makes all turfs damage anyone on them unless they're standing on a solid object.
	name = "the floor is lava"
	desc = "The ground turns into surprisingly cool lava, lightly damaging anything on the floor."

	telegraph_message = "<span class='warning'>Waves of heat emanate from the ground...</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>The floor is lava! Get on top of something!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 600
	weather_overlay = "lava"

	end_message = "<span class='danger'>The ground cools and returns to its usual form.</span>"
	end_duration = 0

	area_type = /area
	target_z = ZLEVEL_STATION

	overlay_layer = ABOVE_OPEN_TURF_LAYER //Covers floors only
	immunity_type = "lava"

/datum/weather/floor_is_lava/impact(mob/living/L)
	for(var/obj/structure/O in L.loc)
		if(O.density)
			return
	if(L.loc.density)
		return
	if(!L.client) //Only sentient people are going along with it!
		return
	L.adjustFireLoss(3)


/datum/weather/advanced_darkness //Advanced Darkness: Restricts the vision of all affected mobs to a single tile in the cardinal directions.
	name = "advanced darkness"
	desc = "Everything in the area is effectively blinded, unable to see more than a foot or so around itself."

	telegraph_message = "<span class='warning'>The lights begin to dim... is the power going out?</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>This isn't your average everday darkness... this is <i>advanced</i> darkness!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 300

	end_message = "<span class='danger'>At last, the darkness recedes.</span>"
	end_duration = 0

	area_type = /area
	target_z = ZLEVEL_STATION

/datum/weather/advanced_darkness/update_areas()
	for(var/V in impacted_areas)
		var/area/A = V
		if(stage == MAIN_STAGE)
			A.invisibility = 0
			A.opacity = 1
			A.layer = overlay_layer
			A.icon = 'icons/effects/weather_effects.dmi'
			A.icon_state = "darkness"
		else
			A.invisibility = INVISIBILITY_MAXIMUM
			A.opacity = 0


/datum/weather/ash_storm //Ash Storms: Common happenings on lavaland. Heavily obscures vision and deals heavy fire damage to anyone caught outside.
	name = "ash storm"
	desc = "An intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	telegraph_message = "<span class='boldwarning'>An eerie moan rises on the wind. Sheets of burning ash blacken the horizon. Seek shelter.</span>"
	telegraph_duration = 300
	telegraph_sound = 'sound/lavaland/ash_storm_windup.ogg'
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Smoldering clouds of scorching ash billow down around you! Get inside!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_sound = 'sound/lavaland/ash_storm_start.ogg'
	weather_overlay = "ash_storm"

	end_message = "<span class='boldannounce'>The shrieking wind whips away the last of the ash falls to its usual murmur. It should be safe to go outside now.</span>"
	end_duration = 300
	end_sound = 'sound/lavaland/ash_storm_end.ogg'
	end_overlay = "light_ash"

	area_type = /area/lavaland/surface/outdoors
	target_z = ZLEVEL_LAVALAND

	immunity_type = "ash"

	probability = 90

/datum/weather/ash_storm/impact(mob/living/L)
	if(istype(L.loc, /obj/mecha))
		return
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/thermal_protection = H.get_thermal_protection()
		if(thermal_protection >= FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
			return
	L.adjustFireLoss(4)

/datum/weather/ash_storm/emberfall //Emberfall: An ash storm passes by, resulting in harmless embers falling like snow. 10% to happen in place of an ash storm.
	name = "emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	weather_message = "<span class='notice'>Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...</span>"
	weather_sound = 'sound/lavaland/ash_storm_windup.ogg'
	weather_overlay = "light_ash"

	end_message = "<span class='notice'>The emberfall slows, stops. Another layer of hardened soot to the basalt beneath your feet.</span>"

	aesthetic = TRUE

	probability = 10

/datum/weather/rad_storm
	name = "radiation storm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 600
	telegraph_message = "<span class='danger'>The air begins to grow warm.</span>"

	weather_message = "<span class='userdanger'><i>You feel waves of heat wash over you! Find shelter!</i></span>"
	weather_overlay = "radiation"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "green"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 100
	end_message = "<span class='notice'>The air seems to be cooling off again.</span>"

	area_type = /area
	protected_areas = list(/area/maintenance, /area/turret_protected/ai_upload, /area/turret_protected/ai_upload_foyer, /area/turret_protected/ai)
	target_z = ZLEVEL_STATION

	immunity_type = "rad"

/datum/weather/rad_storm/impact(mob/living/L)
	if(prob(20))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.dna && H.dna.species)
				if(!(RADIMMUNE in H.dna.species.specflags))
					if(prob(50))
						randmuti(H)
						if(prob(90))
							randmutb(H)
						else
							randmutg(H)
						H.domutcheck()
		L.rad_act(20,1)

	L.adjustToxLoss(4)

/datum/weather/rad_storm/end()
	if(..())
		return
	priority_announce("The radiation threat has passed. Please return to your workplaces.", "Anomaly Alert")
	spawn(300) revoke_maint_all_access()

/datum/weather/solar_flare
	name = "solar flare"
	desc = "A solar flare from the local star knocks out power on the station."

	telegraph_duration = 300
	telegraph_message = "<span class='danger'>You feel a slight tingling in the air.</span>"

	weather_message = "<span class='userdanger'><i>Everything shuts off all at once, and the station becomes dark and lifeless.</i></span>"
	weather_duration_lower = 450
	weather_duration_upper = 1200
	weather_sound = 'sound/effects/powerdown.ogg'

	end_duration = 100
	end_message = "<span class='notice'>The buzz of electronics returns once more as the power turns back on.</span>"
	end_sound = 'sound/effects/powerup.ogg'

	area_type = /area
	protected_areas = list(/area/maintenance, /area/turret_protected/ai_upload, /area/turret_protected/ai_upload_foyer, /area/turret_protected/ai)
	target_z = ZLEVEL_STATION

	immunity_type = null

/datum/weather/solar_flare/update_areas()
	for(var/V in impacted_areas)
		var/area/A = V
		if(stage == MAIN_STAGE)
			A.power_light = 0
			A.power_equip = 0
			A.power_environ = 0
			A.power_change()
			for(var/obj/machinery/power/apc/apc in machines)
				apc.shorted_old = apc.shorted
				apc.shorted = TRUE
		else
			A.power_light = 1
			A.power_equip = 1
			A.power_environ = 1
			A.power_change()
			for(var/obj/machinery/power/apc/apc in machines)
				apc.shorted = apc.shorted_old

/datum/weather/solar_flare/end()
	if(..())
		return
	addtimer(GLOBAL_PROC, "priority_announce", 60, FALSE, "The solar flare has ended. We apologize for the inconvenience.", "Anomaly Alert")
