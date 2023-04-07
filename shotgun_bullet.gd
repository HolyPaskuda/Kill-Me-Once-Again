extends CharacterBody3D

@export var bullet_speed := 2.0

const remove_timer = 4
var timer = 0

var is_flying = true

func _process(delta):
	if is_flying:
		velocity = ((transform.basis * Vector3.FORWARD * bullet_speed) * Engine.time_scale) / 1
		timer += delta
		var collision: KinematicCollision3D = move_and_collide(velocity)
		if timer >= remove_timer:
			queue_free()
		if collision:
			is_flying = false
			queue_free()
			


	


