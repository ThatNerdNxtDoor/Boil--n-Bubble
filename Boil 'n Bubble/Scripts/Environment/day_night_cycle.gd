extends WorldEnvironment

var sunlight : DirectionalLight3D
var time

var environment_dictionary = {"normal": preload("res://Assets/Shaders/Area1Environment.tres"),
					"bog": preload("res://Assets/Shaders/Area2Environment.tres")}

# Called when the node enters the scene tree for the first time.
func _ready():
	sunlight = $"../SunLight"
	time = -116.5
	
	SignalBus.change_environment.connect(_change_environment)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = time + (delta * 1.25)
	sunlight.set_rotation_degrees(Vector3(time, 0, 0))
	var time_in_day #Saving for later (time-keeping system?)
	if time >= 0:
		sunlight.light_energy = 0
	else:
		sunlight.light_energy = 1

func _change_environment(key : String):
	environment = environment_dictionary[key]
