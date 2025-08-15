extends ColorRect

var status : String  #The name of the status effect
@onready var picture : TextureRect = $PictureIcon

@onready var status_panel : Panel = $StatusPanel

var panel_vanishing : bool = false
@onready var status_text : RichTextLabel = $StatusPanel/RichTextLabel

@onready var status_window_timer : Timer = $Timer
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var status_dict = {
	"Wind": {
			"sprite": "res://Assets/Sprites/StatusIcons/StatusIcon_JumpUp.png",
			"text": "You feel a little lighter on your feet."
		}
	,
	"Fire": {
			"sprite": "res://Assets/Sprites/StatusIcons/StatusIcon_On_Fire.png",
			"text": "You feel warm. Way too warm."
		}
	,
	"Poison": {
			"sprite": "res://Assets/Sprites/StatusIcons/StatusIcon_Posion.png",
			"text": "The inside of your body is recoiling in pain."
		}
	,
	"Regeneration": {
			"sprite": "res://Assets/Sprites/StatusIcons/StatusIcon_Empty.png",
			"text": "You feel your body slowly mending itself together."
		}
	,
	"Slow": {
			"sprite": "res://Assets/Sprites/StatusIcons/StatusIcon_Slow.png",
			"text": "You can hardly move your legs!"
		}
	,
	"Bog": {
		"sprite": "res://Assets/Sprites/StatusIcons/StatusIcon_Bogged.png",
		"text": "You seem a little... bogged down, eh?"
	}
	,
	"Dizzy": {
			"sprite": "res://Assets/Sprites/StatusIcons/StatusIcon_Empty.png",
			"text": "Your senses are hindered, as well as your footing."
		}
	,
	"Shrink": {
			"sprite": "res://Assets/Sprites/StatusIcons/StatusIcon_Shrink.png",
			"text": "Hey... since when did everything get bigger?"
		}
	,
	"DEFAULT": {
			"sprite": "res://Assets/Sprites/StatusIcons/StatusIcon_Empty.png",
			"text": "You feel... something."
		}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#TODO: Maybe make another JSON for the status effects? Or combine it with the material datalist for
# one big json?
##Sets the picture and status to the specified status effect.
func set_status(status_effect):
	# picture and text have a default value in case the effect hasn't been defined in the
	# status_dict yet.
	status = status_effect
	picture.texture = load(status_dict.get(status_effect, status_dict["DEFAULT"])["sprite"])
	status_text.text = "[center]" + status_dict.get(status_effect, status_dict["DEFAULT"])["text"]

func _on_timer_timeout():
	animation_player.play("StatusPanelVanish")
	pass # Replace with function body.
