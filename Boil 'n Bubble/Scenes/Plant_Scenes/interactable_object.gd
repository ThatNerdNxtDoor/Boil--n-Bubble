extends StaticBody3D

var interaction_id

# Called when the node enters the scene tree for the first time.
func _ready():
	interaction_id = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Interaction function for raycasting
func interaction():
	print("Interaction: " + str(interaction_id))
