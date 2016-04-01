/datum/organ_controller

	var/list/organs = list()

	var/mob/living/carbon/holder

	var/list/organs_to_process = list()
	var/list/infected_organs = list()

	var/const/tick_delay = 10 // How many mob.life() ticks before updating organs fully.
	var/ticks = 0

	var/infections_processing = 1
	var/organ_processing = 1
	var/damage_processing = 1
	var/blood_loss = 1


	var/list/functions = list()
	functions["breathing"] = list("efficiency" = 100)
	functions["filtration"] = list("efficiency" = 100)
	functions["blood_pumping"] = list("efficiency" = 100)
	functions["metabolism"] = list("efficiency" = 100)
	functions["conciousness"] = list("efficiency" = 100)
	functions["eating"] = list("efficiency" = 100)
	functions["moving"] = list("efficiency" = 100)
	functions["manipulation"] = list("efficiency" = 100)
	functions["hearing"] = list("efficiency" = 100)
	functions["speaking"] = list("efficiency" = 100)
	functions["sight"] = list("efficiency" = 100)
	functions["taste"] = list("efficiency" = 100)
	functions["speaking"] = list("efficiency" = 100)
	functions["regeneration"] = list("efficiency" = 100)
	functions["verterbrae"] = list("efficiency" = 100)


	proc/handle_infections()
		for(var/obj/item/organ/O in infected_organs)
			for(var/datum/infection/I in O.infections)
				I.process()

	proc/check_organs(var/obj/item/organ/to_check)
		spawn(0)
		if(!organ_processing) return
		if(!to_check) // We don't know which organ to check, so let's check all of them!
			organs_to_process.Cut()
			for(var/obj/item/organ/O in organs)
				if(O.force_processing ||\ // One of these shouldn't be without most of the others, but just incase.
				   O.efficiency < max_efficiency ||\
				   O.needs_processing ||\
				   O.infections.len ||\
				   O.structure < O.max_structure ||\
				   O.bleeding )
				   	organs_to_process.Add(O)
				if(O.infections.len)
					infected_organs.Add(O)
		else if(!(to_check in organs_to_process || to_check in infected_organs))
			if(to_check.force_processing||\
			   to_check.efficiency < max_efficiency||\
			   to_check.needs_processing||\
			   to_check.infections.len||\
			   to_check.structure < O.max_structure||\
			   to_check.bleeding)
				organs_to_process.Add(O)
			if(to_check.infections.len)
				infected_organs.Add(O)

	proc/update()
		if(!organ_processing || !organs_to_process.len) return
		handle_infections()
		ticks++
		if(ticks < tick_delay)
			check_organs()
		var/obj/item/organ/O = organs_to_process[1]
		organs_to_process.Cut(1,2)
		if(O.process()) // If it still needs processing, append it to the list.
			organs_to_process.Add(O)



	proc/electric_current(var/damage = 0)
		if(damage)
			for(var/obj/item/organ/O in organs)
				if(prob(neural_receptors/0.5*conductivity*damage))
					O.spasm()
					spawn(0)
						check_organs(O)

	New(var/mob/living/carbon/holder)
		..()
		holder.organ_controller = src
		src.holder = holder
		for(var/obj/item/organ/O in organs)
			O = new(holder)
			O.controller = src

/datum/organ_controller/human




