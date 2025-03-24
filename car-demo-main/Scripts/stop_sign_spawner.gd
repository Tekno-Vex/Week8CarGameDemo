extends Node3D

@export var stop_sign_scene: PackedScene  # Assign StopSign.tscn in the Inspector
@export var spawn_positions: Array[Vector3]  # Predefined spawn points along road
@export var max_stop_signs = 5  # Limit number of active stop signs

var active_stop_signs = []

func _ready():
	spawn_random_stop_signs()

func spawn_random_stop_signs():
	while active_stop_signs.size() < max_stop_signs:
		var position = get_random_position()
		var stop_sign = stop_sign_scene.instantiate()
		stop_sign.global_transform.origin = position
		stop_sign.stop_sign_cleared.connect(_on_stop_sign_removed)  # Listen for removal
		add_child(stop_sign)
		active_stop_signs.append(stop_sign)

func get_random_position():
	if spawn_positions.is_empty():
		return Vector3.ZERO
	return spawn_positions[randi() % spawn_positions.size()]  # Select a random location

func _on_stop_sign_removed(stop_sign):
	active_stop_signs.erase(stop_sign)  # Remove from active list
	spawn_random_stop_signs()  # Spawn a new stop sign elsewhere
