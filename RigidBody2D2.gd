extends RigidBody2D

signal startuem

# Настройки
export var speed = 200
export var jump_force = -500
export var gravity = 3  # ✅ Оставляем как есть

# Внутренние переменные
var can_jump = true

# Ссылки на узлы
var sprite
var jump_sfx
var raycast

func _ready():
	sprite = $AnimatedSprite
	jump_sfx = $jump
	raycast = $RayCast2D
	jump_sfx.stop()
	rotation = 0  # ✅ Правильно: угол в ноль

func _integrate_forces(state):
	# ✅ Исправляем: используем ТВОЮ переменную gravity
	state.linear_velocity.y += gravity * 400 * state.get_step()

	# Движение
	var input_x = 0
	if Input.is_action_pressed("ui_right"):
		input_x = 1
	elif Input.is_action_pressed("ui_left"):
		input_x = -1
	state.linear_velocity.x = input_x * speed

	# Спрайт
	if input_x > 0:
		sprite.flip_h = false
		if not sprite.is_playing():
			sprite.play()
			emit_signal("startuem")
	elif input_x < 0:
		sprite.flip_h = true
		if not sprite.is_playing():
			sprite.play()
			emit_signal("startuem")
	else:
		sprite.stop()

	# Прыжок — теперь РАБОТАЕТ
	if Input.is_action_just_pressed("ui_up"):
		print('ye')
		state.linear_velocity.y = jump_force
		can_jump = false
		jump_sfx.play()
		can_jump = true  # ✅ Восстанавливаем
	else:
		jump_sfx.stop()
	# Защита от вращения
	state.angular_velocity = 0
	if rotation != 0:
		rotation = 0




func _on_RigidBody2D_popka():
	print('popka')
	speed = 5
