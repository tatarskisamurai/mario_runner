extends KinematicBody2D

signal startuem

# Настройки
export var speed = 200
export var jump_force = -500
export var gravity = 600

# Скорость
var velocity = Vector2.ZERO

# Ссылка на спрайт
onready var sprite = $AnimatedSprite  # Убедись, что имя узла — "Sprite"

func _process(delta):
	$jump.stop()

func _physics_process(delta):
	# Применяем гравитацию
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Горизонтальное движение
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		sprite.play()
		emit_signal("startuem")
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		sprite.play()
	else:
		velocity.x = 0
		sprite.stop()

	# Прыжок
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force
		$jump.play()

	# 🔄 ПОВОРОТ СПРАЙТА
	if velocity.x > 0:
		sprite.flip_h = false  # Смотрит вправо
	elif velocity.x < 0:
		sprite.flip_h = true   # Смотрит влево
	# Если стоит (velocity.x == 0) — не меняем направление

	# Двигаем
	velocity = move_and_slide(velocity, Vector2.UP)


