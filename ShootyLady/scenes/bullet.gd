extends KinematicBody2D

var velocity = Vector2()
var direction = 1

const MYSPEED = 1200

func _ready():
	velocity.x = MYSPEED * direction

func _physics_process(delta):
	var collision = move_and_collide(velocity*delta)
	if collision:
		print("bang")
		queue_free()

func _on_Timer_timeout():
	queue_free()

func done():
	queue_free()
