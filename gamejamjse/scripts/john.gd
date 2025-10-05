extends CharacterBody2D


const SPEED = 150
const JUMP_VELOCITY = -300
const BULLET_SCENE = preload("res://scenes/bullet.tscn")
@export var shoot_rate : float = 0.2
var last_shoot_time : float = 0.0
const GRAVITY = Vector2(0, 980)

## FALL DAMAGE ## - New variables for fall damage. Tweak these in the Inspector.
@export var fall_damage_threshold: float = 500.0 # The downward speed needed to take damage.
@export var fall_damage_amount: int = 50 # The amount of damage to take.

var max_fall_speed: float = 0.0
var was_in_air: bool = false
## END FALL DAMAGE VARIABLES ##

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle = $muzzle
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar
@onready var camera: Camera2D = $Camera2D

var is_dead: bool = false

func _on_died():
	is_dead = true
	sprite.modulate = Color(1, 0, 0) # Tint red to show death
	
	# Logic from the new health system
	print(self.name + " has died!")
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout # Wait 1 second
	get_tree().reload_current_scene() # Remove the character from the game

func _ready() -> void:
	# Connect the health component's signals to functions
	health_component.died.connect(self._on_died)
	health_component.health_changed.connect(health_bar._on_health_changed)
	
	# Initialize the health bar
	health_bar.initialize(health_component.max_health)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	## FALL DAMAGE ## - Part 1: Track the peak fall speed while in the air.
	if not is_on_floor():
		if velocity.y > max_fall_speed:
			max_fall_speed = velocity.y
		was_in_air = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("jump")

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
		sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			sprite.play("idle")

	# move_and_slide() must be called BEFORE we check for landing.
	move_and_slide()
	
	## FALL DAMAGE ## - Part 2: Check if we just landed and apply damage if necessary.
	if is_on_floor() and was_in_air:
		# We have just landed. Check if the fall speed was dangerous.
		if max_fall_speed > fall_damage_threshold:
			print("Took fall damage! Fall speed was: ", max_fall_speed)
			health_component.take_damage(fall_damage_amount)
		
		# Reset the trackers for the next jump/fall.
		was_in_air = false
		max_fall_speed = 0.0
	
func _process(_delta: float) -> void:
	global_position = global_position.round()
	# Flip player sprite based on mouse
	sprite.flip_h = get_global_mouse_position().x < global_position.x

	# Flip muzzle with sprite
	if sprite.flip_h:
		muzzle.position.x = -abs(muzzle.position.x)
	else:
		muzzle.position.x = abs(muzzle.position.x)
		
	# aiming logic
	var aim_dir = (get_global_mouse_position() - global_position).normalized()
	var aim_angle = rad_to_deg(atan2(aim_dir.y, aim_dir.x))
	
	if aim_angle < -30:   # aiming upward
		sprite.play("aim_up")
	else:
		sprite.play("aim_straight")

	# Camera look-ahead toward mouse
	var look_dir = (get_global_mouse_position() - global_position).normalized()
	var target_offset = look_dir * 30
	camera.offset = camera.offset.lerp(target_offset, 0.1)  # 0.1 = smoothing factor
	
	# Shooting
	if Input.is_action_pressed("shoot") and not is_dead:
		if Time.get_unix_time_from_system() - last_shoot_time > shoot_rate:
			_shoot()



func _shoot():
	last_shoot_time = Time.get_unix_time_from_system()
	
	# Create a new bullet instance
	var bullet = BULLET_SCENE.instantiate()
	
	# -- Configure the bullet --
	bullet.owner_group = "player"
	bullet.global_position = muzzle.global_position
	
	var mouse_pos = get_global_mouse_position()
	var mouse_dir = muzzle.global_position.direction_to(mouse_pos)
	bullet.move_dir = mouse_dir
	
	# Add the new bullet to the main game world
	get_tree().current_scene.add_child(bullet)
	
func die():
	is_dead = true
	sprite.modulate = Color(1, 0, 0) # optional: tint red to show death
	
