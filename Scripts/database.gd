extends Node

var humanName: String = "Test"
var level: int = 1
var max_health: float = 20.0
var health: float = 3.0
var items: Array[Item] = [
	Item.new("Bing Chilling", 5),
	Item.new("Zen An", 10),
	Item.new("Zen Thye", 15),
	Item.new("Choon Hong", 20),
	Item.new("Benjamin", 25),
	Item.new("Yao Zong", 30),
	Item.new("Bing Chilling", 35),
	Item.new("Bing Chilling", 40)
]

var weapon: String
var armor: String
