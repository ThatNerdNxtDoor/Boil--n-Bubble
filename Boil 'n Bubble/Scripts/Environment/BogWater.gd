extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body.get_class() == "CharacterBody3D":
		body.speed_factor = body.speed_factor * .1
		body.jump_factor = body.jump_factor * .1
	pass # Replace with function body.

func _on_body_exited(body):
	if body.get_class() == "CharacterBody3D":
		body.speed_factor = body.speed_factor / .1
		body.jump_factor = body.jump_factor / .1
		if body.jump_factor > 1:
			body.jump_factor = 1
		if body.speed_factor > 1:
			body.speed_factor = 1
	pass # Replace with function body.
