/obj/item/bodypart/l_eyesocket
	name = "left eyesocket"
	desc = "Sightless, until the eyes reappear."
	icon = 'modular_septic/icons/obj/items/surgery.dmi'
	icon_state = "eyelid"
	base_icon_state = "eyelid"
	attack_verb_continuous = list("looks at", "sees")
	attack_verb_simple = list("look at", "see")
	parent_body_zone = BODY_ZONE_HEAD
	body_zone = BODY_ZONE_PRECISE_L_EYE
	body_part = EYE_LEFT
	limb_flags = BODYPART_EDIBLE|BODYPART_NO_STUMP|BODYPART_EASY_MAJOR_WOUND|BODYPART_HAS_TENDON|BODYPART_HAS_NERVE|BODYPART_HAS_ARTERY
	sight_index = 1
	w_class = WEIGHT_CLASS_TINY
	max_damage = 30
	max_stamina_damage = 30
	wound_resistance = -10
	maxdam_wound_penalty = 5
	stam_heal_tick = 1

	hit_modifier = -5
	hit_zone_modifier = -3

	max_cavity_item_size = WEIGHT_CLASS_TINY
	max_cavity_volume = 2

	throw_range = 7
	scars_covered_by_clothes = FALSE
	dismemberment_sounds = list('modular_septic/sound/gore/severed.ogg')

	cavity_name = "orbital cavity"
	amputation_point_name = "orbit"
	tendon_type = TENDON_L_EYE
	artery_type = ARTERY_L_EYE
	nerve_type = NERVE_L_EYE

/obj/item/bodypart/l_eyesocket/get_limb_icon(dropped)
	if(dropped && !isbodypart(loc))
		. = list()
		var/image/funky_anus = image('modular_septic/icons/obj/items/surgery.dmi', src, base_icon_state, BELOW_MOB_LAYER)
		funky_anus.plane = plane
		funky_anus.transform = matrix(-1, 0, 0, 0, 1, 0) //mirroring
		. += funky_anus
		for(var/obj/item/organ/eyes/eye in src)
			var/image/eye_under
			var/image/iris
			eye_under = image(eye.icon, src, eye.icon_state, BELOW_MOB_LAYER-0.02)
			eye_under.transform = matrix(-1, 0, 0, 0, 1, 0)
			if(eye.iris_icon_state)
				iris = image(eye.icon, src, "eye-iris", BELOW_MOB_LAYER-0.01)
				iris.transform = matrix(-1, 0, 0, 0, 1, 0) //mirroring
				iris.color = eye.eye_color || eye.old_eye_color
			. += eye_under
			if(iris)
				. += iris
			break

/obj/item/bodypart/l_eyesocket/transfer_to_limb(obj/item/bodypart/new_limb, mob/living/carbon/was_owner)
	. = ..()
	if(istype(new_limb, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/head = new_limb
		head.left_eye = src
