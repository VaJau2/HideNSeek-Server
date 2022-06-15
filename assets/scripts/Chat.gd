extends RichTextLabel

onready var network = get_node("../Network")


func send_server_message(message):
	var name = "Сервер"
	network.add_message_to_chat(name, message)
	if (get_tree().network_peer):
		network.rpc("add_message_to_chat", name, message)


func clear():
	network.update_chat_text("")
	if (get_tree().network_peer):
		network.rpc("update_chat_text", "")


func _on_send_pressed():
	var label = get_node("../chatInput")
	if (label.text.empty()): 
		return
	send_server_message(label.text)
	label.text = ""
