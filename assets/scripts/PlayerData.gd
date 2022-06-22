class_name PlayerData

var id: int
var timestamp: int
var name: String
var gender: String
var position: Vector2
var flip_x: bool
var is_hiding: bool
var hiding_animation: String
var my_prop_path: String
var partsData: Dictionary

enum states {none, wait, search, hide}
var state = states.none

func _init(id: int, name: String, gender: String):
	self.id = id
	self.name = name
	self.gender = gender
	position = Vector2.ZERO
	timestamp = 0
	hiding_animation = ""
	my_prop_path = ""
