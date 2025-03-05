extends StaticInteractable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interaction(caller):
	SignalBus.show_paper.emit(get_parent().get_meta("page_id"))
