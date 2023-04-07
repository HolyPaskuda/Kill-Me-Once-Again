extends Node

@export var ammo = 10
@export var ammo_max = 10
@export var shoot_timer_max = 1.0
@export var projectile_scene : PackedScene
var shoot_timer = 0.0

@onready var shoota : CollisionShape3D = get_node("../rot_helper/Area3D/shoot-area")

signal set_ammo_count (a: int, am: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("set_ammo_count", ammo, ammo_max)
	


func _input(event: InputEvent):
	if event.is_action_pressed("shoot"):
		if shoot_timer >= 1:
			return
		if ammo == 0:
			return
		var projectile = projectile_scene.instantiate()
		projectile.position = shoota.global_transform.origin
		projectile.rotation = shoota.global_rotation
		add_child(projectile)
		ammo -= 1
		shoot_timer = shoot_timer_max
		emit_signal("set_ammo_count", ammo, ammo_max)
	if event.is_action_pressed("reload"):
		ammo = ammo_max
		emit_signal("set_ammo_count", ammo, ammo_max)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	shoot_timer = max(shoot_timer - delta, 0)
