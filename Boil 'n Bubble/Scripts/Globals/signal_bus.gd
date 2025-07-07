extends Node

#Signal Bus holds onto signals for other scripts,
# which call the signal bus to emit instead of emitting themselves.
# That way, scripts in different scenes can speak to eachother.

##Signal for opening viewable pieces of paper. Gives id of paper
signal show_paper(id)

##Signal for opening a storage window. Gives the object and the type of storage
signal open_storage_window(object, type)

##Signal for opening the dialogue window
signal open_dialogue_box(ncp_name, dialogue_track)

##Signal telling the specific npc that the dialogue window was closed
signal dialogue_box_closed(ncp_name)

##Signal for changing the sky and music
signal change_environment(key)

##Signals for enabling upgrades
signal enable_farm
signal enable_storage
signal unlock_collectible(collectible)

##Signal for trader entering scene
signal trader_entered

func enable(type):
	match(type):
		"Farm":
			enable_farm.emit()
		"Storage":
			enable_storage.emit()
		"Everbell":
			unlock_collectible.emit("Everbell")
