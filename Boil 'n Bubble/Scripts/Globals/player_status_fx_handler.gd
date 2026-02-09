extends Node3D
class_name StatusManager

@onready var ui_master_node = $"../Pivot/PlayerUI"
@onready var player : Player = $".."

@onready var particle_emitter : PackedScene = load("res://Scenes/Generics/StatusParticles.tscn")

var status_fx = []
#status effect structure:
#{
#	"status": the name of the effect
#	"timer": The timer attached to the effect
#	"repeat": The amount of times the timer repeats
#	"dot": Damage Over Time (procs when timer repeats)
#	"power": The potency of the effect (aka how effective the effect is) 
#}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#The static effect (stays until removed via remove_effect())
func add_static_effect(effect):
	var fx = search_status_by_effect(effect)
	if fx:
		remove_effect(effect)
	match(effect):
		"Bog":
			player.speed_factor -= .9
			status_fx.append({repeat = 0, timer = null, duration = 0, status = effect, dot = 0, power = 0, particle = null})
	ui_master_node.add_status(effect)

func add_effect(effect, repeats, duration, dot, power, timer_def = -1):
	# afflict any stat changes to the player
	match(effect):
		"Wind":
			player.jump_factor += power
		"Shrink":
			player.global_scale(Vector3(.5, .5, .5))
		"Dizzy":
			player.vel_clamp = false
			player.clampable = false
			player.speed_factor += -.8
	# Define Timer
	var timer
	timer = Timer.new()
	timer.wait_time = duration
	timer.autostart = true
	if timer_def > 0:
		timer.time_left = timer_def
	# Bind timeout and DOT (if any) functions to it
	if (dot != 0):
		timer.timeout.connect(damage_over_time.bind(dot))
	timer.timeout.connect(time_out_timer_statusef.bind(timer, effect))
	#Create and define particles for the effect
	var status_particles = particle_emitter.instantiate()
	status_particles.define_status(effect)
	add_child(status_particles)
	#If the effect already exists, remove it before adding the new one.
	remove_effect(effect)
	#Add effect to status list,
	status_fx.append({repeat = repeats, timer = timer, duration = duration, status = effect, dot = dot, power = power, particle = status_particles})
	#Add particle effect
	#var particle = particle_emitter.Instantiate()
	#particle.define_status(effect)
	#timer.add_child(particle)
	#Add and activate timer
	add_child(timer)
	#counter += 1
	#TODO: Maybe use effect timers to give list of effects? what about environmental ones like mud?
	#Add effect to the player's UI
	ui_master_node.add_status(effect)

func remove_effect(effect):
	var status = search_status_by_effect(effect)
	#if the status has a buff/debuff attached to it, remove that.
	if status:
		match(status.status):
				"Wind":
					player.jump_factor += -(status.power)
				"Shrink":
					player.global_scale(Vector3(2, 2, 2))
				"Dizzy":
					player.clampable = true
					player.speed_factor += .8
				"Bog":
					player.speed_factor += .9
		ui_master_node.remove_status(effect)
		if status.timer:
			status.timer.call_deferred("queue_free")
		if (status.particle != null):
			status.particle.queue_free()
		status_fx.erase(status)

func search_status_by_timer(timer : Timer):
	for fx in status_fx:
		if fx.timer == timer:
			return fx
	return null

func search_status_by_effect(effect : String):
	for fx in status_fx:
		if fx.status == effect:
			return fx
	return null

# Time Out function for status effects
func time_out_timer_statusef(id, statusef):
	var fx = search_status_by_timer(id)
	#Decrement the amount of repeat times. If at 0, the effect ends
	fx.repeat -= 1
	if (fx.repeat <= 0):
		print("timeout")
		#Look at the associated effect to see if anything needs to be undone 
		remove_effect(fx.status)

func damage_over_time(damage):
	#Create function in player for damage, and have this function call it.
	player.damage(damage)
	pass

func status_save_data():
	var save_data = []
	for fx in status_fx:
		save_data.append([fx, fx.timer.time_left])
	return save_data
