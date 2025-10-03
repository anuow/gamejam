extends CharacterBody2D

@export var projectile_scene: PackedScene = preload("res://scenes/falling_spikes.tscn")
@export var projectile_spawn_rate: float = 1.0
@export var detection_radius: float = 300.0
@export var aura_damage: float = 5.0
@export var aura_interval: float = 1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_component: Node = $HealthComponent
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var detection_area: Area2D = $DetectionArea
@onready var camera: Camera2D = $/root/Main/Camera2D  # Adjust path to your camera

var target: Node2D = null
var is_active: bool = false
var phase: int = 1

func _ready():
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_update_phase)
	audio_player.stream = preload("res://assets/music/heartbeat-sound-372448.mp3")  # Add heartbeat sound
	audio_player.play()
	target = get_tree().get_nodes_in_group("player")[0]  # Player in "player" group
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	print("Boss ready, detection radius: ", detection_radius)

func _physics_process(_delta):
	if not health_component or health_component.current_health <= 0:
		return
	if is_active and target:
		apply_anxiety_aura(_delta)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		is_active = true
		print("Player entered detection range, boss is active!")
		start_spawning_projectiles()

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		is_active = false
		print("Player left detection range, boss is idle!")

func apply_anxiety_aura(_delta):  # Marked as unused with underscore
	if target and global_position.distance_to(target.global_position) < detection_radius:
		await get_tree().create_timer(aura_interval).timeout
		var player = target.get_parent()
		var player_health = player.find_child("HealthComponent")
		if player_health:
			player_health.take_damage(aura_damage)
			print("Aura dealt ", aura_damage, " damage")

func start_spawning_projectiles():
	while is_active and health_component.current_health > 0:
		if target:
			spawn_projectile()
		await get_tree().create_timer(1.0 / projectile_spawn_rate).timeout

func spawn_projectile():
	var screen_size = get_viewport_rect().size
	var projectile_instance = projectile_scene.instantiate()
	get_parent().add_child(projectile_instance)
	var random_x = randf_range(0, screen_size.x)
	# Spawn just above the camera's visible area
	projectile_instance.position = Vector2(random_x, camera.global_position.y - camera.get_viewport_rect().size.y / 2 - 50.0)
	var random_angle = randf_range(-45.0, 45.0)
	projectile_instance.rotation_degrees = random_angle
	projectile_instance.speed = randf_range(100.0, 200.0)
	# Enhanced debug to check sprite and position
	var sprite_node = projectile_instance.get_node("Sprite2D") if projectile_instance.has_node("Sprite2D") else null
	print("Spawned projectile at ", projectile_instance.position, " with angle ", random_angle, 
		  " | Sprite exists: ", sprite_node != null, " | Visible: ", sprite_node.visible if sprite_node else "No Sprite")

func _update_phase(_new_health):
	if health_component.current_health <= 75.0 and phase == 1:
		phase = 2
		projectile_spawn_rate = 1.5
		aura_damage = 7.0
		print("Phase 2: Increased aggression")
	elif health_component.current_health <= 50.0 and phase == 2:
		phase = 3
		projectile_spawn_rate = 2.0
		aura_damage = 10.0
		print("Phase 3: Maximum anxiety")

func _on_died():
	print("Anxiety Boss defeated!")
	queue_free()

func _process(_delta):
	if camera and is_active:
		camera.offset = Vector2(randf_range(-5.0, 5.0), randf_range(-5.0, 5.0))  # Screen shake
