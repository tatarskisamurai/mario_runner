extends RigidBody2D

var target_position: Vector2
var follow_speed = 200

func _integrate_forces(state):
	# Целевая позиция (например, рядом с игроком)
	var direction = (target_position - state.transform.origin).normalized()
	var distance = (target_position - state.transform.origin).length()

	# Ограничиваем скорость
	var max_speed = min(follow_speed, distance * 5)
	var desired_velocity = direction * max_speed


