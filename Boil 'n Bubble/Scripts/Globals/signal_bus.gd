extends Node

#Signal Bus holds onto signals for other scripts,
# which call the signal bus to emit instead of emitting themselves.
# That way, scripts in different scenes can speak to eachother.

##Signal for opening viewable pieces of paper. Gives id of paper
signal show_paper(id)

##Signal for opening a storage window. Gives the object and the type of storage
signal open_storage_window(object, type)

signal change_environment(key)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
