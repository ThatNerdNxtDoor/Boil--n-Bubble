extends Control

signal load_save()

var selected_file : String

@export var save_slot_button : PackedScene

@onready var save_container = $Page1/SavedGames/ScrollContainer/Panel/VBoxContainer

@onready var save_title = $Page2/LoadButtons/SaveData/FileName
@onready var save_data = $Page2/LoadButtons/SaveData/FileData

@onready var load_button = $Page2/LoadButtons/LoadGameButton
@onready var delete_button = $Page2/LoadButtons/DeleteButton

func load_slots():
	for child in save_container.get_children():
		save_container.remove_child(child)
		child.queue_free()
	var save_directory = DirAccess.open("res://Assets/Data/SaveData")
	var save_files = save_directory.get_files()
	print(save_files)
	for file in save_files:
		var new_slot = save_slot_button.instantiate()
		new_slot.text = file
		new_slot.connect("pressed", select_slot.bind(file))
		save_container.add_child(new_slot)

func select_slot(file : String):
	selected_file = "res://Assets/Data/SaveData/" + file
	save_title.text = "[center]" + file
	var metadata : Dictionary = SaveManager.get_file_metadata(selected_file)
	save_data.text = "Save Date: " + metadata["date saved"] + "\nVersion: " + metadata["version"]
	load_button.visible = true
	delete_button.visible = true

func new_game():
	SaveManager.current_slot = "newgame"
	load_save.emit()

func delete_save():
	if selected_file != null:
		SaveManager.current_slot = selected_file
		SaveManager.delete_save()
		load_slots()

func load_save_slot():
	if selected_file != null:
		SaveManager.current_slot = selected_file
		load_save.emit()

func load_tutorial():
	get_tree().change_scene_to_file("res://Scenes/World_Scenes/TutorialGame.tscn")
