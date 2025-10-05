extends Node2D


func _ready():
	var button = $Button
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	SceneManager.change_scene("res://scenes/another_test_scene.tscn")
