extends KinematicBody2D

export var speed = 300
var direction = Vector2.RIGHT
var bullet_owner = null
var is_initialized = false  # Флаг: пуля готова к столкновениям

func _ready():
	print("🔴 Пуля: создана, направление: ", direction)
	# Не начинаем движение сразу

func _physics_process(delta):
	var velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.collider
		# Игнорируем владельца, ТОЛЬКО если инициализирована
		if is_initialized and collider == bullet_owner:
			return
		if collider.has_method("take_damage"):
			collider.take_damage(10)
		print("💥 Пуля столкнулась с: ", collider.name)
		queue_free()

func set_direction(dir, owner_node = null):
	direction = dir
	bullet_owner = owner_node
	is_initialized = true  # Только после этого проверяем владельца
	print("🎯 set_direction() вызван: ", direction)
