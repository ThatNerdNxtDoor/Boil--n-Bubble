extends CanvasLayer

@export var ui_icon_packed : PackedScene

@onready var storage_windows = $StorageWindow
var open_window
var icon_container

var inventory_slot

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_slot = [$Hotbar/ItemIcon, $Hotbar/ItemIcon2, $Hotbar/ItemIcon3, $Hotbar/ItemIcon4, $Hotbar/ItemIcon5, $Hotbar/ItemIcon6, $Hotbar/ItemIcon7, $Hotbar/ItemIcon8]
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(8):
		(inventory_slot[i]).held = false
		(inventory_slot[i]).datalist = PlayerInventory.inventory[i]
	(inventory_slot[PlayerInventory.holding_index]).held = true

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/World_Scenes/MainGame.tscn")

func display_storage_window(window_source, type):
	match(type):
		"chest":
			open_window = storage_windows.get_node("ChestWindow")
			pass
		"farm":
			open_window = storage_windows.get_node("FarmWindow")
			pass
	open_window.visible = true
	icon_container = open_window.get_child(0)
	var icon_id = 0
	for datalist in window_source.storage:
		var new_icon = ui_icon_packed.instantiate()
		new_icon.datalist = datalist
		new_icon.purpose = type
		new_icon.source = window_source
		new_icon.id = icon_id
		icon_id += 1
		icon_container.add_child(new_icon)

func close_storage_window():
	for icon in icon_container.get_children():
		icon.queue_free()
	open_window.visible = false
	open_window = null
	icon_container = null
