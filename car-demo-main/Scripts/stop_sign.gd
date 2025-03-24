extends Area3D

const STOP_TIME_REQUIRED = 3.0  # How long the car must stop (in seconds)

var car_in_area = false
var car_stopped_time = 0.0
var car: BaseCar = null  # Reference to the car in the stop zone
var has_stopped_properly = false  # New flag to track if the stop was valid

func _process(delta):
	if car_in_area and car != null:
		var speed_threshold = 0.5  
		var car_speed = car.linear_velocity.length()

		print("Car Speed:", car_speed, " | Stopped Time:", car_stopped_time)

		if car_speed < speed_threshold:
			if not has_stopped_properly:  # Only increase time if stop hasn't been confirmed
				car_stopped_time += delta
				car.linear_velocity = Vector3.ZERO  # Prevent rolling
			if car_stopped_time >= STOP_TIME_REQUIRED:
				has_stopped_properly = true  # Lock in the stop
		else:
			if not has_stopped_properly:
				car_stopped_time -= delta * 0.5  # Reduce time gradually if moving early

func _on_body_entered(body):
	if body is BaseCar:
		car = body
		car_in_area = true
		car_stopped_time = 0  # Reset stop timer
		has_stopped_properly = false  # Reset stop flag

func _on_body_exited(body):
	if body is BaseCar:
		if has_stopped_properly:
			print("Car stopped correctly.")
			car.successfully_stopped_at_stop_sign()  # Award points for correct stop
		else:
			print("Car did not stop long enough! Stopped for:", car_stopped_time, "seconds")
			car.apply_stop_sign_penalty()  # Apply penalty

		car_in_area = false
		car = null
		car_stopped_time = 0  # Reset after evaluation
		has_stopped_properly = false  # Reset stop flag
