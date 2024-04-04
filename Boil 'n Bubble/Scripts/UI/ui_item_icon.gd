extends ColorRect

var border
var picture
var datalist
var held = false

# Called when the node enters the scene tree for the first time.
func _ready():
	border = $SelectBorder
	picture = $PictureIcon
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	border.visible = held
	if (datalist == null):
		color = Color(1, 1, 1, 174 / 255.0)
	else:
		color = Color((datalist["color"][0]) / 255.0, datalist["color"][1] / 255.0, datalist["color"][2] / 255.0, 174 / 255.0)
	pass
