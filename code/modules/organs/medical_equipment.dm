#define NONE 0
#define GHETTO 1
#define LOWEST_QUALITY 2
#define LOW_QUALITY 3
#define MED_QUALITY 4
#define HIGH_QUALITY 5
#define HIGHEST_QUALITY 6

#define UNGAUZABLE 1
#define UNDISINFECTABLE 2
#define PAINFUL 3
#define HIGH_PRESSURE 4

/obj/item/weapon/bandage
	var/pressure = 0 		// 50% pressure = 50% less blood loss, 175% recovery/hemostasis time.
	var/coverage = 0 		// Chance to block potential infections.
	var/recovery = 0 		// 10 = 110% recovery speed (does not help with bleeding)

	//Absorption- Default: 40% absorbed, 30% lost, 30% saved
	var/quality = 0			// Flat addition to amount of blood stopped. 4
	var/absorption = 0 		// Max ml/tick absorbed
	var/thickness = 0     	// Max % of blood loss can absorb.
	var/max_absorbed = 0 	// How much it can absorb before needing to be replaced.

	var/flags = 0

	var/absorbed = 0
	var/put_on = 0
	var/disinfected = NONE
	var/gauzed = NONE
	var/dirty = 0

/obj/item/weapon/bandage/low
	name = "bandage(low-quality)"
	desc = "A low quality bandage. Better than nothing."

	New()
		pressure = rand(1, 10)
		coverage = rand(10, 40)
		recovery = rand(1, 30)
		quality = 0
		absorption = rand(10, 30)
		thickness = rand(10, 30)
		max_absorbed = rand(1, 20)
		..()

/obj/item/weapon/bandage/basic
	name = "bandage(standard)"
	desc = "A standard bandage, used on small wounds or in a pinch."

	pressure = 10
	coverage = 40
	recovery = 30
	quality = 0
	absorption = 30
	thickness = 30
	max_absorbed = 20

/obj/item/weapon/bandage/compression
	name = "bandage(compression)"
	desc = "A compressive bandage, able to stay on for extended periods of time."

	pressure = 80
	coverage = 90
	recovery = -50
	quality = 0
	absorption = 0
	thickness = 0
	max_absorbed = 5

	flags = HIGH_PRESSURE

/obj/item/weapon/bandage/elastic
	name = "bandage(elastic)"
	desc = "A bandage made with elastic, used to treat large bleeding wounds. Needs changing often."

	pressure = 50
	coverage = 60
	recovery = 50 // 125% recovery time.
	quality = 25
	absorption = 20
	thickness = 50
	max_absorbed = 35

/obj/item/weapon/bandage/high_quality
	name = "bandage(high-quality)"
	desc = "A high-quality bandage, applicable in most situations"

	pressure = 50
	coverage = 80
	recovery = 90
	quality = 20
	absorption = 100
	thickness = 100
	max_absorbed = 50

/obj/item/weapon/bandage/heat_patch
	name = "heat patch"
	desc = "A patch used to lower swelling and heal abrasions or sealed cuts."

	pressure = 0
	coverage = 60
	recovery = 50
	quality = 0
	absorption = 5
	thickness = 10
	max_absorbed = 10

	flags = UNGAUZABLE

/obj/item/weapon/bandage/tournequit
	name = "turnequit"
	desc = "A temporary measure to stop bleeding or in an emergency"

	presure = 100
	coverage = 80
	recovery = -100
	quality = 0
	absorption = 0
	thickness = 0
	max_absorbed = 5

	flags = UNGAUZABLE | UNDISINFECTABLE | PAINFUL | HIGH_PRESSURE

/obj/item/weapon/bandage/absorbant
	name = "bandage(absorbant)"
	desc = "An absorbant bandage, excels at stopping blood loss."

	pressure = 10
	coverage = 60
	recovery = 20
	quality = 25
	absorption = 200
	thickness = 100
	max_absorbed = 60

/obj/item/weapon/bandage/emergency
	name = "bandage(emergency)"
	desc = "A small packaged bandage for emergencies."

	pressure = 0
	coverage = 30
	recovery = -20
	quality = 0
	absorption = 150
	thickness = 100
	max_absorbed = 40

	flags = UNGAUZABLE | UNDISINFECTABLE

/obj/item/weapon/bandage/experimetal
	name = "bandage(experimental)"
	desc = "A weirdly shaped bandage. You have no idea where this would be used."

	New() // Can be no worse than a basic bandage.
		pressure = rand(10,60)
		coverage = rand(10, 100)
		recovery = rand(10, 50)
		quality = rand(5, 45)
		absorption = rand(5,500)
		thickness = rand(30,100)
		max_absorbed = rand(20,100)
		..()

