class_name PlayerData

var id: int
var name: String
var gender: String
var is_hiding: bool
var hiding_animation: String
var my_prop_path: String
var partsData: Dictionary

enum states {none, wait, search, hide}
var state = states.none

func _init(_id: int, _name: String, _gender: String):
	self.id = _id
	self.name = _name
	self.gender = _gender
	hiding_animation = ""
	my_prop_path = ""
