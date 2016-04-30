// Picks an organ below src, weighted based on size.
/obj/item/organ/proc/pick_lower_layer(var/tissue_layer = FAT_LAYER, var/max_layers = 1)
	var/list/lower_organs = get_lower_layer(tissue_layer, max_layers)
	if(!lower_organs.len) return 0
	var/total_size = 0
	for(var/obj/item/organs/O in lower_organs)
		total_size += O.relevant_size
	for(var/obj/item/organs/O in lower_organs)
		if(prob(round(O.size / total_size) * 100))
			return O
	return pick(lower_organs)

//Returns a list of organs below src.
/obj/item/organ/proc/get_lower_layer(var/tissue_layer = FAT_LAYER, var/max_layers = 1)
	var/list/lower_organs = list()
	for(var/obj/item/organ/O in holder_organ.organs)
		var/dist = O.tissue_layer - src.tissue_layer
		if(dist > 0 && dist <= max_layers)
			lower_organs += O
	return lower_organs


/obj/item/organ/proc/get_highest_layer()
	var/obj/item/organ/highest
	for(var/obj/item/organ/O in holder_organ.organs)
		if(!highest || O.layer < highest.layer)
			highest = O
	return highest

/obj/item/organ/proc/external_organ()
	var/obj/item/organ/O = holder_organ
	for(var/i=1 to 20) // Incase of accidental loops.
		if(O.holder_organ)
			O = O.holder_organ
			continue
		break
	return O