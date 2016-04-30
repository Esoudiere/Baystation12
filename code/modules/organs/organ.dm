//Layers - Specific organ based
#define SKIN_LAYER 1			//Any external tissues
#define FAT_LAYER 2				//Similar to the skin, "protective" but should cause more pain/bleeding
#define MUSCLE_LAYER 3			//Real damage begins here
#define CONNECTIVE_LAYER 4		//Connects parts together (tendons)
#define STRUCTURE_LAYER 5		//Skeletal structure
#define TISSUE_LAYER 6			//Mostly protective or cushioning muscles/fats around the organs
#define INTERNAL_LAYER 7		//For organs (E.G. heart)
#define INTERAL_TISSUE_LAYER 8	//Behind the organs, I guess.
//Special damage types.
#define SPECIAL_ELECTRIC 1 		// Does alot of internal damage
#define SPECIAL_TOXIC 2	   		// Raises toxicity
#define SPECIAL_MUTATION 3 		// Mutates
#define SPECIAL_CORROSSIVE 4	// Burns through each layer entirely before continuing
#define SPECIAL_PIERCE 5		// Pierces easily.
#define SPECIAL_EXPLOSIVE 6		// Mostly surface damage
#define SPECIAL_PROJECTILE 7	// Self-explanatory
//Flags
#define HAS_MINOR_ARTERY 1		// Adds a flat 2 to blood loss rate
#define HAS_ARTERY 2			// Adds a flat 5 to blood loss rate
#define HAS_MAJOR_ARTERY 4		// Adds a flat 10 to blood loss rate (Sometimes fatal just on its own.)
#define CANNOT_SCAR	8			// Removes the possibility of scarring
#define CANNOT_SWELL 16			// Excessive brute damage causes swelling. (Pain, layer damage, faster healing)
#define CANNOT_BLISTER	 32		// Excessive burn damage causes blisters.  (Lots of pain, faster healing)





/obj/item/organ
	name = "squishy blob"
	desc = "A squishy blob, ew."

	var/list/damage_text = list()
	damage_text["brute"] = list("It looks bruised!" = 25,\
						   		"It looks heavily bruised!" = 50,\
						   		"It looks torn apart!" = 75, \
						   		"It has been pulped!" = 100)
	damage_text["burn"] = list( "It looks slightly singed!" = 25,\
								"It looks burned!" = 50,\
								"It looks heavily burned!" = 75,\
								"It looks scorched and black!" = 100)
	damage_text["oxy"] = list(  "It looks lifeless" = 100)
	damage_text["tox"] = list(  "It looks slightly green" = 33, \
								"It looks extremely green" = 66, \
								"It looks swollen and clotted" = 100)
	var/scar_lower_threshold = 50//50% of max_structure
	var/scar_upper_threshold = 90

	var/flags = 0

	var/list/default_tissues = list()
	var/pain_receptors = 2 				// Multiplier
	var/neural_receptors = 1 			// The more neural receptors, the higher chance of spasm and quicker recovery from spasms.
	var/tissue_layer = FAT_LAYER+0.5 	// Comes into play when something is damaged.
	var/blood_loss_rate = 0.5 			// Multiplier.
	var/heal_rate = 1		  			// Multiplier
	var/infection_resistance = 1 		// Multiplier
	var/conductivity = 0				// Multiplier
	var/brute_mod = 1					// Multiplier
	var/burn_mod = 1					// Multiplier
	// For a rough idea, bones are about 3.66g/cm^2, 5cm thick, 3.5dm long.

	var/burn_potential = 1 // Multiplier for burn absorption
	var/tensile_strength = 1 // Multiplier for brute absorption

	var/relative_density = 1 //g/cm^2
	var/relative_thickness = 1 //cm
	var/relative_size = 1 // dm
	var/material = "flesh"

	var/efficiency = 100

	var/max_antibody_count = 10

	var/list/functions = list()
	var/message_cooldown = 0
//	functions["example"]["efficiency"] = 100


//Runtime variables. You shouldn't need to change these.

	var/structure = 100
	var/max_structure = 100
	var/list/infections = list()
	var/datum/organ_controller/control
	var/antibody_count = 0
	var/efficiency = 100
	var/needs_processing = 0
	var/force_processing = 0 // Debug var
	var/list/implants = list()
	var/list/wounds = list()
	var/bleeding = 0
	var/bleeding_time = 0
	var/bleeding_cycles = 0
	var/heal_cycles = 0
	var/obj/item/organ/holder_organ
	var/list/organs = list()
	var/burn_damage = 0
	var/brute_damage = 0
	var/list/autopsy_details = list()
	var/list/tissues = list()
	var/scar_damage = 0
	var/list/scars = list()
	var/open = 0
	var/obj/item/weapon/bandage/bandage

	var/last_message = 0

/obj/item/organ/receive_damage(var/obj/W, var/brute, var/burn, var/brute_type = BRUTE, var/autopsy_desc, var/initbrute=0, var/initburn=0)// None of this is really that realistic, I know.
	needs_processing = 1
	if(!controller.damage_processing) return
	update_structure()
	if(!initbrute) initbrute = brute
	if(!initburn) initburn = burn
	var/brute_absorption = 0
	//Cuts are not affected by thickness, and so get through skin and the like extremely easily.
	if(brute_type == BRUTE)
		brute_absorption = relative_density/0.25 *relative_thickness * structure/max_structure * tensile_strength * 0.01 // Reduce it to a percentage
	else
		brute_absorption = relative_density/0.08 * structure/max_structure * tensile_strength * 0.01
	var/heat_absorption =relative_size/0.5 *relative_thickness * structure/max_structure * burn_potential * 0.01 // Heat often spreads evenly.
	var/brute_d = initbrute*brute_absorption
	var/burn_d = initburn*burn_absorption
	var/list/remainder = take_damage(W, min(brute_d,brute), min(burn_d,burn), autopsy_desc)
	brute -= (brute_d - remainder["brute"])
	burn -= (burn_d - remainder["burn"])
	if(!brute && !burn)
		return 0
	var/obj/item/organ/O = pick_lower_layer(tissue_layer, 1)
	if(!O)
		O = get_highest_layer()
		O.take_damage(W, brute, burn, brute_type, autopsy_desc, 0) // The first layer (presumably skin) is forced to take the remaining damage.

	else
		O.receive_damage(W, brute, burn, brute_type, autopsy_desc, initbrute, initburn)

/obj/item/organ/proc/take_damage(var/obj/W, var/brute, var/burn, var/brute_type = BRUTE, var/autopsy_desc, var/remainder = 1)
	if(!controller.damage_processing) return
	var/brute_d = brute * brute_mod
	var/burn_d = burn * burn_mod
	if(!istype(src, /obj/item/organ/tissue) && open)
		for(var/obj/item/organ/tissue/T in tissues)
			if(prob((brute+burn) * T.size))
				var/list/absorbed = T.absorb_damage(src, W, brute, burn, brute_type, autopsy_desc))
				brute_d -= absorbed["brute"]
				burn_d -= absorbed["burn"]
	if(!open && !istype(src, /obj/item/organ/tissue) && (brute_type == CUT || brute > 10)  && structure < max_structure/2 && brute > structure/10)
		rip_open()
	if(brute && control.blood_loss)
		var/blood_loss = brute
		var/P = brute
		var/cycles = 1
		if(brute_type == CUT)
			P*=2
			cycles = 5
		switch(flags)
			if(HAS_MINOR_ARTERY)
				if(prob(P)) blood_loss+=2
			if(HAS_ARTERY)
				if(prob(P)) blood_loss+=5
			if(HAS_MAJOR_ARTERY)
				if(prob(P)) blood_loss+=10
		if(brute_type == BRUTE)
			if(brute >= 10)
				blood_loss /= 2
			else blood_loss = 0
		else blood_loss *= 1.5
		blood_loss *= blood_loss_rate
		bleeding = blood_loss
		bleeding_cycles = cycles * brute

	var/count = 1
	if(autopsy_desc in autopsy_details)
		count = autopsy_details[autopsy_desc][count]
		count++
	autopsy_details["[autopsy_desc]"] = list("time" = worldtime2text, "brute" = brute_d, "burn" = burn_d, "count" = count)
	update_scars()
	if(remainder)
		return list("brute" = brute_d, "burn" = burn_d)
	var/obj/item/organ/O = pick_lower_layer(tissue_layer, 1)
	if(!O) return
	O.receive_damage(W, brute_d, burn_d, autopsy_desc)

/obj/item/organ/proc/receive_special_damage(var/obj/W, var/special_damage = 0, var/special_effect = 0, var/autopsy_desc, var/init_special)
	if(special_damage && special_effect)
		update_structure()
		var/start = 0
		if(!init_special)
			init_special = special_damage
			start = 1
		switch(special_effect)
			if(SPECIAL_ELECTRIC)
				if(start)
					controller.electric_current(init_special)
				var/absorb =relative_size/0.5*thickness*(structure/max_structure)//50% of heat absorption
				absorb *= conductivity
				if(prob(absorb))
					spasm()
					controller.check_organs(src)
				special_damage -= init_special*absorb
				if(!special_damage) return
				var/obj/item/organ/O = pick_lower_layer(tissue_layer, 1)
				if(!O)
					O = get_highest_layer()
					O.take_damage(W, 0, special_damage, autopsy_desc, 0) // The rest gets burnt.
				else
					O.receive_special_damage(W, special_damage, special_effect, autopsy_desc, init_special)
//			if(SPECIAL_TOXIC)
//			if(SPECIAL_MUTATION)
			if(SPECIAL_CORROSIVE)
				var/list/remainder = take_damage(W, special_damage*0.33, special_damage*0.66, autopsy_desc)
				special_damage = 0
				special_damage += (remainder["brute"] + remainder["burn"])
				var/obj/item/organ/O = pick_lower_layer(tissue_layer, 1)
				if(O) // There shouldn't be any "upper layer".
					O.receive_special_damage(W, special_damage, special_effect, autopsy_desc, init_special)
			if(SPECIAL_PIERCE)
				var/modifified_density = 0
				if(relative_density*6 > special_damage) // E.G. In order to pierce through most bones, the damage must be >22
					modified_density = relative_density
				else modified_density = relative_density/4
				var/absorption = modified_density/0.05*relative_thickness/7.5 * structure/max_structure * tensile_strength * 0.01
				//It'll easily pierce through most soft things like skin, muscle and fat with ease.
				var/dam = init_special*brute_absorption
				var/list/remainder = take_damage(W, min(special_damage, dam), 0, autopsy_desc)
				special_damage -= (dam - remainder["brute"])
				if(!special_damage)
					return 0
				var/obj/item/organ/O = pick_lower_layer(tissue_layer, 1)
				if(!O)
					O = get_highest_layer()
					O.take_damage(W, special_damage, burn, autopsy_desc, 0)
				else
					O.receive_special_damage(W, special_damage, special_effect, autopsy_desc, init_special)
//			if(SPECIAL_EXPLOSIVE)
//			if(SPECIAL_PROJECTILE)


/obj/item/organ/proc/update_structure()
	max_structure = initial(max_structure) -= scar_damage
	structure = min(round(relative_size *relative_thickness *relative_density), max_structure)
	structure -= (brute_damage + burn_damage)

/obj/item/organ/proc/handle_bleeding()
	if(bleeding)
		bleeding_time -= 1
		if(bleeding_time <= 0)
			var/cycle_reduce = 1
			var/reduced = round(bleeding / bleeding_cycles) * 100
			if(bandage)
				cycle_reduce *= (1+bandage.recovery*0.01) * (1-bandage.pressure*0.005)
				reduced *= (1+bandage.recovery*0.01) * (1-bandage.pressure*0.005)
			bleeding_time = bleeding_cycles * (1+bandage.pressure*1.5)
		if(bleeding < 1)
			bleeding = 0
			bleeding_cycles = 0
		var/blood_to_lose = bleeding
		if(bandage)
			if(!bandage.dirty && bandage.absorbed >= bandage.max_absorbed)
				bandage.dirty = 1
				bandage.name = "dirty [initial(bandage.name)]"
				bandage.coverage = 0
			if(bandage.dirty) // Eventually wont help at all.
				if(bandage.recovery > 0) // Possible for negative values
					bandage.recovery = round(bandage.recovery / 1.5)
				if(bandage.pressure)
					bandage.pressure = round(bandage.pressure / 1.5)
				if(bandage.thickness)
					bandage.thickness = round(bandage.thickness / 1.25)
				if(bandage.absorption)
					bandage.absorption = round(bandage.absorption / 1.25)
			var/saved = 0.3 + (bandage.recovery*0.01)
			var/remaining = 1 - saved
			var/lost = (remaining *0.45) //TODO:Balance ratios
			var/absorb = (remaining * 0.55)
			var/absorbed = (blood_to_lose - min(bandage.absorption, blood_to_lose/(bandage.thickness*0.01))
			bandage.absorbed += absorbed * absorb
			blood_to_lose -= absorbed*saved
			blood_to_lose *= (1-(bandage.pressure*0.01))
		lose_blood(blood_to_lose)
	else if(structure < max_structure) // Proliferation.
		bleeding_time -= 1
		if(bleeding_time <= 0)
			if(bandage)
				structure = min(maxstructure, structure + (round(max_structure/100, 0.1) * (1+bandage.recovery*0.01) * heal_rate))
			else structure = min(maxstructure, structure + (1*heal_rate))
			if(prob(5))
				display_message("<span class='warning'>Your [external_organ()] feels itchy.</span>")
				if(prob(50))
					itch()

			bleeding_time = (bandage ? min(1, 300 -= bandage.recovery) : 300)

/obj/item/organ/proc/process()
	update_structure()
	handle_bleeding

/obj/item/organ/proc/itch()
	return 1


/obj/item/organ/New(var/obj/item/organ/O)
	if(O)
		holder_organ = O
		if(istype(src, /obj/item/organ/tissue))
			holder_organ.tissues += src
		else holder_organ.organs += src
	update_structure()
	init()
	..()

/obj/item/organ/proc/init()
	for(var/obj/item/organ/tissue/T in controller.tissues)
		if(T.type in src.default_tissues)
			src.tissues += T
//	if(!O.tissues.len && !istype(src, /obj/item/organ/tissue))
//		for(var/T in default_tissues)
//			var/num = default_tissues[T]
//			while(num)
//				T = new(src)

/obj/item/organ/proc/spasm(var/damage = 0)
	if(!damage) return
	efficiency += rand(0, neural_receptors)
	efficiency -= rand(0, damage)
	if(prob(damage*1.5))
		damage--
//	if(efficiency >= maxefficiency) // Sometimes going *above* maxefficiency for a little while is purposeful.
//		efficiency = maxefficiency
//		return
	spawn(rand(10,600)) // 1-60 seconds between spasms
		spasm(damage)

/obj/item/organ/proc/update_scars()
	scar_damage = 0
	for(var/datum/scar/S in scars)
		scar_damage += S.damage
	var/datum/scar/scar
	if(structure < (max_structure*scar_upper_threshold*0.01)*100)
		if(burn_damage > brute_damage)
			scar = new(min(burn_damage, 20), BURN, src)
			burn_damage -= min(burn_damage, 20)
		else
			scar = new(min(brute_damage,20), BRUTE, src)
			brute_damage -= min(brute_damage, 20)
	else if(structure < max_structure*scar_lower_threshold*0.01)
		var/over = (burn_damage+brute_damage) - (max_structure*scar_lower_threshold*0.01)
		var/difference = scar_lower_threshold / scar_upper_threshold
		if(prob(over * difference))
			if(burn_damage > brute_damage)
				scar = new(min(burn_damage, 20), BURN, src)
				burn_damage -= min(burn_damage, 20)
			else
				scar = new(min(brute_damage,20), BRUTE, src)
				brute_damage -= min(brute_damage, 20)
	if(scar)
		update_structure()
		for(var/datum/scar/S in scars)
			if(scars.len)
				if(S == scar) continue
				if(S.damtype != scar.damtype) continue
				(S.damage + scar.damage >= 25) continue
				S.damage += scar.damage
				del(scar)
			return
		scars.Add(scar)
		scar_damage += scar.damage

/obj/item/organ/proc/rip_open(var/external = 1)
	display_message("<span class='danger'><BIG>You feel something in your [external_organ()] rip apart!</BIG></span>",\
				    "[external ? "<span class='danger'>[control.holder]'s [src] is ripped open in a spray of blood!</span>" : ""]")
	bleeding += 5 * size * blood_loss_rate
	open = 1

/obj/item/organ/proc/apply_bandage(var/obj/item/weapon/bandage/B, var/mob/user)
	user.visible_message("<span class='notice'>[user] begins applying \the [B] to [control.holder]'s [src]</span>", "<span class='notice'>You begin applying \the [B] to [control.holder]'s [src].</span>")
	if(!do_after(user, 150)) return 0
	bandage = B
	user.drop_item()
	B.loc = src
	B.put_on = world.time














