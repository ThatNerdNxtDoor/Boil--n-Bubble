extends StaticInteractable

@export var function : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interaction(caller):
	SignalBus.activate_distiller.emit(function, caller)
