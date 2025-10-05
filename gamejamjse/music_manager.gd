extends Node

@onready var player_a: AudioStreamPlayer = $PlayerA
@onready var player_b: AudioStreamPlayer = $PlayerB

var current_player: AudioStreamPlayer
var queued_track: AudioStream = null


func _ready():
	current_player = player_a
	player_b.volume_db = -80.0


func _process(_delta):
	if queued_track == null or not current_player.playing or not current_player.stream:
		return

	var position = current_player.get_playback_position()
	var length = current_player.stream.get_length()
	
	if position >= length - 0.1:
		print("Current track finished loop. Instantly playing queued track.")
		_play_queued_track()


## QUEUES a new track to be played at the end of the current loop.
func play_music(track: AudioStream):
	if not current_player.playing:
		play_music_immediately(track)
		return

	if (current_player.stream == track and not queued_track) or queued_track == track:
		return

	queued_track = track
	print("Music Queued: ", track.resource_path)


## IMMEDIATELY interrupts and plays a new track instantly.
func play_music_immediately(track: AudioStream):
	queued_track = null
	
	if current_player.stream == track and current_player.playing:
		return

	var player_to_stop = current_player
	var player_to_start = player_b if current_player == player_a else player_a
	
	current_player = player_to_start

	player_to_stop.stop()
	
	player_to_start.stream = track
	if player_to_start.stream: 
		player_to_start.stream.loop = true
	player_to_start.volume_db = 0.0
	player_to_start.play()


func _play_queued_track():
	play_music_immediately(queued_track)
	queued_track = null


# --- ADD THIS MISSING FUNCTION ---
## STOPS all music instantly and clears the queue.
func stop_music():
	# Clear any track that was waiting to play.
	queued_track = null

	# Stop both players to be safe.
	player_a.stop()
	player_b.stop()
	print("All music stopped.")
