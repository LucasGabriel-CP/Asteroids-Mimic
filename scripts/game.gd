extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var player_respawn_pos = $PlayerRespawn
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_respawn_area = $PlayerRespawn/PlayerSpawnArea
@onready var spawn_timer = $Timer
@onready var global_vars = get_node('/root/GlobalVars')

var asteroid_scene = preload("res://Scenes/asteroid.tscn")
var side := 0

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives = 3:
	set(value):
		lives = value
		hud.init_lives(lives)

# Called when the node enters the scene tree for the first time.
func _ready():
	game_over_screen.visible = false
	score = 0
	lives = 3
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("reset"):
		get_tree().reload_current_scene()

func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)

func _on_asteroid_exploded(pos, size, points):
	score += points
	$AsteroidHit.play()
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass

func spawn_asteroid(pos, size):
	var asteroid = asteroid_scene.instantiate()
	asteroid.global_position = pos
	asteroid.size = size
	asteroid.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", asteroid)

func _on_player_died():
	player.global_position = player_respawn_pos.global_position
	lives -= 1
	if !lives:
		$LoseSound.play()
		await get_tree().create_timer(2).timeout
		global_vars.highscore = score
		game_over_screen.highscore = global_vars.highscore
		game_over_screen.visible = true
	else:
		$LiveSound.play()
		await get_tree().create_timer(1).timeout
		while !player_respawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_respawn_pos.global_position)


func _on_timer_timeout():
	match side:
		0:
			spawn_asteroid(Vector2(randf_range(1.0, 1280.0), -30.0), Asteroid.AsteroidSize.LARGE)
		1:
			spawn_asteroid(Vector2(randf_range(1.0, 1280.0), 800.0), Asteroid.AsteroidSize.LARGE)
		2:
			spawn_asteroid(Vector2(-30.0, randf_range(1.0, 720.0)), Asteroid.AsteroidSize.LARGE)
		3:
			spawn_asteroid(Vector2(1380.0, randf_range(1.0, 720.0)), Asteroid.AsteroidSize.LARGE)
	side = (side + 1) % 4
	spawn_timer.set_wait_time(max(1, 10 * (1 - ((min(9000.0, score))/10000.0))))
