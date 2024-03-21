extends StaticInteractable

var datalist
var complexity
var complexity_limit
var material_num

var aspects
var effects

# Called when the node enters the scene tree for the first time.
func _ready():
	datalist = {
		"color": [0, 0, 0],
		"aspect": ["None"],
		"effect": ["None"],
		"potency": 0
	}
	aspects = ["None"]
	effects = ["None"]
	
	complexity = 0
	complexity_limit = 6
	
	material_num = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	object_name = "cauldron"
	pass

# Interaction function for raycasting
func interaction():
	#Potions and empty iventories can't be added
	if PlayerInventory.inventory[PlayerInventory.holding_index] == null or (PlayerInventory.inventory[PlayerInventory.holding_index])["name"] == "potion":
		print("Invalid Component")
		pass
	else:
		# Remove material from inventory
		var mat_dictionary = PlayerInventory.inventory[PlayerInventory.holding_index]
		PlayerInventory.inventory[PlayerInventory.holding_index] = null
		# Add aspect, replace if it is empty, don't add if aspect exists
		if datalist["aspect"].find("None") != -1:
			datalist["aspect"] = mat_dictionary["aspect"]
		else:
			for aspect in mat_dictionary["aspect"]:
				if datalist["aspect"].find(aspect) == -1 and  aspect != "None":
					datalist["aspect"].append(aspect)
		print(datalist["aspect"])
		# Add effect, replace if it is empty, don't add if effect exists
		if datalist["effect"].find("None") != -1:
			datalist["effect"] = mat_dictionary["effect"]
		else:
			for effect in mat_dictionary["effect"]:
				if datalist["effect"].find(effect) == -1 and effect != "None":
					datalist["effect"].append(effect)
		print(datalist["effect"])
		# Add color
		(datalist["color"])[0] = (datalist["color"])[0] + (mat_dictionary["color"])[0]
		(datalist["color"])[1] = (datalist["color"])[1] + (mat_dictionary["color"])[1]
		(datalist["color"])[2] = (datalist["color"])[2] + (mat_dictionary["color"])[2]
		# Add Potency
		datalist["potency"] = datalist["potency"] + mat_dictionary["potency"]
		# Add complexity, then check for overload
		complexity =+ mat_dictionary["complexity"]
		material_num = material_num + 1
		if complexity > complexity_limit:
			print("warning, exceeding complexity limit")
		print("Datalist " + str(mat_dictionary) + " added")

# Signal Function to start brewing
func _on_nozzle_start_brewing():
	if material_num != 0:
		var potion = {
			"name": "potion",
			"color": [(datalist["color"])[0] / material_num,
					  (datalist["color"])[1] / material_num,
					  (datalist["color"])[2] / material_num],
			"aspect": datalist["aspect"],
			"effect": datalist["effect"],
			"potency": datalist["potency"]
		}
		var index = PlayerInventory.inventory.find(null)
		if (index != -1):
			PlayerInventory.inventory[index] = potion
			datalist = {
				"color": [0, 0, 0],
				"aspect": ["None"],
				"effect": ["None"],
				"potency": 0
			}
			complexity = 0
			
			material_num = 0
			print("Pick-Up Successful")
		else:
			print('inventory full')
	else:
		print("No contents in cauldron")
