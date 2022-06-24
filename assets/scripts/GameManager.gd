class_name GameManager

const START_TIME = 3
const WAIT_TIME = 10
const GAME_TIME = 70

var network = null
var playersList = null

var searcher_id = null
var hiders_id = []

var temp_timer = 0
var is_error = false


func _init(network, playersList, searcher_id):
	self.network = network
	self.playersList = playersList
	self.searcher_id = searcher_id
	self.is_error = false
	
	for id in playersList.playersData.keys():
		if id == searcher_id: continue
		hiders_id.append(id)


func get_tree(): return network.get_tree()


func teleport_players() -> bool:
	if playersList.get_count() == 1:
		network.chat.send_server_message("Невозможно начать игру: необходимо минимум 2 игрока")
		network.clean_game_manager()
		return false
	
	network.rpc_id(searcher_id, "teleport", -1)
	for i in range(hiders_id.size()):
		network.rpc_id(hiders_id[i], "teleport", i)
	return true


func wait_and_start():
	#несколько секунд, чтобы игроки изучили друг друга
	yield(count_timer(START_TIME), "completed")
	if check_errors(): return
	
	#ищущий закрывает глаза, прячущиеся разбегаются
	network.rpc_id(searcher_id, "start_game", true)
	var hiders_names = {}
	for i in range(hiders_id.size()):
		network.rpc_id(hiders_id[i], "start_game", false)
		var temp_hider = playersList.get_player(hiders_id[i])
		hiders_names[hiders_id[i]] = temp_hider.name
	
	yield(count_timer(WAIT_TIME), "completed")
	if check_errors(): return
	
	#ищущий открывает глаза и начинает искать
	network.rpc_id(searcher_id, "start_searching", hiders_names)
	for i in range(hiders_id.size()):
		network.rpc_id(hiders_id[i], "start_searching", false)
	
	var main_game_time = GAME_TIME - (hiders_id.size() * 10)
	if main_game_time < 10: main_game_time = 10
	yield(count_timer(main_game_time), "completed")
	if check_errors(): return
	
	#игра заканчивается
	var searcher_name = playersList.get_player(searcher_id).name
	hiders_names = []
	for i in range(hiders_id.size()):
		var temp_hider = playersList.get_player(hiders_id[i])
		hiders_names.append(temp_hider.name)
	network.rpc("game_finished", searcher_name, hiders_names, is_error)
	network.clean_game_manager()


func check_errors() -> bool:
	if is_error:
		network.rpc("game_finished", "", [], is_error)
		network.clean_game_manager()
		return true
	return false


func count_timer(wait_time):
	temp_timer = wait_time
	while temp_timer > 0:
		network.rpc("count_timer", temp_timer)
		yield(get_tree().create_timer(1), "timeout")
		temp_timer -= 1
	network.rpc("count_timer", 0)


func player_found(player_id):
	if hiders_id.has(player_id):
		hiders_id.erase(player_id)
		temp_timer += 10
		network.rpc("player_found", player_id)
	
	if hiders_id.size() == 0:
		temp_timer = 0


func player_leave(player_id):
	if player_id == searcher_id:
		is_error = true
		temp_timer = 0
		return
	
	if hiders_id.has(player_id):
		hiders_id.erase(player_id)
		network.rpc("player_found", player_id)
	
	if hiders_id.size() == 0:
		temp_timer = 0
		is_error = true
