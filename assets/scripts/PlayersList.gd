extends OptionButton


var playersData = {}


func add_player(id: int, playerData: PlayerData):
	playersData[id] = playerData
	add_item(playerData.name, id)


func remove_player(id: int):
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


func get_selected_player() -> PlayerData:
	if get_selected_id() > 0:
		return playersData[get_selected_id()]
	else:
		return null


func clear_players():
	playersData = {}
	clear()
