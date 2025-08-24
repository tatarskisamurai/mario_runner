extends KinematicBody2D

signal startuem

# Настройки
export var speed = 200
export var jump_force = -500
export var gravity = 1200  # ✅ Правильная гравитация для KinematicBody

# Внутренние переменные
var velocity = Vector2.ZERO
var can_jump = true

# Ссылки на узлы
var sprite
var jump_sfx

func _ready():
	sprite = $AnimatedSprite
	jump_sfx = $jump
	jump_sfx.stop()

func _physics_process(delta):
	# Гравитация
	velocity.y += gravity * delta
	
	# Движение влево/вправо
	var input_x = 0
	if Input.is_action_pressed("ui_right"):
		input_x = 1
	elif Input.is_action_pressed("ui_left"):
		input_x = -1
	
	velocity.x = input_x * speed
	
	# Прыжок
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force
		jump_sfx.play()
	
	# Применяем движение
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Анимация
	if input_x != 0:
		sprite.flip_h = input_x < 0
		if not sprite.is_playing():
			sprite.play()
			emit_signal("startuem")
	else:
		sprite.stop()

func _on_RigidBody2D_popka():
	print('popka')
	speed = 5
