extends Control

@onready var nurse_sprite: AnimatedSprite2D = $NurseAnimatedSprite2D
@onready var nurse_anim_player: AnimationPlayer = $NurseAnimationPlayer

@onready var wife_sprite: AnimatedSprite2D = $WifeAnimatedSprite2D
@onready var wife_anim_player: AnimationPlayer = $WifeAnimationPlayer

func _ready():
	# Hide wife at start
	wife_sprite.visible = false
	
	# Nurse enters
	nurse_anim_player.play("RESET")
	await nurse_anim_player.animation_finished
	
	# Load and show nurse dialogue
	var nurse_dialogue = load("res://Dialogue/HP_Afternoon.dialogue")
	DialogueManager.show_dialogue_balloon(nurse_dialogue)
	DialogueManager.connect("dialogue_ended", Callable(self, "_on_nurse_dialogue_ended"))

func _on_nurse_dialogue_ended(resource: DialogueResource):
	if resource.resource_path.ends_with("HP_Afternoon.dialogue"):
		# Nurse leaves
		_nurse_leave()
	elif resource.resource_path.ends_with("HP_Afternoon2.dialogue"):
		# Patient dialogue finished, wife enters
		_wife_enter()
	elif resource.resource_path.ends_with("HP_Afternoon3.dialogue"):
		# Wife dialogue finished, change scene
		SceneManager.change_scene("res://scenes/game.tscn")

func _nurse_leave():
	nurse_anim_player.play("leave")
	await nurse_anim_player.animation_finished
	nurse_sprite.visible = false
	
	# Load and show patient dialogue
	var patient_dialogue = load("res://Dialogue/HP_Afternoon2.dialogue")
	DialogueManager.show_dialogue_balloon(patient_dialogue)
	# Already connected dialogue_ended signal continues to listen

func _wife_enter():
	wife_sprite.visible = true
	wife_anim_player.play("enter")
	await wife_anim_player.animation_finished
	
	var wife_dialogue = load("res://Dialogue/HP_Afternoon3.dialogue")
	DialogueManager.show_dialogue_balloon(wife_dialogue)
