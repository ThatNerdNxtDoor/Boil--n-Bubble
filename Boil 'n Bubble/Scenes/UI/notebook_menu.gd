extends Panel

#Left Page
var page_1
var page_1_number
var page_1_icon
var page_1_text
var page_1_button

#Right Page
var page_2
var page_2_number
var page_2_icon
var page_2_text
var page_2_button

#tracks pairs of pages, since they are both shown at the same time
var page_info = []
var current_pages

#AudioStreamPlayer
var audio_player
var page_audio = [preload("res://Assets/SoundEffects/book_flip.1.ogg"),
					preload("res://Assets/SoundEffects/book_flip.2.ogg"),
					preload("res://Assets/SoundEffects/book_flip.3.ogg"),
					preload("res://Assets/SoundEffects/book_flip.4.ogg"),]

# Called when the node enters the scene tree for the first time.
func _ready():
	page_1 = $Page1
	page_1_number = $Page1/PageNumber
	page_1_text = $Page1/PageText
	page_1_icon = $Page1/ItemIcon
	page_1_button = $Page1/PreviousButton
	page_1_button.visible = false
	
	page_2 = $Page2
	page_2_number = $Page2/PageNumber
	page_2_text = $Page2/PageText
	page_2_icon = $Page2/ItemIcon
	page_2_button = $Page2/NextButton
	
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
	
	audio_player = $AudioStreamPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#---------------------------Signal Functions---------------------------

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
