extends CharacterBody3D
class_name enemy

var health = 30

func damage(hurt):
	health -= hurt
	
func _physics_process(delta: float) -> void:
	if health <= 0:
		queue_free()
