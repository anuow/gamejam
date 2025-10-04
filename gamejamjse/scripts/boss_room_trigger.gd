extends Area2D

# The camera we want to modify.
@export var camera: Camera2D

# The zoom level we want the camera to have in the boss room.
@export var target_zoom: Vector2 = Vector2(1.5, 1.5)

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
		
		print("Player entered the trigger area! Changing camera zoom.")
		
		# Set the flag so this won't run again.
		has_been_triggered = true
		
		# Change the Camera Zoom
		#camera.zoom = target_zoom
		
		# For a smoother zoom, comment the line above
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_SINE) # Makes the transition smooth
		tween.tween_property(camera, "zoom", target_zoom, 2.0) # Zoom over 2 seconds
