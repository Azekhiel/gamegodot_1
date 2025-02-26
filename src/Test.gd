extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dicktionary = {"Penis":true,"Balls":"Wide"}

var jj = 0
var test_icle = 5
# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug(dicktionary)
	pass # Replace with function body.
	while jj < test_icle or jj < 10:
		jj += 1
		test_icle += 1
		if jj >8:
			break
		print_debug(jj)




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
