extends Control

@onready var nurse_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	animation_player.play("RESET")
	await animation_player.animation_finished
	
	var dialogue_resource = load("res://dialogue/HP_Afternoon.dialogue")
	print("Starting dialogue balloon...")
	DialogueManager.show_dialogue_balloon(dialogue_resource)
	DialogueManager.connect("dialogue_ended", Callable(self, "dialogue_ended"))


# --- THIS IS THE MODIFIED FUNCTION ---
func dialogue_ended(_resource: DialogueResource):
	print("Dialogue ended. Nurse is leaving...")

	# 1. Play the "leave" animation for the nurse
	animation_player.play("leave")

	# 2. Wait here until the animation is completely finished
	await animation_player.animation_finished

	# 3. Once finished, make the sprite invisible
	nurse_sprite.visible = false

	# 4. NOW transition to the next scene
	print("Transitioning to anxiety...")
	SceneManager.change_scene("res://scenes/game.tscn")
