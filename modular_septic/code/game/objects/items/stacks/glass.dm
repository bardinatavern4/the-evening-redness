/obj/item/shard/on_entered(datum/source, atom/movable/AM)
    var/glass_sound = list('modular_septic/sound/effects/glass1.wav', 'modular_septic/sound/effects/glass2.wav')
	SIGNAL_HANDLER
	if(isliving(AM))
		var/mob/living/L = AM
		if(!(L.movement_type & (FLYING|FLOATING)) || L.buckled)
			playsound(src, 'modular_septic/sound/effects/glass1.wav', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 30 : 50, TRUE)