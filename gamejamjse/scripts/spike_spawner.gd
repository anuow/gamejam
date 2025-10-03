extends Node2D

@export var spike_scene: PackedScene = preload("res://scenes/falling_spikes.tscn")
@export var spawn_rate: float = 2.0  # Spikes per second (adjustable)
@export var spawn_area_width: float = 640.0  # Width of the spawn area (e.g., screen width)
@export var spawn_height: float = -100.0  # Y-position above the screen (negative y is up)

func _ready():
	start_spawning()

func start_spawning():
	while true:
		spawn_spike()
		await get_tree().create_timer(1.0 / spawn_rate).timeout  # Wait based on spawn_rate

func spawn_spike():
	var spike_instance = spike_scene.instantiate()
	add_child(spike_instance)  # Add to the spawner node
	
	# Random x-position within spawn_area_width
	var random_x = randf_range(0, spawn_area_width)
	# Random y-position (above the screen)
	var random_y = spawn_height
	
	# Set initial position
	spike_instance.position = Vector2(random_x, random_y)
	
	# Random rotation (e.g., -45 to 45 degrees)
	var random_angle = randf_range(-45.0, 45.0)  # Adjust range as needed
	spike_instance.rotation_degrees = random_angle
	
	# Optional: Pass speed or adjust it randomly if needed
	spike_instance.speed = randf_range(100.0, 200.0)  # Random speed between 100 and 200

func _on_tree_exiting():
	# Clean up to avoid coroutine issues
	pass
