extends Control

func _ready():
	var good_ending_dialogue = load("res://Dialogue/good_ending.dialogue")
	DialogueManager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))
	DialogueManager.show_dialogue_balloon(good_ending_dialogue)
	MusicManager.play_music(preload("res://Music/scene_1.ogg"))

func _on_dialogue_ended(resource: DialogueResource):
	if resource.resource_path.ends_with("good_ending.dialogue"):
		SceneManager.change_scene("res://scenes/EndCredits.tscn")
