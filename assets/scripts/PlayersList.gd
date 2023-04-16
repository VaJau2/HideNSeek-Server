extends OptionButton


var playersData = {}
var positions_data = {} #ключи - pos, flip_x
var timestamps = {}


func add_player(id: int, playerData: PlayerData) -> void:
	playersData[id] = playerData
	add_item(playerData.name, id)


func remove_player(id: int) -> void:
	playersData.erase(id)
	var idx = get_item_index(id)
	remove_item(idx)
	if (get_count() == 0):
		clear()


func get_count() -> int:
	return playersData.size()


func get_player(id: int) -> PlayerData:
	if (playersData.has(id)):
		return playersData[id]
	return null


func get_position_data(id: int) -> Dictionary:
	if positions_data.has(id):
		return positions_data[id]
	return {}


func get_player_timestamp(id: int) -> int:
	if timestamps.has(id): return timestamps[id]
	return 0


func set_player_timestamp(id: int, timestamp: int) -> void:
	timestamps[id] = timestamp


func get_selected_player() -> PlayerData:
	if get_selected_id() > 0:
		return playersData[get_selected_id()]
	else:
		return null


func clear_players() -> void:
	playersData = {}
	clear()
