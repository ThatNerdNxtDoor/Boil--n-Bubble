extends Area3D

@onready var lifespan_timer = $Timer
@onready var aspect_timer = $AspectTimer
@onready var particles = $UnstableParticles
var datalist

func _ready():
	lifespan_timer.start(datalist["potency"])
	aspect_timer.start()
	particles.color = Color(datalist["color"][0], datalist["color"][1], datalist["color"][2])

func _process(delta):
	var bodies = self.get_overlapping_bodies()
	for target_body in bodies:
		if datalist["effect"].find("Wind") != -1:
				var direction = self.global_position.direction_to(target_body.global_position + Vector3(0, .25, 0))
				print(direction)
				#For player, apply it to the velocity and temporarily deactivate the velocity limiter
				if target_body is CharacterBody3D:
					target_body.vel_clamp = false
					target_body.velocity += (datalist["potency"] * .3) * direction
				elif target_body is RigidBody3D: #Otherwise, apply force
					target_body.apply_central_impulse((datalist["potency"] * .1) * direction)
	pass

func _on_timer_timeout():
	self.queue_free()
	pass # Replace with function body.

func _on_aspect_timer_timeout():
	print("timeout")
	var bodies = self.get_overlapping_bodies()
	for target_body in bodies:
		print(target_body)
		if (target_body is RigidBody3D) or (target_body is CharacterBody3D):
			for aspect in datalist["aspect"]:
				match(aspect):
					"Fire":
						if target_body.has_method("apply_effect"):
							target_body.apply_effect(aspect, 5, 2, (datalist["potency"] * .01), 0)
					"Healing":
						if (target_body is CharacterBody3D) and ("curr_health" in target_body):
							target_body.curr_health = clamp(target_body.curr_health + (datalist["potency"] * .25), 1, target_body.max_health)
					"Poison":
						if target_body.has_method("apply_effect"):
							target_body.apply_effect(aspect, 5, 2, (datalist["potency"] * .01), 0)
		if target_body.has_method("check_weakness"):
				target_body.check_weakness(datalist)
	pass # Replace with function body.
