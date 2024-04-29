extends CharacterBody3D
class_name Player

#Constants for movement
const BASE_SPEED = 4.75
const JUMP_VELOCITY = 5.0
const MOUSE_SENSITIVITY = 0.20

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Variables for everything under the rotation pivot/'face' (Camera + Raycast)
var camera
var rotation_pivot
var raycast
var held_item
var potion_light

var audio_player
var eat_audio = [preload("res://Assets/SoundEffects/crunch.1.ogg"),
				preload("res://Assets/SoundEffects/crunch.2.ogg"),
				preload("res://Assets/SoundEffects/crunch.3.ogg"),
				preload("res://Assets/SoundEffects/crunch.4.ogg")]
var potion_audio = preload("res://Assets/SoundEffects/bottle-glass-uncork-03.wav")
var throw_audio = preload("res://Assets/SoundEffects/air_move.wav")
var damage_audio = preload("res://Assets/SoundEffects/take_damage.wav")
var step_audio_player
var step_timer

var ui_interact
var ui_notebook
var ui_health_bar
var ui_death_screen

var potion_child : PackedScene = load("res://Scenes/Generics/ActiveGenericPotion.tscn")

#Player Variables
var max_health
var curr_health
var dead
var speed_factor
var vel_clamp

#Initializing Function
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	camera = $Pivot/PlayerCamera
	raycast = $Pivot/RayCast3D
	rotation_pivot = $Pivot
	held_item = $Pivot/HeldPotionBottle
	potion_light = $Pivot/HeldPotionBottle/HeldPotionLight
	
	audio_player = $Pivot/On_PersonAudioPlayer
	step_audio_player = $StepAudioPlayer
	step_timer = $StepTimer
	
	ui_interact = $Pivot/PlayerUI/RichTextLabel
	ui_notebook = $Pivot/PlayerUI/NotebookMenu
	ui_health_bar = $Pivot/PlayerUI/HealthBar
	ui_death_screen = $Pivot/PlayerUI/DeadPanel
	
	max_health = 100
	curr_health = max_health
	dead = false
	speed_factor = 1
	
	PlayerInventory.holding_index = 0 
	PlayerInventory.inventory = [null, null, null, null, null, null, null, null]
#------------------------------- Player Processes ------------------------------
func _process(delta):
	#Check for pausing
	if Input.is_action_just_pressed("pause"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and !dead:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			ui_notebook.visible = false
			ui_notebook.play_randomized_page_audio()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			ui_notebook.visible = true
			ui_notebook.play_randomized_page_audio()
	
	#Handle Raycast
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var body = raycast.get_collider()
		if body == null:
			ui_interact.hide()
			null
			#Do nothing
		#If object can be interacted with
		elif body.has_method("interaction"):
			ui_interact.show()
			# Change Tooltip depending on what it is
			if "mat_datalist" in body:
				ui_interact.text = "[center](E) Pick Up[/center]"
			elif "object_name" in body:
				match(body.object_name):
					"cauldron":
						ui_interact.text = "[center](E) Add to Cauldron[/center]"
					"nozzle":
						ui_interact.text = "[center](E) Pour Mixture[/center]"
					_: #Default
						ui_interact.text = "[center](E) Interact[/center]"
			# If player interacts with object
			if Input.is_action_just_pressed("interact") && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				body.interaction(self)
	else:
		ui_interact.hide()
	
	#Update health bar, and check if the player is dead
	ui_health_bar.value = curr_health
	if (curr_health <= 0 and !dead):
		dead = true
		ui_death_screen.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	#Get Inputs, determine based on if mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Switching held item in inventory
		if Input.is_action_just_pressed("scroll_wheel_down"):
			if PlayerInventory.holding_index == 7:
				PlayerInventory.holding_index = 0
			else:
				PlayerInventory.holding_index = PlayerInventory.holding_index + 1
			print(PlayerInventory.holding_index)
			print(PlayerInventory.inventory[PlayerInventory.holding_index])
		elif Input.is_action_just_pressed("scroll_wheel_up"):
			if PlayerInventory.holding_index == 0:
				PlayerInventory.holding_index = 7
			else:
				PlayerInventory.holding_index = PlayerInventory.holding_index - 1
			print(PlayerInventory.holding_index)
			print(PlayerInventory.inventory[PlayerInventory.holding_index])
		# Change displayed held item
		if PlayerInventory.inventory[PlayerInventory.holding_index] != null:
			if (PlayerInventory.inventory[PlayerInventory.holding_index])["name"] == "potion":
				held_item.visible = true
				if (PlayerInventory.inventory[PlayerInventory.holding_index])["effect"].find("Light") != -1:
					potion_light.visible = true
					potion_light.light_color = Color8(int((PlayerInventory.inventory[PlayerInventory.holding_index])["color"][0]), int((PlayerInventory.inventory[PlayerInventory.holding_index])["color"][1]), int((PlayerInventory.inventory[PlayerInventory.holding_index])["color"][2]))
					potion_light.omni_range = 1.5 + ((PlayerInventory.inventory[PlayerInventory.holding_index])["potency"] * .1)
				else:
					potion_light.visible = false
			else:
				held_item.visible = false
		else:
			held_item.visible = false
		
		# Player Throw/Consume Actions (maybe change inputs?)
		if Input.is_action_just_pressed("drop-throw"):
			if PlayerInventory.inventory[PlayerInventory.holding_index] != null:
				if (PlayerInventory.inventory[PlayerInventory.holding_index])["name"] == "potion":
					print("throw potion")
					throw_potion()
				else:
					print("drop item")
		elif Input.is_action_just_pressed("consume"):
			if PlayerInventory.inventory[PlayerInventory.holding_index] != null:
				if (PlayerInventory.inventory[PlayerInventory.holding_index])["name"] == "potion":
					print("drink potion")
					audio_player.stream = potion_audio
					audio_player.play()
				else:
					print("eat item")
					audio_player.stream = eat_audio[randi_range(0, 3)]
					audio_player.play()
				consume_held()
	
#Movement Calculation
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		vel_clamp = true
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var speed = (BASE_SPEED * speed_factor)
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if vel_clamp:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x += direction.x * (speed * .05)
			velocity.z += direction.z * (speed * .05)
		if is_on_floor() and step_timer.time_left <= 0:
			step_audio_player.pitch_scale = randf_range(0.8, 1.2)
			step_audio_player.play()
			step_timer.start(clampf(0.5 * (1 + ((BASE_SPEED - speed) * 0.25)), 0.1, 0.9))
			print(clampf(0.5 * (1 + ((BASE_SPEED - speed) * 0.25)), 0.1, 0.9))
	else:
		if vel_clamp:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		else:
			pass
			#velocity.x += move_toward(velocity.x, 0, speed)
			#velocity.z += move_toward(velocity.z, 0, speed)
	move_and_slide()

#------------------------------ Other Function(s) ------------------------------
#Camera Movement Algorithm
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_pivot.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		var camera_rot = rotation_pivot.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -90, 70)
		rotation_pivot.rotation_degrees = camera_rot

#Create potion instance to throw
func throw_potion():
	#Create Instance
	var scene_root = get_tree().root.get_children()[0]
	var potion_instance = potion_child.instantiate()
	potion_instance.pot_datalist = PlayerInventory.inventory[PlayerInventory.holding_index]
	#Setup Physics for throw
	var direction = rotation_pivot.global_position.direction_to(raycast.to_global(raycast.target_position))
	potion_instance.position = rotation_pivot.global_position + (direction)
	scene_root.add_child(potion_instance)
	potion_instance.apply_central_impulse(direction * 8)
	potion_instance.angular_velocity = Vector3(randi_range(-15, 15), randi_range(-15, 15), randi_range(-15, 15))
	#Remove Potion from the inventory
	PlayerInventory.inventory[PlayerInventory.holding_index] = null
	
	#play throwing sound effect
	audio_player.stream = throw_audio
	audio_player.play()
	print("Done")

#Consume Potion/Item
func consume_held():
	#Get Datalist from held item
	var item_datalist = PlayerInventory.inventory[PlayerInventory.holding_index]
	#Apply Effects/Aspects to Player (match case?)
	for aspect in item_datalist["aspect"]:
		print(aspect)
		match(aspect):
			"Fire":
				apply_effect(aspect, 5, 2, 3 + (item_datalist["potency"] * .1))
			"Healing":
				curr_health = clamp(curr_health + (item_datalist["potency"] * 1.2), 1, max_health)
			"Poison":
				apply_effect(aspect, 5, 2, 3 + (item_datalist["potency"] * .25))
	for effect in item_datalist["effect"]:
		print(effect)
		match(effect):
			"Wind":
				speed_factor = 1 + (item_datalist["potency"] * .05)
				apply_effect(effect, 1, 10, 0)
			"Light":
				pass
	#Remove item from inventory
	PlayerInventory.inventory[PlayerInventory.holding_index] = null
	print("Done")

# Applies Effect
var counter = 0
var effect_timers = {}
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

#-------------------------- Signal Recieving Functions -------------------------
# Time Out function
func time_out_timer_statusef(id, statusef):
	#Decrement the amount of repeat times. If at 0, the effect ends
	effect_timers[id].repeat -= 1
	if (effect_timers[id].repeat == 0):
		print("timeout")
		#Look at the associated effect to see if anything needs to be undone 
		match(statusef):
			"Wind":
				speed_factor = 1
			
		#Destroys the timer
		effect_timers[id].timer.call_deferred("queue_free")
		effect_timers.erase(id)

# Damage Over Time Function
func damage_over_time(damage):
	curr_health = clamp(curr_health - damage, 0, max_health)
	audio_player.stream = damage_audio
	audio_player.play()

func _on_kill_box_body_entered(body):
	curr_health = 0
