extends Node3D

@onready var grace_timer = $Timer
var lifespan_duration
var grace = true
@onready var true_scale = scale
var scale_factor = 1.0

func _ready():
	grace_timer.start(lifespan_duration)

func _process(delta):
	if !grace:
		scale_factor -= (delta * 0.5)
		global_scale(true_scale * scale_factor)
		if scale_factor <= 0.01:
			self.queue_free()

func _on_grace_timer_timeout():
	grace = false
