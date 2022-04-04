#define MAX_ALERTS 5

/datum/peeper_tab/alerts
	name = "Alert"
	desc = "Tab that contains context-sensitive alerts."
	icon_state = "alerts_tab"
	/// All of our alert movables
	var/list/all_alerts = list()
	/// Tooltip for the alert name
	var/atom/movable/screen/alert_tooltip/name_tooltip
	/// Tooltip for the alert desc
	var/atom/movable/screen/alert_tooltip/description/desc_tooltip

/datum/peeper_tab/alerts/New()
	. = ..()
	name_tooltip = new(mypeeper?.myhud)
	desc_tooltip = new(mypeeper?.myhud)

/datum/peeper_tab/alerts/Destroy()
	. = ..()
	QDEL_NULL(name_tooltip)
	QDEL_NULL(desc_tooltip)

/datum/peeper_tab/alerts/get_all_screen_atoms()
	. = ..()
	. |= all_alerts
	. |= name_tooltip
	. |= desc_tooltip

/datum/peeper_tab/alerts/get_visible_screen_atoms()
	. = ..()
	. |= all_alerts
	. |= name_tooltip
	. |= desc_tooltip

/datum/peeper_tab/alerts/update_tab_loadout()
	var/atom/movable/screen/alert/alert
	var/alerts_length = LAZYLEN(all_alerts)
	var/border_x = world.icon_size * MAX_ALERTS
	var/padding_x = (border_x - (world.icon_size * min(alerts_length, MAX_ALERTS)) )/2
	for(var/i in 1 to alerts_length)
		alert.mytab = src
		alert = all_alerts[i]
		if(i <= MAX_ALERTS)
			alert.screen_loc = "statmap:[i]:[padding_x],3:-16"
		else
			alert.screen_loc = ""
	return TRUE

/datum/peeper_tab/alerts/proc/update_alert_tooltip(atom/movable/screen/alert/alert)
	if(!istype(alert))
		name_tooltip?.update_maptext("N/A")
		desc_tooltip?.update_maptext("Everything is fine...")
		return
	name_tooltip?.update_maptext(alert.name)
	desc_tooltip?.update_maptext(alert.desc)

#undef MAX_ALERTS
