extends Node


func _ready():
	pass

func _on_AreaDeath_body_entered(body):
	var coll = body.get_collision_layer()
	if coll == 1:
		$FallTimer.start()
		body.get_falled()
		#get_tree().change_scene("res://scenes/prelevel.tscn")
	else:
		body.queue_free()



func _on_FallTimer_timeout():
	get_tree().change_scene("res://scenes/prelevel.tscn")
