extends Control

var quit_button

var master_volume_sl
var music_volume_sl
var sfx_volume_sl

# Called when the node enters the scene tree for the first time.
func _ready():
	quit_button = $Page2/QuitToMenuButton
	print(get_tree().current_scene)
	if get_tree().current_scene.name ==  "TitlePage":
		quit_button.visible = false
	else:
		quit_button.visible = true
	
	master_volume_sl = $"Page1/Settings/AudioPanel/MasterVolumeSlider"
	master_volume_sl.value = GlobalSettings.master_volume
	music_volume_sl = $"Page1/Settings/AudioPanel/MusicVolumeSlider"
	music_volume_sl.value = GlobalSettings.music_volume
	sfx_volume_sl = $"Page1/Settings/AudioPanel/SFXVolumeSlider"
	sfx_volume_sl.value = GlobalSettings.sfx_volume
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_master_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	GlobalSettings.master_volume = value
	pass # Replace with function body.

func _on_music_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	GlobalSettings.music_volume = value
	pass # Replace with function body.

func _on_sfx_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	GlobalSettings.sfx_volume = value
	pass # Replace with function body.

func _on_quit_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/World_Scenes/title_page.tscn")
	pass # Replace with function body.
