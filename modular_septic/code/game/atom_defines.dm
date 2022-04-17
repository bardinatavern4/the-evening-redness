/atom
	/**
	 * Icon path
	 * Smoothing objects larger than 32x32 require a visual object to represent the excess part,
	 * in order not to increase its hitbox. We call that a frill.
	 */
	var/icon/frill_icon
	/// Subtractible armor
	var/datum/subarmor/subarmor
	/// Default pixel w shifting for the atom's icon
	var/base_pixel_w = 0
	/// Default pixel z shifting for the atom's icon
	var/base_pixel_z = 0
	/// Maximum distance we can be examined from
	var/maximum_examine_distance = 7
	/// The icon_state we use for ghost images on inspect
	var/inspect_icon_state = "what"
	/// Duration of inspection
	var/inspect_duration = 4 SECONDS
	/**
	 *  Basically the level of dirtiness on an atom, which will spread to wounds and stuff and cause infections
	 */
	var/germ_level = GERM_LEVEL_AMBIENT
	/// Should we ignore any attempts to auto align? Mappers should edit this!
	var/manual_align = FALSE
