extends StaticInteractable

var storage = [null, null, null, null, null]

signal open_storage_window(storage : Array)

@onready var hitbox = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.enable_storage.connect(enable)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interaction(caller):
	#open window with storage UIIcons
	SignalBus.open_storage_window.emit(self, "chest")
	pass

func enable():
	self.visible = true
	hitbox.disabled = false

func save():
	var save_dictionary = {
		"storage" = storage,
		"enabled" = self.visible
	}
	return save_dictionary

func load_save(load_data):
	storage = load_data["storage"]
	if load_data["enabled"]:
		enable()
