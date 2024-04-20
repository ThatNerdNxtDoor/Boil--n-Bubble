extends StaticBody3D

@export var weakness : Array

var audio_player
var collision_box

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_player = get_node_or_null("AudioStreamPlayer3D")
	collision_box = get_node_or_null("CollisionShape3D")
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
			#Removes collision and hides mesh to allow music to finish
			collision_box.queue_free()
			audio_player.finished.connect(_sound_effect_finished)
			audio_player.play()
			if (get_node("..") is MeshInstance3D):
				get_node("..").hide()
			else:
				self.hide()
			return
	for effect in datalist["effect"]:
		print(effect)
		if weakness.find(effect) != -1:
			print("Body Destroyed")
			#Removes collision and hides mesh to allow music to finish
			collision_box.queue_free()
			audio_player.finished.connect(_sound_effect_finished)
			audio_player.pitch_scale = 1 + randf_range(-0.5, 0.5)
			audio_player.play()
			if (get_node("..") is MeshInstance3D):
				get_node("..").hide()
			else:
				self.hide()
			return

func _sound_effect_finished():
	if (get_node("..") is MeshInstance3D):
		get_node("..").queue_free()
	else:
		self.queue_free()
