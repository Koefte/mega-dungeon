@tool
extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
var is_enabled := false

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		get_tree().create_timer(0.1).timeout.connect(anim_player.play.bind("RESET"))

func _process(delta: float) -> void:
	if not is_enabled:
		return
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	# 1. Cast from camera cursor into the world
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var to = from + (dir * 1000.0)

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)

	var result = space_state.intersect_ray(query)

	if Input.is_action_just_pressed("hit"):
		if anim_player.is_animation_active() and anim_player.current_animation == "RESET":
			return
		anim_player.play("shoot")
		if not result.has("collider"):
			return
		var collider = result["collider"]
		if collider.is_in_group("Enemy"):
			collider.on_hit.emit(2)
