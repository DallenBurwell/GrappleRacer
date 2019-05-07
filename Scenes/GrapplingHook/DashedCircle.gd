extends Node2D

export var HINT_COLOR: Color = Color(0.15, 0.78, 1)
export var DASHED_LINE_WIDTH: float = 50.0
export var LENGTH: float = 250.0
export var ROTATE: float = 7.0

func _physics_process(delta):
	rotate(deg2rad(ROTATE * delta))

func _draw():
	var num_dashed_lines = LENGTH * 2 * PI / DASHED_LINE_WIDTH
	
	for i in num_dashed_lines:
		var start_angle = i * 360 / num_dashed_lines
		var end_angle = (i + 0.5) * 360 / num_dashed_lines
		draw_circle_arc(Vector2(0,0), LENGTH, start_angle, end_angle, HINT_COLOR)

func draw_circle_arc(center, radius, angle_from, angle_to, color):
    var nb_points = 32
    var points_arc = PoolVector2Array()

    for i in range(nb_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

    for index_point in range(nb_points):
        draw_line(points_arc[index_point], points_arc[index_point + 1], color, 3)
