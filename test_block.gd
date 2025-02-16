extends Node3D

func get_spawn_point()->Vector3:
	var spawn_body = Globals.get_random_child($"Spawn Shape")
	return Globals.get_random_point_within_shape(spawn_body)

func get_target_spawn_point()->Vector3:
	return Globals.get_random_child($"Target Spawn").global_position
