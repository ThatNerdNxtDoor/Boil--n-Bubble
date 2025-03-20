extends StaticInteractable

var storage = [null, null, null, null, null]

signal open_storage_window(storage : Array)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interaction(caller):
	#open window with storage UIIcons
	SignalBus.open_storage_window.emit(self, "chest")
	pass

func save():
	var save_dictionary = {
		"storage" = storage
	}
	return save_dictionary

func load_save(load_data):
	storage = load_data["storage"]
