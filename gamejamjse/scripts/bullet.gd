extends Area2D

@export var speed: float = 200.0
@export var damage: float = 20 
@export var max_distance: float = 350

var move_dir: Vector2 = Vector2.ZERO
var owner_group: String = ""
var start_position: Vector2

@onready var distroy_timer: Timer = $DistroyTimer

func _ready():
	distroy_timer.start()
	start_position = global_position

func _physics_process(delta: float) -> void:
	global_position += move_dir * speed * delta
	if global_position.distance_to(start_position) > max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	print("Bullet hit: ", body.name) 
	if body.is_in_group(owner_group):
		return

	# --- NEW DAMAGE LOGIC ---
	# Check if the body we hit has a HealthComponent
	var health_component = body.find_child("HealthComponent")
	if health_component:
		# If it does, call its take_damage functiondddd
		health_component.take_damage(damage)

func _on_distroy_timer_timeout() -> void:
	queue_free()
