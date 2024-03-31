extends CharacterBody3D
class_name Player

#Constants for movement
const BASE_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.20

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Variables for everything under the rotation pivot/'face' (Camera + Raycast)
var camera
var rotation_pivot
var raycast
var held_item

var interaction
var ui_interact
var ui_notebook

var potion_child : PackedScene = preload("res://Scenes/Generics/ActiveGenericPotion.tscn")

#Player Variables
var max_health
var curr_health
var speed_factor
var vel_clamp

#Initializing Function
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	camera = $Pivot/PlayerCamera
	raycast = $Pivot/RayCast3D
	rotation_pivot = $Pivot
	held_item = $Pivot/HeldPotionBottle
	
	ui_interact = $Pivot/PlayerUI/RichTextLabel
	ui_notebook = $Pivot/PlayerUI/NotebookMenu
	
	max_health = 100
	curr_health = max_health
	speed_factor = 1

#------------------------------- Player Processes ------------------------------
func _process(delta):
	#Check for pausing
	if Input.is_action_just_pressed("pause"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			ui_notebook.visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			ui_notebook.visible = true
	
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
			else:
				ui_interact.text = "[center](E) Interact[/center]"
			# If player interacts with object
			if Input.is_action_just_pressed("interact") && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				body.interaction()
	else:
		ui_interact.hide()
	
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
				else:
					print("eat item")
				consume_held()
	
#Movement Calculation
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		vel_clamp = true
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var speed = (BASE_SPEED * speed_factor)
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if vel_clamp:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x += direction.x * (speed * .05)
			velocity.z += direction.z * (speed * .05)
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
				curr_health = clamp(curr_health + (item_datalist["potency"] * .4), 1, max_health)
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
	print(damage)
	pass
