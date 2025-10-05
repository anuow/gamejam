extends Control

@onready var v_box_container: VBoxContainer = $PanelContainer/VBoxContainer
@onready var options: Panel = $Options

func _ready() -> void:
	v_box_container.visible = true
	options.visible = false
	

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	
func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")


func testESC():
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()
		


func _on_start_pressed() -> void:
	resume()
	



func _on_options_pressed() -> void:
	v_box_container.visible = false
	options.visible = true
	



func _on_exit_pressed() -> void:
	get_tree().quit()
	



func _on_back_pressed() -> void:
	_ready()

func _process(delta: float) -> void:
	testESC()
