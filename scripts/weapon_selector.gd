extends Node3D

var active_weapon := 0 # 0 -> Knife 1 -> Pistol

@onready var knife = $Camera3D/knife
@onready var pistol = $Camera3D/pistol

func switch_weapon(i:int) -> void:
	if i == active_weapon:
		return
	pistol.visible = i == 1
	pistol.is_enabled = i == 1
	knife.visible = i == 0
	knife.get_node("StaticBody3D").is_enabled = i == 0
	active_weapon = i

	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("hotbar_1"):
		switch_weapon(0)
	elif Input.is_action_just_pressed("hotbar_2"):
		switch_weapon(1)
