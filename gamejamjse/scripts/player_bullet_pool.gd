extends Node

# Assign the correct bullet scene in the Inspector for each pool
@export var bullet_scene: PackedScene

# An array to hold the inactive, ready-to-use bullets
var cached_nodes: Array[Node2D] = []

# This function is used by the shooter to get a bullet
func spawn() -> Node2D:
	# First, check if there's an inactive bullet in our cache
	if not cached_nodes.is_empty():
		var bullet = cached_nodes.pop_front()
		bullet.visible = true # Make it visible again
		return bullet
	else:
		# If the cache is empty, create a brand new bullet
		var bullet = bullet_scene.instantiate()
		add_child(bullet) # Add it to this node to keep the scene tree clean
		return bullet

# --- THIS IS THE MISSING FUNCTION ---
# This function is used by the BULLET to return itself to the pool
func return_bullet(bullet: Node2D):
	# Add the bullet back to our cache of inactive nodes
	cached_nodes.push_back(bullet)
	# Hide it so it's not visible or processed
	bullet.visible = false
