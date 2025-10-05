extends Node

@export var fade_duration: float = 0.5

var transition_layer: CanvasLayer = null
var color_rect: ColorRect = null
# No longer need to track current_scene or game_data here

func _ready():
	# Make sure the transition layer persists across scene changes
	process_mode = Node.PROCESS_MODE_ALWAYS 

	transition_layer = CanvasLayer.new()
	transition_layer.layer = 128 # High layer to ensure it's on top
	add_child(transition_layer)
	
	color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 1) # Start faded IN (black screen)
	color_rect.size = get_viewport().size
	transition_layer.add_child(color_rect)
	
	# Start the game by fading in the first scene
	fade_in()

# Call this to transition TO a new scene
func change_scene(target_scene_path: String):
	await fade_out()
	
	# Load the scene as a PackedScene resource
	var packed_scene = load(target_scene_path)
	
	# This properly removes the old scene and adds the new one,
	# setting it as the "current_scene" automatically.
	get_tree().change_scene_to_packed(packed_scene)
	
	# After the scene changes, the SceneManager is still here (as an autoload).
	# Now we can fade the new scene in.
	await fade_in()

func fade_in():
	color_rect.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(color_rect, "color:a", 0.0, fade_duration)
	await tween.finished
	color_rect.visible = false

func fade_out():
	color_rect.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(color_rect, "color:a", 1.0, fade_duration)
	await tween.finished
