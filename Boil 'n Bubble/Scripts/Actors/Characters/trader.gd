extends Actor

@onready var enter_target = $"../EnterTarget"
@onready var exit_target = $"../ExitTarget"

var object_name = "NPC"

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5
	
	#Set target position to the spot the trader will walk to.
	movement_target_position = enter_target.global_position

	# Make sure to not await during _ready.
	actor_setup.call_deferred(false)
	pass

func interaction():
	pass

func _on_aggro_sphere_body_entered(body):
	if body is Player && idle:
		print("player detected")
		look_at(Vector3(body.global_position.x, self.global_position.y, body.global_position.z))
	pass # Replace with function body.
