extends CharacterBody3D


const SPEED = 7.0
var JUMP_VELOCITY = 4.5
var mouse_sense = 0.05
var slow_mo_on = false

@onready var flashlight = $rot_helper/Flashlight
@onready var rot_help = $rot_helper
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var air_time := 0.0
var jump_boost_time := 0.0
var slow_mo_time:= 0.0
var intoxication := 0.0

signal intoxication_level (i: int)
signal slow_mo_timer (t: int)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	emit_signal("slow_mo_timer", slow_mo_time)

func _input(event):
	
	if event is InputEventMouseMotion:
		rot_help.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		self.rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		rot_help.rotation.x = clamp(rot_help.rotation.x, deg_to_rad(-89),  deg_to_rad(70))
	
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
		
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		air_time += delta
		velocity.y -= gravity * delta
	else:
		air_time = 0
		
		
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and air_time < 0.2:
		velocity.y = JUMP_VELOCITY
	#Boosted Jump
	if Input.is_action_just_pressed("boost_jump") and air_time < 0.2:
		JUMP_VELOCITY = 9
		velocity.y = JUMP_VELOCITY
		intoxication += 15
		update_intox()
		
	if air_time > 0.2:
		JUMP_VELOCITY = 4.5
	
	#Slow Motion
	if Input.is_action_just_pressed("slow_mo"):
		if slow_mo_on == false:
			slow_mo_on = true
			Engine.time_scale = 0.45
			
	#Slow Motion Timer
	if slow_mo_on == true:
		#$rot_helper/camera.fov = 100
		slow_mo_time += delta * 2 + 0.1
		emit_signal("slow_mo_timer", slow_mo_time)
	if slow_mo_on == true and slow_mo_time >= 30:
		#$rot_helper/camera.fov = 75
		slow_mo_on = false
		Engine.time_scale = 1
		slow_mo_time = 0
		emit_signal("slow_mo_timer", slow_mo_time)
		intoxication += 25
		update_intox()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func update_intox():
	emit_signal("intoxication_level", intoxication)

