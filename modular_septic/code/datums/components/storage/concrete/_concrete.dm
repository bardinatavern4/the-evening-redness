/datum/component/storage/concrete/slave_can_insert_object(datum/component/storage/slave, obj/item/storing, stop_messages = FALSE, mob/user, params, storage_click = FALSE)
	//This is where the pain begins
	if(tetris)
		var/list/modifiers = params2list(params)
		var/screen_loc = LAZYACCESS(modifiers, SCREEN_LOC)

		//converting screen loc into useful variables
		var/screen_x = src.screen_start_x
		var/screen_pixel_x = src.screen_pixel_x
		if(storage_click)
			screen_x = copytext(screen_loc, 1, findtext(screen_loc, ","))
			testing("screen_x: [screen_x]")
			screen_pixel_x = text2num(copytext(screen_x, findtext(screen_x, ":") + 1))
			testing("screen_pixel_x: [screen_pixel_x]")
			screen_x = text2num(copytext(screen_x, 1, findtext(screen_x, ":")))
		testing("screen_x: [screen_x]")
		testing("screen_x: [screen_x]")
		screen_x += FLOOR(screen_pixel_x/world.icon_size, 1)
		testing("screen_x: [screen_x]")

		//converting screen loc into useful variables
		var/screen_y = src.screen_start_y
		var/screen_pixel_y = src.screen_pixel_y
		if(storage_click)
			screen_y = copytext(screen_loc, findtext(screen_loc, ",") + 1)
			testing("screen_y: [screen_y]")
			screen_pixel_y = text2num(copytext(screen_y, findtext(screen_y, ":") + 1))
			testing("screen_pixel_y: [screen_pixel_y]")
			screen_y = text2num(copytext(screen_y, 1, findtext(screen_y, ":")))
		testing("screen_y: [screen_y]")
		testing("screen_y: [screen_y]")
		screen_y += FLOOR(screen_pixel_y/world.icon_size, 1)
		testing("screen_y: [screen_y]")

		var/calculated_coordinates = ""
		var/final_x
		var/final_y
		var/validate_x = storing.tetris_width-1
		var/validate_y = storing.tetris_height-1
		//this loops through all possible cells in the inventory box that we could overlap when given this screen_x and screen_y
		for(var/current_x in 0 to validate_x)
			for(var/current_y in 0 to validate_y)
				final_x = screen_x+current_x
				final_y = screen_y+current_y
				calculated_coordinates = "[final_x],[final_y]"
				if(final_x > screen_max_columns)
					testing("slave_can_insert_object FAILED validate_x: ([validate_x])")
					return FALSE
				if(final_y > screen_start_y)
					testing("slave_can_insert_object FAILED validate_y: ([validate_y])")
					return FALSE
				if(LAZYACCESS(coordinates_to_item, calculated_coordinates))
					testing("slave_can_insert_object FAILED final_x: ([final_x]) final_y: ([final_y]) calculated_coordinates: ([calculated_coordinates])")
					return FALSE
	return TRUE

//Remote is null or the slave datum
/datum/component/storage/concrete/handle_item_insertion(obj/item/storing, prevent_warning = FALSE, mob/user, datum/component/storage/remote, params, storage_click = FALSE)
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
		var/screen_x = src.screen_start_x
		var/screen_pixel_x = src.screen_pixel_x
		if(storage_click)
			screen_x = copytext(screen_loc, 1, findtext(screen_loc, ","))
			testing("screen_x: [screen_x]")
			screen_pixel_x = text2num(copytext(screen_x, findtext(screen_x, ":") + 1))
			testing("screen_pixel_x: [screen_pixel_x]")
			screen_x = text2num(copytext(screen_x, 1, findtext(screen_x, ":")))
		testing("screen_x: [screen_x]")
		testing("screen_x: [screen_x]")
		screen_x += FLOOR(screen_pixel_x/world.icon_size, 1)
		testing("screen_x: [screen_x]")

		//converting screen loc into useful variables
		var/screen_y = src.screen_start_y
		var/screen_pixel_y = src.screen_pixel_y
		if(storage_click)
			screen_y = copytext(screen_loc, findtext(screen_loc, ",") + 1)
			testing("screen_y: [screen_y]")
			screen_pixel_y = text2num(copytext(screen_y, findtext(screen_y, ":") + 1))
			testing("screen_pixel_y: [screen_pixel_y]")
			screen_y = text2num(copytext(screen_y, 1, findtext(screen_y, ":")))
		testing("screen_y: [screen_y]")
		testing("screen_y: [screen_y]")
		screen_y += FLOOR(screen_pixel_y/world.icon_size, 1)
		testing("screen_y: [screen_y]")

		var/calculated_coordinates = ""
		var/final_x
		var/final_y
		var/validate_x = storing.tetris_width-1
		var/validate_y = storing.tetris_height-1
		//this loops through all cells we overlap given these coordinates
		for(var/current_x in 0 to validate_x)
			for(var/current_y in 0 to validate_y)
				final_x = screen_x+current_x
				final_y = screen_y+current_y
				calculated_coordinates = "[final_x],[final_y]"
				testing("handle_item_insertion SUCCESS final_x: ([final_x]) final_y: ([final_y]) calculated_coordinates: ([calculated_coordinates])")
				LAZYADDASSOC(coordinates_to_item, calculated_coordinates, storing)
				LAZYINITLIST(item_to_coordinates)
				LAZYINITLIST(item_to_coordinates[storing])
				LAZYADD(item_to_coordinates[storing], calculated_coordinates)
	update_icon()
	refresh_mob_views()
	return TRUE

/datum/component/storage/concrete/handle_item_insertion_from_slave(datum/component/storage/slave, obj/item/storing, prevent_warning = FALSE, mob/user, params, storage_click = FALSE)
	. = handle_item_insertion(storing, prevent_warning, user, slave, params = params, storage_click = storage_click)
	if(. && !prevent_warning)
		slave.mob_item_insertion_feedback(usr, user, storing)

/datum/component/storage/concrete/remove_from_storage(atom/movable/removed, atom/new_location)
	//This loops through all cells in the inventory box that we overlap and removes the item from them
	//using lazy defines just didn't work here for no good reason
	if(item_to_coordinates)
		for(var/location in item_to_coordinates[removed])
			coordinates_to_item -= location
		if(!LAZYLEN(coordinates_to_item))
			coordinates_to_item = null
		item_to_coordinates -= removed
		if(!LAZYLEN(item_to_coordinates))
			item_to_coordinates = null
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
