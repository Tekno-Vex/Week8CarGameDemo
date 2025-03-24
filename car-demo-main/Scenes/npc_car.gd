extends Node3D

@export var path_follow: PathFollow3D  # Assign this in the Inspector
@export var speed: float = 5.0  # Default speed (adjust as needed)
@export var stop_duration: float = 3.0  # How long NPC stops at stop signs

var is_stopped = false  # Tracks if the NPC is stopped
var stop_timer = 0.0  # Countdown for stopping
var current_speed = speed  # Dynamic speed variable

func _process(delta):
	if not path_follow:
		return  # Ensure path_follow is assigned

	if is_stopped:
		stop_timer -= delta
		if stop_timer <= 0:
			is_stopped = false  # Resume movement
			current_speed = speed  # Restore original speed
	else:
		path_follow.progress += current_speed * delta  # Move forward

# Called when NPC enters a stop sign
func _on_stop_sign_area_entered():
	is_stopped = true
	stop_timer = stop_duration
	current_speed = 0  # Stop movement

# Called when NPC leaves a stop sign
func _on_stop_sign_area_exited():
	is_stopped = false
	current_speed = speed  # Resume normal speed

# Handle collisions with the player car
func _on_body_entered(body):
	if body is BaseCar:
		print("Collision! The player hit an NPC car.")
		body.display_feedback("Watch out! Don't crash into other cars.")
