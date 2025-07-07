extends WorldEnvironment

@onready var sunlight : DirectionalLight3D = $"../SunLight"
@onready var music_player = $MusicPlayer
var time
var current_environment = "normal"

var environment_dictionary = {"normal": [preload("res://Assets/Shaders/Area1Environment.tres"), null],
					"bog": [preload("res://Assets/Shaders/Area2Environment.tres"), null]}

# Called when the node enters the scene tree for the first time.
func _ready():
	time = -116.5
	
	SignalBus.change_environment.connect(_change_environment)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = time + (delta * .5)
	sunlight.set_rotation_degrees(Vector3(time, 0, 0))
	var time_in_day #Saving for later (time-keeping system?)
	if time >= 0:
		sunlight.light_energy = 0
	else:
		sunlight.light_energy = 1

func _change_environment(key : String):
	environment = environment_dictionary[key][0]
	#music_player.stream = environment_dictionary[key][1]
	current_environment = key

func save():
	var save_dictionary = {
		"time": time,
		"current_environment": current_environment
	}
	return save_dictionary

func load_save(load_data):
	time = load_data["time"]
	_change_environment(load_data["current_environment"])
