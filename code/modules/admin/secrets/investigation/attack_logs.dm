/datum/admin_secret_item/investigation/attack_logs
	name = "Attack Logs"
	var/list/filts_per_client

/datum/admin_secret_item/investigation/attack_logs/New()
	..()
	filts_per_client = list()

/datum/admin_secret_item/investigation/attack_logs/execute(var/mob/user)
	. = ..()
	if(!.)
		return
	var/dat = list()
	dat += "<a href='?src=\ref[src]'>Refresh</a> | "
	dat += get_filt_html(user)
	dat += " | <a href='?src=\ref[src];reset=1'>Reset</a>"
	dat += "<HR>"
	dat += "<table border='1' style='width:100%;border-collapse:collapse;'>"
	dat += "<tr><th style='text-align:left;'>Time</th><th style='text-align:left;'>Attacker</th><th style='text-align:left;'>Intent</th><th style='text-align:left;'>Victim</th></tr>"

	for(var/log in attack_log_repository.attack_logs_)
		var/datum/attack_log/al = log
		if(filt_log(user, al))
			continue

		dat += "<tr><td>[al.station_time]</td>"

		if(al.attacker)
			dat += "<td>[al.attacker.key_name(check_if_offline = FALSE)] <a HREF='?_src_=holder;adminplayeropts=[al.attacker.ref]'>PP</a></td>"
		else
			dat += "<td></td>"

		dat += "<td>[al.intent]</td>"

		if(al.victim)
			dat += "<td>[al.victim.key_name(check_if_offline = FALSE)] <a HREF='?_src_=holder;adminplayeropts=[al.victim.ref]'>PP</a></td>"
		else
			dat += "<td></td>"

		dat += "</tr>"
		dat += "<tr><td colspan=4>[al.message]"
		if(al.location)
			dat += " <a HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[al.location.x];Y=[al.location.y];Z=[al.location.z]'>JMP</a>"
		dat += "</td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "admin_attack_logs", "Attack Logs", 800, 400)
	popup.set_content(jointext(dat, null))
	popup.open()

/datum/admin_secret_item/investigation/attack_logs/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["refresh"])
		. = 1
	if(href_list["reset"])
		reset_user_filts(usr)
		. = 1
	if(.)
		execute(usr)

/datum/admin_secret_item/investigation/attack_logs/proc/get_user_filts(var/mob/user)
	if(!user.client)
		return list()

	. = filts_per_client[user.client]
	if(!.)
		. = list()
		for(var/af_type in subtypesof(/attack_filt))
			var/attack_filt/af = af_type
			if(initial(af.category) == af_type)
				continue
			. += new af_type(src)
		filts_per_client[user.client] = .

/datum/admin_secret_item/investigation/attack_logs/proc/get_filt_html(user)
	. = list()
	for(var/filt in get_user_filts(user))
		var/attack_filt/af = filt
		. += af.get_html()
	. = jointext(.," | ")

/datum/admin_secret_item/investigation/attack_logs/proc/filt_log(user, var/datum/attack_log/al)
	for(var/filt in get_user_filts(user))
		var/attack_filt/af = filt
		if(af.filt_attack(al))
			return TRUE
	return FALSE

/datum/admin_secret_item/investigation/attack_logs/proc/reset_user_filts(user)
	for(var/filt in get_user_filts(user))
		var/attack_filt/af = filt
		af.reset()

/attack_filt
	var/category = /attack_filt
	var/datum/admin_secret_item/investigation/attack_logs/holder

/attack_filt/New(var/holder)
	..()
	src.holder = holder

/attack_filt/Topic(href, href_list)
	if(..())
		return TRUE
	if(OnTopic(href_list))
		holder.execute(usr)
		return TRUE

/attack_filt/proc/get_html()
	return

/attack_filt/proc/reset()
	return

/attack_filt/proc/filt_attack(var/datum/attack_log/al)
	return FALSE

/attack_filt/proc/OnTopic(href_list)
	return FALSE

/*
* filt logs with one or more missing clients
*/
/attack_filt/no_client
	var/filt_missing_clients = TRUE

/attack_filt/no_client/get_html()
	. = list()
	. += "Must have clients: "
	if(filt_missing_clients)
		. += "<span class='linkOn'>Yes</span><a href='?src=\ref[src];no=1'>No</a>"
	else
		. += "<a href='?src=\ref[src];yes=1'>Yes</a><span class='linkOn'>No</span>"
	. = jointext(.,null)

/attack_filt/no_client/OnTopic(href_list)
	if(href_list["yes"] && !filt_missing_clients)
		filt_missing_clients = TRUE
		return TRUE
	if(href_list["no"] && filt_missing_clients)
		filt_missing_clients = FALSE
		return TRUE

/attack_filt/no_client/reset()
	filt_missing_clients = initial(filt_missing_clients)

/attack_filt/no_client/filt_attack(var/datum/attack_log/al)
	if(!filt_missing_clients)
		return FALSE
	if(al.attacker && al.attacker.client.ckey == NO_CLIENT_CKEY)
		return TRUE
	if(al.victim && al.victim.client.ckey == NO_CLIENT_CKEY)
		return TRUE
	return FALSE

/*
	Either subject must be the selected client
*/
/attack_filt/must_be_given_ckey
	var/ckey_filt
	var/check_attacker = TRUE
	var/check_victim = TRUE
	var/description = "Either ckey is"

/attack_filt/must_be_given_ckey/reset()
	ckey_filt = null

/attack_filt/must_be_given_ckey/get_html()
	return "[description]: <a href='?src=\ref[src];select_ckey=1'>[ckey_filt ? ckey_filt : "*ANY*"]</a>"

/attack_filt/must_be_given_ckey/OnTopic(href_list)
	if(!href_list["select_ckey"])
		return
	var/ckey = input("Select ckey to filt on","Select ckey", ckey_filt) as null|anything in get_ckeys()
	if(ckey)
		if(ckey == "*ANY*")
			ckey_filt = null
		else
			ckey_filt = ckey
		return TRUE

/attack_filt/must_be_given_ckey/proc/get_ckeys()
	. = list()
	for(var/log in attack_log_repository.attack_logs_)
		var/datum/attack_log/al = log
		if(check_attacker && al.attacker && al.attacker.client.ckey != NO_CLIENT_CKEY)
			. |= al.attacker.client.ckey
		if(check_victim && al.victim && al.victim.client.ckey != NO_CLIENT_CKEY)
			. |= al.victim.client.ckey
	. = sortList(.)
	. += "*ANY*"

/attack_filt/must_be_given_ckey/filt_attack(var/datum/attack_log/al)
	if(!ckey_filt)
		return FALSE
	if(check_attacker && al.attacker && al.attacker.client.ckey == ckey_filt)
		return FALSE
	if(check_victim && al.victim && al.victim.client.ckey == ckey_filt)
		return FALSE
	return TRUE

/*
	Attacker must be the selected client
*/
/attack_filt/must_be_given_ckey/attacker
	description = "Attacker ckey is"
	check_victim = FALSE

/attack_filt/must_be_given_ckey/attacker/filt_attack(al)
	return ..(al, TRUE, FALSE)

/*
	Victim must be the selected client
*/
/attack_filt/must_be_given_ckey/victim
	description = "Victim ckey is"
	check_attacker = FALSE

/attack_filt/must_be_given_ckey/victim/filt_attack(al)
	return ..(al, FALSE, TRUE)
