extends VehicleBody3D
class_name BaseCar

@onready var feedback_label = $UI/FeedbackLabel  # Reference to the UI Label
@onready var siren_sound = %SirenSound       # Reference to the siren sound

@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
var steer_target = 0
@export var engine_force_value = 40
var init_transform : Transform3D  # Store initial position


var fwd_mps : float
var speed: float

func _ready():
	init_transform = transform  # Save the starting position
	# Debugging node existence
	print("Looking for FeedbackLabel and SirenSound...")

	if has_node("UI/FeedbackLabel"):
		feedback_label = get_node("UI/FeedbackLabel")
		print("FeedbackLabel found!")
	else:
		print("Error: FeedbackLabel not found!")

	if has_node("SirenSound"):
		siren_sound = get_node("SirenSound")
		print("SirenSound found!")
	else:
		print("Error: SirenSound not found!")

func _physics_process(delta):
	speed = linear_velocity.length()*Engine.get_frames_per_second()*delta
	fwd_mps = transform.basis.x.x
	traction(speed)
	process_accel(delta)
	process_steer(delta)
	process_brake(delta)
	##%Hud/speed.text=str(round(speed*3.8 / 1.609))+"  MPH"

func process_accel(delta):
	var speed_mph = speed * 3.8 / 1.609
	var max_speed_mph = 100
	var speed_factor = max(0, (max_speed_mph - speed_mph) / max_speed_mph) 

	if Input.is_action_pressed("ui_up"):
		if fwd_mps >= -1:
			engine_force = clamp(
				engine_force_value * (1.0 / (1.0 + speed * 0.02)) * speed_factor, 
				0, 
				300
			)
		return
	
	if Input.is_action_pressed("ui_down"):
	# Increase engine force at low speeds to make the initial acceleration faster.
		if speed < 20 and speed != 0:
			engine_force = -clamp(engine_force_value * 3 / speed, 0, 300)
		else:
			engine_force = -engine_force_value
		return
	
	engine_force = 0
	brake = 0	

func process_steer(delta):
	steer_target = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	steer_target *= STEER_LIMIT
	steering = move_toward(steering, steer_target, STEER_SPEED * delta)

func process_brake(delta):
	if Input.is_action_pressed("ui_select"):
		brake=0.5
		$wheel_rear_left.wheel_friction_slip=2
		$wheel_rear_right.wheel_friction_slip=2
	else:
		$wheel_rear_left.wheel_friction_slip=2.9
		$wheel_rear_right.wheel_friction_slip=2.9


func traction(speed):
	apply_central_force(Vector3.DOWN*speed)


#func _on_area_3d_body_entered(body: Node3D) -> void:
	#if body.is_in_group("Trees"):  # Ensure your trees are in the "trees" group
		#reset_car()
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Collision detected with:", body.name)
	var message = ""

	# Determine the feedback message based on what the player hit
	if body.is_in_group("Trees"):
		message = "Watch out for Trees! Always scan the road ahead."

	# Display the feedback message
	if message != "":
		display_feedback(message)  # Only call this if there's a valid message
	
	
func reset_car():
	feedback_label.visible = false  # Hide the message
	PhysicsServer3D.body_set_state(
		get_rid(),
		PhysicsServer3D.BODY_STATE_TRANSFORM,
		init_transform
	)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func display_feedback(message: String):
	feedback_label.text = message  # Set the message text
	feedback_label.visible = true  # Show the message
	siren_sound.play()  # Play the police siren sound

	await get_tree().create_timer(2.0).timeout  # Wait for 3 seconds

	reset_car()  # Reset the car after the delay
