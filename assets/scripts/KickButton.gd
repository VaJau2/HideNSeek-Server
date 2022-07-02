extends Button


func on_pressed():
	var players_list = get_node("../playersList")
	var player_data = players_list.get_selected_player()
	players_list.text = ""
	if player_data:
		get_node("/root/Main/Network").kick_player(player_data.id)
	
