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
var launch_timer
var stamina_stasis_timer

#
@onready var ui_master_node = $Pivot/PlayerUI
var ui_interact
var ui_notebook
var ui_health_bar
var ui_stamina_bar
var ui_death_screen
var ui_papers
var open_paper
var open_window

var potion_child : PackedScene = load("res://Scenes/Generics/ActiveGenericPotion.tscn")

@onready var status_manager : StatusManager = $PlayerStatusFXHandler

#Player Variables
var max_health
var curr_health
var max_stamina
var curr_stamina
var stamina_regen_factor
var sprinting
var dead
var speed_factor
var jump_factor
var vel_clamp
var clampable

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
	launch_timer = $LaunchTimer
	stamina_stasis_timer = $StaminaTimer
	
	ui_interact = $Pivot/PlayerUI/RichTextLabel
	ui_notebook = $Pivot/PlayerUI/NotebookMenu
	ui_health_bar = $Pivot/PlayerUI/HealthBar
	ui_stamina_bar = $Pivot/PlayerUI/StaminaBar
	ui_death_screen = $Pivot/PlayerUI/DeadPanel
	ui_papers = $Pivot/PlayerUI/CloseUpPapers
	
	max_health = 100.0
	curr_health = max_health
	max_stamina = 100.0
	curr_stamina = max_stamina
	stamina_regen_factor = 1.0
	sprinting = true
	dead = false
	speed_factor = 1.0
	jump_factor = 1.0
	
	vel_clamp = false
	clampable = true
	
	PlayerInventory.holding_index = 0 
	PlayerInventory.inventory = [null, null, null, null, null, null, null, null]
	
	SignalBus.show_paper.connect(_on_show_paper)
	SignalBus.open_storage_window.connect(_on_open_storage)
	SignalBus.open_dialogue_box.connect(_on_open_dialogue)

#------------------------------- Player Processes ------------------------------
func _process(delta):
	#Check for pausing
	if Input.is_action_just_pressed("pause"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and open_paper != null:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			open_paper.visible = false
			open_paper = null
			ui_notebook.play_randomized_page_audio()
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and open_window != null:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			ui_master_node.close_window()
			open_window = null
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and !dead:
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
			#Do nothing
		#If object can be interacted with
		elif body.has_method("interaction"):
			ui_interact.show()
			# Change Tooltip depending on what it is
			ui_interact.text = "[center](E) " + body.get_interact_text() + "[/center]"
			# If player interacts with object
			if Input.is_action_just_pressed("interact") && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				body.interaction(self)
	else:
		ui_interact.hide()
	
	#Update health bar and stamina bar, and check if the player is dead
	ui_health_bar.value = (curr_health / max_health) * 100
	if (curr_health <= 0 and !dead):
		dead = true
		ui_death_screen.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	ui_stamina_bar.value = curr_stamina / max_stamina * 100
	
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
					potion_light.omni_range = 1.5 + ((PlayerInventory.inventory[PlayerInventory.holding_index])["potency"] * .33)
					potion_light.omni_range = .75 + ((PlayerInventory.inventory[PlayerInventory.holding_index])["potency"] * .33)
				else:
					potion_light.visible = false
			else:
				held_item.visible = false
		else:
			held_item.visible = false
		
		#Sprinting
		sprinting = Input.is_action_pressed("sprint") and curr_stamina > 0 and stamina_stasis_timer.time_left <= 0
		if sprinting:
			curr_stamina = clamp(curr_stamina - (.2), 0, max_stamina)
			if curr_stamina <= 0:
				stamina_stasis_timer.start()
				ui_stamina_bar.modulate = Color(.5, 0, 0)
		else:
			if stamina_stasis_timer.time_left <= 0:
				curr_stamina = clamp(curr_stamina + (0.1 * stamina_regen_factor), 0, max_stamina)
				if ui_stamina_bar.modulate == Color(.5, 0, 0):
					ui_stamina_bar.modulate = Color(1, 1, 1)
		
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
	elif clampable:
		vel_clamp = true
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		velocity.y = JUMP_VELOCITY * jump_factor

	# Get the input direction and handle the movement/deceleration.
	var speed = ((BASE_SPEED + (1.25 if sprinting else 0.0)) * speed_factor) 
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
				status_manager.add_effect(aspect, 5, 2, 3 + (item_datalist["potency"] * .1), 0)
			"Healing":
				curr_health = clamp(curr_health + (item_datalist["potency"] * 1.2), 1, max_health)
			"Poison":
				status_manager.add_effect(aspect, 5, 2, 3 + (item_datalist["potency"] * .25), 0)
			"Harmful_Consumption": #General tag for ingredients not safe to eat.
				#Any healing ingredient will nullify this effect.
				if item_datalist["aspect"].find("Healing") != -1:
					damage((item_datalist["potency"] * .25))
	for effect in item_datalist["effect"]:
		print(effect)
		match(effect):
			"Wind":
				var j_modifier = (item_datalist["potency"] * .05)
				jump_factor = 1 + j_modifier
				status_manager.add_effect("Wind", 1, 10, 0, j_modifier)
			"Shrink":
				status_manager.add_effect("Shrink", 1, 6 + item_datalist["potency"] / 2, 0, 0)
			"Dizzy":
				status_manager.add_effect("Dizzy", 1, 10, 0, 0)
			"Light":
				pass
	#Remove item from inventory
	PlayerInventory.inventory[PlayerInventory.holding_index] = null
	print("Done")

# Applies Effect
#TODO: move stat mods to here or to status manager
func apply_effect(effect, repeats, duration, damage_amnt, potency):
	status_manager.add_effect(effect, repeats, duration, damage_amnt, potency)

#Puts persistent data within a dictionary that is sent to the save manager
func save():
	var save_dictionary = {
		"curr_health": curr_health,
		"inventory": PlayerInventory.inventory,
		"held_index": PlayerInventory.holding_index,
		"position": [global_position.x, global_position.y, global_position.z],
		"rotation": [rotation_pivot.rotation_degrees.x, rotation_pivot.rotation_degrees.y, rotation_pivot.rotation_degrees.z],
		"velocity": [velocity.x, velocity.y,velocity.z],
		"vel_clamp": vel_clamp,
		"active_effects": status_manager.status_save_data(),
		"collectibles": ui_master_node.collectibles
	}
	return save_dictionary

#Takes saved data from the save manager and applies it to respective attributes
func load_save(node_load_data : Dictionary):
	curr_health = node_load_data["curr_health"]
	PlayerInventory.inventory = node_load_data["inventory"]
	PlayerInventory.holding_index = node_load_data["held_index"]
	global_position = Vector3(node_load_data["position"][0], node_load_data["position"][1], node_load_data["position"][2])
	rotation_pivot.rotation_degrees = Vector3(node_load_data["rotation"][0], node_load_data["rotation"][1], node_load_data["rotation"][2])
	velocity = Vector3(node_load_data["velocity"][0], node_load_data["velocity"][1], node_load_data["velocity"][2])
	vel_clamp = node_load_data["vel_clamp"]
	var status_data = node_load_data["active_effects"]
	for i in range(len(status_data)):
		var fx = status_data[i][0]
		status_manager.add_effect(fx.status, fx.repeat, fx.duration, fx.dot, fx.potency, status_data[i][1])
	for item in node_load_data["collectibles"]:
		if node_load_data["collectibles"][item]:
			ui_master_node.unlock_collectible(item)

#========================= Signal Recieving Functions =========================#

## Time Out function for status effects
#func time_out_timer_statusef(id, statusef):
	#var status
	#for fx in effect_timers:
		#if fx.timer == id:
			#status = fx
			#break
	##Decrement the amount of repeat times. If at 0, the effect ends
	#status.repeat -= 1
	#if (status.repeat <= 0):
		#print("timeout")
		##Look at the associated effect to see if anything needs to be undone 
		#match(statusef):
			#"Wind":
				#jump_factor = 1
			#"Shrink":
				#global_scale(Vector3(2, 2, 2))
			#"Dizzy":
				#clampable = true
				#speed_factor = speed_factor + .8
		##Destroys the timer
		#ui_master_node.remove_status(statusef)
		#status.timer.call_deferred("queue_free")
		#effect_timers.erase(status)

func damage(damage_amnt):
	curr_health = clamp(curr_health - damage_amnt, 0, max_health)
	audio_player.stream = damage_audio
	audio_player.play()

func _on_kill_box_body_entered(body):
	curr_health = 0

func _on_launch_timer_timeout():
	clampable = true

#--------------------------------------------UI Windows---------------------------------------------

func _on_show_paper(page_id):
	print(page_id)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	open_paper = ui_papers.get_node(page_id)
	open_paper.visible = true
	ui_notebook.play_randomized_page_audio()

func _on_open_storage(window_source, type):
	ui_master_node.display_storage_window(window_source, type)
	open_window = window_source
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_open_dialogue(npc_name, dialogue_track):
	ui_master_node.display_dialogue_window(npc_name, dialogue_track)
	open_window = ui_master_node.dialogue_window
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
