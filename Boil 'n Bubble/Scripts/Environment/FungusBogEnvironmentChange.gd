extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	#When Player walks in, change environment to bog environment
	if body.name == "Player":
		print("Entering Fungus Bog")
		SignalBus.change_environment.emit("bog")
	pass # Replace with function body.

func _on_body_exited(body):
	#When Player walks out, change environment to frontier environment
	if body.name == "Player":
		print("Exiting Fungus Bog")
		SignalBus.change_environment.emit("normal")
	pass # Replace with function body.
