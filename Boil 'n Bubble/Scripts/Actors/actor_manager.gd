extends Node

@export var trader : PackedScene
var active_trader

@onready var trader_spawn_tree = $Frontier/TraderNavGroup
@onready var trader_timer = $TraderTimer

var trader_reward_pool = ["Ingredient", "Farm", "Storage"]

func _ready():
	pass

func spawn_trader():
	active_trader = trader.instantiate()
	active_trader.global_position = Vector3(19.248, -12.9, -11.422)
	active_trader.connect("left", trader_left)
	active_trader.reward = trader_reward_pool[randi_range(0, trader_reward_pool.size() - 1)]
	trader_spawn_tree.add_child(active_trader)
	SignalBus.trader_entered.emit()

func trader_left(success, reward):
	if success:
		match reward: #If the reward was not an ingredient, it will be removed from the reward pool.
			"Farm":
				trader_reward_pool.erase("Farm")
			"Storage":
				trader_reward_pool.erase("Storage")
			_:
				pass
	trader_timer.start()

func save():
	var trader_request
	var trader_stay
	var trader_reward
	var trader_pos
	var trader_target
	if trader_timer.time_left == 0: #Signifies that the trader has spawned and exists
		trader_request = active_trader.desired_potion_specs
		trader_reward = active_trader.reward
		trader_stay = active_trader.stay_timer.time_left
		trader_pos = [active_trader.global_position[0], active_trader.global_position[1], active_trader.global_position[2]]
		trader_target = [active_trader.movement_target_position[0], active_trader.movement_target_position[1], active_trader.movement_target_position[2]]
	else: #If trader does not exists, then do not fill any of these attributes
		trader_request = null
		trader_reward = null
		trader_stay = null
		trader_pos = null
		trader_target = null
	var save_data = {
		"trader_arrival": trader_timer.time_left, 
		"trader_request": trader_request,
		"trader_reward_pool": trader_reward_pool,
		"trader_reward": trader_reward,
		"trader_stay": trader_stay,
		"trader_pos": trader_pos,
		"trader_target": trader_target
	}
	return save_data

func load_save(load_data):
	if load_data["trader_arrival"] == 0: #If trader existed when saved
		active_trader = trader.instantiate()
		trader_spawn_tree.add_child(active_trader)
		
		active_trader.global_position = Vector3(load_data["trader_pos"][0], load_data["trader_pos"][1], load_data["trader_pos"][2])
		active_trader.movement_target_position = Vector3(load_data["trader_target"][0], load_data["trader_target"][1], load_data["trader_target"][2])
		active_trader.set_movement_target(active_trader.movement_target_position)
		
		active_trader.desired_potion_specs = load_data["trader_request"]
		active_trader.reward = load_data["trader_reward"]
		
		active_trader.connect("left", trader_left)
		active_trader.stay_timer.start(load_data["trader_stay"])
		trader_timer.stop()
	else: #If trader didn't exist, then resume where the timer left off
		trader_timer.start(load_data["trader_arrival"])
	trader_reward_pool = load_data["trader_reward_pool"]
