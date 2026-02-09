extends CharacterBody3D
class_name Actor

@onready var nav_agent : NavigationAgent3D = $MeshInstance3D/NavigationAgent3D
@onready var nav_timer : Timer = $NavigationTimer

var idle = true
@export var movement_speed : float = 2.0
@export var jump_velocity : float = 8.0
var movement_target_position: Vector3
var target_entity

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var jump_factor = 1
@onready var speed_factor = 1
var vel_clamp = false
var clampable = true

var particle_emitter : PackedScene = load("res://Scenes/Generics/StatusParticles.tscn")

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	nav_agent.path_desired_distance = 1
	nav_agent.target_desired_distance = 5

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
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif clampable:
		vel_clamp = true
	general_movement_calculation()
	move_and_slide()

func _process(delta):
	pass

func general_movement_calculation():
		if nav_agent.is_navigation_finished() && vel_clamp:
			velocity.x = 0
			velocity.z = 0
		else:
			var current_agent_position : Vector3 = global_position
			var next_path_position : Vector3 = nav_agent.get_next_path_position()
			var next_path_pos_flattened : Vector3 = Vector3(next_path_position.x, global_position.y, next_path_position.z)
			#print(next_path_pos_flattened)
			#velocity = current_agent_position.direction_to(next_path_position) * (movement_speed * speed_factor)
			
			self.look_at(next_path_pos_flattened)
			
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
		movement_target_position = Vector3(randf_range(global_position.x - 20.0, global_position.x + 20.0),
		randf_range(global_position.y - 20.0, global_position.y + 20.0),
		randf_range(global_position.z - 20.0, global_position.z + 20.0))
		set_movement_target(movement_target_position)
		print("New Idle")
		nav_timer.start(15)
	elif global_position.distance_to(target_entity.global_position) >= 40:
		target_entity = null
		idle = true
		print("Deaggro")
		nav_timer.start(15)
	else:
		movement_target_position = target_entity.global_position
		set_movement_target(movement_target_position)
		nav_timer.start(1)
		print("Aggro")

func attack(action : String):
	pass

# Applies Effect
var counter = 0
var effect_timers = {}
func apply_effect(effect, repeats, duration, damage, potency):
	# Define Timer
	var timer = Timer.new()
	timer.wait_time = duration
	timer.autostart = true
	#Create and define particles for the effect
	var status_particles = particle_emitter.instantiate()
	status_particles.define_status(effect)
	add_child(status_particles)
	# Bind timeout and DOT (if any) functions to it
	if (damage != 0):
		timer.timeout.connect(damage_over_time.bind(damage))
	timer.timeout.connect(time_out_timer_statusef.bind(counter, effect, potency))
	#Add timer to timer list, 
	effect_timers[counter] = {repeat = repeats, timer = timer, power = potency, particles = status_particles}
	add_child(timer)
	counter += 1

# Time Out function
func time_out_timer_statusef(id, statusef, potency):
	#Decrement the amount of repeat times. If at 0, the effect ends
	effect_timers[id].repeat -= 1
	if (effect_timers[id].repeat == 0):
		print("timeout")
		#Look at the associated effect to see if anything needs to be undone 
		match(statusef):
			"Wind":
				jump_factor = 1
			"Shrink":
				global_scale(Vector3(2, 2, 2))
			"Dizzy":
				clampable = true
		#Destroys the timer and the particle emitter
		effect_timers[id].particles.call_deferred("queue_free")
		effect_timers[id].timer.call_deferred("queue_free")
		effect_timers.erase(id)

# Damage Over Time Function
func damage_over_time(damage):
	pass

func declamp():
	clampable = true
