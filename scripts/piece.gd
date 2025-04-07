extends Node2D

@export var color: String;
var move_tween;
var matched = false;
@export var row_texture: Texture;
@export var column_texture: Texture;
@export var adjacent_texture: Texture;

var is_row_bomb = false
var is_column_bomb = false
var is_adjacent_bomb = false



func _ready():
	move_tween = get_node("move_tween");

func move(target):
	var tween: Tween = create_tween();
	tween.tween_property(self,"position",target, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _process(delta):
	pass

func make_column_bomb():
	is_column_bomb = true
	$Sprite2D.texture = column_texture
	$Sprite2D.modulate = Color(1, 1, 1, 1)

func make_row_bomb():
	is_row_bomb = true
	$Sprite2D.texture = row_texture
	$Sprite2D.modulate = Color(1, 1, 1, 1)

func make_adjacent_bomb():
	is_adjacent_bomb = true
	$Sprite2D.texture = adjacent_texture
	$Sprite2D.modulate = Color(1, 1, 1, 1)

func dim():
	var sprite = get_node("Sprite2D");
	sprite.modulate = Color(1, 1, 1, .5);
