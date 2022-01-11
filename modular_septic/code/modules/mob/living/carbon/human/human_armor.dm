// PERCENTAGE ARMOR
/mob/living/carbon/human/getarmor(def_zone, type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isbodypart(def_zone))
			var/obj/item/bodypart/bodypart = def_zone
			if(bodypart)
				return checkarmor(def_zone, type)
		var/obj/item/bodypart/affecting = get_bodypart(check_zone(def_zone))
		if(affecting)
			//If a specific bodypart is targetted, check how that bodypart is protected and return the value.
			return checkarmor(affecting, type)

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/x in bodyparts)
		var/obj/item/bodypart/bodypart = x
		armorval += checkarmor(bodypart, type)
		organnum++

	return (armorval/max(organnum, 1))

/mob/living/carbon/human/checkarmor(obj/item/bodypart/def_zone, d_type)
	if(!d_type)
		return 0
	var/protection = 0
	//Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	var/list/body_parts = list(head, \
							wear_mask, \
							wear_suit, \
							w_uniform, \
							back, \
							gloves, \
							shoes, \
							belt, \
							s_store, \
							glasses, \
							ears, \
							ears_extra, \
							wear_id, \
							wear_neck)
	for(var/obj/item/clothing in body_parts)
		if(clothing.body_parts_covered & def_zone.body_part)
			protection += clothing.armor.getRating(d_type)
	protection += physiology.armor.getRating(d_type)
	return protection

// SUBTRACTIBLE ARMOR
/mob/living/carbon/human/getsubarmor(def_zone, type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isbodypart(def_zone))
			var/obj/item/bodypart/bodypart = def_zone
			if(bodypart)
				return checksubarmor(def_zone, type)
		var/obj/item/bodypart/affecting = get_bodypart(check_zone(def_zone))
		if(affecting)
			//If a specific bodypart is targetted, check how that bodypart is protected and return the value.
			return checksubarmor(affecting, type)

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/x in bodyparts)
		var/obj/item/bodypart/bodypart = x
		armorval += checksubarmor(bodypart, type)
		organnum++

	return (armorval/max(organnum, 1))

//we only get the most superficial edge protection, no stacking
/mob/living/carbon/human/get_edge_protection(def_zone)
	var/obj/item/bodypart/affecting
	if(def_zone)
		if(isbodypart(def_zone))
			affecting = def_zone
		else
			affecting = get_bodypart(check_zone(def_zone))

	if(!affecting)
		return 0

	var/protection = 0
	var/list/clothings = clothingonpart(affecting)
	for(var/obj/item/clothing in clothings)
		protection += clothing.subarmor.getRating(EDGE_PROTECTION)
		return protection
	protection += physiology.subarmor.getRating(EDGE_PROTECTION)
	return protection

//we only get the most superficial armor flags, no stacking
/mob/living/carbon/human/get_subarmor_flags(def_zone)
	var/obj/item/bodypart/affecting
	if(def_zone)
		if(isbodypart(def_zone))
			affecting = def_zone
		else
			affecting = get_bodypart(check_zone(def_zone))

	if(!affecting)
		return NONE

	var/list/clothings = clothingonpart(affecting)
	for(var/obj/item/clothing in clothings)
		return clothing.subarmor.subarmor_flags
	return NONE

/mob/living/carbon/human/proc/checksubarmor(obj/item/bodypart/def_zone, d_type)
	if(!d_type)
		return 0

	var/obj/item/bodypart/affecting
	if(def_zone)
		if(isbodypart(def_zone))
			affecting = def_zone
		else
			affecting = get_bodypart(check_zone(def_zone))

	if(!affecting)
		return FALSE

	var/protection = 0
	var/list/clothings = clothingonpart(affecting)
	for(var/obj/item/clothing in clothings)
		protection += clothing.subarmor.getRating(d_type)
	protection += physiology.subarmor.getRating(d_type)
	return protection

/mob/living/carbon/human/damage_armor(damage = 0, damage_flag = MELEE, damage_type = BRUTE, sharpness = NONE, def_zone = BODY_ZONE_CHEST)
	var/obj/item/bodypart/affecting
	if(def_zone)
		if(isbodypart(def_zone))
			affecting = def_zone
		else
			affecting = get_bodypart(check_zone(def_zone))

	if(!affecting)
		return FALSE

	if(damage_flag in list(MELEE, BULLET))
		damage_flag = CRUSHING
		if(sharpness & SHARP_IMPALING)
			damage_flag = IMPALING
		else if(sharpness & SHARP_POINTY)
			damage_flag = PIERCING
		else if(sharpness & SHARP_EDGED)
			damage_flag = CUTTING

	var/list/clothings = clothingonpart(affecting)
	for(var/obj/item/clothing/clothing in clothings)
		if(clothing.take_damage_zone(def_zone, damage, damage_flag, damage_type, 100))
			return TRUE

	return FALSE