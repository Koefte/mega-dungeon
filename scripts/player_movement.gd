extends CharacterBody3D

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002
@export var acceleration: float = 10.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var anim_player = $Head/Camera3D/knife/AnimationPlayer
@onready var knife_node = $Head/Camera3D/knife/StaticBody3D

func _ready() -> void:
    anim_player.animation_finished.connect(_on_animation_finished)
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

func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "hit":
        get_tree().create_timer(0.1).timeout.connect(anim_player.play.bind("RESET"))

func _physics_process(delta: float) -> void:
    # Add gravity
    if not is_on_floor():
        velocity.y -= gravity * delta
        
    if Input.is_action_just_pressed("hit"):
        anim_player.play("hit")

    # Handle jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    # Get input direction relative to head rotation
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    # Horizontal movement
    if direction:
        velocity.x = lerpf(velocity.x, direction.x * move_speed, acceleration * delta)
        velocity.z = lerpf(velocity.z, direction.z * move_speed, acceleration * delta)
    else:
        velocity.x = lerpf(velocity.x, 0.0, acceleration * delta)
        velocity.z = lerpf(velocity.z, 0.0, acceleration * delta)

    move_and_slide()
