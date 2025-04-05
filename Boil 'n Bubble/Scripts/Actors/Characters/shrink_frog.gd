extends Actor

var health = 20
var max_health = 20
var dead = false

signal queue_respawn(id)

var movement_state

@onready var spore_area = $SporeArea
@onready var attack_timer = $AttackCooldown
@onready var spore_timer = $BarfCooldown
@onready var jump_timer = $JumpCooldown
@onready var respawn_timer = $RespawnTimer
@onready var animation_tree : AnimationTree = $MeshInstance3D/AnimationTree
@onready var animation_state = animation_tree["parameters/StateMachine/playback"]

@export var drop : PackedScene

func _ready():
	#Ready the enemy (in case it is "respawning")
	self.visible = true
	for col in self.find_children("CollisionShape"):
		col.disabled = false
	health = 20
	max_health = 20
	dead = false
	
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	nav_agent.path_desired_distance = 1.0
	nav_agent.target_desired_distance = 5.0

	movement_target_position = Vector3(randf_range(global_position.x - 20.0, global_position.x + 20.0),
		randf_range(global_position.y - 2, global_position.y + 2),
		randf_range(global_position.z - 20.0, global_position.z + 20.0))

	# Make sure to not await during _ready.
	actor_setup.call_deferred(true)
	pass

#Behavior process
func _process(delta):
	if !dead:
		var distance_to_target = self.global_position.distance_to(movement_target_position)
		if distance_to_target <= 5.0 && !idle && is_on_floor() && attack_timer.time_left <= 0: #(add cooldown timer)
			#attack
			var attack_chance = randi_range(0, 100)
			animation_state.travel("Armature|Attack")
			if attack_chance <= 49 && spore_timer.time_left <= 0:
				attack("spores")
				print("spores")
				spore_timer.start()
			else:
				attack("basic")
				print("basic")
				attack_timer.start()

func general_movement_calculation():
	if !dead:
		if nav_agent.is_navigation_finished() && vel_clamp:
			velocity.x = 0
			velocity.z = 0
			animation_state.travel("Armature|Idle")
		else:
			var current_agent_position : Vector3 = global_position
			var next_path_position : Vector3 = nav_agent.get_next_path_position()
			var next_path_pos_flattened : Vector3 = Vector3(next_path_position.x, global_position.y, next_path_position.z)
			
			if !vel_clamp:
				self.look_at(movement_target_position)
			else:
				self.look_at(next_path_pos_flattened)
			
			var distance_to_target = current_agent_position.distance_to(movement_target_position)
			if distance_to_target >= 10 && !idle && is_on_floor() && jump_timer.time_left <= 0:
				print("jump")
				velocity.y = jump_velocity * jump_factor
				velocity.x = current_agent_position.direction_to(nav_agent.target_position).x * (movement_speed * 4)
				velocity.z = current_agent_position.direction_to(nav_agent.target_position).z * (movement_speed * 4)
				vel_clamp = false
				jump_timer.start()
				animation_state.travel("Armature|Jump")
			elif ((current_agent_position.direction_to(next_path_position).y >= 0.9) &&
				(abs(current_agent_position.direction_to(next_path_position).x) < 0.01 &&
				abs(current_agent_position.direction_to(next_path_position).z) < 0.01) && is_on_floor()):
				animation_state.travel("Armature|Jump")
				velocity.y = jump_velocity * jump_factor #normal jump
			else: #walk (or fly)
				if !vel_clamp: #Flying from jump
					velocity.x += current_agent_position.direction_to(nav_agent.target_position).x * (movement_speed * (speed_factor / 3))
					velocity.z += current_agent_position.direction_to(nav_agent.target_position).z * (movement_speed * (speed_factor / 3))
				else: #Normal Walking
					if animation_state.get_current_node() != "Armature|Walk":
						animation_state.travel("Armature|Walk")
					velocity.x = current_agent_position.direction_to(next_path_pos_flattened).x * (movement_speed * speed_factor)
					velocity.z = current_agent_position.direction_to(next_path_pos_flattened).z * (movement_speed * speed_factor)

func attack(action : String):
	var affected_bodies = spore_area.get_overlapping_bodies()
	match(action):
		"basic":
			for body in affected_bodies:
				print(body)
				if body.has_method("damage_over_time") && body != self:
					body.damage_over_time(10)
		"spores":
			#barf spores
			for body in affected_bodies:
				print(body)
				if body.has_method("apply_effect") && body != self:
					body.global_scale(Vector3(.5, .5, .5))
					body.apply_effect("Shrink", 1, 10, 0)

func save():
	var save_dictionary = {
		"position": [global_position.x, global_position.y, global_position.z],
		"target_position": [movement_target_position.x, movement_target_position.y, movement_target_position.z],
		"target_entity": target_entity,
		"idle": idle,
		"health": health
	}
	return save_dictionary

func load_save(load_data):
	if load_data[health] <= 0: #Enemy is dead
		self.visible = false
		for col in self.find_children("CollisionShape"):
			col.disabled = true
		respawn_timer.start()
	else:
		global_position = Vector3(load_data["position"][0], load_data["position"][1], load_data["position"][2])
		set_movement_target(Vector3(load_data["target_position"][0], load_data["target_position"][1], load_data["target_position"][2]))
		health = load_data["health"]
		idle = load_data["idle"]
		target_entity = load_data["target_entity"]
		_on_navigation_timer_timeout() #kickstart navigation

func damage_over_time(damage):
	health = clamp(health - damage, 0, max_health)
	
	if health == 0:
		die()

func apply_effect(effect, repeats, duration, damage):
	# Define Timer
	var timer = Timer.new()
	timer.wait_time = duration
	timer.autostart = true
	# Bind timeout and DOT (if any) functions to it
	if (damage != 0):
		timer.timeout.connect(damage_over_time.bind(damage))
	timer.timeout.connect(time_out_timer_statusef.bind(counter, effect))
	#Add timer to timer list, 
	effect_timers[counter] = {repeat = repeats, timer = timer}
	add_child(timer)
	counter += 1

func time_out_timer_statusef(id, statusef):
	#Decrement the amount of repeat times. If at 0, the effect ends
	effect_timers[id].repeat -= 1
	if (effect_timers[id].repeat <= 0):
		print("timeout")
		#Look at the associated effect to see if anything needs to be undone 
		match(statusef):
			"Wind":
				jump_factor = 1
			"Shrink":
				global_scale(Vector3(2, 2, 2))
		#Destroys the timer
		effect_timers[id].timer.call_deferred("queue_free")
		effect_timers.erase(id)

func die():
	dead = true
	#TODO: make & play death animation
	var new_material = drop.instantiate()
	new_material.global_position = global_position + Vector3(0, .5, 0)
	get_tree().root.get_children()[0].add_child(new_material)
	
	#"get rid" of the enemy and queue it for "respawning"
	self.visible = false
	for col in self.find_children("CollisionShape"):
		col.disabled = true
	respawn_timer.start()

func _on_respawn_timer_timeout():
	_ready() #reinitialize the 
