extends Camera3D


@export var target : Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"..".progress_ratio +=1*delta
	$"..".progress_ratio = roundi($"..".progress_ratio)%100
	look_at(target.position)
