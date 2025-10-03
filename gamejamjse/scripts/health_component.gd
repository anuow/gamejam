extends Node

# SIGNALS: These act like announcements that other nodes can listen to.
# Announces that health has changed, sending the new value.
signal health_changed(new_health)
# Announces that health has reached zero.
signal died

# VARIABLES
@export var max_health: float = 100.0
var current_health: float

func _ready():
	# Initialize health when the game starts.
	current_health = max_health

# This is the main function for dealing damage.
func take_damage(amount: float):
	# Don't do anything if already dead.
	if current_health <= 0:
		return

	current_health -= amount
	print("Took damage: ", amount, " | New health: ", current_health)
	# Announce that the health has changed.
	health_changed.emit(current_health)

	# Check for death.
	if current_health <= 0:
		current_health = 0 # Clamp health at 0
		died.emit()
		# You can disable the component's processing to prevent further damage.
		set_process(false) 
