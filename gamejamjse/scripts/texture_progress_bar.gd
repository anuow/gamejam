extends TextureProgressBar
# This function will be called by the character (Player/Enemy) to set it up.
func initialize(max_hp: float):
	max_value = max_hp
	value = max_hp

# This function will be connected to the HealthComponent's signal.
func _on_health_changed(new_health: float):
	print("HealthBar received new health: ", new_health)
	value = new_health
