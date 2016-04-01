/obj/item/organ/tissue
	var/count = 0

/obj/item/organ/tissue/proc/absorb_damage(var/obj/item/organ/O, var/obj/W, var/brute, var/burn, var/autopsy_desc)
	var/brute_absorption =relative_density/0.25 *relative_thickness * structure/max_structure * tensile_strength * 0.01
	var/heat_absorption =relative_size/0.5 *relative_thickness * 0.01
	var/brute_d = brute*brute_absorption
	var/burn_d = burn*burn_absorption
	var/list/remainders = take_damage(O, W, brute_d, burn_d, autopsy_desc, special_effects)
	brute -= (brute_d - remainders["brute"])
	burn -= (burn_d - remainders["burn"])
	return list("brute" = brute, "burn" = burn)

/obj/item/organ/tissue/fat
	name = "fat blob"
	desc = "A blob of fat. Ew?"

	pain_receptors = 0.6
	neural_receptors = 0
	tissue_layer = FAT_LAYER
	blood_loss_rate = 0.7
	heal_rate = 0.6
	infection_resistance = 0.4
	conductivity = 0.6

	brute_mod = 1
	burn_mod = 2
	tensile_strength = 2
	relative_density = 0.75 // 28% brute absorption
	relative_thickness = 3.9 // 39% burn absorption
	relative_size = 5 // 15hp
	material = "fat"

/obj/item/organ/tissue/muscle
	name = "muscle"
	desc = "A strand of... Muscle..?"

	pain_receptors = 1.6
	neural_receptors = 10
	tissue_layer = MUSCLE_LAYER
	blood_loss_rate = 2
	heal_rate = 0.4
	infection_resistance = 5.3 // Nearly impossible to infect
	conductivity = 0.75

	brute_mod = 1
	burn_mod = 1.2
	tensile_strength = 1.5
	relative_density = 1.88 // 33% brute absorption
	relative_thickness = 3 // 30% burn absoption
	relative_size = 5 // 28hp
	material = "muscle"

/obj/item/organ/tissue/muscle/connective
	name = "connective tissue"
	desc = "Is it a tendon, or a ligmanent?"

	pain_receptors = 3 // Thats gotta hurt.
	neural_receptors = 0.5
	tissue_layer = CONNECTIVE_LAYER
	blood_loss_rate = 1.6
	heal_rate = 0.1
	infection_resistance = 3.2
	conductivity = 0.4

	brute_mod = 1
	burn_mod = 1
	tensile_strength = 1.5
	relative_density = 1.22
	relative_thickness = 0.9
	relative_size = 0.4
	material = "connective tissue"

	var/obj/item/organ/connected_to

/obj/item/organ/tissue/muscle/cardiac
	name = "cardiovascular muscle"
	desc = "This looks important"

	pain_receptors = 4 // Thats gotta hurt.
	neural_receptors = 1.8 //If 10 electric damage, 29% chance to spasm
	tissue_layer = CONNECTIVE_LAYER
	blood_loss_rate = 4
	heal_rate = 0
	infection_resistance = 2.1
	conductivity = 0.8

	brute_mod = 1
	burn_mod = 1
	tensile_strength = 0.8
	relative_density = 0.62 // 1% brute absorption
	relative_thickness = 0.7 // 1% burn absorption
	relative_size = 0.27 // 1hp
	material = "muscle"

	function["blood_pumping"] = list("efficiency" = 25)

/obj/item/organ/tissue/skin
	name = "skin"
	desc = "A flap of loose skin. Gross."

	pain_receptors = 0.4
	neural_receptors = 0
	tissue_layer = SKIN_LAYER
	blood_loss_rate = 0.2
	heal_rate = 1.5
	infection_resistance = 0 // Let's just pretend that the skin is impenetrable to bacteria.
	conductivity = 0.7

	brute_mod = 0.9
	burn_mod = 0.9
	burn_potential = 1.5
	tensile_strength = 2
	relative_density = 2 // 70% brute absorption
	relative_thickness = 4.4  // 72% heat absorption
	relative_size = 5.5 // 48hp
	material = "skin"

/obj/item/organ/tissue/bone
	name = "bone"
	desc = "A solid bone."

	pain_receptors = 0.4
	neural_receptors = 0
	tissue_layer = STRUCTURE_LAYER
	blood_loss_rate = 0.2
	heal_rate = 1.5
	infection_resistance = 0 // Let's just pretend that the skin is impenetrable to bacteria.
	conductivity = 0.7

	brute_mod = 0.9
	burn_mod = 0.9
	burn_potential = 0.5
	tensile_strength = 1.2
	relative_density = 3.66 // 88% brute absorption
	relative_thickness = 5 // 13% heat absorption
	relative_size = 2.5 // 46hp
	material = "bone"

/obj/item/organ/tissue/bone/thin
	name = "bone"
	desc = "A thin bone."

	pain_receptors = 0.4
	neural_receptors = 0
	tissue_layer = STRUCTURE_LAYER
	blood_loss_rate = 0.2
	heal_rate = 1.5
	infection_resistance = 0 // Let's just pretend that the skin is impenetrable to bacteria.
	conductivity = 0.7

	brute_mod = 0.9
	burn_mod = 0.9
	burn_potential = 0.5
	tensile_strength = 1.2
	relative_density = 3.66 // 49% brute absorption
	relative_thickness = 2.8 // 6% heat absorption
	relative_size = 2.2 // 23hp
	material = "bone"

/obj/item/organ/tissue/bone/thick
	name = "bone"
	desc = "A solid bone."

	pain_receptors = 0.4
	neural_receptors = 0
	tissue_layer = SKIN_LAYER
	blood_loss_rate = 0.2
	heal_rate = 1.5
	infection_resistance = 0 // Let's just pretend that the skin is impenetrable to bacteria.
	conductivity = 0.7

	brute_mod = 0.9
	burn_mod = 0.9
	burn_potential = 0.5
	tensile_strength = 1.5
	relative_density = 3.66 // 131% brute absorption
	relative_thickness = 6 // 13% heat absorption
	relative_size = 2.5 // 46hp
	material = "bone"



