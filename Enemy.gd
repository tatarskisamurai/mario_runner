# enemy.gd — стреляет в сторону игрока (любое направление)
extends KinematicBody2D

export var detection_radius = 300
export var shoot_interval = 1.5
export (PackedScene) var bullet_scene

onready var detection_area = $DetectionArea
onready var shoot_timer = $ShootTimer
onready var shoot_point = $ShootPoint
onready var sprite = $Sprite

var player_in_range = false
var player = null

func _ready():
	print("🎯 Враг: _ready() запущен")
	print("Путь к bullet_scene: ", bullet_scene)

	if bullet_scene == null:
		print("❌ bullet_scene = null! Загрузи Bullet.tscn в инспекторе!")
		return

	var collision_shape = detection_area.get_node("CollisionShape2D")
	if collision_shape:
		collision_shape.shape.radius = detection_radius
		print("✅ Радиус обнаружения установлен: ", detection_radius)
	else:
		printerr("❌ CollisionShape2D не найден в DetectionArea!")

	detection_area.connect("body_entered", self, "_on_detection_area_body_entered")
	detection_area.connect("body_exited", self, "_on_detection_area_body_exited")
	shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout")


func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		player_in_range = true
		shoot_timer.start()
		print("✅ Игрок вошёл в зону: ", player.name)


func _on_detection_area_body_exited(body):
	if body == player:
		player_in_range = false
		shoot_timer.stop()
		player = null
		print("❌ Игрок вышел из зоны")


func _on_shoot_timer_timeout():
	print("⏰ Таймер сработал!")
	if not (player_in_range and player != null and bullet_scene):
		print("❌ Условие для стрельбы не выполнено")
		return

	# Вектор от врага к игроку
	var to_player = player.global_position - global_position

	if to_player.length() == 0:
		print("❌ Игрок в той же точке — пропускаем")
		return

	# Нормализованное направление
	var direction = to_player.normalized()
	print("➡️ Направление: ", direction)

	# Поворачиваем спрайт (если нужно): флипаем только по X
	if direction.x > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

	# Смещение точки выстрела (в направлении стрельбы)
	var shoot_offset = 60
	shoot_point.position = direction * shoot_offset

	# Создаём пулю
	var bullet = bullet_scene.instance()
	if bullet == null:
		print("❌ Пуля не создалась! Проверь Bullet.tscn")
		return

	add_child(bullet)
	bullet.global_position = shoot_point.global_position
	print("✅ Пуля создана")
	print("🎯 Позиция пули: ", bullet.global_position)

	# Передаём направление и владельца
	if bullet.has_method("set_direction"):
		bullet.set_direction(direction, self)
		print("✅ set_direction() вызван")
	else:
		print("❌ У пули нет метода set_direction()")
		print("Тип: ", bullet.get_class())
		print("Скрипт: ", bullet.get_script())
