extends CharacterBody3D
class_name Actor

@onready var nav_agent : NavigationAgent3D = $MeshInstance3D/NavigationAgent3D
@onready var nav_timer : Timer = $NavigationTimer

var idle = true
var movement_speed : float = 2.0
var jump_velocity : float = 8.0
var movement_target_position: Vector3
var target_entity

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var jump_factor = 1
@onready var speed_factor = 1

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5

	movement_target_position = Vector3(randf_range(global_position.x - 20.0, global_position.x + 20.0),
		randf_range(global_position.y - 2, global_position.y + 2),
		randf_range(global_position.z - 20.0, global_position.z + 20.0))

	# Make sure to not await during _ready.
	actor_setup.call_deferred()
	pass

func actor_setup(wandering : bool = true):
	await get_tree().physics_frame
	set_movement_target(movement_target_position)
	if wandering:
		nav_timer.start(15)

func set_movement_target(movement_target: Vector3):
	nav_agent.set_target_position(movement_target)

func _physics_process(delta):
	#print("On Floor: " + str(is_on_floor()))
	#print("Position: " + str(global_position))
	if not is_on_floor():
		velocity.y -= gravity * delta
	if nav_agent.is_navigation_finished():
		#print("navigation finished")
		velocity.x = 0
		velocity.z = 0
	else:
		general_movement_calculation()
	move_and_slide()
	#print("Distance to Target:" + str(nav_agent.distance_to_target()))
	#print("----------------------------------------------------------")
	pass

func _process(delta):
	pass

func general_movement_calculation():
		var current_agent_position : Vector3 = global_position
		var next_path_position : Vector3 = nav_agent.get_next_path_position()
		var next_path_pos_flattened : Vector3 = Vector3(next_path_position.x, global_position.y, next_path_position.z)
		#print(next_path_pos_flattened)
		#velocity = current_agent_position.direction_to(next_path_position) * (movement_speed * speed_factor)
		velocity.x = current_agent_position.direction_to(next_path_pos_flattened).x * (movement_speed * speed_factor)
		velocity.z = current_agent_position.direction_to(next_path_pos_flattened).z * (movement_speed * speed_factor)
		
		#print("Next Path Pos: " + str(next_path_position))
		#rint("Next Path Pos Flat: " + str(next_path_position))
		#print("Direction to Next Path: " + str(current_agent_position.direction_to(next_path_position)))
		
		if ((current_agent_position.direction_to(next_path_position).y >= 0.9) &&
			(abs(current_agent_position.direction_to(next_path_position).x) < 0.01 &&
			abs(current_agent_position.direction_to(next_path_position).z) < 0.01) && is_on_floor()):
			velocity.y = jump_velocity * jump_factor
		#print("Velocity" + str(velocity))

func _on_aggro_sphere_body_entered(body):
	if body is Player && idle:
		print("player detected")
		target_entity = body
		set_movement_target(target_entity.global_position)
		idle = false
		nav_timer.start(1)
	pass # Replace with function body.

func _on_navigation_timer_timeout():
	if idle:
		set_movement_target(Vector3(randf_range(global_position.x - 20.0, global_position.x + 20.0),
		randf_range(global_position.y - 20.0, global_position.y + 20.0),
		randf_range(global_position.z - 20.0, global_position.z + 20.0)))
		print("New Idle")
		nav_timer.start(15)
	elif global_position.distance_to(target_entity.global_position) >= 40:
		target_entity = null
		idle = true
		print("Deaggro")
		nav_timer.start(15)
	else:
		set_movement_target(target_entity.global_position)
		nav_timer.start(1)
		print("Aggro")
