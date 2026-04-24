extends CanvasLayer

signal сложность_изменена(сложность: String)
signal start_game

func _ready():
	$LevelButton.item_selected.connect(_on_сложность_выбрана)
	$MessageTimer.timeout.connect(_on_MessageTimer_timeout)  # ← ДОБАВИТЬ ЭТУ СТРОКУ

func _on_сложность_выбрана(индекс: int):
	var имя_сложности = ""
	match индекс:
		0:
			имя_сложности = "Easy"
		1:
			имя_сложности = "Normal"
		2:
			имя_сложности = "Hard"
	сложность_изменена.emit(имя_сложности)

func show_message(текст: String):
	$Message.text = текст
	$Message.show()
	$MessageTimer.start()  # Запускаем таймер

func _on_MessageTimer_timeout():
	$Message.hide()  # Скрываем надпись, когда таймер сработал

func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$StartButton.show()
	$LevelButton.show()

func update_score(счет: int):
	$ScoreLabel.text = str(счет)

func _on_start_button_pressed():
	$StartButton.hide()
	$LevelButton.hide()
	start_game.emit()
