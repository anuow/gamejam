extends Control


@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options

func _process(delta: float) -> void:
	pass

func _ready() -> void:
	main_buttons.visible = true
	options.visible = false


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hospital_nurse.tscn")

func _on_options_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_options_pressed() -> void:
	_ready()
