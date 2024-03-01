extends Node2D

var chinese_numbers: PackedStringArray = [
	"零",
	"一",
	"二",
	"三",
	"四",
	"五",
	"六",
	"七",
	"八",
	"九",
	"十"
]
var chinese_place_value: PackedStringArray = [
	"个",
	"十",
	"百",
	"千",
	"万",
	"十万",
	"百万",
	"千万",
	"亿"
]

func _ready():
	print(number_to_chinese_number(101001))

func number_to_chinese_number(number: int):
	var chinese_number: String = ""
	var contains_zero: bool = false
	
	if number < chinese_numbers.size():
		return chinese_numbers[number]
	else:
		var highest_place_value_index: int = str(number).length() - 1
		
		for number_char in str(number):
			if number_char != "0":
				if contains_zero:
					chinese_number += chinese_numbers[0]
					contains_zero = false
				chinese_number += chinese_numbers[int(number_char)]
				if chinese_place_value[highest_place_value_index] != "个":
					chinese_number += chinese_place_value[highest_place_value_index]
			else:
				contains_zero = true
			highest_place_value_index -= 1
		
		return chinese_number
