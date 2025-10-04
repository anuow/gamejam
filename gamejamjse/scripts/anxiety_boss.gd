extends CharacterBody2D
# --- Movement & AI Variables ---
@export var speed = 75.0
@export var follow_distance = 20 # Will stop moving when closer than this distance.
@export var attack_range = 400.0   # Will only shoot when within this range.

const BULLET_SCENE = preload("res://scenes/enemy_bullet.tscn")
# --- Shooting Variables ---
@export var shoot_cooldown = 1 # Time between shots.

# --- Node References ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $muzzle
@onready var shoot_timer: Timer = $ShootTimer


# --- State Variables ---
var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead: bool = false

func _on_died():
	# Logic from your old die() function
	is_dead = true
	sprite.modulate = Color(1, 0, 0) # Tint red to show death
	
	# Logic from the new health system
	print(self.name + " has died!")
	get_node("CollisionShape2D").disabled = true # Stop collisions
	await get_tree().create_timer(1.0).timeout # Wait 1 second
	queue_free() # Remove the character from the game

func _ready():
	# Find the player using the group you set up.
	player = get_tree().get_first_node_in_group("player")
	
	# Configure and start the shooting timer.
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.start()
	# Connect the health component's signals to functions
	


func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	# Apply gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# If the player doesn't exist or is dead, do nothing.
	if not is_instance_valid(player):
		velocity.x = 0
		move_and_slide() # We still need to call this to apply gravity/stop movement
		return

	# --- AI Logic ---
	var direction_to_player = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)

	# Movement: Move towards player if outside the 'follow_distance'.
	if distance_to_player > follow_distance:
		velocity.x = direction_to_player.x * speed
	else:
		# If too close, stop moving.
		velocity.x = move_toward(velocity.x, 0, speed)
	
	# --- Visuals ---
	# Flip sprite and muzzle to face the player.
	if direction_to_player.x > 0:
		sprite.flip_h = false
		muzzle.position.x = abs(muzzle.position.x)
	elif direction_to_player.x < 0:
		sprite.flip_h = true
		muzzle.position.x = -abs(muzzle.position.x)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _on_shoot_timer_timeout():
	if not is_instance_valid(player) or global_position.distance_to(player.global_position) > attack_range:
		return
	
	# Create a new bullet instance from the scene file
	var bullet = BULLET_SCENE.instantiate()
	
	# -- Configure the bullet --
	bullet.owner_group = "enemy"
	bullet.global_position = muzzle.global_position
	
	var shoot_dir = muzzle.global_position.direction_to(player.global_position)
	bullet.move_dir = shoot_dir
	
	# Add the new bullet to the main game world
	get_tree().root.add_child(bullet)
	
