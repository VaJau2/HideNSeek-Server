extends ServerNetwork


func kick_player(id):
	rpc_id(id, "force_disconnect")


remote func add_player(id, name):
	player_connected(id, name)


remote func add_message_to_chat(name, message):
	if (name == null || message == null): return
	chat.bbcode_text += "[u]{name}[/u]: {text} \n".format({
		"name": name, 
		"text": message
	})


remote func update_chat_text(new_text):
	chat.bbcode_text = new_text


remote func spawn_player_in_map(player_id, position, partsData):
	var player = playersList.get_player(player_id)
	player.position = position
	player.partsData = partsData
	rpc("spawn_puppet", player_id, position, partsData)


remote func get_puppets(player_id):
	for key in playersList.playersData.keys():
		if key == player_id: continue
		var player = playersList.get_player(key)
		rpc("spawn_puppet", key, player.position, player.partsData)


remote func sync_player_movement(data):
	var player = playersList.get_player(data.player_id)
	if data.timestamp > player.timestamp:
		player.timestamp = data.timestamp
		data.timestamp = OS.get_ticks_msec()
		rpc_unreliable("sync_puppet_movement", data)


remote func sync_player_position(data):
	var player = playersList.get_player(data.player_id)
	if data.timestamp > player.timestamp:
		player.timestamp = data.timestamp
		data.timestamp = OS.get_ticks_msec()
		playersList.get_player(data.player_id).position = data.position
		rpc_unreliable("sync_puppet_position", data)
