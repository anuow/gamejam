extends  Area2D

@export var spike_scene: PackedScene = preload("res://scenes/falling_spikes.tscn")
@export var spawn_rate: float = 20  # Spikes per second
@export var spawn_area_width: float = 1000
@export var spawn_height_offset: float = 100 # How far above the spawner to place spikes

@onready var spawn_timer: Timer = $Timer

func _ready():
	spawn_timer.wait_time = 1.0 / spawn_rate
	spawn_timer.timeout.connect(spawn_spike)
	
	# Connect the Area2D signals to functions that control the timer.
	# Make sure your player node is in a group called "player".
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		spawn_timer.start()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		spawn_timer.stop()

func spawn_spike():
	var spike_instance = spike_scene.instantiate()
	
	# Add to current scene (safe for both root and non-root spawners)
	get_tree().current_scene.add_child(spike_instance)
	
	var random_x = randf_range(-spawn_area_width / 2, spawn_area_width / 2)
	spike_instance.global_position = global_position + Vector2(random_x, spawn_height_offset)
	
	spike_instance.rotation_degrees = randf_range(-45.0, 45.0)
	spike_instance.speed = randf_range(200.0, 400.0)
