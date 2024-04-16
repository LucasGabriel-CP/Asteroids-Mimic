class_name Asteroid extends Area2D

signal exploded(pos, size, points)
enum AsteroidSize{LARGE, MEDIUM, SMALL}

@export var size := AsteroidSize.LARGE
@export var speed := 50

@onready var sprite := $Sprite2D
@onready var cshape := $CollisionShape2D

var movement_vector := Vector2(0, -1)

var points : int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 100
			AsteroidSize.MEDIUM:
				return 50
			AsteroidSize.SMALL:
				return 25
			_:
				return 0

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = randf_range(0, 2*PI)
	
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50.0, 100.0)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_big4.png")
			cshape.set_deferred("shape", preload("res://resources/asteroids_cs/big4.tres"))
			pass
		AsteroidSize.MEDIUM:
			speed = randf_range(100.0, 150.0)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_med1.png")
			cshape.set_deferred("shape", preload("res://resources/asteroids_cs/med1.tres"))
			pass
		AsteroidSize.SMALL:
			speed = randf_range(100.0, 200.0)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_tiny1.png")
			cshape.set_deferred("shape", preload("res://resources/asteroids_cs/tiny1.tres"))
			pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	global_position += delta * speed * movement_vector.rotated(rotation)
	
	var screen_size = get_viewport_rect().size
	var shape_size = cshape.shape.radius
	if global_position.y + shape_size < 0:
		global_position.y = screen_size.y+shape_size
	elif global_position.y - shape_size > screen_size.y:
		global_position.y = -shape_size
	
	if global_position.x + shape_size < 0:
		global_position.x = screen_size.x + shape_size
	elif global_position.x - shape_size > screen_size.x:
		global_position.x = -shape_size


func explode():
	emit_signal("exploded", global_position, size, points)
	queue_free()


func _on_body_entered(body):
	if body is Player:
		body.die()
