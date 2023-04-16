extends Node

class_name ServerNetwork

const MAX_PLAYERS = 11

@onready var main = get_node("../")
@onready var chat = get_node("../chat")
@onready var playersList = get_node("../playersList")

var peer
var timestamp = 0
var gameManager = null


func _ready() -> void:
	multiplayer.peer_disconnected.connect(self.player_disconnected)


func kick_player(id) -> void:
	rpc_id(id, "force_disconnect", "Вы были отключены от сервера")


func player_connected(id, player_name, gender) -> void:
	var player = PlayerData.new(id, player_name, gender)
	playersList.add_player(id, player)
	update_players_count()
	chat.send_server_message("Игрок {name} присоединился".format({
		"name": player_name
	}))


func player_disconnected(id) -> void:
	var playerName = playersList.get_player(id).name
	playersList.remove_player(id)
	update_players_count()
	rpc("despawn_puppet", id)
	if gameManager: gameManager.player_leave(id)
	chat.send_server_message("Игрок {name} покинул сервер".format({
		"name": playerName
	}))


func update_players_count() -> void:
	var players_count = playersList.get_count()
	var tempMain = get_node("/root/Main")
	tempMain.update_players_count(str(players_count))


func create_server() -> void:
	peer = ENetMultiplayerPeer.new()
	var port = int(get_node("../port").text)
	if (port <= 0):
		chat.send_server_message("Невозможно запустить сервер: порт введен неверно")
		return
	
	peer.create_server(port, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	main.show_start_server()


func stop_server() -> void:
	if peer: peer.close()
	peer = null
	main.show_stop_server()
	clean_game_manager()


func clean_game_manager() -> void:
	gameManager = null
