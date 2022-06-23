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
	var pos_data = playersList.get_position_data(player_id)
	return {
		"id": player_id,
		"position": pos_data.position,
		"flip_x": pos_data.flip_x,
		"gender": player.gender,
		"state": player.state,
		"is_hiding": player.is_hiding,
		"hiding_animation": player.hiding_animation,
		"my_prop_path": player.my_prop_path,
		"parts_data": player.partsData
	}


remote func spawn_player_in_map(player_id, position, flip_x, partsData):
	var player = playersList.get_player(player_id)
	player.partsData = partsData
	playersList.positions_data[player_id] = {
		"position": position,
		"flip_x": flip_x
	}
	
	#если игрок присоединяется на середине игры
	if gameManager != null: rpc_id(player_id, "make_bell_disabled")
	rpc("spawn_puppet", get_player_data(player_id))


remote func get_puppets(player_id):
	for key in playersList.playersData.keys():
		if key == player_id: continue
		var player = playersList.get_player(key)
		rpc_id(player_id, "spawn_puppet", get_player_data(key))


remote func sync_player_movement(dir, is_running, timestamp):
	var player_id = get_tree().get_rpc_sender_id()
	var player_timestamp = playersList.get_player_timestamp(player_id)
	if timestamp > player_timestamp:
		var pos_data = playersList.get_position_data(player_id)
		playersList.set_player_timestamp(player_id, timestamp)
		if dir.x != 0: pos_data.flip_x = dir.x < 0
		timestamp = OS.get_ticks_msec()
		rpc_unreliable("sync_puppet_movement", player_id, dir, is_running, timestamp)


remote func sync_player_position(position, timestamp):
	var player_id = get_tree().get_rpc_sender_id()
	var player_timestamp = playersList.get_player_timestamp(player_id)
	if timestamp > player_timestamp:
		var pos_data = playersList.get_position_data(player_id)
		playersList.set_player_timestamp(player_id, timestamp)
		pos_data.position = position
		timestamp = OS.get_ticks_msec()
		rpc_unreliable("sync_puppet_position", player_id, position, timestamp)


remote func say_message(message):
	rpc("say_message", get_tree().get_rpc_sender_id(), message)


remote func sync_interact(object_path):
	rpc("sync_interact", get_tree().get_rpc_sender_id(), object_path)


remote func sync_state(player_id, new_state):
	var player = playersList.get_player(player_id)
	
	if player.state == PlayerData.states.hide && new_state == PlayerData.states.none:
		if gameManager: gameManager.player_found(player_id)
		
	player.state = new_state
	rpc("sync_state", player_id, new_state)


remote func sync_hiding(hide_on, animation):
	var player_id = get_tree().get_rpc_sender_id()
	var player = playersList.get_player(player_id)
	player.is_hiding = hide_on
	player.hiding_animation = animation
	rpc("sync_hiding", player_id, hide_on, animation)


remote func start_game():
	if gameManager != null: return
	var player_id = get_tree().get_rpc_sender_id()
	gameManager = GameManager.new(self, playersList, player_id)
	if !gameManager.teleport_players(): return
	gameManager.wait_and_start()


remote func save_hide_in_prop(is_hiding, prop_path):
	var player_id = get_tree().get_rpc_sender_id()
	var player = playersList.get_player(player_id)
	player.my_prop_path = prop_path if is_hiding else ""
