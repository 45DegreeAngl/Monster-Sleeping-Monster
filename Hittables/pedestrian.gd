extends RigidBody3D

signal ive_been_hit(points,color)


var destroyed : bool = false
@export var point_value = 100
@export var mesh : Node3D

func collateral(hit_velocity):
	self.apply_central_force(hit_velocity * 100)
	$AudioStreamPlayer3D.volume_db = pow(hit_velocity.length(),1.0/4.0)
	$AudioStreamPlayer3D.play()
	if !destroyed:
		ive_been_hit.emit(point_value,$Mesh.mesh.surface_get_material(0).albedo_color)
		destroyed = true
		Globals.target_dictionary[$Mesh.mesh.surface_get_material(0).albedo_color].erase(self)
	$Timer.start()


func _on_timer_timeout() -> void:
	queue_free()
