# enemy.gd (отладочная версия)
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
	if player_in_range and player != null and bullet_scene:
		var bullet = bullet_scene.instance()
		if bullet == null:
			print("❌ Пуля не создалась! Проверь Bullet.tscn")
			return
		print("✅ Пуля создана")

		add_child(bullet)
		bullet.global_position = shoot_point.global_position
		print("🎯 Позиция пули: ", bullet.global_position)

		var direction = (player.global_position - shoot_point.global_position).normalized()
		print("➡️ Направление: ", direction)

		if bullet.has_method("set_direction"):
			bullet.set_direction(direction)
			print("✅ set_direction() вызван")
		else:
			print("❌ У пули нет метода set_direction()")
			print("Тип: ", bullet.get_class())
			print("Скрипт: ", bullet.get_script())

		if direction.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	else:
		print("❌ Условие для стрельбы не выполнено")
