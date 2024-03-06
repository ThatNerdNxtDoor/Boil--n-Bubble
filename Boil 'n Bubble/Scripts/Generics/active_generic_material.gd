extends ActiveInteractable
class_name ActiveMaterial

var mat_name
var mat_datalist
# DataList { 
#   name (or some other way to identify it),
#   color (rgb value that effects the color of the mixture)m
#   aspect (element, usually for primary ingredients),
#   effect (any special transmission effects, usually for secondary ingredients),
#   potency (how effective the ingredient is),
#   complexity (how much complexity the ingredient adds to the mixture
# }
#
# Called when the node enters the scene tree for the first time.
func _ready():
	mat_name = "generic"
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
