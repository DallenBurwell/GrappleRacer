extends Node2D

signal hooked
signal unhooked

onready var line: Line2D = $Line
onready var direction: RayCast2D = $Direction

export var LENGTH: float = 500.0

var destination: Vector2
var hooked_at: Vector2

var hooked: bool = false

onready var indic = $Indicator

func _ready():
	show()

func _input(event):
	if Input.is_action_just_pressed("left_click"):
		if hookable():
			hooked = true
			hooked_at = destination
			indic.hide()
			emit_signal("hooked")
	
	if Input.is_action_just_released("left_click"):
		if hooked:
			hooked = false
			indic.show()
			
			for i in line.get_point_count() - 1:
				line.remove_point(i)
			
			emit_signal("unhooked")

func _physics_process(delta):
	direction.cast_to = get_global_mouse_position() - global_position
	direction.cast_to = direction.cast_to.normalized() * 10000
	
	direction.force_raycast_update()
	
	destination = direction.get_collision_point()
	
	indic.position = destination - global_position
	
	if not in_range():
		indic.self_modulate = Color.red
	else:
		indic.self_modulate = Color.white
	
	if hooked:
		for i in line.get_point_count() - 1:
				line.remove_point(i)
		
		line.add_point(Vector2(0,0))
		line.add_point(hooked_at - global_position)

func add_exception(node: Object):
	direction.add_exception(node)

func in_range() -> bool:
	return (destination - global_position).length() <= LENGTH

func hookable() -> bool:
	if in_range():
		return true
		
		
		var hooked_object = direction.get_collider()
		if hooked_object and hooked_object.has_method("is_grappable") and hooked_object.is_grappable():
			return true
	return false