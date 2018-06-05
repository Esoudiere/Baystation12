/obj/machinery/atmospherics/trinary/filt
	icon = 'icons/atmos/filter.dmi'
	icon_state = "map"
	density = 0
	level = 1

	name = "Gas filt"

	use_power = 1
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	power_rating = 7500	//This also doubles as a measure of how powerful the filt is, in Watts. 7500 W ~ 10 HP

	var/temp = null // -- TLE

	var/set_flow_rate = ATMOS_DEFAULT_VOLUME_filt

	/*
	filt types:
	-1: Nothing
	 0: Phoron: Phoron, Oxygen Agent B
	 1: Oxygen: Oxygen ONLY
	 2: Nitrogen: Nitrogen ONLY
	 3: Carbon Dioxide: Carbon Dioxide ONLY
	 4: Sleeping Agent (N2O)
	*/
	var/filt_type = -1
	var/list/filted_out = list()


	var/frequency = 0
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/trinary/filt/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/trinary/filt/New()
	..()
	switch(filt_type)
		if(0) //removing hydrocarbons
			filted_out = list("phoron")
		if(1) //removing O2
			filted_out = list("oxygen")
		if(2) //removing N2
			filted_out = list("nitrogen")
		if(3) //removing CO2
			filted_out = list("carbon_dioxide")
		if(4)//removing N2O
			filted_out = list("sleeping_agent")

	air1.volume = ATMOS_DEFAULT_VOLUME_filt
	air2.volume = ATMOS_DEFAULT_VOLUME_filt
	air3.volume = ATMOS_DEFAULT_VOLUME_filt

/obj/machinery/atmospherics/trinary/filt/update_icon()
	if(istype(src, /obj/machinery/atmospherics/trinary/filt/m_filt))
		icon_state = "m"
	else
		icon_state = ""

	if(!powered())
		icon_state += "off"
	else if(node2 && node3 && node1)
		icon_state += use_power ? "on" : "off"
	else
		icon_state += "off"
		use_power = 0

/obj/machinery/atmospherics/trinary/filt/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, node1, turn(dir, -180))

		if(istype(src, /obj/machinery/atmospherics/trinary/filt/m_filt))
			add_underlay(T, node2, turn(dir, 90))
		else
			add_underlay(T, node2, turn(dir, -90))

		add_underlay(T, node3, dir)

/obj/machinery/atmospherics/trinary/filt/hide(var/i)
	update_underlays()

/obj/machinery/atmospherics/trinary/filt/process()
	..()

	last_power_draw = 0
	last_flow_rate = 0

	if((stat & (NOPOWER|BROKEN)) || !use_power)
		return

	//Figure out the amount of moles to transfer
	var/transfer_moles = (set_flow_rate/air1.volume)*air1.total_moles

	var/power_draw = -1
	if (transfer_moles > MINIMUM_MOLES_TO_filt)
		power_draw = filt_gas(src, filted_out, air1, air2, air3, transfer_moles, power_rating)

		if(network2)
			network2.update = 1

		if(network3)
			network3.update = 1

		if(network1)
			network1.update = 1

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power(power_draw)

	return 1

/obj/machinery/atmospherics/trinary/filt/initialize()
	set_frequency(frequency)
	..()

/obj/machinery/atmospherics/trinary/filt/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		to_chat(user, "<span class='warning'>You cannot unwrench \the [src], it too exerted due to internal pressure.</span>")
		add_fingerprint(user)
		return 1
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (do_after(user, 40, src))
		user.visible_message( \
			"<span class='notice'>\The [user] unfastens \the [src].</span>", \
			"<span class='notice'>You have unfastened \the [src].</span>", \
			"You hear a ratchet.")
		new /obj/item/pipe(loc, make_from=src)
		qdel(src)


/obj/machinery/atmospherics/trinary/filt/attack_hand(user as mob) // -- TLE
	if(..())
		return

	if(!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	var/dat
	var/current_filt_type
	switch(filt_type)
		if(0)
			current_filt_type = "Phoron"
		if(1)
			current_filt_type = "Oxygen"
		if(2)
			current_filt_type = "Nitrogen"
		if(3)
			current_filt_type = "Carbon Dioxide"
		if(4)
			current_filt_type = "Nitrous Oxide"
		if(-1)
			current_filt_type = "Nothing"
		else
			current_filt_type = "ERROR - Report this bug to the admin, please!"

	dat += {"
			<b>Power: </b><a href='?src=\ref[src];power=1'>[use_power?"On":"Off"]</a><br>
			<b>filting: </b>[current_filt_type]<br><HR>
			<h4>Set filt Type:</h4>
			<A href='?src=\ref[src];filtset=0'>Phoron</A><BR>
			<A href='?src=\ref[src];filtset=1'>Oxygen</A><BR>
			<A href='?src=\ref[src];filtset=2'>Nitrogen</A><BR>
			<A href='?src=\ref[src];filtset=3'>Carbon Dioxide</A><BR>
			<A href='?src=\ref[src];filtset=4'>Nitrous Oxide</A><BR>
			<A href='?src=\ref[src];filtset=-1'>Nothing</A><BR>
			<HR>
			<B>Set Flow Rate Limit:</B>
			[src.set_flow_rate]L/s | <a href='?src=\ref[src];set_flow_rate=1'>Change</a><BR>
			<B>Flow rate: </B>[round(last_flow_rate, 0.1)]L/s
			"}

	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_filt")
	onclose(user, "atmo_filt")
	return

/obj/machinery/atmospherics/trinary/filt/Topic(href, href_list) // -- TLE
	if(..())
		return 1
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["filtset"])
		filt_type = text2num(href_list["filtset"])

		filted_out.Cut()	//no need to create new lists unnecessarily
		switch(filt_type)
			if(0) //removing hydrocarbons
				filted_out += "phoron"
			if(1) //removing O2
				filted_out += "oxygen"
			if(2) //removing N2
				filted_out += "nitrogen"
			if(3) //removing CO2
				filted_out += "carbon_dioxide"
			if(4)//removing N2O
				filted_out += "sleeping_agent"

	if (href_list["temp"])
		src.temp = null
	if(href_list["set_flow_rate"])
		var/new_flow_rate = input(usr,"Enter new flow rate (0-[air1.volume]L/s)","Flow Rate Control",src.set_flow_rate) as num
		src.set_flow_rate = max(0, min(air1.volume, new_flow_rate))
	if(href_list["power"])
		use_power=!use_power
	src.update_icon()
	src.updateUsrDialog()
/*
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
*/
	return

/obj/machinery/atmospherics/trinary/filt/m_filt
	icon_state = "mmap"

	dir = SOUTH
	initialize_directions = SOUTH|NORTH|EAST

obj/machinery/atmospherics/trinary/filt/m_filt/New()
	..()
	switch(dir)
		if(NORTH)
			initialize_directions = WEST|NORTH|SOUTH
		if(SOUTH)
			initialize_directions = SOUTH|EAST|NORTH
		if(EAST)
			initialize_directions = EAST|WEST|NORTH
		if(WEST)
			initialize_directions = WEST|SOUTH|EAST

/obj/machinery/atmospherics/trinary/filt/m_filt/initialize()
	set_frequency(frequency)

	if(node1 && node2 && node3) return

	var/node1_connect = turn(dir, -180)
	var/node2_connect = turn(dir, 90)
	var/node3_connect = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			node2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
		if(target.initialize_directions & get_dir(target,src))
			node3 = target
			break

	update_icon()
	update_underlays()
