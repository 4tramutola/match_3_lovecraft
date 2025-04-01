extends Node2D

@export var color: String;
var move_tween;
var matched = false;


func _ready():
	move_tween = get_node("move_tween");


func move(target):
	var tween: Tween = create_tween();
	tween.tween_property(self,"position",target, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func dim():
	var sprite = get_node("Sprite2D");
	sprite.modulate = Color(1, 1, 1, .5);


pass;
