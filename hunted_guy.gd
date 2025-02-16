extends Node3D

func set_color(color:Color):
	var ped_material : StandardMaterial3D= $Mesh.mesh.surface_get_material(0).duplicate()
	ped_material.albedo_color = color
	$Mesh.mesh.surface_set_material(0,ped_material)
