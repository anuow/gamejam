extends Node

@export var fade_duration: float = 0.5

var current_scene: Node = null
var transition_layer: CanvasLayer = null
var color_rect: ColorRect = null
var game_data: Dictionary = {}

func _ready():
	transition_layer = CanvasLayer.new()
	add_child(transition_layer)
	color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0)
	# Set size to match the current viewport
	color_rect.size = get_viewport().size
	transition_layer.add_child(color_rect)
	color_rect.visible = false  # Hidden until a transition starts
	print("ColorRect size set to viewport: ", color_rect.size)

func change_scene(target_scene_path: String, data: Dictionary = {}):
	color_rect.visible = true
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, fade_duration)
	await tween.finished

	if current_scene:
		current_scene.queue_free()

	var new_scene = load(target_scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	current_scene = new_scene

	game_data = data

	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, fade_duration)
	await tween.finished
	color_rect.visible = false
