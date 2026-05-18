extends Node3D

@onready var mixture_mesh : MeshInstance3D = $Mixture
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var burner_timer : Timer = $DistillerTimer
@onready var burner_particles : CPUParticles3D = $Burner/StatusParticles
@onready var container_sprites : Node = $RetopodDistiller/DistillerInteractable/ContainerSprites

var contained_ingredients = []
var full_mixture = null
var open = false
var door_lock = false

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.activate_distiller.connect(activate)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (contained_ingredients.size() > 0):
		for child in contained_ingredients.size():
			(container_sprites.get_child(child)).texture = load(contained_ingredients[child]["icon"])

#Change Color of mixture
func change_mixture_color(color : Color):
	var material = mixture_mesh.get_surface_override_material(0)
	material.albedo_color = color
	mixture_mesh.set_surface_override_material(0, material)

#Funnels the three interactables into a singular function to streamline the process
func activate(function, caller):
	match(function):
		"place": #Place an ingredient in the distiller (up to 5 of the same ingredient)
			var mat_dictionary = PlayerInventory.inventory[PlayerInventory.holding_index]
			
			if ((mat_dictionary != null and mat_dictionary["type"] != "potion" and mat_dictionary["type"] != "mixture") 
			and full_mixture == null and contained_ingredients.size() < 5):
				if (contained_ingredients.size() > 0):
					if (contained_ingredients[0] == mat_dictionary):
						contained_ingredients.append(mat_dictionary)
				else:
					contained_ingredients.append(mat_dictionary)
				PlayerInventory.inventory[PlayerInventory.holding_index] = null
				print(contained_ingredients)
			else:
				pass
		"hatch": #Open/close the hatch
			if (!door_lock):
				open = !open
				animation.play("OpenHatch") if open else animation.play_backwards("OpenHatch")
		"distill": #Distill the ingredients into a potent and more stable mixture
			if (open):
				open = false
				animation.play_backwards("OpenHatch")
			if (full_mixture == null and contained_ingredients[0] != null and contained_ingredients.size() >= 2):
				var main_ingredient = contained_ingredients[0];
				full_mixture = {
					"name": "mixture",
					"icon": "res://Assets/Sprites/MixtureResult.png",
					"type": "mixture",
					"color": [(main_ingredient["color"])[0],
							  (main_ingredient["color"])[1],
							  (main_ingredient["color"])[2]],
					"aspect": main_ingredient["aspect"],
					"effect": main_ingredient["effect"],
					"potency": (main_ingredient["potency"] * contained_ingredients.size()) * .75,
					"complexity": (main_ingredient["complexity"] * contained_ingredients.size()) * .5,
				}
				door_lock = true
				burner_particles.emitting = true
				burner_timer.start()
		"collect": #Collect the mixture from the beaker
			if (mixture_mesh.visible):
				var index = PlayerInventory.inventory.find(null)
				if (index != -1):
					PlayerInventory.inventory[index] = full_mixture
					print("Pick-Up Successful")
					contained_ingredients = []
					full_mixture = null
					mixture_mesh.visible = false
					door_lock = false
				else:
					print('inventory full')

#Burner timer ending completes the distilling
func burner_timeout():
	burner_particles.emitting = false
	mixture_mesh.visible = true
	change_mixture_color(Color(full_mixture["color"][0], full_mixture["color"][1], full_mixture["color"][2]))

#----------------------------Save Management Functions----------------------------
func save():
	var save_dictionary = {
		"contained_ingredients": contained_ingredients,
		"full_mixture": full_mixture,
		"open": open,
		"burner_timer": burner_timer.time_left,
	}
	return save_dictionary

func load_save(load_data):
	contained_ingredients = load_data["contained_ingredients"]
	full_mixture = load_data["full_mixture"]
	open = load_data["open"]
	if (full_mixture != null): #Mixture is brewing or ready to collect.
		if (load_data["burner_timer"] > 0.0):
			burner_timer.start(load_data["burner_timer"])
			door_lock = true
		else:
			burner_timeout()
	
