class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 120.0

@onready var shooter := $shooter
@onready var sprite := $Sprite2D
@onready var cshape := $CollisionShape2D

var laser_scene := preload("res://Scenes/laser.tscn")
var laser_on_cd := false
var laser_cd := 0.2
var alive := true

func _process(delta):
	if !alive:
		return

	if Input.is_action_pressed("shoot"):
		if !laser_on_cd:
			laser_on_cd = true
			shoot_laser()
			await get_tree().create_timer(laser_cd).timeout
			laser_on_cd = false

func _physics_process(delta):
	if !alive:
		return

	var input_dir = Vector2(0, Input.get_axis("mv_foward", "mv_backward"))
	velocity += acceleration * input_dir.rotated(rotation)
	velocity = velocity.limit_length(max_speed)
	
	if input_dir.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 2.3)
		
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-delta*rotation_speed))
	elif Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(delta*rotation_speed))
	
	move_and_slide()
	
	var screen_size = get_viewport_rect().size
	
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
		
func shoot_laser():
	var las = laser_scene.instantiate()
	las.global_position = shooter.global_position
	las.rotation = rotation
	emit_signal("laser_shot", las)

func die():
	if alive:
		alive = false
		emit_signal("died")
		sprite.visible = false
		cshape.set_deferred("disabled", true)

func respawn(pos):
	if !alive:
		alive = true
		sprite.visible = true
		velocity = Vector2.ZERO
		cshape.set_deferred("disabled", false)
		global_position = pos
