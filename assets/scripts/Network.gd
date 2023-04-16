extends ServerNetwork


@rpc("any_peer") 
func add_player(id, player_name, gender) -> void:
	player_connected(id, player_name, gender)


@rpc("any_peer") 
func add_message_to_chat(player_name, message) -> void:
	if (player_name == null || message == null): return
	chat.text += "[u]{name}[/u]: {text} \n".format({
		"name": player_name, 
		"text": message
	})


@rpc("any_peer") 
func update_chat_text(new_text) -> void:
	chat.text = new_text


@rpc("any_peer") 
func add_message_to_chat_from_user(user_name, message) -> void:
	add_message_to_chat(user_name, message)
	rpc("add_message_to_chat", user_name, message)


func get_player_data(player_id) -> Dictionary:
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


@rpc("any_peer") 
func spawn_player_in_map(player_id, position, flip_x, partsData) -> void:
	var player = playersList.get_player(player_id)
	player.partsData = partsData
	playersList.positions_data[player_id] = {
		"position": position,
		"flip_x": flip_x
	}
	
	#если игрок присоединяется на середине игры
	if gameManager != null: rpc_id(player_id, "make_bell_disabled")
	rpc("spawn_puppet", get_player_data(player_id))


@rpc("any_peer") 
func get_puppets(player_id) -> void:
	for key in playersList.playersData.keys():
		if key == player_id: continue
		rpc_id(player_id, "spawn_puppet", get_player_data(key))


@rpc("any_peer", "unreliable") 
func sync_player_movement(dir, is_running, temp_timestamp) -> void:
	var player_id = multiplayer.get_remote_sender_id()
	var player_timestamp = playersList.get_player_timestamp(player_id)
	if temp_timestamp > player_timestamp:
		var pos_data = playersList.get_position_data(player_id)
		playersList.set_player_timestamp(player_id, temp_timestamp)
		if dir.x != 0: pos_data.flip_x = dir.x < 0
		temp_timestamp = Time.get_ticks_msec()
		rpc("sync_puppet_movement", player_id, dir, is_running, temp_timestamp)


@rpc("any_peer", "unreliable") 
func sync_player_position(position, temp_timestamp) -> void:
	var player_id = multiplayer.get_remote_sender_id()
	var player_timestamp = playersList.get_player_timestamp(player_id)
	if temp_timestamp > player_timestamp:
		var pos_data = playersList.get_position_data(player_id)
		playersList.set_player_timestamp(player_id, temp_timestamp)
		pos_data.position = position
		temp_timestamp = Time.get_ticks_msec()
		rpc("sync_puppet_position", player_id, position, temp_timestamp)


@rpc("any_peer") 
func say_message(message) -> void:
	rpc("say_message", multiplayer.get_remote_sender_id(), message)


@rpc("any_peer") 
func sync_interact(object_path) -> void:
	rpc("sync_interact", multiplayer.get_remote_sender_id(), object_path)


@rpc("any_peer") 
func sync_state(player_id, new_state) -> void:
	var player = playersList.get_player(player_id)
	
	if player.state == PlayerData.states.hide && new_state == PlayerData.states.none:
		if gameManager: gameManager.player_found(player_id)
		
	player.state = new_state
	rpc("sync_state", player_id, new_state)


@rpc("any_peer") 
func sync_hiding(hide_on, animation) -> void:
	var player_id = multiplayer.get_remote_sender_id()
	var player = playersList.get_player(player_id)
	player.is_hiding = hide_on
	player.hiding_animation = animation
	rpc("sync_hiding", player_id, hide_on, animation)


@rpc("any_peer") 
func start_game() -> void:
	if gameManager != null: return
	var player_id = multiplayer.get_remote_sender_id()
	gameManager = GameManager.new(self, playersList, player_id)
	if !gameManager.teleport_players(): return
	gameManager.wait_and_start()


@rpc("any_peer") 
func save_hide_in_prop(is_hiding, prop_path) -> void:
	var player_id = multiplayer.get_remote_sender_id()
	var player = playersList.get_player(player_id)
	player.my_prop_path = prop_path if is_hiding else ""


#функции клиента (без них жодот не хочет их отправлять)
@rpc func force_disconnect(error) -> void: pass
@rpc func spawn_puppet(puppetData) -> void: pass
@rpc func despawn_puppet(id) -> void: pass
@rpc func sync_puppet_movement(player_id, dir, is_running, temp_timestamp) -> void: pass
@rpc func sync_puppet_position(player_id, position, temp_timestamp) -> void: pass
@rpc func teleport(start_point_id) -> void: pass
@rpc func start_searching(hiders_names) -> void: pass
@rpc func player_found(found_id) -> void: pass
@rpc func count_timer(time) -> void: pass
@rpc func game_finished(searcher_name, hiders_names, is_error) -> void: pass
@rpc func make_bell_disabled() -> void: pass
