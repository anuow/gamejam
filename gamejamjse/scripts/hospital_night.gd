extends Control

@onready var wife_sprite: AnimatedSprite2D = $WifeAnimatedSprite2D
@onready var wife_anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	var wife_dialogue = load("res://Dialogue/HP_Night.dialogue")
	DialogueManager.show_dialogue_balloon(wife_dialogue)
	DialogueManager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))
	MusicManager.play_music(preload("res://Music/scene_2.ogg"))

func _on_dialogue_ended(resource: DialogueResource):
	if resource.resource_path.ends_with("HP_Night.dialogue"):
		_wife_leave()
		
	elif resource.resource_path.ends_with("HP_Night2.dialogue"):
		SceneManager.change_scene("res://scenes/lvl_2.tscn")

func _wife_leave():
	wife_anim_player.play("leave")
	await wife_anim_player.animation_finished
	wife_sprite.visible = false
	var patient_dialogue = load("res://Dialogue/HP_Night2.dialogue")
	DialogueManager.show_dialogue_balloon(patient_dialogue)
