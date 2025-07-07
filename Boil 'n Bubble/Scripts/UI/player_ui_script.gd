extends CanvasLayer

#--------------------------------------------------------------------------------------------------#
var inventory_slot
var collectibles = {
	"Everbell": false
}
@onready var everbell_ui = $EverbellSprite
@onready var everbell_animation : AnimationPlayer = $EverbellSprite/AnimationPlayer
@onready var bell_audio = load("res://Assets/SoundEffects/ever-bell.wav")
@onready var ui_sfx = $SFX
#--------------------------------------------------------------------------------------------------#
@export var ui_icon_packed : PackedScene
@onready var storage_windows = $StorageWindow
var open_window
var icon_container
#--------------------------------------------------------------------------------------------------#
@onready var dialogue_window = $DialogueWindow
@onready var dialogue_text = $DialogueWindow/DialogueBox/DialogueText
@onready var name_text = $DialogueWindow/DialogueBox/NamePanel/NameText
var text_speed = 2
var talking_npc
#--------------------------------------------------------------------------------------------------#

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_slot = [$Hotbar/ItemIcon, $Hotbar/ItemIcon2, $Hotbar/ItemIcon3, $Hotbar/ItemIcon4, $Hotbar/ItemIcon5, $Hotbar/ItemIcon6, $Hotbar/ItemIcon7, $Hotbar/ItemIcon8]
	SignalBus.connect("unlock_collectible", unlock_collectible)
	SignalBus.connect("trader_entered", ring_bell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Monitors the hotbar
	for i in range(8):
		(inventory_slot[i]).held = false
		(inventory_slot[i]).datalist = PlayerInventory.inventory[i]
	(inventory_slot[PlayerInventory.holding_index]).held = true
	
	#Types out the dialog box while the dialog box is active
	if (dialogue_text.visible_ratio < 1):
		dialogue_text.visible_ratio += 1.0/dialogue_text.text.length()/text_speed

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/World_Scenes/MainGame.tscn")

#General function for closing a window
func close_window():
	if icon_container != null: ##Means that it is a container window
		for icon in icon_container.get_children():
			icon.queue_free()
		icon_container = null
	elif talking_npc != null:
		print("emit closed dialogue")
		SignalBus.dialogue_box_closed.emit(talking_npc)
		talking_npc = null
	open_window.visible = false
	open_window = null

func unlock_collectible(collectible):
	print("collected " + str(collectible))
	collectibles[collectible] = true
	match(collectible):
		"Everbell":
			everbell_ui.visible = true

#==========================================Storage Window===========================================

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

#=========================================Dialogue Window===========================================

func display_dialogue_window(npc_name, dialogue_track):
	open_window = dialogue_window
	talking_npc = npc_name
	dialogue_window.visible = true
	name_text.text = "[center]" + npc_name
	dialogue_text.text = dialogue_track
	dialogue_text.visible_ratio = 0

#=========================================Misc Functions============================================

func ring_bell():
	if collectibles["Everbell"]:
		ui_sfx.stream = bell_audio
		ui_sfx.play()
		everbell_animation.play("Ring")
