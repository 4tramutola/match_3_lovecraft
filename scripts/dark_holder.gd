extends Node2D

var dark_pieces = []
var width = 6
var height = 8
var dark = preload("res://scenes/dark.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null);
	return array;

func _on_grid_make_dark(board_position):
	if dark_pieces.size() == 0:
		dark_pieces = make_2d_array()
	var current = dark.instantiate()
	add_child(current)
	current.position = Vector2(board_position.x * 64 + 90, -board_position.y * 90 + 864)
	dark_pieces[board_position.x][board_position.y] = current

func _on_grid_damage_dark(board_position):
	if dark_pieces.size() != 0:
		if dark_pieces[board_position.x][board_position.y]	 != null:
			dark_pieces[board_position.x][board_position.y].take_damage(1)
			if dark_pieces[board_position.x][board_position.y].health <= 0:
				dark_pieces[board_position.x][board_position.y].queue_free()  # Correct usage
				dark_pieces[board_position.x][board_position.y] = null  # Clear the reference
