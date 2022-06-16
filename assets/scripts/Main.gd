extends Control

onready var chat = get_node("chat")
onready var network = get_node("Network")

#labels
onready var status = get_node("status")
onready var playersCount = get_node("playersCount")
onready var playersList = get_node("playersList")

#buttons
onready var startButton = get_node("start")


func show_start_server():
	startButton.text = "Остановить сервер"
	status.text = "запущен"
	chat.clear()
	chat.send_server_message("Сервер успешно запущен")


func show_stop_server():
	startButton.text = "Запустить сервер"
	status.text = "не запущен"
	chat.send_server_message("Сервер остановлен")


func update_server_status():
	var peer = get_tree().network_peer
	if peer is NetworkedMultiplayerENet: 
		network.stop_server(peer)
		playersList.clear_players()
	else:
		network.create_server()


func update_players_count(count):
	$playersCount.text = count
