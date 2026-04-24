extends Node

@export var mob_scene: PackedScene
var score

# ===== НАСТРОЙКИ СЛОЖНОСТИ =====
var текущая_сложность: String = "Normal"

var настройки_сложности = {
	"Easy": {
		"мин_скорость": 80.0,
		"макс_скорость": 110.0,
		"интервал_появления": 1.2
	},
	"Normal": {
		"мин_скорость": 150.0,
		"макс_скорость": 250.0,
		"интервал_появления": 0.8
	},
	"Hard": {
		"мин_скорость": 500.0,
		"макс_скорость": 550.0,
		"интервал_появления": 0.2
	}
}
# ===== КОНЕЦ НАСТРОЕК =====

func new_game():
	score = 0
	$Player.start($PlayerStartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

func game_over():
	get_tree().call_group("mobs", "queue_free")
	$HUD.show_game_over()
	
	$ScoreTimer.stop()
	$MobTimer.stop()
	
	$Music.stop()
	$GameOver.play()

func _ready():
	# Подключаем сигнал из HUD (когда игрок выбрал сложность)
	$HUD.сложность_изменена.connect(_on_сложность_изменена)
	
	# Подключаем сигнал из HUD (когда игрок нажал кнопку Start)
	$HUD.start_game.connect(_on_start_game)

func _on_start_game():
	new_game()

func _on_сложность_изменена(сложность: String):
	текущая_сложность = сложность
	применить_настройки_сложности()

func применить_настройки_сложности():
	var настройки = настройки_сложности[текущая_сложность]
	$MobTimer.wait_time = настройки["интервал_появления"]
	
	# Выводим в консоль для проверки (можно удалить потом)
	print("Сложность: ", текущая_сложность)
	print("Скорость врагов: ", настройки["мин_скорость"], "-", настройки["макс_скорость"])
	print("Интервал появления: ", настройки["интервал_появления"], " сек")

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	# Применяем настройки сложности перед запуском таймеров
	применить_настройки_сложности()
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	
	# Set the mob's direction perpendicular to the path direction. aka add 90degrees
	var direction = mob_spawn_location.rotation + PI / 2
	mob.position = mob_spawn_location.position
	
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	# ===== ИЗМЕНЁННЫЙ КОД: скорость зависит от сложности =====
	var настройки = настройки_сложности[текущая_сложность]
	var мин_скорость = настройки["мин_скорость"]
	var макс_скорость = настройки["макс_скорость"]
	
	var velocity = Vector2(randf_range(мин_скорость, макс_скорость), 0.0)
	# ===== КОНЕЦ ИЗМЕНЕНИЙ =====
	
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)
