extends Control

const MAX_PLAYERS = 15

var playersData = {}

onready var chat = get_node("chat")

#labels
onready var status = get_node("status")
onready var playersCount = get_node("playersCount")
onready var playersList = get_node("playersList")

#buttons
onready var startButton = get_node("start")


func _ready():
	get_tree().connect("network_peer_connected", self, "player_connected")
	get_tree().connect("network_peer_disconnected", self, "player_disconnected")


func set_player_name(id, name):
	playersData[id] = name
	print(playersData)


func player_connected(_id):
	chat.send_server_message("Игрок присоединился")


func player_disconnected(_id):
	chat.send_server_message("Игрок покинул сервер")


func update_server_status():
	var peer = get_tree().network_peer
	if peer is NetworkedMultiplayerENet: 
		stop_server(peer)
	else:
		create_server()


func create_server():
	var peer = NetworkedMultiplayerENet.new()
	var port = int($port.text)
	if (port <= 0):
		chat.send_server_message("Невозможно запустить сервер: порт введен неверно")
		return
	
	chat.clear()
	peer.create_server(port, MAX_PLAYERS)
	get_tree().network_peer = peer
	startButton.text = "Остановить сервер"
	status.text = "запущен"
	chat.send_server_message("Сервер успешно запущен")


func stop_server(peer = null):
	if peer: peer.close_connection()
	get_tree().network_peer = null
	startButton.text = "Запустить сервер"
	status.text = "не запущен"
	chat.send_server_message("Сервер остановлен")
