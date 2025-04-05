extends Node

#This save system uses a JSON system, so a helper class must be instantiated
var json = JSON.new()
#The const filepath used for making new files
const FILE_PATH = "res://Assets/Data/SaveData/"
#Stores what slot the save manager is currently managing
var current_slot : String

func save_game():
	var date_time = Time.get_datetime_dict_from_system()
	#If this is a new save, then it is given a name based on when it was made
	if current_slot == "newgame":
		var date = "%02d-%02d-%04d" % [date_time.day, date_time.month, date_time.year]
		var time = "%02d-%02d" % [date_time.hour, date_time.minute]
		current_slot = FILE_PATH + "BnB_" + date + "_" + time + ".json"
	var save_file = FileAccess.open(current_slot, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persistent")
	
	save_file.store_line("{")
	for node in save_nodes:
		# Check the node has a save function.
		print(node)
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, saving skipped" % node.name)
			continue
		# Call the node's save function.
		var node_data = node.call("save")
		#print(node_data)
		# JSON provides a static method to serialized JSON string.
		var json_string = json.stringify(node_data)
		#print(json_string)
		# Store the save dictionary as a new line in the save file.
		save_file.store_line("\"" + str(node.name) + "\": " + json_string + ",")
	#Store Metadata, including version and date saved
	var metadata = {
		"version": ProjectSettings.get_setting("application/config/version"),
		"date saved": ("%02d-%02d-%04d" % [date_time.day, date_time.month, date_time.year]) +
			" - " + ("%02d:%02d" % [date_time.hour, date_time.minute])
	}
	save_file.store_line("\"metadata\": " + json.stringify(metadata))
	save_file.store_line("}")
	
	save_file.close()
	#Return to signal that the function is complete to the save/quit button
	return

func load_game():
	if current_slot == "newgame":
		pass #No point in loading in data that isn't there
	else:
		print("================================================================")
		var load_file = FileAccess.open(current_slot, FileAccess.READ)
		var input = load_file.get_as_text()
		print("input: " + input)
		print(json.parse(input))
		var load_data : Dictionary = json.parse_string(input)
		print(load_data)
		load_file.close()
		
		#Nodes are saved in the same order, so data should be retrieved in that order
		var load_nodes = get_tree().get_nodes_in_group("Persistent")
		for node in load_nodes:
			#var node = load_nodes[i]
			
			# Check the node has a save function.
			if !node.has_method("load_save"):
				print("persistent node '%s' is missing a save() function, loading skipped" % node.name)
				continue
			
			#print(node)
			var node_data = load_data.get(node.name)
			node.load_save(node_data)

func delete_save():
	DirAccess.remove_absolute(current_slot)

func get_file_metadata(file):
	var load_file = FileAccess.open(file, FileAccess.READ)
	var input = load_file.get_as_text()
	print("input: " + input)
	print(json.parse(input))
	var load_data : Dictionary = json.parse_string(input)
	print(load_data)
	load_file.close()
	
	return load_data["metadata"]
