extends RigidBody3D

signal ive_been_hit(points)

var destroyed : bool = false
@export var point_value = 100

func collateral(hit_velocity):
	self.apply_central_force((hit_velocity+ Vector3(0,sqrt(hit_velocity.length()),0))*100 * Vector3(1,1.5,1) )
	if !destroyed:
		ive_been_hit.emit(point_value)
		destroyed = true
