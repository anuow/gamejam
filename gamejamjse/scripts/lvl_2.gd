extends Node2D

func _ready():
	# This line will run as soon as the level loads.
	# Make sure to replace the path with your actual music file for the level.
	MusicManager.play_music(preload("res://Music/lvl-2 start.ogg"))
