extends KinematicBody2D

enum States {FALL, IDLE, WALK, ATTACK}

var velocity = Vector2(0,0)

const MAXSPEED = 150
const GRABBITY = 35

const PLAYER_DETECT_RANGE = 120
const HURTBOX_OFFSET_X = 57
const FEETCHECK_OFFSET_X = 35

const CONTROL_NORMAL = 1.0
const CONTROL_AIR = 0.7
const DECELERATION = 0.06

export var facing = 1
export var strong := false
export var smart := false
var state = States.FALL

func update_facing():
	if facing < 0:
		$Sprite.flip_h = true
	elif facing > 0:
		$Sprite.flip_h = false
	$FeetCheck.position.x = facing * FEETCHECK_OFFSET_X
	$Hurtbox/CollisionShape2D.position.x =  facing * HURTBOX_OFFSET_X
	$PlayerCheck.cast_to.x = facing * PLAYER_DETECT_RANGE


func _ready():
	update_facing()
	if smart:
		$FeetCheck.enabled = true
	else:
		$FeetCheck.enabled = false

func _enter_state(newstate):
	match newstate:
		States.WALK:
			$Sprite.play("walk")
		States.FALL:
			$Sprite.play("idle")
		States.ATTACK:
			$Sprite.play("attack")
			$AttackTimer.start()

func _physics_process(delta):
	var fac = CONTROL_NORMAL
	var next_state = null
	velocity.y += GRABBITY
	match state:
		States.IDLE:
			if is_on_floor():
				next_state = States.WALK
		States.WALK:
			if not is_on_floor():
				next_state = States.FALL
			if is_on_wall():
				facing = -facing
				update_facing()
			if not $FeetCheck.is_colliding() and smart:
				facing = -facing
				update_facing()
			if $PlayerCheck.is_colliding():
				next_state = States.ATTACK
			velocity.x = facing * MAXSPEED
		States.FALL:
			velocity.x = facing * MAXSPEED * CONTROL_AIR
			if is_on_floor():
				next_state = States.WALK
	
	velocity = move_and_slide(velocity, Vector2.UP) if strong else move_and_slide(velocity, Vector2.UP, false, 4, 0.78, false)
	velocity.x = lerp(velocity.x, 0, DECELERATION)
	if next_state != null:
		_enter_state(next_state)
		state = next_state
	


func _on_AttackTimer_timeout():
	velocity.x += MAXSPEED*3*facing
	$Hurtbox.set_collision_mask_bit(0,true)
	$HurtTimer.start()
	
func _on_HurtTimer_timeout():
	$Hurtbox.set_collision_mask_bit(0,false)
	state = States.IDLE

func _on_Hurtbox_body_entered(body):
	if body.get_collision_layer_bit(0):
		body.get_hurt(self)
