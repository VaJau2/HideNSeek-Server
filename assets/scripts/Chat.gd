extends RichTextLabel


func send_server_message(message):
	var name = "Сервер"
	var data = {"name": name, "text": message}
	append_data(data)
	if (get_tree().network_peer):
		rpc("append_data", data)


func clear():
	update_text("")
	if (get_tree().network_peer):
		rpc("update_text", "")


remote func append_data(data):
	if (data.name == null || data.text == null): 
		return
	
	bbcode_text += "[u]{name}[/u]: {text} \n".format({"name": data.name, "text": data.text})


remote func update_text(new_text):
	bbcode_text = new_text


func _on_send_pressed():
	var label = get_node("../chatInput")
	if (label.text.empty()): 
		return
	send_server_message(label.text)
	label.text = ""
