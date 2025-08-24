extends KinematicBody2D

# --- Сигналы ---
signal player_died  # Сигнал, когда игрок умирает
signal startuem     # Уже есть — оставляем

# --- Настройки ---
export var speed = 200
export var jump_force = -500
export var gravity = 600
export var max_health = 100
export var invincibility_duration = 1.5  # Время неуязвимости после урона

# --- Переменные ---
var velocity = Vector2.ZERO
var health = max_health
var is_invincible = false

# --- Узлы ---
onready var sprite = $AnimatedSprite
onready var jump_sound = $jump

# --- Таймер для неуязвимости (создадим динамически) ---
var invincibility_timer

func _ready():
	# Создаём таймер для неуязвимости
	invincibility_timer = Timer.new()
	invincibility_timer.wait_time = invincibility_duration
	invincibility_timer.one_shot = true
	invincibility_timer.connect("timeout",self , "_on_invincibility_end")
	add_child(invincibility_timer)

func _process(delta):
	jump_sound.stop()

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
		jump_sound.play()

	# 🔄 ПОВОРОТ СПРАЙТА
	if velocity.x > 0:
		sprite.flip_h = false  # Смотрит вправо
	elif velocity.x < 0:
		sprite.flip_h = true   # Смотрит влево

	# Двигаем
	velocity = move_and_slide(velocity, Vector2.UP)

# --- МЕТОД ПОЛУЧЕНИЯ УРОНА ---
func take_damage(amount):
	if is_invincible:
		return  # Игнорируем урон во время неуязвимости

	health -= amount
	print("Игрок получил урон! Осталось: ", health)

	# Включаем неуязвимость
	is_invincible = true
	invincibility_timer.start()

	# Мигание спрайта
	sprite.modulate = Color(1, 0.5, 0.5, 1)  # Красноватый оттенок
	if has_node("HurtSound"):
		$HurtSound.play()
	# Если здоровье закончилось
	if health <= 0:
		$DieSound.play()
		die()
		

# --- ОКОНЧАНИЕ НЕУЯЗВИМОСТИ ---
func _on_invincibility_end():
	is_invincible = false
	sprite.modulate = Color(1, 1, 1, 1)  # Возвращаем нормальный цвет

# --- СМЕРТЬ ИГРОКА ---
func die():
	print("Игрок погиб!")
	velocity = Vector2.ZERO
	emit_signal("player_died")
	queue_free()  # Удаляем игрока (или можно показать экран смерти)

# --- ОБРАБОТКА СТОЛКНОВЕНИЙ ---
func _on_Area2D_body_entered(body):
	# Если пуля попала в игрока
	if body.is_in_group("bullet"):
		# Пуля должна иметь группу "bullet" (см. ниже)
		body.queue_free()  # Удаляем пулю
		take_damage(20)    # Наносим урон


