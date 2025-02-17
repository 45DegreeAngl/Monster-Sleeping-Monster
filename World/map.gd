extends Node

@onready var player_packed : PackedScene = preload("res://Vehicles/Player/cart_test.tscn")
@onready var pedestrian_packed: PackedScene = preload("res://Hittables/pedestrian.tscn")
@onready var cop_packed : PackedScene = preload("res://Vehicles/Police/police.tscn")
@onready var main_menu_music : AudioStream = preload("res://Sounds/Title.mp3")
@onready var in_game_music : AudioStream = null
@onready var player: Node = $Player
@onready var player_spawns: Node = $"Player Spawns"
@onready var hittables: Node = $Hittables
@onready var pedestrian_spawns: Node = $"Pedestrian Spawns"
@onready var terrain: Node = $Terrain
@onready var buildings: Node = $Buildings

func _ready() -> void:
	process_mode = PROCESS_MODE_DISABLED

func start():
	$AudioStreamPlayer.stream = in_game_music
	$CanvasLayer/HUD.visible = true
	$"CanvasLayer/Main Menu".visible = false
	$"CanvasLayer/Main Menu/SubViewportContainer/SubViewport/Path3D/PathFollow3D/Camera3D".current = false
	if player_spawns.get_child_count()<1:
		print("No places for the player to spawn")
		return
	
	##choose random color to be important
	_on_randomize_objective_timer_timeout()
	#print(Globals.cur_chosen_color)
	
	var chosen_place = Globals.get_random_child(player_spawns)
	var player_instance = Globals.spawn_packed(player_packed)
	player.add_child(player_instance)
	player_instance.global_position = chosen_place.global_position
	process_mode = PROCESS_MODE_INHERIT

func randomize_objectives():
	Globals.cur_chosen_color = Globals.get_random_element(Globals.colors)
	Globals.cur_chosen_multiplier = Globals.get_random_element(Globals.multipliers)

func _process(delta: float) -> void:
	Globals.total_time_in_sec += delta
	Globals.time_left_in_sec -= delta
	if Globals.time_left_in_sec <= 0:
		lose()
	if rolling:
		randomize_objectives()
		

func lose():
	$"CanvasLayer/Lose Screen/VBoxContainer/Total Points".text = "Total Points: "+str(Globals.points)
	$"CanvasLayer/Lose Screen/VBoxContainer/Total Time".text = "Time Lasted: "+str(Globals.total_time_in_sec)
	call_deferred("disable_process")
	player.get_child(0).queue_free()
	$CanvasLayer/HUD.visible = false
	$"CanvasLayer/Lose Screen".visible = true

func disable_process():
	process_mode = PROCESS_MODE_DISABLED

##if they hit the current color, they get bonus points, if they hit the wrong color they earn points but a lot less
func receive_points(points,color):
	print("Hunted Color: "+str(Globals.colors[Globals.cur_chosen_color])+" | Hit: "+str(Globals.colors[color])+" | Worth : "+str(points))
	if color == Globals.cur_chosen_color:
		#print("BONUS : "+str(points * Globals.cur_chosen_multiplier))
		Globals.points += points * Globals.cur_chosen_multiplier
		Globals.time_left_in_sec += 5
	else:
		#print("Adding points : "+str(points / max(Globals.cur_chosen_multiplier,0.01)))
		Globals.points += points / max(Globals.cur_chosen_multiplier,0.01)

func create_pedestrian()->RigidBody3D:
	var pedestrian_instance : RigidBody3D = Globals.spawn_packed(pedestrian_packed)
	pedestrian_instance.mass = Globals.get_random_element(Globals.mass_variations)
	var physics_material : PhysicsMaterial = PhysicsMaterial.new()
	physics_material.absorbent = Globals.get_random_element(Globals.absorbant_variations)
	physics_material.bounce = Globals.get_random_element(Globals.bounce_variations)
	physics_material.friction = Globals.get_random_element(Globals.friction_variations)
	physics_material.rough = Globals.get_random_element(Globals.rough_variations)
	pedestrian_instance.physics_material_override = physics_material
	pedestrian_instance.gravity_scale = Globals.get_random_element(Globals.gravity_variations)
	var ped_mesh : Mesh = pedestrian_instance.get_node("Mesh").mesh
	var ped_material :StandardMaterial3D = ped_mesh.surface_get_material(0)
	
	ped_material.albedo_color = Color(Globals.get_random_element(Globals.colors))
	#print("Random element example: " + Globals.colors[Globals.get_random_element(Globals.colors)])
	#print("Current element: " + Globals.colors[ped_material.albedo_color])
	ped_mesh.surface_set_material(0,ped_material)
	pedestrian_instance.get_node("Mesh").mesh = ped_mesh
	pedestrian_instance.ive_been_hit.connect(receive_points)
	if !Globals.target_dictionary.has(ped_material.albedo_color):
		Globals.target_dictionary[ped_material.albedo_color] = []
	Globals.target_dictionary[ped_material.albedo_color].append(pedestrian_instance)
	#if ped_material.albedo_color == Globals.cur_chosen_color:
		#print("A TARGET HAS SPAWNED")
	return pedestrian_instance

var time_of_day_in_deg = 200
func _on_1_second_timeout() -> void:
	$Light/Sun.rotation.x = deg_to_rad(time_of_day_in_deg)
	time_of_day_in_deg+=2
	time_of_day_in_deg = time_of_day_in_deg%360
	if $Cops.get_child_count()>=Globals.cop_limit:
		return
	var cop_instance = Globals.spawn_packed(cop_packed)
	$Cops.add_child(cop_instance)
	cop_instance.global_position = Globals.get_random_point_within_shape(Globals.get_random_child($"Pedestrian Spawns"))

func _on_hittable_timeout() -> void:
	#return
	if hittables.get_child_count()>=Globals.spawn_cap:
		return
	var chosen_place = Globals.get_random_point_within_shape(Globals.get_random_child(pedestrian_spawns))
	var pedestrian = create_pedestrian()
	hittables.add_child(pedestrian)
	pedestrian.global_position = chosen_place

var rolling : bool = false
func _on_randomize_objective_timer_timeout() -> void:
	$CanvasLayer/HUD.play_roll()
	$Balls.start()
	rolling = true


func _on_balls_timeout() -> void:
	rolling = false
	$CanvasLayer/HUD.play_win()


func _on_main_menu_pressed() -> void:
	$"CanvasLayer/Main Menu".visible = true
	$"CanvasLayer/Main Menu/SubViewportContainer/SubViewport/Path3D/PathFollow3D/Camera3D".make_current()
	$"CanvasLayer/Lose Screen".visible = false
	Globals.lives = 3
	Globals.points = 0
	Globals.time_left_in_sec = 360
	Globals.total_time_in_sec = 0
	for child in $Cops.get_children():
		child.queue_free()
	for color in Globals.target_dictionary:
		for pedestrian in Globals.target_dictionary[color]:
			Globals.target_dictionary[color].erase(pedestrian)
			pedestrian.queue_free()
	$AudioStreamPlayer.stream = main_menu_music
	$AudioStreamPlayer.play()
			
