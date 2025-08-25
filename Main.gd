extends Node2D

onready var health_bar = $UI/HealthBar
onready var game_over_label = $UI/GameOverLabel
onready var crosshair = $UI/Crosshair
func _ready():
	var player = $Player
	if player:
		# Подключаем HP
		player.connect("health_updated", self, "_on_player_health_updated")
		# Подключаем смерть
		player.connect("player_died", self, "_on_player_died")
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(1, 0, 0)  # Красный
	$UI/Inventory/Slot1.connect("pressed", self, "select_weapon", [0])
	$UI/Inventory/Slot2.connect("pressed", self, "select_weapon", [1])
	$UI/Inventory/Slot3.connect("pressed", self, "select_weapon", [2])
func select_weapon(index):
	$Player.equip_weapon(index)
func _process(delta):
	crosshair.global_position = get_global_mouse_position()
# Обновляем полосу HP
func _on_player_health_updated(new_health):
	if health_bar:
		health_bar.value = new_health

# Показываем Game Over
func _on_player_died():
	game_over_label.visible = true
