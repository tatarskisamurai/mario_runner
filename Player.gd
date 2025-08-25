extends KinematicBody2D

# --- Сигналы ---
signal player_died  # Сигнал, когда игрок умирает
signal startuem     # Уже есть — оставляем
signal health_updated(health)  # 🔥 Для обновления HP-бара

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

# --- Таймер для неуязвимости ---
var invincibility_timer

# 🔫 Оружие (дробовик как дочерний узел)
onready var current_weapon = $Shotgun
onready var gun_point = $Shotgun/GunPoint

# 🎯 Мушка и ввод
var current_weapon_index = 0  # 0 = Shotgun

func _ready():
	# Создаём таймер для неуязвимости
	invincibility_timer = Timer.new()
	invincibility_timer.wait_time = invincibility_duration
	invincibility_timer.one_shot = true
	invincibility_timer.connect("timeout", self, "_on_invincibility_end")
	add_child(invincibility_timer)

	# Инициализация здоровья
	health = max_health
	emit_signal("health_updated", health)

	# Скрываем мышь
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

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

# --- Ввод: переключение оружия и выстрел ---
func _input(event):
	# Переключение оружия (1, 2, 3)
	if event.is_action_pressed("ui_select_weapon_1"):
		current_weapon_index = 0
		print("Оружие: Shotgun")
	elif event.is_action_pressed("ui_select_weapon_2"):
		current_weapon_index = 1
		print("Оружие: Пусто")
	elif event.is_action_pressed("ui_select_weapon_3"):
		current_weapon_index = 2
		print("Оружие: Пусто")

	# Выстрел (только если выбрано оружие)
	if event.is_action_pressed("ui_attack") and current_weapon_index == 0:
		shoot()

# --- ВЫСТРЕЛ ---
func shoot():
	if not current_weapon:
		return

	# Создаём пулю
	var bullet = current_weapon.bullet_scene.instance()
	add_child(bullet)
	bullet.global_position = gun_point.global_position
	var direction = (get_global_mouse_position() - gun_point.global_position).normalized()
	bullet.set_direction(direction, self)  # Я — владелец
	# Направление — к мыши
	var target = get_global_mouse_position()

	# 🔍 Ограничиваем дистанцию
	var distance = bullet.global_position.distance_to(target)
	if distance > current_weapon.shoot_distance:
		var overshoot = (distance - current_weapon.shoot_distance) / distance
		target = target.linear_interpolate(bullet.global_position, overshoot)

	bullet.set_direction((target - bullet.global_position).normalized())

# --- МЕТОД ПОЛУЧЕНИЯ УРОНА ---
func take_damage(amount):
	if is_invincible:
		return  # Игнорируем урон во время неуязвимости

	health -= amount
	print("Игрок получил урон! Осталось: ", health)

	# 🔥 Обновляем UI
	emit_signal("health_updated", health)

	# Включаем неуязвимость
	is_invincible = true
	invincibility_timer.start()

	# Мигание спрайта
	sprite.modulate = Color(1, 0.5, 0.5, 1)  # Красноватый оттенок

	# Если здоровье закончилось
	if health <= 0:
		if has_node("DieSound"):
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
	queue_free()  # Удаляем игрока

# --- ОБРАБОТКА СТОЛКНОВЕНИЙ ---
func _on_Area2D_body_entered(body):
	# Если пуля попала в игрока
	if body.is_in_group("bullet"):
		body.queue_free()  # Удаляем пулю
		take_damage(20)    # Наносим урон
