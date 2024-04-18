extends StaticBody3D

@export var weakness : Array

var audio_player

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_player = get_node_or_null("AudioStreamPlayer3D")
	print(audio_player)
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
			if (get_node("..") is MeshInstance3D):
				get_node("..").queue_free()
			else:
				audio_player.play()
				self.queue_free()
			return
	for effect in datalist["effect"]:
		print(effect)
		if weakness.find(effect) != -1:
			print("Body Destroyed")
			if (get_node("..") is MeshInstance3D):
				get_node("..").queue_free()
			else:
				audio_player.play()
				self.queue_free()
			return
