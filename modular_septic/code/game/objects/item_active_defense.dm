//this is a stupid fucking name for a proc but i can't really change it now, can i?
/obj/item/proc/item_block(mob/living/carbon/human/owner, \
					atom/movable/hitby, \
					attack_text = "the attack", \
					damage = 0, \
					attacking_flags = BLOCK_FLAG_MELEE)
	// cannot block when unready
	if(HAS_TRAIT(src, TRAIT_WEAPON_UNREADY))
		return
	var/signal_return = SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, owner, hitby, attack_text, damage, attacking_flags)
	if(signal_return)
		return signal_return

	if(damage && !isnull(blocking_modifier) && CHECK_MULTIPLE_BITFIELDS(blocking_flags, attacking_flags))
		var/blocking_score = 0
		if(skill_blocking)
			blocking_score = owner.get_blocking_score(skill_blocking, blocking_modifier)
		if(owner.diceroll(blocking_score) >= DICE_SUCCESS)
			owner.visible_message(span_danger("<b>[owner]</b> blocks [attack_text] with [src]!"), \
								span_userdanger("I block [attack_text] with [src]!"), \
								vision_distance = COMBAT_MESSAGE_RANGE)
			COOLDOWN_START(owner, blocking_cooldown, BLOCKING_COOLDOWN)
			return COMPONENT_HIT_REACTION_CANCEL | COMPONENT_HIT_REACTION_BLOCK
		COOLDOWN_START(owner, blocking_cooldown, BLOCKING_COOLDOWN)
		return COMPONENT_HIT_REACTION_CANCEL

/obj/item/proc/item_parry(mob/living/carbon/human/owner, \
					atom/movable/hitby, \
					attack_text = "the attack", \
					damage = 0, \
					attacking_flags = BLOCK_FLAG_MELEE)
	// cannot parry when unready
	if(HAS_TRAIT(src, TRAIT_WEAPON_UNREADY))
		return
	var/signal_return = SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, owner, hitby, attack_text, damage, attacking_flags)
	if(signal_return)
		return signal_return

	if(damage && !isnull(parrying_modifier) && CHECK_MULTIPLE_BITFIELDS(parrying_flags, attacking_flags))
		var/parrying_score = 0
		if(skill_parrying)
			parrying_score = owner.get_parrying_score(skill_parrying, parrying_modifier)
		if(owner.diceroll(parrying_score) >= DICE_SUCCESS)
			owner.visible_message(span_danger("<b>[owner]</b> parries [attack_text] with [src]!"), \
								span_userdanger("I parry [attack_text] with [src]!"), \
								vision_distance = COMBAT_MESSAGE_RANGE)
			COOLDOWN_START(owner, blocking_cooldown, BLOCKING_COOLDOWN)
			return COMPONENT_HIT_REACTION_CANCEL | COMPONENT_HIT_REACTION_BLOCK
		COOLDOWN_START(owner, blocking_cooldown, BLOCKING_COOLDOWN)
		return COMPONENT_HIT_REACTION_CANCEL