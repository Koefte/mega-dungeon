extends CharacterBody3D

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002
@export var acceleration: float = 10.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

enum State {CRAWLING,JUMPING,BEGIN_CRAWL,END_CRAWL,MOVING,IDLE}

var player_state : State = State.IDLE

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var anim_player = $Head/Camera3D/AnimationPlayer
@onready var knife_node = $Head/Camera3D/knife/StaticBody3D
@onready var collider = $CollisionShape3D

func _can_move() -> bool:
	return player_state != State.BEGIN_CRAWL

func _can_jump() -> bool:
	return player_state != State.CRAWLING

func is_ceiling_above() -> bool:
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = from + Vector3.UP * 1.5 
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self.get_rid()] 
	
	var result = space_state.intersect_ray(query)
	return not result.is_empty()

func _on_animation_finished(anim_name: StringName) -> void:
	
	if anim_name == "crawl": 
		if player_state == State.END_CRAWL:
			player_state = State.IDLE
			move_speed = 5.0
			collider.shape.height = 2.0
			collider.position.y = 0.0
		elif player_state == State.BEGIN_CRAWL:
			move_speed = 2.0
			collider.shape.height = 1.0
			collider.position.y = -0.5
			player_state = State.CRAWLING
	

func _ready() -> void:
	anim_player.connect("animation_finished",_on_animation_finished)
	add_collision_exception_with(knife_node)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	# Toggle mouse lock with Escape
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Mouse look
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(85), deg_to_rad(85))



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("crawl") and player_state != State.BEGIN_CRAWL:
		if player_state == State.CRAWLING:
			if not is_ceiling_above():
				anim_player.play_backwards("crawl")
				player_state = State.END_CRAWL
		else:
			anim_player.play("crawl")
			player_state = State.BEGIN_CRAWL
			
	

	
	if Input.is_action_just_pressed("jump") and is_on_floor() and _can_jump():
		velocity.y = jump_velocity

	if not _can_move():
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	
	if direction:
		velocity.x = lerpf(velocity.x, direction.x * move_speed, acceleration * delta)
		velocity.z = lerpf(velocity.z, direction.z * move_speed, acceleration * delta)
	else:
		velocity.x = lerpf(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerpf(velocity.z, 0.0, acceleration * delta)

	move_and_slide()
