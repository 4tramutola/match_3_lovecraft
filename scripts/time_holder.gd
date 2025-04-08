extends Node2D

signal remove_time

var time_pieces = []
var width = 6
var height = 8
var time = preload("res://scenes/time.tscn")

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

func _on_grid_make_time(board_position):
	if time_pieces.size() == 0:
		time_pieces = make_2d_array()
	var current = time.instantiate()
	add_child(current)
	current.position = Vector2(board_position.x * 90 + 64, -board_position.y * 90 + 864)
	time_pieces[board_position.x][board_position.y] = current

func _on_grid_damage_time(board_position):
	if time_pieces.size() != 0:
		if board_position.x < width and board_position.y < height:
			if time_pieces[board_position.x][board_position.y] != null:
				time_pieces[board_position.x][board_position.y].take_damage(1)
				if time_pieces[board_position.x][board_position.y].health <= 0:
					time_pieces[board_position.x][board_position.y].queue_free()  # Correct usage
					time_pieces[board_position.x][board_position.y] = null  # Clear the reference
					emit_signal("remove_time", board_position)
