extends Node

class_name ServerNetwork

const MAX_PLAYERS = 15

onready var main = get_node("../")
onready var chat = get_node("../chat")

var playersData = {}


func _ready():
	get_tree().connect("network_peer_disconnected", self, "player_disconnected")


func player_connected(id, name):
	var player = PlayerData.new(id, name)
	playersData[id] = player
	update_players_count()
	chat.send_server_message("Игрок {name} присоединился".format({
		"name": name
	}))


func player_disconnected(id):
	var playerName = playersData[id].name
	playersData.erase(id)
	update_players_count()
	chat.send_server_message("Игрок {name} покинул сервер".format({
		"name": playerName
	}))


func update_players_count():
	var players_count = playersData.keys().size()
	var main = get_node("/root/Main")
	main.update_players_count(String(players_count))


func create_server():
	var peer = NetworkedMultiplayerENet.new()
	var port = int(get_node("../port").text)
	if (port <= 0):
		chat.send_server_message("Невозможно запустить сервер: порт введен неверно")
		return
	
	peer.create_server(port, MAX_PLAYERS)
	get_tree().network_peer = peer
	main.show_start_server()


func stop_server(peer = null):
	if peer: peer.close_connection()
	get_tree().network_peer = null
	main.show_stop_server()
