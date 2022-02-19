/datum/component/storage/concrete/slave_can_insert_object(datum/component/storage/slave, obj/item/storing, stop_messages = FALSE, mob/user, params)
	//This is where the pain begins
	if(tetris)
		var/list/modifiers = params2list(params)
		var/screen_loc = LAZYACCESS(modifiers, SCREEN_LOC)
		//converting screen loc into useful variables
		var/screen_x = 0
		if(!LAZYACCESS(modifiers, "storage_click"))
			screen_x = screen_start_x
		else
			screen_x = copytext(screen_loc, 1, findtext(screen_loc, ","))
			testing("screen_x: [screen_x]")
			screen_x = text2num(copytext(screen_x, 1, findtext(screen_x, ":")))
		testing("screen_x: [screen_x]")
		var/screen_y = 0
		if(!LAZYACCESS(modifiers, "storage_click"))
			screen_y = screen_start_y
		else
			screen_y = copytext(screen_loc, findtext(screen_loc, ",") + 1)
			testing("screen_y: [screen_y]")
			screen_y = text2num(copytext(screen_y, 1, findtext(screen_y, ":")))
		testing("screen_y: [screen_y]")
		var/calculated_screen_loc = ""
		var/final_x
		var/final_y
		var/validate_x = storing.tetris_width-1
		var/validate_y = storing.tetris_height-1
		//this loops through all possible cells in the inventory box that we could overlap when given this screen_x and screen_y
		for(var/current_x in 0 to validate_x)
			for(var/current_y in 0 to validate_y)
				final_x = screen_x+current_x
				final_y = screen_y+current_y
				calculated_screen_loc = "[final_x],[final_y]"
				if(LAZYACCESS(screen_loc_to_item, calculated_screen_loc))
					testing("slave_can_insert_object FAILED final_x: ([final_x]) final_y: ([final_y]) calculated_screen_loc: ([calculated_screen_loc])")
					return FALSE
	return TRUE

//Remote is null or the slave datum
/datum/component/storage/concrete/handle_item_insertion(obj/item/storing, prevent_warning = FALSE, mob/user, datum/component/storage/remote, params)
	var/datum/component/storage/concrete/master = master()
	var/atom/parent = src.parent
	var/moved = FALSE
	if(!istype(storing))
		return FALSE
	if(user)
		if(!worn_check(parent, user))
			return FALSE
		if(!user.temporarilyRemoveItemFromInventory(storing))
			return FALSE
		else
			//At this point if the proc fails we need to manually move the object back to the turf/mob/whatever.
			moved = TRUE
	if(storing.pulledby)
		storing.pulledby.stop_pulling()
	if(silent)
		prevent_warning = TRUE
	if(!_insert_physical_item(storing))
		if(moved)
			if(user)
				if(!user.put_in_active_hand(storing))
					storing.forceMove(parent.drop_location())
			else
				storing.forceMove(parent.drop_location())
		return FALSE
	storing.on_enter_storage(master)
	storing.item_flags |= IN_STORAGE
	storing.mouse_opacity = MOUSE_OPACITY_OPAQUE //So you can click on the area around the item to equip it, instead of having to pixel hunt
	if(user)
		if(user.client && (user.active_storage != src))
			user.client.screen -= storing
		if(LAZYLEN(user.observers))
			for(var/mob/dead/observe as anything in user.observers)
				if(observe.client && (observe.active_storage != src))
					observe.client.screen -= storing
		if(!remote)
			parent.add_fingerprint(user)
			if(!prevent_warning)
				mob_item_insertion_feedback(usr, user, storing)
	if(tetris)
		var/list/modifiers = params2list(params)
		var/screen_loc = LAZYACCESS(modifiers, SCREEN_LOC)
		//converting screen loc into useful variables
		var/screen_x = 0
		if(!LAZYACCESS(modifiers, "storage_click"))
			screen_x = screen_start_x
		else
			screen_x = copytext(screen_loc, 1, findtext(screen_loc, ","))
			testing("screen_x: [screen_x]")
			screen_x = text2num(copytext(screen_x, 1, findtext(screen_x, ":")))
		testing("screen_x: [screen_x]")
		var/screen_y = 0
		if(!LAZYACCESS(modifiers, "storage_click"))
			screen_y = screen_start_y
		else
			screen_y = copytext(screen_loc, findtext(screen_loc, ",") + 1)
			testing("screen_y: [screen_y]")
			screen_y = text2num(copytext(screen_y, 1, findtext(screen_y, ":")))
		testing("screen_y: [screen_y]")
		var/calculated_screen_loc = ""
		var/final_x
		var/final_y
		var/validate_x = storing.tetris_width-1
		var/validate_y = storing.tetris_height-1
		//this loops through all possible cells in the inventory box that we could overlap when given this screen_x and screen_y
		for(var/current_x in 0 to validate_x)
			for(var/current_y in 0 to validate_y)
				final_x = screen_x+current_x
				final_y = screen_y+current_y
				calculated_screen_loc = "[final_x],[final_y]"
				testing("handle_item_insertion SUCCESS final_x: ([final_x]) final_y: ([final_y]) calculated_screen_loc: ([calculated_screen_loc])")
				LAZYADDASSOC(screen_loc_to_item, calculated_screen_loc, storing)
				LAZYINITLIST(item_to_screen_locs)
				LAZYINITLIST(item_to_screen_locs[storing])
				LAZYADD(item_to_screen_locs[storing], calculated_screen_loc)
	update_icon()
	refresh_mob_views()
	return TRUE

/datum/component/storage/concrete/handle_item_insertion_from_slave(datum/component/storage/slave, obj/item/storing, prevent_warning = FALSE, mob/user, params)
	. = handle_item_insertion(storing, prevent_warning, user, slave, params = params)
	if(. && !prevent_warning)
		slave.mob_item_insertion_feedback(usr, user, storing)

/datum/component/storage/concrete/remove_from_storage(atom/movable/removed, atom/new_location)
	//This loops through all cells in the inventory box that we overlap and removes the item from them
	//using lazy defines just didn't work here for no good reason
	if(item_to_screen_locs)
		for(var/location in item_to_screen_locs[removed])
			screen_loc_to_item -= location
		if(!LAZYLEN(screen_loc_to_item))
			screen_loc_to_item = null
		item_to_screen_locs -= removed
		if(!LAZYLEN(item_to_screen_locs))
			item_to_screen_locs = null
	removed.underlays = null
	//Cache this as it should be reusable down the bottom, will not apply if anyone adds a sleep to dropped or moving objects, things that should never happen
	var/atom/parent = src.parent
	var/list/seeing_mobs = can_see_contents()
	for(var/mob/seeing_mob as anything in seeing_mobs)
		seeing_mob.client.screen -= removed
	if(isitem(removed))
		var/obj/item/removed_item = removed
		removed_item.item_flags &= ~IN_STORAGE
		if(ismob(parent.loc))
			var/mob/carrying_mob = parent.loc
			removed_item.dropped(carrying_mob, TRUE)
	if(new_location)
		//Reset the items values
		_removal_reset(removed)
		removed.forceMove(new_location)
		//We don't want to call this if the item is being destroyed
		removed.on_exit_storage(src)
	else
		//Being destroyed, just move to nullspace now (so it's not in contents for the icon update)
		removed.moveToNullspace()
	removed.update_appearance()
	update_icon()
	refresh_mob_views()
	return TRUE
