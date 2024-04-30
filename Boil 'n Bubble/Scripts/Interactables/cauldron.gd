extends StaticInteractable

var datalist
var complexity
var complexity_limit
var material_num

var aspects
var effects

var explosion_timer : Timer
var explosion_time_left
var explosion_hitbox
var unstable

var ambient_audio_player #Plays unstable and ambient audio
var unstable_audio = preload("res://Assets/SoundEffects/loop_water_02.wav")
var pour_audio = preload("res://Assets/SoundEffects/water pouring into glass 4.wav")
var active_audio_player #For adding and explosion audio
var add_audio = preload("res://Assets/SoundEffects/splash_02.ogg")
var explosion_audio = preload("res://Assets/SoundEffects/cauldron_explosion.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	object_name = "cauldron"
	datalist = {
		"color": [0, 0, 0],
		"aspect": ["None"],
		"effect": ["None"],
		"potency": 0
	}
	aspects = ["None"]
	effects = ["None"]
	
	complexity = 0
	complexity_limit = 6
	material_num = 0
	
	explosion_timer = $CauldronExplosionTimer
	explosion_time_left = explosion_timer.get_wait_time()
	explosion_hitbox = $ExplosionCollisionBox
	unstable = false
	
	ambient_audio_player = $AudioStreamPlayer3D
	active_audio_player = $SecondaryAudioStreamPlayer3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#If the mixture is unstable and then falls under the complexity limit,
	# it restabilizes.
	if complexity <= complexity_limit:
		if unstable:
			unstable = false
			explosion_timer.paused = true
		elif explosion_time_left < explosion_timer.get_wait_time():
			explosion_time_left = clamp(explosion_time_left + (delta * .5), 0.1, explosion_timer.get_wait_time())
			print(explosion_time_left)
	else:
		explosion_time_left = explosion_timer.get_time_left()
		print(explosion_time_left)

# Interaction function for raycasting
func interaction(caller):
	var mat_dictionary = PlayerInventory.inventory[PlayerInventory.holding_index]
	#Potions and empty iventories can't be added
	if mat_dictionary == null or (mat_dictionary)["name"] == "potion":
		print("Invalid Component")
	else:
		active_audio_player.stream = add_audio
		active_audio_player.play()
		# Remove material from inventory
		PlayerInventory.inventory[PlayerInventory.holding_index] = null
		# Add aspect, replace if it is empty, don't add if aspect exists
		if datalist["aspect"].find("None") != -1:
			datalist["aspect"] = mat_dictionary["aspect"]
		else:
			for aspect in mat_dictionary["aspect"]:
				if datalist["aspect"].find(aspect) == -1 and  aspect != "None":
					datalist["aspect"].append(aspect)
		# Add effect, replace if it is empty, don't add if effect exists
		if datalist["effect"].find("None") != -1:
			datalist["effect"] = mat_dictionary["effect"]
		else:
			for effect in mat_dictionary["effect"]:
				if datalist["effect"].find(effect) == -1 and effect != "None":
					datalist["effect"].append(effect)
		# Add color
		(datalist["color"])[0] = (datalist["color"])[0] + (mat_dictionary["color"])[0]
		(datalist["color"])[1] = (datalist["color"])[1] + (mat_dictionary["color"])[1]
		(datalist["color"])[2] = (datalist["color"])[2] + (mat_dictionary["color"])[2]
		# Add Potency
		datalist["potency"] = datalist["potency"] + mat_dictionary["potency"]
		# Add complexity, then check for overload
		complexity = complexity + mat_dictionary["complexity"]
		print(complexity)
		material_num = material_num + 1
		#If complexity goes over limit, start countdown and make unstable
		if complexity > complexity_limit and !unstable:
			print("warning, exceeding complexity limit")
			unstable = true
			explosion_timer.paused = false
			explosion_timer.start(explosion_time_left)
			ambient_audio_player.stream = unstable_audio
			ambient_audio_player.play()
		print("Datalist " + str(mat_dictionary) + " added")

# Signal Function to start brewing
func _on_nozzle_start_brewing():
	if material_num != 0 && !unstable:
		var potion = {
			"name": "potion",
			"icon": "res://Assets/Sprites/PotionBottle.png",
			"color": [(datalist["color"])[0] / material_num,
					  (datalist["color"])[1] / material_num,
					  (datalist["color"])[2] / material_num],
			"aspect": datalist["aspect"],
			"effect": datalist["effect"],
			"potency": datalist["potency"]
		}
		var index = PlayerInventory.inventory.find(null)
		if (index != -1):
			ambient_audio_player.stream = pour_audio
			ambient_audio_player.play()
			PlayerInventory.inventory[index] = potion
			datalist = {
				"color": [0, 0, 0],
				"aspect": ["None"],
				"effect": ["None"],
				"potency": 0
			}
			complexity = 0
			
			material_num = 0
			print("Pick-Up Successful")
		else:
			print('inventory full')
	else:
		print("Unable to brew.")

func _on_cauldron_explosion_timeout():
	print("cauldron is exploding")
	active_audio_player.stream = explosion_audio
	active_audio_player.play()
	#Simulate the explosion
	var bodies = explosion_hitbox.get_overlapping_bodies()
	for target_body in bodies:
		print(target_body)
		print(target_body.has_method("check_weakness"))
		if (target_body is RigidBody3D) or (target_body is CharacterBody3D):
			if ("curr_health" in target_body):
				target_body.curr_health = target_body.curr_health - (datalist["potency"] * .5)
			for aspect in datalist["aspect"]:
				print(aspect)
				match(aspect):
					"Fire":
						if target_body.has_method("apply_effect"):
							target_body.apply_effect(aspect, 5, 2, 3 + (datalist["potency"] * .1))
					"Healing":
						if (target_body is CharacterBody3D) and ("curr_health" in target_body):
							target_body.curr_health = clamp(target_body.curr_health + (datalist["potency"] * .25), 1, target_body.max_health)
					"Poison":
						if target_body.has_method("apply_effect"):
							target_body.apply_effect(aspect, 5, 2, 3 + (datalist["potency"] * .15))
			for effect in datalist["effect"]:
				print(effect)
				match(effect):
					"Wind":
						var direction = explosion_hitbox.global_position.direction_to(target_body.global_position + Vector3(0, .5, 0))
						print(direction)
						#For player, apply it to the velocity and temporarily deactivate the velocity limiter
						if target_body is CharacterBody3D:
							target_body.vel_clamp = false
							target_body.velocity += (datalist["potency"] * .25) * direction
						else: #Otherwise, apply force
							target_body.apply_central_impulse(datalist["potency"] * direction)
					"Light":
						pass
		elif target_body.has_method("check_weakness"):
			target_body.check_weakness(datalist)
	
	#Empty the datalist
	datalist = {
		"color": [0, 0, 0],
		"aspect": ["None"],
		"effect": ["None"],
		"potency": 0
	}
	complexity = 0
	material_num = 0
