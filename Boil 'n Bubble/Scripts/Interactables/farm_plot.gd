extends StaticInteractable

@onready var growth_timer = $GrowingTimer

var storage = [null]
var growing
var plant_ready
var plant_model
var plant_vector : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	plant_ready = false
	growing = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if plant_model != null:
		plant_model.scale = plant_vector * ((240.0 - float(growth_timer.time_left)) / 240.0)

func interaction(caller):
	#Harvest
	if plant_ready:
		var index = PlayerInventory.inventory.find(null)
		if (index != -1):
			PlayerInventory.inventory[index] = storage[0]
			print("Pick-Up Successful")
			growth_timer.start()
		plant_ready = false
	#Open Farm "storage" window
	else:
		SignalBus.open_storage_window.emit(self, "farm")

func start_growing():
	growing = true
	plant_ready = false
	match(storage[0]["name"]):
		"lampshade":
			plant_model = $Plant/Lampshade
			plant_vector = Vector3(0.389, 0.389, 0.389)
		"calientus root":
			plant_model = $Plant/CalientusRoot
			plant_vector = Vector3(0.2, 0.2, 0.2)
		"mixture mint":
			plant_model = $Plant/MixtureMint
			plant_vector = Vector3(0.285, 0.285, 0.285)
	plant_model.visible = true
	growth_timer.start()

func stop_growing():
	growing = false
	plant_ready = false
	plant_model.visible = false
	plant_model = null
	plant_vector = Vector3(0, 0, 0)
	growth_timer.stop()

func _on_growing_timer_timeout():
	plant_ready = true
	pass # Replace with function body.
