extends KinematicBody2D

# Настройки
export var speed = 200
export var jump_force = -400
export var gravity = 800

# Скорость
var velocity = Vector2.ZERO

# Ссылка на спрайт
onready var sprite = $AnimatedSprite  # Убедись, что имя узла — "Sprite"



func _physics_process(delta):
	# Применяем гравитацию
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Горизонтальное движение
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	else:
		velocity.x = 0

	# Прыжок
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force

	# 🔄 ПОВОРОТ СПРАЙТА
	if velocity.x > 0:
		sprite.flip_h = false  # Смотрит вправо
	elif velocity.x < 0:
		sprite.flip_h = true   # Смотрит влево
	# Если стоит (velocity.x == 0) — не меняем направление

	# Двигаем
	velocity = move_and_slide(velocity, Vector2.UP)


