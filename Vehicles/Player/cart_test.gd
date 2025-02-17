extends Car
##thanks Toiu for the kart :)
@export var target : Node3D
@onready var compass: Node3D = $Compass

func collateral(hit_velocity):
	Globals.lives -= 1
	velocity += (hit_velocity * 1.5)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		rotation = Vector3(0,rotation.y,0)
	
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y += jump_velocity
	
	local_velocity = Vector3(basis.x.dot(velocity),basis.y.dot(velocity),basis.z.dot(velocity))
	
	apply_friction()
	
	handle_movement(delta)
	
	#update global velocity
	velocity = basis.x * local_velocity.x + basis.y * local_velocity.y + basis.z * local_velocity.z
	
	move_and_slide()
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal()) /2


func apply_friction():
	local_velocity.z -= local_velocity.z * (forward_friction/100.0)
	local_velocity.x -= local_velocity.x * (lateral_friction/100.0)

func handle_movement(delta):
	if Input.is_action_pressed("W"):
		local_velocity.z -= engine_power*delta
		$AudioStreamPlayer3D.play()
	elif Input.is_action_pressed("S"):
		local_velocity.z += engine_power/2 * delta
		$AudioStreamPlayer3D.play()
	else:
		$AudioStreamPlayer3D.stop()
	
	if Input.is_action_pressed("Space") and is_on_floor() and not Input.is_action_just_pressed("Space"):
		if !drifting:
			drifting = true
			var steer_dir := Input.get_axis("A","D")
			if steer_dir < 0:
				current_turn_direction = 1
			elif steer_dir > 0:
				current_turn_direction = -1
			else:
				current_turn_direction = 0
				drifting = false
		handle_turning(drift_speed,delta)
	else:
		handle_turning(turn_speed,delta)

func handle_turning(speed,delta):
	var steer_dir := Input.get_axis("A","D")
	if drifting:
		if !Input.is_action_pressed("Space"):
			drifting = false
		if current_turn_direction == 1: #if drifting left
			if steer_dir<0:#turning left
				rotate_y(speed*delta)
			elif steer_dir>0:#turning right
				rotate_y((speed/2)*delta)
			else:#no turning
				rotate_y((speed/1.5)*delta)
		elif current_turn_direction == -1:
			if steer_dir<0:#turning left
				rotate_y(-(speed/2)*delta)
			elif steer_dir>0:#turning right
				rotate_y(-speed*delta)
			else:#no turning
				rotate_y(-(speed/1.5)*delta)
	else:
		if steer_dir:
			rotate_y(-steer_dir*delta)

func global_velocity_to_local(global_vel)->Vector3:
	return Vector3(
		basis.x.dot(global_vel),
		basis.y.dot(global_vel),
		basis.z.dot(global_vel)
	)

##visually change the chasis
func _process(_delta: float) -> void:
	if is_instance_valid(target) and target:
		compass.visible = true
		compass.look_at(target.global_position)
	else:
		compass.visible = false
		compass.rotation = Vector3(deg_to_rad(-90),0,0)
	#front_ray.global_position = global_position
	#back_ray.global_position = global_position

	#if is_on_floor():
		#if front_ray.is_colliding() and back_ray.is_colliding():
			#var ray_normal = (front_ray.get_collision_normal() + back_ray.get_collision_normal()) /2.0
			#var xform = align_with_y(global_transform, ray_normal)
			#global_transform = global_transform.interpolate_with(xform,10*delta)

func calculate_closest_target():
	var current_winner = null
	var current_distance = 0
	if !Globals.target_dictionary.has(Globals.cur_chosen_color):
		target = current_winner
		return
	
	if Globals.target_dictionary[Globals.cur_chosen_color].is_empty():
		target = current_winner
		return
	
	for pedestrian:Node3D in Globals.target_dictionary[Globals.cur_chosen_color]:
		if !is_instance_valid(pedestrian):
			continue
		if current_winner==null :
			current_winner = pedestrian
			current_distance = pedestrian.global_position.distance_to(global_position)
			continue
		
		if pedestrian.global_position.distance_to(global_position)<current_distance:
			current_winner = pedestrian
			current_distance = pedestrian.global_position.distance_to(global_position)
	#print("target has been set")
	target = current_winner

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
