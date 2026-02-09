extends Node3D

@onready var tutorial_box = $TutorialUI/TutorialBox
@onready var tutorial_text = $TutorialUI/TutorialBox/RichTextLabel
@onready var continue_text = $TutorialUI/TutorialBox/RichTextLabel2

var tutorial_text_track = ["Welcome to [color=purple]Boil n' Bubble[/color]! This tutorial serves to help you understand some basic aspects of the game before you go off into the wilderness!",
							"Take a look inside your [color=brown]cabin[/color]. You'll notice that there's a big [color=purple]cauldron[/color] in the middle. That is where your brewing will begin, but let's get back to that later...",
							"Right now, you need ingredients to actually brew with! Talk a walk around and find some things to [b]interact[/b] with by pressing [b]'E'[/b].",
							"Now that you've got some ingredients, you need to figure out what to do with them. Unfortunately, you're in an [color=green]unexplored wilderness[/color], so that's for you to figure out.",
							"Well, there's a pretty easy way to do it. Use the [b]scroll wheel[/b] to pick the ingredient you want to hold. Once you've selected it, you can [b]right click[/b] to eat it and see the effects.",
							"If you don't feel like eating something, you can just run back to your [color=purple]cauldron[/color]. Once you do, select the ingredient you want to throw in and [b]interact[/b] with the [color=purple]cauldron[/color].",
							"Once you've put in your ingredients, you can [b]interact[/b] with the nozzle attached to the [color=purple]cauldron[/color]. Just be sure to not put too much in... If you see a lot of[color=dark gray]bubbles[/color] and hear hissing, you'll want to back away.",
							"If you've got your [color=blue]potion[/color], congrats! Now to figure what to do with it. While you are holding it, you can either [b]Left Click[/b] to throw it, or [b]Right Click[/b] it to drink it.",
							"Now there's a new issue: How do you keep track of what everything does? Well thankfully, you brought your trusty [color=brown]notebook[/color] with you! Press [b]Esc[/b] to open it.",
							"Each page of your [color=brown]notebook[/color] can have an image and text. You can drag an item from your inventory to the empty image space to dedicate the page to that item.",
							"After that, you can write down whatever you want about the item in the space below it! Then you can to refer back to that page if you forget what you've discovered about it.",
							"When you are done and want to close your [color=brown]notebook[/color], simply press [b]Esc[/b] again. Don't worry, it'll remember the last page you were on!",
							"If you forget anything, or want to learn more about the brewing process, there is a note on your [color=brown]cabin[/color] that you can always [b]interact[/b] with and read.",
							"And that concludes the tutorial, the rest is for you to learn and decipher. To go back to the menu, open the [color=brown]notebook[/color], click the gear, and press the quit button."]
var tutorial_position_track = [Vector2(18, 12), Vector2(330.0, 7), Vector2(644, 453), Vector2(330.0, 7), Vector2(330.0, 7), Vector2(330.0, 7), Vector2(18, 12), Vector2(18, 12), Vector2(18, 12), Vector2(644, 453), Vector2(644, 453), Vector2(644, 453), Vector2(644, 453), Vector2(18, 12)]
var current_context = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if Input.is_action_just_pressed("continue"):
		continue_tutorial()

func continue_tutorial():
	current_context = clamp(current_context + 1, 0, tutorial_text_track.size() - 1)
	if current_context == tutorial_text_track.size() - 1:
		continue_text.visible = false
	tutorial_text.text = tutorial_text_track[current_context]
	tutorial_box.position = tutorial_position_track[current_context]
	#maybe change text box positions?
