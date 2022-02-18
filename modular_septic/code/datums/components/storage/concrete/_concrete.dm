/datum/component/storage/concrete/proc/slave_can_insert_object(datum/component/storage/slave, obj/item/storing, stop_messages = FALSE, mob/user, params)
	//This is where the pain begins
	if(tetris)
		var/box_size = world.icon_size
		var/calculated_screen_loc = ""
		var/screen_x = LAZYACCESS(modifiers, SCREEN_X)
		var/screen_y = LAZYACCESS(modifiers, SCREEN_Y)
		var/tetris_checks_failed = FALSE
		if((screen_x <= 0) || (screen_x > (screen_max_columns * box_size)))
			return FALSE
		if((screen_y <= 0) || (screen_y > (screen_max_rows * box_size)))
			return FALSE
		screen_x = round(screen_x, box_size)
		screen_y = round(screen_y, box_size)
		var/validate_x = (screen_x/box_size)
		var/validate_y = (screen_y/box_size)
		//this loops through all possible cells in the inventory box that we could overlap when given this screen_x and screen_y
		for(var/current_x in 0 to validate_x)
			for(var/current_y in 0 to validate_y)
				calculated_screen_loc = "[screen_start_x+screen_x+current_x]:[screen_pixel_x],[screen_start_y+screen_y+current_y]:[screen_pixel_y]"
				if(LAZYACCESS(screen_loc_to_item, calculated_screen_loc))
					return FALSE
	return TRUE

/datum/component/storage/concrete/handle_item_insertion_from_slave(datum/component/storage/slave, obj/item/storing, prevent_warning = FALSE, mob/user, params)
	. = handle_item_insertion(storing, prevent_warning, user, slave, params)
	if(. && !prevent_warning)
		slave.mob_item_insertion_feedback(usr, user, storing)
	if(!tetris)
		return
	var/list/modifiers = params2list(params)
	var/box_size = world.icon_size
	var/screen_x = LAZYACCESS(modifiers, SCREEN_X)
	var/screen_y = LAZYACCESS(modifiers, SCREEN_Y)
	screen_x = round(screen_x, box_size)
	screen_y = round(screen_y, box_size)
	var/validate_x = (screen_x/box_size)
	var/validate_y = (screen_y/box_size)
	var/calculated_screen_loc = ""
	//this loops through all possible cells in the inventory box that we could overlap when given this screen_x and screen_y
	for(var/current_x in 0 to validate_x)
		for(var/current_y in 0 to validate_y)
			calculated_screen_loc = "[screen_start_x+screen_x+current_x]:[screen_pixel_x],[screen_start_y+screen_y+current_y]:[screen_pixel_y]"
			LAZYADDASSOC(screen_loc_to_item, calculated_screen_loc, storing)
			if(!item_to_screen_locs[storing])
				item_to_screen_locs[storing] = list()
			LAZYADDASSOC(item_to_screen_locs[storing], storing, calculated_screen_loc)

/datum/component/storage/concrete/remove_from_storage(atom/movable/removed, atom/new_location)
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
	if(tetris)
		//this loops through all possible cells in the inventory box that we overlap and removes the item from them
		for(var/screen_loc in item_to_screen_locs[removed])
			LAZYREMOVE(screen_loc_to_item, screen_loc)
		LAZYREMOVE(item_to_screen_locs, removed)
	refresh_mob_views()
	removed.update_appearance()
	return TRUE
