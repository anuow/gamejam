extends CharacterBody2D

# --- Movement & AI Variables ---
@export var SPEED = 151
@export var follow_distance = 40 # Will stop moving when closer than this distance.
@export var attack_range = 40   # Will only shoot when within this range.

# --- Node References ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $muzzle
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar

# --- State Variables ---
var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead: bool = false

func _on_died():
	is_dead = true
	sprite.stop()  # stops current animation
	sprite.rotate(90)
	sprite.modulate = Color(1, 0, 0)
	print(name + " has died!")
	$CollisionShape2D.disabled = true
	get_node("CollisionShape2D").disabled = true # Stop collisions
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
func _ready():
	# Find the player using the group you set up.
	player = get_tree().get_first_node_in_group("player")
	# Connect the health component's signals to functions
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(health_bar._on_health_changed)
	
	# Initialize the health bar
	health_bar.initialize(health_component.max_health)
	
func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	# Apply gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var direction = Input.get_axis("move_left", "move_right")
	
	# If the player doesn't exist or is dead, do nothing.
	if not is_instance_valid(player):
		velocity.x = 0
		move_and_slide() # We still need to call this to apply gravity/stop movement
		return
		
	if direction:
		velocity.x = direction * SPEED
		sprite.play("default")
		
	# --- AI Logic ---
	var direction_to_player = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)

	# Movement: Move towards player if outside the 'follow_distance'.
	if distance_to_player > follow_distance:
		velocity.x = direction_to_player.x * SPEED
	else:
		# If too close, stop moving.
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# --- Visuals ---
	# Flip sprite and muzzle to face the player.
	if direction_to_player.x > 0:
		sprite.flip_h = false
		muzzle.position.x = abs(muzzle.position.x)
	elif direction_to_player.x < 0:
		sprite.flip_h = true
		muzzle.position.x = -abs(muzzle.position.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func die():
	is_dead = true
	sprite.modulate = Color(1, 0, 0) # optional: tint red to show death
