extends ActiveInteractable
class_name ActivePotion

var pot_datalist
#datalist = {
	#"name": always "potion", used to differentiate it from ingredients
	#"color": color, average of all ingredients
	#"aspect": Primary ingredients
	#"effect": Secondary ingredients
	#Maybe have value for support effects (ie increased duration, lingering, etc)
	#"potency": Power of the potion
#}

var blast_radius
var potion_light
var potion_bottle
var audio_player
var break_particles
var break_audio = preload("res://Assets/SoundEffects/LargeGlassMirrorSmash1.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	blast_radius = $CollisionBox
	potion_light = $PotionLight
	potion_bottle = $"Potion Bottle"
	audio_player = $AudioStreamPlayer3D
	break_particles = $BreakParticles
	print(break_particles)
	if (pot_datalist["effect"].find("Light") != -1):
		potion_light.visible = true
		potion_light.light_color = Color8(int(pot_datalist["color"][0]), int(pot_datalist["color"][1]), int(pot_datalist["color"][2]))
		potion_light.omni_range = 2 + ((PlayerInventory.inventory[PlayerInventory.holding_index])["potency"] * .15)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interaction():
	print("Interaction Potion")

# When Potions Collides
func _on_body_entered(body):
	if body is Player:
		pass
	else:
		#Check for immediate effects
		
		#Apply Effects/Aspects to Player (match case?)
		#Get bodies in Area3D
		var bodies = blast_radius.get_overlapping_bodies()
		for target_body in bodies:
			print(target_body)
			print(target_body.has_method("check_weakness"))
			if (target_body is RigidBody3D) or (target_body is CharacterBody3D):
				for aspect in pot_datalist["aspect"]:
					print(aspect)
					match(aspect):
						"Fire":
							if target_body.has_method("apply_effect"):
								target_body.apply_effect(aspect, 5, 2, 3 + (pot_datalist["potency"] * .1))
						"Healing":
							if (target_body is CharacterBody3D) and ("curr_health" in target_body):
								target_body.curr_health = clamp(target_body.curr_health + (pot_datalist["potency"] * .25), 1, target_body.max_health)
						"Poison":
							if target_body.has_method("apply_effect"):
								target_body.apply_effect(aspect, 5, 2, 3 + (pot_datalist["potency"] * .15))
				for effect in pot_datalist["effect"]:
					print(effect)
					match(effect):
						"Wind":
							var direction = blast_radius.global_position.direction_to(target_body.global_position + Vector3(0, .25, 0))
							print(direction)
							#For player, apply it to the velocity and temporarily deactivate the velocity limiter
							if target_body is CharacterBody3D:
								target_body.vel_clamp = false
								target_body.velocity += (pot_datalist["potency"] * .75) * direction
							else: #Otherwise, apply force
								target_body.apply_central_impulse((pot_datalist["potency"] * .75) * direction)
						"Light":
							pass
			elif target_body.has_method("check_weakness"):
				target_body.check_weakness(pot_datalist)
		#Hide and remove hitbox to play sound effect without reactivating
		$PhysicsCollisionShape.queue_free()
		potion_bottle.hide()
		potion_light.hide()
		break_particles.mesh.material.set_albedo(Color(pot_datalist["color"][0], pot_datalist["color"][1], pot_datalist["color"][2], 1))
		print(break_particles.mesh.material.get_albedo())
		break_particles.emitting = true
		audio_player.play()

#Noise is played, and the object is officially destroyed
func _on_audio_stream_player_3d_finished():
	self.queue_free()
