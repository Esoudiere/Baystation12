/datum/admin_secret_item/investigation/admin_pms
	name = "Admin PMs"

/datum/admin_secret_item/investigation/admin_pms/execute(var/mob/user, var/filt)
	. = ..()
	if(!.)
		return
	var/dat = list()
	dat += "<a href='?src=\ref[src];filt=[filt]'>Refresh</a> filting on: "
	if(filt)
		dat += " [filt] <a href='?src=\ref[src]'>Clear</a>"
	else
		dat += "None"
	dat += "<HR>"
	dat += "<table border='1' style='width:100%;border-collapse:collapse;'>"
	dat += "<tr><th style='text-align:left;'>Time</th><th style='text-align:left;'>Sender</th><th style='text-align:left;'>Receiver</th></tr>"

	for(var/datum/admin_privat_message/pm in admin_pm_repository.admin_pms_)
		var/datum/client_lite/sender = pm.sender
		var/datum/client_lite/receiver = pm.receiver

		if(filt && !(sender.ckey == filt || (receiver && receiver.ckey == filt)))
			continue

		if(receiver)
			dat += "<tr><td>[pm.station_time]</td><td>[sender.key_name(FALSE)] <a href='?src=\ref[src];filt=[html_encode(sender.ckey)]'>F</a></td><td>[receiver.key_name(FALSE)] <a href='?src=\ref[src];filt=[receiver.ckey]'>F</a></td></tr>"
		else
			dat += "<tr><td>[pm.station_time]</td><td>[sender.key_name(FALSE)] <a href='?src=\ref[src];filt=[html_encode(sender.ckey)]'>F</a></td><td></td></tr>"
		dat += "<tr><td colspan=3>[pm.message]</td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "admin_ahelps", "Admin PMs", 800, 400)
	popup.set_content(jointext(dat, null))
	popup.open()

/datum/admin_secret_item/investigation/admin_pms/Topic(href, href_list)
	. = ..()
	if(.)
		return
	execute(usr, href_list["filt"])
