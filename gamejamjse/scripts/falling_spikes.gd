extends Node2D

@export var speed = 160.0  # Can be set randomly by the spawner
var current_speed = 0.0

func _physics_process(delta):
	# Move based on rotation and speed
	var velocity = Vector2(0, 1).rotated(rotation) * current_speed
	position += velocity * delta
	print("Position: ", position, " | Rotation: ", rotation_degrees, " | Speed: ", current_speed)

func _on_player_detect_area_entered(area: Area2D) -> void:
	print("Detected area: ", area.name, " | Parent: ", area.get_parent().name, " | In group: ", area.is_in_group("player"))
	if area.is_in_group("player"):
		print("Player detected, calling fall()")
		fall()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("Hitbox triggered, dealing damage")
		var parent = area.get_parent()
		var health_component = parent.find_child("HealthComponent")
		if health_component:
			health_component.take_damage(50.0)

func fall():
	print("Falling started, current_speed: ", current_speed)
	current_speed = speed
	print("Falling with speed set to: ", current_speed)
	await get_tree().create_timer(5.0).timeout
	print("Falling finished, queueing free")
	queue_free()
