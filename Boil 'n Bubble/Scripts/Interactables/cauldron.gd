extends StaticInteractable

var datalist
var complexity
var complexity_limit
var material_num

# Called when the node enters the scene tree for the first time.
func _ready():
	datalist = {
		"color": [0, 0, 0],
		"aspect": ["None"],
		"effect": ["None"],
		"potency": 0
	}
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
		if datalist["aspect"] == ["None"]:
			datalist["aspect"] = mat_dictionary["aspect"]
		elif datalist["aspect"].find(mat_dictionary["aspect"]) != -1:
			datalist["aspect"].append(mat_dictionary["aspect"])
		# Add effect, replace if it is empty, don't add if effect exists
		if datalist["effect"] == ["None"]:
			datalist["effect"] = mat_dictionary["effect"]
		elif datalist["effect"].find(mat_dictionary["effect"]) != -1:
			datalist["effect"].append(mat_dictionary["effect"])
		# Add color
		datalist["color"] = datalist["color"] + mat_dictionary["color"]
		# Add Potency
		datalist["potency"] = datalist["potency"] + mat_dictionary["potency"]
		# Add complexity, then check for overload
		complexity =+ mat_dictionary["complexity"]
		material_num =+ 1
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