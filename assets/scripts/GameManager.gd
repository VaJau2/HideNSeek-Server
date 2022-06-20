class_name GameManager

var network = null
var playersList = null

var searcher_id = null
var hiders_id = []

var start_timer = 3
var wait_timer = 10


func _init(network, playersList, searcher_id):
	self.network = network
	self.playersList = playersList
	self.searcher_id = searcher_id
	start_timer = 3
	wait_timer = 10
	
	for id in playersList.playersData.keys():
		if id == searcher_id: continue
		hiders_id.append(id)


func get_tree(): return network.get_tree()


func teleport_players() -> bool:
	if playersList.get_count() == 1:
		network.chat.send_server_message("Невозможно начать игру: необходимо минимум 2 игрока")
		network.cleanGameManager()
		return false
	
	network.rpc_id(searcher_id, "teleport", -1)
	for i in range(hiders_id.size()):
		network.rpc_id(hiders_id[i], "teleport", i)
	return true


func wait_and_start():
	yield(count_timer(start_timer), "completed")
	
	network.rpc_id(searcher_id, "start_game", true)
	for i in range(hiders_id.size()):
		network.rpc_id(hiders_id[i], "start_game", false)
	
	yield(count_timer(wait_timer), "completed")
	
	network.rpc_id(searcher_id, "stop_waiting")


func count_timer(timer):
	while timer > 0:
		network.rpc("count_timer", timer)
		yield(get_tree().create_timer(1), "timeout")
		timer -= 1
	network.rpc("count_timer", 0)
