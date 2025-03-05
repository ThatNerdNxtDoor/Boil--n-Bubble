extends Area3D

@onready var lifespan_timer = $Timer
var lifespan_duration

func _ready():
	lifespan_timer.start(lifespan_duration)

func _process(delta):
	pass
