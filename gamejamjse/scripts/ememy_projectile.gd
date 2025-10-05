extends Area2D

@export var speed: float = 1000.0
@export var damage: float = 10.0
@export var lifetime: float = 1.0 # Time in seconds before the bullet disappears

# This is set automatically by the timer node in the editor
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	# Configure the timer with the lifetime value from the inspector
	lifetime_timer.wait_time = lifetime
	lifetime_timer.start()
	
	# Connect the collision signal from this Area2D to our damage function
	# This tells the bullet to run _on_body_entered when it hits a physics body
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move forward in the direction I was spawned facing
	position += transform.x * speed * delta

# This function runs when the bullet's Area2D hits a PhysicsBody2D
func _on_body_entered(body: Node2D) -> void:
	# Check if the body we hit has a HealthComponent.
	# We also check if the body is in the "player" group to be sure.
	if body.is_in_group("player"):
		var health_component = body.find_child("HealthComponent")
		if health_component:
			# If it does, call its take_damage function
			health_component.take_damage(damage)

	# The bullet is destroyed after hitting any physics body.
	queue_free()

# This function is called by the LifetimeTimer when it finishes.
func _on_lifetime_timer_timeout() -> void:
	# Destroy the bullet when its time is up.
	queue_free()
