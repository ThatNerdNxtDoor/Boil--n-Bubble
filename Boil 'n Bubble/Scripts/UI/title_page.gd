extends Control

var settings_panel

# Called when the node enters the scene tree for the first time.
func _ready():
	settings_panel = $SettingsPanel
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/World_Scenes/MainGame.tscn")
	pass # Replace with function body.

func _on_settings_button_pressed():
	settings_panel.visible = true
	pass # Replace with function body.

func _on_close_button_pressed():
	settings_panel.visible = false
	pass # Replace with function body.
