extends Node2D

signal remove_stone

var stone_pieces = []
var width = 6
var height = 8
var stone = preload("res://scenes/stone.tscn")

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

func _on_grid_make_stone(board_position):
	if stone_pieces.size() == 0:
		stone_pieces = make_2d_array()
	var current = stone.instantiate()
	add_child(current)
	current.position = Vector2(board_position.x * 90 + 64, -board_position.y * 90 + 864)
	stone_pieces[board_position.x][board_position.y] = current

func _on_grid_damage_stone(board_position):
	if stone_pieces.size() != 0:
		if stone_pieces[board_position.x][board_position.y]	 != null:
			stone_pieces[board_position.x][board_position.y].take_damage(1)
			if stone_pieces[board_position.x][board_position.y].health <= 0:
				stone_pieces[board_position.x][board_position.y].queue_free()  # Correct usage
				stone_pieces[board_position.x][board_position.y] = null  # Clear the reference
				emit_signal("remove_stone", board_position)
