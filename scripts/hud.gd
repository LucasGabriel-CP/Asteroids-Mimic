extends Control

@onready var score = $Score:
	set(value):
		score.text = "SCORE: " + str(value)

@onready var lives = $Lives

var uilife_scene = preload("res://Scenes/ui_life.tscn")

func init_lives(amount):
	for ul in lives.get_children():
		ul.queue_free()

	for i in amount:
		var ul = uilife_scene.instantiate()
		lives.add_child(ul)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
