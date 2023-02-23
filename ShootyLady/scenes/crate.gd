extends RigidBody2D


func _ready():
	pass


func _on_Crate_body_entered(body):
	if body.get_collision_layer() & 2 == 2:
		body.done()
