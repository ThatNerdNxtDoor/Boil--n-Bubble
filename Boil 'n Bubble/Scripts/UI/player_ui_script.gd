extends CanvasLayer

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
