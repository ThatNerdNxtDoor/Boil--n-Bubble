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

# When Potions Collides
func _on_body_entered(body):
	#Apply Effects/Aspects to Player (match case?)
	for aspect in pot_datalist["aspect"]:
		print(aspect)
		pass
	for effect in pot_datalist["effect"]:
		print(effect)
		pass
	self.queue_free()
	pass # Replace with function body.
