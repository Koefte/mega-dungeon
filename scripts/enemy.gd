extends StaticBody3D

signal on_hit(damage_took: int)
signal died()

var health := 3

func _ready() -> void:
	on_hit.connect(_on_hit_)

func _on_hit_(damage_took: int) -> void:
	print(" I was hit")
	health -= damage_took
	if health <= 0:
		died.emit()
		queue_free()
