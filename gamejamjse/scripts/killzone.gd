extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		print("you died!")
		_body.die()   # call the player's stop/death function
		timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
