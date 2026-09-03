extends Area3D

@export var anim_player : AnimationPlayer


var bodies_already_checked = []

var current_anim = "hit"
var is_enabled = true

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		get_tree().create_timer(0.1).timeout.connect(anim_player.play.bind("RESET"))

func _process(delta: float) -> void:
	if not is_enabled:
		return
		
	if Input.is_action_just_pressed("hit"):
		anim_player.play("hit")
	
	var colliding_bodies = get_overlapping_bodies()
	
	if current_anim != anim_player.current_animation:
		bodies_already_checked.clear()
	
	for colliding_body in colliding_bodies:
		if colliding_body.is_in_group("Enemy"):
			if not bodies_already_checked.has(colliding_body):
				if anim_player.is_animation_active() and anim_player.current_animation == "hit":
					colliding_body.on_hit.emit(1)
					bodies_already_checked.append(colliding_body)
			

		
		
