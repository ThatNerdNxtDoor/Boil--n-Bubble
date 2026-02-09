extends CPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#Define the sprite of the particles based on the status effect
func define_status(effect):
	match(effect):
		"Fire":
			mesh.material.albedo_texture = preload("res://Assets/Sprites/StatusParticles/StatusParticleSprite_Fire.png")
			pass
		"Poison":
			mesh.material.albedo_texture = preload("res://Assets/Sprites/StatusParticles/StatusParticleSprite_Poison.png")
			pass
		"Dizzy":
			mesh.material.albedo_texture = preload("res://Assets/Sprites/StatusParticles/StatusParticleSprite_Dizzy.png")
			pass
		_: #No particles for effect, destroy this object
			self.visible = false
	pass
