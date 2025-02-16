extends Node

@onready var player_packed : PackedScene = preload("res://Vehicles/Player/cart_test.tscn")
@onready var pedestrian_packed: PackedScene = preload("res://Hittables/pedestrian.tscn")
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
	Globals.total_time_in_sec += delta
	Globals.time_left_in_sec -= delta
	if Globals.total_time_in_sec > 5.0 and hittables.get_child_count()<5:
		print("Making pedestrian")
		var chosen_place = Globals.get_random_child(player_spawns)
		var pedestrian = create_pedestrian()
		hittables.add_child(pedestrian)
		pedestrian.global_position = chosen_place.global_position
	
	if roundi(Globals.total_time_in_sec) % 30 == 0:
		randomize_objectives()
	

##if they hit the current color, they get bonus points, if they hit the wrong color they earn points but a lot less
func receive_points(points,color):
	print("Hunted Color: "+str(Globals.colors[Globals.cur_chosen_color])+" | Hit: "+str(Globals.colors[color])+" | Worth : "+str(points))
	if color == Globals.cur_chosen_color:
		#print("BONUS : "+str(points * Globals.cur_chosen_multiplier))
		Globals.points += points * Globals.cur_chosen_multiplier
		Globals.time_left_in_sec += 10
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
	return pedestrian_instance
