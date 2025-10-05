extends Node2D

func _ready():
	# This line will run as soon as the level loads.
	# Make sure to replace the path with your actual music file for the level.
	MusicManager.play_music(preload("res://Music/RuN!.ogg"))
	
	# This is the new function that Godot created for you.
# It runs automatically when the player touches the 'end' Area2D.
func _on_end_body_entered(body: Node2D):
	# First, we check if the body that entered is the player.
	if body.is_in_group("player"):
		
		print("Player reached the end of the level! Changing scene.")
		
		# Tell the MusicManager to stop the current music with a 1-second fade.
		# We 'await' this to make sure the fade finishes before we change the scene.
		MusicManager.stop_music()
		
		# Tell the SceneManager to go to the next level.
		# IMPORTANT: Replace this path with the actual scene you want to load next.
		SceneManager.change_scene("res://scenes/hospital_night.tscn")
