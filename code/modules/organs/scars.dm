/datum/scar
	var/damage = 0
	var/damtype = BRUTE // BURN
	var/description = ""
	var/obj/item/organ/holder

	New(dam, type, /obj/item/organ/O) // It's easier
		damage = dam
		damtype = type
		holder = O
		description = description()

	proc/description()
		switch(damtype)
			if(BRUTE)
				if(1 to 2)
					return "small scar"
				if(2 to 5)
					return "straight scar"
				if(5 to 8)
					return "deep scar"
				if(8 to 10)
					return "large ugly scar"
				if(10 to 15)
					return "jagged scar"
				if(15 to 25)
					return	"deep jagged scar"
				if(25 to 35)
					return "multiple deep scars"
				if(35 to INFINITY)
					return "multiple jagged scars"
			if(BURN)
				if(1 to 2)
					return "damaged skin"
				if(2 to 5)
					return "small burn scar"
				if(5 to 8)
					return "burn scar"
				if(8 to 10)
					return "ugly burn scar"
				if(10 to 15)
					return "large ugly burn scar"
				if(15 to 25)
					return "severe ugly burn scar"
				if(25 to 35)
					return "multiple burn scars"
				if(35 to INFINITY)
					return "multiple severe burn scars"

