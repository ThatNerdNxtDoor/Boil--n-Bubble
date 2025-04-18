extends StaticInteractable

var active = true
@onready var collision = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interaction(caller):
	SignalBus.enable("Everbell")
	active = false
	visible = false
	collision.disabled = true
	pass

func save():
	var save_dictionary = {
		"active": active
	}
	return save_dictionary

func load_save(load_data):
	active = load_data["active"]
	visible = load_data["active"]
	collision.disabled = !load_data["active"]
