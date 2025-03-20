extends StaticInteractable

@export var activatee : StaticBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interaction(caller):
	activatee.visible = true
	activatee.find_child("CollisionShape3D").disabled = false
	activatee.find_child("AudioStreamPlayer3D").play()
	self.visible = false

func save():
	var save_dictionary = {
		"activated": activatee.visible
	}
	return save_dictionary

func load_save(load_data):
	activatee.visible = load_data["activated"]
	self.visible = !load_data["activated"]
