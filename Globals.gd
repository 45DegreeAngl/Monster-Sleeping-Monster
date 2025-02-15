extends Node

const colors : Array[Color] = [Color.YELLOW,Color.BLUE,Color.RED]
@onready var cur_chosen_color : Color = colors[0]
const multipliers : Array[float] = [1.0,0.5,0.3,1.5,2.0,3.0,4.0,5.0,7.5,10.0,15.0]
@onready var cur_chosen_multiplier : float = multipliers[0]
const size_variations : Array[float] = [0.3,0.5,0.7,0.9,1.0,1.2,1.4,1.6,1.8,2.0,3.0,4.0,5.0]
@onready var points = 0
@onready var total_time = 0

func get_random_child(node:Node)->Node:
	return node.get_child(randi()%node.get_child_count())

##returns an element within the array that is random, if the holder is a dictionary, returns random key
func get_random_element(holder):
	if holder is Array:
		var size = holder.size()
		if size!=0:
			return holder[randi_range(0,size-1)]
	elif holder is Dictionary:
		var keys = holder.keys()
		var size = keys.size()
		if size!=0:
			return keys[randi_range(0,size-1)]
	#if not a array or dictionary, or it doesnt contain any elements
	return null

func spawn_packed(packedScene:PackedScene)->Node:
	return packedScene.instantiate()

func load_scene(filePath:String)->Node:
	return load(filePath).instantiate()


func get_random_point_within_shape(collision_shape : CollisionShape3D) -> Vector3:
	var points = []

	if collision_shape.shape is BoxShape3D:
		points = get_points_in_box(collision_shape.shape)
	elif collision_shape.shape is SphereShape3D:
		points = get_points_in_sphere(collision_shape.shape)
	elif collision_shape.shape is CapsuleShape3D:
		points = get_points_in_capsule(collision_shape.shape)
	else:
		return Vector3.ZERO  # Return a default value if shape is not supported

	return points[randi() % points.size()]

func get_points_in_box(box_shape : BoxShape3D) -> Array:
	var points = []
	var min = -box_shape.extents
	var max = box_shape.extents

	for i in range(1000):  # Generate a set of random points
		var point = Vector3(randf_range(min.x, max.x), randf_range(min.y, max.y), randf_range(min.z, max.z))
		points.append(point)

	return points

func get_points_in_sphere(sphere_shape : SphereShape3D) -> Array:
	var points = []
	var radius = sphere_shape.radius

	for i in range(1000):  # Generate a set of random points
		var theta = randf() * TAU
		var phi = acos(2.0 * randf() - 1.0)
		var r = pow(randf(),1/3) * radius  # Cube root for uniform distribution
		var point = Vector3(r * sin(phi) * cos(theta), r * sin(phi) * sin(theta), r * cos(phi))
		points.append(point)

	return points

func get_points_in_capsule(capsule_shape : CapsuleShape3D) -> Array:
	var points = []
	var radius = capsule_shape.radius
	var height = capsule_shape.height

	for i in range(1000):  # Generate a set of random points
		var theta = randf() * TAU
		var r = sqrt(randf()) * radius  # Square root for uniform distribution on disc
		var x = r * cos(theta)
		var y = r * sin(theta)
		var z = randf_range(-height / 2, height / 2)  # Random point along the height
		if randi() % 2 == 0:
			z += sign(z) * radius  # Adjust for the capsule ends
		var point = Vector3(x, y, z)
		points.append(point)

	return points
