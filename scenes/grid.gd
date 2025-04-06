extends Node2D

# State Machine
enum {wait, move};
var state

# Grid Variables
@export var width: int;
@export var height: int;
@export var x_start: int;
@export var y_start: int;
@export var offset: int;
@export var y_offset: int;

# Obstacle Stuff
@export var empty_spaces: PackedVector2Array
@export var dark_spaces: PackedVector2Array
@export var stone_spaces: PackedVector2Array
@export var time_spaces: PackedVector2Array

# Obstacle signals
signal damage_dark
signal make_dark
signal damage_stone
signal make_stone
signal damage_time
signal make_time

#Pieces array
var possible_pieces = [
preload("res://scenes/blue_piece.tscn"),
preload("res://scenes/gray_piece.tscn"),
preload("res://scenes/purple_piece.tscn"),
preload("res://scenes/red_piece.tscn"),
preload("res://scenes/yellow_piece.tscn")
] 

#Pieces in scene
var all_pieces = [];

# Swap Back Variables
var piece_one = null;
var piece_two = null;
var last_place = Vector2(0, 0);
var last_direction = Vector2(0, 0);
var move_checked = false;

#Touch Variables
var first_touch = Vector2(0,0);
var final_touch = Vector2(0,0);
var controlling = false;

func _ready():
	state = move;
	all_pieces = make_2d_array()
	spawn_pieces();
	spawn_dark();
	spawn_stone();
	spawn_time();
	
func restricted_fill(place):
		#check empty pieces
	if is_in_array(empty_spaces, place):
		return true
	if is_in_array(time_spaces, place):
		return true
	return false

func restricted_move(place):
	#Check the stone pieces
	if is_in_array(stone_spaces, place):
		return true
	return false

func is_in_array(array, item):
	for i in array.size():
		if array[i] == item:
			return true
	return false

func remove_from_array(array, item):
	for i in range(array.size() - 1, -1, -1):
		if array[i] == item:
			array.remove_at(i)
pass # Replace with function body.

	

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null);
	return array;

func spawn_pieces():
	for i in width:
		for j in height:
			if !restricted_fill(Vector2(i, j)):
				var rand = floor(randi_range(0, possible_pieces.size() - 1))
				var loops = 0
				var piece = possible_pieces[rand].instantiate()
				while(match_at(i,j,piece.color) && loops < 100):
					rand = floor(randi_range(0, possible_pieces.size() - 1))
					loops += 1
					piece = possible_pieces[rand].instantiate()
					
				add_child(piece)
				piece.set_position(grid_to_pixel(i, j))
				all_pieces[i][j] = piece

func spawn_dark():
	for i in dark_spaces.size():
		emit_signal("make_dark", dark_spaces[i])
		
func spawn_stone():
	for i in stone_spaces.size():
		emit_signal("make_stone",stone_spaces[i])

func spawn_time():
	for i in time_spaces.size():
		emit_signal("make_time",time_spaces[i])

func match_at(i, j, color):
	if i > 1:
		if all_pieces[i - 1][j] != null && all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color && all_pieces[i - 2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i ][j - 1] != null && all_pieces[i ][j - 2] != null:
			if all_pieces[i ][j - 1].color == color && all_pieces[i][j - 2].color == color:
				return true

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column;
	var new_y = y_start + -offset * row;
	return Vector2(new_x, new_y)

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset);
	var new_y = round((pixel_y - y_start) / -offset);
	return Vector2(new_x, new_y);

func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true;
	return false;

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y);
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)) && controlling:
			controlling = false;
			final_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y);
			touch_difference(first_touch, final_touch);

func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row];
	var other_piece = all_pieces[column + direction.x][row + direction.y];
	if first_piece != null && other_piece != null:
		if !restricted_move(Vector2(column, row)) and !restricted_move(Vector2(column, row) + direction):
			store_info(first_piece, other_piece, Vector2(column, row), direction);
			state = wait
			all_pieces[column][row] = other_piece;
			all_pieces[column + direction.x][row + direction.y] = first_piece;
			first_piece.move(grid_to_pixel(column + direction.x, row + direction.y));
			other_piece.move(grid_to_pixel(column, row));
			if !move_checked:
				find_matches()

func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece;
	piece_two = other_piece;
	last_place = place;
	last_direction = direction;
	pass

func swap_back():
	if piece_one != null && piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction);
	state = move
	move_checked = false
	pass

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1;
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1,0));
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0));
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0,1));
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0,-1));

func _process(delta):
	if state == move:
		touch_input();

func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color;
				if i > 0 && i < width - 1:
					if !is_piece_null(i - 1, j) && all_pieces[i + 1][j] != null && all_pieces[i + 1][j] != null:
						if all_pieces[i - 1][j].color == current_color && all_pieces[i + 1][j].color == current_color:
							match_and_dim(all_pieces[i - 1][j])
							match_and_dim(all_pieces[i][j])
							match_and_dim(all_pieces[i + 1][j])
				if j > 0 && j < height - 1:
					if all_pieces[i][j - 1] != null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j - 1].color == current_color && all_pieces[i][j + 1].color == current_color:
							match_and_dim(all_pieces[i][j - 1])
							match_and_dim(all_pieces[i][j])
							match_and_dim(all_pieces[i][j + 1])
	get_parent().get_node("destroy_timer").start();

func is_piece_null(column, row):
	if all_pieces[column][row] == null:
		return true
	return false
	
func match_and_dim(item):
	item.matched = true
	item.dim()
	pass

func destroy_matched():
	var was_matched = false;
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					damage_special(i, j)
					was_matched = true
					all_pieces[i][j].queue_free();
					all_pieces[i][j] != null
	move_checked = true
	if was_matched:
		get_parent().get_node("collapse_timer").start()
	else:
		swap_back()

func check_time(column, row):
	# Check Right
	if column < width - 1:
		emit_signal("damage_time", Vector2(column + 1, row))
	# Check Left
		emit_signal("damage_time", Vector2(column - 1, row))
	# Check Up
		emit_signal("damage_time", Vector2(column, row + 1))
	# Check Down
		emit_signal("damage_time", Vector2(column, row - 1))

		
func damage_special(column, row):
	emit_signal("damage_dark", Vector2(column, row))
	emit_signal("damage_stone", Vector2(column, row))
	check_time(column, row)

func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restricted_fill(Vector2(i, j)):
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("refill_timer").start()

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restricted_fill(Vector2(i, j)):
				var rand = floor(randi_range(0, possible_pieces.size() - 1));
				var loops = 0;
				var piece = possible_pieces[rand].instantiate();
				# Remove # if want to block matches to cascade
				#while(match_at(i,j,piece.color) && loops < 100):
				#	rand = floor(randi_range(0, possible_pieces.size() - 1));
				#	loops += 1;
				#	piece = possible_pieces[rand].instantiate();
				add_child(piece);
				piece.set_position(grid_to_pixel(i, j - y_offset));
				piece.move(grid_to_pixel(i,j));
				all_pieces[i][j] = piece;
	
	after_refill()

func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].color):
					find_matches()
					get_parent().get_node("destroy_timer").start()
					return
	state = move;
	move_checked = false;
	pass

func _on_destroy_timer_timeout():
	destroy_matched();

func _on_collapse_timer_timeout():
	collapse_columns()

func _on_refill_timer_timeout():
	refill_columns()

func _on_stone_holder_remove_stone(place):
	remove_from_array(stone_spaces, place)

func _on_time_holder_remove_time(place):
	remove_from_array(time_spaces, place)
	pass # Replace with function body.
