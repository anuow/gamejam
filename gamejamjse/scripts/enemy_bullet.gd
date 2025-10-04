
extends Area2D

@export var speed: float = 200.0
@export var damage: float = 10 # <-- ADDED DAMAGE VARIABLE

var move_dir: Vector2 = Vector2.ZERO
var owner_group: String = ""

@onready var distroy_timer: Timer = $DistroyTimer

func _ready():
	distroy_timer.start()

func _process(delta: float) -> void:
	global_position += move_dir * speed * delta

func _on_body_entered(body: Node2D) -> void:
	print("Bullet hit: ", body.name) # <-- ADD THIS
	if body.is_in_group(owner_group):
		return

	# --- NEW DAMAGE LOGIC ---
	# Check if the body we hit has a HealthComponent
	var health_component = body.find_child("HealthComponent")
	if health_component:
		# If it does, call its take_damage function
		health_component.take_damage(damage)

	# The bullet is destroyed after hitting anything valid.
	queue_free()

func _on_distroy_timer_timeout() -> void:
	queue_free()
