extends Node2D

signal remove_corrupt

var corrupt_pieces = []
var width = 6
var height = 8
var corrupt = preload("res://scenes/corrupt.tscn")

# Called when the node enters the scene tree for the first corrupt.
func _ready():
	pass
	
func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null);
	return array;

func _on_grid_make_corrupt(board_position):
	if corrupt_pieces.size() == 0:
		corrupt_pieces = make_2d_array()
	var current = corrupt.instantiate()
	add_child(current)
	current.position = Vector2(board_position.x * 90 + 64, -board_position.y * 90 + 864)
	corrupt_pieces[board_position.x][board_position.y] = current

func _on_grid_damage_corrupt(board_position):
	if corrupt_pieces.size() != 0:
		if board_position.x < width and board_position.y < height:
			if corrupt_pieces[board_position.x][board_position.y] != null:
				corrupt_pieces[board_position.x][board_position.y].take_damage(1)
				if corrupt_pieces[board_position.x][board_position.y].health <= 0:
					corrupt_pieces[board_position.x][board_position.y].queue_free()  # Correct usage
					corrupt_pieces[board_position.x][board_position.y] = null  # Clear the reference
					emit_signal("remove_corrupt", board_position)
