extends Control

func _ready():
	var dialogue = load("res://Dialogue/BadEnding.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue)
	DialogueManager.connect("dialogue_ended", Callable(self, "dialogue_ended"))
	
func dialogue_ended(resource: DialogueResource):
	if resource.resource_path.ends_with("BadEnding.dialogue"):
		SceneManager.change_scene("res://scenes/EndCredits.tscn")
