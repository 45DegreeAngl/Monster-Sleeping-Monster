extends RigidBody3D

signal ive_been_hit(points,color)

var destroyed : bool = false
@export var point_value = 100
@export var mesh : Node3D

func collateral(hit_velocity):
	self.apply_central_force(hit_velocity * 100)
	if !destroyed:
		ive_been_hit.emit(point_value)
		destroyed = true
	$Timer.start()


func _on_timer_timeout() -> void:
	queue_free()
