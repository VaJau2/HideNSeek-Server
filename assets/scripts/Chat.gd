extends RichTextLabel

@onready var network = get_node("../Network")
@onready var input = get_node("../chatInput")


func send_server_message(message):
	var server_name = "Сервер"
	network.add_message_to_chat(server_name, message)
	if (network.peer != null):
		network.rpc("add_message_to_chat", server_name, message)


func sync_clear():
	network.update_chat_text("")
	if (network.peer != null):
		network.rpc("update_chat_text", "")


func _on_send_pressed():
	if (input.text.is_empty()): 
		return
	send_server_message(input.text)
	input.text = ""


func _on_chat_input_text_submitted(new_text):
	send_server_message(new_text)
	input.text = ""
