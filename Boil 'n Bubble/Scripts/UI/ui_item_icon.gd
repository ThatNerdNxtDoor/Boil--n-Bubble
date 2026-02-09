extends ColorRect
class_name UIItemIcon

var border
var picture
var datalist
var held = false
@export var purpose : String
##The source of the datalist
var source
##The id of the spot in a storage array the icon is representing
@export var id : int

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
		if (held):
			# Create dummy stylebox to replace border color
			var border_change : StyleBox = border.get_theme_stylebox("panel").duplicate()
			border_change.set("border_color", color.inverted())
			border.add_theme_stylebox_override("panel", border_change)
	elif purpose == "notebook":
		pass
	if (datalist == null):
		color = Color(1, 1, 1, 174 / 255.0)
		picture.texture = null
	else:
		color = Color((datalist["color"][0]) / 255.0, datalist["color"][1] / 255.0, datalist["color"][2] / 255.0, 174 / 255.0)
		if (datalist["icon"] != null):
			picture.texture = load(datalist["icon"])

func _get_drag_data(_pos):
	# Use another icon as drag preview.
	#var drag_shadow = copy.instantiate()
	#drag_shadow.datalist = datalist
	#drag_shadow.size = Vector2(50, 50)
	#set_drag_preview(drag_shadow)
	# Return datalist as drag data.
	print("pick up datalist")
	if (datalist == null):
		return {"icon": "res://Assets/Sprites/EmptyUISlot.png", "color": [255, 255, 255]}
	else:
		return [datalist, self]

func _can_drop_data(_pos, data):
	#if data is not a dictionary, and the origin and destination types allow it
	return (data is not Dictionary) && (purpose == "notebook" || purpose == "chest" || purpose == "farm" || purpose == "hotbar") && data[1].purpose != "notebook"

func _drop_data(_pos, data):
	#data[0] is the datalist, data[1] is the originally dragged object.
	print("drop datalist")
	if(datalist == {"icon": "res://Assets/Sprites/EmptyUISlot.png", "color": [255, 255, 255]}):
		datalist = null
	elif purpose != "farm": #data change can be handled at specific points
		datalist = data[0]
	#Determine what specifically needs to be done based off of the purpose of the icon
	if (purpose == "notebook"):
		notebook_icon_changed.emit()
	elif purpose == "chest":
		source.storage[id] = datalist
		if data[1].purpose == "hotbar":
			PlayerInventory.inventory[data[1].id] = null
			print(PlayerInventory.inventory[data[1].id])
			data[1].datalist = null
		elif data[1].purpose == "chest":
			data[1].datalist = null
			data[1].source.storage[data[1].id] = null
	elif purpose == "farm":
		if data[0]["type"] == "plant":
			datalist = data[0]
			source.storage[id] = datalist
			source.start_growing()
			if data[1].purpose == "hotbar":
				PlayerInventory.inventory[data[1].id] = null
				print(PlayerInventory.inventory[data[1].id])
			data[1].datalist = null
		else:
			pass
	elif purpose == "hotbar":
		PlayerInventory.inventory[id] = data[0]
		if data[1].purpose == "farm":
			data[1].datalist = null
			data[1].source.storage[data[1].id] = null
			data[1].source.stop_growing()
		elif data[1].purpose == "chest":
			data[1].datalist = null
			data[1].source.storage[data[1].id] = null
		elif data[1].purpose == "hotbar":
			if data[1] == self:
				pass
			else:
				data[1].datalist = null
				PlayerInventory.inventory[data[1].id] = null
