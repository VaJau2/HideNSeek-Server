extends ServerNetwork


remote func add_player(id, name, gender):
	player_connected(id, name, gender)


remote func add_message_to_chat(name, message):
	if (name == null || message == null): return
	chat.bbcode_text += "[u]{name}[/u]: {text} \n".format({
		"name": name, 
		"text": message
	})


remote func update_chat_text(new_text):
	chat.bbcode_text = new_text


remote func add_message_to_chat_from_user(name, message):
	add_message_to_chat(name, message)
	rpc("add_message_to_chat", name, message)


func get_player_data(player_id):
	var player = playersList.get_player(player_id)
	return {
		"id": player_id,
		"position": player.position,
		"flip_x": player.flip_x,
		"gender": player.gender,
		"state": player.state,
		"is_hiding": player.is_hiding,
		"hiding_animation": player.hiding_animation,
		"my_prop_path": player.my_prop_path,
		"parts_data": player.partsData
	}


remote func spawn_player_in_map(player_id, position, flip_x, partsData):
	var player = playersList.get_player(player_id)
	player.position = position
	player.flip_x = flip_x
	player.partsData = partsData
	
	#если игрок присоединяется на середине игры
	if gameManager != null: rpc_id(player_id, "make_bell_disabled")
	
	rpc("spawn_puppet", get_player_data(player_id))


remote func get_puppets(player_id):
	for key in playersList.playersData.keys():
		if key == player_id: continue
		var player = playersList.get_player(key)
		rpc_id(player_id, "spawn_puppet", get_player_data(key))


remote func sync_player_movement(data):
	var player = playersList.get_player(data.player_id)
	if data.timestamp > player.timestamp:
		player.timestamp = data.timestamp
		player.flip_x = data.flip_x
		data.timestamp = OS.get_ticks_msec()
		rpc_unreliable("sync_puppet_movement", data)


remote func sync_player_position(data):
	var player = playersList.get_player(data.player_id)
	if data.timestamp > player.timestamp:
		player.timestamp = data.timestamp
		player.position = data.position
		data.timestamp = OS.get_ticks_msec()
		rpc_unreliable("sync_puppet_position", data)


remote func say_message(player_id, message):
	rpc("say_message", player_id, message)


remote func sync_interact(player_id, object_path):
	rpc("sync_interact", player_id, object_path)


remote func sync_state(player_id, new_state):
	var player = playersList.get_player(player_id)
	
	if player.state == PlayerData.states.hide && new_state == PlayerData.states.none:
		if gameManager: gameManager.player_found(player_id)
		
	player.state = new_state
	rpc("sync_state", player_id, new_state)


remote func sync_hiding(player_id, hide_on, animation):
	var player = playersList.get_player(player_id)
	player.is_hiding = hide_on
	player.hiding_animation = animation
	rpc("sync_hiding", player_id, hide_on, animation)


remote func start_game(player_id):
	if gameManager != null: return
	gameManager = GameManager.new(self, playersList, player_id)
	if !gameManager.teleport_players(): return
	gameManager.wait_and_start()


remote func save_hide_in_prop(player_id, is_hiding, prop_path):
	var player = playersList.get_player(player_id)
	player.my_prop_path = prop_path if is_hiding else ""
