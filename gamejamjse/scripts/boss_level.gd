extends Node2D

# --- CONFIGURATION ---
# These paths are based on the information you provided.
# Make sure they are 100% correct.
var dialogue_resource_path = "res://dialogue/bossfight.dialogue"
var good_ending_scene_path = "res://scenes/good_ending.tscn"
var bad_ending_scene_path = "res://scenes/bad_ending.tscn"
# --------------------

# This variable will silently track the player's choices.
var boss_mood: int = 0
# This variable prevents the dialogue from starting more than once.
var dialogue_has_started: bool = false


# The scene starts, but does nothing until the player enters the trigger area.
func _ready():
	pass


# This function is called by the Area2D's "body_entered" signal.
func _on_dialogue_trigger_area_body_entered(body):
	# Check if it's the player and if the dialogue hasn't already started.
	if not dialogue_has_started and body.is_in_group("player"):
		dialogue_has_started = true
		
		print("Player entered the boss arena. Starting dialogue...")
		
		# Load the dialogue resource from the path defined above.
		var dialogue_resource = load(dialogue_resource_path)

		# Connect to the signals that will listen for choices and the dialogue's end.
		DialogueManager.mutated.connect(_on_dialogue_mutated)
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
		# Start the conversation.
		DialogueManager.show_dialogue_balloon(dialogue_resource)

		# Disable the trigger so it can't be activated again.
		# IMPORTANT: This path MUST match the location of your trigger area in the scene tree.
		$DialogueTriggerArea/CollisionShape2D.set_deferred("disabled", true)


# This function listens for ALL mutations from the dialogue.
func _on_dialogue_mutated(mutation: Dictionary):
	# We check if the mutation is the "signal" for a choice we are looking for.
	if mutation.get("signal") == "choice_made":
		if mutation.has("args") and not mutation["args"].is_empty():
			var choice_type = mutation["args"][0]
			# Now we call our function that handles the game logic.
			_on_player_choice(choice_type)


# This function contains the game logic for making a choice.
func _on_player_choice(choice_type: String):
	match choice_type:
		"aggressive":
			boss_mood -= 2
		"accepting":
			boss_mood += 3
		"desperate":
			boss_mood -= 1
		"instakill":
			_trigger_instakill_ending()
			return

	print("Boss mood is now (for debugging): ", boss_mood)


# This function runs ONCE when the dialogue file reaches "=> END".
func _on_dialogue_ended(_resource: DialogueResource):
	print("The conversation is over. Final boss mood is: ", boss_mood)

	# Disconnect the signals to prevent them from firing again in the future.
	if DialogueManager.is_connected("mutated", _on_dialogue_mutated):
		DialogueManager.mutated.disconnect(_on_dialogue_mutated)
	if DialogueManager.is_connected("dialogue_ended", _on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

	# Check the final score and trigger the correct ending.
	if boss_mood > 0:
		_trigger_good_ending()
	else:
		_trigger_bad_ending()


# --- ENDING FUNCTIONS ---

func _trigger_good_ending():
	print("ENDING: Good")
	SceneManager.change_scene("res://scenes/good_ending.tscn")


func _trigger_bad_ending():
	print("ENDING: Bad")
	SceneManager.change_scene("res://scenes/bad_ending.tscn")


func _trigger_instakill_ending():
	print("ENDING: Instakill")
	DialogueManager.end_dialogue()

	var player = get_tree().get_first_node_in_group("player")
	
	if player and player.has_method("die"):
		player.die()
	else:
		print("ERROR: Could not find player in group 'player' or player has no 'die()' function.")
