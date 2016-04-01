/datum/wound
	var/blood_loss_rate = 0
	var/blood_loss_cycle = 0
	var/damtype = BLUNT // BLUNT | CUT | BURN | SPECIAL
	var/damage = 0
	var/created = 0

	var/obj/item/weapon/bandage
	var/clamped = 0

	var/obj/item/organ/holder
	var/datum/organ_controller/control

	var/infection_chance = 0
	var/desc = "wound"

	New(var/obj/item/organ/O, var/damage as num, var/additional)
		if(!damage || !O) return
		created = world.time
		src.damage = damage
		holder = O
		initialise(additional)

	proc/initialise(var/additional = 0)
		blood_loss_rate = additional
		switch(damtype)
			if(CUT)
				blood_loss_rate = damage * 1.5
			if(BRUTE)
				if(damage >= 15)
					blood_loss_rate = damage / 2
			else
				blood_loss_rate = damage
		blood_loss_rate *= holder.blood_loss_rate
		blood_loss_cycles = rand(damage/2,damage*2)
		infection_chance = blood_loss_rate
		desc = description()

	proc/description()
		switch(damtype)
			if(CUT)
				switch(damage)
					if(1 to 5)
						return "small cut"
					if(6 to 10)
						return


/** CUTS **/
/datum/wound/cut/small
	// link wound descriptions to amounts of damage
	// Minor cuts have max_bleeding_stage set to the stage that bears the wound type's name.
	// The major cut types have the max_bleeding_stage set to the clot stage (which is accordingly given the "blood soaked" descriptor).
	max_bleeding_stage = 3
	stages = list("ugly ripped cut" = 20, "ripped cut" = 10, "cut" = 5, "healing cut" = 2, "small scab" = 0)
	damage_type = CUT

/datum/wound/cut/deep
	max_bleeding_stage = 3
	stages = list("ugly deep ripped cut" = 25, "deep ripped cut" = 20, "deep cut" = 15, "clotted cut" = 8, "scab" = 2, "fresh skin" = 0)
	damage_type = CUT

/datum/wound/cut/flesh
	max_bleeding_stage = 4
	stages = list("ugly ripped flesh wound" = 35, "ugly flesh wound" = 30, "flesh wound" = 25, "blood soaked clot" = 15, "large scab" = 5, "fresh skin" = 0)
	damage_type = CUT

/datum/wound/cut/gaping
	max_bleeding_stage = 3
	stages = list("gaping wound" = 50, "large blood soaked clot" = 25, "blood soaked clot" = 15, "small angry scar" = 5, "small straight scar" = 0)
	damage_type = CUT

/datum/wound/cut/gaping_big
	max_bleeding_stage = 3
	stages = list("big gaping wound" = 60, "healing gaping wound" = 40, "large blood soaked clot" = 25, "large angry scar" = 10, "large straight scar" = 0)
	damage_type = CUT

datum/wound/cut/massive
	max_bleeding_stage = 3
	stages = list("massive wound" = 70, "massive healing wound" = 50, "massive blood soaked clot" = 25, "massive angry scar" = 10,  "massive jagged scar" = 0)
	damage_type = CUT

/** BRUISES **/
/datum/wound/bruise
	stages = list("monumental bruise" = 80, "huge bruise" = 50, "large bruise" = 30,
				  "moderate bruise" = 20, "small bruise" = 10, "tiny bruise" = 5)
	max_bleeding_stage = 3 //only large bruise and above can bleed.
	autoheal_cutoff = 30
	damage_type = BRUISE

/** BURNS **/
/datum/wound/burn/moderate
	stages = list("ripped burn" = 10, "moderate burn" = 5, "healing moderate burn" = 2, "fresh skin" = 0)
	damage_type = BURN

/datum/wound/burn/large
	stages = list("ripped large burn" = 20, "large burn" = 15, "healing large burn" = 5, "fresh skin" = 0)
	damage_type = BURN

/datum/wound/burn/severe
	stages = list("ripped severe burn" = 35, "severe burn" = 30, "healing severe burn" = 10, "burn scar" = 0)
	damage_type = BURN

/datum/wound/burn/deep
	stages = list("ripped deep burn" = 45, "deep burn" = 40, "healing deep burn" = 15,  "large burn scar" = 0)
	damage_type = BURN

/datum/wound/burn/carbonised
	stages = list("carbonised area" = 50, "healing carbonised area" = 20, "massive burn scar" = 0)
	damage_type = BURN





