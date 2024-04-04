extends StaticBody3D

@export var weakness : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Function for checking if the potion destroys the debris
func check_weakness(datalist):
	for aspect in datalist["aspect"]:
		print(aspect)
		print(aspect is String)
		print(weakness.find(aspect))
		if weakness.find(aspect) != -1:
			print("Body Destroyed")
			self.queue_free()
			return
	for effect in datalist["effect"]:
		print(effect)
		if weakness.find(effect) != -1:
			print("Body Destroyed")
			self.queue_free()
			return
