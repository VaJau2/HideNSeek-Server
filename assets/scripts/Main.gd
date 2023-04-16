extends Control

@onready var chat = get_node("chat")
@onready var network = get_node("Network")
@onready var settingsBack = get_node("settingsBack")

#labels
@onready var status = get_node("status")
@onready var playersCount = get_node("playersCount")
@onready var playersList = get_node("playersList")

#buttons
@onready var startButton = get_node("start")


func show_start_server() -> void:
	startButton.text = "Остановить сервер"
	status.text = "запущен"
	chat.sync_clear()
	chat.send_server_message("Сервер успешно запущен")


func show_stop_server() -> void:
	startButton.text = "Запустить сервер"
	status.text = "не запущен"
	chat.send_server_message("Сервер остановлен")


func update_server_status() -> void:
	if network.peer is ENetMultiplayerPeer: 
		network.stop_server()
		playersList.clear_players()
	else:
		network.create_server()


func update_players_count(count) -> void:
	$playersCount.text = count


func _on_settings_pressed() -> void:
	settingsBack.visible = !settingsBack.visible
