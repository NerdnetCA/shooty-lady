extends KinematicBody2D

enum States {IDLE, JUMP, FALL, FLOOR, DYING}

const BULLET = preload("res://scenes/bullet.tscn")

const SPEED = 300
const MAXSPEED = 750
const GRABBITY = 35
const LEGPOWER = 1300
const ACCEL = 0.3

var velocity = Vector2(0,0)
var facing = 1
var state = States.FALL

func check_shoot():
	if Input.is_action_just_pressed("player_shoot"):
		$AnimatedSprite.play("shoot")
		var b = BULLET.instance()
		b.direction = facing
		get_parent().add_child(b)
		b.position.x = position.x
		b.position.y = position.y
		
func motion_apply(factor):
	if Input.is_action_pressed("player_left"):
		velocity.x = lerp(velocity.x, -MAXSPEED, ACCEL * factor)
		facing = -1
	elif Input.is_action_pressed("player_right"):
		velocity.x = lerp(velocity.x, MAXSPEED, ACCEL * factor)
		facing = 1

	update_facing()
	velocity.y += GRABBITY
	velocity = move_and_slide(velocity,Vector2.UP, false, 4, 0.78, false )
	velocity.x = lerp(velocity.x,0,0.15 * factor)

func _physics_process(delta):
	var action_x = 0
	var action_y = 0
	var onfloor = false
	var falling = 0
	
	match state:
		States.FLOOR:
			if not is_on_floor():
				state = States.FALL
				$AnimatedSprite.play("fall")
			elif velocity.x > 40 or velocity.x < -40:
				$AnimatedSprite.play("walk")
			else:
				$AnimatedSprite.play("idle")
			if Input.is_action_just_pressed("player_jump"):
				$AnimatedSprite.play("jump")
				velocity.y = -LEGPOWER
				state = States.JUMP
			check_shoot()
			motion_apply(1.0)
		States.JUMP:
			if velocity.y > 0:
				state = States.FALL
				$AnimatedSprite.play("fall")
			motion_apply(0.4)
		States.FALL:
			if is_on_floor():
				state = States.FLOOR
				$AnimatedSprite.play("idle")
			motion_apply(0.4)
		States.DYING:
			motion_apply(0)

func update_facing():
	if facing < 0:
		$AnimatedSprite.flip_h = true
	elif facing > 0:
		$AnimatedSprite.flip_h = false
		
func get_hurt(enemy):
	$AnimatedSprite.play('fall')
	$AudioHit.play()
	state = States.DYING
	if enemy.position.x > self.position.x:
		velocity.x = -350
	else:
		velocity.x = 350
	velocity.y = -800
	set_collision_mask_bit(2,false)
	set_collision_mask_bit(3,false)

func get_falled():
	$AudioFall.play()
	
