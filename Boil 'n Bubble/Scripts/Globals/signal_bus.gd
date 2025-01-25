extends Node

#Signal Bus holds onto signals for other scripts,
# which call the signal bus to emit instead of emitting themselves.
# That way, scripts in different scenes can speak to eachother.
signal show_paper(id)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
