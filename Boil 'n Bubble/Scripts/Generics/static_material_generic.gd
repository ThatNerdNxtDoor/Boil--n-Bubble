extends StaticInteractable
class_name StaticMaterial

@export var mat_name : String
var mat_datalist

# Called when the node enters the scene tree for the first time.
func _ready():
	mat_datalist = get_dataset()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_dataset():
	var file = FileAccess.open("res://Assets/Data/MaterialDataList.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	if json_data:
		print("dataset " + str(json_data[mat_name]) + " loaded")
		return json_data[mat_name]
	else:
		print("dataset " + str(mat_name) + " failed to load")

func interaction():
	print("Interaction Material")
	var index = PlayerInventory.inventory.find(null)
	if (index != -1):
		PlayerInventory.inventory[index] = mat_datalist
		print("Pick-Up Successful")
		self.queue_free()
	else:
		print('inventory full')
