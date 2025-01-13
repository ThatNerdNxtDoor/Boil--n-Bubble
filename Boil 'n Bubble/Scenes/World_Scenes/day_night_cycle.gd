extends WorldEnvironment

var sunlight : DirectionalLight3D
var time

# Called when the node enters the scene tree for the first time.
func _ready():
	sunlight = $"../SunLight"
	time = -116.5
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = time + (delta / 12)
	sunlight.set_rotation_degrees(Vector3(time, 0, 0))
