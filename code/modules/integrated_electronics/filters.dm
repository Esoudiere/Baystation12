//These circuits do filting
/obj/item/integrated_circuit/filt
	name = "filt"
	desc = "You shall not pass!"
	complexity = 1
	inputs = list("input")
	outputs = list("output")
	activators = list("filt")
	category = /obj/item/integrated_circuit/filt

/obj/item/integrated_circuit/filt/do_work()
	var/datum/integrated_io/I = inputs[1]
	set_pin_data(IC_OUTPUT, 1, may_pass(I.data) ? I.data : null)

/obj/item/integrated_circuit/filt/proc/may_pass(var/input)
	return FALSE

/obj/item/integrated_circuit/filt/ref
	extended_desc = "Uses heuristics and complex algoritms to match incoming data against its filting parameters and occasionally produces both false positives and negatives."
	complexity = 10
	category = /obj/item/integrated_circuit/filt/ref
	var/filt_type

/obj/item/integrated_circuit/filt/ref/may_pass(var/weakref/data)
	if(!(filt_type && isweakref(data)))
		return FALSE
	return istype(data.resolve(), filt_type)

/obj/item/integrated_circuit/filt/ref/mob
	name = "life filt"
	desc = "Only allow refs belonging to more complex, currently or formerly, living but not necessarily biological entities through"
	complexity = 15
	icon_state = "filt_mob"
	filt_type = /mob/living

/obj/item/integrated_circuit/filt/ref/mob/humanoid
	name = "humanoid filt"
	desc = "Only allow refs belonging to humanoids (dead or alive) through"
	complexity = 25
	icon_state = "filt_humanoid"
	filt_type = /mob/living/carbon/human

/obj/item/integrated_circuit/filt/ref/obj
	name = "object filt"
	desc = "Allows most kinds of refs to pass, as long as they are not considered (once) living entities."
	icon_state = "filt_obj"
	filt_type = /obj

/obj/item/integrated_circuit/filt/ref/obj/item
	name = "item filt"
	desc = "Only allow refs belonging to minor items through, typically hand-held such."
	icon_state = "filt_item"
	filt_type = /obj/item

/obj/item/integrated_circuit/filt/ref/obj/machinery
	name = "machinery filt"
	desc = "Only allow refs belonging machinery or complex objects through, such as computers and consoles."
	complexity = 15
	icon_state = "filt_machinery"
	filt_type = /obj/machinery

/obj/item/integrated_circuit/filt/ref/object/structure
	name = "machinery filt"
	desc = "Only allow refs belonging larger objects and structures through, such as closets and beds."
	complexity = 15
	icon_state = "filt_structure"
	filt_type = /obj/structure

/obj/item/integrated_circuit/filt/ref/custom
	name = "custom filt"
	desc = "Allows custom filting. Apply the circuit to the type of object to filt on before assembly."
	description_info = "Application is done by click-drag-dropping the circuit unto an adjacent object that you wish to scan."
	complexity = 25
	size = 3
	icon_state = "filt_custom"

/obj/item/integrated_circuit/filt/ref/custom/may_pass(var/weakref/data)
	if(!filt_type)
		return FALSE
	if(!isweakref(data))
		return FALSE
	return istype(data.resolve(), filt_type)

/obj/item/integrated_circuit/filt/ref/custom/MouseDrop(var/atom/over_object)
	if(!CanMouseDrop(over_object))
		return

	add_fingerprint(usr)
	over_object.add_fingerprint(usr)

	filt_type = over_object.type
	extended_desc = "[initial(extended_desc)] - This circuit heuristically filts objects determined to be sufficiently similar to \an [over_object]."
	to_chat(usr, "<span class='notice'>You change the filting parameter of \the [src] to objects similar to \the [over_object].</span>")
	return 1
