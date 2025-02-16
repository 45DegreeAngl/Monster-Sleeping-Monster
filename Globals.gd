extends Node

##player variables
signal time_left_changed
signal points_changed
signal chosen_color_changed
signal chosen_multiplier_changed
@onready var time_left_in_sec : float = 180.0:
	set(value):
		time_left_in_sec = value
		time_left_changed.emit()
@onready var points : int = 0:
	set(value):
		points = value
		points_changed.emit()
@onready var total_time_in_sec : float = 0
@onready var cur_chosen_color : Color = colors.keys()[0]:
	set(value):
		cur_chosen_color = value
		chosen_color_changed.emit()
const multipliers : Array[float] = [1.0,0.5,0.3,1.5,2.0,3.0,4.0,5.0,7.5,10.0,15.0]
@onready var cur_chosen_multiplier : float = multipliers[0]:
	set(value):
		cur_chosen_multiplier = value
		chosen_multiplier_changed.emit()
##pedestrian constants
#color
const colors : Dictionary = {
	Color(1,1,1,1):"Pure White",
	Color.ALICE_BLUE: "Alice Blue",
	Color.ANTIQUE_WHITE: "Antique White",
	Color.AQUA: "Aqua",
	Color.AQUAMARINE: "Aquamarine",
	Color.AZURE: "Azure",
	Color.BEIGE: "Beige",
	Color.BISQUE: "Bisque",
	Color.BLACK: "Black",
	Color.BLANCHED_ALMOND: "Blanched Almond",
	Color.BLUE: "Blue",
	Color.BLUE_VIOLET: "Blue Violet",
	Color.BROWN: "Brown",
	Color.BURLYWOOD: "Burlywood",
	Color.CADET_BLUE: "Cadet Blue",
	Color.CHARTREUSE: "Chartreuse",
	Color.CHOCOLATE: "Chocolate",
	Color.CORAL: "Coral",
	Color.CORNFLOWER_BLUE: "Cornflower Blue",
	Color.CORNSILK: "Cornsilk",
	Color.CRIMSON: "Crimson",
	Color.DARK_BLUE: "Dark Blue",
	Color.DARK_CYAN: "Dark Cyan",
	Color.DARK_GOLDENROD: "Dark Goldenrod",
	Color.DARK_GRAY: "Dark Gray",
	Color.DARK_GREEN: "Dark Green",
	Color.DARK_KHAKI: "Dark Khaki",
	Color.DARK_MAGENTA: "Dark Magenta",
	Color.DARK_OLIVE_GREEN: "Dark Olive Green",
	Color.DARK_ORANGE: "Dark Orange",
	Color.DARK_ORCHID: "Dark Orchid",
	Color.DARK_RED: "Dark Red",
	Color.DARK_SALMON: "Dark Salmon",
	Color.DARK_SEA_GREEN: "Dark Sea Green",
	Color.DARK_SLATE_BLUE: "Dark Slate Blue",
	Color.DARK_SLATE_GRAY: "Dark Slate Gray",
	Color.DARK_TURQUOISE: "Dark Turquoise",
	Color.DARK_VIOLET: "Dark Violet",
	Color.DEEP_PINK: "Deep Pink",
	Color.DEEP_SKY_BLUE: "Deep Sky Blue",
	Color.DIM_GRAY: "Dim Gray",
	Color.DODGER_BLUE: "Dodger Blue",
	Color.FIREBRICK: "Firebrick",
	Color.FLORAL_WHITE: "Floral White",
	Color.FOREST_GREEN: "Forest Green",
	Color.FUCHSIA: "Fuchsia",
	Color.GAINSBORO: "Gainsboro",
	Color.GHOST_WHITE: "Ghost White",
	Color.GOLD: "Gold"
}
#physics
const mass_variations : Array[float] = [0.5,0.75,1.0,1.25,1.5,1.75,2.0]
const size_variations : Array[float] = [0.3,0.5,0.7,0.9,1.0,1.2,1.4,1.6,1.8,2.0,3.0,4.0,5.0]
const friction_variations : Array[float] = [0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]
const rough_variations : Array[bool] = [true,false]
const bounce_variations : Array[float] = [0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]
const absorbant_variations : Array[bool] = [true,false]
const gravity_variations : Array[float] = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.5,2.0,3.0]

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
	var verticies = []

	if collision_shape.shape is BoxShape3D:
		verticies = get_verticies_in_box(collision_shape.shape)
	elif collision_shape.shape is SphereShape3D:
		verticies = get_verticies_in_sphere(collision_shape.shape)
	elif collision_shape.shape is CapsuleShape3D:
		verticies = get_verticies_in_capsule(collision_shape.shape)
	else:
		return Vector3.ZERO  # Return a default value if shape is not supported

	return verticies[randi() % verticies.size()]

func get_verticies_in_box(box_shape : BoxShape3D) -> Array:
	var verticies = []
	var minimum = -box_shape.extents
	var maximum = box_shape.extents

	for i in range(1000):  # Generate a set of random verticies
		var point = Vector3(randf_range(minimum.x, maximum.x), randf_range(minimum.y, maximum.y), randf_range(minimum.z, maximum.z))
		verticies.append(point)

	return verticies

func get_verticies_in_sphere(sphere_shape : SphereShape3D) -> Array:
	var verticies = []
	var radius = sphere_shape.radius

	for i in range(1000):  # Generate a set of random verticies
		var theta = randf() * TAU
		var phi = acos(2.0 * randf() - 1.0)
		var r = pow(randf(),1.0/3.0) * radius  # Cube root for uniform distribution
		var point = Vector3(r * sin(phi) * cos(theta), r * sin(phi) * sin(theta), r * cos(phi))
		verticies.append(point)

	return verticies

func get_verticies_in_capsule(capsule_shape : CapsuleShape3D) -> Array:
	var verticies = []
	var radius = capsule_shape.radius
	var height = capsule_shape.height

	for i in range(1000):  # Generate a set of random verticies
		var theta = randf() * TAU
		var r = sqrt(randf()) * radius  # Square root for uniform distribution on disc
		var x = r * cos(theta)
		var y = r * sin(theta)
		var z = randf_range(-height / 2, height / 2)  # Random point along the height
		if randi() % 2 == 0:
			z += sign(z) * radius  # Adjust for the capsule ends
		var point = Vector3(x, y, z)
		verticies.append(point)

	return verticies

func format_seconds_as_time(seconds:float)->String:
	var hours = int(seconds / 3600)
	
	@warning_ignore("integer_division")
	var minutes = int((int(seconds)%3600)/60)
	
	var secs = int(seconds)%60
	
	var deciseconds = int((seconds-int(seconds))*10)
	return "%02d:%02d:%02d.%01d"%[hours, minutes, secs, deciseconds]

func format_number_with_commas(number:int)->String:
	if number<10:
		return str(number)
	var num_str = str(number)
	var result = ""
	var count = 0
	
	for i in range(num_str.length()-1,-1,-1):
		result = num_str[i]+result
		count+= 1
		if count % 3 == 0 and i!=0:
			result = ","+result
	return result
