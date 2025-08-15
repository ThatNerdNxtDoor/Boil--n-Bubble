extends StaticBody3D
class_name StaticInteractable

@export var object_name : String
@export var interact_text : String = "Interact"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Interaction function for raycasting
func interaction(caller):
	print("Interaction")

func get_interact_text():
	return interact_text
