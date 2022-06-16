class_name PlayerData

var id: int
var timestamp: int
var name: String
var position: Vector2

func _init(id: int, name: String):
	self.id = id
	self.name = name
	position = Vector2.ZERO
	timestamp = 0
