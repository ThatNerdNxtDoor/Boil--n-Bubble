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

# Called when the node enters the scene tree for the first time.
func _ready():
	blast_radius = $CollisionBox
	pass # Replace with function body.

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
			print(body)
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
							var direction = blast_radius.global_position.direction_to(target_body.global_position)
							print(direction)
							#For player, apply it to the velocity to deactivating
							if target_body is CharacterBody3D:
								target_body.vel_clamp = false
								target_body.velocity += (pot_datalist["potency"]) * direction
							else: #Otherwise, apply force
								target_body.apply_central_impulse(pot_datalist["potency"] * direction)
						"Light":
							pass
		self.queue_free()
