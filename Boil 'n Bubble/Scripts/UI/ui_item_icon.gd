extends ColorRect

var border
var picture
var datalist
var held = false
@export var purpose : String

signal notebook_icon_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	border = $SelectBorder
	border.visible = (purpose != "hotbar")
	picture = $PictureIcon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if purpose == "hotbar":
		border.visible = held
	elif purpose == "notebook":
		pass
	if (datalist == null):
		color = Color(1, 1, 1, 174 / 255.0)
	else:
		color = Color((datalist["color"][0]) / 255.0, datalist["color"][1] / 255.0, datalist["color"][2] / 255.0, 174 / 255.0)

func _get_drag_data(_pos):
	# Use another icon as drag preview.
	#var drag_shadow = copy.instantiate()
	#drag_shadow.datalist = datalist
	#drag_shadow.size = Vector2(50, 50)
	#set_drag_preview(drag_shadow)
	# Return datalist as drag data.
	print("pick up datalist")
	return datalist

func _can_drop_data(_pos, data):
	return purpose == "notebook"

func _drop_data(_pos, data):
	print("drop datalist")
	datalist = data
	if (purpose == "notebook"):
		notebook_icon_changed.emit()
