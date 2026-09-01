extends Area3D

@export var anim_player : AnimationPlayer


var bodies_already_checked = []

func _process(delta: float) -> void:
	
	var colliding_bodies = get_overlapping_bodies()
	if colliding_bodies.size() == 1 and colliding_bodies[0].name == "Player":
		bodies_already_checked.clear()
	
	for colliding_body in colliding_bodies:
		if colliding_body.is_in_group("Enemy"):
			if not bodies_already_checked.has(colliding_body):
				if anim_player.is_animation_active() and anim_player.current_animation == "hit":
					colliding_body.on_hit.emit(1)
					bodies_already_checked.append(colliding_body)
			

		
		
