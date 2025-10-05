extends Control

@onready var nurse_sprite: AnimatedSprite2D = $NurseAnimatedSprite2D
@onready var nurse_anim_player: AnimationPlayer = $NurseAnimationPlayer

@onready var wife_sprite: AnimatedSprite2D = $WifeAnimatedSprite2D
@onready var wife_anim_player: AnimationPlayer = $WifeAnimationPlayer


func _ready():
	# --- MUSIC SETUP (NEW CODE) ---
	# Start the initial music for the scene.
	MusicManager.play_music(preload("res://Music/mainmenu.ogg"))
	# Connect to the 'mutated' signal to listen for tags like [signal=change_music, ...].
	DialogueManager.mutated.connect(_on_dialogue_mutated)
	# --------------------------

	# Hide wife at start
	wife_sprite.visible = false
	
	# Nurse enters
	nurse_anim_player.play("RESET")
	await nurse_anim_player.animation_finished
	
	# Load and show nurse dialogue
	var nurse_dialogue = load("res://Dialogue/HP_Afternoon.dialogue")
	DialogueManager.show_dialogue_balloon(nurse_dialogue)
	# We use the modern signal connection syntax here for consistency.
	DialogueManager.dialogue_ended.connect(_on_nurse_dialogue_ended)

# --- NEW FUNCTION to handle music changes from dialogue ---
func _on_dialogue_mutated(mutation: Dictionary):
	# We check if the signal is the "change_music" signal we created.
	if mutation.get("signal") == "change_music":
		# Get the path to the new song from the signal's arguments.
		if mutation.has("args") and not mutation["args"].is_empty():
			var new_music_path = mutation["args"][0]
			
			print("Music change triggered! Playing: ", new_music_path)
			
			# Load the new music and tell the MusicManager to play it.
			var music_resource = load(new_music_path)
			MusicManager.play_music(music_resource)
# ----------------------------------------------------

func _on_nurse_dialogue_ended(resource: DialogueResource):
	# This function acts as a controller, directing the scene's flow.
	if resource.resource_path.ends_with("HP_Afternoon.dialogue"):
		# Nurse dialogue finished, nurse leaves
		_nurse_leave()
	elif resource.resource_path.ends_with("HP_Afternoon2.dialogue"):
		# Patient dialogue finished, wife enters
		_wife_enter()
	elif resource.resource_path.ends_with("HP_Afternoon3.dialogue"):
		# Wife dialogue finished, clean up and change scene
		
		# --- CLEANUP (NEW CODE) ---
		# It's good practice to disconnect signals before leaving a scene.
		if DialogueManager.is_connected("dialogue_ended", _on_nurse_dialogue_ended):
			DialogueManager.dialogue_ended.disconnect(_on_nurse_dialogue_ended)
		if DialogueManager.is_connected("mutated", _on_dialogue_mutated):
			DialogueManager.mutated.disconnect(_on_dialogue_mutated)
		# --------------------------
		
		SceneManager.change_scene("res://scenes/game.tscn")

func _nurse_leave():
	nurse_anim_player.play("leave")
	await nurse_anim_player.animation_finished
	nurse_sprite.visible = false
	
	# Load and show patient dialogue
	var patient_dialogue = load("res://Dialogue/HP_Afternoon2.dialogue")
	DialogueManager.show_dialogue_balloon(patient_dialogue)
	# The connected dialogue_ended signal will handle what happens next.

func _wife_enter():
	wife_sprite.visible = true
	wife_anim_player.play("enter")
	await wife_anim_player.animation_finished
	
	# Load and show wife dialogue
	var wife_dialogue = load("res://Dialogue/HP_Afternoon3.dialogue")
	DialogueManager.show_dialogue_balloon(wife_dialogue)
	# The connected dialogue_ended signal will handle what happens next.
