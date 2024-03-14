extends ActiveInteractable
class_name ActivePotion

var pot_datalist
#datalist = {
	#"name": always "potion", used to differentiate it from ingredients
	#"color": color, average of all ingredients
	#"aspect": Primary ingredients
	#"effect": Secondaty ingredients
	#"potency": Power of the potion
#}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interaction():
	print("Interaction Potion")
