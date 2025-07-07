extends Actor

@onready var animation_player : AnimationPlayer = $MeshInstance3D/AnimationPlayer
@onready var animation_tree : AnimationTree = $MeshInstance3D/AnimationTree
@onready var animation_state = animation_tree["parameters/StateMachine/playback"]

@onready var enter_target = $"../EnterTarget"
@onready var exit_target = $"../ExitTarget"

@onready var stay_timer = $StayTimer
@onready var launch_timer = $LaunchTimer

signal left(success, reward)

@onready var aggro_sphere = $AggroSphere

var object_name = "NPC"
var npc_name = "Trader"

var dialogue_track = {
	"Intro": {
		
	}
	,
	"Spec": {
		"Light":
			"I can light up the trail with"
		,
		"Fire":
			"I can trailblaze with"
		,
		"Wind":
			"packs quite a force"
		,
		"Healing":
			"can fix what ails ya"
		,
		"Poison":
			"is silent, but deadly"
	}
	,
	"Reward": {
		
	}
}

var potion_specs = ["Light", "Fire", "Wind", "Healing", "Poison", "None"]

var desired_potion_specs = []

var reward

var succeed = false

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1
	
	#Set target position to the spot the trader will walk to.
	movement_target_position = enter_target.global_position
	
	var first_spec = randi_range(0,4)
	var second_spec = randi_range(0, 5)
	while second_spec == first_spec:
		second_spec = randi_range(0, 5)
	desired_potion_specs = [potion_specs[first_spec], potion_specs[second_spec]]
	idle = false
	
	# Make sure to not await during _ready.
	actor_setup.call_deferred(false)
	pass

func _process(delta):
	if idle:
		var bodies = aggro_sphere.get_overlapping_bodies()
		for body in bodies:
			if body is Player:
				look_at(Vector3(body.global_position.x, self.global_position.y, body.global_position.z))

func interaction(caller):
	var item = PlayerInventory.inventory[PlayerInventory.holding_index]
	animation_state.travel("Armature|Dialouge")
	#Checks if the potion exists and has the right components
	if item != null && item["name"] == "potion":
		for spec in desired_potion_specs:
			if spec != "None":
				if (item != null) && (item["aspect"].has(spec) || item["effect"].has(spec)):
					pass
				else:
					print(desired_potion_specs)
					prepare_dialogue("info")
					#Animation travel and things changing will wait for user to close the dialogue box
					while true:
						var signal_name = await SignalBus.dialogue_box_closed
						if signal_name  == npc_name:
							break
					print("Broken loop")
					animation_state.travel("Armature|Idle")
					return
			else:
				pass
	else:
		print(desired_potion_specs)
		prepare_dialogue("info")
		#Animation travel and things changing will wait for user to close the dialogue box
		while true:
			var signal_name = await SignalBus.dialogue_box_closed
			if signal_name == npc_name:
				break
		print("Broken loop")
		animation_state.travel("Armature|Idle")
		return
	#If the function gets to this point, then the input must have been correct.
	print("success")
	succeed = true
	prepare_dialogue("success")
	#Animation travel and things changing will wait for user to close the dialogue box
	while true:
		var signal_name = await SignalBus.dialogue_box_closed
		if signal_name  == npc_name:
			break
	print("Broken loop")
	PlayerInventory.inventory[PlayerInventory.holding_index] = null
	match(reward):
		"Ingredient":
			var file = FileAccess.open("res://Assets/Data/MaterialDataList.json", FileAccess.READ)
			var json_data = JSON.parse_string(file.get_as_text())
			if json_data:
				print("dataset " + str(json_data["wine"]) + " loaded")
				PlayerInventory.inventory[PlayerInventory.holding_index] = json_data["wine"]
			else:
				print("dataset " + str("wine") + " failed to load")
		"Farm":
			SignalBus.enable("Farm")
		"Storage":
			SignalBus.enable("Storage")
	leave()

func _on_aggro_sphere_body_entered(body):
	if body is Player && idle:
		print("player detected")
		look_at(Vector3(body.global_position.x, self.global_position.y, body.global_position.z))
	pass # Replace with function body.

func _on_navigation_target_reached():
	if movement_target_position == enter_target.global_position:
		print("destination reached")
		idle = true
		animation_state.travel("Armature|Idle")
		stay_timer.start()
	elif movement_target_position == exit_target.global_position:
		left.emit(succeed, reward)
		self.queue_free()

func leave():
	idle = false
	movement_target_position = exit_target.global_position
	animation_state.travel("Armature|WalkCycle")
	set_movement_target(movement_target_position)

func prepare_dialogue(case):
	var dialogue
	match(case):
		"info":
			dialogue = "Alchemist! I need a potion that "
			if desired_potion_specs[1] == "None":
				dialogue += dialogue_track["Spec"][desired_potion_specs[0]] + "."
			else:
				dialogue += dialogue_track["Spec"][desired_potion_specs[0]] + " and " + dialogue_track["Spec"][desired_potion_specs[1]] + "."
		"success":
			dialogue = "Thank you! Now in exchange for that... "
			match(reward):
				"Ingredient":
					dialogue += "I brought some Alkovian Wine with me, do with it as you wish."
				"Farm":
					dialogue += "Aha! A a little farming set for you to put up! Should ease the hassle of collecting certain ingredients."
				"Storage":
					dialogue += "I noticed you only have that little backpack for storage, so have this chest for your excess supplies."
	
	SignalBus.open_dialogue_box.emit(npc_name, dialogue)
