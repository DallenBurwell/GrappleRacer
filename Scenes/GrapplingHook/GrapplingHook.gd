extends Node2D

onready var line: Line2D = $Line
onready var direction: RayCast2D = $Direction

export var LENGTH: float = 250.0
export var speed: float = 1000
export (NodePath) var exception_path

var destination: Vector2
var shooting: bool = false
var line_length: float = 0.0

onready var tween = $Tween

func _ready():
	direction.add_exception(get_node(exception_path))

func _input(event):
	if Input.is_action_just_pressed("left_click"):
		direction.cast_to = get_global_mouse_position() - global_position
		direction.cast_to = direction.cast_to.normalized() * LENGTH
		
		direction.force_raycast_update()
		
		for i in line.get_point_count() - 1:
			line.remove_point(i)
		
		if direction.is_colliding():
			shooting = true
			destination = direction.get_collision_point()
			var final_length = (destination - global_position).length()
			tween.start()
			tween.interpolate_property($".", "line_length", 0.0, final_length, final_length / speed, Tween.TRANS_CUBIC, Tween.EASE_IN)

func _physics_process(delta):
	if shooting:
		for i in line.get_point_count() - 1:
			line.remove_point(i)
		
		var final_point: Vector2 = destination - global_position
		var end_point: Vector2 = final_point.normalized() * line_length
		
		line.add_point(Vector2(0,0))
		line.add_point(end_point)
		
#		if end_point.length() == final_point.length():
#			shooting = false