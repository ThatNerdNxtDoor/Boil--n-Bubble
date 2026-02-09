extends Control

var menu_panel
var settings_page
var load_page
var version_label

# Called when the node enters the scene tree for the first time.
func _ready():
	menu_panel = $SettingsPanel
	settings_page = $SettingsPanel/MenuSpine/Settings
	load_page = $SettingsPanel/MenuSpine/LoadPanel
	version_label = $VersionLabel
	version_label.text = "v" + ProjectSettings.get_setting("application/config/version")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	menu_panel.visible = true
	load_page.visible = true
	settings_page.visible = false
	load_page.load_slots()
	pass # Replace with function body.

func _on_settings_button_pressed():
	menu_panel.visible = true
	load_page.visible = false
	settings_page.visible = true
	pass # Replace with function body.

func _on_close_button_pressed():
	menu_panel.visible = false
	pass # Replace with function body.

func _on_load_save():
	get_tree().change_scene_to_file("res://Scenes/World_Scenes/MainGame.tscn")
