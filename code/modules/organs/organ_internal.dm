/obj/item/organ/internal/heart
	name = "heart"
	desc = "A heart. Looks bloody."

	can_scar = 1

	pain_receptors = 0.7
	neural_receptors = 0
	tissue_layer = INTERNAL_LAYER
	blood_loss_rate = 3 //The muscles do most the bleeding.
	heal_rate = 0
	infection_resistance = 1.2
	conductivity = 0

	brute_mod = 1
	burn_mod = 1
	tensile_strength = 0.6
	relative_density = 1.2 // 11% brute absorption
	relative_thickness = 2.1 // 15% heat absorption
	relative_size = 3.6 // 9hp
	material = "muscle"
	flags = HAS_MAJOR_ARTERY | HAS_ARTERY | HAS_MINOR_ARTERY | CANNOT_BLISTER | CANNOT_SWELL

	default_tissues = list(/obj/item/organ/tissue/muscle/cardiac = 4)

/obj/item/organ/internal/lungs
	name = "lungs"
	desc = "A pair of lungs. They look spongy."

	can_scar = 0

	pain_receptors = 0.4
	neural_receptors = 0.2 // I guess the lungs can spasm?
	tissue_layer = INTERNAL_LAYER
	blood_loss_rate = 0.8
	heal_rate = 0
	infection_resistance = 1
	conductivity = 0.4

	brute_mod = 0.9
	burn_mod = 5 // I'm guessing sacs producing oxygen would burn easily enough.
	tensile_strength = 0.3
	relative_density = 1 // 4% brute absorption
	relative_thickness = 3.2 // 29% heat absorption
	relative_size = 4.6 // 15hp
	material = "flesh"

	functions["breathing"] = list("efficiency" = 100)

/obj/item/organ/internal/stomach
	name = "stomach"
	desc = "A stomach. Looks a bit chubby."

	can_scar = 0

	pain_receptors = 0.4
	neural_receptors = 1.2
	tissue_layer = INTERNAL_LAYER
	blood_loss_rate = 0.8
	heal_rate = 0
	infection_resistance = 1
	conductivity = 0.4

	brute_mod = 1
	burn_mod = 1
	tensile_strength = 0.7
	relative_density = 1.6 // 18% brute absorption
	relative_thickness = 4 // 32% heat absorption
	relative_size = 4 // 26hp
	material = "flesh"

	functions["metabolism"] = list("efficiency" = 80)
	functions["eating"] = list("efficiency" = 50) // It'd be pretty hard to swallow without a functioning stomach, y'know.

/obj/item/organ/internal/spleen
	name = "spleen"
	desc = "A spleen. Looks squishy"

	can_scar = 0

	pain_receptors = 1
	neural_receptors = 0
	tissue_layer = INTERNAL_LAYER
	blood_loss_rate = 0.8
	heal_rate = 0
	infection_resistance = 1
	conductivity = 0

	brute_mod = 1
	burn_mod = 1
	tensile_strength = 0.7
	relative_density = 1.6 // 18% brute absorption
	relative_thickness = 4 // 32% heat absorption
	relative_size = 4 // 26hp
	material = "flesh"

	functions["metabolism"] = list("efficiency" = 80)
	functions["eating"] = list("efficiency" = 50) // It'd be pretty hard to swallow without a functioning stomach, y'know.


