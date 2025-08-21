extends Camera2D

# Настройки
export var move_speed = 80  # Скорость движения камеры (не слишком быстро)
export var right_limit = 2000  # Правая граница уровня (установи по размеру карты)

var target_velocity = 0  # Целевая скорость движения камеры
var current_speed = 0    # Текущая скорость (для плавного старта/остановки)
var smooth_time = 0.1    # Время разгона/торможения

# Флаг: разрешено ли камере двигаться?
var can_move_right = false

func _ready():
	# Убедимся, что камера текущая
	make_current()

# Принимаем сигнал от игрока
func _on_Player_startuem():
	can_move_right = true
	print("Камера: разрешено движение вправо")

# В физическом процессе — плавно двигаем камеру
func _physics_process(delta):
	# Если разрешено двигаться — пытаемся ускориться вправо
	var target_speed = 0
	if can_move_right:
		target_speed = move_speed

	# Плавная интерполяция скорости (разгон и торможение)
	current_speed = move_toward(current_speed, target_speed, move_speed * delta)

	# Двигаем камеру
	if current_speed > 0:
		position.x += current_speed * delta

	# Ограничиваем по правой границе
	if right_limit > 0:
		position.x = min(position.x, right_limit)

	# ⚠️ Важно: мы не двигаем камеру назад!
	# Она "догоняет" игрока только вперёд, но не возвращается
