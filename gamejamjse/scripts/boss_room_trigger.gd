extends Area2D

# The camera we want to modify.
@export var camera: Camera2D

# The zoom level we want the camera to have in the boss room.
@export var target_zoom: Vector2 = Vector2(1.5, 1.5)

# --- ADD THIS LINE ---
# The music track to play for the boss fight.
@export var boss_music: AudioStream
# --------------------

# This flag ensures the trigger only fires once.
var has_been_triggered: bool = false


func _ready():
	# Connect the 'body_entered' signal to our function.
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D):
	# If the trigger has already been fired, do nothing.
	if has_been_triggered:
		return
		
	# Check if the body that entered is the player.
	# Make sure your player node is in a group called "player".
	if body.is_in_group("player"):
		
		print("Player entered the boss area! Changing camera and music.")
		
		# Set the flag so this won't run again.
		has_been_triggered = true
		
		# --- ADD THIS SECTION ---
		# Change the Music using the MusicManager.
		if boss_music:
			MusicManager.play_music(boss_music)
		# ------------------------
		
