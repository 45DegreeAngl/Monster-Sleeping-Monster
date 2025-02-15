extends Node

@onready var player_packed : PackedScene = preload("res://cart_test.tscn")
@onready var player: Node = $Player
@onready var player_spawns: Node = $"Player Spawns"
@onready var hittables: Node = $Hittables
@onready var terrain: Node = $Terrain
@onready var buildings: Node = $Buildings

func _ready() -> void:
	process_mode = PROCESS_MODE_DISABLED
	start()

func start():
	if player_spawns.get_child_count()<1:
		print("No places for the player to spawn")
		return
	
	##choose random color to be important
	randomize_objectives()
	print(Globals.cur_chosen_color)
	
	var chosen_place = Globals.get_random_child(player_spawns)
	var player_instance = Globals.spawn_packed(player_packed)
	player.add_child(player_instance)
	player_instance.global_position = chosen_place.global_position
	process_mode = PROCESS_MODE_INHERIT

func randomize_objectives():
	Globals.cur_chosen_color = Globals.get_random_element(Globals.colors)
	Globals.cur_chosen_multiplier = Globals.get_random_element(Globals.multipliers)

func _process(delta: float) -> void:
	Globals.total_time += delta

##if they hit the current color, they get bonus points, if they hit the wrong color they earn points but a lot less
func receive_points(points,color):
	if color == Globals.cur_chosen_color:
		Globals.points += points * Globals.cur_chosen_multiplier
	else:
		Globals.points += points / max(Globals.cur_chosen_multiplier,0.01)
	
	
