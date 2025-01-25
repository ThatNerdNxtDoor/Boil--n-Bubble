extends Panel

#Active Side tracking
var active_section
var notes_section
var settings_section

#-------Buttons-------
var notes_button
var settings_button

#-------Left Page-------
# Notes
var page_1_notes
var page_1_number
var page_1_icon
var page_1_text
var page_1_button

#-------Right Page-------
# Notes
var page_2_notes
var page_2_number
var page_2_icon
var page_2_text
var page_2_button

#tracks pairs of note pages, since they are both shown at the same time
var page_info = []
var current_pages

#---------Settings---------
var settings

#AudioStreamPlayer
var audio_player
var page_audio = [preload("res://Assets/SoundEffects/book_flip.1.ogg"),
					preload("res://Assets/SoundEffects/book_flip.2.ogg"),
					preload("res://Assets/SoundEffects/book_flip.3.ogg"),
					preload("res://Assets/SoundEffects/book_flip.4.ogg"),]

# Called when the node enters the scene tree for the first time.
func _ready():
	#-------Buttons-------
	active_section = "Notes"
	notes_button = $NotesButton
	settings_button = $SettingsButton
	
	#-------Notes-------
	notes_section = $Notes
	
	page_1_notes = $Notes/Page1/Notes
	page_1_number = $Notes/Page1/Notes/PageNumber
	page_1_text = $Notes/Page1/Notes/PageText
	page_1_icon = $Notes/Page1/Notes/ItemIcon
	page_1_button = $Notes/Page1/Notes/PreviousButton
	page_1_button.visible = false
	
	page_2_notes = $Notes/Page2/Notes
	page_2_number = $Notes/Page2/Notes/PageNumber
	page_2_text = $Notes/Page2/Notes/PageText
	page_2_icon = $Notes/Page2/Notes/ItemIcon
	page_2_button = $Notes/Page2/Notes/NextButton
	
	# Adds first page to Notes
	page_info.append({
		"Left Text":
			"",
		"Left Icon":
			null,
		"Right Text":
			"",
		"Right Icon":
			null
	})
	current_pages = 1
	
	#-------Settings-------
	settings_section = $Settings
	
	audio_player = $AudioStreamPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#---------------------------Signal Functions---------------------------

#-------------------Side Changing-------------------
func _on_side_change(side : String):
	#Check if the side is the same before making any changes
	if (side == active_section):
		pass
	else:
		#Find which side needs to be disable
		match active_section:
			"Notes":
				notes_section.visible = false
				notes_button.global_position = Vector2(notes_button.global_position.x + 30, notes_button.global_position.y)
			"Settings":
				settings_section.visible = false
				settings_button.global_position = Vector2(settings_button.global_position.x + 30, settings_button.global_position.y)
		#Find which side needs to be enabled
		match side:
			"Notes":
				notes_section.visible = true
				notes_button.global_position = Vector2(notes_button.global_position.x - 30, notes_button.global_position.y)
			"Settings":
				settings_section.visible = true
				settings_button.global_position = Vector2(settings_button.global_position.x - 30, settings_button.global_position.y)
		#Set active section to new side
		active_section = side
		play_randomized_page_audio()

#-------------------Notes-------------------
func _on_page_1_text_changed():
	(page_info[current_pages - 1])["Left Text"] = page_1_text.text

func _on_page_1_icon_changed():
	(page_info[current_pages - 1])["Left Icon"] = page_1_icon.datalist

func _on_page_2_text_changed():
	(page_info[current_pages - 1])["Right Text"] = page_2_text.text

func _on_page_2_icon_changed():
	(page_info[current_pages - 1])["Right Icon"] = page_2_icon.datalist

func _on_previous_button_pressed():
	current_pages = current_pages - 1
	page_1_button.visible = (current_pages != 1)
	page_1_text.text = (page_info[current_pages - 1])["Left Text"]
	page_1_icon.datalist = (page_info[current_pages - 1])["Left Icon"]
	page_1_number.text = "[left][b]" + str(current_pages * 2 - 1)
	
	page_2_text.text = (page_info[current_pages - 1])["Right Text"]
	page_2_icon.datalist = (page_info[current_pages - 1])["Right Icon"]
	page_2_number.text = "[right][b]" + str(current_pages * 2)
	
	play_randomized_page_audio()

func _on_next_button_pressed():
	current_pages = current_pages + 1
	page_1_button.visible = (current_pages != 1)
	if (current_pages > page_info.size()):
		page_info.append({
			"Left Text":
				"",
			"Left Icon":
				null,
			"Right Text":
				"",
			"Right Icon":
				null
		})
	page_1_text.text = (page_info[current_pages - 1])["Left Text"]
	page_1_icon.datalist = (page_info[current_pages - 1])["Left Icon"]
	page_1_number.text = "[left][b]" + str(current_pages * 2 - 1)
	
	page_2_text.text = (page_info[current_pages - 1])["Right Text"]
	page_2_icon.datalist = (page_info[current_pages - 1])["Right Icon"]
	page_2_number.text = "[right][b]" + str(current_pages * 2)
	
	play_randomized_page_audio()

func play_randomized_page_audio():
	audio_player.stream = page_audio[randi_range(0, 3)]
	audio_player.play()
