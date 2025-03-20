extends Actor

var health = 10
var dead = false

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 2.5

	movement_target_position = Vector3(randf_range(global_position.x - 20.0, global_position.x + 20.0),
		randf_range(global_position.y - 2, global_position.y + 2),
		randf_range(global_position.z - 20.0, global_position.z + 20.0))

	# Make sure to not await during _ready.
	actor_setup.call_deferred(true)
	pass

#Behavior process
func _process(delta):
	pass

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
	global_position = Vector3(load_data["position"][0], load_data["position"][1], load_data["position"][2])
	set_movement_target(Vector3(load_data["target_position"][0], load_data["target_position"][1], load_data["target_position"][2]))
	health = load_data["health"]
	idle = load_data["idle"]
	target_entity = load_data["target_entity"]
	_on_navigation_timer_timeout()
